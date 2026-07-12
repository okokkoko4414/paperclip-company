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
