# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a modified Paperclip Agent Company template — `product-compass-consulting-v2` — based on the official [Product Compass Consulting](https://github.com/paperclipai/companies) template. V2 adds an enforceable delivery governance layer on top of the original 48-agent, 65-skill PM consultancy.

The company package lives in `product-compass-consulting-v2/`. The repo root holds only dev docs and this CLAUDE.md.

## Architecture

```
product-compass-consulting-v2/
├── COMPANY.md                    # agentcompanies/v1 schema, slug: product-compass-consulting-v2
├── .paperclip.yaml               # paperclip/v1
├── agents/                       # 48 agents (CEO + 3 VPs + 5 Directors + 39 Specialists)
├── skills/                       # 69 skills (65 original PM + 4 governance)
├── teams/                        # 8 teams with TEAM.md files
├── governance/                   # V2.1 acceptance criteria + bash validation script
└── images/                       # Org chart
```

**V2 governance additions (vs official template):**
- 4 new skills in `skills/`: `delegate-with-tree`, `acceptance-criteria`, `document-template`, `vp-raise-convention`
- `governance/` directory with 7-criteria V2.1 spec and automated `acceptance_check.sh`
- 9 management AGENTS.md injected with Delegation Rules / Review Responsibility / Raise Convention sections (CEO + 3 VPs + 5 Directors)
- 8 TEAM.md files include references to 3 governance skills (delegate-with-tree, acceptance-criteria, document-template)
- COMPANY.md expanded with Delegation Tree Convention, Quality Gates, and Document Standards sections
- 39 Specialist/Analyst agents and all 65 original skills are untouched

**Key rules encoded in the governance layer:**
- Parent Issue assignee = direct manager, child Issue assignee = executor
- All children done/cancelled → parent assignee auto-woken for review
- 5 P0 criteria (must all pass) + 2 P1 criteria for deliverable acceptance
- Mandatory frontmatter on every deliverable (author, reviewer, version, status)
- Blocked >1 heartbeat cycle → must escalate via `vp-raise-convention`

## Validation

No build step. Validate the company package imports correctly:

```bash
npx companies.sh add ./product-compass-consulting-v2 --dry-run
```

Check bash script syntax:

```bash
bash -n product-compass-consulting-v2/governance/acceptance_check.sh
```

## Relevant Specs

- [Agent Companies specification](https://agentcompanies.io/specification) (`agentcompanies/v1` schema)
- [companies.sh](https://companies.sh) — import CLI
- [paperclipai/companies-tool](https://github.com/paperclipai/companies-tool) — company creator/validator
- [Paperclip](https://github.com/paperclipai/paperclip) — runtime platform

## Development Docs

- `docs/PRODUCT-COMPASS-TRANSFORM-PRD.md` — full PRD with requirements
- `docs/superpowers/specs/` — design spec
- `docs/superpowers/plans/` — implementation plan
- `product-compass-consulting-v2/GRAPH.md` — complete knowledge graph (org chart, skills, delegation flow, modification checklist, in Chinese)
