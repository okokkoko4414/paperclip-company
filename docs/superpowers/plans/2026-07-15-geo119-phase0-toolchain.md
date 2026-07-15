> 📌 审查轨迹归档（需求/设计/计划三文档的完整决策链、关键事实锚点、放行条件）：`/media/ok2049/work/work/AMM/GEO/GEO119-V2/Phase0-审查轨迹归档.md`

# GEO119 Phase 0 Toolchain Fix Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix three blocking issues (403 import, multi-MCP config, Agency Agents governance) to close GEO119 Phase 0.

**Architecture:** Single-line backend fallback fixes all adapter validation. Hermes `mcp_servers` extended to 3 named instances with per-wrapper `PAPERCLIP_COMPANY_ID` isolation. Agency Agents template gets 4 governance skills + 11 leadership injections + cross-company coordination pattern, authored in parallel with config work.

**Tech Stack:** TypeScript (Paperclip backend), YAML (Hermes config), Markdown frontmatter (agent templates), Bash (wrapper scripts)

## Global Constraints

- **C1**: config.yaml protected; use `hermes config set` exclusively
- **C2**: All deliverables in Chinese
- **C3**: Changes reversible; backups at `/tmp/*-v2.bak-*`
- **C4**: config.yaml `mcp_servers` starts from clean single `paperclip` instance
- **C5**: A company already imported (UUID `3d402864-4cb8-4334-b376-2670abfa05e1`); B/C not yet imported
- **C6**: paperclip-mcp-v2 paths use three-layer directory structure (`paperclip-mcp-v2/paperclip-mcp-v2-{a,b,c}/`)
- **C7**: Data isolation ONLY via wrapper `PAPERCLIP_COMPANY_ID`; all 3 must have explicit real UUIDs before Hermes restart
- **C8**: `acceptance-criteria` in Phase 0 is framework only; no hardcoded PM standards
- **C9**: Cross-company coordination is isolation mechanism; per-company board + routine, beta consumes summaries

---

### Task 1: Backend fallback — running instance

**Files:**
- Modify: `/home/ok2049/paperclip/server/src/services/company-portability.ts:2712`

**Interfaces:**
- Produces: `adapterType` now falls back to `frontmatter.adapterType` when `.paperclip.yaml` lacks `adapter.type`

- [ ] **Step 1: Apply the 1-line fallback**

```typescript
// Line 2712 — BEFORE:
      adapterType: asString(extensionAdapter?.type) ?? "process",

// Line 2712 — AFTER:
      adapterType: asString(extensionAdapter?.type) ?? asString(frontmatter.adapterType) ?? "process",
```

- [ ] **Step 2: Verify tsx watch picks it up**

```bash
ps aux | grep "tsx watch" | grep -v grep
```

Expected: shows pid 1747027 watching `/home/ok2049/paperclip`. tsx watch auto-reloads on file change — no manual restart needed.

- [ ] **Step 3: Mirror to source fork**

Apply the identical change to `/media/ok2049/work/tools/paperclip-src/server/src/services/company-portability.ts:2712`

- [ ] **Step 4: Commit backend change**

`/home/ok2049/paperclip` is a git repo — commit for record-keeping. `/media/ok2049/work/tools/paperclip-src` is NOT a git repo — file mirror in Step 3 is sufficient; skip commit there. tsx watch auto-reload already applied the change to the running instance.

```bash
cd /home/ok2049/paperclip && git add server/src/services/company-portability.ts && git commit -m "fix: fallback to frontmatter adapterType in safe imports"
```

---

### Task 2: Import B and C templates

**Files:**
- No file changes — uses paperclip-mcp tool to import

**Interfaces:**
- Consumes: backend fallback from Task 1
- Produces: UUID-B, UUID-C (real company IDs)

- [ ] **Step 1: Import superpowers-v2 (B)**

Via `mcp__paperclip__import_company_package` with package path `/media/ok2049/work/work/paperclip-company-v2/superpowers-v2`

Expected: HTTP 200, returns company object with real UUID-B. Record it.

- [ ] **Step 2: Import agency-agents-v2 (C)**

Via `mcp__paperclip__import_company_package` with package path `/media/ok2049/work/work/paperclip-company-v2/agency-agents-v2`

Expected: HTTP 200, returns company object with real UUID-C. Record it.

- [ ] **Step 3: Verify no 403**

Both imports must succeed without `"Adapter type \"process\" is not allowed in safe imports"` error. If either fails with 403, re-check Task 1 diff was applied to running instance.

---

