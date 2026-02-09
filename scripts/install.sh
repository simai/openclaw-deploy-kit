#!/usr/bin/env bash
set -euo pipefail

PROFILE_ARG="${1:-}"
PROFILE="split-bridge"
if [[ "$PROFILE_ARG" == --profile=* ]]; then
  PROFILE="${PROFILE_ARG#--profile=}"
elif [[ -n "$PROFILE_ARG" ]]; then
  PROFILE="$PROFILE_ARG"
fi

echo "[install] profile=$PROFILE"

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

bash scripts/check.sh --profile="$PROFILE"
bash scripts/configure.sh --profile="$PROFILE"
bash scripts/verify.sh --profile="$PROFILE"

echo "[install] success"
