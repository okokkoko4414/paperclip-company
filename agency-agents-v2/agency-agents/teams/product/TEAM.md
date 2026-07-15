---
name: "Product & Project Management"
description: Product strategy and project coordination division covering roadmap planning, sprint management, and cross-functional delivery
slug: product
manager: ../../agents/vp-product/AGENTS.md
includes:
  - ../../agents/product-manager/AGENTS.md
  - ../../agents/product-sprint-prioritizer/AGENTS.md
  - ../../agents/product-feedback-synthesizer/AGENTS.md
  - ../../agents/product-trend-researcher/AGENTS.md
  - ../../agents/product-behavioral-nudge-engine/AGENTS.md
  - ../../agents/project-manager-senior/AGENTS.md
  - ../../agents/project-management-studio-producer/AGENTS.md
  - ../../agents/project-management-project-shepherd/AGENTS.md
  - ../../agents/project-management-studio-operations/AGENTS.md
  - ../../agents/project-management-experiment-tracker/AGENTS.md
  - ../../agents/project-management-jira-workflow-steward/AGENTS.md
tags:
  - product
  - project-management
  - strategy
---

The Product & Project Management division defines what to build, when, and why — then ensures it gets delivered. Led by the VP of Product, the team combines product strategy specialists with project management professionals who coordinate cross-functional execution.

## Governance

This division's lead uses `delegate-with-tree` to split multi-person work into parent/child Issue trees. All deliverables must pass `acceptance-criteria` (7 criteria: 5 P0 + 2 P1) before being marked done. Blocked work >1 heartbeat must escalate via `vp-raise-convention`.

Concrete acceptance criteria for this division will be declared in Phase C through `context` parameters in this TEAM.md.
