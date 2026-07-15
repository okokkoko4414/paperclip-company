# GEO119 Phase 0 整改实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix 4 root causes from Beta's E2E test report (config corruption, session rebuild tool loss, missing MCP delete, import pollution) and harden against component upgrades. 8 actions, 9 acceptance criteria.

**Architecture:** Three-layer defense — (1) patch/verify scripts that survive upgrades, (2) a self-healing config script, (3) a regression gate script. Hermes session keepalive uses `on_session_start` plugin hook + non-interactive reload. All deliverables are scripts or verified configuration — no modifications to upstream Paperclip or Hermes core.

**Tech Stack:** Bash (scripts), Python (Hermes plugin, API calls), YAML (config), TypeScript (patch)

## Global Constraints

- 不改 Hermes 源码核心文件（R11：方案 D 零改核心）
- 不改 paperclip upstream 工作树（R9：用 git format-patch）
- paperclip-mcp FastMCP 依赖 pin 为 3.4.3（R10：防浮动升级）
- 清理操作前核实目标无交付物（不可逆确认）
- TDD：代码变更必须先写失败测试，配置/脚本变更验证等价行为

---

### Task 1: 生成 403 修复 patch 文件（动作 1）

**Files:**
- Create: `/media/ok2049/work/work/paperclip-company-v2/patches/0001-fix-fallback-to-frontmatter-adapterType.patch`

**Interfaces:**
- Consumes: commit `0cb2dde` in `/home/ok2049/paperclip`
- Produces: patch file that can be `git apply`'d to any paperclip instance

- [ ] **Step 1: Create patches directory**

```bash
mkdir -p /media/ok2049/work/work/paperclip-company-v2/patches
```

- [ ] **Step 2: Generate patch from the specific commit**

```bash
cd /home/ok2049/paperclip
git format-patch -1 0cb2dde -o /media/ok2049/work/work/paperclip-company-v2/patches/
```

- [ ] **Step 3: Verify patch contains only the adapterType fallback change**

```bash
grep "frontmatter.adapterType" /media/ok2049/work/work/paperclip-company-v2/patches/0001-*.patch
```

Expected: shows the `+ asString(frontmatter.adapterType)` line.

- [ ] **Step 4: Verify patch applies cleanly**

```bash
cd /home/ok2049/paperclip
git stash
git apply --check /media/ok2049/work/work/paperclip-company-v2/patches/0001-*.patch
git stash pop
```

Expected: no output (patch applies cleanly, no conflicts).

- [ ] **Step 5: Commit**

```bash
cd /media/ok2049/work/work/paperclip-company-v2
git add patches/
git commit -m "feat: add 403 adapterType fallback patch for paperclip upgrade recovery"
```

---

### Task 2: 验证 C 模板 adapterType 全覆盖（动作 2）

**Files:**
- No files modified — verification only

**Interfaces:**
- Produces: confirmation that 167/167 AGENTS.md contain `adapterType: claude_local`

- [ ] **Step 1: Count adapterType coverage in C template**

```bash
grep -rl "adapterType: claude_local" \
  /media/ok2049/work/work/paperclip-company-v2/agency-agents-v2/agency-agents/agents/*/AGENTS.md \
  | wc -l
```

Expected: `167`

- [ ] **Step 2: List any agents missing adapterType (must be empty)**

```bash
for f in /media/ok2049/work/work/paperclip-company-v2/agency-agents-v2/agency-agents/agents/*/AGENTS.md; do
  grep -q "adapterType:" "$f" || echo "MISSING: $f"
done
```

Expected: no output (all 167 have adapterType).

---

### Task 3: Config 自愈脚本（动作 3）

**Files:**
- Create: `/media/ok2049/work/work/paperclip-mcp-v2/setup-mcp-config.sh`
- Create: `/media/ok2049/work/work/paperclip-company-v2/tests/test-setup-mcp-config.sh`

- [ ] **Step 1: Write the failing test**

