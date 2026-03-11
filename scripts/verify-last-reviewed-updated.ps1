param(
    [Parameter(Mandatory = $true)]
    [string]$BaseRef,
    [string]$HeadRef = "HEAD"
)

$ErrorActionPreference = "Stop"

$utf8BomChar = [char]0xFEFF
$metadataPattern = '^<sub><(?:em|i)>\s*Status:\s*(?<Status>[^|]+?)\s*\|\s*Audience:\s*(?<Audience>[^|]+?)\s*\|\s*Owner:\s*(?<Owner>[^|]+?)\s*\|\s*Last Reviewed:\s*(?<LastReviewed>[^|]+?)\s*\|\s*Canonical:\s*(?<Canonical>[^|<]+?)\s*</(?:em|i)></sub>$'

function Invoke-Git {
    param(
        [string[]]$Arguments
    )

    $output = & git @Arguments 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "git $($Arguments -join ' ') failed: $output"
    }

    return @($output)
}

function Test-GitCommitRef {
    param(
        [string]$Ref
    )

    & git rev-parse --verify --quiet "${Ref}^{commit}" *> $null
    return ($LASTEXITCODE -eq 0)
}

function Get-LastReviewedFromLine {
    param(
        [string]$Line
    )

    if ($null -eq $Line) {
        return $null
    }

    $clean = $Line.TrimStart($utf8BomChar)
    if ($clean -notmatch $metadataPattern) {
        return $null
    }

    $value = $Matches['LastReviewed'].Trim()
    if ($value -notmatch '^\d{4}-\d{2}-\d{2}$') {
        return $null
    }

    return $value
}

if ($BaseRef -match '^0+$') {
    Write-Host "Base ref is all zeros (initial push). Skipping Last Reviewed verification."
    exit 0
}

if (-not (Test-GitCommitRef -Ref $BaseRef)) {
    throw "Base ref '$BaseRef' is not available in this checkout."
}

if (-not (Test-GitCommitRef -Ref $HeadRef)) {
    throw "Head ref '$HeadRef' is not available in this checkout."
}

$changedMarkdownFiles = Invoke-Git -Arguments @(
    "diff",
    "--name-only",
    "--diff-filter=M",
    "${BaseRef}...${HeadRef}",
    "--",
    "*.md"
) |
    Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
    Sort-Object -Unique

if (-not $changedMarkdownFiles -or $changedMarkdownFiles.Count -eq 0) {
    Write-Host "No modified markdown files found between '$BaseRef' and '$HeadRef'."
    exit 0
}

$failures = New-Object System.Collections.Generic.List[string]

foreach ($file in $changedMarkdownFiles) {
    $baseSpec = "{0}:{1}" -f $BaseRef, $file
    $headSpec = "{0}:{1}" -f $HeadRef, $file

    $baseContent = Invoke-Git -Arguments @("show", $baseSpec)
    $headContent = Invoke-Git -Arguments @("show", $headSpec)

    $baseLine1 = if ($baseContent.Count -gt 0) { $baseContent[0] } else { "" }
    $headLine1 = if ($headContent.Count -gt 0) { $headContent[0] } else { "" }

    $baseLastReviewed = Get-LastReviewedFromLine -Line $baseLine1
    $headLastReviewed = Get-LastReviewedFromLine -Line $headLine1

    if (-not $baseLastReviewed) {
        $failures.Add("${file}: base revision metadata line is invalid or missing Last Reviewed value.")
        continue
    }

    if (-not $headLastReviewed) {
        $failures.Add("${file}: head revision metadata line is invalid or missing Last Reviewed value.")
        continue
    }

    if ($baseLastReviewed -eq $headLastReviewed) {
        $failures.Add("${file}: Last Reviewed was not updated (still '$headLastReviewed').")
    }
}

if ($failures.Count -gt 0) {
    Write-Host "Last Reviewed verification failed with $($failures.Count) issue(s):"
    $failures | ForEach-Object { Write-Host "- $_" }
    exit 1
}

Write-Host "Last Reviewed verification passed for $($changedMarkdownFiles.Count) modified markdown file(s)."
exit 0
