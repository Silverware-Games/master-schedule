param(
    [string]$Root = ".",
    [string]$RepoMapPath = "docs/indexes/repo-map.md"
)

$ErrorActionPreference = "Stop"

$allowedStatus = @("Active", "Draft", "Needs Review", "Archived", "Replaced By")
$allowedDocTypes = @("Orientation", "Reference", "Workflow")
$utf8BomChar = [char]0xFEFF
$metadataPattern = '^<sub><(?:em|i)>\s*Status:\s*(?<Status>[^|]+?)\s*\|\s*Audience:\s*(?<Audience>[^|]+?)\s*\|\s*Doc-Type:\s*(?<DocType>[^|]+?)\s*\|\s*Owner:\s*(?<Owner>[^|]+?)\s*\|\s*Last Reviewed:\s*(?<LastReviewed>[^|]+?)\s*\|\s*Canonical:\s*(?<Canonical>[^|<]+?)\s*</(?:em|i)></sub>$'
$failures = New-Object System.Collections.Generic.List[string]

function Get-MetadataFromMetadataLine {
    param(
        [string]$Line
    )

    $lineWithoutBom = $Line.TrimStart($utf8BomChar)

    if ($lineWithoutBom -notmatch $metadataPattern) {
        return $null
    }

    return @{
        Status = $Matches['Status'].Trim()
        DocType = $Matches['DocType'].Trim()
    }
}

$rootResolved = Resolve-Path -LiteralPath $Root
$rootPath = $rootResolved.ProviderPath
$repoMapFullPath = Join-Path $rootPath $RepoMapPath

if (-not (Test-Path -LiteralPath $repoMapFullPath -PathType Leaf)) {
    Write-Host "Repo map file not found at '$RepoMapPath'."
    exit 1
}

$repoMapDir = Split-Path -Path $repoMapFullPath -Parent
$lines = Get-Content -Path $repoMapFullPath

$sectionStart = -1
for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match '^##\s+Major Document Registry\s*$') {
        $sectionStart = $i
        break
    }
}

if ($sectionStart -lt 0) {
    Write-Host "Could not find '## Major Document Registry' section in '$RepoMapPath'."
    exit 1
}

$registryRows = New-Object System.Collections.Generic.List[string]
for ($i = $sectionStart + 1; $i -lt $lines.Count; $i++) {
    $line = $lines[$i]

    if ($line -match '^##\s+') {
        break
    }

    if ($line -match '^\|\s*\[') {
        $registryRows.Add($line)
    }
}

if ($registryRows.Count -eq 0) {
    Write-Host "No registry rows found in '$RepoMapPath'."
    exit 1
}

$rowPattern = '^\|\s*\[(?<docText>[^\]]+)\]\((?<link>[^)]+)\)\s*\|\s*(?<title>.*?)\s*\|\s*(?<audience>.*?)\s*\|\s*(?<purpose>.*?)\s*\|\s*(?<docType>.*?)\s*\|\s*(?<status>.*?)\s*\|\s*(?<owner>.*?)\s*\|\s*(?<reviewed>.*?)\s*\|$'

foreach ($row in $registryRows) {
    if ($row -notmatch $rowPattern) {
        $failures.Add("${RepoMapPath}: could not parse registry row: $row")
        continue
    }

    $link = $Matches['link'].Trim()
    $tableDocType = $Matches['docType'].Trim()
    $tableStatus = $Matches['status'].Trim()

    if ($allowedDocTypes -notcontains $tableDocType) {
        $failures.Add("${RepoMapPath}: invalid Doc-Type '$tableDocType' in row link '$link'.")
        continue
    }

    if ($allowedStatus -notcontains $tableStatus) {
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

    $firstLine = Get-Content -Path $targetPath -TotalCount 1
    if (-not $firstLine) {
        $relativeTarget = Resolve-Path -LiteralPath $targetPath -Relative
        $failures.Add("${RepoMapPath}: linked file '$relativeTarget' is empty.")
        continue
    }

    $firstLine = $firstLine.TrimStart($utf8BomChar)

    $docMetadata = Get-MetadataFromMetadataLine -Line $firstLine
    if (-not $docMetadata) {
        $relativeTarget = Resolve-Path -LiteralPath $targetPath -Relative
        $failures.Add("${RepoMapPath}: linked file '$relativeTarget' is missing the required metadata line format.")
        continue
    }

    $docStatus = $docMetadata.Status
    $docDocType = $docMetadata.DocType

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

    if ($docStatus -ne $tableStatus) {
        $relativeTarget = Resolve-Path -LiteralPath $targetPath -Relative
        $failures.Add("${RepoMapPath}: status mismatch for '$relativeTarget' (table='$tableStatus', doc='$docStatus').")
    }

    if ($docDocType -ne $tableDocType) {
        $relativeTarget = Resolve-Path -LiteralPath $targetPath -Relative
        $failures.Add("${RepoMapPath}: Doc-Type mismatch for '$relativeTarget' (table='$tableDocType', doc='$docDocType').")
    }
}

if ($failures.Count -gt 0) {
    Write-Host "Repo map status verification failed with $($failures.Count) issue(s):"
    $failures | ForEach-Object { Write-Host "- $_" }
    exit 1
}

Write-Host "Repo map status verification passed for $($registryRows.Count) registry row(s)."
exit 0
