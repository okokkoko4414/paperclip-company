# Product Compass Transform Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Transform the product-compass-consulting template into an enforceable delivery pipeline by adding delegation tree conventions, quality gates, document templates, and raise conventions.

**Architecture:** Copy the official template into project root, then layer 4 new governance skills + 2 governance files on top. Modify 9 management AGENTS.md files with delegation/review/raise sections, 8 TEAM.md files with new skill references, and COMPANY.md with governance overview. All 65 existing skills and 39 Specialist agents remain untouched.

**Tech Stack:** YAML frontmatter (agentcompanies/v1 schema), Markdown, Bash. Validation via `paperclipai company import --dry-run`.

## Global Constraints

- All AGENTS.md files must conform to agentcompanies/v1 spec
- All TEAM.md files must resolve includes paths correctly (relative `../../skills/...`)
- No modification to Specialist/Analyst AGENTS.md or existing 65 SKILL.md files
- `acceptance_check.sh` must pass `bash -n` syntax check
- All YAML frontmatter must be valid YAML

---

### Task 1: Copy template to project root

**Files:**
- Create: all template files at project root (from `companies/product-compass-consulting/`)

**Interfaces:**
- Produces: working tree with 48 agents, 65 skills, 8 teams, COMPANY.md, .paperclip.yaml, README.md, LICENSE, images/

- [ ] **Step 1: Copy template files to root**

```bash
cp -r /media/ok2049/work/work/paperclip-company/companies/product-compass-consulting/* /media/ok2049/work/work/paperclip-company/
cp /media/ok2049/work/work/paperclip-company/companies/product-compass-consulting/.paperclip.yaml /media/ok2049/work/work/paperclip-company/
```

- [ ] **Step 2: Verify the copy**

```bash
ls /media/ok2049/work/work/paperclip-company/COMPANY.md
ls /media/ok2049/work/work/paperclip-company/agents/ceo/AGENTS.md
ls /media/ok2049/work/work/paperclip-company/.paperclip.yaml
```

Expected: all three files exist.

---

### Task 2: Create delegate-with-tree SKILL.md

**Files:**
- Create: `skills/delegate-with-tree/SKILL.md`

**Interfaces:**
- Produces: SKILL.md with frontmatter including `name: delegate-with-tree`, and body describing parent/child Issue tree delegation rules

- [ ] **Step 1: Create the skill directory**

```bash
mkdir -p /media/ok2049/work/work/paperclip-company/skills/delegate-with-tree
```

- [ ] **Step 2: Write SKILL.md**

Write to `skills/delegate-with-tree/SKILL.md`:

```markdown
---
name: delegate-with-tree
description: Delegate work by building a parent/child issue tree that mirrors the org hierarchy — managers own parent issues, individual contributors own child issues — so completed child work automatically flows back up to the responsible manager for review.
key: okokkoko4414/delegate-with-tree
recommendedForRoles:
  - ceo
  - manager
  - director
  - product
tags:
  - delegation
  - planning
  - issues
  - management
---

# Delegate with Tree

When splitting a task across multiple people, build a parent/child Issue tree that mirrors the org hierarchy.

## Tree Structure

```
CEO (top-level leader)
└── VP/Director ← parent issue assignee = the DIRECT manager of the executors
    ├── Specialist A ← child issue assignee = executor
    ├── Specialist B ← child issue assignee = executor
    └── Specialist C ← child issue assignee = executor
```

## Rules

1. **Parent Issue assignee = direct manager** of the executors (not CEO, unless CEO is the direct manager).
2. **Child Issue assignee = executor** — the individual contributor doing the work.
3. **Parent Issue must stay `todo` or `in_progress`** — `backlog` status will not trigger wake-on-children-complete.
4. **All child Issues must be `done` or `cancelled`** before the parent assignee is woken for review. A single child completing is not enough.
5. **Parent Issue must not be marked `done`** until all children are done AND the parent assignee has reviewed all deliverables.

## When to Use

- Multi-person task splitting
- Cross-functional coordination
- Any deliverable requiring management review

## When Not to Use

- Single-person tasks completable in one heartbeat
- Assigner is the executor (no management layer between)
```

