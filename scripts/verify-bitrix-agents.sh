#!/usr/bin/env bash
set -euo pipefail

AGENTS=(bitrix-router bitrix-support bitrix-sales bitrix-ops)
VERIFY_TIMEOUT_MS="${VERIFY_TIMEOUT_MS:-30000}"
VERIFY_RETRIES="${VERIFY_RETRIES:-3}"
MODE="${1:-full}"   # full|quick

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

if [ "$MODE" = "quick" ]; then
  echo "[verify-agents] quick mode: presence only"
  exit 0
fi

echo "[verify-agents] probing each agent (timeout=${VERIFY_TIMEOUT_MS}ms retries=${VERIFY_RETRIES})"
probe_once() {
  local agent="$1"
  local msg="$2"
  local sk="agent:${agent}:verify:$(date -u +%s):$RANDOM"
  local params
  params=$(printf '{"idempotencyKey":"verify-%s-%s","agentId":"%s","sessionKey":"%s","message":"%s"}' "$agent" "$RANDOM" "$agent" "$sk" "$msg")
  local out
  out=$(openclaw gateway call agent --json --expect-final --timeout "$VERIFY_TIMEOUT_MS" --params "$params")
  local text
  text=$(echo "$out" | sed -n 's/.*"text": "\(.*\)".*/\1/p' | head -n1)
  [ -n "$text" ]
}

probe_with_retry() {
  local agent="$1"
  local msg="$2"
  local attempt=1
  while [ "$attempt" -le "$VERIFY_RETRIES" ]; do
    if probe_once "$agent" "$msg"; then
      echo "  - ok: $agent (attempt $attempt/$VERIFY_RETRIES)"
      return 0
    fi
    echo "  - retry: $agent (attempt $attempt/$VERIFY_RETRIES failed)"
    attempt=$((attempt+1))
    sleep 1
  done
  echo "[verify-agents] call failed after retries: $agent"
  return 1
}

probe_with_retry bitrix-router "маршрутизация"
probe_with_retry bitrix-support "ошибка интеграции"
probe_with_retry bitrix-sales "какая цена"
probe_with_retry bitrix-ops "дай runbook деплоя"

echo "[verify-agents] done"
