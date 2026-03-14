param(
    [string]$Root = ".",
    [string]$RepoMapPath = "docs/indexes/repo-map.md",
    [switch]$Regenerate,
    [switch]$Stage,
    [switch]$OnlyChangedDocs
)

$ErrorActionPreference = "Stop"

$allowedStatus = @("Active", "Draft", "Needs Review", "Archived", "Replaced By")
$allowedDocTypes = @("Orientation", "Reference", "Workflow")
$utf8BomChar = [char]0xFEFF
$metadataPattern = '^<sub><(?<Tag>em|i)>\s*Status:\s*(?<Status>[^|]+?)\s*\|\s*Audience:\s*(?<Audience>[^|]+?)\s*\|\s*Doc-Type:\s*(?<DocType>[^|]+?)\s*\|\s*Owner:\s*(?<Owner>[^|]+?)\s*\|\s*Last Reviewed:\s*(?<LastReviewed>[^|]+?)\s*\|\s*Canonical:\s*(?<Canonical>[^|<]+?)\s*</\k<Tag>></sub>$'
$failures = New-Object System.Collections.Generic.List[string]

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

function Get-MetadataFromMetadataLine {
    param(
        [string]$Line
    )

    $lineWithoutBom = $Line.TrimStart($utf8BomChar)

    if ($lineWithoutBom -notmatch $metadataPattern) {
        return $null
    }

    return @{
        Tag = $Matches['Tag'].Trim()
        Status = $Matches['Status'].Trim()
        Audience = $Matches['Audience'].Trim()
        DocType = $Matches['DocType'].Trim()
        Owner = $Matches['Owner'].Trim()
        LastReviewed = $Matches['LastReviewed'].Trim()
        Canonical = $Matches['Canonical'].Trim()
    }
}

function Get-DocTitle {
    param(
        [string[]]$Lines
    )

    foreach ($line in $Lines) {
        if ($line -match '^#+\s+(.+)$') {
            return $Matches[1].Trim()
        }
    }

    return $null
}

function Build-RegistryRow {
    param(
        [string]$DocText,
        [string]$Link,
        [string]$Title,
        [string]$Audience,
        [string]$Purpose,
        [string]$DocType,
        [string]$Status,
        [string]$Owner,
        [string]$LastReviewed
    )

    return "| [$DocText]($Link) | $Title | $Audience | $Purpose | $DocType | $Status | $Owner | $LastReviewed |"
}

$rootResolved = Resolve-Path -LiteralPath $Root
$rootPath = $rootResolved.ProviderPath
$repoMapFullPath = Join-Path $rootPath $RepoMapPath
$rootUri = [System.Uri]::new($rootPath.TrimEnd([System.IO.Path]::DirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar)

$changedMarkdownSet = $null
if ($Regenerate -and $OnlyChangedDocs) {
    Push-Location $rootPath
    try {
        $changedMarkdownFiles = Invoke-Git -Arguments @(
            "diff",
            "--cached",
            "--name-only",
            "--diff-filter=ACMR",
            "--",
            "*.md"
        ) |
            Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
            ForEach-Object { ($_ -replace '\\', '/').Trim() } |
            Sort-Object -Unique
    }
    finally {
        Pop-Location
    }

    $changedMarkdownSet = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($file in $changedMarkdownFiles) {
        $changedMarkdownSet.Add($file) | Out-Null
    }
}

if (-not (Test-Path -LiteralPath $repoMapFullPath -PathType Leaf)) {
    Write-Host "Repo map file not found at '$RepoMapPath'."
    exit 1
}

$repoMapDir = Split-Path -Path $repoMapFullPath -Parent
$repoMapFile = Read-Utf8TextFile -Path $repoMapFullPath
$newline = if ($repoMapFile.Text -match "`r`n") {
    "`r`n"
}
elseif ($repoMapFile.Text -match "`r") {
    "`r"
}
else {
    "`n"
}

$lines = $repoMapFile.Text -split "`r`n|`n|`r", -1

if (-not $lines -or $lines.Count -lt 1) {
    Write-Host "Repo map file '$RepoMapPath' is empty."
    exit 1
}

$sectionStart = -1
$sectionMatchReason = "none"
for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match '^(?i)\s*#{2,6}\s+Major\s+Document\s+Registry\b.*$') {
        $sectionStart = $i
        $sectionMatchReason = "major-document-registry-heading"
        break
    }
}

