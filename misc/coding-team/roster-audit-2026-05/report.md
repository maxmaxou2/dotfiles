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

## Tier-2 behavioral audit — architect (via @agent-auditor)

Tier-1 agentmemory pass showed no strong architect defect cluster (scores <0.02; flagged `error` obs were generic step-hook noise). Delegated byte-level forensics to @agent-auditor (agent-smith never ingested the 10.3M-token session).

Findings:
- **Top waste (confirmed):** in the architect's last real session (`ses_18d5c1bb7ffeJS1AOm0PhAlPRr`), 23/34 bash calls (68%) were `cat`/`grep`/`find`/`head`/`tail`/`ls` for analysis instead of `ctx_execute_file`. Only 4 sandbox calls. Est. 15–25% token reduction if file-analysis reads route to the sandbox. No quality loss.
- **No runtime loops/error storms.** 2 low-severity `question`-tool issues: (1) a call missing the required `question` field; (2) a garbled question string (`"Wat want do next?"`) the user dismissed.
- **Hook-noise confirmed:** `ses_18d3f8e1...` was @developer, not architect — discarded.

Fixes applied (user-approved):
- architect.md L47: explicit rule — reading a file to analyze/summarize/search goes through `ctx_execute_file`, not raw `cat`/`grep`/`head`; read directly only to edit. Flagged as the single biggest token lever.
- architect.md L25: question-tool hygiene — every call must carry a clear, complete, grammatical `question` string; never header-only or garbled. Fixes both validation errors.

## Caveman rollout (token efficiency)

User confirmed they read caveman natively. Caveman (full intensity) is applied to **agent-to-agent return messages** (receiver parses it natively) and to agent-smith's user-facing chat — but never to written artifacts, headings, file paths, commands, or code identifiers, which stay exact.

- developer.md + both reviewers: already carried caveman return-message instructions from the reviewer-consolidation phase.
- repo-scout.md: report **prose** (bullets/reasons) in caveman; headings/paths/commands kept exact.
- pre-deploy-checker.md: problem/why prose in caveman; `file:line`/env names/commands kept exact.
- agent-auditor.md: free-text `top waste signal` line in caveman; template keys/numbers/ids kept exact.
- agent-smith.md (me): full caveman in chat; **caveman-lite + grammatical** for `question` prompts/option labels (a garbled caveman question is what caused architect's dismissed-question defect); audit report **files** stay clear normal prose (durable human reference).
- architect.md L33: left as caveman-everywhere per user decision (user reads caveman fine).

## Tier-2 behavioral audit — developer (via @agent-auditor)

Tier-1 agentmemory pass weak (scores <0.016, generic hook noise). Delegated byte-level forensics to @agent-auditor; agent-smith never ingested the 263M-token DB.

Findings (window: all, 200 developer sessions):
- **Top waste (confirmed, biggest lever in the roster):** 467/1948 bash calls (24%) were raw `cat`/`grep`/`find`/`head`/`tail`/`ls`; `ctx_execute`/`ctx_execute_file` usage = **0**. developer.md already had a context-mode directive (L28) but it was soft + buried and ignored in practice. Same anti-pattern as architect, larger absolute volume.
- Loops: 10 sequences (edit x139, read x125, bash x90) — read/edit thrash on same files.
- Errors: 80 (edit:23, apply_patch:21, read:17, skill:11, write:3, grep:3, glob:2) — failed edit/patch retries waste tokens.

Root-cause note on edit/apply_patch errors: dominant cheap-to-fix class is **stale context after the developer's own prior edit** (on-disk bytes changed under the agent's model). A read-freshness rule fixes that subset; the remaining class (non-unique/whitespace/fabricated context) needs precision, not freshness.

Fixes applied (user-approved):
- developer.md L28: soft directive **sharpened into a HARD RULE** — scan/search/analyze-to-understand (`grep`/`cat`/`find`/`head`/`tail` over file contents) MUST go through `ctx_execute_file`/`ctx_execute`; read-to-edit = native Read; read-to-understand = sandbox. Flagged as developer's single biggest token lever. Est. 15–25% cut on large-diff sessions, no quality loss.
- developer.md (new): combined **anti-thrash + edit-freshness rule** — re-Read a file after editing it before the next edit/patch; build patch context from current bytes with exact indentation and unique surrounding lines; don't re-run reads/edits on a file already fresh in context. Addresses both the loop sequences and the file-changed subset of edit/apply_patch errors with one rule (chosen over separate verbose patch-hygiene text for ROI).

## Tier-2 behavioral audit — repo-scout + pre-deploy-checker (via @agent-auditor)

Ran the two remaining bash subagents in parallel to test whether the raw-bash/zero-sandbox pattern (already confirmed on architect 68% and developer 24%) is **roster-wide**. Tier-1 agentmemory weak (<0.016). agent-smith never ingested the session DBs; read only the distilled @agent-auditor templates.

**Confirmed roster-wide.** Both offend, repo-scout worst by ratio:

- **repo-scout** (window: all; total 4.7M tok): **26/27 file-read bash commands raw (96%)**, `ctx_execute` used: **no**. Plus native-Read thrash — 230 read calls; one session (`ses_24fe6a27cffeL7tznhZy022M2j`) burned **1.4M tokens on a 61-repeat read-loop**. 21 loop sequences, 0 errors. The agent re-reads the same files raw instead of sandboxing or caching.
- **pre-deploy-checker** (window: all, 3 sessions; total 7.3M tok): **79/110 bash calls (72%)** raw `cat`/`grep`/`find`/`head`/`tail`/`ls`. Unlike the others it *does* reach for the sandbox sometimes (37 `ctx_execute` calls in other sessions) but still defaults to raw bash for analysis. Priciest session `ses_196ca4ddcffemteQi6YB2o38QU` 4.45M tok driven by raw file-read loops. 17 loops, 0 errors.

Both files already carried a *soft* context-mode directive (repo-scout L56, pre-deploy L35) — runtime proves soft directives are ignored, same lesson as developer L28.

Fixes applied (user-approved):
- repo-scout.md L56: soft directive **sharpened into a HARD RULE** — scan-never-ingest; file-CONTENT reads (`cat`/`grep`/`rg`/`find`/`head`/`tail` + native Read used to explore) MUST route through `ctx_execute_file`/`ctx_execute`; native Read reserved for quoting one specific file. **Plus an anti-re-read clause** — don't re-scan a file already pulled this run (targets the 1.4M-token read-loop directly).
- pre-deploy-checker.md L35: soft directive **sharpened into a HARD RULE** — file-CONTENT scans (`grep`/`rg`/`cat`/`find`/`head`/`tail`, diffs, migrations, Dockerfiles) route through sandbox; reserve raw bash for state/metadata only (`git diff --name-only`, existence checks).

Both est. 15–25% token cut at equal quality — same lever as architect/developer.

### Roster-wide conclusion

The raw-bash-file-read + under-used-sandbox anti-pattern is now confirmed on **all four bash-using agents** (architect, developer, repo-scout, pre-deploy-checker). Root cause: soft/buried context-mode directives. Fix pattern that worked: a single explicit HARD RULE drawing the read-to-edit (native) vs read-to-understand (sandbox) line, plus an anti-re-read/anti-thrash clause where loops were observed. Future new bash agents should ship this hard rule from day one.
