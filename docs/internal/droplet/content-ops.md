# Content Ops - Server Command Reference

## Static Sites, WordPress Staging, and Client Infrastructure

This document explains the custom command-line tools used on the **Silverware Games droplet** to create and manage client environments.

The goal of these tools is to make it extremely easy to:

- create WordPress staging environments
- create static client sites
- manage deployments
- maintain a consistent server structure
- avoid manual configuration errors

All commands are installed in:

/usr/local/bin/

and are designed to be run with:

sudo

# System Overview

The server hosts three main types of environments:

## 1. Static client sites

Example:
https://awesomeclientsite.silverwaregames.com

Directory:
/var/www/clients/awesomeclientsite

These are typically deployed via **GitHub Actions + rsync**.

## 2. WordPress staging environments

Example:
https://alokothai.silverwaregames.com

Directory:
/var/www/clients/alokothai

Used to safely modify WordPress sites before pushing changes back to the client.

## 3. Top-level domains

Example:

https://silverware.design

Directory:
/var/www/silverware.design/public_html

These are full standalone sites with their own nginx configuration and SSL certificate.

# Directory Layout

/var/www
├─ clients/
│ ├─ awesomeclientsite
│ ├─ alokothai
│ └─ demo
│
├─ silverware.design
│ └─ public_html


# File Ownership Model

Static sites and client folders use this ownership model:

deploy-user : www-data

Example:
deploy:www-data


Permissions:

| Type | Permission |
|-----|-----|
| directories | `2775` |
| files | `664` |

This allows:

- the deploy user to write files
- nginx to read files
- group inheritance to remain consistent

# Command Reference

## client-list

Lists all client environments.

client-list

Example output:

CLIENT TYPE SIZE URL

alokothai wordpress 612M https://alokothai.silverwaregames.com

awesomeclientsite static 84K https://awesomeclientsite.silverwaregames.com

Purpose:

- quickly see all hosted client sites
- identify WordPress vs static sites
- monitor disk usage


# Static Client Commands

## static-new-client

Creates a new **static staging site**.

Usage:
sudo static-new-client <client-slug> "<site title>" [deploy-user]

Example:
sudo static-new-client awesomeclientsite "Awesome Client Site"

Example with deploy user:
sudo static-new-client awesomeclientsite "Awesome Client Site" deploy

Creates:
/var/www/clients/awesomeclientsite

Accessible at:
https://awesomeclientsite.silverwaregames.com


The script also generates:

index.html
.github-actions-deploy.yml
.gitkeep

The placeholder page includes a **downloadable GitHub Actions workflow** for deployment.

## static-remove-client

Deletes a static client environment.

Usage:
sudo static-remove-client <client-slug>

Example:
sudo static-remove-client awesomeclientsite


Removes:
/var/www/clients/awesomeclientsite

The subdomain stops working automatically because nginx uses wildcard routing.

# WordPress Staging Commands

## wp-new-client

Creates a WordPress staging environment.

Usage:
sudo wp-new-client <client-slug> "<site title>" <admin-email>

Example:
sudo wp-new-client alokothai "Aloko Thai Staging" michael@silverwaregames.com

Creates:
/var/www/clients/alokothai


Access:
https://alokothai.silverwaregames.com


Admin panel:
https://alokothai.silverwaregames.com/wp-admin


Credentials are saved to:
/root/wp-client-secrets/

## wp-remove-client

Deletes a WordPress staging environment.

Usage:
sudo wp-remove-client <client-slug>


Example:
sudo wp-remove-client alokothai

Removes:
/var/www/clients/alokothai
database
nginx config

# Top-Level Domain Commands

## new-top-domain

Creates a new top-level domain environment.

Usage:
sudo new-top-domain <domain> "<site title>" [deploy-user]

Example:
sudo new-top-domain silverware.design "Silverware Design"

Creates:
/var/www/silverware.design/public_html

Creates nginx config:
/etc/nginx/sites-available/silverware.design.conf

Enables site:
/etc/nginx/sites-enabled/

Obtains SSL certificate automatically using:

certbot --nginx

After creation the site will be accessible at:

https://silverware.design
https://www.silverware.design

# Deployment System

Static sites are deployed using **GitHub Actions**.

Workflow location inside repo:

.github/workflows/deploy.yml

Deployment process:

1. push to `main`
2. GitHub Actions builds site
3. SSH connects to droplet
4. rsync uploads files to:

/var/www/clients/<repo-name>

Required GitHub secrets:

DROPLET_HOST
DROPLET_USER
DROPLET_SSH_KEY
DROPLET_PORT

# Naming Convention

Repository name must match client slug.

Example:

| Repo | Deploy Directory |
|-----|-----|
| awesomeclientsite | `/var/www/clients/awesomeclientsite` |
| alokothai | `/var/www/clients/alokothai` |

This keeps deployments automatic.

# DNS Setup

Wildcard DNS must already be configured:

*.silverwaregames.com → droplet IP

This allows automatic subdomain routing.

Example:

awesomeclientsite.silverwaregames.com
demo.silverwaregames.com
alokothai.silverwaregames.com

# Server Philosophy

The Silverware Games hosting environment is designed around several key principles.

### Safety

Work is performed on staging environments instead of live client sites.

### Automation

Most setup tasks are handled by small command-line scripts.

### Consistency

All sites follow the same directory structure and naming conventions.

### Simplicity

Commands are designed to be easy to remember and repeat.

# Quick Command Summary

Create static client:
sudo static-new-client slug "Site Title"

Delete static client:
sudo static-remove-client slug

Create WordPress staging:
sudo wp-new-client slug "Site Title" email@example.com

Delete WordPress staging:
sudo wp-remove-client slug


Create top-level domain:
sudo new-top-domain domain.com "Site Title"


List all clients:
client-list


# Future Improvements

Potential additions:

- automated backups
- deploy logs
- client portal dashboard
- automated staging links
- site status monitoring
- internal admin UI

# Summary

The Silverware Games droplet uses a lightweight command-driven system for managing:

- static sites
- WordPress staging
- client environments
- domain provisioning

This allows extremely fast setup of new client projects while maintaining a safe and consistent hosting structure.
