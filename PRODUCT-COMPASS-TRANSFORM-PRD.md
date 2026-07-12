# Product Compass 改造需求文档

**版本**: V1.0  
**日期**: 2026-07-12  
**作者**: 阿尔法（峰哥首席参谋）  
**项目**: AMM-OPC Phase A 产出物治理改造  
**目标仓库**: https://github.com/okokkoko4414/（私有，仅自用）

---

## 一、需求背景

### 1.1 问题描述

我们使用 Paperclip 官方模板 `product-compass-consulting` 创建了 GEO119 项目公司，执行 Phase A（产品战略咨询）后产出 96 个 Markdown 文档，发现以下致命问题：

| 问题 | 具体表现 | 后果 |
|------|---------|------|
| **委派链路断层** | 模板只定义了"有哪些人"（48 Agents, 8 Teams），没有定义"活怎么分"。CEO 随机拆分任务，VP 不知道自己该收什么活，Specialist 做完没人收 | 无责任归属，无人对质量负责 |
| **无审查门禁** | 没有可量化的验收标准，VP 审查靠"感觉" | SEO 概念错误（将产品自身功能称为"SEO"）遍布 6 个目录、88 个 HIGH 问题，无人拦截 |
| **无文档模板** | 产出物没有 author/version/frontmatter 元数据 | 96 个文件不知道哪个是哪个 Agent 写的、哪个被审过、哪个是最终版 |
| **版本失控** | 00-plans/ 目录产生 61 个文件，包含大量 `-root`, `-root2`, `-from-brand` 后缀中间稿 | 同一文档在 00-plans/ 和 01-strategy/ 各有一份，无法区分最终版 |
| **异常不上报** | VP 卡住时不知道如何上报 CEO | CEO 不知道项目停滞，等 deadline 才发现什么都没做 |

### 1.2 根因分析

**Product Compass 模板是官方样板间**，展示"一家 PM 咨询公司可以有哪些团队、角色、技能"，但只管"摆人"，不管"流转"：
- ✅ 48 Agents 定义完整（谁管谁）
- ✅ 65 Skills 预置齐全（每人会什么）
- ✅ 8 Teams 结构清晰（团队归属）
- ❌ **0 个预置 Issue**（没有任务分解规则）
- ❌ **无委派链路约定**（Issue 树与 org 树割裂）
- ❌ **无质量门禁**（无可量化验收标准）
- ❌ **无文档模板**（无 frontmatter 元数据要求）

**一句话总结**：模板提供了组织架构的骨架，但缺少任务流转的神经系统。

### 1.3 官方模板参考

本项目基于以下 4 个 Paperclip 官方公司模板：

