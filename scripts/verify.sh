#!/usr/bin/env bash
set -euo pipefail
PROFILE="${1#--profile=}" || true
PROFILE=${PROFILE:-${PROFILE:-split-bridge}}

echo "[verify] profile=${PROFILE}"
if command -v curl >/dev/null; then
  curl -fsS "http://127.0.0.1:8787/health" || echo "[verify] bridge health not reachable yet"
fi

echo "[verify] verify dedicated bitrix agents"
VERIFY_TIMEOUT_MS=${VERIFY_TIMEOUT_MS:-30000} VERIFY_RETRIES=${VERIFY_RETRIES:-3} \
  bash "$(dirname "$0")/verify-bitrix-agents.sh" quick

echo "[verify] check bitrix security policy"
openclaw config get agents.defaults.sandbox.mode --json | grep -q '"non-main"'
openclaw config get agents.defaults.sandbox.workspaceAccess --json | grep -q '"none"'
openclaw config get agents.list --json | jq -e '
  map(select(.id|startswith("bitrix-")))
  | length > 0
  and all(.[]; .tools.profile=="minimal")
  and all(.[]; (.memorySearch.enabled==false))
' >/dev/null

echo "[verify] done"
