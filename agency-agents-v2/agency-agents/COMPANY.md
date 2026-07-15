---
name: Agency Agents
description: A complete AI agency with 167 specialized agents across 10 divisions — engineering, design, marketing, product, sales, QA, operations, game development, spatial computing, and specialized operations
slug: agency-agents
schema: agentcompanies/v1
version: 1.0.0
license: MIT
authors:
  - name: AgentLand Contributors
goals:
  - Provide deep specialist expertise across every business and technical domain
  - Coordinate multi-agent workflows through structured handoffs and quality gates
  - Transform complex initiatives into delivered work products through division-level orchestration
metadata:
  sources:
    - kind: github-dir
      repo: msitarzewski/agency-agents
      path: .
      commit: 6254154899f510eb4a4de10561fecfc1f32ff17f
      attribution: AgentLand Contributors
      license: MIT
      usage: referenced
---

Agency Agents is a complete AI organization with 167 agents organized into 10 divisions. Each agent is a domain specialist with deep expertise, a defined personality, and structured workflows.

## How It Works

Agency Agents operates on a **hub-and-spoke model**. The CEO coordinates across division heads, who manage their teams autonomously. For complex multi-division initiatives, Agency Agents follows the **NEXUS framework** — a seven-phase pipeline (Discovery, Strategy, Foundation, Build, Hardening, Launch, Operate) with quality gates at each stage.

## Divisions

- **Engineering** (23 agents) — Frontend, backend, mobile, AI/ML, DevOps, security, and specialized engineering
- **Design** (8 agents) — UX architecture, UI design, brand identity, and visual storytelling
- **Marketing & Paid Media** (34 agents) — Content, growth, SEO, social media, paid advertising, and regional market expertise
- **Product & Project Management** (11 agents) — Product strategy, sprint planning, and cross-functional delivery
- **Sales** (8 agents) — Outbound strategy, deal management, pipeline analysis, and sales engineering
- **Quality Assurance** (8 agents) — API testing, performance, accessibility, and evidence-based certification
- **Operations & Support** (6 agents) — Analytics, finance, legal compliance, infrastructure, and customer support
- **Game Development** (20 agents) — Unity, Unreal, Godot, Roblox, Blender, and cross-engine disciplines
- **Spatial Computing & XR** (6 agents) — visionOS, WebXR, Metal rendering, and spatial interface design
- **Specialized Operations** (32 agents) — Compliance, automation, knowledge management, developer advocacy, and academic research

## Leadership

| Role | Slug | Reports To |
|------|------|------------|
| Managing Director & CEO | ceo | — |
| VP of Engineering & CTO | vp-engineering | CEO |
| Creative Director | creative-director | CEO |
| Chief Marketing Officer | cmo | CEO |
| VP of Product | vp-product | CEO |
| VP of Sales | vp-sales | CEO |
| QA Director | qa-director | VP of Engineering |
| VP of Operations | vp-operations | CEO |
| Game Development Director | game-dev-director | CEO |
| XR Director | xr-director | VP of Engineering |
| Chief of Staff | chief-of-staff | CEO |

Generated from [agency-agents](https://github.com/msitarzewski/agency-agents) with the company-creator skill from [Paperclip](https://github.com/paperclipai/paperclip)

## Delegation Tree Convention

Agency Agents operates on a hub-and-spoke model with the following hard rules:

1. **Coordinator classifies, specialist executes.** Division leads (CEO + 10 directors/VPs) classify incoming tasks and delegate to the appropriate specialist. Division leads do not execute tasks directly — their role is classification, routing, and review.
2. **Parent Issue assignee = direct manager.** CEO delegates to division leads; division leads delegate to specialists. The Issue tree mirrors the org chart.
3. **Child Issue assignee = executor.** Each specialist owns their child Issue and produces the deliverable.
4. **All children done → parent woken.** Parent Issue assignee is woken for review only when all child Issues are `done` or `cancelled`.
5. **Parent not done until reviewed.** Parent Issue stays open until the parent assignee has reviewed all deliverables against acceptance criteria.

## Cross-Company Issue Coordination

GEO119 operates three independent Paperclip companies (A: Product Compass, B: Superpowers, C: Agency Agents) controlled by a single Hermes beta session via `mcp__paperclip_{a,b,c}__*` tool prefixes.

**Isolation mechanism** (C9):
- Each company exposes 1 project board + 1 routine aggregation
- Beta consumes per-company dashboard summaries (active issues, blocked issues, completion rate) without pulling raw agent state
- Beta creates cross-company coordination issues that reference deliverables across companies
- Each company's CEO is responsible for producing the summary artifact; beta reads the artifact, not the underlying issues directly

This is NOT equivalent to `dashboard = read_issue`. The summary artifact is a CEO-produced deliverable, not a raw API response.

## Quality Gates

All deliverables must pass the 7-criteria acceptance checklist (5 P0 must-pass + 2 P1 must-pass) defined in the `acceptance-criteria` skill. Every deliverable must include the frontmatter template defined in the `document-template` skill. Blocked work >1 heartbeat cycle must escalate per `vp-raise-convention`.