### Task 3: Backfill wrapper UUIDs (C7 — blocking)

**Files:**
- Modify: `/media/ok2049/work/work/paperclip-mcp-v2/paperclip-mcp-v2-b/wrapper.sh`
- Modify: `/media/ok2049/work/work/paperclip-mcp-v2/paperclip-mcp-v2-c/wrapper.sh`

**Interfaces:**
- Consumes: UUID-B, UUID-C from Task 2
- Produces: wrappers with real `PAPERCLIP_COMPANY_ID` values

- [ ] **Step 1: Backfill wrapper B**

Edit `/media/ok2049/work/work/paperclip-mcp-v2/paperclip-mcp-v2-b/wrapper.sh`: replace `<B-UUID-PENDING-IMPORT>` with UUID-B from Task 2.

```bash
# Line to edit — BEFORE:
      PAPERCLIP_COMPANY_ID="<B-UUID-PENDING-IMPORT>" \

# AFTER (use actual UUID-B):
      PAPERCLIP_COMPANY_ID="<UUID-B>" \
```

- [ ] **Step 2: Backfill wrapper C**

Edit `/media/ok2049/work/work/paperclip-mcp-v2/paperclip-mcp-v2-c/wrapper.sh`: replace `<C-UUID-PENDING-IMPORT>` with UUID-C from Task 2.

- [ ] **Step 3: Verify all three wrappers**

```bash
grep PAPERCLIP_COMPANY_ID /media/ok2049/work/work/paperclip-mcp-v2/paperclip-mcp-v2-{a,b,c}/wrapper.sh
```

Expected output: three lines, each with a real UUID (not `<*-PENDING>`). A must show `3d402864-4cb8-4334-b376-2670abfa05e1`.

---

### Task 4: Create paperclip_a/b/c in Hermes config

**Files:**
- Modify: `/home/ok2049/.hermes/profiles/beta/config.yaml` (via `hermes config set`)

**Interfaces:**
- Consumes: wrappers with real UUIDs from Task 3
- Produces: 3 MCP instances in config, old instance removed

- [ ] **Step 1: Create paperclip_a**

```bash
hermes config set mcp_servers.paperclip_a.command "/media/ok2049/work/work/paperclip-mcp-v2/paperclip-mcp-v2-a/wrapper.sh"
hermes config set mcp_servers.paperclip_a.enabled true
hermes config set mcp_servers.paperclip_a.env.PAPERCLIP_API_KEY "pcp_board_e65a40681143c73cda97a250ed4d21c8eb48a43427f089ab"
hermes config set mcp_servers.paperclip_a.env.PAPERCLIP_BASE_URL "http://127.0.0.1:3100/api"
```

- [ ] **Step 2: Create paperclip_b**

```bash
hermes config set mcp_servers.paperclip_b.command "/media/ok2049/work/work/paperclip-mcp-v2/paperclip-mcp-v2-b/wrapper.sh"
hermes config set mcp_servers.paperclip_b.enabled true
hermes config set mcp_servers.paperclip_b.env.PAPERCLIP_API_KEY "pcp_board_e65a40681143c73cda97a250ed4d21c8eb48a43427f089ab"
hermes config set mcp_servers.paperclip_b.env.PAPERCLIP_BASE_URL "http://127.0.0.1:3100/api"
```

- [ ] **Step 3: Create paperclip_c**

```bash
hermes config set mcp_servers.paperclip_c.command "/media/ok2049/work/work/paperclip-mcp-v2/paperclip-mcp-v2-c/wrapper.sh"
hermes config set mcp_servers.paperclip_c.enabled true
hermes config set mcp_servers.paperclip_c.env.PAPERCLIP_API_KEY "pcp_board_e65a40681143c73cda97a250ed4d21c8eb48a43427f089ab"
hermes config set mcp_servers.paperclip_c.env.PAPERCLIP_BASE_URL "http://127.0.0.1:3100/api"
```

- [ ] **Step 4: Pre-deletion checklist**

```bash
# 1. Confirm no active session references old mcp__paperclip__* prefix
# 2. Verify config now has paperclip_a, paperclip_b, paperclip_c (plus old paperclip)
grep -A3 "paperclip" /home/ok2049/.hermes/profiles/beta/config.yaml
```

- [ ] **Step 5: Implementation note — env deviation**

`hermes config set` does not support deeply nested keys (e.g., `mcp_servers.paperclip_b.env.PAPERCLIP_API_KEY`). The command fails with `ValueError: Invalid environment variable name`. As a result, paperclip_b and paperclip_c have no `env:` block in config — only `command:` and `enabled: true`.

