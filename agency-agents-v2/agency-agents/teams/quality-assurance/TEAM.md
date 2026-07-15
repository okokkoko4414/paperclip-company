---
name: Quality Assurance
description: Testing and quality verification division covering API testing, performance, accessibility, and evidence-based certification
slug: quality-assurance
manager: ../../agents/qa-director/AGENTS.md
includes:
  - ../../agents/testing-api-tester/AGENTS.md
  - ../../agents/testing-performance-benchmarker/AGENTS.md
  - ../../agents/testing-accessibility-auditor/AGENTS.md
  - ../../agents/testing-reality-checker/AGENTS.md
  - ../../agents/testing-evidence-collector/AGENTS.md
  - ../../agents/testing-test-results-analyzer/AGENTS.md
  - ../../agents/testing-tool-evaluator/AGENTS.md
  - ../../agents/testing-workflow-optimizer/AGENTS.md
tags:
  - testing
  - quality
  - qa
---

The Quality Assurance division verifies quality through evidence-based assessment. Led by the QA Director, the team enforces a "default to NEEDS WORK" posture — production readiness requires proof, not claims. Specialists cover API testing, performance benchmarking, accessibility auditing, and workflow optimization.

## Governance

This division's lead uses `delegate-with-tree` to split multi-person work into parent/child Issue trees. All deliverables must pass `acceptance-criteria` (7 criteria: 5 P0 + 2 P1) before being marked done. Blocked work >1 heartbeat must escalate via `vp-raise-convention`.

Concrete acceptance criteria for this division will be declared in Phase C through `context` parameters in this TEAM.md.
