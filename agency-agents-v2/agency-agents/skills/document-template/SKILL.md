---
name: document-template
description: 强制交付物 frontmatter 元数据 — 作者、审批者、版本、状态 — 确保每份文件可追溯至创建者及审批链。
key: geo119/document-template
recommendedForRoles:
  - all
tags:
  - documentation
  - metadata
  - governance
---

# 文档模板

每份交付物 `.md` 文件必须在文件顶部包含以下 YAML frontmatter。

## 必需 Frontmatter

```yaml
---
document_type: deliverable          # deliverable | plan | review | report
phase: A                            # 阶段标识
directory: 01-strategy              # 归属目录
filename: value-proposition.md      # 文件名
version: V1.0                       # 版本号
author_agent: VP Product Strategy   # 撰写者（Agent 名称）
reviewer_agent: Reviewer            # 审批者（Agent 名称）
status: draft                       # draft | in_review | approved
created_at: 2026-07-12T10:00:00Z    # ISO 8601 创建时间
updated_at: 2026-07-12T12:00:00Z    # ISO 8601 最后修改时间
issue_id: PHA-XXX                   # 关联 Issue ID
---
```

## 硬规则

1. **无 frontmatter = 驳回。** 缺少此元数据块的交付物不予接受。
2. **author_agent 必须匹配 Issue assignee。** 作者必须为子 Issue 所指派的人员。
3. **状态变更须有审批记录。** `draft` → `in_review` → `approved` 流转须附带审批者评论或交互记录。

## 状态流转

```
draft → in_review → approved
  ↑                    │
  └──── (rejected) ────┘
```

- `draft`：进行中，尚未提交审批。
- `in_review`：已提交，等待审批者反馈。
- `approved`：通过审批及验收标准。