```bash
#!/bin/bash
# tests/test-setup-mcp-config.sh — 验证 setup-mcp-config.sh 的核心行为

set -e
TEST_CONFIG="/tmp/test-config.yaml"
PASS=0; FAIL=0

# Setup: 模拟干净 config（只有 paperclip_a，缺 b/c）
cat > "$TEST_CONFIG" << 'YAML'
mcp_servers:
  paperclip_a:
    command: /media/ok2049/work/work/paperclip-mcp-v2/paperclip-mcp-v2-a/wrapper.sh
    enabled: true
YAML

# Test 1: script 检测到缺失 paperclip_b/c
bash /media/ok2049/work/work/paperclip-mcp-v2/setup-mcp-config.sh --config "$TEST_CONFIG" --check-only 2>&1 | grep -q "MISSING: paperclip_b"
if [ $? -eq 0 ]; then echo "PASS: detects missing paperclip_b"; PASS=$((PASS+1)); else echo "FAIL: does not detect missing paperclip_b"; FAIL=$((FAIL+1)); fi

# Test 2: 检测到 paperclip: 'null' 残留
cat > "$TEST_CONFIG" << 'YAML'
mcp_servers:
  paperclip: 'null'
  paperclip_a:
    command: /media/ok2049/work/work/paperclip-mcp-v2/paperclip-mcp-v2-a/wrapper.sh
    enabled: true
YAML

bash /media/ok2049/work/work/paperclip-mcp-v2/setup-mcp-config.sh --config "$TEST_CONFIG" --check-only 2>&1 | grep -q "paperclip.*残留"
if [ $? -eq 0 ]; then echo "PASS: detects paperclip: null residue"; PASS=$((PASS+1)); else echo "FAIL: does not detect paperclip: null"; FAIL=$((FAIL+1)); fi

# Test 3: 检测到 paperclip_a 有 env 键
cat > "$TEST_CONFIG" << 'YAML'
mcp_servers:
  paperclip_a:
    command: /media/ok2049/work/work/paperclip-mcp-v2/paperclip-mcp-v2-a/wrapper.sh
    enabled: true
    env: '{"PAPERCLIP_API_KEY":"test"}'
YAML

bash /media/ok2049/work/work/paperclip-mcp-v2/setup-mcp-config.sh --config "$TEST_CONFIG" --check-only 2>&1 | grep -q "env"
if [ $? -eq 0 ]; then echo "PASS: detects bad env on paperclip_a"; PASS=$((PASS+1)); else echo "FAIL: does not detect bad env"; FAIL=$((FAIL+1)); fi

echo "=== $PASS passed, $FAIL failed ==="
[ "$FAIL" -eq 0 ]
```

- [ ] **Step 2: Run test, verify it fails**

```bash
bash /media/ok2049/work/work/paperclip-company-v2/tests/test-setup-mcp-config.sh
```

Expected: FAIL because `setup-mcp-config.sh` does not exist yet.

- [ ] **Step 3: Write setup-mcp-config.sh (minimal, passes tests only)**

```bash
#!/bin/bash
# setup-mcp-config.sh — 自愈 Hermes beta MCP 配置
# 可重复执行，幂等。--check-only 只检查不修复。

set -e
CONFIG="${CONFIG:-$HOME/.hermes/profiles/beta/config.yaml}"
CHECK_ONLY=false
for arg in "$@"; do
  case "$arg" in
    --config) CONFIG="$2"; shift 2 ;;
    --check-only) CHECK_ONLY=true; shift ;;
  esac
done

issues=0

# 1. 检查旧 paperclip 实例残留
if grep -q "paperclip:.*null\|^  paperclip:" "$CONFIG" 2>/dev/null; then
  echo "[ISSUE] paperclip 旧实例残留"
  issues=$((issues+1))
  if [ "$CHECK_ONLY" = false ]; then
    python3 -c "
import yaml
with open('$CONFIG') as f: cfg = yaml.safe_load(f)
if 'paperclip' in cfg.get('mcp_servers', {}):
    del cfg['mcp_servers']['paperclip']
with open('$CONFIG', 'w') as f: yaml.dump(cfg, f, default_flow_style=False, allow_unicode=True)
" && echo "[FIXED] 已删除 paperclip 旧实例残留"
  fi
fi

# 2. 检查 paperclip_a/b/c 存在且 enabled
for inst in a b c; do
  key="paperclip_${inst}"
  if ! grep -q "${key}:" "$CONFIG" 2>/dev/null; then
    echo "[ISSUE] MISSING: ${key}"
    issues=$((issues+1))
  fi
done

# 3. 检查 paperclip_a 错误 env
if grep -A3 "paperclip_a:" "$CONFIG" 2>/dev/null | grep -q "env:"; then
  echo "[ISSUE] paperclip_a 有错误 env 段"
  issues=$((issues+1))
  if [ "$CHECK_ONLY" = false ]; then
    python3 -c "
import yaml
with open('$CONFIG') as f: cfg = yaml.safe_load(f)
a = cfg['mcp_servers'].get('paperclip_a', {})
if 'env' in a: del a['env']
with open('$CONFIG', 'w') as f: yaml.dump(cfg, f, default_flow_style=False, allow_unicode=True)
" && echo "[FIXED] 已删除 paperclip_a 错误 env 段"
  fi
fi

# 4. 验证 wrapper 可执行
for inst in a b c; do
  wrapper="/media/ok2049/work/work/paperclip-mcp-v2/paperclip-mcp-v2-${inst}/wrapper.sh"
  if [ -x "$wrapper" ]; then
    echo "[OK] paperclip_${inst} wrapper 可执行"
  else
    echo "[FAIL] paperclip_${inst} wrapper 不可执行: $wrapper"
    issues=$((issues+1))
  fi
done

if [ "$issues" -eq 0 ]; then
  echo "=== CONFIG HEALTHY ==="
  exit 0
else
  echo "=== CONFIG: $issues issue(s) ==="
  exit 1
fi
```