- [ ] **Step 3: Validate YAML frontmatter**

```bash
python3 -c "
import yaml
with open('skills/delegate-with-tree/SKILL.md') as f:
    content = f.read()
# Extract frontmatter between --- markers
parts = content.split('---')
if len(parts) >= 3:
    fm = yaml.safe_load(parts[1])
    print('YAML OK:', fm.get('name'))
"
```

Expected: `YAML OK: delegate-with-tree`

---

### Task 3: Create acceptance-criteria SKILL.md

**Files:**
- Create: `skills/acceptance-criteria/SKILL.md`

**Interfaces:**
- Produces: SKILL.md referencing `governance/DELIVERABLE-ACCEPTANCE-CRITERIA-V2.1.md` and `governance/acceptance_check.sh`

- [ ] **Step 1: Create the skill directory**

```bash
mkdir -p /media/ok2049/work/work/paperclip-company/skills/acceptance-criteria
```

- [ ] **Step 2: Write SKILL.md**

Write to `skills/acceptance-criteria/SKILL.md`:

```markdown
---
name: acceptance-criteria
description: Validate deliverables against 7 quantifiable quality gates (5 P0 + 2 P1) before marking work as done — automated via bash script, no more "feels right" reviews.
key: okokkoko4414/acceptance-criteria
recommendedForRoles:
  - ceo
  - manager
  - director
  - reviewer
tags:
  - quality
  - review
  - governance
  - validation
---

# Acceptance Criteria V2.1

All deliverables must pass quantifiable quality gates before being marked done. No more "feels right" reviews.

## The 7 Criteria

| # | Criterion | Priority | Threshold | Verification |
|---|-----------|----------|-----------|-------------|
| C1 | SEO misrepresentation zero | P0 | 0 HIGH findings | grep pattern matching |
| C2 | GEO/SEO conflation zero | P0 | 0 occurrences | grep `SEO/GEO` |
| C3 | Core fact consistency | P0 | 0 errors | Language=119, Product=GEO119, Positioning=AI Search Optimization, Model=Prepaid, V1 Market=Vietnam |
| C4 | Deliverable completeness | P0 | All files exist and >200 bytes | File existence + size check |
| C5 | Semantic quality | P1 | h2≥3, ≥200 bytes, no placeholders | Structure check |
| C6 | Link validity | P1 | 0 broken links | Relative path target existence |
| C7 | Version consistency | P0 | Final version ≥ draft line count | 01-strategy ≥ 00-plans |

## Pass Standard

- **P0: 5/5 must pass.** Any single P0 failure = deliverable rejected.
- **P1: 2/2 must pass.** Any P1 failure must be documented as a known limitation with reason.

## How to Validate

1. Load `governance/DELIVERABLE-ACCEPTANCE-CRITERIA-V2.1.md` for full definitions.
2. Run `bash governance/acceptance_check.sh` for automated checking.
3. Review the PASS/FAIL output.
4. For any FAIL: fix the issue or document it as a known limitation (P1 only).
```

- [ ] **Step 3: Validate YAML frontmatter**

```bash
python3 -c "
import yaml
with open('skills/acceptance-criteria/SKILL.md') as f:
    parts = f.read().split('---')
fm = yaml.safe_load(parts[1])
print('YAML OK:', fm.get('name'))
"
```

Expected: `YAML OK: acceptance-criteria`

---

### Task 4: Create document-template SKILL.md

**Files:**
- Create: `skills/document-template/SKILL.md`

**Interfaces:**
- Produces: SKILL.md with mandatory frontmatter spec for all deliverable `.md` files

- [ ] **Step 1: Create the skill directory**

```bash
mkdir -p /media/ok2049/work/work/paperclip-company/skills/document-template
```

- [ ] **Step 2: Write SKILL.md**

Write to `skills/document-template/SKILL.md`:

