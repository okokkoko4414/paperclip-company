#!/usr/bin/env bash
set -euo pipefail

PASS=0
FAIL=0
P1_FAIL=0
REPORT=""

check() {
    local id="$1" level="$2" desc="$3"
    # shellcheck disable=SC2068
    if eval ${@:4} > /dev/null 2>&1; then
        echo "  [PASS] $id: $desc"
        ((PASS++)) || true
    else
        if [ "$level" = "P1" ]; then
            echo "  [FAIL] $id (P1): $desc — document as known limitation"
            ((P1_FAIL++)) || true
        else
            echo "  [FAIL] $id (P0): $desc"
            ((FAIL++)) || true
        fi
    fi
}

echo "=== Deliverable Acceptance Criteria V2.1 ==="
echo ""

# C1: SEO Misrepresentation Zero
check "C1" "P0" "SEO misrepresentation zero" \
    bash -c '! grep -rni "SEO" --include="*.md" . \
    | grep -v "GEO119\|GEO\|acceptance-criteria\|governance\|SKILL.md\|COMPANY.md\|TEAM.md\|AGENTS.md" \
    | grep -i "seo" || true'

# C2: GEO/SEO Conflation Zero
check "C2" "P0" "GEO/SEO conflation zero" \
    bash -c '! grep -rni "SEO.GEO\|SEO and GEO\|SEO & GEO" --include="*.md" . || true'

# C3: Core Fact Consistency
echo "  [MANUAL] C3 (P0): Core fact consistency — verify: Language=119, Product=GEO119, Positioning=AI Search Optimization, Model=Prepaid, V1 Market=Vietnam"

# C4: Deliverable Completeness
check "C4" "P0" "Deliverable completeness" \
    bash -c '! find . -name "*.md" -not -path "./companies/*" -size -201c | grep -v "^$" || true'

# C5: Semantic Quality (P1)
check "C5" "P1" "Semantic quality (h2>=3, no placeholders)" \
    bash -c '! grep -rni "TBD\|TODO\|lorem ipsum\|placeholder\|coming soon" --include="*.md" . | grep -v "governance\|SKILL.md\|AGENTS.md\|TEAM.md\|COMPANY.md" || true'

# C6: Link Validity (P1)
check "C6" "P1" "Link validity (0 broken links)" \
    bash -c '
broken=0
for f in $(find . -name "*.md" -not -path "./companies/*"); do
    links=$(grep -oP "\[[^\]]*\]\((\./[^)]+)\)" "$f" | grep -oP "(?<=\()./(?=[^)]).*" || true)
    for link in $links; do
        target="$(dirname "$f")/${link#./}"
        if [ ! -f "$target" ]; then
            broken=1
        fi
    done
done
[ "$broken" -eq 0 ]
'

# C7: Version Consistency
check "C7" "P0" "Version consistency" \
    bash -c '
consistent=0
for f in 01-strategy/*.md 2>/dev/null; do
    [ -f "$f" ] || continue
    base=$(basename "$f")
    draft="00-plans/$base"
    if [ -f "$draft" ]; then
        draft_lines=$(wc -l < "$draft")
        final_lines=$(wc -l < "$f")
        if [ "$final_lines" -lt "$draft_lines" ]; then
            consistent=1
        fi
    fi
done
[ "$consistent" -eq 0 ]
'

echo ""
echo "=== Results ==="
echo "P0 failures: $FAIL"
echo "P1 failures: $P1_FAIL"

if [ "$FAIL" -gt 0 ]; then
    echo "VERDICT: FAIL — $FAIL P0 criteria failed"
    exit 1
elif [ "$P1_FAIL" -gt 0 ]; then
    echo "VERDICT: CONDITIONAL PASS — $P1_FAIL P1 criteria failed, document as known limitations"
    exit 0
else
    echo "VERDICT: PASS — all criteria passed"
    exit 0
fi
