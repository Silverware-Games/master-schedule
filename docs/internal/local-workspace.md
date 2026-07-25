<sub><em>Status: Active | Audience: Internal | Doc-Type: Workflow | Owner: Michael | Last Reviewed: 2026-07-25 | Canonical: Yes</em></sub>

# Local Silverware Games Workspace

The canonical local development workspace for Silverware Games is:

```text
E:\Dev\SilverwareGames
```

Open this folder when working across the main site, public docs, shared engine, or any current web game.

## Canonical Local Repos

| Folder | Role |
| --- | --- |
| `silverwaregames.com` | Main Silverware Games website and latest-game feed |
| `silverware-drawer` | Public-facing company documentation and knowledge base |
| `swgengine` | Shared Silverware Games engine, UI, audio, settings, versioning, and shared assets |
| `kingzazz.com` | King Zazz game site |
| `eggfun.io` | Egg Fun game site |
| `bobblebonanza.io` | Bobble Bonanza game site |
| `firestarter.cc` | Firestarter game site |
| `washtowelfill.io` | Wash Towel Fill game site |
| `lilysgame.io` | Lily's Game site and reference implementation for menus/options flow |

## Support Folders

- `E:\Dev\SilverwareGames\_staging` is the drop zone for unsorted files before they are moved into the correct repo.
- `E:\Dev\Archive` stores old top-level checkout folders. Do not do active work from archive folders.

## Active Unity Checkouts

Some established Unity repositories remain directly under `E:\Dev` because their editor and package configuration predates the consolidated web workspace.

| Folder | Role |
| --- | --- |
| `E:\Dev\MatchyStar.git` | Private Matchy Star Unity implementation |

Treat these paths as active canonical checkouts, not archives. Cross-repository work should use explicit paths and separate commits for the Unity project, shared documentation, and hosted services.

## Staging Workflow

1. Drop incoming files into `E:\Dev\SilverwareGames\_staging`.
2. Put files in a project-named subfolder when the owner is known, such as `_staging\swgengine` or `_staging\kingzazz.com`.
3. Use `_staging\unknown` for files that need triage.
4. Ask Codex or a maintainer to move files into the correct repo path.
5. After files are moved, verify the target repo status before committing.

## Engine Rule

Shared behavior should live in `swgengine` whenever practical. Game repos should consume shared behavior through their local `engine` submodule and keep only game-specific hooks, assets, and state locally.

## Naming Rule

- Game and site folders use lowercase public domain names.
- Shared non-domain repos use lowercase repo-style names.
- Old local paths are kept only as archives.
