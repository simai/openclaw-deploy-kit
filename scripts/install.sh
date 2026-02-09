#!/usr/bin/env bash
set -euo pipefail
PROFILE="${1#--profile=}" || true
PROFILE=${PROFILE:-${PROFILE:-split-bridge}}

echo "[install] profile=${PROFILE}"
command -v node >/dev/null
command -v npm >/dev/null
command -v systemctl >/dev/null

echo "[install] prerequisites ok"
