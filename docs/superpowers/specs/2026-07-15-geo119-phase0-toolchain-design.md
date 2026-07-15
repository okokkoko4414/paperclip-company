> 📌 审查轨迹归档（需求/设计/计划三文档的完整决策链、关键事实锚点、放行条件）：`/media/ok2049/work/work/AMM/GEO/GEO119-V2/Phase0-审查轨迹归档.md`

# GEO119 Phase 0 Toolchain Fix Design

**Date**: 2026-07-15
**Source**: Phase0-开发需求文档.md
**Status**: draft

## Summary

Fix three blocking issues preventing GEO119 Phase 0 completion: (P2) B/C company templates fail import with 403 due to adapter type defaulting to "process"; (P1) beta session can only control one Paperclip company, needs three; (P3) Agency Agents template lacks radial delegation chain and cross-company governance.

Execution order: P2 → (P1 ∥ P3 authoring) → P1 restart. P2 must resolve first because B/C must be imported to get real UUIDs. Afterwards, P1 config work and P3 template authoring can run in parallel — P3 writes template files only and does not depend on B/C UUIDs. P1's Hermes restart is the final gate.

---

## Problem 2: 403 Import Fix (FIRST)

### Root Cause

`company-portability.ts:2712` reads adapterType exclusively from `.paperclip.yaml` extension:

```typescript
adapterType: asString(extensionAdapter?.type) ?? "process",
```

The `adapterType: claude_local` in every agent's AGENTS.md frontmatter is never consulted during import. If an agent lacks an `adapter.type` entry in `.paperclip.yaml`, it defaults to `"process"`, which is forbidden in safe imports (`IMPORT_FORBIDDEN_ADAPTER_TYPES = Set(["process", "http"])`).

Superpowers (B) `.paperclip.yaml` has zero `adapter` entries. Agency Agents (C) `.paperclip.yaml` has one agent (`vp-engineering`) with only `inputs.env.GH_TOKEN`, no `adapter` block. All other agents in B (4 unique slugs) and C (166) fall through to `"process"` → 403.

The `adapterType: claude_local` already present in every agent's AGENTS.md frontmatter (all 167 in C, all 4 in B) is ignored.

### Fix: Backend (1 line) — the unified solution

**Target**: `/home/ok2049/paperclip/server/src/services/company-portability.ts`, line 2712.

```diff
- adapterType: asString(extensionAdapter?.type) ?? "process",
+ adapterType: asString(extensionAdapter?.type) ?? asString(frontmatter.adapterType) ?? "process",
```

`tsx watch` (pid 1747027) monitors `/home/ok2049/paperclip` and will auto-reload. No restart needed.

Mirror the change to `/media/ok2049/work/tools/paperclip-src` for source-of-truth consistency. The running directory (`/home/ok2049/paperclip`) and source fork (`/media/ok2049/work/tools/paperclip-src`) are separate copies; both must be updated to prevent regression on rebuild from source.

### Template changes: NOT required

With the backend fallback in place, B and C templates need no `.paperclip.yaml` changes — the import will read `adapterType: claude_local` from each agent's AGENTS.md frontmatter. This covers all 167 agents in C and all 4 unique agents in B in a single backend change.

### Verification

```bash
# After backend fix, import B and C
# Expected: both succeed, return real UUIDs, no 403
```

---

## Problem 1: Multi-MCP Configuration (SECOND)

### Current State

Per C4: config.yaml `mcp_servers` currently has only a single `paperclip` instance. No `paperclip_a`, `paperclip_b`, or `paperclip_c` entries exist.

```
mcp_servers:
  paperclip:
    command: /home/ok2049/.local/bin/paperclip-mcp-stdio
    enabled: true
    env:
      PAPERCLIP_API_KEY: pcp_board_...
      PAPERCLIP_BASE_URL: http://127.0.0.1:3100/api
```