| 模板 | GitHub 路径 | 用途 | 可借鉴点 |
|------|-----------|------|---------|
| **Product Compass Consulting** | [paperclipai/companies#product-compass-consulting](https://github.com/paperclipai/companies#product-compass-consulting) | 全服务 PM 咨询公司（48 agents, 65 skills） | 组织架构、团队结构、skill 体系 |
| **Gstack** | [paperclipai/companies#gstack](https://github.com/paperclipai/companies#gstack) | 工程开发工具链 | 工程流程、代码审查、CI/CD |
| **Superpowers Dev Shop** | [paperclipai/companies#superpowers-dev-shop](https://github.com/paperclipai/companies#superpowers-dev-shop) | 结构化开发流程 | spec → plan → TDD → verify 工作流 |
| **Agency Agents** | [paperclipai/companies#agency-agents](https://github.com/paperclipai/companies#agency-agents) | 代理机构模式 | 客户项目管理、交付物管理 |

**开发资料**：
- [companies.sh](https://companies.sh) — Paperclip 公司创建平台
- [paperclipai/companies-tool](https://github.com/paperclipai/companies-tool) — 公司创建工具 CLI

---

## 二、改造目标

将 Product Compass 从"静态组织模板"改造为"可执行的智能交付管线"，实现：

1. **可追溯**：每个文档都有明确的 author、reviewer、version、status
2. **可验证**：交付物必须通过可量化的验收标准（V2.1）
3. **可问责**：委派链路完整，每个层级知道收什么活、交什么活
4. **可控**：版本受控，无中间稿污染，异常及时上报

---

## 三、改造范围

### 3.1 新增文件/目录

| 文件/目录 | 类型 | 说明 |
|-----------|------|------|
| `skills/delegate-with-tree/SKILL.md` | Skill | 委派链路规则（详见 4.1） |
| `skills/acceptance-criteria/SKILL.md` | Skill | V2.1 验收标准（详见 4.2） |
| `skills/document-template/SKILL.md` | Skill | 文档 frontmatter 模板（详见 4.3） |
| `skills/vp-raise-convention/SKILL.md` | Skill | 异常上报约定（详见 4.4） |
| `agents/ceo/AGENTS.md` | Agent 配置 | 注入委派约定 + 审查要求 |
| `agents/vp-*/AGENTS.md` | Agent 配置 | 注入委派约定 + 审查要求 |
| `agents/director-*/AGENTS.md` | Agent 配置 | 注入委派约定 + 审查要求 |
| `governance/ACCEPTANCE-CRITERIA-V2.1.md` | 验收标准 | 7 条可量化标准 |
| `governance/acceptance_check.sh` | 脚本 | 一键验收脚本 |

### 3.2 修改现有文件

| 文件 | 修改内容 |
|------|---------|
| `COMPANY.md` | 增加"如何工作"章节，说明委派链路、审查流程、交付标准 |
| `agents/ceo/AGENTS.md` | 增加 delegation-tree-convention、acceptance-gate、document-template 要求 |
| `agents/vp-*/AGENTS.md` | 增加 delegation-tree-convention、acceptance-gate、vp-raise-convention 要求 |
| `agents/director-*/AGENTS.md` | 增加 delegation-tree-convention、acceptance-gate、vp-raise-convention 要求 |
| `teams/*/TEAM.md` | 增加 includes 指向新 skill |

### 3.3 不修改的文件

- 所有 Specialist/Analyst 级别的 AGENTS.md（执行层不需要委派约定）
- 所有 skill 文件（不修改已有 skill 内容）
- `skills/` 下原有的 65 个 skill

---

## 四、详细需求

### 4.1 delegate-with-tree Skill

**目的**：确保任务委派时 Issue 树与 org 树映射，完成时自动回流至管理者审查。

**核心规则**（必须完整实现）：

```
CEO（顶层领导）
└── VP/Director ← parent issue assignee = 该层管理者（不是 CEO！）
    ├── Specialist A ← child issue assignee = 执行者
    ├── Specialist B ← child issue assignee = 执行者
    └── Specialist C ← child issue assignee = 执行者

完成回流：所有 child done/cancelled → 自动唤醒 parent assignee → VP 审查
```

**关键约束**：
1. **父 issue assignee = 直接管理者**（不是 CEO，除非 CEO 是直接管理者）
2. **子 issue assignee = 执行者**
3. **父 issue 必须保持 todo/in_progress 状态**（backlog 不会唤醒）
4. **全部子 issue 完成才唤醒**（单个完成不唤醒）
5. **父 issue 在子 issue 完成并审查前不得标记 done**

**when to use**：
- 多人员任务拆分
- 跨职能部门协调
- 需要管理层审查的交付物

**when not to use**：
- 单人可快速完成的小任务
- assigner 与 executor 之间无管理层级

**完整 SKILL.md 内容**（参考已验证版本）：

```yaml
---
name: delegate-with-tree
description: Delegate work by building a parent/child issue tree that mirrors the org hierarchy — managers own parent issues, individual contributors own child issues — so completed child work automatically flows back up to the responsible manager for review.
key: okokkoko4414/delegate-with-tree
recommendedForRoles:
  - ceo
  - manager
  - director
  - product
tags:
  - delegation
  - planning
  - issues
  - management
---
```

（正文内容见上文完整的 delegate-with-tree SKILL.md）

### 4.2 验收标准 Skill（V2.1）

**目的**：为所有交付物提供可量化的质量门禁，审查不再靠"感觉"。

**7 条标准**：

| 标准 | 优先级 | 阈值 | 验证方式 |
|------|--------|------|---------|
| C1: SEO 不当描述归零 | P0 | 0 个 HIGH | grep 模式匹配 |
| C2: GEO/SEO 混用归零 | P0 | 0 处 | grep `SEO/GEO` |
| C3: 核心事实一致性 | P0 | 0 处 | 语种=119, 产品名=GEO119, 定位=AI搜索优化, 模式=预付费, V1市场=越南 |
| C4: 交付物完整性 | P0 | 全部存在且>200bytes | 文件存在性+大小检查 |
| C5: 语义质量 | P1 | h2≥3, ≥200bytes, 无占位符 | 结构检查 |
| C6: 链接有效性 | P1 | 0 个断链 | 相对路径目标文件存在性 |
| C7: 版本一致性 | P0 | 正式版不低于草稿行数 | 01-strategy ≥ 00-plans |

**验收脚本**：可一键执行的 bash 脚本，输出 PASS/FAIL。

**通过标准**：
- P0: 5/5 全部通过（任一 P0 未通过 = 交付物不合格）
- P1: 2/2 通过（未通过需说明原因并记录为已知限制）

**完整 V2.1 内容**（参考已验证版本）：
- 文件路径：`governance/DELIVERABLE-ACCEPTANCE-CRITERIA-V2.1.md`
- 包含完整的标准定义、验证命令、判定规则、一键验收脚本

### 4.3 文档模板 Skill（Frontmatter 强制元数据）

**目的**：每个交付物必须有可追溯的元数据。

**强制 frontmatter**（所有 `.md` 交付物文件头部）：

```yaml
---
document_type: deliverable          # deliverable | plan | review | report
phase: A                            # Phase 标识
directory: 01-strategy              # 归属目录
filename: value-proposition.md      # 文件名
version: V1.0                       # 版本号
author_agent: VP 产品战略            # 谁写的（Agent 名称）
reviewer_agent: Reviewer            # 谁审的（Agent 名称）
status: draft | in_review | approved  # 状态
created_at: 2026-07-12T10:00:00Z    # 创建时间
updated_at: 2026-07-12T12:00:00Z    # 修改时间
issue_id: PHA-XXX                   # 关联的 Issue
---
```

**硬规则**：
- **没有 frontmatter = 拒绝接收**
- **author_agent 必须与 Issue assignee 一致**
- **status 变更必须有审查记录**

### 4.4 VP Raise 约定 Skill

**目的**：当 VP 卡住或需要上级决策时，主动上报 CEO 的约定。

**约定内容**：

| 场景 | 上报方式 | 触发条件 |
|------|---------|---------|
| 子 issue 执行者卡住 | 在 parent issue 开 `request_confirmation` interaction | 执行者无法继续 |
| VP 自己卡住 | 在 CEO 分配的 parent issue 开 interaction 或 comment | 需要 CEO 决策 |
| Specialist 需 VP 介入 | 在 parent issue @mention VP 或开 interaction | 需要管理层判断 |
| 预算告警 | VP 在 parent issue comment 说明 | 预算接近上限 |

**硬规则**：
- 卡住超过 1 个 heartbeat 周期必须上报
- 不得静默等待 deadline
- CEO 收到上报后必须在下一个 heartbeat 响应

### 4.5 AGENTS.md 注入内容

**CEO AGENTS.md 新增段落**：

```markdown
## Delegation Rules
When you receive a client challenge:
1. Load the `delegate-with-tree` skill before splitting work
2. Create a parent issue assigned to the DIRECT manager of the executors (NOT yourself unless you are the direct manager)
3. Create child issues assigned to individual contributors
4. Each child must have a clear deliverable and reference the acceptance criteria skill
5. Keep parent issues in `todo` or `in_progress` (never `backlog`)

## Quality Gates
Before marking any parent issue as done:
1. Verify all child issues are done
2. Run the acceptance criteria validation script (load `acceptance-criteria` skill)
3. Review each deliverable against the criteria
4. Only then mark the parent issue done

## Document Standards
All deliverables must include the frontmatter template (load `document-template` skill):
- author_agent must match the child issue assignee
- reviewer_agent must be set after your review
- status must progress: draft → in_review → approved
```

**VP/Director AGENTS.md 新增段落**：

```markdown
## Delegation Rules
When you receive work from above:
1. Load the `delegate-with-tree` skill
2. If the work can be done by one person in a single heartbeat, do it directly
3. If it needs splitting, create child issues assigned to individual contributors
4. Keep your parent issue in `todo` or `in_progress`

## Review Responsibility
You are responsible for reviewing all child issues under your parent:
1. When all children are done, you will be automatically woken
2. Run the acceptance criteria validation script (load `acceptance-criteria` skill)
3. Review each deliverable
4. If it passes, mark your parent issue done
5. If it fails, send it back with specific feedback

## Raise Convention
If you are blocked or need a decision:
1. Open a `request_confirmation` interaction on your parent issue
2. Mention the specific blocker
3. Do not wait silently — report within 1 heartbeat cycle
```

### 4.6 COMPANY.md 修改

**原内容**（第 18-31 行）：
```markdown
## How the company works

The CEO receives client challenges and routes them to the right department.
```

**修改为**：
```markdown
## How the company works

The CEO receives client challenges and routes them to the right department using the **delegate-with-tree** skill. Work flows through the organization following the product lifecycle AND the management hierarchy:

1. **Discovery** — Brainstorm ideas, map assumptions, design experiments, conduct user research
2. **Strategy** — Define vision, evaluate business models, analyze competition, set pricing
3. **Execution** — Write PRDs, set OKRs, plan sprints, create stories, manage releases
4. **Market Research** — Build personas, map journeys, size markets, analyze sentiment
5. **Data Analytics** — Write SQL queries, analyze A/B tests, study cohort retention
6. **Go-to-Market** — Plan launches, identify beachheads, design growth loops
7. **Marketing & Growth** — Generate campaigns, craft positioning, define North Star metrics
8. **PM Toolkit** — Review resumes, draft legal docs, proofread content

### Delegation Tree Convention
Every multi-person task follows a parent/child issue tree:
- The **parent issue assignee** is the manager responsible for that subtree
- The **child issue assignees** are the individual contributors executing the work
- When all children are done, the parent assignee is automatically woken to review
- See the `delegate-with-tree` skill for detailed rules

### Quality Gates
All deliverables must pass the acceptance criteria before being marked done:
- 5 P0 standards (must all pass) + 2 P1 standards
- Validation is automated via bash scripts
- See the `acceptance-criteria` skill and `governance/` directory

### Document Standards
Every deliverable must include frontmatter with author, reviewer, version, and status.
See the `document-template` skill for the required format.
```

### 4.7 TEAM.md 修改

**原格式**：
```yaml
---
name: Product Strategy
slug: product-strategy
manager: ../../agents/vp-strategy/AGENTS.md
includes:
  - ../../agents/business-model-analyst/AGENTS.md
  - ...
---
```

**修改为**（增加 skill 引用）：
```yaml
---
name: Product Strategy
slug: product-strategy
manager: ../../agents/vp-strategy/AGENTS.md
includes:
  - ../../agents/business-model-analyst/AGENTS.md
  - ../../agents/competitive-intel-analyst/AGENTS.md
  - ../../agents/pricing-strategist/AGENTS.md
  - ../../agents/vision-strategist/AGENTS.md
  - ../../skills/delegate-with-tree/SKILL.md
  - ../../skills/acceptance-criteria/SKILL.md
  - ../../skills/document-template/SKILL.md
---
```

---

## 五、开发约束

### 5.1 开发工具

- **Claude Code CLI** + **Superpowers workflow**（spec → plan → TDD → verify）
- **Superpowers brainstorming** 用于需求澄清
- 禁止 ad-hoc 直接写代码

### 5.2 文件结构

```
product-compass-consulting/
├── COMPANY.md                          # 修改
├── agents/
│   ├── ceo/AGENTS.md                   # 修改（注入委派约定）
│   ├── vp-discovery/AGENTS.md          # 修改
│   ├── vp-execution/AGENTS.md          # 修改
│   ├── vp-strategy/AGENTS.md           # 修改
│   ├── director-data-analytics/AGENTS.md   # 修改
│   ├── director-gtm/AGENTS.md          # 修改
│   ├── director-marketing/AGENTS.md    # 修改
│   ├── director-market-research/AGENTS.md  # 修改
│   ├── director-toolkit/AGENTS.md      # 修改
│   └── ...（Specialist/Analyst 不修改）
├── teams/
│   ├── product-discovery/TEAM.md       # 修改（增加 skill 引用）
│   ├── product-execution/TEAM.md       # 修改
│   ├── product-strategy/TEAM.md        # 修改
│   ├── data-analytics/TEAM.md          # 修改
│   ├── go-to-market/TEAM.md            # 修改
│   ├── marketing-growth/TEAM.md        # 修改
│   ├── market-research/TEAM.md         # 修改
│   └── pm-toolkit/TEAM.md              # 修改
├── skills/
│   ├── delegate-with-tree/SKILL.md     # 新增
│   ├── acceptance-criteria/SKILL.md    # 新增
│   ├── document-template/SKILL.md      # 新增
│   ├── vp-raise-convention/SKILL.md    # 新增
│   └── ...（原有 65 个 skill 不修改）
└── governance/
    ├── DELIVERABLE-ACCEPTANCE-CRITERIA-V2.1.md  # 新增
    └── acceptance_check.sh             # 新增
```

### 5.3 验证标准

- `COMPANY.md` YAML frontmatter 语法正确
- 所有 AGENTS.md YAML frontmatter 语法正确
- 所有 TEAM.md YAML frontmatter 语法正确
- 所有新增 SKILL.md YAML frontmatter 语法正确
- acceptance_check.sh bash 语法正确（`bash -n` 通过）
- 所有新增文件通过 lint（YAML/Markdown）

---

## 六、验收标准

开发完成后，验收方式：

1. **结构验证**：使用 `paperclip-companies-tool` 或 `companies.sh` 导入该模板，确认无报错
2. **Agent 验证**：确认 CEO + 8 个 VP/Director 的 AGENTS.md 包含新增段落
3. **Skill 验证**：确认 4 个新 skill 可被 Agent 加载
4. **脚本验证**：`bash -n governance/acceptance_check.sh` 通过

---

## 七、参考资料

### 官方模板
- [Product Compass Consulting](https://github.com/paperclipai/companies#product-compass-consulting)
- [Gstack](https://github.com/paperclipai/companies#gstack)
- [Superpowers Dev Shop](https://github.com/paperclipai/companies#superpowers-dev-shop)
- [Agency Agents](https://github.com/paperclipai/companies#agency-agents)

### 开发工具
- [companies.sh](https://companies.sh)
- [paperclipai/companies-tool](https://github.com/paperclipai/companies-tool)
- [paperclipai/companies（源码）](https://github.com/paperclipai/companies)

### 已验证的 deliverable-with-tree SKILL.md
（完整内容见上文 4.1 节引用）

### 已验证的 V2.1 验收标准
（完整内容见上文 4.2 节描述，脚本已实际可执行）

---

## 八、变更记录

| 版本 | 日期 | 变更内容 | 作者 |
|------|------|----------|------|
| V1.0 | 2026-07-12 | 初始版本，基于 Product Compass 模板调研 + Phase A 经验教训 | 阿尔法 |
