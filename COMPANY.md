---
name: Product Compass Consulting
description: Full-service AI product management consultancy with 65 specialized skills covering discovery, strategy, execution, research, analytics, go-to-market, marketing, and PM career tools
slug: product-compass-consulting
schema: agentcompanies/v1
version: 1.0.0
license: MIT
authors:
  - name: Pawel Huryn
goals:
  - Help teams make better product decisions using proven PM frameworks
  - Cover the full product lifecycle from discovery through launch and growth
  - Provide structured, repeatable PM workflows powered by AI
---

Product Compass Consulting is a full-service AI product management consultancy. The company encodes 65 proven PM frameworks — from Teresa Torres' Opportunity Solution Trees to Lean Canvas to RICE prioritization — into structured agent workflows.

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
