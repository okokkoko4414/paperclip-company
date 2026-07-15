# GEO119 Phase 0 整改设计

**Date**: 2026-07-15
**Source**: Phase0-端到端交付测试报告.md + Phase0-改进优化方案.md (R1-R13)
**Status**: draft

## Summary

Phase 0 交付物在 paperclip 侧全部通过（后端修复生效、wrapper 绑定正确、治理层完整），但 Hermes × paperclip 联调层暴露出配置脏数据、session 重建工具丢失、MCP 删除能力缺失、重复 import 污染四类问题，且后端的 403 修复直接改在 upstream 工作树、paperclip-mcp 版本浮动，存在升级后静默失效的风险。

本次整改覆盖 R1-R13 全部要求，交付 8 个动作，验收标准 9 条。

## Architecture

```
                        ┌──────────────────────────┐
                        │   phase0-regression-check │  ← 动作 8：升级门禁
                        │   (T1-T8 自动化验证)       │
                        └──────────┬───────────────┘
                                   │ 验证
        ┌──────────────────────────┼──────────────────────────┐
        │                          │                          │
   ┌────▼─────┐            ┌──────▼──────┐           ┌───────▼────────┐
   │ 防御层    │            │  自愈层      │           │  运维层         │
   │          │            │             │           │                │
   │ 动作1    │            │ 动作3       │           │ 动作7          │
   │ patch文件│            │ config脚本  │           │ 版本pin        │
   │          │            │             │           │                │
   │ 动作2    │            │ 动作4       │           │ 动作6          │
   │ 模板防御 │            │ auto-reload │           │ 环境清理       │
   │          │            │             │           │                │
   │ 动作5    │            │             │           │                │
   │ delete   │            │             │           │                │
   │ _agent   │            │             │           │                │
   └──────────┘            └─────────────┘           └────────────────┘
```

三层设计原则：
- **防御层**：每项关键功能至少有两条独立路径存活
- **自愈层**：升级后跑脚本恢复正确状态，不依赖人工记忆
- **运维层**：固化回归检查，升级即验证

## 组件版本基线 (2026-07-15)

| 组件 | 版本 | 升级风险 |
|------|------|---------|
| paperclip 后端 | paperclipai/paperclip (upstream) | 403 修复在 upstream 工作树，git pull 即覆盖 |
| paperclip-mcp | 0.4.0 (wizarck) | pyproject 未 pin 版本，uv run 静默拉最新 |
| FastMCP | 3.4.3 | 浮动依赖 |
| Hermes | 本地 ~/.hermes/hermes-agent | MCP 加载逻辑绑死当前 mcp_tool.py |

---

## 动作 1：后端 403 修复脱离 upstream（R9）

### 问题

`company-portability.ts:2712` 的 1 行修复直接改在 `/home/ok2049/paperclip`（upstream 工作树）。`git pull upstream` 或重新 clone 即覆盖，B/C import 403 重现。

### 方案

1. 从 commit `0cb2dde` 生成 patch（只含那 1 行修复，不含工作树其他改动）：
   ```bash
   cd /home/ok2049/paperclip
   git format-patch -1 0cb2dde -o /media/ok2049/work/work/paperclip-company-v2/patches/
   # 生成 0001-fix-fallback-to-frontmatter-adapterType-in-safe-imports.patch
   ```

   `git diff` 会捕获工作树全部脏文件（当前 11 个文件有无关改动），不可用。必须用 `git format-patch` 从 commit 提取。<!-- 已核：工作树脏，git diff 策略错 -->

2. 源码 fork `/media/ok2049/work/tools/paperclip-src` 建分支 `geo119-phase0`，提交修复。

3. 运行目录用 `git apply` 方式应用 patch（而非直接编辑）。

4. 升级 paperclip 后：
   ```bash
   cd /home/ok2049/paperclip
   git stash && git pull upstream && git stash pop
   # 如果冲突：
   git apply /media/ok2049/work/work/paperclip-company-v2/patches/403-adapterType-fallback.patch
   ```

### 验证

```bash
grep "frontmatter.adapterType" /home/ok2049/paperclip/server/src/services/company-portability.ts
# 预期：回退逻辑存在
```

---

## 动作 2：模板层双重防御（R4）

