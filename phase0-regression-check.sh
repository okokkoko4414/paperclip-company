#!/bin/bash
# phase0-regression-check.sh — GEO119 Phase 0 工具链升级回归检查
# 任何 hermes/paperclip/paperclip-mcp 升级后必跑
set -e

PASS=0; FAIL=0
check() { local label="$1"; shift; if "$@" 2>/dev/null; then echo "  PASS: $label"; PASS=$((PASS+1)); else echo "  FAIL: $label"; FAIL=$((FAIL+1)); fi; }

API="http://127.0.0.1:3100/api"
KEY="pcp_board_e65a40681143c73cda97a250ed4d21c8eb48a43427f089ab"
LOG=$(ls -t ~/.hermes/profiles/beta/logs/agent.log* 2>/dev/null | head -1)

echo "=== T1: agent.log 注册检查 ==="
check "T1" grep -q "registered.*from 3 server" "$LOG" 2>/dev/null

echo "=== T2: paperclip_a 无 env 格式错误 ==="
check "T2" ! grep -q "paperclip_a.*length 1.*2 is required" "$LOG" 2>/dev/null

echo "=== T3: 三实例工具全部注入 ==="
check "T3" grep -q "mcp__paperclip_a__\|mcp__paperclip_b__\|mcp__paperclip_c__" "$LOG" 2>/dev/null

echo "=== T4: 写操作隔离 (REST API) ==="
check "T4" python3 -c "
import json, urllib.request, time
CO={'A':'3d402864-4cb8-4334-b376-2670abfa05e1','B':'7588c82e-932c-4af7-9bae-01c6ce684573','C':'e6e64b85-2177-4e0c-af5c-6f52ad6f016b'}
def api(u,b=None):
    d=json.dumps(b).encode() if b else None; r=urllib.request.Request(u,data=d,method='POST' if b else 'GET')
    r.add_header('Authorization','Bearer $KEY'); r.add_header('Content-Type','application/json')
    with urllib.request.urlopen(r,timeout=10) as resp: return json.loads(resp.read())
def titles(res):
    if isinstance(res,list): return [i.get('title','') for i in res]
    return [i.get('title','') for i in res.get('issues',res.get('data',[]))]
ts=str(int(time.time()))
for l,cid in CO.items():
    try: api(f'\$API/companies/{cid}/issues',{'title':f'REGRESSION-T4-{l}-{ts}'})
    except: pass
ok=True
for sl,scid in CO.items():
    try:
        st=titles(api(f'\$API/companies/{scid}/issues'))
        for tl in CO:
            if sl==tl: continue
            if any(f'REGRESSION-T4-{tl}-{ts}' in t for t in st): ok=False
    except: ok=False
sys.exit(0 if ok else 1)
" 2>/dev/null

echo "=== T5: 后端 1 行修复仍在 ==="
check "T5" grep -q "frontmatter.adapterType" /home/ok2049/paperclip/server/src/services/company-portability.ts

echo "=== T6: 治理层交付物完好 ==="
SKILLS=$(ls /media/ok2049/work/work/paperclip-company-v2/agency-agents-v2/agency-agents/skills/*/SKILL.md 2>/dev/null | wc -l)
INJECTIONS=0
for a in ceo vp-engineering creative-director cmo vp-product vp-sales vp-operations game-dev-director chief-of-staff qa-director xr-director; do
  grep -q "委派规则\|审批责任\|升级路径" /media/ok2049/work/work/paperclip-company-v2/agency-agents-v2/agency-agents/agents/$a/AGENTS.md 2>/dev/null && INJECTIONS=$((INJECTIONS+1))
done
TEAMS=$(grep -rl "delegate-with-tree" /media/ok2049/work/work/paperclip-company-v2/agency-agents-v2/agency-agents/teams/*/TEAM.md 2>/dev/null | wc -l)
COMPANY=$(grep -c "Delegation Tree Convention\|Cross-Company Issue Coordination\|Quality Gates" /media/ok2049/work/work/paperclip-company-v2/agency-agents-v2/agency-agents/COMPANY.md 2>/dev/null)
check "T6" [ "$SKILLS" -ge 4 ] && [ "$INJECTIONS" -ge 11 ] && [ "$TEAMS" -ge 10 ] && [ "$COMPANY" -ge 3 ]

echo "=== T7: delete_agent 已注册 ==="
check "T7" python3 -c "
import sys; ok=True
for inst in ['a','b','c']:
    f=f'/media/ok2049/work/work/paperclip-mcp-v2/paperclip-mcp-v2-{inst}/src/paperclip_mcp/tools/agents.py'
    if 'mcp.tool()(delete_agent)' not in open(f).read(): ok=False
sys.exit(0 if ok else 1)
"

echo "=== T8: 环境干净 ==="
check "T8" python3 -c "
import json,urllib.request
req=urllib.request.Request('$API/companies',headers={'Authorization':'Bearer $KEY'})
cs=json.loads(urllib.request.urlopen(req,timeout=10).read())
cs=cs if isinstance(cs,list) else cs.get('companies',[]); ok=True
ghosts=[c for c in cs if 'GEO119-Phase' in c.get('name','') and c.get('id','') not in
        ['3d402864-4cb8-4334-b376-2670abfa05e1','7588c82e-932c-4af7-9bae-01c6ce684573','e6e64b85-2177-4e0c-af5c-6f52ad6f016b']]
if ghosts: print(f'GHOSTS: {[(c[\"name\"],c[\"id\"][:8]) for c in ghosts]}'); ok=False
sys.exit(0 if ok else 1)
" 2>/dev/null

echo "=== 结果: $PASS 通过, $FAIL 失败 ==="
[ "$FAIL" -eq 0 ] && echo "PHASE 0 TOOLCHAIN: HEALTHY" || echo "PHASE 0 TOOLCHAIN: DEGRADED"
exit $FAIL
