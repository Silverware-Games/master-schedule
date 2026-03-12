<sub><em>Status: Needs Review | Audience: Internal | Doc-Type: Reference | Owner: Michael | Last Reviewed: 2026-03-11 | Canonical: Yes</em></sub>

# Silverware Games WordPress Staging Server Architecture

This document describes the staging server used for WordPress development at Silverware Games.

The staging server allows safe development and testing of client websites without affecting the client's live production site.

Each client website is cloned into a staging environment hosted on the Silverware Games DigitalOcean server.

# Goals of the Staging System

The staging system is designed to provide:

- safe development environments
- isolated client workspaces
- easy client preview links
- repeatable deployment workflows
- protection of production sites

The staging server ensures that development work never directly affects a client's live website.

# Server Environment

Hosting provider:

DigitalOcean Droplet

Typical software stack:

- Ubuntu Linux
- Nginx
- PHP-FPM
- MySQL / MariaDB
- WordPress
- Certbot (Let's Encrypt SSL)

This stack provides a lightweight and reliable WordPress hosting environment.

# Staging Domain Structure

Each client receives a staging subdomain.

Example:

clientname.silverwaregames.com

Examples for multiple clients:

facilitatewell.silverwaregames.com  
valscolorfulworld.silverwaregames.com  
exampleclient.silverwaregames.com

These domains point to the Silverware Games droplet.

Clients can preview their site using these links during development.

# DNS Configuration

A wildcard DNS record is used so new staging sites can be created without adding DNS records manually.

Example record:

Type: A  
Name: \*  
Value: [Droplet IP Address]

This allows any subdomain of silverwaregames.com to resolve to the server.

Example valid subdomains:

client1.silverwaregames.com  
client2.silverwaregames.com  
anything.silverwaregames.com

# SSL Configuration

A wildcard SSL certificate is used to secure all staging subdomains.

Example certificate coverage:

\*.silverwaregames.com  
silverwaregames.com

SSL certificates are generated using Certbot and Let's Encrypt.

This ensures staging sites can be accessed securely using HTTPS.

---

# Server Directory Structure

Client staging sites are stored in the following location:

/var/www/clients/

Each client receives a dedicated directory.

Example structure:

/var/www/clients/facilitatewell  
/var/www/clients/valscolorfulworld  
/var/www/clients/exampleclient

Each directory contains a full WordPress installation.

# WordPress Structure

Inside each client directory is a standard WordPress install.

Example:

/var/www/clients/clientname

Typical contents:

wp-admin/  
wp-content/  
wp-includes/

Within wp-content:

themes/  
plugins/  
uploads/

The uploads folder contains media files and is not tracked in version control.

# Development Workflow

The typical workflow is:

1. Export client website
2. Import into staging environment
3. Perform development on staging
4. Client reviews staging version
5. Approved changes are deployed to production

All development work occurs on the staging copy.

The client's live site remains unchanged until approval.

# Version Control

Custom development code is maintained in GitHub repositories.

Typical items stored in GitHub:

- child themes
- custom plugins
- CSS / JavaScript
- template overrides
- project documentation

Items NOT stored in GitHub:

- WordPress core
- database
- uploads
- cache files
- backups

GitHub is used to track code changes and maintain development history.

# Local Development Environment

Development is performed locally using:

Visual Studio Code  
GitHub repositories  
PowerShell / SSH for deployment

Code is edited locally and then deployed to the staging server.

# Staging Site Security

Staging sites should not be indexed by search engines.

WordPress setting:

Settings → Reading → Discourage search engines

Optional additional protections:

- HTTP password protection
- robots noindex rules
- restricted access if required

This prevents unfinished staging sites from appearing in search results.

# Deployment to Production

Once a client approves the staging version, the changes are transferred back to the client's production website.

Typical deployment steps:

1. Backup the production site
2. Export approved staging version
3. Import to production site
4. Verify functionality
5. Clear caches

This ensures safe and controlled updates.

# Summary

The Silverware Games staging system provides a safe environment for developing and testing WordPress sites.

Key principles:

- never edit the live site directly
- work on staging copies
- track development code in GitHub
- obtain client approval before deployment

This workflow protects both the client's website and the development process.
