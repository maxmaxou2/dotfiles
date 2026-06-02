# Audit Report: Architect Brief Extraction

**Date:** 2026-06-01

## Roster Audit Verdict

| agent | verdict | reasoning (usage/ROI/distinctness/cohesion) | proposed action |
|---|---|---|---|
| architect | SLIM | High usage but poor token ROI due to heavy bash loops (2,999 calls) and zero reasoning (0.7%). Distinct role (system design), but cohesion leaks into raw code discovery. | Restrict raw bash, enforce `ctx_execute`/`repo-scout` delegation. To enable brief extraction, explicitly enforce reasoning mode. |

## Behavioral Findings
The premise of extracting briefs from reasoning is structurally blocked: the architect agent currently does not use reasoning mode in any meaningful capacity. Furthermore, writing briefs is not its primary token drain.

### Key Metrics (from agent-auditor)
- **Output vs Reasoning:** 4.5M output tokens vs 65K reasoning tokens (0.7%). 
- **Output Size:** Median output is 167 chars (~42 tokens). The agent is not writing monolithic long briefs; it is writing thousands of short outputs.
- **Tool Waste:** 2,999 `bash` calls vs 23 `ctx_execute` calls. The agent iterates heavily on shell commands instead of context-mode tools.
- **Top Waste:** One session consumed 1.3M tokens (13.9% of total) across 2,182 messages due to bash iteration loops.

### Analysis
1. **No Reasoning to Extract From:** You cannot extract briefs from reasoning because the agent doesn't reason. It generates output directly. 
2. **Briefs Are Already Short:** The user's concern about "losing tokens on the output of briefs" is unfounded. Briefs are already tiny (median 42 tokens).
3. **Waste is in Volume:** The token drain comes from the high volume of iterative turns (specifically bash discovery loops without cached context), not from generating massive Task Brief files. 

### Next Steps
To achieve the goal of cheap brief generation and better token ROI, we must either:
1. **Option A (Fix Bash Bleed):** Stop the massive token bleed by stripping its raw `bash` access and forcing `repo-scout` or `ctx_execute`.
2. **Option B (Force Reasoning):** Upgrade the agent to a reasoning-native model, force extended reasoning, and pipe the thought process to a cheaper subagent for brief formatting.
