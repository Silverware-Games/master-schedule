# Hosting And DNS

This document tracks hosting and DNS architecture for Silverware Games properties.

## Primary Reference

- Migration master plan: `docs/internal/migration.md`

## Working Conventions

- use a single authoritative DNS source per domain
- use one domain per virtual host and document root
- avoid temporary production routing hacks
- document all domain and server changes in this repo

## Maintenance Note

Use this file for current-state hosting conventions. Keep historical migration details in `docs/internal/migration.md`.