This is functionally equivalent: all three wrappers hardcode `PAPERCLIP_BASE_URL`, `PAPERCLIP_API_KEY`, and `PAPERCLIP_COMPANY_ID` directly in the shell script, bypassing the need for config-level env injection. The config is cleaner (no redundant env declarations) and the wrappers are self-contained.

paperclip_a has a JSON-string `env:` block from an earlier attempt; it is harmless (wrapper values take precedence).

- [ ] **Step 6: Remove old paperclip instance**

```bash
hermes config set mcp_servers.paperclip null
```

- [ ] **Step 6: Verify config structure**

```bash
grep -A4 "paperclip_[abc]:" /home/ok2049/.hermes/profiles/beta/config.yaml
```

Expected: three instances (a/b/c), each with command + enabled + env lines. No old `paperclip:` entry.

---

### Task 5: Restart Hermes and verify isolation (AC1)

**Files:**
- No file changes

**Interfaces:**
- Consumes: Hermes config from Task 4

- [ ] **Step 1: Restart Hermes**

Restart the Hermes beta session so new `mcp__paperclip_a/b/c__*` tool prefixes load.

- [ ] **Step 2: Verify old tools gone**

Confirm no `mcp__paperclip__*` tools (without `_a/_b/_c` suffix) exist in the tool list.

- [ ] **Step 3: Write-op isolation — company A**

```
Via mcp__paperclip_a__create_issue:
  title: "AC1-isolation-test-a"
  assignee: ceo

Via mcp__paperclip_a__list_issues → confirm "AC1-isolation-test-a" appears in A's issue list
```

- [ ] **Step 4: Write-op isolation — company B**

```
Via mcp__paperclip_b__create_issue:
  title: "AC1-isolation-test-b"

Via mcp__paperclip_b__list_issues → confirm issue exists, only on B
Via mcp__paperclip_a__list_issues → confirm isolation test for B does NOT appear
```

- [ ] **Step 5: Write-op isolation — company C**

```
Via mcp__paperclip_c__create_issue:
  title: "AC1-isolation-test-c"

Via mcp__paperclip_c__list_issues → confirm issue exists, only on C
Via mcp__paperclip_a__list_issues → confirm only "AC1-isolation-test-a" visible
Via mcp__paperclip_b__list_issues → confirm only "AC1-isolation-test-b" visible
```

- [ ] **Step 6: Verify zero cross-contamination**

Three test issues, each visible only via its bound company's tools. AC1 passes.

---

### Task 6: Fresh backup of agency-agents-v2 (C3)

**Files:**
- Copy: `/media/ok2049/work/work/paperclip-company-v2/agency-agents-v2/` → `/tmp/agency-agents-v2.bak-$(date +%s)/`

- [ ] **Step 1: Create timestamped backup**

```bash
cp -a /media/ok2049/work/work/paperclip-company-v2/agency-agents-v2 /tmp/agency-agents-v2.bak-$(date +%s)
```

- [ ] **Step 2: Verify backup**

```bash
ls -d /tmp/agency-agents-v2.bak-* | tail -1
diff -rq /media/ok2049/work/work/paperclip-company-v2/agency-agents-v2 $(ls -d /tmp/agency-agents-v2.bak-* | tail -1)
```

Expected: no differences reported.

---

### Task 7: Create 4 governance skills

**Files:**
- Create: `/media/ok2049/work/work/paperclip-company-v2/agency-agents-v2/agency-agents/skills/delegate-with-tree/SKILL.md`
- Create: `/media/ok2049/work/work/paperclip-company-v2/agency-agents-v2/agency-agents/skills/acceptance-criteria/SKILL.md`
- Create: `/media/ok2049/work/work/paperclip-company-v2/agency-agents-v2/agency-agents/skills/document-template/SKILL.md`
- Create: `/media/ok2049/work/work/paperclip-company-v2/agency-agents-v2/agency-agents/skills/vp-raise-convention/SKILL.md`

- [ ] **Step 1: Create skills directory**

```bash
mkdir -p /media/ok2049/work/work/paperclip-company-v2/agency-agents-v2/agency-agents/skills/delegate-with-tree
mkdir -p /media/ok2049/work/work/paperclip-company-v2/agency-agents-v2/agency-agents/skills/acceptance-criteria
mkdir -p /media/ok2049/work/work/paperclip-company-v2/agency-agents-v2/agency-agents/skills/document-template
mkdir -p /media/ok2049/work/work/paperclip-company-v2/agency-agents-v2/agency-agents/skills/vp-raise-convention
```

