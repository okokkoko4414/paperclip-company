# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

GEO119 Phase 0 toolchain — three Paperclip agent companies (A/B/C) controlled by a single Hermes beta profile via `mcp__paperclip_{a,b,c}__*` tool prefixes. The repo contains three company templates, V2 governance layer, and operational tooling (regression gates, config self-heal, keepalive plugin, patch files).

## Three Company Templates

| Template | Path | Agents | Type |
|---|---|---|---|
| A — Product Compass Consulting V2 | `product-compass-consulting-v2/` | 48 | Hub-and-spoke (CEO → 3 VP → 5 Directors → 39 Specialists) |
| B — Superpowers Dev Shop | `superpowers-v2/` | 4 | Linear pipeline (CEO → Lead Engineer → Code Reviewer → Release Engineer) |
| C — Agency Agents | `agency-agents-v2/agency-agents/` | 167 | Hub-and-spoke (CEO → 10 Division Leads → Specialists) |

Each contains: `COMPANY.md`, `.paperclip.yaml`, `agents/*/AGENTS.md`, `skills/`, `governance/`. C also has `teams/{10}/TEAM.md`.

## V2 Governance Layer

All three templates have a declarative governance layer injected into leadership AGENTS.md files. Each injection has 3 sections: **委派规则** (Delegation), **审批责任** (Review), **升级路径** (Escalation). Governance skills are in `skills/`:

- `delegate-with-tree` — parent/child Issue tree mirroring org hierarchy
- `acceptance-criteria` — 7-criteria deliverable checklist (5 P0 + 2 P1); Phase 0 is framework only (C8)
- `document-template` — mandatory frontmatter on every deliverable
- `vp-raise-convention` — escalate blocked work within 1 heartbeat cycle

A has 48 agents with governance injections in 9 management AGENTS.md. B is a linear pipeline, governance at CEO/Lead Engineer level. C has 11 leadership injections (CEO + 10 division leads) and 10 TEAM.md files with governance references.

## Operational Tooling

All paths below are relative to the repo root unless absolute.

### Regression Gate

```bash
bash phase0-regression-check.sh
```

Runs T1-T8 checks: MCP registration, tool prefixes, write isolation, backend fix presence, governance artifacts, delete_agent registration, environment cleanliness. Outputs HEALTHY or DEGRADED. Run after any component upgrade.

### Config Self-Heal

```bash
bash /media/ok2049/work/work/paperclip-mcp-v2/setup-mcp-config.sh
bash /media/ok2049/work/work/paperclip-mcp-v2/setup-mcp-config.sh --check-only  # dry run
```

Idempotent. Detects and fixes: `paperclip: 'null'` residue, missing `paperclip_a/b/c` instances, bad `env:` on paperclip_a, non-executable wrappers.

### Backend Patch

```bash
git apply patches/0001-fix-fallback-to-frontmatter-adapterType-in-safe-impo.patch
```

Re-applies the 1-line `asString(frontmatter.adapterType)` fallback in `company-portability.ts:2712` after Paperclip upstream `git pull`.

## Runtime Infrastructure (external to this repo)

### Paperclip Backend

- Running instance: `/home/ok2049/paperclip` (listen 127.0.0.1:3100)
- Source fork: `/media/ok2049/work/tools/paperclip-src` (NOT a git repo)
- Start: `cd /home/ok2049/paperclip && pnpm --filter @paperclipai/server exec tsx ../scripts/dev-runner.ts watch`
- The running instance IS a git repo. Source fork is NOT.
- API base: `http://127.0.0.1:3100/api`
- API key: `pcp_board_e65a40681143c73cda97a250ed4d21c8eb48a43427f089ab`
- DB: embedded PostgreSQL on port 54329, user `paperclip`, password `paperclip`
- Company deletion cascade is incomplete (upstream bug) — `cost_events` and `issue_thread_interactions` must be deleted before `heartbeat_runs` and `issues` respectively. See commit `e6bd9c0` in `/home/ok2049/paperclip`.

### paperclip-mcp Wrappers

- Path: `/media/ok2049/work/work/paperclip-mcp-v2/paperclip-mcp-v2-{a,b,c}/`
- Each `wrapper.sh` hardcodes PAPERCLIP_BASE_URL, PAPERCLIP_API_KEY, and PAPERCLIP_COMPANY_ID
- Wrappers are SELF-CONTAINED — no config `env:` block needed
- Version pinned: paperclip-mcp 0.4.0, FastMCP 3.4.3 (uv.lock generated)
- C6 constraint: three-layer directory structure (`paperclip-mcp-v2/paperclip-mcp-v2-{a,b,c}/`)

### Hermes Beta Config

- Config: `~/.hermes/profiles/beta/config.yaml`
- Edit via `hermes config set <key> <value>` (C1 constraint)
- `hermes config set` CANNOT delete keys or handle deeply nested paths (e.g. `mcp_servers.paperclip_b.env.PAPERCLIP_API_KEY` fails). For deletions, direct YAML edit is the only option.
- `hermes config set key null` sets the STRING "null", not YAML null.
- State snapshots at `~/.hermes/profiles/beta/state-snapshots/` can restore stale config — delete them if old config keeps reappearing.

### Keepalive Plugin

- Path: `~/.hermes/plugins/observability/geo119_keepalive/`
- `plugin.yaml` + `__init__.py` per Hermes plugin SDK
- Calls `discover_mcp_tools()` (mcp_tool.py:5202) on `on_session_start` hook
- Reconnects parked MCP servers and re-registers tools in-process

## Known Quirks

1. **`hermes config set` limitations**: Cannot unset keys. Deeply nested keys fail with `ValueError: Invalid environment variable name`. String "null" ≠ YAML null.
2. **teams=0 after import**: Paperclip import (`--include`) supports company, agents, projects, issues, tasks, skills — NOT teams. V2 template `teams/` directories are governance documentation, not Paperclip entities. Agent reporting lines (`reportsTo`) ARE preserved.
3. **Company deletion cascade**: Paperclip's API cascade is incomplete for companies with many FK-dependent tables. Direct DB cleanup may be needed. `SET session_replication_role = replica` disables FK checks for bulk cleanup.
4. **Import idempotency**: Always `list_companies` before `import_company_package` to avoid ghost companies. The `superpowers-v2/superpowers/` nested sub-package was removed to prevent duplicate agent imports.
5. **Wrapper UUIDs**: Must backfill real company UUIDs into `wrapper.sh` before Hermes restart. Placeholder strings are non-empty and will be sent as company_id.
6. **`tsx watch`**: The Paperclip dev runner's watch process can die silently. Check with `ps aux | grep "tsx watch"`.
7. **Regression check UUIDs**: `phase0-regression-check.sh` hardcodes company UUIDs. Update after re-import.

## Design & Planning Docs

- `docs/superpowers/specs/` — design specs (Phase 0 toolchain, remediation)
- `docs/superpowers/plans/` — implementation plans
- `docs/superpowers/GEO119-Phase0-整改结案报告.md` — remediation closing report
- `.superpowers/sdd/progress.md` — task ledger (for subagent-driven development)
- `patches/` — upgrade-recovery patch files

## External Docs References

- [Hermes Plugin SDK](https://hermes-agent.nousresearch.com/docs/developer-guide/plugins)
- [Paperclip Export/Import](https://docs.paperclip.ing/guides/power/export-import/)
- [Paperclip Org Structure](https://docs.paperclip.ing/guides/org/org-structure/)
- [Paperclip Team Catalog](https://docs.paperclip.ing/guides/org/team-catalog/)
