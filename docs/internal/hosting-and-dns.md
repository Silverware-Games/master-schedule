<sub><em>Status: Active | Audience: Internal | Doc-Type: Reference | Owner: Michael | Last Reviewed: 2026-08-02 | Canonical: Yes</em></sub>

# Hosting And DNS

This public-safe reference defines how hosting and DNS decisions are managed without disclosing the production layout.

## Policy

- Assign a clear owner to every domain and hosted property.
- Maintain one authoritative DNS source for each domain.
- Separate staging from production and label environments unambiguously.
- Use HTTPS, least-privilege access, and managed credential storage.
- Review redirects, certificate coverage, and visitor-visible behavior after changes.
- Confirm rollback and recovery readiness before modifying production routing.
- Record provider, account, zone, host, address, and access details only in the private operations system.

## DNS Change Workflow

1. Confirm ownership and authorization.
2. Capture the current record privately and define the desired result.
3. Review dependencies such as email, verification records, redirects, and certificates.
4. Prepare a rollback and select an appropriate change window.
5. Apply the smallest necessary change through the authoritative provider.
6. Verify resolution and application behavior from outside the hosting environment.
7. Record the outcome in the private operations log.

## Repository Safety

Do not commit zone exports, IP addresses, account identifiers, secret names, screenshots of control panels, or full infrastructure inventories. Public project links may be documented in project pages when they are intended for visitors.

## Related References

- [Hosting Operations Boundary](./droplet/droplet.md)
- [Content Operations Safety](./droplet/content-ops.md)
- [WordPress Operations Policy](./wordpress/operations.md)