- [ ] **Step 2: Create delegate-with-tree/SKILL.md**

```markdown
---
name: delegate-with-tree
description: 委派工作：构建映射组织层级的父子 Issue 树 — 管理者持有父 Issue，执行者持有子 Issue，子任务完成后自动回流至负责管理者进行审批。
key: geo119/delegate-with-tree
recommendedForRoles:
  - ceo
  - manager
  - director
tags:
  - delegation
  - issues
  - management
---

# 委派树

将跨人员任务拆分为映射组织层级的父子 Issue 树。

## 树结构

```
CEO（最高层级领导）
└── 部门负责人 ← 父 Issue 的 assignee = 执行者的直接管理者
    ├── 专员 A ← 子 Issue 的 assignee = 执行者
    ├── 专员 B ← 子 Issue 的 assignee = 执行者
    └── 专员 C ← 子 Issue 的 assignee = 执行者
```

## 规则

1. **父 Issue assignee = 执行者的直接管理者**（非 CEO，除非 CEO 即为直接管理者）。
2. **子 Issue assignee = 执行者** —— 承担具体工作的个人贡献者。
3. **父 Issue 状态必须为 `todo` 或 `in_progress`** —— `backlog` 状态不会触发子任务全部完成后的唤醒。
4. **所有子 Issue 必须为 `done` 或 `cancelled`** 之后，父 Issue assignee 才会被唤醒进行审批。单一子任务完成并不足够。
5. **父 Issue 在所有子任务完成且父 assignee 完成全部交付物审批之前，不得标记为 `done`**。

## 适用场景

- 多人员任务拆分
- 跨职能协调
- 任何需要管理层审批的交付物

## 不适用场景

- 单人员任务，可在一个心跳周期内完成
- 委派者即为执行者（无中间管理层）
```

- [ ] **Step 3: Create acceptance-criteria/SKILL.md** (framework only per C8)

```markdown
---
name: acceptance-criteria
description: 交付物验收标准框架 — 7 项可量化质量门（5 P0 + 2 P1），交付物标记为 done 前必须通过。具体验收项由各部门在 Phase C 通过 TEAM.md context 参数声明。
key: geo119/acceptance-criteria
recommendedForRoles:
  - ceo
  - manager
  - director
  - reviewer
tags:
  - quality
  - review
  - governance
---

# 验收标准 V2.4（框架）

所有交付物在标记为 done 之前必须通过可量化质量门。杜绝"感觉差不多"式审批。

## 7 项验收标准结构

| # | 标准 | 优先级 | 阈值 | Phase 0 状态 |
|---|------|--------|------|-------------|
| C1 | 事实一致性 | P0 | 0 错误 | 框架就绪，具体事实由部门 TEAM.md context 注入 |
| C2 | 范畴混淆为零 | P0 | 0 次 | 框架就绪 |
| C3 | 引用完整性 | P0 | 0 断裂引用 | 框架就绪 |
| C4 | 交付物完整性 | P0 | 全部文件存在且 >200 bytes | 框架就绪 |
| C5 | 语义质量 | P1 | h2≥3, ≥200 bytes, 无占位符 | 框架就绪 |
| C6 | 链接有效性 | P1 | 0 断裂链接 | 框架就绪 |
| C7 | 版本一致性 | P0 | 终版 ≥ 草稿行数 | 框架就绪 |

## 通过标准

- **P0：5/5 必须通过。** 任一 P0 失败 = 交付物驳回。
- **P1：2/2 必须通过。** P1 失败须以已知限制形式记录原因。

## Phase C 扩展

各部门在 TEAM.md 中通过 `context` 参数声明具体验收项（如 SEO 标准、越南市场要求、部门特定指标）。Phase 0 仅搭上述 7 项结构框架，**禁止硬编码**部门特定标准进本 skill。
```

- [ ] **Step 4: Create document-template/SKILL.md**

