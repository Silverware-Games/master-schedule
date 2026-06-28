<sub><em>Status: Active | Audience: Internal | Doc-Type: Orientation | Owner: Michael | Last Reviewed: 2026-06-28 | Canonical: Yes</em></sub>

# INTERNAL HUB

Use this page if you are on the internal team or maintaining systems and automation.

## What This Section Is For

`docs/internal/` contains operating knowledge, infrastructure references, and procedure-heavy docs used to run Silverware Games systems.

## Recommended Reading Order

1. [../indexes/repo-map.md](../indexes/repo-map.md) for the authoritative document inventory.
2. [repo-map-automation-setup.md](./repo-map-automation-setup.md) for setting up automatic repo-map verification (recommended!).
3. [local-workspace.md](./local-workspace.md) for the canonical local repo layout.
4. [droplet/droplet.md](./droplet/droplet.md) for current server structure.
5. [hosting-and-dns.md](./hosting-and-dns.md) for hosting and DNS references.
6. [calendar.md](./calendar.md) for working rhythm expectations.
7. [wordpress/staging-server.md](./wordpress/staging-server.md) for staging architecture.
8. [wordpress/onboarding.md](./wordpress/onboarding.md) for onboarding procedures.
9. [wordpress/deployment.md](./wordpress/deployment.md) for deployment workflow.
10. [droplet/content-ops.md](./droplet/content-ops.md) for command-level operations.
11. [legacy-projects.md](./legacy-projects.md) and [migration-from-hostgator.md](./migration-from-hostgator.md) only for historical context.

## In A Hurry

Use task-based triage:

1. Infra issue: [droplet/droplet.md](./droplet/droplet.md) then [hosting-and-dns.md](./hosting-and-dns.md).
2. WordPress release: [wordpress/deployment.md](./wordpress/deployment.md) then [wordpress/staging-server.md](./wordpress/staging-server.md).
3. Content changes on server: [droplet/content-ops.md](./droplet/content-ops.md).
4. Local repo or staging-file question: [local-workspace.md](./local-workspace.md).

## Should Anything Be Ignored?

For day-to-day operations, yes:

- Treat historical docs (`legacy-projects.md`, `migration-from-hostgator.md`) as optional unless you are investigating old migrations.
- Read only the runbook that matches your current incident or task.