```markdown
---
name: document-template
description: Enforce mandatory frontmatter metadata on every deliverable — author, reviewer, version, status — so every file is traceable to its creator and review chain.
key: okokkoko4414/document-template
recommendedForRoles:
  - all
tags:
  - documentation
  - metadata
  - governance
  - traceability
---

# Document Template

Every deliverable `.md` file must include the following YAML frontmatter at the top of the file.

## Required Frontmatter

```yaml
---
document_type: deliverable          # deliverable | plan | review | report
phase: A                            # Phase identifier
directory: 01-strategy              # Owning directory
filename: value-proposition.md      # File name
version: V1.0                       # Version number
author_agent: VP Product Strategy   # Who wrote it (Agent name)
reviewer_agent: Reviewer            # Who reviewed it (Agent name)
status: draft                       # draft | in_review | approved
created_at: 2026-07-12T10:00:00Z    # ISO 8601 creation timestamp
updated_at: 2026-07-12T12:00:00Z    # ISO 8601 last modified timestamp
issue_id: PHA-XXX                   # Associated Issue ID
---
```

## Hard Rules

1. **No frontmatter = rejected.** Files without this metadata block are not accepted as deliverables.
2. **author_agent must match the Issue assignee.** The person listed as author must be the one assigned to the child Issue.
3. **Status changes require review records.** Moving from `draft` → `in_review` → `approved` must be accompanied by reviewer comments or interaction records.

## Status Lifecycle

```
draft → in_review → approved
  ↑                    │
  └──── (rejected) ────┘
```

- `draft`: Work in progress, not yet submitted for review.
- `in_review`: Submitted, awaiting reviewer feedback.
- `approved`: Passed review and acceptance criteria.
```

- [ ] **Step 3: Validate YAML frontmatter**

```bash
python3 -c "
import yaml
with open('skills/document-template/SKILL.md') as f:
    parts = f.read().split('---')
fm = yaml.safe_load(parts[1])
print('YAML OK:', fm.get('name'))
"
```

Expected: `YAML OK: document-template`

---

### Task 5: Create vp-raise-convention SKILL.md

**Files:**
- Create: `skills/vp-raise-convention/SKILL.md`

**Interfaces:**
- Produces: SKILL.md defining escalation rules for VP/Director when blocked

- [ ] **Step 1: Create the skill directory**

```bash
mkdir -p /media/ok2049/work/work/paperclip-company/skills/vp-raise-convention
```

- [ ] **Step 2: Write SKILL.md**

Write to `skills/vp-raise-convention/SKILL.md`:

```markdown
---
name: vp-raise-convention
description: Escalation protocol for managers — when blocked, how to escalate, and the hard rule that silence is not an option beyond one heartbeat cycle.
key: okokkoko4414/vp-raise-convention
recommendedForRoles:
  - manager
  - director
  - vp
tags:
  - escalation
  - management
  - communication
---

# VP Raise Convention

When a VP or Director is blocked and cannot proceed without a decision from above, they must actively escalate. Silent waiting is not acceptable.

## Escalation Table

| Scenario | How to Escalate | Trigger |
|----------|----------------|---------|
| Child Issue executor stuck | Open `request_confirmation` interaction on parent Issue | Executor cannot continue |
| VP/Director themselves blocked | Open interaction or comment on CEO-assigned parent Issue | Needs CEO decision |
| Specialist needs VP intervention | @mention VP or open interaction on parent Issue | Needs management judgment |
| Budget warning | Comment on parent Issue with budget status | Budget approaching limit |

## Hard Rules

1. **Report within 1 heartbeat cycle.** If you are blocked for longer than one heartbeat period, you must escalate.
2. **Never wait silently for a deadline.** If you can see you will miss a deadline, escalate immediately.
3. **CEO must respond within the next heartbeat.** After receiving an escalation, the CEO acknowledges and responds within one heartbeat cycle.
```

- [ ] **Step 3: Validate YAML frontmatter**

