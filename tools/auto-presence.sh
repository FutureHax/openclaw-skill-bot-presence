#!/usr/bin/env bash
set -euo pipefail

# Auto-Update Bot Presence from Zordon API stats
# Usage: auto-presence.sh
#
# Fetches server stats and sets a dynamic "Watching N active games" presence.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# --- Environment checks ---
if [[ -z "${DISCORD_BOT_TOKEN:-}" ]]; then
  echo '{"error":"DISCORD_BOT_TOKEN is not set"}' >&2
  exit 1
fi

# --- Fetch stats from Zordon API (optional -- graceful fallback) ---
GAME_COUNT=""
if [[ -n "${ZORDON_API_URL:-}" && -n "${ZORDON_API_KEY:-}" ]]; then
  STATUS_JSON=$(curl -sfk --connect-timeout 5 --max-time 10 \
    -H "Authorization: Bearer ${ZORDON_API_KEY}" \
    -H "Accept: application/json" \
    "${ZORDON_API_URL}/status" 2>/dev/null) || true

  if [[ -n "$STATUS_JSON" ]]; then
    GAME_COUNT=$(echo "$STATUS_JSON" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    stats = data.get('stats', data)
    count = stats.get('activeGames') or stats.get('active_games') or stats.get('games', '')
    print(count)
except:
    pass
" 2>/dev/null) || true
  fi
fi

# --- Build presence text ---
if [[ -n "$GAME_COUNT" && "$GAME_COUNT" != "0" && "$GAME_COUNT" != "" ]]; then
  PRESENCE_TEXT="${GAME_COUNT} active games | @mention me"
else
  PRESENCE_TEXT="r2Plays TTRPG | @mention me"
fi

# --- Set presence via the set-presence tool ---
bash "${SCRIPT_DIR}/set-presence.sh" watching "$PRESENCE_TEXT" online