### 当前状态

- **B（superpowers-v2）**：用户已手动添加 `adapter.type: claude_local` 到全部 4 个 agent。✅ 已完成。
- **C（agency-agents-v2）**：`agency-agents/.paperclip.yaml` 当前只有 `vp-engineering`（GH_TOKEN 输入，无 adapter）。其余 166 个 agent 缺失。❌ 需补。

### 方案

为 C 模板的 `agency-agents-v2/agency-agents/.paperclip.yaml` 批量补全 166 条 `adapter.type: claude_local`。Agent slug 列表来自 `agency-agents/agents/*/` 目录名。

生成格式（与 B 一致）：
```yaml
agents:
  academic-anthropologist:
    adapter:
      type: claude_local
  academic-geographer:
    adapter:
      type: claude_local
  # ... 167 total
```

### 防御逻辑

```
import_company_package
  → .paperclip.yaml 有 adapter.type?  → 用 .paperclip.yaml 的值
  → .paperclip.yaml 无 adapter.type?  → 后端回退读 AGENTS.md frontmatter (动作1)
  → 两者都无?                         → process → 403
```

### 验证

```bash
grep -c "adapter:" /media/ok2049/work/work/paperclip-company-v2/agency-agents-v2/agency-agents/.paperclip.yaml
# 预期：≥167（每个 agent 一个 adapter 块）
```

---

## 动作 3：Config 自愈脚本（R1、R5）

### 问题

当前 config 残留在：`paperclip: 'null'`（旧实例没删干净，Hermes 尝试解析字符串 `"null"` 为 MCP 配置）。恢复路径依赖人工记忆 `hermes config set` 命令序列，且 C1 约束下嵌套键无法通过 CLI 删除。

### 方案

创建 `paperclip-mcp-v2/setup-mcp-config.sh`，可重复执行：

```bash
#!/bin/bash
# setup-mcp-config.sh — 自愈 Hermes beta MCP 配置
# 可重复执行，幂等

CONFIG="$HOME/.hermes/profiles/beta/config.yaml"
API_KEY="pcp_board_e65a40681143c73cda97a250ed4d21c8eb48a43427f089ab"
BASE_URL="http://127.0.0.1:3100/api"

echo "=== Phase 0 MCP Config Self-Heal ==="

# 1. 清理旧实例残留（paperclip: 'null' 或 paperclip: 旧版）
if grep -q "paperclip:.*null\|^  paperclip:" "$CONFIG" 2>/dev/null; then
  echo "FIX: 删除旧 paperclip 实例残留"
  # hermes config set 不支持删除 key，直修 config.yaml（C1例外——仅此操作）
  python3 -c "
import yaml
with open('$CONFIG') as f: cfg = yaml.safe_load(f)
if 'paperclip' in cfg.get('mcp_servers', {}):
    del cfg['mcp_servers']['paperclip']
with open('$CONFIG', 'w') as f: yaml.dump(cfg, f, default_flow_style=False, allow_unicode=True)
"
fi

# 2. 确保 paperclip_a/b/c 存在且 enabled
for inst in a b c; do
  cmd=$(hermes config get "mcp_servers.paperclip_${inst}.command" 2>/dev/null || echo "")
  if [ -z "$cmd" ]; then
    echo "FIX: 创建 paperclip_${inst}"
    hermes config set "mcp_servers.paperclip_${inst}.command" \
      "/media/ok2049/work/work/paperclip-mcp-v2/paperclip-mcp-v2-${inst}/wrapper.sh"
    hermes config set "mcp_servers.paperclip_${inst}.enabled" true
  fi
done

# 3. 清除 paperclip_a 的错误 env（JSON 字符串）
if grep -A2 "paperclip_a:" "$CONFIG" | grep -q "env:"; then
  echo "FIX: 删除 paperclip_a 的错误 env 段"
  python3 -c "
import yaml
with open('$CONFIG') as f: cfg = yaml.safe_load(f)
a = cfg['mcp_servers'].get('paperclip_a', {})
if 'env' in a:
    del a['env']
with open('$CONFIG', 'w') as f: yaml.dump(cfg, f, default_flow_style=False, allow_unicode=True)
"
fi

# 4. 验证 wrapper 可执行
for inst in a b c; do
  wrapper="/media/ok2049/work/work/paperclip-mcp-v2/paperclip-mcp-v2-${inst}/wrapper.sh"
  if [ -x "$wrapper" ]; then
    echo "OK: paperclip_${inst} wrapper 可执行"
  else
    echo "FAIL: paperclip_${inst} wrapper 不可执行或不存在: $wrapper"
  fi
done

echo "=== 自愈完成 ==="
```

