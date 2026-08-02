<sub><em>Status: Needs Review | Audience: Internal | Doc-Type: Reference | Owner: Michael | Last Reviewed: 2026-08-02 | Canonical: Yes</em></sub>

# Hosting And DNS

This document tracks hosting and DNS architecture for Silverware Games properties.

## Primary Reference

- Current droplet structure: [droplet/droplet.md](./droplet/droplet.md)
- Historical migration archive: [migration-from-hostgator.md](./migration-from-hostgator.md)

## Working Conventions

- Use a single authoritative DNS source per domain.
- Use one domain per virtual host and document root.
- Avoid temporary production routing hacks.
- Document domain and server changes in the relevant canonical reference or runbook.

## Maintenance Note

Use this file for current-state hosting conventions. Keep historical migration details in `docs/internal/migration-from-hostgator.md`.
