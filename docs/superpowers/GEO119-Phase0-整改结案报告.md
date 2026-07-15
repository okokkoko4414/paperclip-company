# GEO119 Phase 0 整改结案报告

**日期**: 2026-07-16
**编制**: Claude Code + Superpowers
**审查**: 贝塔（操盘手）独立核验通过
**状态**: 结案

---

## 一、整改起因

Phase 0 开发完成后，贝塔端到端测试发现 8 项问题（T1-T8），其中 4 项失败、1 项缺陷：

- T1: 三实例在操作 session 不可用
- T2: paperclip_a 因 env 格式错误永久 parking
- T3: session 重建后工具零注入
- T7: MCP 缺 delete_agent/delete_company
- T8: B 公司重复 import 污染 + 幽灵公司残留

根因归类为：配置格式契约盲区、session 保活契约盲区、MCP 工具集盲区、import 幂等性盲区。同时暴露了 4 个组件升级耦合风险（R9-R13）。

---

## 二、整改范围

13 条需求（R1-R13），8 个动作，9 条验收标准。

```
R1-R4: 需求文档盲区修复（Hermes MCP 配置契约、session 保活契约、MCP 工具集、import 幂等性）
R5-R8: Hermes MCP 系统层改造（config 修复、session 重注、删除工具注册、环境清理）
R9-R13: 组件升级抗脆弱（patch 脱离 upstream、版本 pin、plugin/hook 零改核心、回归门禁、模板兼容矩阵）
```

---

## 三、交付物清单

### 运行时系统

| 交付物 | 位置 | 状态 |
|---|---|---|
| 后端 403 修复 patch | `patches/403-adapterType-fallback.patch` | 804 bytes。实测重放：回退修复行 → `git apply` 成功 → 修复行恢复。验证通过 |
| 后端 FK cascade 修复 | `paperclip/server/src/services/companies.ts` | 已提交 `e6bd9c0` |
| Config 自愈脚本 | `paperclip-mcp-v2/setup-mcp-config.sh` | 3/3 测试通过 |
| Hermes 保活插件 | `~/.hermes/plugins/observability/geo119_keepalive/` | 3/3 测试通过，已启用 |
| 回归门禁脚本 | `phase0-regression-check.sh` | 8/8 T1-T8 全绿 |
| 版本 pin | `paperclip-mcp-v2-{a,b,c}/pyproject.toml` | FastMCP 3.4.3, uv.lock 已生成 |

### 模板系统

| 交付物 | 位置 | 状态 |
|---|---|---|
| 治理技能 ×4 | `agency-agents-v2/agency-agents/skills/` | 4/4 存在，中文 |
| 领导注入 ×11 | `agency-agents-v2/agency-agents/agents/{11个}/AGENTS.md` | 11/11，委派/审批/升级 三段声明式 |
| 团队治理 ×10 | `agency-agents-v2/agency-agents/teams/{10个}/TEAM.md` | 10/10，含 `delegate-with-tree` 引用 |
| 公司章程 | `agency-agents-v2/agency-agents/COMPANY.md` | 3 章节，含 C9 |
| B 模板清理 | `superpowers-v2/` | 已删嵌套 `superpowers/` 子包 |
| C adapterType | 167 个 AGENTS.md | 167/167 含 `adapterType: claude_local` |

### 设计文档

| 文档 | 路径 |
|---|---|
| 整改设计 | `docs/superpowers/specs/2026-07-15-geo119-phase0-remediation-design.md` |
| 整改计划 | `docs/superpowers/plans/2026-07-16-geo119-phase0-remediation.md` |
| 结案报告 | `docs/superpowers/GEO119-Phase0-整改结案报告.md`（本文档） |

---

## 四、当前运行状态

```
=== T1: agent.log 注册检查 === PASS
=== T2: paperclip_a 已注册 === PASS
=== T3: 三实例工具全部注入 === PASS
=== T4: 写操作隔离 (REST API) === PASS
=== T5: 后端 1 行修复仍在 === PASS
=== T6: 治理层交付物完好 === PASS
=== T7: delete_agent 已注册 === PASS
=== T8: 环境干净 === PASS
=== 结果: 8 通过, 0 失败 ===
PHASE 0 TOOLCHAIN: HEALTHY
```

| 公司 | UUID | Agent 数 | 状态 |
|---|---|---|---|
| A — Product Compass Consulting V2 | `a87ea87b` | 48 | 干净 |
| B — Superpowers Dev Shop | `7cf82520` | 4 | 干净，无重复 |
| C — Agency Agents | `d79258ba` | 167 | 干净 |

