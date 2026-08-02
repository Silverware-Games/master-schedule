<sub><em>Status: Active | Audience: Internal | Doc-Type: Workflow | Owner: Michael | Last Reviewed: 2026-08-02 | Canonical: Yes</em></sub>

# WordPress Operations Policy

This public-safe workflow covers the controls around WordPress client work. Provider details, site exports, credentials, server locations, plugin licenses, and executable deployment steps belong in the private project runbook.

## Onboarding

1. Confirm the scope, client authorization, production owner, and approval contact.
2. Request only the minimum access needed through an approved private channel.
3. Record who may approve releases and who may access client data.
4. Create an isolated, access-controlled staging copy using the private runbook.
5. Prevent indexing and avoid exposing personal or production data unnecessarily.
6. Verify the staging copy before development begins.
7. Keep only custom code and safe documentation in version control—never credentials, databases, uploads, exports, or licensed packages.

## Development And Review

1. Make changes in version-controlled custom code when practical.
2. Test on staging without affecting production visitors.
3. Check representative pages, responsive layouts, forms, integrations, accessibility, and performance as applicable.
4. Give the client a clear review link and describe any known limitations.
5. Capture explicit approval before scheduling production deployment.

## Production Release

1. Reconfirm the approved scope and release owner.
2. Confirm a current recovery point and the private rollback procedure.
3. Account for production changes made since the staging copy was created; do not overwrite newer orders, submissions, accounts, comments, or content.
4. Choose the least disruptive deployment method for the change. A full-site replacement is not the default when production data is active.
5. Apply the approved change using the private site-specific runbook.
6. Clear relevant caches and verify critical visitor and administrator paths.
7. Notify the client of completion and record the result privately.

## Release Checklist

- Client approval is recorded.
- Backup and rollback readiness are confirmed.
- Production data drift has been considered.
- Search visibility and access controls are correct for the target environment.
- Homepage, navigation, forms, media, and critical integrations pass a smoke test.
- HTTPS, redirects, caching, and analytics behave as expected.
- No secrets, exports, debug logs, or client data were committed publicly.

## When To Stop

Pause and escalate if access is ambiguous, the recovery point cannot be verified, staging is materially out of date, the target is unclear, or a deployment would overwrite unreviewed production data.
