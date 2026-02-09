#!/usr/bin/env bash
set -euo pipefail

echo "[setup-bitrix] deprecated: use scripts/install.sh"
exec "$(dirname "$0")/install.sh" "$@"
