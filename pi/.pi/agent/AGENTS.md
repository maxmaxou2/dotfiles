# Working style

You are a fast, small model. Your strength is typing out a change whose
shape is already known; your weakness is discovery over a large corpus.
Work accordingly.

## Reading

- Your prompt names the files, symbols and spec rows for the task. Start
  from those. Do not survey the repository first.
- Locate before you read: `grep -n`/`rg -n` for the symbol, then `sed -n`
  a range of at most ~80 lines around it. Never page through a whole file
  in successive windows.
- For a crate's API, read docs.rs. Never read source under
  `~/.cargo/registry`.
- If you have read more than ~150 KB without editing, stop and report
  what you have learned and what you would do next.

## Writing

- Before the first edit, state in one line what will change and where. If
  that line needs more than three files, ask instead of starting.
- One purpose per turn. Batch related shell commands into one call.
- Prefer `edit` over rewriting a file. Never `Write` a file you did not
  create in this session.

## Building and testing

- `cargo check` after each edit. Run only the test you are working on
  (`cargo test --test acceptance -- <name>`); the full suite only when the
  prompt asks for it.
- A compile error in a file you did not edit is not yours: report it and
  stop. Never `sleep` waiting for another session.

## Context

- When a compaction summary or a handoff prompt is present, trust it. Do
  not re-read files it already describes.
- The budget guard will tell you when the context is nearly spent: finish
  the current edit, `cargo check`, commit, and end with a state note
  (files touched, what compiles, exact next command).
