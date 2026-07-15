# GEO119 Phase 0 — Paperclip 公司模板仓库

三套 Paperclip 公司模板（A/B/C），含 V2 治理层、设计文档、运维工具和升级恢复 patch。供 Hermes beta 通过 `mcp__paperclip_{a,b,c}__*` 工具前缀并行控制。

## 模板

| 模板 | 路径 | Agent 数 | 形态 |
|---|---|---|---|
| A — Product Compass Consulting V2 | `product-compass-consulting-v2/` | 48 | Hub-and-spoke（CEO → 3 VP → 5 Directors → 39 Specialists） |
| B — Superpowers Dev Shop | `superpowers-v2/` | 4 | 线性流水线（CEO → Lead Engineer → Code Reviewer → Release Engineer） |
| C — Agency Agents | `agency-agents-v2/agency-agents/` | 167 | Hub-and-spoke（CEO → 10 Division Leads → Specialists） |

每个模板包含：`COMPANY.md`、`.paperclip.yaml`、`agents/*/AGENTS.md`、`skills/`、`governance/`。C 额外包含 `teams/{10}/TEAM.md`。

## V2 治理层

三套模板均有声明式治理层注入，每个领导层 AGENTS.md 追加三段：

1. **委派规则** — 谁委派给谁，什么约束
2. **审批责任** — 父 Issue 何时可以标记 done
3. **升级路径** — 受阻 >1 心跳周期如何升级

治理技能在 `skills/` 目录：

- `delegate-with-tree` — 父子 Issue 树映射组织层级
- `acceptance-criteria` — 7 条验收标准（5 P0 + 2 P1，Phase 0 仅框架）
- `document-template` — 交付物强制 frontmatter 元数据
- `vp-raise-convention` — 受阻升级协议

## 运维工具

### 回归检查

```bash
bash phase0-regression-check.sh
```

T1-T8 全自动检查，输出 `HEALTHY` 或 `DEGRADED`。任何组件升级后必跑。

### 后端修复 Patch

Paperclip 后端有两个修复，不做独立仓库，通过 patch 桥接：

```bash
cd /home/ok2049/paperclip
git apply patches/0001-fix-fallback-to-frontmatter-adapterType-in-safe-impo.patch
```

| 修复 | 文件 | 作用 |
|---|---|---|
| adapterType 回退 | `company-portability.ts:2712` | import 时从前端 frontmatter 读取 adapterType |
| FK cascade 删除顺序 | `companies.ts` | 修复公司删除时外键约束违反 |

Paperclip `git pull upstream` 后 patch 可能被覆盖，重新 `git apply` 即可。回归脚本 T5 会自动验证。

## 配套仓库

| 仓库 | 内容 |
|---|---|
| `okokkoko4414/paperclip-mcp-v2` | 三个 MCP wrapper + config 自愈脚本 + Hermes 保活插件 + 版本锁 |
| paperclip 后端 | 不做独立仓库，通过本仓库 `patches/` 桥接 |

## 文档

- `docs/superpowers/specs/` — 设计规格
- `docs/superpowers/plans/` — 实施计划
- `docs/superpowers/GEO119-Phase0-整改结案报告.md` — 整改结案报告
- `CLAUDE.md` — Claude Code 工作指南

## License

各模板保留原始 License。GEO119 工具链部分 MIT。
