#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
WORKSPACE_ROOT="${WORKSPACE_ROOT:-/root/.openclaw/workspace/agents}"
MODEL="${MODEL:-openai-codex/gpt-5.3-codex}"
COPY_AUTH_FROM_MAIN="${COPY_AUTH_FROM_MAIN:-1}"

AGENTS=(bitrix-router bitrix-support bitrix-sales bitrix-ops)

echo "[bootstrap-agents] root=$ROOT_DIR"
echo "[bootstrap-agents] workspace_root=$WORKSPACE_ROOT"
echo "[bootstrap-agents] model=$MODEL"

command -v openclaw >/dev/null
mkdir -p "$WORKSPACE_ROOT"

existing_json="$(openclaw agents list --json)"

for agent in "${AGENTS[@]}"; do
  ws="$WORKSPACE_ROOT/$agent"
  if echo "$existing_json" | grep -q '"id": "'"$agent"'"'; then
    echo "[bootstrap-agents] exists: $agent"
  else
    echo "[bootstrap-agents] create: $agent"
    openclaw agents add "$agent" --workspace "$ws" --non-interactive --model "$MODEL" --json >/dev/null
  fi

  mkdir -p "$ws"
  tpl="$ROOT_DIR/templates/agents/$agent.AGENTS.md"
  if [ -f "$tpl" ]; then
    cp -f "$tpl" "$ws/AGENTS.md"
    echo "[bootstrap-agents] wrote $ws/AGENTS.md"
  fi

  if [ "$COPY_AUTH_FROM_MAIN" = "1" ]; then
    src_auth="/root/.openclaw/agents/main/agent/auth-profiles.json"
    dst_dir="/root/.openclaw/agents/$agent/agent"
    if [ -f "$src_auth" ]; then
      mkdir -p "$dst_dir"
      cp -f "$src_auth" "$dst_dir/auth-profiles.json"
      echo "[bootstrap-agents] auth copied for $agent"
    fi
  fi
done

echo "[bootstrap-agents] done"
