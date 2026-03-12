param(
    [string]$Date = (Get-Date).ToString("yyyy-MM-dd")
)

$ErrorActionPreference = "Stop"

$metadataPattern = '^<sub><(?<Tag>em|i)>\s*Status:\s*(?<Status>[^|]+?)\s*\|\s*Audience:\s*(?<Audience>[^|]+?)\s*\|\s*Doc-Type:\s*(?<DocType>[^|]+?)\s*\|\s*Owner:\s*(?<Owner>[^|]+?)\s*\|\s*Last Reviewed:\s*(?<LastReviewed>[^|]+?)\s*\|\s*Canonical:\s*(?<Canonical>[^|<]+?)\s*</\k<Tag>></sub>$'

function Invoke-Git {
    param(
        [string[]]$Arguments
    )

    $output = & git @Arguments 2>&1
    if ($LASTEXITCODE -ne 0) {
        $rendered = if ($null -eq $output) { "" } else { @($output) -join [Environment]::NewLine }
        throw "git $($Arguments -join ' ') failed: $rendered"
    }

    if ($null -eq $output) {
        return @()
    }

    return @($output)
}

function Read-Utf8TextFile {
    param(
        [string]$Path
    )

    $bytes = [System.IO.File]::ReadAllBytes($Path)
    $hasBom = $bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF

    if ($hasBom) {
        $text = [System.Text.Encoding]::UTF8.GetString($bytes, 3, $bytes.Length - 3)
    }
    else {
        $text = [System.Text.Encoding]::UTF8.GetString($bytes)
    }

    return @{
        Text = $text
        HasBom = $hasBom
    }
}

$stagedMarkdownFiles = Invoke-Git -Arguments @(
    "diff",
    "--cached",
    "--name-only",
    "--diff-filter=ACMR",
    "--",
    "*.md"
) |
    Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
    Sort-Object -Unique

if (-not $stagedMarkdownFiles -or $stagedMarkdownFiles.Count -eq 0) {
    Write-Host "No staged markdown files to update."
    exit 0
}

$updatedCount = 0
$alreadyCurrentCount = 0
$failures = New-Object System.Collections.Generic.List[string]

foreach ($file in $stagedMarkdownFiles) {
    if (-not (Test-Path -LiteralPath $file -PathType Leaf)) {
        continue
    }

    $resolvedPath = (Resolve-Path -LiteralPath $file).ProviderPath
    $fileData = Read-Utf8TextFile -Path $resolvedPath
    $text = $fileData.Text

    if ([string]::IsNullOrEmpty($text)) {
        $failures.Add("${file}: file is empty; cannot update Last Reviewed metadata.")
        continue
    }

    $newline = if ($text -match "`r`n") { "`r`n" } else { "`n" }
    $lines = $text -split "`r`n|`n", -1

    if ($lines.Count -lt 1 -or [string]::IsNullOrEmpty($lines[0])) {
        $failures.Add("${file}: missing metadata on line 1.")
        continue
    }

    $line1 = $lines[0]
    if ($line1 -notmatch $metadataPattern) {
        $failures.Add("${file}: line 1 does not match required metadata format.")
        continue
    }

    $tag = $Matches['Tag'].Trim()
    $status = $Matches['Status'].Trim()
    $audience = $Matches['Audience'].Trim()
    $docType = $Matches['DocType'].Trim()
    $owner = $Matches['Owner'].Trim()
    $lastReviewed = $Matches['LastReviewed'].Trim()
    $canonical = $Matches['Canonical'].Trim()

    if ($lastReviewed -eq $Date) {
        $alreadyCurrentCount++
        continue
    }

    $lines[0] = "<sub><$tag>Status: $status | Audience: $audience | Doc-Type: $docType | Owner: $owner | Last Reviewed: $Date | Canonical: $canonical</$tag></sub>"
    $newText = $lines -join $newline

    $encoding = [System.Text.UTF8Encoding]::new($fileData.HasBom)
    [System.IO.File]::WriteAllText($resolvedPath, $newText, $encoding)

    Invoke-Git -Arguments @("add", "--", $file) | Out-Null
    $updatedCount++
}

if ($failures.Count -gt 0) {
    Write-Host "Last Reviewed auto-update failed with $($failures.Count) issue(s):"
    $failures | ForEach-Object { Write-Host "- $_" }
    exit 1
}

Write-Host "Last Reviewed auto-update complete: updated $updatedCount file(s), already current $alreadyCurrentCount file(s)."
exit 0