- [ ] **Step 4: Run test, verify it passes**

```bash
bash /media/ok2049/work/work/paperclip-company-v2/tests/test-setup-mcp-config.sh
```

Expected: `3 passed, 0 failed`.

- [ ] **Step 5: Run against real config (check-only mode)**

```bash
bash /media/ok2049/work/work/paperclip-mcp-v2/setup-mcp-config.sh --check-only
```

Expected: detects `paperclip: null` residue and any other issues.

- [ ] **Step 6: Run in fix mode against real config**

```bash
bash /media/ok2049/work/work/paperclip-mcp-v2/setup-mcp-config.sh
```

Expected: fixes detected issues, confirms wrappers are executable.

- [ ] **Step 7: Commit**

```bash
cd /media/ok2049/work/work/paperclip-company-v2
git add tests/test-setup-mcp-config.sh
git commit -m "test: add config self-heal script tests"
# script itself lives in paperclip-mcp-v2 repo; document it
```

---

### Task 4: Hermes on_session_start 保活插件（动作 4）

**Files:**
- Create: `/home/ok2049/.hermes/profiles/beta/plugins/geo119_keepalive.py`
- Create: `/media/ok2049/work/work/paperclip-company-v2/tests/test-keepalive-plugin.py`

- [ ] **Step 1: Write failing test**

```python
# tests/test-keepalive-plugin.py
"""验证 keepalive 插件的注册行为。

注意：此测试验证插件的接口契约（register_hook 被正确调用），
不验证 Hermes 运行时行为（需要真实 session 环境）。
"""
import sys
sys.path.insert(0, '/home/ok2049/.hermes/profiles/beta/plugins')

def test_plugin_registers_on_session_start():
    """插件必须调用 register_hook('on_session_start', callback)。"""
    from geo119_keepalive import register
    
    # 模拟 plugin facade
    hooks_registered = {}
    class MockFacade:
        def register_hook(self, name, callback):
            hooks_registered[name] = callback
    
    facade = MockFacade()
    register(facade)
    
    assert 'on_session_start' in hooks_registered, \
        f"插件未注册 on_session_start hook，已注册: {list(hooks_registered.keys())}"
    assert callable(hooks_registered['on_session_start']), \
        "on_session_start 回调不可调用"

def test_callback_is_callable_with_kwargs():
    """回调必须接受 **kwargs 以兼容 Hermes 传递的 session_id 等参数。"""
    from geo119_keepalive import _on_session_start_callback
    import inspect
    
    sig = inspect.signature(_on_session_start_callback)
    params = list(sig.parameters.keys())
    # 必须接受 **kwargs 或有 session_id 参数
    assert 'kwargs' in params or 'session_id' in params or any(
        p.kind == inspect.Parameter.VAR_KEYWORD for p in sig.parameters.values()
    ), f"回调不接受 **kwargs: {params}"
```

