<sub><em>Status: Active | Audience: Internal | Doc-Type: Workflow | Owner: Michael | Last Reviewed: 2026-07-25 | Canonical: Yes</em></sub>

# Game Telemetry Integration

This document defines how Silverware Games clients hand gameplay telemetry to the shared stats service. It is the cross-repository integration contract; implementation details remain in the repository that owns them.

## Ownership

| Concern | Source of truth |
| --- | --- |
| Shared integration workflow, privacy rules, and rollout checklist | `silverware-drawer/docs/internal/game-telemetry.md` |
| Accepted events, validation, storage, reporting, and operations | `silverwaregames.com/docs/stats-server.md` and `silverwaregames.com/server/statsServer.js` |
| Matchy Star Unity client and gameplay hooks | `E:\Dev\MatchyStar.git\MatchyStar\Assets\Telemetry\` |

Do not copy the complete server contract into every game. Link to the server documentation and keep game repositories focused on their local lifecycle mapping.

## Transport

Clients send JSON batches to:

```text
POST https://stats.silverwaregames.com/v1/events
Content-Type: application/json
```

The request body is:

```json
{
  "events": [
    {
      "event": "level_start",
      "site": "matchystar.com",
      "game": "matchystar",
      "platform": "unity_windows",
      "version": "0.1.0",
      "visitorId": "anonymous-persistent-guid",
      "sessionId": "per-launch-guid",
      "page": "/unity/game",
      "timestamp": 1784995200000,
      "data": {
        "trackerVersion": "unity-v1",
        "level": "Windy Path",
        "attempt": 1
      }
    }
  ]
}
```

The current service accepts at most 50 events and 64 KB per request. Clients should use smaller batches, send asynchronously, and never block gameplay on telemetry.

## Identity And Privacy

- Generate a random visitor GUID once and retain it in the game's local preferences.
- Generate a new random session GUID for each application launch.
- Do not use a Steam display name, email address, IP address, hardware ID, save filename, or typed player text.
- Do not send board contents, cursor paths, or per-frame movement.
- Leave `playerId` empty until a separate privacy decision explicitly defines a safe account identifier.
- Keep error messages and context bounded; never attach arbitrary files or user content.

The stats server hashes accepted identifiers before writing events.

## Native Unity Product Fields

Matchy Star uses:

| Field | Value |
| --- | --- |
| `site` | `matchystar.com` |
| `game` | `matchystar` |
| `platform` | `unity_windows`, `unity_editor`, or the equivalent Unity runtime platform |
| `version` | `Application.version` |
| `page` | `/unity/game` |
| `data.trackerVersion` | `unity-v1` |

Native players post directly to `stats.silverwaregames.com`; `matchystar.com` does not proxy or redirect telemetry. Browser CORS origins are still registered for future WebGL clients.

## Minimum Gameplay Lifecycle

1. Emit `game_ready` once the main scene and required game state are usable.
2. Emit `game_start` after the player's first real interaction.
3. Emit `level_start` when a playable planet attempt begins, not merely when a planet is highlighted.
4. Emit exactly one `level_complete` for each win, loss, restart, replacement, or abandonment.
5. Emit `game_over` when the route or run ends.
6. Emit a low-frequency `heartbeat` while gameplay is active.
7. Flush on a short interval and on application pause. Application quit delivery is best-effort.
8. Report bounded `error` events for unhandled Unity log exceptions.

Matchy Star's existing `StatsManager` records local match, color, ship, and Zoot totals. Network telemetry belongs in a separate `SwgTelemetryClient` so those responsibilities remain distinct.

## Failure Rules

- Telemetry failures must never prevent loading, input, saving, level completion, or shutdown.
- Use a bounded in-memory queue.
- Retry transient network failures with delay; do not retry malformed `400` responses forever.
- Cap retries and queue size so an unavailable service cannot consume unbounded memory.
- Do not log full event payloads in production.
- Duplicate lifecycle calls must be suppressed by the client.

## Rollout Checklist

1. Confirm the product slug and lifecycle mapping.
2. Add or update server validation tests.
3. Deploy and verify server support before releasing the client.
4. Implement the Unity client behind an enable switch.
5. Test against a local stats server with synthetic anonymous IDs.
6. Verify accepted events and private flow reporting.
7. Build the target Unity player and confirm gameplay is unaffected with the stats service unavailable.
8. Release gradually and review errors, starts, level outcomes, and abandonment before expanding event coverage.
