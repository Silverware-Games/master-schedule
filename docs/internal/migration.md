# MIGRATION.md  
## Silverware Games – HostGator → DigitalOcean Droplet Migration

This document is the **primary organizing reference** for migrating Silverware Games and all related properties from the legacy HostGator shared hosting environment to the new DigitalOcean droplet.

The long-term goals of this migration are:
- Fully decommission HostGator and delete the account
- Centralize hosting on the droplet
- Centralize DNS authority (no HostGator DNS)
- Establish clear conventions for domains, subdomains, and server layout
- Make future projects easy to add without ad-hoc fixes or late-night rescues

## 1. DNS STRATEGY (AUTHORITATIVE SOURCE)

**HostGator must not remain authoritative DNS.**

DNS authority should be moved to **the domain registrar** (recommended) or DigitalOcean DNS.

Target state:
- Registrar (or DO) = single source of truth
- All domains explicitly mapped
- No wildcard or inherited HostGator records
- Droplet IP referenced via A records only

HostGator DNS will be removed entirely before account deletion.

## 2. SERVER LAYOUT CONVENTION (FINAL)

Each domain or subdomain gets:
- Its own virtual host
- Its own document root
- Its own TLS certificate

Recommended layout on the droplet:

```text
/var/www/
    silverwaregames.com/
        public_html/
    wiki.silverwaregames.com/
        public_html/
    mandela.agency/
        public_html/
    lilysgame.io/
        public_html/
    bobblebonanza.io/
        public_html/
    kingzazz.com/
        public_html/
    firestarter.cc/
        public_html/
    eggfun.io/
        public_html/
    washtowelfill.io/
        public_html/
```

No shared docroots.  
No “temporary” overrides.  
Boring is good.

## 3. SITE INVENTORY & MIGRATION STATUS

### Core Sites

- **silverwaregames.com**  
  https://silverwaregames.com  
  Main site. Rendered from Git repository via build script using data JSON files.

- **wiki.silverwaregames.com**  
  Status: **DONE**  
  MediaWiki instance running on droplet.

- **mandela.agency**  
  https://mandela.agency  
  WikiMedia-based site. Migrated / migrating to droplet.

### Archived / Consolidated Properties

- **matchyverse.com**  
  https://matchyverse.com  
  Former WordPress site.  
  Functionality/content now merged into silverwaregames.com.  
  Action: Archive old WordPress database and files, then decommission.

### HTML5 Applets (Require SWG API)

These titles require backend access for:
- Scores
- Leaderboards
- Achievements
- Save state

They should eventually be hosted on their own domains, not under `/games/`.

- **Lily’s Game**  
  https://lilysgame.io  
  HTML5 applet.

- **Bobble Bonanza**  
  Current: https://silverwaregames.com/games/bobble/  
  Target: https://bobblebonanza.io  
  HTML5 applet.

- **King Zazz**  
  Current: https://silverwaregames.com/games/zazz/  
  Target: https://kingzazz.com  
  HTML5 applet.

- **Firestarter**  
  Current: https://silverwaregames.com/games/firestarter/  
  Target: https://firestarter.cc  
  HTML5 applet.

- **Egg Fun**  
  Current: https://silverwaregames.com/games/eggfun/  
  Target: https://eggfun.io  
  HTML5 applet.

- **WTF (Wash Towel Fill)**  
  Current: https://silverwaregames.com/games/wtf/  
  Target: https://washtowelfill.io  
  HTML5 applet.  
  First title with proper backend logic.

### Download / Redirect-Only Properties

These are also hosted on the droplet, each as its own small site with:

* A uniform landing page
* Downloadable .zip assets
* Links back to silverwaregames.com

- **Blokaroka**  
  Redirect from main site → https://blokaroka.com  
  Downloadable `.zip` with instructions.

- **Speedway Heroes**  
  Redirect from main site → https://speedwayheroes.com  
  Downloadable `.zip` with instructions.

- **Xanadu**  
  Redirect from main site → https://xanadu.live  
  Downloadable `.zip` with instructions.

- **Hundred Bullets**  
  Redirect from main site → https://hundredbullets.com  
  Press kit `.zip` and Microsoft Store link.

## 4. HOSTGATOR AUDIT (REQUIRED BEFORE DELETION)

Before canceling HostGator:

- Obtain a **full recursive directory listing** of the HostGator server
- Save as plaintext
- Review and categorize:
  - Active sites
  - Forgotten experiments
  - Old backups
  - Dead or abandoned content

This list will be reviewed and categorized to ensure nothing important is lost.

## 5. EMAIL & DNS VERIFICATION

Before HostGator deletion:

- Verify MX records
- Verify SPF
- Verify DKIM
- Verify DMARC

Confirm all mail delivery works for:
- Google Workspace / Gmail
- MailerLite
- Any transactional email used by apps or wikis

## 6. TLS & CERTIFICATE MANAGEMENT

On the droplet:
- Certbot installed
- Auto-renew enabled
- Manual dry run verified:
```text
    certbot renew --dry-run
```

Certificates must be verified for **all domains**, not just the wiki.

## 7. BACKUPS (NON-NEGOTIABLE)

Minimum required backups:
- Daily database dumps
- Weekly `/var/www` snapshots
- Stored off-droplet (object storage or secondary machine)

Goal:  
Droplet failure should be **annoying**, not catastrophic.

## 8. FINAL HOSTGATOR DECOMMISSION CHECKLIST

HostGator can be canceled only after:

- DNS no longer points to HostGator
- All sites load from the droplet
- Email delivery confirmed
- Backups verified
- Old content archived

Only then:
- Cancel HostGator plan
- Delete HostGator account
- Remove credentials and references

## 9. GUIDING PRINCIPLES GOING FORWARD

- DNS authority lives in one place
- One domain = one vhost = one directory
- Apps get their own domains
- Experiments are explicitly labeled
- No “temporary” production hacks

Future migrations should be boring.

## 10. IMPORTANT WARNING: FORGOTTEN / ODDBALL PROJECTS

There are known cases of **additional domains and projects** that were hosted on the legacy HostGator account and are **not yet fully accounted for** in this document.

Example:
- https://blackandwhitestone.com

There may be other:
- Client sites
- One-off experiments
- Abandoned prototypes
- Temporary landing pages
- Old databases (WordPress, MediaWiki, custom PHP)
- Asset-only directories

Some of these may:
- Still be live
- Still be referenced externally
- Still be tied to active domains
- Contain content that should be archived rather than deleted

### Mandatory Verification Step

Before HostGator is canceled or the account is deleted, it is **essential** to:

- Obtain the **entire directory structure** from the HostGator server
- Obtain a **full list of databases** (including unused or legacy ones)
- Preserve both in plaintext / export form
- Review and categorize every item

Nothing should be assumed “dead” until it has been explicitly reviewed.

This step exists specifically to prevent:
- Accidental data loss
- Broken client links
- Forgotten live domains
- Irreversible deletions

Only after this audit is complete should HostGator decommissioning proceed.
