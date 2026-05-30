# Roster Audit Report — opencode agent fleet

_Read-only audit. 8 agents inspected via context-mode sandbox parse. No files edited._

## 1. Summary

Fleet healthy. All 8 agents pass usage+wiring, distinctness, and cohesion tests; none warrant KILL or MERGE. Wiring graph is fully connected through the `architect → developer → code-reviewer-* / repo-scout` loop; `agent-smith` and `pre-deploy-checker` are correctly orphan-by-design (user-/architect-invoked, not peer-wired). No dangling `@diff-summarizer` or stale refs remain — the only `@code-reviewer-*` "dangling" hits are wildcard prose (`@code-reviewer-*`) and truncated-line artifacts, not real targets. The one real fleet-wide gap is tool-convention coverage: 4 agents that do shell/data work omit any mention of `rtk` and `context-mode`. Verdicts: 6 KEEP, 2 SLIM (light tool-note injection, not restructuring). No CREATE justified.

## 2. @-mention wiring graph

```
architect              -> developer, repo-scout, code-reviewer-{opus,sonnet,gemini-flash}
developer              -> architect, repo-scout, code-reviewer-{sonnet,opus}
code-reviewer-opus     -> developer, architect, repo-scout
code-reviewer-sonnet   -> developer, architect, repo-scout
code-reviewer-gemini-flash -> developer, architect, repo-scout
repo-scout             -> (terminal, emits report only)
agent-smith            -> (none; user-invoked meta-agent)
pre-deploy-checker     -> (none; architect/user-invoked, terminal)
```

Called-by:
- architect ← developer, all 3 reviewers (return path)
- developer ← architect, all 3 reviewers
- repo-scout ← architect, developer, all 3 reviewers (most-invoked utility)
- code-reviewer-* ← architect, developer
- **orphans (by design, OK):** agent-smith (meta/user), pre-deploy-checker (terminal gate)

Dangling refs: **none real.** `@code-reviewer-*` (wildcard), `@code-reviewer` (mid-prose) are descriptive, not invocations. No `@diff-summarizer`. No `@architect-gemini-pro`.

## 3. Per-agent verdict table

| agent | mode | verdict | reasoning (usage / ROI / distinct / cohesion) | proposed action |
|---|---|---|---|---|
| architect | primary | **KEEP** | hub of loop / 1236w high but it's the orchestrator, justified / unique driver role / coherent | none (optionally trim verbosity later, low pri) |
| developer | subagent | **KEEP** | core implementer, well-wired / 775w fair / unique impl role / coherent | inject rtk/context-mode tool note (does shell/edits, lacks it) |
| code-reviewer-opus | subagent | **KEEP** | invoked by architect+developer / 689w fair / multi-model cross-check (intentional) / coherent | inject rtk/context-mode note; lockstep edit caveat |
| code-reviewer-sonnet | subagent | **KEEP** | same / same / intentional dup / coherent | inject rtk/context-mode note; lockstep edit caveat |
| code-reviewer-gemini-flash | subagent | **KEEP** | same / same / intentional dup / coherent | inject rtk/context-mode note; lockstep edit caveat |
| repo-scout | subagent | **KEEP** | most-invoked utility / 635w tight / unique recon role / coherent | inject rtk/context-mode note (heavy shell/grep scanner — biggest gap) |
| agent-smith | primary | **KEEP** | user-invoked meta / 739w tight / unique authoring role / coherent, already cites rtk+ctx+question | none |
| pre-deploy-checker | subagent | **KEEP** | terminal gate / 378w lean (just slimmed) / unique risk-gate role / coherent, already cites rtk+ctx | none |

_Note: the 3 code-reviewers are byte-identical except the model line (user-confirmed intentional). Maintenance caveat: any prompt edit MUST be applied to all 3 in lockstep._

No CREATE gap found. No missing capability has demand that passes the four tests; adding an agent now would fail distinctness/ROI.

## 4. Ranked action list (highest impact first)

1. **Inject rtk + context-mode tool-usage note into `repo-scout`** — highest impact: it is the most-invoked agent and does the heaviest shell/grep/find scanning, exactly the work the conventions govern. Currently zero coverage.
2. **Inject rtk + context-mode note into the 3 code-reviewers (opus, sonnet, gemini-flash) in lockstep** — they run diff/shell inspection with zero coverage; one shared snippet applied to all three identically.
3. **Inject rtk + context-mode note into `developer`** — performs edits and shell work, currently no coverage.
4. (low pri) **Trim architect verbosity** — 1236w is the fleet's largest; tighten redundant question-tool restatements once tool notes land. Not urgent.

## 5. Tool-convention coverage matrix

| agent | rtk | context-mode | question tool |
|---|---|---|---|
| architect | no | no | yes |
| agent-smith | yes | yes | yes |
| developer | no | no | yes (defers to @architect, intentional) |
| code-reviewer-opus | no | no | no |
| code-reviewer-sonnet | no | no | no |
| code-reviewer-gemini-flash | no | no | no |
| repo-scout | no | no | no |
| pre-deploy-checker | yes | yes | no (terminal, OK) |

**Gap:** rtk/context-mode missing in developer + 3 reviewers + repo-scout (5 agents). question-tool absence in subagents/terminals is expected and fine — only primaries need it.
