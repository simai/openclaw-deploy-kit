#!/usr/bin/env bash
set -euo pipefail

echo "[harden-bitrix-security] applying security policy"

DENY='["exec","write","edit","gateway","cron","nodes","browser","canvas","message","sessions_send","sessions_spawn"]'

openclaw config set --json 'agents.defaults.sandbox' '{"mode":"non-main","workspaceAccess":"none","sessionToolsVisibility":"spawned","scope":"agent"}'

agents_json="$(openclaw config get agents.list --json)"
patched="$(echo "$agents_json" | jq --argjson deny "$DENY" '
  map(
    if (.id | startswith("bitrix-")) then
      . + {
        tools: ((.tools // {}) + {profile:"minimal", deny:$deny}),
        memorySearch: ((.memorySearch // {}) + {enabled:false})
      }
    else . end
  )
')"

openclaw config set --json 'agents.list' "$patched"
openclaw gateway restart >/dev/null || true

echo "[harden-bitrix-security] done"
