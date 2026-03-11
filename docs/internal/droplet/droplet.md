# DigitalOcean Droplet Structure

This document is the source of truth for how the Silverware Games production droplet is organized.

## Scope And Status

- This is the active hosting layout.
- HostGator migration is complete.
- Historical migration context is archived in `docs/internal/migration-from-hostgator.md`.

## Hosting Model

- One hostname = one virtual host = one document root.
- Document roots are not shared across properties.
- Each hostname has its own TLS certificate.
- DNS is managed outside HostGator, with explicit A records pointing hostnames to the droplet IP.

## Filesystem Layout

All hosted properties are rooted under `/var/www`, with each hostname using its own `public_html` directory.

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
	blokaroka.com/
		public_html/
	speedwayheroes.com/
		public_html/
	xanadu.live/
		public_html/
	hundredbullets.com/
		public_html/
```

## Hostname Roles

- `silverwaregames.com`: Main studio site generated from repository content and data files.
- `wiki.silverwaregames.com`: MediaWiki instance.
- `mandela.agency`: WikiMedia-based site.
- `lilysgame.io`, `bobblebonanza.io`, `kingzazz.com`, `firestarter.cc`, `eggfun.io`, `washtowelfill.io`: HTML5 game domains.
- `blokaroka.com`, `speedwayheroes.com`, `xanadu.live`, `hundredbullets.com`: Download or landing domains.

## Operations Baseline

- TLS certificates are managed with Certbot and auto-renewal.
- Renewal check command:

```text
certbot renew --dry-run
```

- Backups include daily database dumps and weekly `/var/www` snapshots stored off-droplet.

## Standard Process For A New Hostname

1. Create `/var/www/<hostname>/public_html`.
2. Add a dedicated virtual host that points to that path.
3. Issue and attach a TLS certificate for the hostname.
4. Add or update DNS A records for the hostname.
5. Document the change in this file and `docs/internal/hosting-and-dns.md`.
