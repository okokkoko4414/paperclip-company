---
document_type: governance
version: V2.1
status: approved
---

# Deliverable Acceptance Criteria V2.1

Quantifiable quality gates for all Phase A deliverables. No more "feels right" reviews.

## P0 Criteria (Must All Pass — Any Single Failure = Reject)

### C1: SEO Misrepresentation Zero
- **Threshold**: 0 HIGH findings
- **Check**: grep for patterns indicating product features described as SEO
- **Command**: `grep -rni "SEO" --include="*.md" . | grep -v "GEO119\|GEO\|acceptance-criteria\|governance"`

### C2: GEO/SEO Conflation Zero
- **Threshold**: 0 occurrences of "SEO/GEO" or "SEO and GEO" used interchangeably
- **Check**: Verify GEO119 is never described as an SEO tool
- **Command**: `grep -rni "SEO.GEO\|SEO and GEO\|SEO & GEO" --include="*.md" .`

### C3: Core Fact Consistency
- **Threshold**: 0 inconsistencies across all deliverables
- **Facts**: Language=119 languages, Product name=GEO119, Positioning=AI Search Optimization, Business model=Prepaid, V1 Market=Vietnam
- **Check**: Manual review of core facts in each deliverable

### C4: Deliverable Completeness
- **Threshold**: All expected files exist AND each file > 200 bytes
- **Check**: `find . -name "*.md" -size -201c` returns empty (no files under 201 bytes)
- **Check**: Expected deliverable list matches actual files

### C7: Version Consistency
- **Threshold**: Final version line count ≥ draft version line count
- **Check**: For each file in 01-strategy/, verify line count ≥ corresponding file in 00-plans/ (if exists)

## P1 Criteria (Must Pass or Document as Known Limitation)

### C5: Semantic Quality
- **Threshold**: At least 3 h2 sections (##), ≥200 bytes per section, no placeholder text
- **Check**: `grep -c "^## " <file>` returns ≥ 3
- **Check**: No "TBD", "TODO", "lorem ipsum", "placeholder", "coming soon"

### C6: Link Validity
- **Threshold**: 0 broken internal links
- **Check**: All relative markdown links `[text](./path/to/file.md)` point to existing files
- **Command**: Extract all relative links and verify target exists

## Pass/Fail Rules

| Status | Condition |
|--------|-----------|
| **PASS** | All 5 P0 criteria pass AND all 2 P1 criteria pass |
| **CONDITIONAL PASS** | All 5 P0 criteria pass, P1 failures documented with reason |
| **FAIL** | Any P0 criterion fails |

## Running Validation

```bash
bash governance/acceptance_check.sh
```
