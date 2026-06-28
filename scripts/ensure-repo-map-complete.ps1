param(
    [string]$Root = ".",
    [string]$RepoMapPath = "docs/indexes/repo-map.md",
    [switch]$AutoFix,
    [switch]$Stage
)

$ErrorActionPreference = "Stop"

$utf8BomChar = [char]0xFEFF
$metadataPattern = '^<sub><(?:em|i)>\s*Status:\s*(?<Status>[^|]+?)\s*\|\s*Audience:\s*(?<Audience>[^|]+?)\s*\|\s*Doc-Type:\s*(?<DocType>[^|]+?)\s*\|\s*Owner:\s*(?<Owner>[^|]+?)\s*\|\s*Last Reviewed:\s*(?<LastReviewed>[^|]+?)\s*\|\s*Canonical:\s*(?<Canonical>[^|<]+?)\s*</(?:em|i)></sub>$'

# Directories to exclude from scanning
$excludeDirs = @('.git', 'node_modules', '.vscode', 'scripts')

# Specific files/patterns to exclude
$excludePatterns = @(
    'LICENSE'
    'node_modules'
    '.git'
)

$rootPath = (Resolve-Path -LiteralPath $Root).ProviderPath
$repoMapFullPath = Join-Path $rootPath $RepoMapPath
$repoMapDir = Split-Path -Path $repoMapFullPath -Parent

function Get-AllMarkdownFiles {
    param([string]$SearchRoot)
    
    $allMdFiles = @()
    
    # Get all .md files recursively
    Get-ChildItem -Path $SearchRoot -Filter "*.md" -Recurse -File | ForEach-Object {
        $relativePath = Resolve-Path -Relative -Path $_.FullName
        $normalized = $relativePath -replace '^\..*?[\\/]', '' -replace '\\', '/'
        
        # Skip excluded patterns
        $shouldExclude = $false
        foreach ($pattern in $excludePatterns) {
            if ($normalized -match [regex]::Escape($pattern)) {
                $shouldExclude = $true
                break
            }
        }
        
        if (-not $shouldExclude) {
            $allMdFiles += $normalized
        }
    }
    
    return $allMdFiles | Sort-Object
}

function Parse-RepoMapLinks {
    param([string]$RepoMapContent)
    
    $links = @()
    
    # Match all markdown links in the format [text](path)
    $linkPattern = '\]\((?<link>[^)]+)\)'
    
    foreach ($match in [regex]::Matches($RepoMapContent, $linkPattern)) {
        $link = $match.Groups['link'].Value
        
        # Only include relative markdown files, not external URLs
        if ($link -notmatch '^[a-zA-Z]+://' -and $link -match '\.md$') {
            # Normalize the path
            $normalized = $link -replace '\\', '/'
            $links += $normalized
        }
    }
    
    return $links | Select-Object -Unique | Sort-Object
}

function Read-Utf8TextFile {
    param([string]$Path)
    
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

function Get-DocumentMetadata {
    param([string]$FilePath)
    
    $content = Read-Utf8TextFile -Path $FilePath
    $lines = $content.Text -split "`r`n|`n|`r"
    
    if (-not $lines -or $lines.Count -lt 1) {
        return $null
    }
    
    $firstLine = $lines[0].TrimStart($utf8BomChar)
    
    if ($firstLine -notmatch $metadataPattern) {
        return @{
            Status = "Draft"           # Default for unformatted docs
            Audience = "Internal"
            DocType = "Reference"
            Owner = "Unknown"
            LastReviewed = (Get-Date).ToString("yyyy-MM-dd")
            Canonical = "No"
        }
    }
    
    $title = ""
    foreach ($line in $lines[1..($lines.Count-1)]) {
        if ($line -match '^#+\s+(.+)$') {
            $title = $Matches[1].Trim()
            break
        }
    }
    
    return @{
        Status = $Matches['Status'].Trim()
        Audience = $Matches['Audience'].Trim()
        DocType = $Matches['DocType'].Trim()
        Owner = $Matches['Owner'].Trim()
        LastReviewed = $Matches['LastReviewed'].Trim()
        Canonical = $Matches['Canonical'].Trim()
        Title = $title
    }
}

# Main execution
Write-Host "Scanning repository for markdown files..."
$allMdFiles = Get-AllMarkdownFiles -SearchRoot $rootPath
Write-Host "Found $($allMdFiles.Count) markdown file(s)"

Write-Host "Reading repo map from '$RepoMapPath'..."
$repoMapContent = (Read-Utf8TextFile -Path $repoMapFullPath).Text
$mappedLinks = Parse-RepoMapLinks -RepoMapContent $repoMapContent

Write-Host "Repo map contains $($mappedLinks.Count) mapped file(s)"

# Find missing files
$missing = @()
foreach ($mdFile in $allMdFiles) {
    # Normalize for comparison
    $normalized = $mdFile -replace '\\', '/'
    
    # Check if this file is in the map (need to handle both relative path formats)
    $found = $false
    foreach ($mapLink in $mappedLinks) {
        $mapNorm = $mapLink -replace '\\', '/'
        $mdNorm = $normalized -replace '\\', '/'
        
        # Remove leading ./ for comparison
        $mapNorm = $mapNorm -replace '^\.\/', ''
        $mdNorm = $mdNorm -replace '^\.\/', ''
        
        # Normalize relative paths like ../../README.md
        # by resolving them relative to repo-map location
        $mapFullPath = Join-Path $repoMapDir $mapLink
        $mapFullResolved = (Resolve-Path -LiteralPath $mapFullPath -ErrorAction SilentlyContinue).ProviderPath
        $mdFullPath = Join-Path $rootPath $mdNorm
        $mdFullResolved = (Resolve-Path -LiteralPath $mdFullPath -ErrorAction SilentlyContinue).ProviderPath
        
        if ($mapFullResolved -and $mdFullResolved -and $mapFullResolved -eq $mdFullResolved) {
            $found = $true
            break
        }
        
        # Also try string matching as fallback
        if ($mapNorm -eq $mdNorm -or $mapNorm.EndsWith("/$mdNorm") -or $mdNorm.EndsWith($mapNorm)) {
            $found = $true
            break
        }
    }
    
    if (-not $found) {
        $missing += $mdFile
    }
}

if ($missing.Count -eq 0) {
    Write-Host -ForegroundColor Green "OK: All markdown files are mapped in the repo-map!"
    exit 0
}

Write-Host -ForegroundColor Yellow ("Missing from repo-map: {0} files" -f $missing.Count)
$missing | ForEach-Object { Write-Host "  - $_" }

if (-not $AutoFix) {
    Write-Host ""
    Write-Host -ForegroundColor Red "FAILED: Unmapped files detected. Run with -AutoFix to regenerate repo-map."
    exit 1
}

Write-Host ""
Write-Host "Running verify-repo-map-status.ps1 with -Regenerate..."
$verifyArgs = @("-Root", $Root, "-RepoMapPath", $RepoMapPath, "-Regenerate")
if ($Stage) {
    $verifyArgs += "-Stage"
}
& "$PSScriptRoot\verify-repo-map-status.ps1" @verifyArgs

if ($LASTEXITCODE -ne 0) {
    Write-Host -ForegroundColor Red "Regeneration failed!"
    exit 1
}

Write-Host -ForegroundColor Green "OK: Repo-map regenerated successfully!"
exit 0
