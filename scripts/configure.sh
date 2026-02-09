#!/usr/bin/env bash
set -euo pipefail
PROFILE="${1#--profile=}" || true
PROFILE=${PROFILE:-${PROFILE:-split-bridge}}

if [ ! -f .env ]; then
  cp .env.example .env
  echo "[configure] created .env"
fi

echo "[configure] profile=${PROFILE}"
echo "[configure] TODO: render systemd/nginx templates"