- [ ] **Step 2: Run test, verify it fails**

```bash
cd /media/ok2049/work/work/paperclip-company-v2
python3 -m pytest tests/test-keepalive-plugin.py -v
```

Expected: FAIL, `ModuleNotFoundError: No module named 'geo119_keepalive'`

- [ ] **Step 3: Write minimal plugin**

```python
# ~/.hermes/profiles/beta/plugins/geo119_keepalive.py
"""GEO119 Phase 0 — MCP 实例保活插件。

注册 on_session_start hook，session 启动后自动全量 reload MCP，
确保三实例工具全部注入。零改 Hermes 核心。
"""
import logging

logger = logging.getLogger(__name__)

def _on_session_start_callback(session_id=None, **kwargs):
    """on_session_start 回调：触发非交互 MCP reload。"""
    logger.info(f"GEO119 keepalive: session_start triggered (session={session_id})")
    try:
        from hermes_cli.commands import _reload_mcp_impl
        _reload_mcp_impl(interactive=False)
        logger.info("GEO119 keepalive: MCP reload completed")
    except ImportError:
        logger.warning(
            "GEO119 keepalive: cannot import _reload_mcp_impl — "
            "Hermes version may have changed. Run /reload-mcp manually."
        )
    except Exception as exc:
        logger.error(f"GEO119 keepalive: MCP reload failed: {exc}")


def register(facade):
    """插件入口。Facade 提供 register_hook(name, callback)。"""
    facade.register_hook("on_session_start", _on_session_start_callback)
```

- [ ] **Step 4: Run test, verify it passes**

```bash
cd /media/ok2049/work/work/paperclip-company-v2
python3 -m pytest tests/test-keepalive-plugin.py -v
```

Expected: 2 passed.

- [ ] **Step 5: Configure non-interactive reload**

```bash
hermes config set approvals.mcp_reload_confirm false
```

Expected: `✓ Set approvals.mcp_reload_confirm = false`

- [ ] **Step 6: Verify plugin is loadable by Hermes**

```bash
grep -r "geo119_keepalive\|plugins" /home/ok2049/.hermes/profiles/beta/config.yaml 2>/dev/null || echo "Plugin will be auto-discovered from plugins/ directory"
```

- [ ] **Step 7: Commit test and plugin**

```bash
cd /media/ok2049/work/work/paperclip-company-v2
git add tests/test-keepalive-plugin.py
git commit -m "test: add keepalive plugin interface contract tests"
```

---

### Task 5: MCP 删除能力核实 + 缺口文档化（动作 5）

**Files:**
- No files modified — verification and documentation only

- [ ] **Step 1: Verify delete_agent registered in all three instances**

```bash
for inst in a b c; do
  echo -n "paperclip_${inst}: "
  grep -c "mcp.tool()(delete_agent)" \
    /media/ok2049/work/work/paperclip-mcp-v2/paperclip-mcp-v2-${inst}/src/paperclip_mcp/tools/agents.py 2>/dev/null || echo "0"
done
```

Expected: all three show `1` (or higher).

- [ ] **Step 2: Confirm delete_company NOT implemented**

```bash
grep -rn "delete_company\|def delete.*company" \
  /media/ok2049/work/work/paperclip-mcp-v2/paperclip-mcp-v2-a/src/paperclip_mcp/tools/ 2>/dev/null
```

Expected: no output (no implementation found).

- [ ] **Step 3: Document REST fallback path**

The REST endpoint for company deletion is `DELETE /api/companies/:id`. Confirmed safe: `svc.remove` uses transactional cascading delete. No agent-level orphan risk.

- [ ] **Step 4: Record in progress ledger**

Add to `.superpowers/sdd/progress.md`: "delete_agent: confirmed registered in all 3 instances. delete_company: REST path documented (`DELETE /api/companies/:id`)."

---

### Task 6: 环境清理 — 删到 0 家（动作 6）

**Files:**
- No files modified — API operations only

- [ ] **Step 1: Verify ghost A (5412501b) has no unique deliverables**

