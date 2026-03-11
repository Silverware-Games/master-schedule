param(
    [string]$Root = "."
)

$ErrorActionPreference = "Stop"

$allowedStatus = @("Active", "Draft", "Needs Review", "Archived", "Replaced By")
$allowedCanonical = @("Yes", "No")
$utf8BomChar = [char]0xFEFF
$metadataPattern = '^<sub><(?:em|i)>\s*Status:\s*(?<Status>[^|]+?)\s*\|\s*Audience:\s*(?<Audience>[^|]+?)\s*\|\s*Owner:\s*(?<Owner>[^|]+?)\s*\|\s*Last Reviewed:\s*(?<LastReviewed>[^|]+?)\s*\|\s*Canonical:\s*(?<Canonical>[^|<]+?)\s*</(?:em|i)></sub>$'

function Parse-MetadataLine {
    param(
        [string]$Line
    )

    $lineWithoutBom = $Line.TrimStart($utf8BomChar)

    if ($lineWithoutBom -notmatch $metadataPattern) {
        return $null
    }

    return @{
        Status = $Matches['Status'].Trim()
        Audience = $Matches['Audience'].Trim()
        Owner = $Matches['Owner'].Trim()
        LastReviewed = $Matches['LastReviewed'].Trim()
        Canonical = $Matches['Canonical'].Trim()
    }
}

$markdownFiles = Get-ChildItem -Path $Root -Recurse -File -Filter *.md |
    Where-Object { $_.FullName -notmatch "[\\/]\\.git[\\/]" } |
    Sort-Object FullName

if (-not $markdownFiles) {
    Write-Host "No markdown files found."
    exit 0
}

$failures = New-Object System.Collections.Generic.List[string]

foreach ($file in $markdownFiles) {
    $relativePath = Resolve-Path -LiteralPath $file.FullName -Relative
    if ($relativePath.StartsWith(".\\")) {
        $relativePath = $relativePath.Substring(2)
    }
    if ($relativePath.StartsWith("./")) {
        $relativePath = $relativePath.Substring(2)
    }

    $lines = Get-Content -Path $file.FullName

    if ($lines.Count -lt 1) {
        $failures.Add("${relativePath}: expected metadata on line 1.")
        continue
    }

    $line1 = $lines[0]
    $metadata = Parse-MetadataLine -Line $line1

    if (-not $metadata) {
        $failures.Add("${relativePath}: line 1 must match '<sub><em>Status: <...> | Audience: <...> | Owner: <...> | Last Reviewed: <YYYY-MM-DD> | Canonical: <Yes|No></em></sub>' (found '$line1').")
        continue
    }

    foreach ($key in @("Status", "Audience", "Owner", "LastReviewed", "Canonical")) {
        $value = $metadata[$key]

        switch ($key) {
            "Status" {
                if ($allowedStatus -notcontains $value) {
                    $failures.Add("${relativePath}: invalid Status '$value'. Allowed: $($allowedStatus -join ", ").")
                }
            }
            "Audience" {
                if ([string]::IsNullOrWhiteSpace($value)) {
                    $failures.Add("${relativePath}: Audience cannot be empty.")
                }
            }
            "Owner" {
                if ([string]::IsNullOrWhiteSpace($value)) {
                    $failures.Add("${relativePath}: Owner cannot be empty.")
                }
            }
            "LastReviewed" {
                if ($value -notmatch "^\d{4}-\d{2}-\d{2}$") {
                    $failures.Add("${relativePath}: Last Reviewed must use YYYY-MM-DD (found '$value').")
                }
                else {
                    try {
                        [void][datetime]::ParseExact($value, "yyyy-MM-dd", [Globalization.CultureInfo]::InvariantCulture)
                    }
                    catch {
                        $failures.Add("${relativePath}: Last Reviewed is not a valid date ('$value').")
                    }
                }
            }
            "Canonical" {
                if ($allowedCanonical -notcontains $value) {
                    $failures.Add("${relativePath}: Canonical must be Yes or No (found '$value').")
                }
            }
        }
    }

}

if ($failures.Count -gt 0) {
    Write-Host "Doc metadata lint failed with $($failures.Count) issue(s):"
    $failures | ForEach-Object { Write-Host "- $_" }
    exit 1
}

Write-Host "Doc metadata lint passed for $($markdownFiles.Count) markdown file(s)."
exit 0
