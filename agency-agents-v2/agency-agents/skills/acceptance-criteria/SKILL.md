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
