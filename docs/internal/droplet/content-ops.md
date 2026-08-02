<sub><em>Status: Active | Audience: Internal | Doc-Type: Workflow | Owner: Michael | Last Reviewed: 2026-08-02 | Canonical: Yes</em></sub>

# Content Operations Safety

This is the public-safe workflow for changing hosted Silverware Games or client content. Exact commands, targets, accounts, and recovery procedures belong in access-controlled operations records.

## Before A Change

1. Confirm that the requester and operator are authorized for the property.
2. Identify the intended environment and make sure it is not being confused with production.
3. Define the expected result and a short validation checklist.
4. Confirm that a current, restorable backup or artifact exists when production data could change.
5. Confirm the private rollback procedure and responsible operator.
6. Avoid placing credentials, client data, exports, or logs containing sensitive data in source control.

## Make The Change

1. Prefer an automated, reviewed deployment over an interactive server edit.
2. Test on an isolated preview or staging environment first.
3. Limit the change to the approved property and files.
4. Treat deletion, database replacement, DNS changes, and permission changes as high-risk operations requiring a second check.
5. Stop if the observed target or output differs from the approved plan.

## Verify And Close

1. Check the primary page or feature and its critical paths.
2. Check forms, downloads, authentication, or purchases when relevant.
3. Confirm HTTPS, redirects, and cache behavior from a visitor's perspective.
4. Record the release, validation result, and any follow-up in the private operations log.
5. Notify the requester and retain the rollback point for the agreed recovery window.

## Incident Rule

If production is degraded, protect evidence and prefer the known rollback over improvised repairs. Escalate through the private incident contacts; do not publish logs, addresses, credentials, or infrastructure details in a public issue.

## Private Runbook Requirement

This policy is not a server runbook. An operator must have the current private runbook before performing provisioning, deployment, removal, restoration, DNS, certificate, or account-management work.
