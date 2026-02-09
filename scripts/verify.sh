#!/usr/bin/env bash
set -euo pipefail
PROFILE="${1#--profile=}" || true
PROFILE=${PROFILE:-${PROFILE:-split-bridge}}

echo "[verify] profile=${PROFILE}"
if command -v curl >/dev/null; then
  curl -fsS "http://127.0.0.1:8787/health" || echo "[verify] bridge health not reachable yet"
fi

echo "[verify] done"