```markdown
---
name: document-template
description: 强制交付物 frontmatter 元数据 — 作者、审批者、版本、状态 — 确保每份文件可追溯至创建者及审批链。
key: geo119/document-template
recommendedForRoles:
  - all
tags:
  - documentation
  - metadata
  - governance
---

# 文档模板

每份交付物 `.md` 文件必须在文件顶部包含以下 YAML frontmatter。

## 必需 Frontmatter

```yaml
---
document_type: deliverable          # deliverable | plan | review | report
phase: A                            # 阶段标识
directory: 01-strategy              # 归属目录
filename: value-proposition.md      # 文件名
version: V1.0                       # 版本号
author_agent: VP Product Strategy   # 撰写者（Agent 名称）
reviewer_agent: Reviewer            # 审批者（Agent 名称）
status: draft                       # draft | in_review | approved
created_at: 2026-07-12T10:00:00Z    # ISO 8601 创建时间
updated_at: 2026-07-12T12:00:00Z    # ISO 8601 最后修改时间
issue_id: PHA-XXX                   # 关联 Issue ID
---
```

## 硬规则

1. **无 frontmatter = 驳回。** 缺少此元数据块的交付物不予接受。
2. **author_agent 必须匹配 Issue assignee。** 作者必须为子 Issue 所指派的人员。
3. **状态变更须有审批记录。** `draft` → `in_review` → `approved` 流转须附带审批者评论或交互记录。

## 状态流转

```
draft → in_review → approved
  ↑                    │
  └──── (rejected) ────┘
```

- `draft`：进行中，尚未提交审批。
- `in_review`：已提交，等待审批者反馈。
- `approved`：通过审批及验收标准。
```

- [ ] **Step 5: Create vp-raise-convention/SKILL.md**

```markdown
---
name: vp-raise-convention
description: 升级协议 — 部门负责人在受阻时如何升级，以及沉默不得超过一个心跳周期的硬规则。
key: geo119/vp-raise-convention
recommendedForRoles:
  - manager
  - director
tags:
  - escalation
  - management
---

# 升级约定

部门负责人受阻且无法在上级决策之前推进时，必须主动升级。沉默等待不可接受。

## 升级表

| 场景 | 升级方式 | 触发条件 |
|------|---------|---------|
| 子 Issue 执行者卡住 | 在父 Issue 上发起 `request_confirmation` 交互 | 执行者无法继续 |
| 部门负责人本人受阻 | 在 CEO 指派 Issue 上发起交互或评论 | 需要 CEO 决策 |
| 专员需要部门负责人介入 | @提及负责人或在父 Issue 上发起交互 | 需要管理判断 |

## 硬规则

1. **一个心跳周期内上报。** 受阻超过一个心跳周期，必须升级。
2. **不得对截止日期沉默等待。** 若判断无法按时完成，立即升级。
3. **CEO 须在下一个心跳周期内响应。** 收到升级后，CEO 在一个心跳周期内确认并响应。
```

- [ ] **Step 6: Verify all 4 skill files exist**

```bash
ls /media/ok2049/work/work/paperclip-company-v2/agency-agents-v2/agency-agents/skills/*/SKILL.md
```

Expected: 4 files listed.

---

### Task 8: Inject 11 leadership AGENTS.md (declarative)

**Files:**
- Modify 11 files under `/media/ok2049/work/work/paperclip-company-v2/agency-agents-v2/agency-agents/agents/`:
  - `ceo/AGENTS.md`
  - `vp-engineering/AGENTS.md`
  - `creative-director/AGENTS.md`
  - `cmo/AGENTS.md`
  - `vp-product/AGENTS.md`
  - `vp-sales/AGENTS.md`
  - `vp-operations/AGENTS.md`
  - `game-dev-director/AGENTS.md`
  - `chief-of-staff/AGENTS.md`
  - `qa-director/AGENTS.md`
  - `xr-director/AGENTS.md`

**Interfaces:**
- Consumes: governance skills from Task 7
- Produces: each leadership agent has appends `## 委派规则`, `## 审批责任`, `## 升级路径`

- [ ] **Step 1: Inject CEO**

Append to `/media/ok2049/work/work/paperclip-company-v2/agency-agents-v2/agency-agents/agents/ceo/AGENTS.md`:

```markdown

## 委派规则
你通过 hub-and-spoke 模型委派任务：分类意图后分发至对应部门负责人（VP 工程、创意总监、CMO、VP 产品、VP 销售、VP 运营、游戏开发总监、chief-of-staff）。加载 `delegate-with-tree` skill：创建父 Issue 指派给直接管理者，子 Issue 指派给执行专员。你不直接执行任务——你的职责是分类和分发。

## 审批责任
父 Issue 在所有子 Issue 完成且部门负责人通过 `acceptance-criteria` 验收后，方可标记为 done。你审批跨部门交付物的最终签核。

## 升级路径
部门负责人受阻 >1 心跳周期 → 通过 `vp-raise-convention` 向你升级。你须在下一个心跳周期内响应。跨部门阻塞 → 你直接协调或重新分配资源。
```

- [ ] **Step 2: Inject vp-engineering**

Append to `vp-engineering/AGENTS.md`:

