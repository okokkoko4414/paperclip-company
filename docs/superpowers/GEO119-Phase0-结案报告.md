# GEO119 Phase 0 结案报告

**日期**: 2026-07-15
**编制**: Claude Code + Superpowers
**状态**: 结案

---

## 一、项目概述

GEO119 Phase 0 目标是搭建贝塔（Hermes beta profile）并行控制三家 Paperclip 公司的工具链。三个阻塞问题：

1. beta 会话只能控一家公司，无法并行控三家
2. B/C 两家公司模板 import 被 403 拦截
3. Agency Agents 模板缺径向委派链和跨公司治理

---

## 二、交付物清单

### 代码层

| 交付物 | 位置 | 变更 |
|---|---|---|
| 后端 adapter 回退修复 | `/home/ok2049/paperclip/server/src/services/company-portability.ts:2712` | 1 行：`?? asString(frontmatter.adapterType)` |
| 源码分支镜像 | `/media/ok2049/work/tools/paperclip-src/server/src/services/company-portability.ts:2712` | 同上 |
| Wrapper A/B/C | `paperclip-mcp-v2/paperclip-mcp-v2-{a,b,c}/wrapper.sh` | 硬编码 COMPANY_ID + API_KEY + BASE_URL |
| Hermes 配置 | `~/.hermes/profiles/beta/config.yaml` | paperclip_a/b/c 已启用，旧 paperclip 已移除 |
| 治理技能 ×4 | `agency-agents-v2/agency-agents/skills/{4个}/SKILL.md` | delegate-with-tree, acceptance-criteria(框架), document-template, vp-raise-convention |
| 领导注入 ×11 | `agency-agents-v2/agency-agents/agents/{11个}/AGENTS.md` | 委派/审批/升级 三段声明式注入 |
| 团队治理 ×10 | `agency-agents-v2/agency-agents/teams/{10个}/TEAM.md` | delegate-with-tree 引用 |
| 公司章程 | `agency-agents-v2/agency-agents/COMPANY.md` | 委派约定 + 跨公司协调(C9) + 质量门 |

### 设计文档层

| 文档 | 路径 |
|---|---|
| 需求文档 | `AMM/GEO/GEO119-V2/Phase0-开发需求文档.md` |
| 设计规格 | `docs/superpowers/specs/2026-07-15-geo119-phase0-toolchain-design.md` |
| 实施计划 | `docs/superpowers/plans/2026-07-15-geo119-phase0-toolchain.md` |
| 结案报告 | `docs/superpowers/GEO119-Phase0-结案报告.md`（本文档） |

### 运行时数据

| 公司 | UUID | MCP 前缀 | 工具数 |
|---|---|---|---|
| A - Product Compass V2 | `3d402864-4cb8-4334-b376-2670abfa05e1` | `mcp__paperclip_a__*` | 82 |
| B - Superpowers Dev Shop | `7588c82e-932c-4af7-9bae-01c6ce684573` | `mcp__paperclip_b__*` | 82 |
| C - Agency Agents | `e6e64b85-2177-4e0c-af5c-6f52ad6f016b` | `mcp__paperclip_c__*` | 82 |

---

## 三、验收标准

| 标准 | 判定 | 证据 |
|---|---|---|
| **AC1** 写操作隔离，零交叉污染 | 通过 | 3 个测试 issue，A 仅显示 A，B 仅显示 B，C 仅显示 C |
| **AC2** B/C import 成功，无 403 | 通过 | API 确认 B(`7588c82e`) 和 C(`e6e64b85`) 均已导入 |
| **AC3** 委派树不断裂 | 就绪 | 11/11 领导层含委派/审批/升级链，4 个治理技能已部署 |

---

## 四、技术决策与偏差

### 决策 1：后端 1 行回退 > 模板 167 条批量修补

**选择**：在 `company-portability.ts` 添加 `?? asString(frontmatter.adapterType)` 回退逻辑。
**理由**：一层修复覆盖所有模板中的所有 agent，现在和将来均是如此。对 `.paperclip.yaml` 做 167 条条目属于变通方案，在修复程序已将其变为不必要后仍需维护。
**结果**：正确决策。B 和 C 均无需修改 `.paperclip.yaml` 即可导入。

### 决策 2：Wrapper 自包含 > Config env 注入

**选择**：将 API key、base URL 和 company UUID 硬编码到每个 wrapper.sh 中。
**理由**：`hermes config set` 不支持深度嵌套键（`mcp_servers.paperclip_b.env.PAPERCLIP_API_KEY` 会因 `ValueError: Invalid environment variable name` 失败）。Wrapper 自包含所有运行时配置，无需 config 层的 env 注入。
**结果**：paperclip_b 和 paperclip_c 在 config 中没有 `env:` 块。功能等价，已记录为计划偏差。

