# context-mode — MANDATORY routing rules

context-mode MCP tools available. Rules protect context window from flooding. One unrouted command dumps 56 KB into context.

## Think in Code — MANDATORY

Analyze/count/filter/compare/search/parse/transform data: **write code** via `context-mode_ctx_execute(language, code)`, `console.log()` only the answer. Do NOT read raw data into context. PROGRAM the analysis, not COMPUTE it. Pure JavaScript — Node.js built-ins only (`fs`, `path`, `child_process`). `try/catch`, handle `null`/`undefined`. One script replaces ten tool calls.

## BLOCKED — do NOT attempt

### curl / wget — BLOCKED
Shell `curl`/`wget` intercepted and blocked. Do NOT retry.
Use: `context-mode_ctx_fetch_and_index(url, source)` or `context-mode_ctx_execute(language: "javascript", code: "const r = await fetch(...)")`

### Inline HTTP — BLOCKED
`fetch('http`, `requests.get(`, `requests.post(`, `http.get(`, `http.request(` — intercepted. Do NOT retry.
Use: `context-mode_ctx_execute(language, code)` — only stdout enters context

### Direct web fetching — BLOCKED
Use: `context-mode_ctx_fetch_and_index(url, source)` then `context-mode_ctx_search(queries)`

## REDIRECTED — use sandbox

### Shell (>20 lines output)
Shell ONLY for: `git`, `mkdir`, `rm`, `mv`, `cd`, `ls`, `npm install`, `pip install`.
Otherwise: `context-mode_ctx_batch_execute(commands, queries)` or `context-mode_ctx_execute(language: "shell", code: "...")`

### File reading (for analysis)
Reading to **edit** → reading correct. Reading to **analyze/explore/summarize** → `context-mode_ctx_execute_file(path, language, code)`.

### grep / search (large results)
Use `context-mode_ctx_execute(language: "shell", code: "grep ...")` in sandbox.

## Tool selection

0. **MEMORY**: `context-mode_ctx_search(sort: "timeline")` — after resume, check prior context before asking user.
1. **GATHER**: `context-mode_ctx_batch_execute(commands, queries)` — runs all commands, auto-indexes, returns search. ONE call replaces 30+. Each command: `{label: "header", command: "..."}`.
2. **FOLLOW-UP**: `context-mode_ctx_search(queries: ["q1", "q2", ...])` — all questions as array, ONE call (default relevance mode).
3. **PROCESSING**: `context-mode_ctx_execute(language, code)` | `context-mode_ctx_execute_file(path, language, code)` — sandbox, only stdout enters context.
4. **WEB**: `context-mode_ctx_fetch_and_index(url, source)` then `context-mode_ctx_search(queries)` — raw HTML never enters context.
5. **INDEX**: `context-mode_ctx_index(content, source)` — store in FTS5 for later search.

## Parallel I/O batches

For multi-URL fetches or multi-API calls, **always** include `concurrency: N` (1-8):

- `context-mode_ctx_batch_execute(commands: [3+ network commands], concurrency: 5)` — gh, curl, dig, docker inspect, multi-region cloud queries
- `context-mode_ctx_fetch_and_index(requests: [{url, source}, ...], concurrency: 5)` — multi-URL batch fetch

**Use concurrency 4-8** for I/O-bound work (network calls, API queries). **Keep concurrency 1** for CPU-bound (npm test, build, lint) or commands sharing state (ports, lock files, same-repo writes).

GitHub API rate-limit: cap at 4 for `gh` calls.

## Output

Write artifacts to FILES — never inline. Return: file path + 1-line description.
Descriptive source labels for `search(source: "label")`.

# code-review-graph — graph-first navigation

First: call `code-review-graph_list_graph_stats_tool`. If `total_nodes > 0`, graph usable. If graph empty/missing/tool fails, **fallback to usual tools**.

## Prefer graph before file scanning

When graph usable, prefer code-review-graph over Grep/Glob/Read for structure, impact, and symbol lookup. Use file tools only to edit, confirm exact snippets, or when graph lacks coverage.

| Need | Tool |
|------|------|
| Availability check | `code-review-graph_list_graph_stats_tool` |
| Review changed code | `code-review-graph_detect_changes_tool` |
| Review with snippets | `code-review-graph_get_review_context_tool` |
| Blast radius | `code-review-graph_get_impact_radius_tool` |
| Callers/callees/tests/imports | `code-review-graph_query_graph_tool` (`callers_of`, `callees_of`, `tests_for`, `imports_of`, `importers_of`) |
| Name/keyword search | `code-review-graph_semantic_search_nodes_tool` |
| Repo structure | `code-review-graph_get_architecture_overview_tool` |

# rtk — silent shell rewriting

A plugin silently rewrites common shell commands (`ls`, `cat`, `grep`, `find`, `head`, `tail`, etc.) into token-efficient `rtk` equivalents BEFORE execution. The output you see is from the rewritten command, not the literal one you typed — different formatting, line numbering, truncation behavior. **This is intentional and correct. Trust the output. Do not retry, do not try to defeat the rewrite, do not assume something went wrong.** If you genuinely need the original command's raw byte output, invoke it through `context-mode_ctx_execute(language: "shell", ...)` — that path bypasses the plugin.

## Session Continuity

Skills, roles, and decisions persist for the entire session. Do not abandon them as the conversation grows.

## Memory

Session history is persistent and searchable. On resume, search BEFORE asking the user:

| Need | Command |
|------|---------|
| What did we decide? | `context-mode_ctx_search(queries: ["decision"], source: "decision", sort: "timeline")` |
| What constraints exist? | `context-mode_ctx_search(queries: ["constraint"], source: "constraint")` |

DO NOT ask "what were we working on?" — SEARCH FIRST.
If search returns 0 results, proceed as a fresh session.

## ctx commands

| Command | Action |
|---------|--------|
| `ctx stats` | Call `stats` MCP tool, display full output verbatim |
| `ctx doctor` | Call `doctor` MCP tool, run returned shell command, display as checklist |
| `ctx upgrade` | Call `upgrade` MCP tool, run returned shell command, display as checklist |
| `ctx purge` | Call `purge` MCP tool with confirm: true. Warns before wiping knowledge base. |

After /clear or /compact: knowledge base and session stats preserved. Use `ctx purge` to start fresh.

# agentmemory — recall at task start

Persistent memory MCP available (`memory_smart_search`, `memory_recall`, `memory_save`).

- **At the start of a non-trivial task on a known project, call `memory_smart_search` once** with the task topic to pull relevant past decisions/context before proceeding. Skip for trivial one-off questions.
- After a notable decision, bug fix, or discovered convention, call `memory_save` to persist it.
- If the memory MCP tools are absent (shim not connected), continue normally — capture hooks still record the session.
