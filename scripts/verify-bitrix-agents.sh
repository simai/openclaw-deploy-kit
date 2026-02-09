#!/usr/bin/env bash
set -euo pipefail

AGENTS=(bitrix-router bitrix-support bitrix-sales bitrix-ops)

command -v openclaw >/dev/null

echo "[verify-agents] checking presence"
list_json="$(openclaw agents list --json)"
for a in "${AGENTS[@]}"; do
  if echo "$list_json" | grep -q '"id": "'"$a"'"'; then
    echo "  - ok: $a"
  else
    echo "  - missing: $a"
    exit 2
  fi
done

echo "[verify-agents] probing each agent"
probe() {
  local agent="$1"
  local msg="$2"
  local sk="agent:${agent}:verify:$(date -u +%s):$RANDOM"
  local params
  params=$(printf '{"idempotencyKey":"verify-%s-%s","agentId":"%s","sessionKey":"%s","message":"%s"}' "$agent" "$RANDOM" "$agent" "$sk" "$msg")
  out=$(openclaw gateway call agent --json --expect-final --timeout 30000 --params "$params") || {
    echo "[verify-agents] call failed: $agent"
    return 1
  }
  text=$(echo "$out" | sed -n 's/.*"text": "\(.*\)".*/\1/p' | head -n1)
  if [ -z "$text" ]; then
    echo "[verify-agents] empty reply: $agent"
    return 1
  fi
  echo "  - ok: $agent"
}

probe bitrix-router "маршрутизация"
probe bitrix-support "ошибка интеграции"
probe bitrix-sales "какая цена"
probe bitrix-ops "дай runbook деплоя"

echo "[verify-agents] done"
