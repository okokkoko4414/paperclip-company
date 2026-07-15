---
name: delegate-with-tree
description: 委派工作：构建映射组织层级的父子 Issue 树 — 管理者持有父 Issue，执行者持有子 Issue，子任务完成后自动回流至负责管理者进行审批。
key: geo119/delegate-with-tree
recommendedForRoles:
  - ceo
  - manager
  - director
tags:
  - delegation
  - issues
  - management
---

# 委派树

将跨人员任务拆分为映射组织层级的父子 Issue 树。

## 树结构

```
CEO（最高层级领导）
└── 部门负责人 ← 父 Issue 的 assignee = 执行者的直接管理者
    ├── 专员 A ← 子 Issue 的 assignee = 执行者
    ├── 专员 B ← 子 Issue 的 assignee = 执行者
    └── 专员 C ← 子 Issue 的 assignee = 执行者
```

## 规则

1. **父 Issue assignee = 执行者的直接管理者**（非 CEO，除非 CEO 即为直接管理者）。
2. **子 Issue assignee = 执行者** —— 承担具体工作的个人贡献者。
3. **父 Issue 状态必须为 `todo` 或 `in_progress`** —— `backlog` 状态不会触发子任务全部完成后的唤醒。
4. **所有子 Issue 必须为 `done` 或 `cancelled`** 之后，父 Issue assignee 才会被唤醒进行审批。单一子任务完成并不足够。
5. **父 Issue 在所有子任务完成且父 assignee 完成全部交付物审批之前，不得标记为 `done`**。

## 适用场景

- 多人员任务拆分
- 跨职能协调
- 任何需要管理层审批的交付物

## 不适用场景

- 单人员任务，可在一个心跳周期内完成
- 委派者即为执行者（无中间管理层）
