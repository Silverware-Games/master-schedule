# START HERE

This is the universal orientation document for the `silverware-drawer` repository.

## What Silverware Games Is

Silverware Games (SWG) is an independent game studio, creative playground, and collaboration hub.

SWG works across games, art, media, and client projects. The company culture is practical, experimental, and fun-focused.

## What This Repository Is For

This repository is a documentation hub that helps humans and AI systems quickly find the right information.

It is intentionally organized by audience and task so that people do not need prior context to navigate it.

## How Documentation Is Organized

- [README.md](README.md): front-door dashboard with role-based routing.
- [docs/public/](docs/public/): public-facing information about SWG.
- [docs/collaborators/](docs/collaborators/): onboarding and contribution guidance.
- [docs/clients/](docs/clients/): client-facing service and workflow documentation.
- [docs/internal/](docs/internal/): internal operational and planning docs.
- [docs/indexes/](docs/indexes/): navigation indexes by audience, project, task, and brand.

## Public vs Internal

Public-safe content lives in:

- [docs/public/](docs/public/)
- selected client guidance in [docs/clients/](docs/clients/)

Internal-only or operational content lives in:

- [docs/internal/](docs/internal/)

If you are unsure whether something should be public, place it in `docs/internal/` first and review later.

## Where To Find Things

Start with:

- [docs/indexes/by-audience.md](docs/indexes/by-audience.md)

Then branch by role:

- New visitors: [docs/public/about-swg.md](docs/public/about-swg.md)
- Collaborators: [docs/collaborators/collaborator-onboarding.md](docs/collaborators/collaborator-onboarding.md)
- Clients: [docs/clients/services-overview.md](docs/clients/services-overview.md)
- Internal SWG: [docs/internal/repo-map.md](docs/internal/repo-map.md)
- AI systems: [docs/indexes/by-task.md](docs/indexes/by-task.md)

## How Collaborators Can Participate

Collaborators should follow this order:

1. Read [docs/collaborators/collaborator-onboarding.md](docs/collaborators/collaborator-onboarding.md).
2. Review [docs/collaborators/contribution-paths.md](docs/collaborators/contribution-paths.md).
3. Follow [docs/collaborators/repo-and-communication-norms.md](docs/collaborators/repo-and-communication-norms.md).

## Notes For AI And Automation

For predictable parsing:

- start at [README.md](README.md)
- then read [START-HERE.md](START-HERE.md)
- then use [docs/indexes/by-audience.md](docs/indexes/by-audience.md) and [docs/indexes/by-task.md](docs/indexes/by-task.md)

This repo is intended to be machine-navigable as well as human-readable.