if ($sectionStart -lt 0) {
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match '^(?i)\s*\|\s*Doc\s*\|\s*Title\s*\|\s*Audience\s*\|\s*Purpose\s*\|\s*Doc\s*Type\s*\|\s*Status\s*\|\s*Owner\s*\|\s*Last\s*Reviewed\s*\|\s*$') {
            $sectionStart = $i
            $sectionMatchReason = "registry-table-header"
            break
        }
    }
}

if ($sectionStart -lt 0) {
    $sectionMatchReason = "whole-file-fallback"
}

$registryRows = New-Object System.Collections.Generic.List[object]
$tableLikeLines = New-Object System.Collections.Generic.List[object]
$scanStartLineIndex = if ($sectionStart -ge 0) { $sectionStart + 1 } else { 0 }
$scanEndLineIndex = $lines.Count - 1
if ($sectionStart -ge 0) {
    for ($i = $sectionStart + 1; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]

        if ($line -match '^\s*##\s+') {
            $scanEndLineIndex = $i - 1
            break
        }

        if ($line -match '^\s*\|') {
            $tableLikeLines.Add([pscustomobject]@{
                LineIndex = $i
                RowText = $line
            })
        }

        if ($line -match '^\s*\|\s*\[') {
            $registryRows.Add([pscustomobject]@{
                LineIndex = $i
                RowText = $line
            })
        }
    }
}
else {
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        if ($line -match '^\s*\|') {
            $tableLikeLines.Add([pscustomobject]@{
                LineIndex = $i
                RowText = $line
            })
        }

        if ($line -match '^\s*\|\s*\[') {
            $registryRows.Add([pscustomobject]@{
                LineIndex = $i
                RowText = $line
            })
        }
    }
}