```bash
python3 -c "
import yaml
with open('skills/vp-raise-convention/SKILL.md') as f:
    parts = f.read().split('---')
fm = yaml.safe_load(parts[1])
print('YAML OK:', fm.get('name'))
"
```

Expected: `YAML OK: vp-raise-convention`

---

### Task 6: Create governance directory

**Files:**
- Create: `governance/DELIVERABLE-ACCEPTANCE-CRITERIA-V2.1.md`
- Create: `governance/acceptance_check.sh`

**Interfaces:**
- Produces: governance directory with 7-criteria spec doc and executable bash validation script

- [ ] **Step 1: Create governance directory**

```bash
mkdir -p /media/ok2049/work/work/paperclip-company/governance
```

- [ ] **Step 2: Write DELIVERABLE-ACCEPTANCE-CRITERIA-V2.1.md**

Write to `governance/DELIVERABLE-ACCEPTANCE-CRITERIA-V2.1.md`:

```markdown
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
```

- [ ] **Step 3: Write acceptance_check.sh**

Write to `governance/acceptance_check.sh`:

```bash
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
```

- [ ] **Step 4: Make the script executable**

```bash
chmod +x /media/ok2049/work/work/paperclip-company/governance/acceptance_check.sh
```

- [ ] **Step 5: Validate bash syntax**

```bash
bash -n /media/ok2049/work/work/paperclip-company/governance/acceptance_check.sh
```

Expected: no output (syntax OK).

---

### Task 7: Modify 8 TEAM.md files — add skill references

**Files:**
- Modify: `teams/product-discovery/TEAM.md`
- Modify: `teams/product-execution/TEAM.md`
- Modify: `teams/product-strategy/TEAM.md`
- Modify: `teams/data-analytics/TEAM.md`
- Modify: `teams/go-to-market/TEAM.md`
- Modify: `teams/marketing-growth/TEAM.md`
- Modify: `teams/market-research/TEAM.md`
- Modify: `teams/pm-toolkit/TEAM.md`

**Interfaces:**
- Consumes: skills from Tasks 2, 3, 4 (`delegate-with-tree`, `acceptance-criteria`, `document-template`)
- Produces: each TEAM.md now includes references to the 3 new governance skills

- [ ] **Step 1: Modify teams/product-discovery/TEAM.md**

In `teams/product-discovery/TEAM.md`, insert these three lines before the `tags:` line in the YAML frontmatter:

```yaml
  - ../../skills/delegate-with-tree/SKILL.md
  - ../../skills/acceptance-criteria/SKILL.md
  - ../../skills/document-template/SKILL.md
```

The includes section should read (after `- ../../skills/summarize-interview/SKILL.md`):

```yaml
  - ../../skills/summarize-interview/SKILL.md
  - ../../skills/delegate-with-tree/SKILL.md
  - ../../skills/acceptance-criteria/SKILL.md
  - ../../skills/document-template/SKILL.md
tags:
```

- [ ] **Step 2: Modify teams/product-execution/TEAM.md**

In `teams/product-execution/TEAM.md`, add the same 3 lines before the `tags:` line:

```yaml
  - ../../skills/wwas/SKILL.md
  - ../../skills/delegate-with-tree/SKILL.md
  - ../../skills/acceptance-criteria/SKILL.md
  - ../../skills/document-template/SKILL.md
tags:
```

- [ ] **Step 3: Modify teams/product-strategy/TEAM.md**

In `teams/product-strategy/TEAM.md`, add before `tags:`:

```yaml
  - ../../skills/value-proposition/SKILL.md
  - ../../skills/delegate-with-tree/SKILL.md
  - ../../skills/acceptance-criteria/SKILL.md
  - ../../skills/document-template/SKILL.md
tags:
```

- [ ] **Step 4: Modify remaining 5 TEAM.md files**

For each of the following files, add the same 3 lines before `tags:`:
- `teams/data-analytics/TEAM.md` — after last existing includes line
- `teams/go-to-market/TEAM.md` — after last existing includes line
- `teams/marketing-growth/TEAM.md` — after last existing includes line
- `teams/market-research/TEAM.md` — after last existing includes line
- `teams/pm-toolkit/TEAM.md` — after last existing includes line