### 验证

```bash
bash /media/ok2049/work/work/paperclip-mcp-v2/setup-mcp-config.sh
# 预期输出：全部 OK，无 FAIL
```

---

## 动作 4：Hermes session 保活 — 方案 D（R2、R6、R11）

### 问题

`mcp_tool.py:2138` — parking 会 deregister tools。`turn_context.py:198` — `refresh_agent_mcp_tools` 仅在 between-turns 触发且 gated by `has_registered_mcp_tools()`。Session 重建后多实例 MCP 工具不自动重注。

### 方案 D：on_session_start hook + 非交互 reload（零改核心）

已核实 Hermes 具备以下能力：

1. **`on_session_start` hook**（`plugins.py:160`，`hooks.py:1158` 提供 `register_hook()`）：插件可注册回调，session 启动时自动触发
2. **非交互 reload**（`config.py:2565`：`mcp_reload_confirm` 默认 `True`）：设 `approvals.mcp_reload_confirm: false` 后 `/reload-mcp` 跳过确认提示，可被 hook 回调直接调用

**实施**：

1. 写一个 Hermes plugin，注册到 `on_session_start` hook
2. 回调函数内调用 `_reload_mcp()`（非交互路径，读 `approvals.mcp_reload_confirm` 配置项跳过确认）
3. 重启 Hermes → session 启动 → `on_session_start` 触发 → 自动全量 reload MCP → 三实例工具注入

**已证伪的歧路（实施方勿走）**：
- 方案 A（改 `turn_context.py` 核心循环）→ 侵入核心，升级冲突
- 方案 C（hooks 目录磁盘脚本）→ 实测 Hermes hooks 是内部 Python 回调体系，非 session_start 自动执行的 shell 脚本
- 方案 B（手动 `/reload-mcp`）→ 运维负债

**符合 R11**：零改核心文件，hook 落在 plugin 扩展层，Hermes 升级不覆盖。

### 待核项（实施时确认）

1. **ctx 暴露 reload 接口**：`_reload_mcp()` 是 `cli.py` 中 CLI 实例的方法。plugin 的 `on_session_start` 回调拿到的 `ctx` 是否有入口调用 reload，需实施时实测。`nemo_relay` 的 `on_session_start` 只记日志，未调 reload——本次是首次在 hook 里调 reload，需验证 ctx 暴露了 reload 路径。<!-- 非阻塞：机制存在，实施验证即可 -->
2. **验收硬要求**：实施后必须实测"重启 Hermes → 三实例自动注入"，不能只因为 `on_session_start` + `mcp_reload_confirm` 机制存在就断言成功。以 agent.log 的 `registered 246 tool(s) from 3 server(s)` 为证据。

### 验证

```bash
# 重启 Hermes 后
grep "MCP: registered 246 tool(s) from 3 server(s)" \
  /home/ok2049/.hermes/profiles/beta/logs/agent.log | tail -1
# 预期：最后一次注册显示 3 server(s)，0 failed
```

---

## 动作 5：MCP 删除能力补全（R3、R7）

### 实测修正

`paperclip-mcp/tools/agents.py:18` **已注册** `mcp.tool()(delete_agent)`。设计文档中"未注册需加"是错误前提。三实例均已注册，delete_agent 当前可用。

### 真正缺口：delete_company

`companies.py` 中经核实无 `delete_company` 函数实现。操盘手删公司只能绕 REST API。

### 方案

1. 实施时核实三实例 `agents.py:18` 均含 `mcp.tool()(delete_agent)` 注册
2. `delete_company`：若 `companies.py` 无实现，在需求文档写明 REST 清理路径：`DELETE /api/companies/:id`（已核 `svc.remove` 事务级联安全）

### 验证

