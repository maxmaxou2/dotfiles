@RTK.md

# agentmemory — recall at task start

Persistent memory MCP available (`memory_smart_search`, `memory_recall`, `memory_save`).

- **At the start of a non-trivial task on a known project, call `memory_smart_search` once** with the task topic to pull relevant past decisions/context before proceeding. Skip for trivial one-off questions.
- After a notable decision, bug fix, or discovered convention, call `memory_save` to persist it.
- If the memory MCP tools are absent (shim not connected), continue normally — capture hooks still record the session.
