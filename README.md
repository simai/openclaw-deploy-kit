# openclaw-deploy-kit

Deploy kit for OpenClaw-side infrastructure (bridge-first).

## Purpose

Standardize installation and verification on servers where OpenClaw Bridge runs.

## Profiles

- `all-in-one` — app + bridge on one host (temporary/dev)
- `split-bridge` — bridge on OpenClaw host, app on separate host (recommended)

## Quick start

```bash
cp .env.example .env
bash scripts/install.sh --profile=split-bridge
bash scripts/configure.sh --profile=split-bridge
bash scripts/verify.sh --profile=split-bridge
```