```markdown

## 委派规则
你向 23 名工程专员 + QA 总监 + XR 总监委派技术任务。加载 `delegate-with-tree` skill：你持有父 Issue，专员持有子 Issue。你分类技术需求并匹配正确专员——你不亲自写代码。

## 审批责任
所有子 Issue 完成并通过 `acceptance-criteria` 后，你审批技术交付物。QA 总监独立审批质量——不向你汇报其审批结果。

## 升级路径
受阻 >1 心跳周期 → 通过 `vp-raise-convention` 向 CEO 升级。跨部门技术需求 → 与 VP 产品或创意总监协调。
```

- [ ] **Step 3: Inject creative-director**

Append to `creative-director/AGENTS.md`:

```markdown

## 委派规则
你向 8 名设计专员委派设计任务。加载 `delegate-with-tree` skill：你指派设计任务至品牌 Guardian、UI 设计师、UX 架构师等。你设定创意方向——你不亲自执行设计。

## 审批责任
设计交付物通过 `acceptance-criteria` 后你审批。品牌一致性和视觉质量由你最终签核。

## 升级路径
受阻 >1 心跳周期 → 通过 `vp-raise-convention` 向 CEO 升级。与工程的设计交接 → 与 VP 工程协调。
```

- [ ] **Step 4: Inject cmo**

Append to `cmo/AGENTS.md`:

```markdown

## 委派规则
你向 34 名营销与付费媒体专员委派营销任务。加载 `delegate-with-tree` skill：你按渠道（SEO、社交媒体、付费广告、内容营销、区域市场）分类并指派至对应专员。你制定营销策略——你不亲自执行投放。

## 审批责任
营销交付物通过 `acceptance-criteria` 后你审批。campaign 效果和品牌安全由你最终签核。

## 升级路径
受阻 >1 心跳周期 → 通过 `vp-raise-convention` 向 CEO 升级。跨部门 campaign → 与 VP 产品或创意总监协调。
```

- [ ] **Step 5: Inject vp-product**

Append to `vp-product/AGENTS.md`:

```markdown

## 委派规则
你向 11 名产品与项目管理专员委派产品任务。加载 `delegate-with-tree` skill：你按职能（产品策略、sprint 规划、项目交付）分类并指派。你设定产品路线图——你不亲自管理每个 sprint。

## 审批责任
产品交付物通过 `acceptance-criteria` 后你审批。产品市场匹配和路线图一致性由你最终签核。

## 升级路径
受阻 >1 心跳周期 → 通过 `vp-raise-convention` 向 CEO 升级。跨部门产品需求 → 与 VP 工程或 CMO 协调。
```

- [ ] **Step 6: Inject vp-sales**

Append to `vp-sales/AGENTS.md`:

```markdown

## 委派规则
你向 8 名销售专员委派销售任务。加载 `delegate-with-tree` skill：你按职能（外拓策略、deal 管理、pipeline 分析、销售工程）分类并指派。你管理销售 pipeline——你不亲自关闭每个 deal。

## 审批责任
销售交付物（proposal、deal 策略、pipeline 报告）通过 `acceptance-criteria` 后你审批。

## 升级路径
受阻 >1 心跳周期 → 通过 `vp-raise-convention` 向 CEO 升级。涉及产品能力的销售需求 → 与 VP 产品协调。
```

- [ ] **Step 7: Inject vp-operations**

Append to `vp-operations/AGENTS.md`:

```markdown

## 委派规则
你向 6 名运营与支持专员委派运营任务。加载 `delegate-with-tree` skill：你按职能（分析、财务、法务合规、基础设施、客户支持）分类并指派。

## 审批责任
运营交付物通过 `acceptance-criteria` 后你审批。

## 升级路径
受阻 >1 心跳周期 → 通过 `vp-raise-convention` 向 CEO 升级。
```

- [ ] **Step 8: Inject game-dev-director**

Append to `game-dev-director/AGENTS.md`:

```markdown

## 委派规则
你向 20 名游戏开发专员委派游戏开发任务。加载 `delegate-with-tree` skill：你按引擎（Unity、Unreal、Godot、Roblox、Blender）和学科（gameplay、multiplayer、shader、audio、level design）分类并指派。你设定技术方向——你不亲自开发。

## 审批责任
游戏开发交付物通过 `acceptance-criteria` 后你审批。

## 升级路径
受阻 >1 心跳周期 → 通过 `vp-raise-convention` 向 CEO 升级。
```

- [ ] **Step 9: Inject chief-of-staff**

