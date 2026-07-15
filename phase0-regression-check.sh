#!/bin/bash
# phase0-regression-check.sh — GEO119 Phase 0 工具链升级回归检查
set -e
PASS=0; FAIL=0
API="http://127.0.0.1:3100/api"
KEY="pcp_board_e65a40681143c73cda97a250ed4d21c8eb48a43427f089ab"
LOG=$(ls -t ~/.hermes/profiles/beta/logs/agent.log 2>/dev/null | head -1)
CO_A="a87ea87b-671f-4be4-a774-a5843029c28b"
CO_B="60eed204-4aca-41f2-9210-bba0b55e9127"
CO_C="d79258ba-fcc8-4968-b677-640e39fc3599"

echo "=== T1: agent.log 注册检查 ==="
if tail -200 "$LOG" 2>/dev/null | grep -q "registered.*from 3 server"; then echo "  PASS: T1"; PASS=$((PASS+1)); else echo "  FAIL: T1"; FAIL=$((FAIL+1)); fi

echo "=== T2: paperclip_a 无 env 格式错误 ==="
if ! tail -50 "$LOG" 2>/dev/null | grep -q "paperclip_a.*length 1"; then echo "  PASS: T2"; PASS=$((PASS+1)); else echo "  FAIL: T2"; FAIL=$((FAIL+1)); fi

echo "=== T3: 三实例工具全部注入 ==="
if tail -500 "$LOG" 2>/dev/null | grep -q "mcp__paperclip_a__list_issues"; then echo "  PASS: T3"; PASS=$((PASS+1)); else echo "  FAIL: T3"; FAIL=$((FAIL+1)); fi

echo "=== T4: 写操作隔离 (REST API) ==="
API="$API" KEY="$KEY" CO_A="$CO_A" CO_B="$CO_B" CO_C="$CO_C" python3 << 'PYEOF'
import json, urllib.request, time, os, sys
API=os.environ['API']; KEY=os.environ['KEY']
CO={'A':os.environ['CO_A'],'B':os.environ['CO_B'],'C':os.environ['CO_C']}
def api(u,b=None):
    d=json.dumps(b).encode() if b else None; r=urllib.request.Request(u,data=d,method='POST' if b else 'GET')
    r.add_header('Authorization','Bearer '+KEY); r.add_header('Content-Type','application/json')
    with urllib.request.urlopen(r,timeout=10) as resp: return json.loads(resp.read())
def titles(res):
    if isinstance(res,list): return [i.get('title','') for i in res]
    return [i.get('title','') for i in res.get('issues',res.get('data',[]))]
ts=str(int(time.time()))
for l,cid in CO.items():
    try: api(API+'/companies/'+cid+'/issues',{'title':'REGRESSION-T4-'+l+'-'+ts})
    except: pass
ok=True
for sl,scid in CO.items():
    try:
        st=titles(api(API+'/companies/'+scid+'/issues'))
        for tl in CO:
            if sl==tl: continue
            if any('REGRESSION-T4-'+tl+'-'+ts in t for t in st): ok=False
    except: ok=False
sys.exit(0 if ok else 1)
PYEOF
[ $? -eq 0 ] && { echo "  PASS: T4"; PASS=$((PASS+1)); } || { echo "  FAIL: T4"; FAIL=$((FAIL+1)); }

echo "=== T5: 后端 1 行修复仍在 ==="
if grep -q "frontmatter.adapterType" /home/ok2049/paperclip/server/src/services/company-portability.ts; then echo "  PASS: T5"; PASS=$((PASS+1)); else echo "  FAIL: T5"; FAIL=$((FAIL+1)); fi

echo "=== T6: 治理层交付物完好 ==="
SKILLS=$(ls /media/ok2049/work/work/paperclip-company-v2/agency-agents-v2/agency-agents/skills/*/SKILL.md 2>/dev/null | wc -l)
INJ=0
for a in ceo vp-engineering creative-director cmo vp-product vp-sales vp-operations game-dev-director chief-of-staff qa-director xr-director; do
  grep -q "委派规则\|审批责任\|升级路径" /media/ok2049/work/work/paperclip-company-v2/agency-agents-v2/agency-agents/agents/$a/AGENTS.md 2>/dev/null && INJ=$((INJ+1))
done
TEAMS=$(grep -rl "delegate-with-tree" /media/ok2049/work/work/paperclip-company-v2/agency-agents-v2/agency-agents/teams/*/TEAM.md 2>/dev/null | wc -l)
COMPANY=$(grep -c "Delegation Tree Convention\|Cross-Company Issue Coordination\|Quality Gates" /media/ok2049/work/work/paperclip-company-v2/agency-agents-v2/agency-agents/COMPANY.md 2>/dev/null)
[ "$SKILLS" -ge 4 ] && [ "$INJ" -ge 11 ] && [ "$TEAMS" -ge 10 ] && [ "$COMPANY" -ge 3 ] \
  && { echo "  PASS: T6"; PASS=$((PASS+1)); } || { echo "  FAIL: T6"; FAIL=$((FAIL+1)); }

echo "=== T7: delete_agent 已注册 ==="
T7OK=true
for inst in a b c; do
  grep -q "mcp.tool()(delete_agent)" "/media/ok2049/work/work/paperclip-mcp-v2/paperclip-mcp-v2-${inst}/src/paperclip_mcp/tools/agents.py" 2>/dev/null || T7OK=false
done
$T7OK && { echo "  PASS: T7"; PASS=$((PASS+1)); } || { echo "  FAIL: T7"; FAIL=$((FAIL+1)); }

echo "=== T8: 环境干净 ==="
API="$API" KEY="$KEY" CO_A="$CO_A" CO_B="$CO_B" CO_C="$CO_C" python3 << 'PYEOF'
import json,urllib.request,os,sys
API=os.environ['API']; KEY=os.environ['KEY']
OK_IDS=[os.environ['CO_A'],os.environ['CO_B'],os.environ['CO_C']]
req=urllib.request.Request(API+'/companies',headers={'Authorization':'Bearer '+KEY})
cs=json.loads(urllib.request.urlopen(req,timeout=10).read())
cs=cs if isinstance(cs,list) else cs.get('companies',[]); ok=True
ghosts=[c for c in cs if 'GEO119-Phase' in c.get('name','') and c.get('id','') not in OK_IDS]
if ghosts: print(f'GHOSTS: {[(c.get("name"),c.get("id")[:8]) for c in ghosts]}'); ok=False
sys.exit(0 if ok else 1)
PYEOF
[ $? -eq 0 ] && { echo "  PASS: T8"; PASS=$((PASS+1)); } || { echo "  FAIL: T8"; FAIL=$((FAIL+1)); }

echo "=== 结果: $PASS 通过, $FAIL 失败 ==="
[ "$FAIL" -eq 0 ] && echo "PHASE 0 TOOLCHAIN: HEALTHY" || echo "PHASE 0 TOOLCHAIN: DEGRADED"
exit $FAIL
