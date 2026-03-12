<sub><em>Status: Needs Review | Audience: Internal | Doc-Type: Workflow | Owner: Michael | Last Reviewed: 2026-03-11 | Canonical: Yes</em></sub>

# Silverware Games WordPress Deployment Workflow

This document explains how approved changes are safely transferred from the staging environment to the client's live website.

Deployment occurs only after the client reviews and approves the staging version.

# Overview

Deployment transfers improvements made on the staging site back to the production site.

Typical changes include:

- updated theme files
- new or modified plugins
- improved styling
- performance improvements
- configuration changes

The live site is always backed up before deployment.

# Step 1 — Confirm Client Approval

Before deployment, confirm that the client has approved the staging version.

Approval may occur through:

- email confirmation
- written approval
- project management system

Deployment should not proceed without approval.

# Step 2 — Create Production Backup

Create a fresh backup of the client's live website.

This backup should include:

- database
- themes
- plugins
- uploads
- configuration

This ensures the site can be restored if needed.

# Step 3 — Export Final Staging Version

From the staging site, export the finalized version using the migration plugin.

This produces a new backup file representing the approved version of the site.

Example file:

final-approved-site.wpress

# Step 4 — Import to Production Site

Log into the client's live WordPress admin.

Install the migration plugin if needed.

Import the exported staging file.

The plugin will update the live site to match the approved staging version.

# Step 5 — Verify Production Site

After deployment, confirm that the production site works correctly.

Check:

- homepage loads
- major pages work
- images appear correctly
- menus function
- forms operate properly

Perform a quick usability check.

# Step 6 — Clear Cache

If the client uses caching plugins or CDN services, clear the cache.

Examples include:

- WordPress caching plugins
- Cloudflare
- hosting cache systems

This ensures visitors see the updated version.

# Step 7 — Final Client Confirmation

Notify the client that deployment is complete.

Provide the production link and confirm the update was successful.

Encourage the client to review the site.

# Deployment Complete

Once verified, the staging site remains available for future improvements.

The workflow can repeat for future updates without affecting the live site until approval.
