---
name: bot-presence
description: Set the Discord bot's presence (status and activity) dynamically. Supports auto-updating based on server stats from the Zordon API.
metadata: {"openclaw":{"requires":{"env":["DISCORD_BOT_TOKEN"]}}}
---

# Bot Presence

Set Zordon's Discord presence -- the "Playing...", "Watching...", or custom status shown under the bot's name in the member list. Can be set manually or auto-updated based on live server stats.

## When to use

- Owner asks to change Zordon's status or activity
- At startup or on a schedule, to show dynamic info (e.g., "3 games this week")
- Owner asks "what's Zordon's status?" -- check and report the current presence

## Tools

### `set-presence.sh` -- Set bot presence

```bash
bash {baseDir}/tools/set-presence.sh <type> <text> [status]
```

**Arguments:**
- `type` -- Activity type: `playing`, `watching`, `listening`, `competing`, `custom`
- `text` -- The status text (e.g., "3 games this week")
- `status` (optional, default: `online`) -- Bot status: `online`, `idle`, `dnd`, `invisible`

**Examples:**

```bash
# "Playing D&D 5e"
bash {baseDir}/tools/set-presence.sh playing "D&D 5e"

# "Watching 3 active games"
bash {baseDir}/tools/set-presence.sh watching "3 active games"

# "Listening to dice rolls"
bash {baseDir}/tools/set-presence.sh listening "dice rolls"

# Custom status with idle indicator
bash {baseDir}/tools/set-presence.sh custom "@mention me for help!" idle
```

### `auto-presence.sh` -- Auto-update presence from server stats

```bash
bash {baseDir}/tools/auto-presence.sh
```

Fetches live stats from the Zordon API (`/status`) and sets a dynamic presence. The format is:

> **Watching N active games | @mention me**

Where N is the current count of active games. If the API is unavailable, falls back to a static status.

This is designed to run on a cron schedule (e.g., every hour) or at gateway startup.

## Automated scheduling

```bash
# Update presence every hour
0 * * * * set -a && source ~/.openclaw/.env && set +a && bash ~/.openclaw/skills/bot-presence/tools/auto-presence.sh
```

## Guidelines

- Keep status text short -- Discord truncates long activity text
- Use "Watching" for stats-based presences (game count, member count)
- Use "Playing" for fun/thematic statuses
- Don't change presence too frequently -- once per hour max for automated updates
