# openclaw-deploy-kit

Deploy kit for OpenClaw-side infrastructure (bridge-first).

## Purpose

Standardize installation and verification on servers where OpenClaw Bridge runs.

## Profiles

- `all-in-one` — app + bridge on one host (temporary/dev)
- `split-bridge` — bridge on OpenClaw host, app on separate host (recommended)

## Quick start

### One-command setup (recommended)

```bash
cp .env.example .env
bash scripts/install.sh --profile=split-bridge
```

### Step-by-step (advanced)

```bash
cp .env.example .env
bash scripts/check.sh --profile=split-bridge
bash scripts/configure.sh --profile=split-bridge
bash scripts/harden-bitrix-security.sh
bash scripts/verify.sh --profile=split-bridge
```

Note: `scripts/setup-bitrix.sh` is kept as backward-compatible alias to `scripts/install.sh`.

## Bitrix dedicated agents (turnkey bootstrap)

Create/update dedicated Bitrix agents and apply role templates:

```bash
bash scripts/bootstrap-bitrix-agents.sh
```

Verify all agents are present and callable:

```bash
bash scripts/verify-bitrix-agents.sh
```

Apply Bitrix isolation policy (included automatically in `install.sh`):

```bash
bash scripts/harden-bitrix-security.sh
```

### What gets created
- `bitrix-router`
- `bitrix-support`
- `bitrix-sales`
- `bitrix-ops`

Role templates are copied to each agent workspace as `AGENTS.md` from `templates/agents/*.AGENTS.md`.
