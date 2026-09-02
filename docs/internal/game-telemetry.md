<sub><em>Status: Active | Audience: Internal | Doc-Type: Workflow | Owner: Michael | Last Reviewed: 2026-09-02 | Canonical: Yes</em></sub>

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
      "eventId": "stable-per-event-guid",
      "environment": "production",
      "site": "matchystar.com",
      "game": "matchystar",
      "platform": "unity_windows",
      "version": "0.1.0",
      "visitorId": "anonymous-persistent-guid",
      "sessionId": "per-launch-guid",
      "page": "/unity/game",
      "timestamp": 1784995200000,
      "data": {
        "trackerVersion": "unity-v2",
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
| `eventId` | A new random GUID for each logical event, retained across retries |
| `environment` | `production`; Editor and Development Builds use `development` and are discarded |
| `site` | `matchystar.com` |
| `game` | `matchystar` |
| `platform` | `unity_windows`, `unity_editor`, or the equivalent Unity runtime platform |
| `version` | `Application.version` |
| `page` | `/unity/game` |
| `data.trackerVersion` | `unity-v2` |

Native players post directly to `stats.silverwaregames.com`; `matchystar.com` does not proxy or redirect telemetry. Browser CORS origins are still registered for future WebGL clients.

The server acknowledges and discards `qa` and `development` events before
validation, storage, rollups, or reporting. Missing `environment` retains the
legacy `production` meaning. Matchy Star additionally suppresses the sender
entirely for `-MenuQA`, `-MenuQAOnly`, `-swgTelemetryDisabled`, and the
machine-level `MATCHYSTAR_TELEMETRY_DISABLED` opt-out. Do not identify a
developer by IP address.

## Matchy Star Detail Events

- `menu_view` records the bounded settled-menu enum.
- `menu_action` records bounded parent-menu and button-action enums after an
  accepted release; disabled controls are excluded.
- `item_purchase` is emitted only after a successful purchase/equip and records
  the catalog item name/type, normalized tier, paid price, and remaining balance.
- `level_complete.data.score` is cumulative ending route Zoot. Historical
  reports may fall back to `data.zoot` for that same meaning.
- `level_complete.data.zootGained` is the non-negative attempt-local earnings
  delta and must not fall back to ending balance.

These values are bounded catalog/enum/numeric fields. They must not contain
typed labels or other player-authored content.

## Minimum Gameplay Lifecycle

1. Emit `app_launch` as soon as the native telemetry runtime starts.
2. Emit `game_ready` once the main scene and required game state are usable,
   with elapsed time measured from Unity process uptime.
3. Emit `game_start` only after the player's first real interaction.
4. Emit `level_start` from authoritative gameplay/run mutation when a playable
   attempt begins, not from menu presentation or planet highlighting.
5. Emit exactly one `level_complete` for each win, loss, restart, replacement,
   or abandonment. Emit `game_over` for terminal route/run outcomes.
6. Emit focused, unpaused, bounded `performance` windows and a low-frequency
   active `heartbeat`.
7. Emit `heartbeat phase=hidden` on pause and `phase=exit` on every ordinary
   shutdown. Persist the complete newly queued shutdown sequence—terminal
   `level_complete`, terminal `game_over`, and the exit heartbeat—with its
   original stable event IDs until the server accepts each event. A next-launch
   replay is therefore deduplicated safely.
8. Flush on a short interval and on application pause. Immediate delivery at
   process teardown remains best-effort, while the persisted ordinary-shutdown
   sequence is replayed on the next launch. A hard process kill can still skip
   Unity's quit callback before that snapshot is written.
9. Report bounded `error` events for unhandled Unity log exceptions.

Matchy Star's existing `StatsManager` records local match, color, ship, and Zoot totals. Network telemetry belongs in a separate `SwgTelemetryClient` so those responsibilities remain distinct.

## Failure Rules

- Telemetry failures must never prevent loading, input, saving, level completion, or shutdown.
- Use a bounded in-memory queue.
- Retry transient network failures with delay; do not retry malformed `400` responses forever.
- Give each logical event a stable ID before its first send so a retry can be deduplicated.
- Cap retries and queue size so an unavailable service cannot consume unbounded memory.
- Do not log full event payloads in production.
- Duplicate lifecycle calls must be suppressed by the client.

## Rollout Checklist

1. Confirm the product slug and lifecycle mapping.
2. Add or update server validation tests.
3. Deploy and verify server support before releasing the client.
4. Implement the Unity client behind an enable switch.
5. Run Matchy Star's cross-repository contract test. It uses the real Unity
   queue and `JsonUtility` serializer, rewrites only the test envelope to the
   release environment/platform, POSTs it through a real local stats server,
   retries the same stable event IDs, and verifies raw storage, privacy,
   funnels, menu/economy reports, frame metrics, and win/loss/abandon results:

   ```powershell
   .\MatchyStar\Tools\Invoke-NativeTelemetryContract.ps1
   ```

   The script requires both repositories and the canonical Unity editor. It
   never points the fixture at production.
6. Verify accepted events and private flow reporting.
7. Build the target Unity player and confirm gameplay is unaffected with the stats service unavailable.
8. Release gradually and review errors, starts, level outcomes, and abandonment before expanding event coverage.
