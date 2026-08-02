<sub><em>Status: Active | Audience: Internal | Doc-Type: Reference | Owner: Michael | Last Reviewed: 2026-08-02 | Canonical: Yes</em></sub>

# Hosting Operations Boundary

This public document records the durable rules for Silverware Games hosting without exposing production topology or access details.

## Public Repository Boundary

Do not record sensitive operational details in this repository, including:

- server addresses, account identifiers, or access methods
- filesystem paths, usernames, or permission layouts
- secret names, credential locations, or configuration values
- complete domain-to-host mappings
- executable provisioning, removal, recovery, or deployment commands
- backup locations, schedules, retention, or restoration details
- monitoring endpoints or security controls

Store those details in the approved private operations system. Link to that system only from another access-controlled location.

## Durable Hosting Principles

- Give each property a clearly owned deployment target.
- Keep staging and production isolated.
- Use encrypted connections and least-privilege access.
- Require recoverable backups before material production changes.
- Test changes in staging and verify them after release.
- Keep credentials out of repositories and rotate them when exposure is suspected.
- Record material infrastructure changes in the private operations log.

## Ownership

The person performing a production change is responsible for confirming authorization, backup readiness, validation, and rollback before beginning. If any of those are uncertain, pause the change and contact the current hosting owner.

## Related Public-Safe References

- [Hosting and DNS](../hosting-and-dns.md)
- [Content Operations Safety](./content-ops.md)
- [WordPress Operations Policy](../wordpress/operations.md)