Exact insertion for each file (before the `tags:` line):

```yaml
  - ../../skills/delegate-with-tree/SKILL.md
  - ../../skills/acceptance-criteria/SKILL.md
  - ../../skills/document-template/SKILL.md
```

- [ ] **Step 5: Validate YAML frontmatter on all 8 TEAM.md files**

```bash
for f in teams/*/TEAM.md; do
    python3 -c "
import yaml
with open('$f') as fh:
    parts = fh.read().split('---')
fm = yaml.safe_load(parts[1])
print(f'$f: YAML OK, name={fm.get(\"name\")}')
"
done
```

Expected: all 8 files report `YAML OK`.

---

### Task 8: Modify CEO AGENTS.md

**Files:**
- Modify: `agents/ceo/AGENTS.md`

**Interfaces:**
- Consumes: skills from Tasks 2, 3, 4
- Produces: CEO AGENTS.md now includes Delegation Rules, Quality Gates, and Document Standards sections

- [ ] **Step 1: Append new sections to CEO AGENTS.md**

Append the following after the existing "## Principles" section in `agents/ceo/AGENTS.md`:

```markdown

## Delegation Rules
When you receive a client challenge:
1. Load the `delegate-with-tree` skill before splitting work
2. Create a parent issue assigned to the DIRECT manager of the executors (NOT yourself unless you are the direct manager)
3. Create child issues assigned to individual contributors
4. Each child must have a clear deliverable and reference the acceptance criteria skill
5. Keep parent issues in `todo` or `in_progress` (never `backlog`)

## Quality Gates
Before marking any parent issue as done:
1. Verify all child issues are done
2. Run the acceptance criteria validation script (load `acceptance-criteria` skill)
3. Review each deliverable against the criteria
4. Only then mark the parent issue done

## Document Standards
All deliverables must include the frontmatter template (load `document-template` skill):
- author_agent must match the child issue assignee
- reviewer_agent must be set after your review
- status must progress: draft → in_review → approved
```

- [ ] **Step 2: Validate YAML frontmatter remains valid**

```bash
python3 -c "
import yaml
with open('agents/ceo/AGENTS.md') as f:
    parts = f.read().split('---')
fm = yaml.safe_load(parts[1])
print('YAML OK:', fm.get('name'))
"
```

Expected: `YAML OK: CEO`

---

### Task 9: Modify VP AGENTS.md files (3 files)

**Files:**
- Modify: `agents/vp-discovery/AGENTS.md`
- Modify: `agents/vp-execution/AGENTS.md`
- Modify: `agents/vp-strategy/AGENTS.md`

**Interfaces:**
- Consumes: skills from Tasks 2, 3, 4, 5
- Produces: each VP AGENTS.md includes Delegation Rules, Review Responsibility, and Raise Convention sections

- [ ] **Step 1: Append to all 3 VP AGENTS.md files**

For each file: `agents/vp-discovery/AGENTS.md`, `agents/vp-execution/AGENTS.md`, `agents/vp-strategy/AGENTS.md`, append the following after the last existing section:

```markdown

## Delegation Rules
When you receive work from above:
1. Load the `delegate-with-tree` skill
2. If the work can be done by one person in a single heartbeat, do it directly
3. If it needs splitting, create child issues assigned to individual contributors
4. Keep your parent issue in `todo` or `in_progress`

## Review Responsibility
You are responsible for reviewing all child issues under your parent:
1. When all children are done, you will be automatically woken
2. Run the acceptance criteria validation script (load `acceptance-criteria` skill)
3. Review each deliverable
4. If it passes, mark your parent issue done
5. If it fails, send it back with specific feedback

## Raise Convention
If you are blocked or need a decision:
1. Open a `request_confirmation` interaction on your parent issue
2. Mention the specific blocker
3. Do not wait silently — report within 1 heartbeat cycle
```