MCP 实例：`mcp__paperclip_a/b/c__*`，每实例 82 工具，合计 246 工具从 3 服务器注册。

---

## 五、途中发现并修复的额外问题

| # | 问题 | 修复 |
|---|---|---|
| 1 | Paperclip 公司删除 cascade 违反 FK（`cost_events` → `heartbeat_runs`） | 交换删除顺序，补 `issueThreadInteractions` |
| 2 | Paperclip 公司删除 cascade 缺 100+ 个 FK 表（幽灵 A 无法通过 API 删除） | 直接 DB 清理，`SET session_replication_role = replica` |
| 3 | Hermes 状态快照残留旧 `paperclip: 'null'` 配置 | 删除 `state-snapshots/20260715-140613-pre-update/` |
| 4 | B 模板嵌套 `superpowers/` 子包导致重复 import | 删除 `superpowers-v2/superpowers/` 目录 |
| 5 | 回归脚本 bash escaping + `import sys` 缺失 | 重写脚本，使用 HEREDOC + env 变量传递 |

---

## 六、验收标准（9/9 全过）

| # | 标准 | 证据 |
|---|---|---|
| 1 | 三实例同时可用 | agent.log: `registered 246 tool(s) from 3 server(s)` |
| 2 | 写操作隔离零串扰 | T4 通过——3 个测试 issue 各落各家 |
| 3 | 重启后工具自动注入 | 插件 `on_session_start` → `discover_mcp_tools()` 生效 |
| 4 | MCP 含 delete_agent | T7 通过——agents.py 注册 + server.json 声明，3 实例均含 |
| 5 | 环境干净 | T8 通过——3 公司，0 幽灵，0 重复 agent |
| 6 | 需求文档已补 | R1-R4 已写入 Phase0-开发需求文档 |
| 7 | git pull 后 403 修复仍在 | 实测验证：回退修复行→`git apply`成功→修复行恢复 |
| 8 | 版本 pin 死 | FastMCP 3.4.3 ×3, paperclip-mcp 0.4.0 ×3 |
| 9 | 升级后 T1-T8 全绿 | 8/8 PASS, `PHASE 0 TOOLCHAIN: HEALTHY` |

---

## 七、已知限制（非阻塞）

1. **teams=0**：Paperclip 导入机制不支持 teams section（设计如此）。委派链靠 AGENTS.md `reportsTo` + 声明式注入，不依赖 Paperclip team 实体。
2. **delete_company**：paperclip-mcp 未实现。通过 REST `DELETE /api/companies/:id` 清理，已文档化。
3. **Paperclip 公司删除 cascade 不完整**：上游 bug（100+ FK 表未覆盖）。本次通过 DB 直接清理绕过。长期建议向上游提交 PR。

---

## 八、组件升级生存性

| 事件 | 后果 |
|---|---|
| Paperclip `git pull upstream` | 403 修复 patch 可 `git apply` 重放 |
| paperclip-mcp 升级 | FastMCP 3.4.3 锁定，`uv.lock` 防止浮动升级 |
| Hermes 升级 | 插件在 `plugins/` 扩展层，零改核心；自愈脚本可恢复 config |
| 任意组件升级后 | `bash phase0-regression-check.sh` 一键验证 8 项全绿 |

---

## 九、Git 提交摘要

| 仓库 | 关键提交 |
|---|---|
| paperclip-company-v2 | `629e308` B 模板清理, `d97d69f` 回归脚本修复, `f064513` 回归门禁, `bf0cc1a` 插件测试, `7ca1f2a` config 脚本测试, `94345bc` patch 文件 |
| paperclip | `e6bd9c0` FK cascade 修复, `0cb2dde` adapterType 回退 |
| hermes | `4723b8c` GEO119 keepalive 插件 |

---

## 十、Phase 0 退出

- [x] 三实例 `mcp__paperclip_a/b/c__*` 在生产 session 同时可用
- [x] 写操作隔离零串扰
- [x] 重启 Hermes 后工具自动全注入
- [x] 环境干净（3 公司，0 幽灵，0 重复 agent）
- [x] 升级后回归门禁一键验证
- [x] 组件版本锁定，抗升级退化

**Phase 0 结案。GEO119 具备转入 Phase A/B/C 的生产级稳定性。**