Wrapper B and C have placeholder UUIDs (`<B-UUID-PENDING-IMPORT>`, `<C-UUID-PENDING-IMPORT>`).

### Target State

```
mcp_servers:
  paperclip_a:
    command: /media/ok2049/work/work/paperclip-mcp-v2/paperclip-mcp-v2-a/wrapper.sh
    enabled: true
    env:
      PAPERCLIP_API_KEY: pcp_board_e65a40681143c73cda97a250ed4d21c8eb48a43427f089ab
      PAPERCLIP_BASE_URL: http://127.0.0.1:3100/api
  paperclip_b:
    command: /media/ok2049/work/work/paperclip-mcp-v2/paperclip-mcp-v2-b/wrapper.sh
    enabled: true
    env:
      PAPERCLIP_API_KEY: pcp_board_e65a40681143c73cda97a250ed4d21c8eb48a43427f089ab
      PAPERCLIP_BASE_URL: http://127.0.0.1:3100/api
  paperclip_c:
    command: /media/ok2049/work/work/paperclip-mcp-v2/paperclip-mcp-v2-c/wrapper.sh
    enabled: true
    env:
      PAPERCLIP_API_KEY: pcp_board_e65a40681143c73cda97a250ed4d21c8eb48a43427f089ab
      PAPERCLIP_BASE_URL: http://127.0.0.1:3100/api
```

Old `paperclip` instance removed. Tool names become `mcp__paperclip_a__*`, `mcp__paperclip_b__*`, `mcp__paperclip_c__*`.

### Method

Use `hermes config set <key> <value>` per leaf key (C1 constraint). Three new instances × 4 set commands each (command, enabled, env.PAPERCLIP_API_KEY, env.PAPERCLIP_BASE_URL).

**COMPANY_ID backfill (CRITICAL — C7)**: After P2 imports B and C, wrapper B and C still have placeholder UUIDs (`<B-UUID-PENDING-IMPORT>`, `<C-UUID-PENDING-IMPORT>`). These MUST be replaced with real imported UUIDs before Hermes restarts. Per C7: a non-empty placeholder string will be sent as `PAPERCLIP_COMPANY_ID`, causing writes to target a non-existent or wrong company. Wrapper A already has the correct UUID hardcoded (`3d402864-4cb8-4334-b376-2670abfa05e1`).

Backfill steps:
1. Import B → get UUID-B
2. Import C → get UUID-C
3. Edit `wrapper.sh` in paperclip-mcp-v2-b and paperclip-mcp-v2-c: replace `<*-UUID-PENDING-IMPORT>` with real UUIDs
4. Verify all three wrappers have explicit, non-placeholder `PAPERCLIP_COMPANY_ID` values

**Pre-deletion checklist** (before removing old `paperclip` instance):
- Confirm no active Hermes session or automation script references `mcp__paperclip__*` tools
- Confirm a/b/c instances all have `enabled: true` and valid COMPANY_ID
- Old instance removal: `hermes config set mcp_servers.paperclip null` (or equivalent delete command)

### Verification (AC1 — write-op isolation)

`list_companies` returns all companies visible to the API key regardless of `PAPERCLIP_COMPANY_ID` — it cannot verify isolation. Use write-op verification instead:

1. Restart Hermes
2. Via `mcp__paperclip_a__*`: create a test issue → call `list_issues` / `get_issue` → confirm issue exists ONLY in company A (UUID `3d402864-4cb8-4334-b376-2670abfa05e1`)
3. Repeat for b/c (after import and UUID backfill): create test issue → confirm isolated to B/C respectively
4. Confirm old `mcp__paperclip__*` tools are gone
5. Three instances: zero cross-contamination

---

## Problem 3: Agency Agents Governance (PARALLEL with P1)

P3 authoring (writing template files) has no dependency on B/C UUIDs — it runs in parallel with P1 config work.

### Architecture

Agency Agents: 167 agents across 10 divisions, hub-and-spoke topology.