if ($registryRows.Count -eq 0) {
    Write-Host "No registry rows found in '$RepoMapPath'."
    Write-Host "Diagnostics:"
    Write-Host "- Section detection mode: $sectionMatchReason"
    if ($sectionStart -ge 0) {
        $anchorPreview = $lines[$sectionStart].Trim()
        Write-Host "- Anchor line: $($sectionStart + 1): $anchorPreview"
    }
    else {
        Write-Host "- Anchor line: none (no section/table header match)"
    }

    Write-Host "- Scan range: lines $($scanStartLineIndex + 1)-$($scanEndLineIndex + 1)"
    Write-Host "- File length (chars): $($repoMapFile.Text.Length)"
    Write-Host "- Newline style detected: $(if ($newline -eq "`r`n") { "CRLF" } elseif ($newline -eq "`r") { "CR" } else { "LF/none" })"
    Write-Host "- Table-like lines found: $($tableLikeLines.Count)"

    if ($tableLikeLines.Count -gt 0) {
        Write-Host "- First table-like lines:"
        foreach ($entry in ($tableLikeLines | Select-Object -First 5)) {
            $preview = $entry.RowText.Trim()
            if ($preview.Length -gt 180) {
                $preview = $preview.Substring(0, 177) + "..."
            }

            Write-Host "  - L$($entry.LineIndex + 1): $preview"
        }
    }

    Write-Host "- Expected registry row format: | [docs/path.md](relative/link.md) | Title | Audience | Purpose | Doc Type | Status | Owner | Last Reviewed |"
    exit 1
}

$rowPattern = '^\s*\|\s*\[(?<docText>[^\]]+)\]\((?<link>[^)]+)\)\s*\|\s*(?<title>.*?)\s*\|\s*(?<audience>.*?)\s*\|\s*(?<purpose>.*?)\s*\|\s*(?<docType>.*?)\s*\|\s*(?<status>.*?)\s*\|\s*(?<owner>.*?)\s*\|\s*(?<reviewed>.*?)\s*\|\s*$'
$rowsUpdated = 0
$repoMapHeaderUpdated = $false

foreach ($rowEntry in $registryRows) {
    $row = $rowEntry.RowText
    $rowLineNumber = $rowEntry.LineIndex + 1

    if ($row -notmatch $rowPattern) {
        $failures.Add("${RepoMapPath}: could not parse registry row at line $rowLineNumber. Expected '| [doc](link) | title | audience | purpose | doc type | status | owner | last reviewed |'. Row: $row")
        continue
    }

    $docText = $Matches['docText'].Trim()
    $link = $Matches['link'].Trim()
    $tableTitle = $Matches['title'].Trim()
    $tableAudience = $Matches['audience'].Trim()
    $tablePurpose = $Matches['purpose'].Trim()
    $tableDocType = $Matches['docType'].Trim()
    $tableStatus = $Matches['status'].Trim()
    $tableOwner = $Matches['owner'].Trim()
    $tableReviewed = $Matches['reviewed'].Trim()

    if ((-not $Regenerate) -and ($allowedDocTypes -notcontains $tableDocType)) {
        $failures.Add("${RepoMapPath}: invalid Doc-Type '$tableDocType' in row link '$link'.")
        continue
    }

    if ((-not $Regenerate) -and ($allowedStatus -notcontains $tableStatus)) {
        $failures.Add("${RepoMapPath}: invalid status '$tableStatus' in row link '$link'.")
        continue
    }

    if ($link -match '^[a-zA-Z]+://') {
        $failures.Add("${RepoMapPath}: external URL '$link' is not supported in status verification.")
        continue
    }

    $candidatePath = Join-Path $repoMapDir $link

    try {
        $targetResolved = Resolve-Path -LiteralPath $candidatePath -ErrorAction Stop
        $targetPath = $targetResolved.ProviderPath
    }
    catch {
        $failures.Add("${RepoMapPath}: linked file '$link' was not found.")
        continue
    }

    $targetLines = Get-Content -Path $targetPath -Encoding UTF8 -ErrorAction SilentlyContinue
    if (-not $targetLines -or $targetLines.Count -lt 1) {
        $relativeTarget = Resolve-Path -LiteralPath $targetPath -Relative
        $failures.Add("${RepoMapPath}: linked file '$relativeTarget' is empty.")
        continue
    }

    $firstLine = $targetLines[0].TrimStart($utf8BomChar)

    $docMetadata = Get-MetadataFromMetadataLine -Line $firstLine
    if (-not $docMetadata) {
        $relativeTarget = Resolve-Path -LiteralPath $targetPath -Relative
        $failures.Add("${RepoMapPath}: linked file '$relativeTarget' is missing the required metadata line format.")
        continue
    }

    $docStatus = $docMetadata.Status
    $docAudience = $docMetadata.Audience
    $docDocType = $docMetadata.DocType
    $docOwner = $docMetadata.Owner
    $docLastReviewed = $docMetadata.LastReviewed
    $docTitle = Get-DocTitle -Lines $targetLines
    $syncedTitle = if ([string]::IsNullOrWhiteSpace($docTitle)) { $tableTitle } else { $docTitle }
    $targetRepoRelative = $rootUri.MakeRelativeUri([System.Uri]::new($targetPath)).ToString() -replace '%20', ' '

    if ($Regenerate -and $OnlyChangedDocs -and (-not $changedMarkdownSet.Contains($targetRepoRelative))) {
        continue
    }

    if ($allowedStatus -notcontains $docStatus) {
        $relativeTarget = Resolve-Path -LiteralPath $targetPath -Relative
        $failures.Add("${RepoMapPath}: linked file '$relativeTarget' has invalid Status '$docStatus'.")
        continue
    }

    if ($allowedDocTypes -notcontains $docDocType) {
        $relativeTarget = Resolve-Path -LiteralPath $targetPath -Relative
        $failures.Add("${RepoMapPath}: linked file '$relativeTarget' has invalid Doc-Type '$docDocType'.")
        continue
    }

    if ($Regenerate) {
        $needsUpdate =
            $tableTitle -ne $syncedTitle -or
            $tableAudience -ne $docAudience -or
            $tableDocType -ne $docDocType -or
            $tableStatus -ne $docStatus -or
            $tableOwner -ne $docOwner -or
            $tableReviewed -ne $docLastReviewed

        if ($needsUpdate) {
            $lines[$rowEntry.LineIndex] = Build-RegistryRow -DocText $docText -Link $link -Title $syncedTitle -Audience $docAudience -Purpose $tablePurpose -DocType $docDocType -Status $docStatus -Owner $docOwner -LastReviewed $docLastReviewed
            $rowsUpdated++
        }

        continue
    }

    if ($docStatus -ne $tableStatus) {
        $relativeTarget = Resolve-Path -LiteralPath $targetPath -Relative
        $failures.Add("${RepoMapPath}: status mismatch for '$relativeTarget' (table='$tableStatus', doc='$docStatus').")
    }

    if ($docDocType -ne $tableDocType) {
        $relativeTarget = Resolve-Path -LiteralPath $targetPath -Relative
        $failures.Add("${RepoMapPath}: Doc-Type mismatch for '$relativeTarget' (table='$tableDocType', doc='$docDocType').")
    }
}

if ($Regenerate -and $rowsUpdated -gt 0) {
    $repoMapMetadata = Get-MetadataFromMetadataLine -Line $lines[0]
    if (-not $repoMapMetadata) {
        $failures.Add("${RepoMapPath}: metadata header is invalid; could not update Last Reviewed after regeneration.")
    }
    else {
        $today = (Get-Date).ToString("yyyy-MM-dd")
        if ($repoMapMetadata.LastReviewed -ne $today) {
            $tag = $repoMapMetadata.Tag
            $lines[0] = "<sub><$tag>Status: $($repoMapMetadata.Status) | Audience: $($repoMapMetadata.Audience) | Doc-Type: $($repoMapMetadata.DocType) | Owner: $($repoMapMetadata.Owner) | Last Reviewed: $today | Canonical: $($repoMapMetadata.Canonical)</$tag></sub>"
            $repoMapHeaderUpdated = $true
        }
    }
}

if ($failures.Count -gt 0) {
    Write-Host "Repo map status verification failed with $($failures.Count) issue(s):"
    $failures | ForEach-Object { Write-Host "- $_" }
    exit 1
}

if ($Regenerate -and ($rowsUpdated -gt 0 -or $repoMapHeaderUpdated)) {
    $content = $lines -join $newline
    if (-not $content.EndsWith($newline)) {
        $content += $newline
    }

    [System.IO.File]::WriteAllText($repoMapFullPath, $content, [System.Text.UTF8Encoding]::new($false))

    if ($Stage) {
        Push-Location $rootPath
        try {
            Invoke-Git -Arguments @("add", "--", $RepoMapPath) | Out-Null
        }
        finally {
            Pop-Location
        }

        Write-Host "Repo map regenerated and staged: updated $rowsUpdated registry row(s)."
    }
    else {
        Write-Host "Repo map regenerated: updated $rowsUpdated registry row(s)."
    }

    exit 0
}

if ($Regenerate) {
    Write-Host "Repo map already up to date for $($registryRows.Count) registry row(s)."
    exit 0
}

Write-Host "Repo map status verification passed for $($registryRows.Count) registry row(s)."
exit 0
