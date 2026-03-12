<sub><em>Status: Active | Audience: All | Doc-Type: Reference | Owner: Michael | Last Reviewed: 2026-03-11 | Canonical: Yes</em></sub>

# Silverware Games Repository Map

This file is the source of truth for documentation navigation in `silverware-drawer`.

Any human or AI that adds, removes, renames, or materially changes a major doc must update this file in the same change.

## Metadata Header Contract

Every Markdown doc must begin with:

```text
<sub><em>Status: <Active|Draft|Needs Review|Archived|Replaced By> | Audience: <target readers> | Doc-Type: <Orientation|Reference|Workflow> | Owner: <primary owner> | Last Reviewed: <YYYY-MM-DD> | Canonical: <Yes|No></em></sub>
```

## Status Legend

- `Active`: living and currently used.
- `Draft`: incomplete or planned content that is not yet authoritative.
- `Needs Review`: content exists but must be validated before relying on it.
- `Archived`: historical only; not part of active operations.
- `Replaced By`: superseded by a newer canonical document.

## Doc-Type Legend

- `Orientation`: entry points and navigation-focused docs.
- `Reference`: descriptive, factual, or archival docs used for lookup.
- `Workflow`: process and procedure docs used to execute work.

## Major Document Registry

| Doc                                                                                          | Title                                                   | Audience                       | Purpose                                                         | Doc Type    | Status       | Owner   | Last Reviewed |
| -------------------------------------------------------------------------------------------- | ------------------------------------------------------- | ------------------------------ | --------------------------------------------------------------- | ----------- | ------------ | ------- | ------------- |
| [README.md](../../README.md)                                                                 | Welcome to the Silverware Games "Silverware Drawer"     | Everyone                       | Root router by audience and task.                               | Orientation | Active       | Michael | 2026-03-11    |
| [START-HERE.md](../../START-HERE.md)                                                         | START HERE                                              | Everyone                       | Human-first intro to repo intent and structure.                 | Orientation | Active       | Michael | 2026-03-11    |
| [docs/public/PUBLIC-HUB.md](../public/PUBLIC-HUB.md)                                         | PUBLIC HUB                                              | Public                         | Audience landing page for public readers.                       | Orientation | Active       | Michael | 2026-03-11    |
| [docs/collaborators/COLLABORATOR-HUB.md](../collaborators/COLLABORATOR-HUB.md)               | COLLABORATOR HUB                                        | Collaborators                  | Audience landing page for collaborators and contributors.       | Orientation | Active       | Michael | 2026-03-11    |
| [docs/clients/CLIENT-HUB.md](../clients/CLIENT-HUB.md)                                       | CLIENT HUB                                              | Clients                        | Audience landing page for clients and prospects.                | Orientation | Active       | Michael | 2026-03-11    |
| [docs/internal/INTERNAL-HUB.md](../internal/INTERNAL-HUB.md)                                 | INTERNAL HUB                                            | Internal                       | Audience landing page for team operations and automation.       | Orientation | Active       | Michael | 2026-03-11    |
| [docs/indexes/orientation-docs.md](./orientation-docs.md)                                    | Orientation Docs Index                                  | Everyone                       | Index of stable entry-point docs.                               | Orientation | Active       | Michael | 2026-03-11    |
| [docs/indexes/operational-docs.md](./operational-docs.md)                                    | Operational Docs Index                                  | Internal and collaborators     | Index of procedure-heavy, living runbooks.                      | Orientation | Active       | Michael | 2026-03-11    |
| [docs/indexes/repo-map.md](./repo-map.md)                                                    | Silverware Games Repository Map                         | Maintainers and AI             | Canonical inventory and metadata map for docs.                  | Reference   | Active       | Michael | 2026-03-11    |
| [docs/indexes/project-index.md](./project-index.md)                                          | Project Index                                           | Public, clients, collaborators | Snapshot of active and visible projects.                        | Reference   | Needs Review | Michael | 2026-03-11    |
| [docs/indexes/incomplete-docs.md](./incomplete-docs.md)                                      | Incomplete Docs Index                                   | Internal                       | Auto-generated index of all Draft and Needs Review documents.   | Workflow    | Active       | Michael | 2026-03-11    |
| [docs/public/coffee-doodle-art.md](../public/coffee-doodle-art.md)                           | Coffee Doodle Art                                       | Public                         | Landing page for the Coffee Doodle Art initiative.              | Reference   | Draft        | Michael | 2026-03-11    |
| [docs/public/gamedev-feedback.md](../public/gamedev-feedback.md)                             | GameDev Feedback (TBD)                                  | Public                         | Reserved for future feedback and review content.                | Reference   | Draft        | Michael | 2026-03-11    |
| [docs/public/philosophy-and-ethos.md](../public/philosophy-and-ethos.md)                     | Philosophy And Ethos                                    | Public and collaborators       | Describes creative principles and working values.               | Orientation | Active       | Michael | 2026-03-11    |
| [docs/public/podcasts-and-content.md](../public/podcasts-and-content.md)                     | Podcasts And Content                                    | Public                         | Tracks podcast and creator-facing media output.                 | Reference   | Needs Review | Michael | 2026-03-11    |
| [docs/public/social-media-overview.md](../public/social-media-overview.md)                   | Social Media Overview                                   | Public                         | Planned overview of social channels and cadence.                | Reference   | Draft        | Michael | 2026-03-11    |
| [docs/collaborators/collaborator-onboarding.md](../collaborators/collaborator-onboarding.md) | Collaboration Guide                                     | Collaborators                  | Onboarding and contribution guide for collaborators.            | Workflow    | Active       | Michael | 2026-03-11    |
| [docs/clients/services-overview.md](../clients/services-overview.md)                         | Services Overview                                       | Clients                        | Explains Silverware Games service offerings and delivery model. | Orientation | Needs Review | Michael | 2026-03-11    |
| [docs/internal/calendar.md](../internal/calendar.md)                                         | Silverware Games - Living Calendar                      | Internal                       | Records recurring work rhythms and expectations.                | Workflow    | Needs Review | Michael | 2026-03-11    |
| [docs/internal/hosting-and-dns.md](../internal/hosting-and-dns.md)                           | Hosting And DNS                                         | Internal                       | Current hosting and DNS architecture reference.                 | Reference   | Needs Review | Michael | 2026-03-11    |
| [docs/internal/HTML5-engine.md](../internal/HTML5-engine.md)                                 | HTML5 Engine (TBD)                                      | Internal                       | Reserved for engine architecture and implementation notes.      | Reference   | Draft        | Michael | 2026-03-11    |
| [docs/internal/legacy-projects.md](../internal/legacy-projects.md)                           | File Listing of Archived Files from HostGator Migration | Internal                       | Inventory of legacy directories and archive decisions.          | Reference   | Archived     | Michael | 2026-03-11    |
| [docs/internal/migration-from-hostgator.md](../internal/migration-from-hostgator.md)         | HostGator Migration Archive                             | Internal                       | Historical record of completed migration work.                  | Reference   | Replaced By  | Michael | 2026-03-11    |
| [docs/internal/droplet/content-ops.md](../internal/droplet/content-ops.md)                   | Content Ops - Server Command Reference                  | Internal                       | Command reference for server content operations.                | Workflow    | Needs Review | Michael | 2026-03-11    |
| [docs/internal/droplet/droplet.md](../internal/droplet/droplet.md)                           | DigitalOcean Droplet Structure                          | Internal                       | Source of truth for active droplet layout.                      | Reference   | Active       | Michael | 2026-03-11    |
| [docs/internal/wordpress/deployment.md](../internal/wordpress/deployment.md)                 | Silverware Games WordPress Deployment Workflow          | Internal and collaborators     | Procedure for safe staging-to-production deployment.            | Workflow    | Needs Review | Michael | 2026-03-11    |
| [docs/internal/wordpress/onboarding.md](../internal/wordpress/onboarding.md)                 | Silverware Games WordPress Client Onboarding            | Internal and collaborators     | Procedure for onboarding new WordPress clients into staging.    | Workflow    | Needs Review | Michael | 2026-03-11    |
| [docs/internal/wordpress/staging-server.md](../internal/wordpress/staging-server.md)         | Silverware Games WordPress Staging Server Architecture  | Internal and collaborators     | Architecture and conventions for WordPress staging.             | Reference   | Needs Review | Michael | 2026-03-11    |
| [docs/internal/wordpress/workflow-client.md](../internal/wordpress/workflow-client.md)       | Silverware Games WordPress Development Process          | Clients and collaborators      | Client-facing workflow from staging through approval.           | Workflow    | Needs Review | Michael | 2026-03-11    |

## Supporting Folders

- `docs/assets/` stores shared documentation assets and is currently empty.
- `docs/diagrams/` is reserved for architecture and process diagrams and is currently empty.
