<sub><em>Status: Archived | Audience: Internal | Doc-Type: Reference | Owner: Michael | Last Reviewed: 2026-08-02 | Canonical: No</em></sub>

# Legacy Hosting Archive Summary

This page preserves the useful conclusions from the completed legacy-hosting review without publishing the original server paths, client references, build filenames, or artifact inventory.

## Historical Outcome

The previous hosting account contained a mixture of active websites, early game builds, prototypes, WordPress installations, experiments, press material, client work, and unclassified files. The migration review separated that material into four outcomes:

| Outcome | Meaning |
| --- | --- |
| Migrated | Still-active properties and required assets moved to their current owned homes. |
| Preserved privately | Historically useful builds, source, media, and records were retained outside the public web root. |
| Superseded | Old sites, installs, and generated output were replaced by current repositories or services. |
| Not restored | Obsolete, duplicated, unsafe, or unidentified material was intentionally kept out of production. |

## Durable Decisions

- Active properties should be deployed from an owned repository or another documented source of truth.
- Historical builds and raw archives should not be placed on a production web server merely to preserve them.
- Client material remains separated from studio archives and follows current authorization and retention requirements.
- Old databases, server-side scripts, logs, configuration, and administrative utilities are not public artifacts.
- A legacy filename or directory is not proof that its contents are authoritative or safe to run.
- Public project history belongs in the relevant project home; private artifact-level inventories belong in access-controlled archival records.

## If Historical Material Is Needed

1. Identify the project and the business or preservation reason for retrieving it.
2. Ask the current archive owner to search the private inventory.
3. Inspect recovered material in an isolated environment before opening or executing it.
4. Check ownership, client confidentiality, licensing, credentials, personal data, and malware risk.
5. Promote only reviewed, necessary material into a current repository or public destination.
6. Record the decision in the private archive log.

## Public Repository Boundary

Do not add old hosting paths, account names, client identifiers, backup locations, database names, build filenames, configuration dumps, or exhaustive archive listings to this repository.

For current policy, use [Hosting Operations Boundary](./droplet/droplet.md). For migration history, use [Host Migration Archive](./migration-from-hostgator.md).