- MCP 工具列表含 `delete_agent`（三实例核实）
- 公司删除路径已文档化（MCP 或 REST）

---

## 动作 6：环境清理（R8）

### 问题

- B 公司 8 个 agent（含 4 个重复，名字带 "2"）：`CEO 2`、`Lead Engineer 2`、`Code Reviewer 2`、`Release Engineer 2`
- 幽灵 A 公司 `5412501b-68b2-4617-ba50-b649c4c13197`：123 issue、48 agent，Phase 0 实验残留

### 方案

**清理 B 重复 agent**（通过 REST API）：
```bash
# 1. 列 B 的 agents
# 2. 删 name 含 " 2" 的 4 个重复 agent
# 3. 验证剩余 4 个唯一 agent
```

**清理幽灵 A 公司**（通过 REST API，因为 delete_company 暂未注册到 MCP）：
```bash
curl -X DELETE \
  -H "Authorization: Bearer pcp_board_..." \
  "http://127.0.0.1:3100/api/companies/5412501b-68b2-4617-ba50-b649c4c13197"
```

**A/B/C 三家公司保留**。R8 验证标准允许"或仅保留你指定的真身"——A-v2（`3d402864`）、B（`7588c82e`）、C（`e6e64b85`）已通过联调验证，推倒重建无收益且增加重配风险。若后续决策要求推倒重建（如 Phase A 开始前统一重置），到那时再执行。

### 验证

```bash
# B agent 数 = 4（唯一 slug）
curl -s -H "Authorization: Bearer ..." \
  "http://127.0.0.1:3100/api/companies/7588c82e.../agents" | python3 -c \
  "import sys,json; d=json.load(sys.stdin); print(len(d if isinstance(d,list) else d.get('agents',[])))"
# 预期：4

# 公司列表无 5412501b
curl -s -H "Authorization: Bearer ..." \
  "http://127.0.0.1:3100/api/companies" | grep -c "5412501b"
# 预期：0
```

---

## 动作 7：paperclip-mcp 版本 pin 死（R10）

### 问题

三个 v2 目录的 `pyproject.toml` 未锁定 paperclip-mcp 版本。`uv run` 会静默拉最新版，MCP 工具名/参数可能变化。

### 方案

三个 `pyproject.toml` 中显式声明：
```toml
[project]
dependencies = [
    "paperclip-mcp==0.4.0",
]
```

然后生成 `uv.lock`：
```bash
for inst in a b c; do
  cd /media/ok2049/work/work/paperclip-mcp-v2/paperclip-mcp-v2-${inst}
  uv lock
done
```

### 验证

```bash
for inst in a b c; do
  cd /media/ok2049/work/work/paperclip-mcp-v2/paperclip-mcp-v2-${inst}
  uv run paperclip-mcp --version
done
# 预期：三实例均输出 0.4.0
```

---

## 动作 8：升级回归门禁（R12、R13）

### 问题

任何组件升级后，没有自动化手段验证 Phase 0 工具链是否完好。当前依赖人工记忆逐项检查。

### 方案

创建 `paperclip-company-v2/phase0-regression-check.sh`，固化 T1-T8：

