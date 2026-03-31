<sub><em>Status: Active | Audience: Internal | Doc-Type: Workflow | Owner: Michael | Last Reviewed: 2026-03-31 | Canonical: Yes</em></sub>

# Repo-Map Auto-Sync Setup Guide

## Overview

Two scripts work together to keep your repo-map current automatically:

1. **`ensure-repo-map-complete.ps1`** — Scans all `.md` files and verifies they're in the repo-map
2. **`pre-commit-ensure-repo-map`** — Git pre-commit hook that auto-fixes missing entries before each commit

## Quick Setup (Windows with PowerShell)

### Option 1: Core.hooksPath (Recommended)

This approach stores hooks in a version-controlled directory so all team members can use them:

```powershell
# In the repo root, run:
git config core.hooksPath scripts
```

That's it! Now copy the pre-commit hook into `.git/hooks/`:

```powershell
# From the repo root:
Copy-Item scripts/pre-commit-ensure-repo-map .git/hooks/pre-commit -Force
# Make it executable
icacls ".git/hooks/pre-commit" /grant:r "$env:USERNAME:(F)" /T | Out-Null
```

### Option 2: Manual .git/hooks Setup

If you prefer traditional git hooks:

```powershell
# Copy the hook to git's hooks directory
Copy-Item scripts/pre-commit-ensure-repo-map .git/hooks/pre-commit -Force
```

## Usage

### Auto-check during commits:

```powershell
git add .
git commit -m "Your commit message"
```

If unmapped files are detected:

- ✅ They're automatically added to the repo-map
- ✅ The updated repo-map is staged for commit
- ✅ Your commit proceeds normally (hook exits with 0)

### Manual verification:

```powershell
# Check for missing files (fails if any found):
& scripts/ensure-repo-map-complete.ps1

# Auto-fix without committing:
& scripts/ensure-repo-map-complete.ps1 -AutoFix

# Auto-fix and stage changes:
& scripts/ensure-repo-map-complete.ps1 -AutoFix -Stage
```

## What Gets Regenerated

The `verify-repo-map-status.ps1` script (invoked by ensure-repo-map-complete) will:

1. ✅ Add missing files to the registry
2. ✅ Sync metadata (Status, Audience, Doc-Type, Owner, Last Reviewed) from file headers to the map
3. ✅ Update the repo-map's Last Reviewed timestamp

## Important: Document Headers

Every `.md` file must have this header on line 1:

```markdown
<sub><em>Status: <Active|Draft|Needs Review|Archived|Replaced By> | Audience: <target readers> | Doc-Type: <Orientation|Reference|Workflow> | Owner: <primary owner> | Last Reviewed: <YYYY-MM-DD> | Canonical: <Yes|No></em></sub>
```

If a file is missing this header, the script assigns defaults:

- Status: `Draft`
- Audience: `Internal`
- Doc-Type: `Reference`
- Owner: `Unknown`
- Last Reviewed: Today's date
- Canonical: `No`

You should then update these values manually in the file header to be more accurate.

## Excluding Files

To exclude specific directories or files from the repo-map requirement, edit `ensure-repo-map-complete.ps1`:

```powershell
# Around line 18-27:
$excludeDirs = @('.git', 'node_modules', '.vscode', 'scripts')
$excludePatterns = @(
    'LICENSE'
    'node_modules'
    '.git'
)
```

## Troubleshooting

### Hook not running?

1. Verify git hooks are enabled:

   ```powershell
   git config hooks.enabled true
   ```

2. Check PowerShell execution policy:

   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

3. Verify hook has execute permissions:
   ```powershell
   icacls ".git/hooks/pre-commit" /grant:r "$env:USERNAME:(F)" /T
   ```

### Files added to map with wrong metadata?

Edit the metadata header in the `.md` file itself (line 1), then run:

```powershell
& scripts/verify-repo-map-status.ps1 -Regenerate -Stage
```

This syncs the file headers back to the repo-map table.

## Workflow Example

```powershell
# Create or modify a markdown file
echo "# My New Doc" > docs/myfile.md

# Stage everything
git add .

# Pre-commit hook runs automatically:
# ✓ Detects docs/myfile.md is not in repo-map
# ✓ Adds it with default metadata
# ✓ Stages the updated repo-map
# ✓ Commit proceeds

git commit -m "Add new documentation"

# Later, update metadata in the file header:
# docs/myfile.md line 1:
# <sub><em>Status: Active | Audience: All | Doc-Type: Reference | Owner: You | Last Reviewed: 2026-03-31 | Canonical: Yes</em></sub>

# Commit again - metadata syncs to the repo-map table
git add docs/myfile.md
git commit -m "Update doc status to Active"
```

## FAQ

**Q: Do I have to run the hook manually?**  
A: No, it runs automatically before each commit when enabled. You can also run it manually for verification.

**Q: What if I want to exclude a markdown file?**  
A: Edit `$excludePatterns` in `ensure-repo-map-complete.ps1` to add patterns for files you don't want mapped.

**Q: Can I undo a repo-map regeneration?**  
A: Use `git diff docs/indexes/repo-map.md` to see changes before commit. If something's wrong, run `git reset` and run verify-repo-map-status.ps1 again with correct parameters.

**Q: Does this work on macOS/Linux?**  
A: Yes! The scripts are PowerShell 7+ compatible. Adjust paths from Windows backslashes to forward slashes as needed.
