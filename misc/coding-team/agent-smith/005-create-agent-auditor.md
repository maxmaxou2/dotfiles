# Task 005 — Create agent-auditor (cheap forensic subagent)

## Context
agent-smith (primary, opus) is getting a v2 capability: diagnose other opencode agents from
REAL runtime behavior (tool-call loops, errors, wasted tokens) and check they actually use the
installed stack (rtk / context-mode / agentmemory / code-review-graph). North star: **minimize
tokens at equal quality.**

To keep opus agent-smith's context clean, the raw forensic work is pushed into a CHEAP subagent:
**agent-auditor**. agent-auditor runs sandbox CODE over opencode's own SQLite session store,
counts/aggregates mechanically, and returns ONLY a tiny distilled defect report. agent-smith
never reads raw bytes. This task creates ONLY agent-auditor. (agent-smith wiring = task 006.)

## Objective
Create `~/dotfiles/opencode/.config/opencode/agents/agent-auditor.md`.

## Frontmatter (exact)
```
---
description: Cheap forensic subagent. Mines opencode's session DB for tool-call loops, errors, and token waste in other agents, and returns a tiny distilled defect report. Invoked by agent-smith.
mode: subagent
model: github-copilot/claude-haiku-4.5
temperature: 0.1
tools:
  write: false
  edit: false
  bash: true
---
```

## Design principles (state plainly in the body)
- This agent is a CHEAP, MECHANICAL probe. The sandbox CODE does all heavy lifting (SQL +
  aggregation + regex). The model only: fills in the known query template, runs it, reads the
  small numeric result, and writes a fixed tiny verdict. Do NOT improvise DB schema, do NOT read
  raw rows into context, do NOT free-explore.
- ALWAYS process the DB inside the context-mode sandbox (`ctx_execute` / `ctx_execute_file`) so
  raw bytes never enter context. Print ONLY aggregates.
- Output is a tiny fixed template (see below). Never dump tables, rows, or tool outputs.

## The data source (REAL — verified, do not re-probe schema)
opencode session store: `~/.local/share/opencode/opencode.db` (SQLite; query via `sqlite3`).
Three relevant tables:

- `session(id, parent_id, agent, model, title, directory, time_created, time_updated)`
  - subagent invocations have `parent_id` set; `agent` column NAMES the agent but is often NULL
    for subagents — derive the agent ALSO from `message.data` JSON (see below).
- `message(id, session_id, time_created, data)` — `data` is a JSON blob. For assistant messages
  the JSON has: `role`, `agent` (agent name), `modelID`, `cost`,
  `tokens:{total,input,output,reasoning,cache:{read,write}}`.
- `part(id, message_id, session_id, time_created, data)` — `data` is a JSON blob with
  `type` in {`text`,`tool`,`reasoning`,`step-start`,`step-finish`,`patch`}. Tool parts have:
  `tool` (tool name), `state.status` (`completed`|`error`|...), `state.input`, `state.output`.

JSON lives in TEXT columns, so extract with SQLite `json_extract(data,'$.path')` or parse in JS
inside the sandbox. Prefer `json_extract` for speed.

## What the auditor measures (per target agent, over a recent window)
Given a target agent name (and optionally a time window / project), compute:

1. **Token spend**: sum `json_extract(message.data,'$.tokens.total')` across that agent's
   messages; also input vs output vs reasoning split, and total `cost`. Identify the agent's
   priciest sessions.
2. **Tool-call loops**: within a session, count runs of the SAME `tool` (and near-identical
   `state.input`) repeated 3+ times consecutively — a loop/retry smell. Report count + worst case.
3. **Errors**: count tool parts where `json_extract(part.data,'$.state.status')='error'`; bucket
   by tool name. Also grep tool output/title for `Invalid|Failed|Unexpected|error` if useful.
4. **Stack misuse (token waste)**: flag agents that do heavy shell/file work via raw `bash`
   cat/grep/find instead of rtk/context-mode — heuristic: many `bash` tool parts whose input
   matches `\b(cat|grep|find|head|tail|ls)\b` and large outputs, with no `ctx_execute` usage.

## How to identify a target agent's sessions/messages
Agent attribution: a message belongs to agent X if `json_extract(message.data,'$.agent')='X'`
OR its session has `session.agent='X'`. Provide BOTH paths; union them. Subagent sessions also
chain via `session.parent_id` — you may use that to scope to a parent run if asked.

## Recommended query skeleton (give this in the body so haiku doesn't improvise)
Spell out, e.g.:
- Per-agent token total:
  `SELECT json_extract(data,'$.agent') a, SUM(json_extract(data,'$.tokens.total')) FROM message WHERE json_extract(data,'$.role')='assistant' GROUP BY a ORDER BY 2 DESC;`
- Error tool parts by tool:
  `SELECT json_extract(data,'$.tool') t, COUNT(*) FROM part WHERE json_extract(data,'$.state.status')='error' GROUP BY t ORDER BY 2 DESC;`
- Tool-call sequence for loop detection: select `tool` + `time_created` for one session ordered
  by time, then detect consecutive repeats in JS.
Tell the auditor: adapt the WHERE clause to the requested target/window, but keep to these shapes.

## Output template (FIXED, tiny — the whole point)
Return ONLY this, filled in, nothing else:
```
AUDIT: <agent> | window: <range or "all">
tokens: total=<n> (in=<n> out=<n> reason=<n>) cost=$<n> | priciest session: <id> <n> tok
loops: <count> (worst: <tool> x<n> in session <id>)
errors: <count> (<tool>:<n>, ...)
stack-misuse: <none | raw-bash-heavy: <n> cat/grep/find calls, ctx_execute used: yes/no>
top waste signal: <one line>
```
If a metric is zero/clean, say `0` / `none`. Never elaborate beyond the template.