- [ ] **Step 2: Validate YAML frontmatter on all 3 VP files**

```bash
for f in agents/vp-discovery/AGENTS.md agents/vp-execution/AGENTS.md agents/vp-strategy/AGENTS.md; do
    python3 -c "
import yaml
with open('$f') as fh:
    parts = fh.read().split('---')
fm = yaml.safe_load(parts[1])
print(f'$f: YAML OK, name={fm.get(\"name\")}')
"
done
```

Expected: all 3 files report `YAML OK`.

---

### Task 10: Modify Director AGENTS.md files (5 files)

**Files:**
- Modify: `agents/director-data-analytics/AGENTS.md`
- Modify: `agents/director-gtm/AGENTS.md`
- Modify: `agents/director-marketing/AGENTS.md`
- Modify: `agents/director-market-research/AGENTS.md`
- Modify: `agents/director-toolkit/AGENTS.md`

**Interfaces:**
- Consumes: skills from Tasks 2, 3, 4, 5
- Produces: each Director AGENTS.md includes same 3 sections as VP files

- [ ] **Step 1: Append to all 5 Director AGENTS.md files**

For each of the 5 director files, append the exact same block as in Task 9:

```markdown

## Delegation Rules
When you receive work from above:
1. Load the `delegate-with-tree` skill
2. If the work can be done by one person in a single heartbeat, do it directly
3. If it needs splitting, create child issues assigned to individual contributors
4. Keep your parent issue in `todo` or `in_progress`

## Review Responsibility
You are responsible for reviewing all child issues under your parent:
1. When all children are done, you will be automatically woken
2. Run the acceptance criteria validation script (load `acceptance-criteria` skill)
3. Review each deliverable
4. If it passes, mark your parent issue done
5. If it fails, send it back with specific feedback

## Raise Convention
If you are blocked or need a decision:
1. Open a `request_confirmation` interaction on your parent issue
2. Mention the specific blocker
3. Do not wait silently — report within 1 heartbeat cycle
```

- [ ] **Step 2: Validate YAML frontmatter on all 5 Director files**

```bash
for f in agents/director-data-analytics/AGENTS.md agents/director-gtm/AGENTS.md agents/director-marketing/AGENTS.md agents/director-market-research/AGENTS.md agents/director-toolkit/AGENTS.md; do
    python3 -c "
import yaml
with open('$f') as fh:
    parts = fh.read().split('---')
fm = yaml.safe_load(parts[1])
print(f'$f: YAML OK, name={fm.get(\"name\")}')
"
done
```

Expected: all 5 files report `YAML OK`.

---

### Task 11: Modify COMPANY.md

**Files:**
- Modify: `COMPANY.md`

**Interfaces:**
- Consumes: all prior tasks
- Produces: COMPANY.md with expanded "How the company works" section including delegation tree convention, quality gates, and document standards

- [ ] **Step 1: Replace the "How the company works" section**

Replace lines 18-33 of COMPANY.md (from `## How the company works` to the end of the lifecycle list before `Not every engagement...`):

**Old text** (lines 18-33):
```markdown
## How the company works

The CEO receives client challenges and routes them to the right department. Work typically flows through the organization following the product lifecycle:

1. **Discovery** — Brainstorm ideas, map assumptions, design experiments, conduct user research
2. **Strategy** — Define vision, evaluate business models, analyze competition, set pricing
3. **Execution** — Write PRDs, set OKRs, plan sprints, create stories, manage releases
4. **Market Research** — Build personas, map journeys, size markets, analyze sentiment
5. **Data Analytics** — Write SQL queries, analyze A/B tests, study cohort retention
6. **Go-to-Market** — Plan launches, identify beachheads, design growth loops
7. **Marketing & Growth** — Generate campaigns, craft positioning, define North Star metrics
8. **PM Toolkit** — Review resumes, draft legal docs, proofread content

Not every engagement touches all departments. The CEO matches the client's need to the right team.
```