```
CEO
├── VP Engineering ──→ 23 engineering specialists + QA Director + XR Director
├── Creative Director ──→ 8 design specialists
├── CMO ──→ 34 marketing specialists
├── VP Product ──→ 11 product/project management specialists
├── VP Sales ──→ 8 sales specialists
├── VP Operations ──→ 6 operations specialists
├── Game Dev Director ──→ 20 game development specialists
├── Chief of Staff ──→ 32 specialized ops specialists
├── QA Director ──→ 8 QA specialists
└── XR Director ──→ 6 spatial computing specialists
```

Reference pattern: WWT hub-and-spoke (1 meta-orchestrator + 4 cluster coordinators + ~50 leaf agents). Agency Agents follows the same structural logic at larger scale.

### Changes

**4 new governance skills** (ported from Product Compass V2, adapted for hub-and-spoke):

| Skill | Purpose | Phase 0 Scope |
|---|---|---|
| `delegate-with-tree` | CEO/division lead splits tasks into parent/child Issue tree; coordinator classifies and delegates, never executes directly | Full |
| `acceptance-criteria` | 7-criteria deliverable checklist (5 P0 must-pass, 2 P1) | Framework only (C8) — keep structure, defer concrete criteria to Phase C per TEAM.md `context` |
| `document-template` | Mandatory frontmatter on every deliverable (author, reviewer, version, status) | Full |
| `vp-raise-convention` | Blocked >1 heartbeat cycle → escalate to division lead | Full |

Per C8: `acceptance-criteria` in Phase 0 only defines the 5 P0 + 2 P1 skeleton. Concrete acceptance items (SEO, Vietnam-market, department-specific standards) must NOT be hardcoded into the 10-division shared skill. They will be declared per department in TEAM.md at Phase C, driven by `context` parameters.

**11 leadership AGENTS.md injections** (CEO + 10 division leads) — declarative, not tutorial:

Each gets three injected sections in declarative form:
1. **Delegation** — statement of what this role delegates, to whom, and under what constraints. "You delegate X-type tasks to Y specialists. You do not execute directly."
2. **Review** — statement of review obligation. "Parent Issue stays open until all child Issues pass acceptance criteria. You are woken when all children complete."
3. **Escalation** — statement of escalation path. "Blocked >1 heartbeat → escalate via vp-raise-convention. Cross-division blockers → CEO."

Pattern is declarative (states rules), not procedural (does not teach how). Each section is 2-4 sentences.

**10 TEAM.md updates** — add references to `delegate-with-tree` and `acceptance-criteria` skills in each division's skill list.

**COMPANY.md expansion** — add three sections:
1. Delegation Tree Convention (hub-and-spoke specific: coordinator classifies, specialist executes)
2. Cross-Company Issue Coordination (beta creates issues across A/B/C without holding raw agent state; each company exposes a per-company dashboard summary)
3. Quality Gates (7-criteria acceptance checklist reference)

**Cross-company coordination pattern** (C9 — preserved, not simplified):

Each company exposes 1 project board + 1 routine aggregation. Beta consumes per-company dashboard summaries (active issues, blocked issues, completion rate) without pulling raw agent state. Beta creates cross-company coordination issues that reference deliverables across companies. The pattern is an isolation mechanism: beta's view is aggregated summaries, not raw per-agent state, preventing contamination across A/B/C.

This is NOT equivalent to "dashboard = read_issue." Each company's CEO is responsible for producing the summary artifact; beta reads the artifact, not the underlying issues directly.

### Verification

After import, create a test task at CEO level → verify it flows through division lead → reaches a specialist → specialist produces deliverable with frontmatter → division lead reviews against acceptance criteria → task closes without broken chain.

---

## Execution Order

