<sub><em>Status: Active | Audience: Internal | Doc-Type: Reference | Owner: Michael | Last Reviewed: 2026-08-02 | Canonical: Yes</em></sub>

# Documentation Backlog

This page tracks missing documentation that would materially improve how Silverware Games operates. It is a backlog, not a collection of empty files.

Use the generated [Incomplete Docs Index](./incomplete-docs.md) for documents that already exist but remain Draft or Needs Review.

## Priority 1: Protect Production Work

| Needed Document | Why It Matters | Ready To Write When |
| --- | --- | --- |
| Incident response | Establishes triage, communication, rollback, evidence capture, and follow-up for outages or broken releases. | Current hosting owners confirm notification and recovery paths. |
| Non-WordPress website deployment | Captures the common build, validation, deployment, cache, and rollback pattern used by static sites and web games. | The shared pattern is reconciled across at least two active sites. |
| Backup and restore | Separates “a backup exists” from a tested recovery procedure. | Storage locations, retention, and restore ownership are confirmed. |

## Priority 2: Make Projects Easier To Start And Finish

| Needed Document | Why It Matters | Ready To Write When |
| --- | --- | --- |
| New-project checklist | Creates consistent repository, tracker, domain, analytics, documentation, and ownership setup. | The minimum requirements are agreed. |
| Game release checklist | Covers build identity, platform requirements, smoke tests, store assets, telemetry, communication, and rollback. | One recent release is used as the concrete baseline. |
| Project retirement checklist | Preserves source, ownership, domains, data, builds, and public messaging when active work stops. | Lifecycle vocabulary and archive destinations are agreed. |

## Priority 3: Reduce Repeated Decisions

| Needed Document | Why It Matters | Ready To Write When |
| --- | --- | --- |
| Domain and DNS change workflow | Adds change validation and rollback to the existing architecture reference. | The authoritative DNS providers and access owners are confirmed. |
| Repository conventions | Defines when to create a code repo, public issue tracker, GDD, or combined project. | Current repository patterns are reviewed for intentional exceptions. |
| Decision log convention | Gives important technical and product decisions a durable, searchable home. | A lightweight format and storage location are chosen. |

## Backlog Rules

- Do not create a placeholder document until someone can add useful confirmed content.
- Link evidence, examples, and responsible systems when beginning a backlog item.
- Mark uncertain procedures as `Needs Review`; never present guesses as production runbooks.
- Remove an item from this page when its document is created and registered in the repository map.
- Revisit priorities when infrastructure, release practices, or project ownership changes.
