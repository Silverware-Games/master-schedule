param(
    [string]$Root = "."
)

$ErrorActionPreference = "Stop"

$allowedStatus = @("Active", "Draft", "Needs Review", "Archived", "Replaced By")
$allowedCanonical = @("Yes", "No")
$utf8BomChar = [char]0xFEFF

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

    if ($lines.Count -lt 5) {
        $failures.Add("${relativePath}: expected at least 5 lines for metadata header.")
        continue
    }

    $checks = @(
        @{ Key = "Status"; Pattern = "^Status:\s*(.+)$" },
        @{ Key = "Audience"; Pattern = "^Audience:\s*(.+)$" },
        @{ Key = "Owner"; Pattern = "^Owner:\s*(.+)$" },
        @{ Key = "Last Reviewed"; Pattern = "^Last Reviewed:\s*(.+)$" },
        @{ Key = "Canonical"; Pattern = "^Canonical:\s*(.+)$" }
    )

    foreach ($index in 0..($checks.Count - 1)) {
        $key = $checks[$index].Key
        $pattern = $checks[$index].Pattern
        $line = $lines[$index]
        if ($index -eq 0) {
            $line = $line.TrimStart($utf8BomChar)
        }

        if ($line -notmatch $pattern) {
            $failures.Add("${relativePath}: line $($index + 1) must be '${key}: <value>' (found '$line').")
            continue
        }

        $value = $Matches[1].Trim()

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
            "Last Reviewed" {
                if ($value -notmatch "^\d{4}-\d{2}-\d{2}$") {
                    $failures.Add("${relativePath}: Last Reviewed must use YYYY-MM-DD (found '$value').")
                }
                else {
                    try {
                        [void][datetime]::ParseExact($value, "yyyy-MM-dd", $null)
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