### 决策 3：直接编辑 Config（C1 例外）

**选择**：直接编辑 `config.yaml` 删除 `env: 'null'` 行。
**理由**：`hermes config set <key> null` 将该值设为字符串 `"null"` 而非 YAML null。Hermes 随后尝试将 `"null"` 解析为 env dict，导致 `dictionary update sequence element #0 has length 1`。`hermes config` 没有 unset/delete 命令。
**结果**：Config 已清理。这是一个 `hermes config set` 无法表示"删除此键"语义的工具局限性——若 Hermes CLI 将来支持 `hermes config unset` 即可解决。

---

## 五、遇到的问题与修复

| # | 问题 | 根因 | 修复 |
|---|---|---|---|
| 1 | C import 在服务器重启前失败 | Paperclip 服务器使用缓存的旧代码运行 | 终止服务器并重启；`tsx watch` 未运行 |
| 2 | B/C 被重复 import（幽灵公司） | import 脚本运行了多次，无幂等性检查 | 删除 7 个幽灵公司，保留 2 个目标公司 |
| 3 | paperclip_a 连接失败，提示 `dictionary update sequence element` | Config 中残留的 `env: 'null'` 字符串被 Hermes 解析为 env dict | 直接从 config.yaml 删除 `env:` 行 |
| 4 | `hermes config set` 无法设置嵌套 env 键 | CLI 将所有键路径转换为大写并将点分隔键视为环境变量名 | Wrapper 硬编码所有 env 值，绕过该限制 |
| 5 | Hermes 重启后 paperclip_a 仍保持 "parked" 状态 | Hermes 在首次失败后缓存了连接状态 | 临时将 paperclip_a 指向 wrapper B 以强制重建传输层，然后恢复为 wrapper A |

---

## 六、约束合规性

| 约束 | 判定 | 备注 |
|---|---|---|
| C1 | 已满足 | 除程序化限制必需的 1 次直接编辑外，全部使用 `hermes config set` |
| C2 | 已满足 | 所有交付物均为中文 |
| C3 | 已满足 | 备份位于 `/tmp/agency-agents-v2.bak-*` 和 `/tmp/superpowers-v2.bak-*` |
| C4 | 已满足 | 从单个 `paperclip` 实例起步 |
| C5 | 已满足 | A 已存在，B/C 为新导入 |
| C6 | 已满足 | 三层目录结构已保留 |
| C7 | 已满足 | 重启前 3 个 wrapper 均已使用真实 UUID 回填 |
| C8 | 已满足 | acceptance-criteria 为框架形式；部门特定标准推迟至 Phase C |
| C9 | 已满足 | 跨公司协调模式已保留；COMPANY.md 显式拒绝简化 |

---

## 七、Git 提交

| 仓库 | 提交 | 描述 |
|---|---|---|
| paperclip (运行实例) | `0cb2dde` | 修复：safe import 中回退至 frontmatter adapterType |
| paperclip-company-v2 | `253b32a` | 特性：为 Agency Agents 添加 V2 治理层 |

---

## 八、经验教训

1. **`hermes config set` 有嵌套键限制**。深度嵌套键（`a.b.c.d`）会因环境变量命名规则而失败。值只能设为字符串，无法表示"删除"。未来的 Hermes 配置工作应预见到这一点。

2. **幂等性缺失**。多次 import 运行会产生幽灵公司。未来的 import 工作流程应包含预先检查：列出已有公司 → 仅 import 不存在的。

3. **`tsx watch` 不可靠**。paperclip 服务器在本次会话的某个时刻丢失了监听进程，需要手动重启。应使用 systemd 服务或更稳健的进程监控。

4. **YAML null ≠ 字符串 "null"**。将 `hermes config set key null` 设为字符串 `"null"`，而非 YAML null，这破坏了 env 字典解析。

---

## 九、Phase 0 退出标准

- [x] 贝塔可以在同一 Hermes 会话中并行控制三家 Paperclip 公司
- [x] B（Superpowers）和 C（Agency Agents）均已导入，具备真实 UUID
- [x] 通过 REST API 和 MCP 传输层验证了三向数据隔离
- [x] Agency Agents 具备带有委派/审批/升级模式的 V2 治理层
- [x] 旧单实例 `mcp__paperclip__*` 已移除

**Phase 0 已结案。GEO119 已准备好转入 Phase A（Product Compass 策划）、Phase B（Superpowers 开发）和 Phase C（Agency Agents 运营）。**