```
P2 (Backend fix)
  ├─→ Import B → get UUID-B
  └─→ Import C → get UUID-C
        │
        ├─→ P1 (MCP config) ─────────────────┐
        │   ├─→ Backfill wrapper B/C UUIDs    │
        │   ├─→ Create paperclip_a + b + c    │
        │   ├─→ Pre-deletion checklist        │
        │   ├─→ Remove old paperclip instance │
        │   └─→ Restart Hermes ←──────────────┤ (gate)
        │                                      │
        └─→ P3 (Agency Agents authoring) ─────┘ (parallel)
              ├─→ Fresh backup agency-agents-v2
              ├─→ Port 4 governance skills (acceptance-criteria: framework only)
              ├─→ Inject 11 leadership AGENTS.md (declarative)
              ├─→ Update 10 TEAM.md
              ├─→ Expand COMPANY.md (delegation + cross-company + quality gates)
              └─→ Cross-company coordination pattern (C9)
```

## Constraints

- **C1**: config.yaml protected; use `hermes config set` exclusively
- **C2**: All deliverables in Chinese
- **C3**: Changes reversible; backups at `/tmp/*-v2.bak-*`
- **C4**: config.yaml `mcp_servers` starts from clean single `paperclip` instance; no `paperclip_a/b/c` pre-exist
- **C5**: A company already imported (UUID `3d402864-4cb8-4334-b376-2670abfa05e1`); B/C not yet imported
- **C6**: paperclip-mcp-v2 paths use three-layer directory structure (`paperclip-mcp-v2/paperclip-mcp-v2-{a,b,c}/`)
- **C7**: Data isolation is ONLY via wrapper `PAPERCLIP_COMPANY_ID`. a/b/c wrappers must all have explicit real UUIDs set before Hermes restart. Placeholder strings (`<*-UUID-PENDING-IMPORT>`) are non-empty and will be sent as company_id → writes land on wrong/non-existent company
- **C8**: `acceptance-criteria` in Phase 0 is framework only (5 P0 + 2 P1 structure). Concrete per-department criteria deferred to Phase C, declared in TEAM.md via `context` parameters. Do NOT hardcode PM-specific standards into 10-division shared skill
- **C9**: Cross-company coordination pattern is an isolation mechanism, not a convenience feature. Preserve: per-company project board + routine aggregation, beta consumes summary artifacts, does not pull raw agent state. Not simplifiable to "dashboard = read_issue"

## Risks

| Risk | Mitigation |
|---|---|
| Backend tsx watch doesn't pick up change | Verify file at `/home/ok2049/paperclip` (not source fork) is edited; check watch process targets correct directory |
| `hermes config set` fails on nested keys | Fallback: document exact sequence of set commands needed; test one instance first |
| B/C import reveals additional adapterType gaps beyond frontmatter fallback | Backend fallback covers all agents with frontmatter adapterType; template backup at `/tmp/superpowers-v2.bak-*` and `/tmp/agency-agents-v2.bak-*` |
| P3 modifies 11 leadership AGENTS.md in `agency-agents-v2/`; damage if format breaks | Create fresh backup before P3: `cp -a /media/ok2049/work/work/paperclip-company-v2/agency-agents-v2 /tmp/agency-agents-v2.bak-$(date +%s)` |
| Governance injection breaks existing agent behavior | All changes are additive (new sections appended, new skills added, no existing content removed); declarative style (2-4 sentences each) minimizes format risk |
| Running instance and source fork diverge | P2 backend change mirrored to both `/home/ok2049/paperclip` and `/media/ok2049/work/tools/paperclip-src` |
| Wrapper B/C placeholder UUIDs not backfilled before Hermes restart (C7) | Placeholder is non-empty string → sent as company_id → writes corrupt. Backfill step in P1 Method is blocking: verify all three wrappers have real UUIDs BEFORE restart |
| Old `paperclip` instance deleted while consumer still references `mcp__paperclip__*` prefix | Pre-deletion checklist: confirm no active session/script references old prefix; confirm a/b/c all enabled with valid COMPANY_ID before removal |
