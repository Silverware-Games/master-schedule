<sub><em>Status: Needs Review | Audience: Internal | Owner: Michael | Last Reviewed: 2026-03-11 | Canonical: Yes</em></sub>
# Silverware Games WordPress Client Onboarding

This document describes the steps used when starting work on a new WordPress client site.

The goal of onboarding is to safely create a working copy of the client's website without affecting their live production site.

All development work will take place on the staging copy.

# Step 1 — Confirm Access

The client must provide at least one of the following:

Preferred:
- WordPress administrator login (wp-admin)

Optional but helpful:
- hosting panel access
- FTP / SFTP access
- domain DNS access

In most cases, **WordPress admin access alone is enough**.

# Step 2 — Install Migration Tool

Log into the client's WordPress admin panel.

Install the plugin:

All-in-One WP Migration

or another equivalent export plugin.

This tool allows the entire site to be exported safely.

# Step 3 — Export the Website

Use the migration tool to export the full site.

This export includes:

- database
- themes
- plugins
- images
- uploads
- configuration

The export will generate a backup file such as:

site-backup.wpress

Download and store this file securely.

This file serves as both:

- the staging import
- a full backup of the site

# Step 4 — Create the Staging Site

On the Silverware Games server:

Create a new staging environment for the client.

Example domain:

clientname.silverwaregames.com

Example server directory:

/var/www/clients/clientname

Install a fresh WordPress instance.

# Step 5 — Import the Client Website

Install the same migration plugin on the staging site.

Import the backup file created in Step 3.

This recreates the client's website exactly as it existed when exported.

At this point the staging site should be a working copy of the client's live site.

# Step 6 — Verify the Clone

Check that the staging site functions correctly:

Confirm:

- pages load properly
- images display
- theme works
- plugins are active
- navigation works

If necessary, adjust any URL settings.

# Step 7 — Secure the Staging Site

Ensure the staging site is not indexed by search engines.

In WordPress settings:

Settings → Reading → Discourage search engines

Optional security:

- add password protection
- restrict access if necessary

# Step 8 — Create Development Repository

Create a GitHub repository for the project.

This repository will contain only the custom development components such as:

- child theme
- custom plugins
- CSS / JavaScript
- template files

The repository will not contain:

- WordPress core
- uploads
- database
- backups

Development work will occur locally and be deployed to the staging environment.

# Step 9 — Notify the Client

Inform the client that the staging environment is ready.

Provide the staging link.

Example:

https://clientname.silverwaregames.com

Explain that this is a safe working copy used for development and review.

The live site remains unchanged during this process.

# Onboarding Complete

Once onboarding is finished, development work may begin on the staging environment.
