Status: Replaced By
Audience: Internal
Owner: Michael
Last Reviewed: 2026-03-11
Canonical: No

# HostGator Migration Archive

## Silverware Games: HostGator to DigitalOcean

`Status`: Completed  
`Document status`: Replaced By `docs/internal/droplet/droplet.md` (historical reference only)

The HostGator migration is finished. This file is kept only as a historical archive and should not be used as the active operations guide.

## Current Sources Of Truth

- Droplet structure and host layout: `docs/internal/droplet.md`
- Current hosting and DNS conventions: `docs/internal/hosting-and-dns.md`

## Migration Outcomes (Completed)

- Hosting moved from HostGator to the DigitalOcean droplet.
- DNS authority moved off HostGator.
- Host and document root conventions were standardized.
- TLS and backup practices were established for droplet operations.
- HostGator dependencies were removed as part of decommissioning.

## Historical Scope

The completed migration effort covered:

- site and domain inventory review
- legacy directory and database audit
- DNS and email verification (MX, SPF, DKIM, DMARC)
- TLS issuance and renewal validation
- backup verification before final cutover
- decommission readiness checks

Use this file for historical context only.
