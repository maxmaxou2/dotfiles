# Roster Audit — Coding Team Agents

Date: 2026-05-30
Auditor: agent-smith
North star: reduce token usage across the roster at equivalent output quality.

## Live stack (read fresh from config)

- MCP servers: `agentmemory`, `code-review-graph`
- Plugins: `rtk` (silent shell rewrite), `context-mode` (sandbox + FTS5)
- Agents dir: `opencode/.config/opencode/agents/`

## Headline finding

The three `code-reviewer-*` agents (opus, sonnet, gemini-flash) had **byte-identical prompt bodies** differing only in the line-1 self-name — pure model-only variants doing the same job. The architect/developer loop invoked all three in parallel on every task, across up to four review rounds. This triplicated review tokens for no quality gain (same instructions, redundant passes). This was the dominant avoidable token cost in the roster.

Secondary: dangling `@`-mentions to non-existent agents (`@code-reviewer`, `@code-reviewerer`, `@code-reviewer-`) in architect.md and developer.md, and unused `write`/`edit` tools on the read-only repo-scout.

## Per-agent verdicts

| agent | verdict | reasoning (usage / ROI / distinctness / cohesion) | action |
|---|---|---|---|
| architect | KEEP | Primary orchestrator; heavily wired. Held the dangling reviewer refs. | Rewired all reviewer mentions to haiku/sonnet; added agentmemory continuity nudge. |
| developer | KEEP | Core implementer; wired to architect + reviewers. Held a dangling `@code-reviewer`. | Rewired review requests to haiku default + sonnet escalation. |
| agent-smith | KEEP | Primary; me. Cohesive (audit/author agents). | Added token-reduction north star to Mandate + loop-memory protocol. |
| agent-auditor | KEEP | Tier-2 forensic subagent; strong ROI (large session bytes in, tiny report out). Distinct, cohesive. | None. |
| pre-deploy-checker | KEEP | Distinct pre-deploy validation job; bash-only, cohesive. | None. |
| repo-scout | SLIM | Useful read-only recon; positive ROI (repo scan in, conventions out). Carried needless write/edit tools. | Stripped `write`/`edit` → bash-only. |
| code-reviewer-haiku | CREATE | New default reviewer. Cheapest capable model for first-pass review on every task → biggest token win. Distinct role (default), cohesive. | Created (github-copilot/claude-haiku-4.5). |
| code-reviewer-sonnet | KEEP (differentiated) | Now the escalation/deep reviewer for high-risk/large diffs. Distinct from haiku by role, not just model. | Re-scoped description + self-intro to ESCALATION reviewer. |
| code-reviewer-opus | KILL | Model-only duplicate of the canonical reviewer body. No distinct role; negative ROI (redundant pass). | Deleted (user-approved). |
| code-reviewer-gemini-flash | KILL | Model-only duplicate; same as above. | Deleted (user-approved). |

## Token-impact summary

- Review fan-out cut from **3 reviewers → 1 default (+1 conditional escalation)**. On a typical low-risk task this is a ~66% reduction in review-pass tokens; high-risk tasks pay for a second sonnet pass only when warranted. Quality preserved: the canonical review instructions are unchanged; escalation routes genuinely risky diffs to a stronger model.
- repo-scout tool surface reduced (no write/edit) — smaller capability prompt, no behavioral loss for a read-only agent.
- Dangling-mention cleanup removes wasted routing attempts to non-existent agents.
- agent-smith loop-memory protocol avoids re-deriving roster + stack each audit (recall at loop start, persist at loop end).

## Verification

`grep` across all agent `.md` files confirms only `@code-reviewer-haiku` and `@code-reviewer-sonnet` remain; all opus/gemini/bare/typo reviewer references are gone.

## Changes applied (this loop)

1. Created `code-reviewer-haiku.md` (default reviewer, haiku-4.5, canonical body + escalation note).
2. Re-scoped `code-reviewer-sonnet.md` to escalation/deep reviewer.
3. Deleted `code-reviewer-opus.md`, `code-reviewer-gemini-flash.md`.
4. Rewired `architect.md` (5 reviewer references; removed dangling `@code-reviewer`/`@code-reviewerer`) + added memory nudge.
5. Rewired `developer.md` (3 reviewer references; removed dangling `@code-reviewer`).
6. Stripped `repo-scout.md` write/edit tools.
7. agent-smith.md: token-reduction north star in Mandate + Loop memory section.