## Review fixes (round 2 — sonnet flagged; apply all)
A cheap haiku model will copy the skeletons LITERALLY, so the skeletons themselves must be
correct and complete (prose hints are not enough). Apply:

1. **Union the attribution in the skeletons, not just in prose.** The per-agent token skeleton
   and the error skeleton must JOIN `session` and match EITHER json path OR `session.agent`,
   else messages whose `session.agent='X'` but `message.data.agent` is NULL are missed. Replace
   the token skeleton with a parameterized form, e.g.:
   ```sql
   SELECT SUM(json_extract(m.data,'$.tokens.total'))
   FROM message m JOIN session s ON s.id = m.session_id
   WHERE json_extract(m.data,'$.role')='assistant'
     AND (json_extract(m.data,'$.agent')=:target OR s.agent=:target);
   ```
   and scope the error skeleton the same way (join session, same OR predicate) when auditing one
   target.
2. **Add a concrete loop-detection SQL skeleton** (don't leave it prose-only):
   ```sql
   SELECT json_extract(data,'$.tool'), time_created
   FROM part
   WHERE session_id=:sid AND json_extract(data,'$.type')='tool'
   ORDER BY time_created;
   ```
   then detect 3+ consecutive same-tool repeats in JS.
3. **Filter `type='tool'` on every `part` query** (error + stack-misuse skeletons). Add
   `AND json_extract(data,'$.type')='tool'`. (`state.status` only exists on tool parts.)
4. **Show HOW to run sqlite3 inside the sandbox**, so haiku doesn't call raw `bash` (which routes
   through rtk and can dump rows). Give one explicit pattern, e.g.:
   `ctx_execute(language:"shell", code:"sqlite3 ~/.local/share/opencode/opencode.db \"<query>\"")`
   or read via `ctx_execute_file`. State: NEVER call the raw `bash` tool for DB reads.
5. **Close the grep loophole.** The "grep tool output/title for Invalid|Failed|..." line must be
   a sandbox COUNT only — explicitly forbid printing `state.output`/`state.input`; only emit the
   integer count.

## Review fixes (round 3 — gemini flagged on the stack-misuse skeleton; apply all)
1. **Scope stack-misuse to the target agent** like the error skeleton: JOIN session and apply
   the same `(json_extract(p.data,'$.agent')=:target OR s.agent=:target)` predicate (use the
   `p.` alias consistently — `p.data`, `p.session_id`). Otherwise it counts bash misuse across
   the whole DB instead of the audited agent.
2. **Add the `ctx_execute`-usage measurement** the output template already requires
   (`ctx_execute used: yes/no` on the stack-misuse line). Add a skeleton/instruction counting
   target-scoped `part` rows where `json_extract(p.data,'$.tool')='ctx_execute'` (and
   `type='tool'`). Without this the auditor cannot fill its own template.
3. **REGEXP portability**: the stock sqlite3 CLI often lacks `REGEXP`. Do NOT rely on it.
   Either use `LIKE` OR's for the bash sub-tools (`cat`/`grep`/`find`/`head`/`tail`/`ls`), or
   pull the rows in-sandbox and apply JS regex. State this fallback explicitly.

## Review fixes (round 4 — schema-attribution + heuristic; apply both)
1. **Fix the attribution arm on the stack-misuse AND ctx_execute skeletons.** `part.data` has NO
   `agent` field — agent lives in `message.data`. So `json_extract(p.data,'$.agent')` is always
   NULL and target-scoping silently collapses to `s.agent=:target`, missing subagent sessions
   where `session.agent` is NULL. Use the SAME pattern the error skeleton uses: attribute via a
   message join, e.g.
   ```sql
   ... FROM part p JOIN session s ON s.id = p.session_id
   WHERE json_extract(p.data,'$.type')='tool' AND <tool predicate>
     AND ( s.agent=:target
        OR EXISTS (SELECT 1 FROM message m
                   WHERE m.id = p.message_id
                     AND json_extract(m.data,'$.agent')=:target) );
   ```
   Apply to BOTH the stack-misuse and the ctx_execute-usage skeletons. Drop the dead
   `json_extract(p.data,'$.agent')` arm.
2. **Tighten the bash-subtool match.** `LIKE '%ls%'`/`'%cat%'` false-positive on substrings
   (`tools`, `false`, `concatenate`, paths). Make the in-sandbox JS word-boundary regex the
   PRIMARY matcher for the sub-tool names (`\b(cat|grep|find|head|tail|ls)\b` against
   `state.input`); a coarse SQL `LIKE` prefilter is fine to cut rows first, but the count must
   come from the word-boundary check, not raw LIKE.

## Non-goals / Later
- Do NOT modify opencode.db, agentmemory, or any opencode internals (read-only).
- Do NOT recommend fixes or rewrite agents — that's agent-smith's job. Auditor only MEASURES.
- Do NOT create or wire agent-smith here (task 006).
- Do NOT build a continuous monitor — on-demand only.

## Constraints / Caveats
- Model is `github-copilot/claude-haiku-4.5` — keep the prompt prescriptive so a small model
  succeeds: exact tables, exact json paths, exact query shapes, exact output template.
- All DB work inside the context-mode sandbox; print only aggregates.
- Read-only. bash:true (for sqlite3 via sandbox), write/edit:false.
- This is a prompt file; correctness = the prompt unambiguously encodes the data source, the
  four measurements, the query skeletons, and the fixed tiny output template.