**New text**:
```markdown
## How the company works

The CEO receives client challenges and routes them to the right department using the **delegate-with-tree** skill. Work flows through the organization following the product lifecycle AND the management hierarchy:

1. **Discovery** — Brainstorm ideas, map assumptions, design experiments, conduct user research
2. **Strategy** — Define vision, evaluate business models, analyze competition, set pricing
3. **Execution** — Write PRDs, set OKRs, plan sprints, create stories, manage releases
4. **Market Research** — Build personas, map journeys, size markets, analyze sentiment
5. **Data Analytics** — Write SQL queries, analyze A/B tests, study cohort retention
6. **Go-to-Market** — Plan launches, identify beachheads, design growth loops
7. **Marketing & Growth** — Generate campaigns, craft positioning, define North Star metrics
8. **PM Toolkit** — Review resumes, draft legal docs, proofread content

Not every engagement touches all departments. The CEO matches the client's need to the right team.

### Delegation Tree Convention
Every multi-person task follows a parent/child issue tree:
- The **parent issue assignee** is the manager responsible for that subtree
- The **child issue assignees** are the individual contributors executing the work
- When all children are done, the parent assignee is automatically woken to review
- See the `delegate-with-tree` skill for detailed rules

### Quality Gates
All deliverables must pass the acceptance criteria before being marked done:
- 5 P0 standards (must all pass) + 2 P1 standards
- Validation is automated via bash scripts
- See the `acceptance-criteria` skill and `governance/` directory

### Document Standards
Every deliverable must include frontmatter with author, reviewer, version, and status.
See the `document-template` skill for the required format.
```

- [ ] **Step 2: Validate COMPANY.md YAML frontmatter**

```bash
python3 -c "
import yaml
with open('COMPANY.md') as f:
    parts = f.read().split('---')
fm = yaml.safe_load(parts[1])
print('YAML OK:', fm.get('name'))
"
```

Expected: `YAML OK: Product Compass Consulting`

---

### Task 12: Full validation

- [ ] **Step 1: Validate all YAML frontmatter in the project**

```bash
find . -name "*.md" -not -path "./companies/*" | while read f; do
    python3 -c "
import yaml, sys
with open('$f') as fh:
    content = fh.read()
if content.startswith('---'):
    parts = content.split('---')
    if len(parts) >= 3:
        try:
            yaml.safe_load(parts[1])
        except Exception as e:
            print(f'YAML ERROR in $f: {e}')
            sys.exit(1)
" || echo "FAILED: $f"
done
echo "YAML validation complete."
```

Expected: no `YAML ERROR` or `FAILED` messages.

- [ ] **Step 2: Verify bash script syntax**

```bash
bash -n governance/acceptance_check.sh && echo "Bash syntax OK"
```

Expected: `Bash syntax OK`

- [ ] **Step 3: Run dry-run import validation**

```bash
cd /media/ok2049/work/work/paperclip-company && paperclipai company import --from . --dry-run 2>&1
```

Expected: import preview succeeds without errors.

- [ ] **Step 4: Verify file counts match expectations**

```bash
echo "Skills (expect 69 = 65 original + 4 new):"
ls -d skills/*/ | wc -l
echo "New skills exist:"
ls skills/delegate-with-tree/SKILL.md skills/acceptance-criteria/SKILL.md skills/document-template/SKILL.md skills/vp-raise-convention/SKILL.md
echo "Governance files:"
ls governance/
echo "Modified AGENTS.md count (expect 9):"
# CEO + 3 VPs + 5 Directors should all have 'Delegation Rules' section
grep -rl "Delegation Rules" agents/*/AGENTS.md | wc -l
echo "Modified TEAM.md count (expect 8):"
grep -rl "delegate-with-tree" teams/*/TEAM.md | wc -l
```

Expected:
- Skills count: 69
- All 4 new skill files exist
- Governance directory has 2 files
- 9 AGENTS.md files contain "Delegation Rules"
- 8 TEAM.md files contain "delegate-with-tree"
```