```bash
#!/bin/bash
# phase0-regression-check.sh — GEO119 Phase 0 工具链回归检查
# 任何 hermes/paperclip/paperclip-mcp 升级后必跑

PASS=0; FAIL=0
check() {
  local label="$1"; shift
  if "$@"; then echo "  PASS: $label"; PASS=$((PASS+1))
  else echo "  FAIL: $label"; FAIL=$((FAIL+1)); fi
}

echo "=== T1: 三实例 agent.log 注册 ==="
check "T1" grep -q "registered 246 tool(s) from 3 server(s)" \
  $(ls -t ~/.hermes/profiles/beta/logs/agent.log* | head -1)

echo "=== T2: paperclip_a 无 env 格式错误 ==="
check "T2" ! grep -q "paperclip_a.*length 1; 2 is required" \
  ~/.hermes/profiles/beta/logs/agent.log

echo "=== T3: 三实例工具全部注入 ==="
check "T3" grep -q "mcp__paperclip_a__list_issues.*mcp__paperclip_b__list_issues.*mcp__paperclip_c__list_issues" \
  ~/.hermes/profiles/beta/logs/agent.log || \
  grep -q "registered.*from 3 server.*(0 failed)" \
  ~/.hermes/profiles/beta/logs/agent.log

echo "=== T4: 写操作隔离 ==="
# 调用 API 验证隔离（与 AC1 验证相同逻辑）
check "T4" python3 -c "
import json, urllib.request
API='http://127.0.0.1:3100/api'
KEY='pcp_board_e65a40681143c73cda97a250ed4d21c8eb48a43427f089ab'
CO={'A':'3d402864-4cb8-4334-b376-2670abfa05e1','B':'7588c82e-932c-4af7-9bae-01c6ce684573','C':'e6e64b85-2177-4e0c-af5c-6f52ad6f016b'}
def api(u,b=None):
    d=json.dumps(b).encode() if b else None
    r=urllib.request.Request(u,data=d,method='POST' if b else 'GET')
    r.add_header('Authorization',f'Bearer {KEY}');r.add_header('Content-Type','application/json')
    with urllib.request.urlopen(r,timeout=10) as resp: return json.loads(resp.read())
def titles(res):
    if isinstance(res,list): return [i.get('title','') for i in res]
    return [i.get('title','') for i in res.get('issues',res.get('data',[]))]
# Create unique test issue
import time
ts=str(int(time.time()))
for l,cid in CO.items():
    api(f'{API}/companies/{cid}/issues',{'title':f'REGRESSION-T4-{l}-{ts}'})
# Verify isolation
ok=True
for sl,scid in CO.items():
    st=titles(api(f'{API}/companies/{scid}/issues'))
    for tl in CO:
        if sl==tl: continue
        if any(f'REGRESSION-T4-{tl}-{ts}' in t for t in st):
            ok=False
sys.exit(0 if ok else 1)
" 2>/dev/null

echo "=== T5: 后端 1 行修复仍在 ==="
check "T5" grep -q "frontmatter.adapterType" \
  /home/ok2049/paperclip/server/src/services/company-portability.ts

echo "=== T6: 治理层交付物完好 ==="
skills=$(ls /media/ok2049/work/work/paperclip-company-v2/agency-agents-v2/agency-agents/skills/*/SKILL.md 2>/dev/null | wc -l)
injections=0
for a in ceo vp-engineering creative-director cmo vp-product vp-sales vp-operations game-dev-director chief-of-staff qa-director xr-director; do
  if grep -q "委派规则\|审批责任\|升级路径" /media/ok2049/work/work/paperclip-company-v2/agency-agents-v2/agency-agents/agents/$a/AGENTS.md 2>/dev/null; then
    injections=$((injections+1))
  fi
done
teams=$(grep -rl "delegate-with-tree" /media/ok2049/work/work/paperclip-company-v2/agency-agents-v2/agency-agents/teams/*/TEAM.md 2>/dev/null | wc -l)
check "T6" [ "$skills" -ge 4 ] && [ "$injections" -ge 11 ] && [ "$teams" -ge 10 ]

echo "=== T7: MCP 工具含 delete_agent ==="
check "T7" grep -q "delete_agent" /media/ok2049/work/work/paperclip-mcp-v2/paperclip-mcp-v2-a/src/paperclip_mcp/tools/agents.py

echo "=== T8: 环境干净 ==="
check "T8" python3 -c "
import json, urllib.request
API='http://127.0.0.1:3100/api'
KEY='pcp_board_e65a40681143c73cda97a250ed4d21c8eb48a43427f089ab'
ok=True
# 1. 公司列表：只应有 A-v1(5412501b)、A-v2(3d402864)、B(7588c82e)、C(e6e64b85)
#    幽灵 B/C 已删，若重现则 fail
req=urllib.request.Request(f'{API}/companies',headers={'Authorization':f'Bearer {KEY}'})
cs=json.loads(urllib.request.urlopen(req,timeout=10).read())
cs=cs if isinstance(cs,list) else cs.get('companies',[])
names=[c.get('name','') for c in cs]
# 检查无 GEO119-Phase-B-v2 / GEO119-Phase-C-v2 幽灵（当前应无）
for n in names:
    if 'GEO119-Phase-B-v2' in n or 'GEO119-Phase-C-v2' in n:
        print(f'GHOST COMPANY: {n}'); ok=False
# 2. B 公司 agent 数 = 4（唯一 slug，无重复）
B_ID='7588c82e-932c-4af7-9bae-01c6ce684573'
req=urllib.request.Request(f'{API}/companies/{B_ID}/agents',headers={'Authorization':f'Bearer {KEY}'})
agents=json.loads(urllib.request.urlopen(req,timeout=10).read())
agents=agents if isinstance(agents,list) else agents.get('agents',[])
# 排除重复 agent（名字含 ' 2'）
dupes=[a.get('name','') for a in agents if ' 2' in a.get('name','')]
if len(dupes)>0:
    print(f'B DUPLICATE AGENTS: {dupes}'); ok=False
if len(agents) != 4:
    print(f'B agent count: {len(agents)} (expected 4)'); ok=False
sys.exit(0 if ok else 1)
" 2>/dev/null

echo "=== 结果: $PASS 通过, $FAIL 失败 ==="
[ "$FAIL" -eq 0 ] && echo "PHASE 0 TOOLCHAIN: HEALTHY" || echo "PHASE 0 TOOLCHAIN: DEGRADED"
```

