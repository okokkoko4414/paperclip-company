---
name: vp-raise-convention
description: Escalation protocol for managers — when blocked, how to escalate, and the hard rule that silence is not an option beyond one heartbeat cycle.
key: okokkoko4414/vp-raise-convention
recommendedForRoles:
  - manager
  - director
  - vp
tags:
  - escalation
  - management
  - communication
---

# VP Raise Convention

When a VP or Director is blocked and cannot proceed without a decision from above, they must actively escalate. Silent waiting is not acceptable.

## Escalation Table

| Scenario | How to Escalate | Trigger |
|----------|----------------|---------|
| Child Issue executor stuck | Open `request_confirmation` interaction on parent Issue | Executor cannot continue |
| VP/Director themselves blocked | Open interaction or comment on CEO-assigned parent Issue | Needs CEO decision |
| Specialist needs VP intervention | @mention VP or open interaction on parent Issue | Needs management judgment |
| Budget warning | Comment on parent Issue with budget status | Budget approaching limit |

## Hard Rules

1. **Report within 1 heartbeat cycle.** If you are blocked for longer than one heartbeat period, you must escalate.
2. **Never wait silently for a deadline.** If you can see you will miss a deadline, escalate immediately.
3. **CEO must respond within the next heartbeat.** After receiving an escalation, the CEO acknowledges and responds within one heartbeat cycle.
