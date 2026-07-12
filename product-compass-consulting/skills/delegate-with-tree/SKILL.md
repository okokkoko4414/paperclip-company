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
