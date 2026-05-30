# Task 006 — Upgrade agent-smith with behavioral audit & token optimization

## Context
agent-smith (`~/dotfiles/opencode/.config/opencode/agents/agent-smith.md`, primary, opus,
88 lines) today audits agents STATICALLY (reads the `.md` prose, maps @-mention wiring,
applies the four roster tests). It is blind to RUNTIME behavior — it can't see which agents
loop on tool calls, throw errors, or burn tokens in production.

We just shipped **agent-auditor** (`agent-auditor.md`, subagent, haiku, read-only): a cheap
forensic worker that mines opencode's session DB in a context-mode sandbox and returns a TINY
distilled defect report (per-agent token spend, tool-call loops, errors, stack-misuse). It
exists precisely so agent-smith (expensive opus) NEVER has to read raw session bytes itself.

This task wires agent-auditor into agent-smith and adds runtime/token-optimization reasoning,
so the meta-agent can recommend token-saving fixes backed by real data.

## Objective
Edit `agent-smith.md`: add ONE new section **"## Behavioral audit & token optimization"**
(place it AFTER "## Audit workflow", BEFORE "## Tool conventions to follow and propagate"),
and make a couple of small supporting touches. Do NOT rewrite the whole file.

## Scope — what the new section must encode

### North star
- agent-smith's overarching goal when improving agents: **minimize token usage while holding
  output quality equal**. Every behavioral fix recommendation must (a) name the expected token
  saving (direction/rough magnitude) and (b) assert it does not degrade quality. If a change
  trades quality for tokens, it is NOT a win — flag the tradeoff, don't silently make it.

### Two-tier token firewall (the core mechanic)
agent-smith must NEVER ingest raw session bytes itself. It gathers runtime evidence in two
cheap tiers:
- **TIER 1 (always first): agentmemory MCP.** Query it DIRECTLY for a cheap, high-level defect
  and pattern feed — which agent, which session, what error type. Relevant tools:
  `memory_sessions` (one row per subagent invocation, names agent+task + observationCount),
  `memory_recall` / `memory_smart_search` (typed observations: error/decision/file_edit/etc.,
  already surfaces titles like "Invalid input for question tool", "Step Failed"). Tiny token
  cost. This tells agent-smith WHERE to look.
- **TIER 2 (only when tier 1 flags something worth measuring): delegate to @agent-auditor.**
  It runs the sandbox forensics over the opencode session DB and returns a tiny distilled
  report (token spend, 3+-consecutive tool loops, errors bucketed by tool, stack-misuse, and
  whether the agent uses ctx_execute). agent-smith reads ONLY that small report — never the
  raw rows. State explicitly that agent-auditor is the ONLY path to byte-level runtime metrics
  and that agent-smith must not try to query the session DB itself.

### Live-stack derivation (no hardcoded stack list)
- At audit time, derive the INSTALLED tool stack from the live config rather than assuming it:
  read `~/.config/opencode/opencode.json` (plugins + MCP servers) and the global
  `AGENTS.md` to learn what is actually available (today that surfaces rtk, agentmemory,
  context-mode, code-review-graph — but DO NOT hardcode that list; read it fresh each time so
  the audit stays correct as the stack changes).
- Then check each agent actually USES the live stack where it would save tokens (e.g. does a
  heavy shell/data agent route through context-mode instead of dumping raw output? does it
  trust rtk?). A capable-but-unused tool = a token-waste finding.

### Guardrails (reuse existing rules — restate briefly)
- Audits are ON-DEMAND, triggered by the user — agent-smith is NOT a continuous monitor.
- Behavioral/prompt fixes still require user signoff via the `question` tool before any file
  change (same rule already in "Audit workflow").
- Do NOT modify agentmemory or opencode internals/DB — these are read-only evidence sources.

## Supporting touches (small)
- In the existing "## Audit workflow" section (or the new section), make clear the roster-audit
  report may now include a runtime column / behavioral findings sourced from tiers 1–2, so the
  static and behavioral audits compose into one report.
- Ensure @agent-auditor is referenced by name so the wiring graph is explicit (agent-smith ->
  @agent-auditor). This also makes agent-auditor a non-orphan.

## Non-goals / Later
- Do NOT modify any other agent file. Only `agent-smith.md` changes in this task.
- Do NOT change agent-auditor.md (it is done/committed).
- Do NOT hardcode the stack list, token thresholds, or specific SQL — agent-smith delegates
  measurement to agent-auditor; it does not embed queries.
- Do NOT add a continuous-monitoring / scheduling mechanism.
- Do NOT touch opencode.json, AGENTS.md, plugins, or MCP config.

## Constraints / Caveats
- Keep the addition LEAN and in the existing house voice (laconic, decision-relevant, the file
  already uses `## ` headings and short prose/bullets — match that). The whole file should stay
  comfortably readable; this is one focused section plus minor touches, not a rewrite.
- Preserve everything already in the file (mandate, format, interaction discipline, four
  roster tests + five verdicts, audit workflow, tool conventions, authoring, stopping).
- This is a prompt/config file — nothing to compile or run. Correctness = the new section
  faithfully encodes the north star, the two-tier firewall (tier1 agentmemory direct, tier2
  @agent-auditor, opus never reads raw bytes), live-stack derivation, and the guardrails;
  and the existing content is intact.

## Acceptance criteria
- New "## Behavioral audit & token optimization" section exists in the right place.
- It names: the minimize-tokens-at-equal-quality north star (with the "name the saving + assert
  no quality loss" rule), the two tiers (agentmemory direct first; @agent-auditor second), the
  "never read raw bytes itself" rule, live-stack derivation from opencode.json + AGENTS.md
  (explicitly NOT hardcoded), and the three guardrails (on-demand, user signoff, no internal
  mutation).
- @agent-auditor is referenced by name.
- No other section is lost or materially altered.
