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
