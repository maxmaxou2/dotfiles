# MCP Tool-Schema Gating Audit

**Date:** 2026-06-01
**Trigger:** User observed architect-gemini's first request loading ~32k of context.
**North star:** Cut first-request token cost across the roster with zero quality loss.

## Problem

The architect-gemini agent's first request consumes ~32k tokens before the user types
anything. The agent's own system prompt is only ~2.6k tokens — the rest is injected
boilerplate, dominated by **MCP tool-schema injection**.

This is not specific to architect-gemini. **All 10 agents pay the same tax**, because
none of them gate MCP tools in frontmatter (they only set `write/edit/bash`).

## Measured token breakdown (architect-gemini first request, approx)

| Source                                              | Tokens |
| --------------------------------------------------- | ------ |
| architect-gemini.md system prompt                   | ~2.6k  |
| global AGENTS.md                                    | ~1.7k  |
| skills list + base system reminders                 | ~2k    |
| **MCP tool schemas (agentmemory + crg + ctx)**      | **~25k** |
| **Total**                                           | **~32k** |

### MCP tool-schema cost (estimated, by server)

| MCP server          | ~tools | description verbosity        | est. schema tokens |
| ------------------- | ------ | ---------------------------- | ------------------ |
| agentmemory         | ~60    | terse, 1 line each           | ~7–9k              |
| code-review-graph   | ~40    | long multi-paragraph each    | ~12–16k            |
| context-mode (ctx_) | ~15    | very verbose WHEN/RETURNS    | ~8–11k             |

Sum ≈ 27–36k, consistent with the observed 32k.

## Live stack (read fresh from config, 2026-06-01)

- `~/.config/opencode/opencode.json` → `mcp`: **agentmemory**, **code-review-graph**.
- **context-mode** is a plugin (not in `mcp`), mandated for *all* agents by the global
  AGENTS.md "Think-in-Code" rules. **Cannot gate without quality loss.** Stays everywhere.
- No agent has per-agent MCP config; all inherit the full catalog.

## Actual MCP usage per agent (references in prompt body)

| agent                | mem refs | crg refs | ctx refs |
| -------------------- | -------- | -------- | -------- |
| architect            | 4        | 5        | 4        |
| architect-gemini     | 4        | 5        | 4        |
| agent-smith          | 7        | 1        | 6        |
| agent-auditor        | 1        | 0        | 7        |
| code-reviewer-haiku  | 0        | 7        | 3        |
| code-reviewer-sonnet | 0        | 7        | 3        |
| developer-deepseek   | 0        | 2        | 5        |
| developer-haiku      | 0        | 2        | 5        |
| pre-deploy-checker   | 0        | 5        | 3        |
| repo-scout           | 0        | 4        | 3        |

**Key finding:** 6 of 10 agents reference agentmemory **zero** times yet pay its full
~7–9k schema. agent-auditor references code-review-graph **zero** times yet pays its
~12–16k schema.

Even the agents that *do* use agentmemory call only 3–5 of its 60 tools
(`smart_search`, `recall`, `save`, occasionally `lesson_recall`/`lesson_save`). The
remaining ~55 tools are pure dead schema weight.

## Mechanism (verified against opencode.ai/config.json)

- `AgentConfig.tools` is `{ [toolId: string]: boolean }`, `additionalProperties: boolean`.
  Schema marks it `@deprecated, use 'permission' instead` — BUT `permission` keys are a
  fixed enum (`read, edit, bash, task, ...`) that **excludes MCP tool names**. So `tools`
  is the **only** lever for per-agent MCP gating and remains functional at runtime.
- opencode wildcard-matches tool ids against the `tools` keys. Pattern:
  ```yaml
  tools:
    write: true
    edit: true
    bash: true
    "agentmemory*": false              # deny the whole server
    agentmemory_memory_smart_search: true   # allow back the few you use
    agentmemory_memory_recall: true
    agentmemory_memory_save: true
  ```
  Explicit tool keys override the wildcard (allow-back works).

## Per-agent gating plan + verdict

context-mode (ctx_) stays on everywhere — mandated, not gatable without quality loss.

| agent                | verdict | gating action                                              | est. saved |
| -------------------- | ------- | ---------------------------------------------------------- | ---------- |
| architect            | SLIM    | `agentmemory*` off + allow {smart_search, recall, save}    | ~6–8k      |
| architect-gemini     | SLIM    | same as architect                                          | ~6–8k      |
| agent-smith          | SLIM    | `agentmemory*` off + allow {smart_search, recall, save, lesson_recall, lesson_save}; `code-review-graph*` off (only 1 ref) | ~6–8k (+12–16k if crg gated) |
| agent-auditor        | SLIM    | `code-review-graph*` off (0 refs); `agentmemory*` off + allow {smart_search, recall} | ~12–16k + ~6k |
| code-reviewer-haiku  | SLIM    | `agentmemory*` off (0 refs)                                | ~7–9k      |
| code-reviewer-sonnet | SLIM    | `agentmemory*` off (0 refs)                                | ~7–9k      |
| developer-deepseek   | SLIM    | `agentmemory*` off (0 refs)                                | ~7–9k      |
| developer-haiku      | SLIM    | `agentmemory*` off (0 refs)                                | ~7–9k      |
| pre-deploy-checker   | SLIM    | `agentmemory*` off (0 refs)                                | ~7–9k      |
| repo-scout           | SLIM    | `agentmemory*` off (0 refs)                                | ~7–9k      |

**Quality-loss assessment:** none expected.
- The 6 subagents that gate agentmemory off never call it; their orchestrating primary
  handles recall/save. The global AGENTS.md memory instruction is satisfied by the
  primary, not by short-lived single-purpose subagents.
- The memory-using primaries keep the exact 3–5 tools their prompts reference; the other
  ~55 are never invoked.
- agent-auditor's job is sandbox forensics over the session DB (ctx_*), not graph
  navigation; it references crg zero times.

## Estimated roster-wide outcome

- agentmemory gating on all 10 agents: ~7–9k saved each on first request (less on the
  ~5 primaries that allow-back a few tools: ~6–8k each).
- code-review-graph gating on agent-auditor (+ optionally agent-smith): ~12–16k each.
- **architect-gemini specifically: ~32k → ~24–26k** from agentmemory gating alone.
  (The remaining bulk is code-review-graph + context-mode, both genuinely used by the
  architect, so they stay.)

## Recommended rollout (risk-managed)

1. **Pilot:** apply agentmemory gating to **architect-gemini only**. User restarts
   opencode, re-checks first-request context, confirms the wildcard syntax works in this
   opencode version and nothing breaks.
2. **Roll out:** on confirmation, apply the per-agent plan above to the remaining 9.
3. Caveat to track: `tools` is schema-deprecated. If a future opencode removes runtime
   support for MCP gating via `tools`, this optimization regresses and we'd need a plugin
   (`tool.definition` hook) instead. Note in agent-smith memory.

## Open decision for the user

- Gate **code-review-graph** off for **agent-smith** too? It has only 1 crg reference and
  rarely navigates code graphs, but its mandate says to *propagate* crg conventions to
  other agents. Gating saves ~12–16k on agent-smith's own context but means agent-smith
  can't directly call crg tools (it can still advise on them). Recommend: **yes, gate** —
  agent-smith reasons about config, not code structure.