Append to `chief-of-staff/AGENTS.md`:

```markdown

## 委派规则
你向 32 名专业运营与学术专员委派跨领域任务。加载 `delegate-with-tree` skill：你按职能（合规、自动化、知识管理、文档生成、开发者关系、招聘、学术研究）分类并指派。你的团队为其他部门提供增援能力——你负责跨部门路由。

## 审批责任
专业运营交付物通过 `acceptance-criteria` 后你审批。

## 升级路径
受阻 >1 心跳周期 → 通过 `vp-raise-convention` 向 CEO 升级。
```

- [ ] **Step 10: Inject qa-director**

Append to `qa-director/AGENTS.md`:

```markdown

## 委派规则
你向 8 名 QA 专员委派质量保证任务。加载 `delegate-with-tree` skill：你按测试类型（API 测试、性能、无障碍、证据收集）分类并指派。你独立于被审批团队运作。

## 审批责任
QA 报告和测试交付物通过 `acceptance-criteria` 后你审批。QA 结果独立于工程部门——你向 VP 工程汇报行政关系，但在质量判断上保持独立。

## 升级路径
受阻 >1 心跳周期 → 通过 `vp-raise-convention` 向 VP 工程升级。质量问题 → 也可直接向 CEO 汇报。
```

- [ ] **Step 11: Inject xr-director**

Append to `xr-director/AGENTS.md`:

```markdown

## 委派规则
你向 6 名空间计算与 XR 专员委派 XR 任务。加载 `delegate-with-tree` skill：你按平台（visionOS、WebXR、Metal 渲染、空间界面设计）分类并指派。你设定 XR 技术方向——你不亲自开发。

## 审批责任
XR 交付物通过 `acceptance-criteria` 后你审批。

## 升级路径
受阻 >1 心跳周期 → 通过 `vp-raise-convention` 向 VP 工程升级。
```

- [ ] **Step 12: Verify injections**

```bash
for agent in ceo vp-engineering creative-director cmo vp-product vp-sales vp-operations game-dev-director chief-of-staff qa-director xr-director; do
  echo "=== $agent ==="
  grep -c "委派规则\|审批责任\|升级路径" /media/ok2049/work/work/paperclip-company-v2/agency-agents-v2/agency-agents/agents/$agent/AGENTS.md
done
```

Expected: each agent shows `3` (three injected sections). If any shows `0`, check file path (slug may differ from directory name).

---

### Task 9: Update 10 TEAM.md files

**Files:**
- Modify 10 files under `/media/ok2049/work/work/paperclip-company-v2/agency-agents-v2/agency-agents/teams/`:
  - `design/TEAM.md`, `engineering/TEAM.md`, `game-development/TEAM.md`, `marketing/TEAM.md`, `operations/TEAM.md`, `product/TEAM.md`, `quality-assurance/TEAM.md`, `sales/TEAM.md`, `spatial-computing/TEAM.md`, `specialized-ops/TEAM.md`

- [ ] **Step 1: Append governance skill references to each TEAM.md**

For each of the 10 TEAM.md files, append the following block at the end of the file (replacing `{DIVISION_NAME}` and `{division-slug}`):

```markdown

## Governance

This division's lead uses `delegate-with-tree` to split multi-person work into parent/child Issue trees. All deliverables must pass `acceptance-criteria` (7 criteria: 5 P0 + 2 P1) before being marked done. Blocked work >1 heartbeat must escalate via `vp-raise-convention`.

Concrete acceptance criteria for this division will be declared in Phase C through `context` parameters in this TEAM.md.
```

- [ ] **Step 2: Verify all 10 TEAM.md updated**

```bash
grep -l "delegate-with-tree" /media/ok2049/work/work/paperclip-company-v2/agency-agents-v2/agency-agents/teams/*/TEAM.md | wc -l
```

Expected: `10`

---

### Task 10: Expand COMPANY.md

**Files:**
- Modify: `/media/ok2049/work/work/paperclip-company-v2/agency-agents-v2/agency-agents/COMPANY.md`

- [ ] **Step 1: Append three governance sections to COMPANY.md**

Append after the leadership table (after the "Generated from agency-agents..." line):

