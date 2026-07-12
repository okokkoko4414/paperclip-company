# Product Compass Transform Design

**Date**: 2026-07-12
**Source PRD**: PRODUCT-COMPASS-TRANSFORM-PRD.md

## Summary

Transform the official `product-compass-consulting` template from a static org chart into an enforceable delivery pipeline by adding delegation tree conventions, quality gates, document template standards, and raise conventions — 4 new skills, injection into 9 management AGENTS.md files, and 2 governance files.

## Architecture

The modified company follows the same Agent Companies spec (`agentcompanies/v1`) as the original. New governance skills layer on top of existing 65 PM skills without modifying them.

```
paperclip-company/
├── COMPANY.md                        # MODIFIED — adds delegation/quality/doc-standard sections
├── .paperclip.yaml                   # UNCHANGED — schema: paperclip/v1
├── agents/
│   ├── ceo/AGENTS.md                 # MODIFIED — delegation rules, quality gates, doc standards
│   ├── vp-discovery/AGENTS.md        # MODIFIED — delegation, review responsibility, raise convention
│   ├── vp-execution/AGENTS.md        # MODIFIED
│   ├── vp-strategy/AGENTS.md         # MODIFIED
│   ├── director-data-analytics/AGENTS.md  # MODIFIED
│   ├── director-gtm/AGENTS.md             # MODIFIED
│   ├── director-marketing/AGENTS.md       # MODIFIED
│   ├── director-market-research/AGENTS.md # MODIFIED
│   ├── director-toolkit/AGENTS.md         # MODIFIED
│   └── ... (39 Specialist agents UNCHANGED)
├── teams/ (8 directories)
│   └── */TEAM.md                     # MODIFIED — add includes for 3 new governance skills
├── skills/
│   ├── delegate-with-tree/SKILL.md   # NEW
│   ├── acceptance-criteria/SKILL.md  # NEW
│   ├── document-template/SKILL.md    # NEW
│   ├── vp-raise-convention/SKILL.md  # NEW
│   └── ... (65 existing skills UNCHANGED)
└── governance/
    ├── DELIVERABLE-ACCEPTANCE-CRITERIA-V2.1.md  # NEW — 7 criteria (5 P0, 2 P1)
    └── acceptance_check.sh                      # NEW — one-shot validation script
```

## Data Flow

```
CEO receives task
  → delegate-with-tree skill: split into parent/child Issue tree
  → VP/Director owns parent Issue, Specialists own child Issues
  → Specialists produce deliverables with document-template skill (frontmatter required)
  → All child Issues done → parent Issue assignee auto-woken
  → VP/Director runs acceptance-criteria skill (7 criteria, P0 must all pass)
  → If blocked: vp-raise-convention skill (escalate within 1 heartbeat)
  → Parent Issue marked done only after review passes
```

## Key Rules

1. Parent Issue assignee = direct manager (not CEO, unless CEO is direct manager)
2. Child Issue assignee = executor
3. Parent Issue must stay todo/in_progress (backlog won't trigger wake)
4. All children done before parent assignee is woken
5. No frontmatter = rejected deliverable
6. P0 criteria: 5/5 must pass; P1: 2/2 must pass or document as known limitation
7. Blocked >1 heartbeat cycle = must escalate

## Scope Boundaries

**Modified**: COMPANY.md, 9 AGENTS.md (CEO + 3 VPs + 5 Directors), 8 TEAM.md
**Created**: 4 SKILL.md, 2 governance files
**Preserved unchanged**: All 39 Specialist/Analyst AGENTS.md, all 65 existing skills, README.md, LICENSE, images/, .paperclip.yaml

## Implementation Approach: Bottom-Up

1. Copy entire template (`companies/product-compass-consulting/`) to project root
2. Create 4 new skills (no dependencies)
3. Create governance/ directory with V2.1 criteria doc + bash script
4. Modify 8 TEAM.md files (add includes for delegate-with-tree, acceptance-criteria, document-template)
5. Modify 9 AGENTS.md files:
   - CEO: delegation rules, quality gates, document standards
   - VP/Director: delegation rules, review responsibility, raise convention
6. Modify COMPANY.md (add delegation tree convention, quality gates, document standards sections)

## Validation

```bash
paperclipai company import --from /path/to/paperclip-company --dry-run
bash -n governance/acceptance_check.sh
```