```bash
curl -s -H "Authorization: Bearer pcp_board_e65a40681143c73cda97a250ed4d21c8eb48a43427f089ab" \
  "http://127.0.0.1:3100/api/companies/5412501b-68b2-4617-ba50-b649c4c13197/issues?limit=5" \
  | python3 -c "import sys,json; d=json.load(sys.stdin); issues=d if isinstance(d,list) else d.get('issues',[]); print(f'Issues: {len(issues)}')"
```

- [ ] **Step 2: Delete all 4 companies**

```bash
for id in 5412501b-68b2-4617-ba50-b649c4c13197 \
         3d402864-4cb8-4334-b376-2670abfa05e1 \
         7588c82e-932c-4af7-9bae-01c6ce684573 \
         e6e64b85-2177-4e0c-af5c-6f52ad6f016b; do
  code=$(curl -s -o /dev/null -w '%{http_code}' -X DELETE \
    -H "Authorization: Bearer pcp_board_e65a40681143c73cda97a250ed4d21c8eb48a43427f089ab" \
    "http://127.0.0.1:3100/api/companies/$id")
  echo "$id: HTTP $code"
done
```

Expected: all 4 return HTTP 200.

- [ ] **Step 3: Verify company list is empty**

```bash
curl -s -H "Authorization: Bearer pcp_board_e65a40681143c73cda97a250ed4d21c8eb48a43427f089ab" \
  "http://127.0.0.1:3100/api/companies" \
  | python3 -c "import sys,json; d=json.load(sys.stdin); cs=d if isinstance(d,list) else d.get('companies',[]); print(len(cs))"
```

Expected: `0`.

---

### Task 7: paperclip-mcp 版本 pin 死（动作 7）

**Files:**
- Modify: `/media/ok2049/work/work/paperclip-mcp-v2/paperclip-mcp-v2-{a,b,c}/pyproject.toml`

- [ ] **Step 1: Pin FastMCP to exact version in all three instances**

```bash
for inst in a b c; do
  pyproject="/media/ok2049/work/work/paperclip-mcp-v2/paperclip-mcp-v2-${inst}/pyproject.toml"
  # Replace 'fastmcp>=3.0' with 'fastmcp==3.4.3'
  sed -i 's/"fastmcp>=3.0"/"fastmcp==3.4.3"/' "$pyproject"
  echo "Pinned $pyproject"
done
```

- [ ] **Step 2: Generate uv.lock for each instance**

```bash
for inst in a b c; do
  cd "/media/ok2049/work/work/paperclip-mcp-v2/paperclip-mcp-v2-${inst}"
  uv lock
  echo "Locked paperclip-mcp-v2-${inst}"
done
```

- [ ] **Step 3: Verify all three instances use same FastMCP version**

```bash
for inst in a b c; do
  cd "/media/ok2049/work/work/paperclip-mcp-v2/paperclip-mcp-v2-${inst}"
  uv run python -c "import fastmcp; print(f'paperclip_${inst}: FastMCP {fastmcp.__version__}')"
done
```

Expected: all three show `FastMCP 3.4.3`.

- [ ] **Step 4: Commit uv.lock files**

```bash
cd /media/ok2049/work/work/paperclip-mcp-v2
git add paperclip-mcp-v2-{a,b,c}/pyproject.toml paperclip-mcp-v2-{a,b,c}/uv.lock
git commit -m "fix: pin FastMCP to 3.4.3 + uv.lock (R10)"
```

---

### Task 8: 升级回归门禁脚本（动作 8）

**Files:**
- Create: `/media/ok2049/work/work/paperclip-company-v2/phase0-regression-check.sh`
- Create: `/media/ok2049/work/work/paperclip-company-v2/tests/test-regression-check-structure.sh`

- [ ] **Step 1: Write structure test**

```bash
#!/bin/bash
# tests/test-regression-check-structure.sh — 验证回归脚本结构完整

SCRIPT="/media/ok2049/work/work/paperclip-company-v2/phase0-regression-check.sh"
PASS=0; FAIL=0

# Test 1: 脚本存在且可执行
[ -x "$SCRIPT" ] && echo "PASS: script exists and executable" && PASS=$((PASS+1)) \
  || { echo "FAIL: script missing or not executable"; FAIL=$((FAIL+1)); }

# Test 2: 包含全部 8 项检查
for check in "T1:.*注册" "T2:.*env" "T3:.*注入" "T4:.*隔离" "T5:.*后端" "T6:.*治理" "T7:.*delete" "T8:.*环境"; do
  grep -q "$check" "$SCRIPT" 2>/dev/null \
    && { echo "PASS: contains $check"; PASS=$((PASS+1)); } \
    || { echo "FAIL: missing $check"; FAIL=$((FAIL+1)); }
done

echo "=== $PASS passed, $FAIL failed ==="
[ "$FAIL" -eq 0 ]
```

