# Product Compass Consulting V2 — 完整图谱

**版本**: V2.0  
**日期**: 2026-07-12  
**基于**: [Paperclip Product Compass Consulting](https://github.com/paperclipai/companies#product-compass-consulting) v1.0  
**改造者**: okokkoko4414 (GEO119 项目)

---

## 一、组织架构图

```
CEO (首席执行)
│
├── VP 产品发现 (vp-discovery) ── 7 人
│   ├── Assumption Analyst ── 假设分析
│   ├── Experiment Designer ── 实验设计
│   ├── Feature Analyst ── 功能分析
│   ├── Ideation Specialist ── 创意专员
│   ├── Metrics Designer ── 指标设计
│   ├── OST Analyst ── 机会解决方案树
│   └── User Researcher ── 用户研究
│
├── VP 产品执行 (vp-execution) ── 12 人
│   ├── Data Generator ── 数据生成
│   ├── Meeting Analyst ── 会议分析
│   ├── OKR Specialist ── OKR
│   ├── PRD Writer ── PRD 撰写
│   ├── Prioritization Specialist ── 优先级
│   ├── QA Specialist ── 质量保证
│   ├── Release Manager ── 发布管理
│   ├── Risk Analyst ── 风险分析
│   ├── Roadmap Specialist ── 路线图
│   ├── Sprint Manager ── 冲刺管理
│   ├── Stakeholder Analyst ── 利益相关者
│   └── Story Writer ── 用户故事
│
├── VP 产品战略 (vp-strategy) ── 4 人
│   ├── Business Model Analyst ── 商业模式分析
│   ├── Competitive Intel Analyst ── 竞品情报
│   ├── Pricing Strategist ── 定价策略
│   └── Vision Strategist ── 愿景策略
│
├── 数据总监 (director-data-analytics) ── 2 人
│   ├── Experimentation Analyst ── 实验分析
│   └── SQL Analyst ── SQL 分析
│
├── GTM 总监 (director-gtm) ── 3 人
│   ├── Battlecard Writer ── 竞品卡片
│   ├── Growth Strategist ── 增长策略
│   └── GTM Strategist ── 上市策略
│
├── 市场总监 (director-marketing) ── 3 人
│   ├── Brand Specialist ── 品牌专员
│   ├── Marketing Strategist ── 营销策略
│   └── North Star Analyst ── 北极星指标
│
├── 市场研究总监 (director-market-research) ── 5 人
│   ├── Competitive Analyst ── 竞品分析
│   ├── Journey Mapper ── 旅程地图
│   ├── Market Sizing Analyst ── 市场规模
│   ├── Persona Specialist ── 用户画像
│   └── Sentiment Analyst ── 情感分析
│
└── 工具总监 (director-toolkit) ── 3 人
    ├── Career Specialist ── 职业发展
    ├── Editor ── 编辑
    └── Legal Specialist ── 法务
```

**48 Agents, 8 Teams, 4 层级**

---

## 二、团队结构

| Team | 管理者 | 成员 | 关联 Skill |
|------|--------|------|-----------|
| **Product Discovery** | VP Discovery | 7 | identify-assumptions, opportunity-solution-tree, experiment-design, ideation, metrics-dashboard, interview-script, brainstorm |
| **Product Execution** | VP Execution | 12 | create-prd, sprint-plan, outcome-roadmap, user-stories, job-stories, prioritization-frameworks, qa, test-scenarios, retro, release-notes, stakeholder-map, summarize-meeting |
| **Product Strategy** | VP Strategy | 4 | business-model, pricing-strategy, product-strategy, product-vision, lean-canvas, swot-analysis, pestle-analysis, porters-five-forces, startup-canvas, monetization-strategy |
| **Data Analytics** | Director Data Analytics | 2 | sql-queries, ab-test-analysis, cohort-analysis, dummy-dataset |
| **Go-to-Market** | Director GTM | 3 | gtm-strategy, gtm-motions, competitive-battlecard, growth-loops, beachhead-segment, ideal-customer-profile |
| **Marketing & Growth** | Director Marketing | 3 | marketing-ideas, north-star-metric, product-name, positioning-ideas, value-prop-statements |
| **Market Research** | Director Market Research | 5 | competitor-analysis, customer-journey-map, market-sizing, user-personas, user-segmentation, sentiment-analysis, market-segments |
| **PM Toolkit** | Director Toolkit | 3 | review-resume, grammar-check, draft-nda, privacy-policy |

---

## 三、Skill 清单（69 Skills）

### 官方原版（65 Skills）

| 分类 | Skill | 用途 |
|------|-------|------|
| **Discovery** | identify-assumptions-existing/new | 识别风险假设 |
| | opportunity-solution-tree | Teresa Torres OST |
| | brainstorm-experiments-existing/new | 实验设计 |
| | brainstorm-ideas-existing/new | 创意脑暴 |
| | brainstorm-okrs | OKR 脑暴 |
| | analyze-feature-requests | 功能需求分析 |
| | interview-script | 用户访谈脚本 |
| | summarize-interview | 访谈摘要 |
| | metrics-dashboard | 指标仪表板设计 |
| | prioritize-assumptions | 假设优先级 |
| | prioritize-features | 功能优先级 |
| **Strategy** | business-model | 商业模式画布 |
| | lean-canvas | 精益画布 |
| | product-strategy | 产品策略画布 |
| | product-vision | 产品愿景 |
| | pricing-strategy | 定价策略 |
| | startup-canvas | 创业画布 |
| | monetization-strategy | 变现策略 |
| | ansoff-matrix | 安索夫矩阵 |
| | pestle-analysis | PESTLE 分析 |
| | porters-five-forces | 波特五力 |
| | swot-analysis | SWOT 分析 |
| **Execution** | create-prd | PRD 撰写 |
| | sprint-plan | 冲刺规划 |
| | outcome-roadmap | 成果导向路线图 |
| | user-stories | 用户故事 |
| | job-stories | Job 故事 |
| | wwas | Why-What-Acceptance |
| | prioritization-frameworks | 9 种优先级框架 |
| | release-notes | 发布说明 |
| | test-scenarios | 测试场景 |
| | pre-mortem | 预-mortem 风险分析 |
| | retro | 回顾会议 |
| | stakeholder-map | 利益相关者地图 |
| | summarize-meeting | 会议摘要 |
| **Data Analytics** | sql-queries | SQL 查询 |
| | ab-test-analysis | A/B 测试分析 |
| | cohort-analysis | 队列分析 |
| | dummy-dataset | 模拟数据生成 |
| **GTM** | gtm-strategy | GTM 策略 |
| | gtm-motions | GTM 动作 |
| | competitive-battlecard | 竞品卡片 |
| | growth-loops | 增长飞轮 |
| | beachhead-segment | 滩头细分市场 |
| | ideal-customer-profile | ICP |
| **Marketing** | marketing-ideas | 营销创意 |
| | north-star-metric | 北极星指标 |
| | product-name | 产品命名 |
| | positioning-ideas | 定位创意 |
| | value-prop-statements | 价值主张声明 |
| **Market Research** | competitor-analysis | 竞品分析 |
| | customer-journey-map | 客户旅程地图 |
| | market-sizing | TAM/SAM/SOM |
| | user-personas | 用户画像 |
| | user-segmentation | 用户分群 |
| | sentiment-analysis | 情感分析 |
| | market-segments | 市场细分 |
| **Toolkit** | review-resume | 简历审查 |
| | grammar-check | 语法检查 |
| | draft-nda | NDA 起草 |
| | privacy-policy | 隐私政策 |

### V2 新增（4 Skills）★

| Skill | 用途 | 适用角色 |
|-------|------|---------|
| **delegate-with-tree** ★ | 委派链路规则：Issue 树映射 org 树，完成自动回流 | CEO, Manager, Director, Product |
| **acceptance-criteria** ★ | 7 条可量化验收标准（5 P0 + 2 P1），自动化验证 | CEO, Manager, Director, Reviewer |
| **document-template** ★ | 强制 frontmatter 元数据：author/reviewer/version/status | All |
| **vp-raise-convention** ★ | 异常上报约定：卡住时如何上报，禁止静默 | Manager, Director, VP |

---

## 四、委派链路（Issue 树）

### V1 原版（无委派链路）

```
CEO ←─ 收到任务，随机拆分，无规则
  └── (不知道谁该收什么活)
```

### V2 改造（delegate-with-tree）

```
CEO（顶层领导）
│
└── VP/Director ← parent issue assignee = 该层管理者（不是 CEO！）
    ├── Specialist A ← child issue assignee = 执行者
    ├── Specialist B ← child issue assignee = 执行者
    └── Specialist C ← child issue assignee = 执行者

完成回流：所有 child done/cancelled → 自动唤醒 parent assignee → VP 审查 → 标记 parent done → CEO 收到汇总
```

**核心规则**：
1. **父 issue assignee = 直接管理者**（不是 CEO，除非 CEO 是直接管理者）
2. **子 issue assignee = 执行者**
3. **父 issue 必须保持 todo/in_progress**（backlog 不会唤醒）
4. **全部子 issue 完成才唤醒**（单个完成不唤醒）
5. **父 issue 在子 issue 完成并审查前不得标记 done**
6. **⚠️【OPC 改造 V25.2 新增】board 审批闸门**：任何 issue 进入 `done` 前，**必须经 board（峰哥/local-board 账号）审批**。智能体（含 CEO/VP）无权自标 `done`——子 issue 完成后回流到 VP 审查，VP 标记 `in_review` 交 board 终裁（comment 固化裁决 + reviewer 收尾），board 裁决后才可 `done`。回流链修正为：`child done → VP 审查 → 标 in_review → board 审批 → done → CEO 汇总`
7. **⚠️【OPC 改造 V25.2 新增】Phase 边界隔离**：本模板用于 OPC 多 Phase 公司（Phase A/B/C），**上一 Phase 全部交付物经 board 审批通过，才解锁下一 Phase 的 root issue**；禁止跨 Phase 自动激活子 issue。委派创建子 issue 时若属下一 Phase，须显式挂起（`todo`）直至上一 Phase 审批闸门通过。

---

## 五、质量门禁（V2.1 验收标准）

| 标准 | 优先级 | 阈值 | 验证方式 |
|------|--------|------|---------|
| C1: SEO 不当描述归零 | P0 | 0 个 HIGH | grep 模式匹配（50 个 HIGH 模式） |
| C2: GEO/SEO 混用归零 | P0 | 0 处 | grep `SEO/GEO` |
| C3: 核心事实一致性 | P0 | 0 处 | 语种=119, 产品名=GEO119, 定位=AI搜索优化, 模式=预付费, V1市场=越南 |
| C4: 交付物完整性 | P0 | 全部存在且>200bytes | 27 文件存在性+大小检查 |
| C5: 语义质量 | P1 | h2≥3, ≥200bytes, 无占位符 | 结构检查（11 个文件） |
| C6: 链接有效性 | P1 | 0 个断链 | 相对路径目标文件存在性 |
| C7: 版本一致性 | P0 | 正式版不低于草稿行数 | 01-strategy ≥ 00-plans |

**通过要求**：P0 5/5 全部通过；P1 2/2 通过。

---

## 六、文档模板（Frontmatter 强制元数据）

```yaml
---
document_type: deliverable          # deliverable | plan | review | report
phase: A
directory: 01-strategy
filename: value-proposition.md
version: V1.0
author_agent: VP 产品战略            # 谁写的
reviewer_agent: Reviewer            # 谁审的
status: draft | in_review | approved
created_at: 2026-07-12T10:00:00Z
updated_at: 2026-07-12T12:00:00Z
issue_id: PHA-XXX
---
```

**硬规则**：
- 没有 frontmatter = 拒绝接收
- author_agent 必须与 Issue assignee 一致
- status 变更必须有审查记录

---

## 七、异常上报约定（VP Raise）

| 场景 | 上报方式 | 触发条件 |
|------|---------|---------|
| 子 issue 执行者卡住 | 在 parent issue 开 `request_confirmation` interaction | 执行者无法继续 |
| VP 自己卡住 | 在 CEO 分配的 parent issue 开 interaction 或 comment | 需要 CEO 决策 |
| Specialist 需 VP 介入 | 在 parent issue @mention VP 或开 interaction | 需要管理层判断 |
| 预算告警 | VP 在 parent issue comment 说明 | 预算接近上限 |

**硬规则**：卡住超过 1 个 heartbeat 周期必须上报，不得静默等待 deadline。

---

## 八、改造清单

| 改造项 | V1 原版 | V2 改造 | 状态 |
|--------|---------|---------|------|
| 委派链路 | 无 | delegate-with-tree skill | ✅ |
| 验收标准 | 无 | acceptance-criteria skill + governance/ | ✅ |
| 文档模板 | 无 | document-template skill | ✅ |
| 异常上报 | 无 | vp-raise-convention skill | ✅ |
| CEO AGENTS.md | 无委派约定 | 注入 Delegation+Quality+Document | ✅ |
| VP AGENTS.md | 无 | 注入 Delegation+Quality+Raise (3 个 VP) | ✅ |
| Director AGENTS.md | 无 | 注入 Delegation+Quality+Raise (5 个 Director) | ✅ |
| COMPANY.md | 无委派/质量说明 | 增加 3 个章节 | ✅ |
| TEAM.md | 无新 skill 引用 | 8 个 team 增加 3 个 skill 引用 | ✅ |

---

## 九、文件清单

| 类型 | 文件 | 来源 |
|------|------|------|
| **新增 Skill** | `skills/delegate-with-tree/SKILL.md` | 改造 |
| | `skills/acceptance-criteria/SKILL.md` | 改造 |
| | `skills/document-template/SKILL.md` | 改造 |
| | `skills/vp-raise-convention/SKILL.md` | 改造 |
| **新增 Governance** | `governance/DELIVERABLE-ACCEPTANCE-CRITERIA-V2.3.md` | 改造 |
| | `governance/acceptance_check.sh` | 改造 |
| **修改** | `COMPANY.md` | 改造 |
| | `agents/ceo/AGENTS.md` | 改造 |
| | `agents/vp-*/AGENTS.md` (3) | 改造 |
| | `agents/director-*/AGENTS.md` (5) | 改造 |
| | `teams/*/TEAM.md` (8) | 改造 |
| **保留** | 65 原版 skills | 官方 |
| | 48 agents (含 Specialist/Analyst) | 官方 |
| | README.md, LICENSE, images | 官方 |

**总计**: 48 Agents, 69 Skills, 8 Teams, 1 Company, 4 Governance files, 9 Modified files
