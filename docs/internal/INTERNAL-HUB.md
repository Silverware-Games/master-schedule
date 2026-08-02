<sub><em>Status: Active | Audience: Internal | Doc-Type: Orientation | Owner: Michael | Last Reviewed: 2026-08-02 | Canonical: Yes</em></sub>

# INTERNAL HUB

Use this page if you are on the internal team or maintaining systems and automation.

## What This Section Is For

`docs/internal/` contains operating knowledge, infrastructure references, and procedure-heavy docs used to run Silverware Games systems.

“Internal” describes the intended reader, not a security boundary. Every file in this repository is public. These docs should give a teammate enough context to identify the task, make safe decisions, and use their authorized internal access to find the current private details. They must remain harmless if read publicly.

Keep credentials, client data, server addresses, filesystem layouts, account identifiers, private contacts, executable production commands, and recovery details in access-controlled systems.

## Recommended Reading Order

1. [../indexes/repo-map.md](../indexes/repo-map.md) for the authoritative document inventory.
2. [repo-map-automation-setup.md](./repo-map-automation-setup.md) for setting up automatic repo-map verification (recommended!).
3. [local-workspace.md](./local-workspace.md) for the canonical local repo layout.
4. [droplet/droplet.md](./droplet/droplet.md) for the public-repository boundary around hosting operations.
5. [hosting-and-dns.md](./hosting-and-dns.md) for public-safe hosting and DNS policy.
6. [game-telemetry.md](./game-telemetry.md) for integrating native and browser games with shared stats.
7. [working-rhythms.md](./working-rhythms.md) for team and collaborator expectations.
8. [wordpress/operations.md](./wordpress/operations.md) for WordPress onboarding, review, and release policy.
9. [droplet/content-ops.md](./droplet/content-ops.md) for safe content-operation controls.
10. [legacy-projects.md](./legacy-projects.md) and [migration-from-hostgator.md](./migration-from-hostgator.md) only for historical context.

## In A Hurry

Use task-based triage:

1. Infra issue: [droplet/droplet.md](./droplet/droplet.md) then [hosting-and-dns.md](./hosting-and-dns.md).
2. WordPress release: [wordpress/operations.md](./wordpress/operations.md), followed by the access-controlled site runbook.
3. Content changes on server: [droplet/content-ops.md](./droplet/content-ops.md).
4. Local repo or staging-file question: [local-workspace.md](./local-workspace.md).
5. Game stats integration: [game-telemetry.md](./game-telemetry.md).

## Should Anything Be Ignored?

For day-to-day operations, yes:

- Treat historical docs (`legacy-projects.md`, `migration-from-hostgator.md`) as optional unless you are investigating old migrations.
- Read only the runbook that matches your current incident or task.