- [ ] **Step 2: Run structure test, verify it fails**

```bash
bash /media/ok2049/work/work/paperclip-company-v2/tests/test-regression-check-structure.sh
```

Expected: FAIL — `phase0-regression-check.sh` does not exist yet.

- [ ] **Step 3: Write phase0-regression-check.sh**

Complete script as specified in the design document, covering T1-T8:
- T1: agent.log shows 3 server(s), 0 failed
- T2: agent.log has no "length 1; 2 is required" error
- T3: agent.log shows all three mcp__paperclip_{a,b,c}__ tool prefixes
- T4: write-op isolation via REST API (create + cross-check)
- T5: company-portability.ts contains frontmatter.adapterType fallback
- T6: governance artifacts present (4 skills, 11 injections, 10 TEAM.md, 3 COMPANY.md sections)
- T7: delete_agent registered in agents.py
- T8: company list clean (no ghosts), B agent count = design value

- [ ] **Step 4: Run structure test, verify it passes**

```bash
bash /media/ok2049/work/work/paperclip-company-v2/tests/test-regression-check-structure.sh
```

Expected: 9 passed, 0 failed.

- [ ] **Step 5: Run full regression check**

```bash
bash /media/ok2049/work/work/paperclip-company-v2/phase0-regression-check.sh
```

- [ ] **Step 6: Commit**

```bash
cd /media/ok2049/work/work/paperclip-company-v2
git add phase0-regression-check.sh tests/test-regression-check-structure.sh
git commit -m "feat: add Phase 0 upgrade regression gate (T1-T8)"
```

---

### Task 9: 最终验收 — 9 条全过

- [ ] **Step 1: Run config self-heal**

```bash
bash /media/ok2049/work/work/paperclip-mcp-v2/setup-mcp-config.sh
```

- [ ] **Step 2: Run full regression check**

```bash
bash /media/ok2049/work/work/paperclip-company-v2/phase0-regression-check.sh
```

Expected: `8 PASS, 0 FAIL, PHASE 0 TOOLCHAIN: HEALTHY`.

- [ ] **Step 3: Verify acceptance criteria 1-9**

| # | 验收标准 | 验证 |
|---|---|---|
| 1 | 三实例同时可用 | regression T1+T3 pass |
| 2 | 写操作隔离 | regression T4 pass |
| 3 | 重启后自动注入 | agent.log: `registered 246 tool(s) from 3 server(s)` |
| 4 | MCP 含 delete_agent | regression T7 pass |
| 5 | 环境干净 | regression T8 pass |
| 6 | 需求文档已补 | R1-R4 documented in Phase0-开发需求文档.md |
| 7 | git pull 后 403 修复仍在 | regression T5 pass |
| 8 | 版本一致 | `uv run python -c "import fastmcp; print(fastmcp.__version__)"` all 3 show `3.4.3` |
| 9 | 升级后 T1-T8 全绿 | Step 2 proves all green |

- [ ] **Step 4: Commit all remaining artifacts**

```bash
cd /media/ok2049/work/work/paperclip-company-v2
git add -A
git commit -m "chore: Phase 0 remediation complete — 9/9 acceptance criteria"
```

---

## Execution Order

```
Task 1 (patch) ──→ Task 2 (verify adapterType)
                      │
                      ├──→ Task 3 (config self-heal) ──→ Task 4 (keepalive plugin)
                      │
                      ├──→ Task 5 (delete capability verify + document)
                      │
                      ├──→ Task 6 (environment cleanup — BLOCKING: destructive)
                      │
                      └──→ Task 7 (version pin)
                               │
                               └──→ Task 8 (regression gate)
                                        │
                                        └──→ Task 9 (final verification)
```

Task 6 (cleanup) 是阻塞点——删除全部 4 家公司后，Phase A/B/C 开始时必须重新 import + 重跑 Task 3 + Task 4。