### 验证

```bash
bash /media/ok2049/work/work/paperclip-company-v2/phase0-regression-check.sh
# 预期：8 通过, 0 失败, "PHASE 0 TOOLCHAIN: HEALTHY"
```

---

## Execution Order

```
动作 1 (patch 文件)
  └─→ 动作 2 (C 模板 adapter.type)
        ├─→ 动作 5 (delete_company 缺口文档化)
        ├─→ 动作 7 (版本 pin)
        └─→ 动作 6 (环境清理)
              └─→ 动作 3 (config 自愈脚本)
                    └─→ 动作 4 (auto-reload 保活)
                          └─→ 动作 8 (回归门禁)
```

动作 3 和 4 最后做——先修好所有组件，最后让 config 自愈脚本把一切恢复到正确状态，再验证 auto-reload 生效。

---

## Constraints

- 所有变更必须在 git 控制下，或生成可重复应用的 patch 文件
- 不改 Hermes 源码（R11）
- 不改 paperclip upstream 工作树（R9）——用 patch 或独立 fork
- paperclip-mcp 版本 pin 死为 0.4.0（R10）
- 清理操作前先验证目标无交付物（不可逆操作确认）

## Acceptance (9 criteria)

| # | 验收标准 | 验证方式 |
|---|---|---|
| 1 | 三实例同时可用 | agent.log 显示 3 server(s), 0 failed |
| 2 | 写操作隔离零串扰 | 动作 8 的 T4 回归检查 |
| 3 | 重启 Hermes 后工具自动全注入 | 动作 8 的 T1/T3 回归检查 |
| 4 | MCP 含 delete_agent | 动作 8 的 T7 回归检查 |
| 5 | 环境干净无幽灵 | 动作 8 的 T8 回归检查 |
| 6 | 需求文档已补 R1-R4 | 文档存在且内容覆盖四项契约 |
| 7 | git pull upstream 后 403 修复仍在 | 动作 8 的 T5：grep 确认回退逻辑存在 |
| 8 | 三实例 paperclip-mcp 版本一致 | `uv run paperclip-mcp --version` 均输出 0.4.0 |
| 9 | 升级后 T1-T8 全绿 | `bash phase0-regression-check.sh` 输出 8 通过 0 失败 |

## Risks

| Risk | Mitigation |
|---|---|
| paperclip 大版本升级改 company-portability.ts 结构，patch 无法应用 | 动作 2 的模板防御层独立于后端，import 仍可成功 |
| paperclip-mcp 0.5.x 不再支持 delete_agent 注册语法 | delete_agent 是 MCP 标准工具注册，接口稳定；若变，动作 8 的 T7 检查会发现 |
| Hermes 不支持 startup hook | 备选：wrapper.sh 侧延迟发送 reload 信号；最坏情况手动 `/reload-mcp` |
| 幽灵 A 公司 123 issue 中有关键数据 | 删除前用 `list_issues` 检查 issue 内容，确认全部为 Phase 0 测试数据（`AC1-isolation-test-*` 等） |
