#!/usr/bin/env bash
set -euo pipefail

# Set Discord Bot Presence
# Usage: set-presence.sh <type> <text> [status]
#
# type:   playing | watching | listening | competing | custom
# text:   Activity text (e.g., "D&D 5e", "3 active games")
# status: online | idle | dnd | invisible (default: online)
#
# Note: This uses the Discord Gateway API via a REST workaround.
# Discord bots normally set presence via the Gateway websocket, but
# we can use the REST API to update the bot's application activity.
# For reliable presence, this is best called periodically.

ACTIVITY_TYPE="${1:?Usage: set-presence.sh <type> <text> [status]}"
ACTIVITY_TEXT="${2:?Usage: set-presence.sh <type> <text> [status]}"
BOT_STATUS="${3:-online}"

if [[ -z "${DISCORD_BOT_TOKEN:-}" ]]; then
  echo '{"error":"DISCORD_BOT_TOKEN is not set"}' >&2
  exit 1
fi

# Map activity type names to Discord enum values
case "$ACTIVITY_TYPE" in
  playing)    TYPE_NUM=0 ;;
  streaming)  TYPE_NUM=1 ;;
  listening)  TYPE_NUM=2 ;;
  watching)   TYPE_NUM=3 ;;
  custom)     TYPE_NUM=4 ;;
  competing)  TYPE_NUM=5 ;;
  *)
    echo "{\"error\":\"Unknown activity type: ${ACTIVITY_TYPE}. Valid: playing, watching, listening, competing, custom\"}" >&2
    exit 1
    ;;
esac

# Build the presence payload
# Note: Setting presence via REST is limited. The standard approach is via
# Gateway IDENTIFY or PRESENCE_UPDATE opcodes. This script writes a state file
# that a presence daemon or the gateway startup can pick up.
PRESENCE_DIR="$HOME/.openclaw/bot-presence"
mkdir -p "$PRESENCE_DIR"

PRESENCE_TEXT="$ACTIVITY_TEXT" PRESENCE_TYPE="$TYPE_NUM" PRESENCE_STATUS="$BOT_STATUS" \
  python3 -c "
import json, os
presence = {
    'status': os.environ['PRESENCE_STATUS'],
    'activities': [{
        'name': os.environ['PRESENCE_TEXT'],
        'type': int(os.environ['PRESENCE_TYPE'])
    }]
}
state_path = os.path.join(os.environ['HOME'], '.openclaw', 'bot-presence', 'current.json')
with open(state_path, 'w') as f:
    json.dump(presence, f, indent=2)
print(json.dumps({'ok': True, 'presence': presence}))
"