```markdown

## Delegation Tree Convention

Agency Agents operates on a hub-and-spoke model with the following hard rules:

1. **Coordinator classifies, specialist executes.** Division leads (CEO + 10 directors/VPs) classify incoming tasks and delegate to the appropriate specialist. Division leads do not execute tasks directly — their role is classification, routing, and review.
2. **Parent Issue assignee = direct manager.** CEO delegates to division leads; division leads delegate to specialists. The Issue tree mirrors the org chart.
3. **Child Issue assignee = executor.** Each specialist owns their child Issue and produces the deliverable.
4. **All children done → parent woken.** Parent Issue assignee is woken for review only when all child Issues are `done` or `cancelled`.
5. **Parent not done until reviewed.** Parent Issue stays open until the parent assignee has reviewed all deliverables against acceptance criteria.

## Cross-Company Issue Coordination

GEO119 operates three independent Paperclip companies (A: Product Compass, B: Superpowers, C: Agency Agents) controlled by a single Hermes beta session via `mcp__paperclip_{a,b,c}__*` tool prefixes.

**Isolation mechanism** (C9):
- Each company exposes 1 project board + 1 routine aggregation
- Beta consumes per-company dashboard summaries (active issues, blocked issues, completion rate) without pulling raw agent state
- Beta creates cross-company coordination issues that reference deliverables across companies
- Each company's CEO is responsible for producing the summary artifact; beta reads the artifact, not the underlying issues directly

This is NOT equivalent to `dashboard = read_issue`. The summary artifact is a CEO-produced deliverable, not a raw API response.

## Quality Gates

All deliverables must pass the 7-criteria acceptance checklist (5 P0 must-pass + 2 P1 must-pass) defined in the `acceptance-criteria` skill. Every deliverable must include the frontmatter template defined in the `document-template` skill. Blocked work >1 heartbeat cycle must escalate per `vp-raise-convention`.
```

- [ ] **Step 2: Verify COMPANY.md**

```bash
grep -c "Delegation Tree Convention\|Cross-Company Issue Coordination\|Quality Gates" /media/ok2049/work/work/paperclip-company-v2/agency-agents-v2/agency-agents/COMPANY.md
```

Expected: `3`

---

### Task 11: Final validation

**Files:**
- No file changes

- [ ] **Step 1: Verify all Phase 0 deliverables exist**

```bash
# Backend fix
grep "frontmatter.adapterType" /home/ok2049/paperclip/server/src/services/company-portability.ts
grep "frontmatter.adapterType" /media/ok2049/work/tools/paperclip-src/server/src/services/company-portability.ts

# Wrappers backfilled
grep -L "PENDING" /media/ok2049/work/work/paperclip-mcp-v2/paperclip-mcp-v2-{a,b,c}/wrapper.sh

# Config
grep "paperclip_a\|paperclip_b\|paperclip_c" /home/ok2049/.hermes/profiles/beta/config.yaml

# Skills
ls /media/ok2049/work/work/paperclip-company-v2/agency-agents-v2/agency-agents/skills/*/SKILL.md | wc -l  # expected: 4

# Leadership injections
for agent in ceo vp-engineering creative-director cmo vp-product vp-sales vp-operations game-dev-director chief-of-staff qa-director xr-director; do
  count=$(grep -c "委派规则\|审批责任\|升级路径" /media/ok2049/work/work/paperclip-company-v2/agency-agents-v2/agency-agents/agents/$agent/AGENTS.md 2>/dev/null || echo 0)
  [ "$count" != "3" ] && echo "MISSING: $agent ($count/3)"
done

# TEAM.md
grep -l "delegate-with-tree" /media/ok2049/work/work/paperclip-company-v2/agency-agents-v2/agency-agents/teams/*/TEAM.md | wc -l  # expected: 10

# COMPANY.md
grep -c "Delegation Tree Convention\|Cross-Company Issue Coordination\|Quality Gates" /media/ok2049/work/work/paperclip-company-v2/agency-agents-v2/agency-agents/COMPANY.md  # expected: 3
```

- [ ] **Step 2: Run AC2 (import test)**

Confirm B and C import successfully (Task 2 verification re-check).

- [ ] **Step 3: Run AC3 (delegation chain test)**

After C company import (Task 2), use `mcp__paperclip_c__*` tools to create a test task at CEO level → verify it flows through division lead → reaches a specialist. The chain must not break.

- [ ] **Step 4: Commit all template changes**

```bash
cd /media/ok2049/work/work/paperclip-company-v2
git add agency-agents-v2/
git commit -m "feat: add V2 governance layer to Agency Agents (Phase 0)

- 4 governance skills: delegate-with-tree, acceptance-criteria (framework), document-template, vp-raise-convention
- 11 leadership injections (declarative: delegation, review, escalation)
- 10 TEAM.md governance references
- COMPANY.md expanded: delegation tree convention, cross-company coordination (C9), quality gates"
```
