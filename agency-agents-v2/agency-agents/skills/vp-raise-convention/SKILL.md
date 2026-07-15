---
name: vp-raise-convention
description: 升级协议 — 部门负责人在受阻时如何升级，以及沉默不得超过一个心跳周期的硬规则。
key: geo119/vp-raise-convention
recommendedForRoles:
  - manager
  - director
tags:
  - escalation
  - management
---

# 升级约定

部门负责人受阻且无法在上级决策之前推进时，必须主动升级。沉默等待不可接受。

## 升级表

| 场景 | 升级方式 | 触发条件 |
|------|---------|---------|
| 子 Issue 执行者卡住 | 在父 Issue 上发起 `request_confirmation` 交互 | 执行者无法继续 |
| 部门负责人本人受阻 | 在 CEO 指派 Issue 上发起交互或评论 | 需要 CEO 决策 |
| 专员需要部门负责人介入 | @提及负责人或在父 Issue 上发起交互 | 需要管理判断 |

## 硬规则

1. **一个心跳周期内上报。** 受阻超过一个心跳周期，必须升级。
2. **不得对截止日期沉默等待。** 若判断无法按时完成，立即升级。
3. **CEO 须在下一个心跳周期内响应。** 收到升级后，CEO 在一个心跳周期内确认并响应。
