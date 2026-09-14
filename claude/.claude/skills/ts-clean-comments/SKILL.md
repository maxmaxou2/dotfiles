---
name: ts-clean-comments
source: "ertugrul-dmr/clean-code-skills (https://github.com/ertugrul-dmr/clean-code-skills), tightened locally"
date_added: "2026-09-11"
description: Use when writing, fixing, editing, or reviewing TypeScript/JavaScript comments and TSDoc/JSDoc. Enforces Clean Code principles strictly—no metadata, no redundancy, no commented-out code, no decision archives, and comments no longer than the code they explain. Prefers changing the code over keeping a comment.
when_to_use: |
  Also trigger on: commented-out code blocks, TODO/FIXME banners, author/ticket/date metadata in comments or TSDoc, TSDoc that no longer matches the code, redundant comments that restate the code (e.g. `i += 1; // increment i`), multi-line comments above short functions, comments narrating how a decision was reached or what bug it once fixed, step-label comments inside long functions, or asks like "is this comment useful", "why is this block commented", "too many comments".
---

# Clean Comments

The best comment is the code itself. A comment is a failure to express
intent in code; every one that survives must earn its place. When editing,
the default action for a comment is **delete**, then **shrink**, then
**replace with code**. Keeping it as-is needs a reason.

## The procedure — apply to every comment you touch

1. **Can the code say it?** Rename the identifier, extract a named constant,
   extract a function whose name is the comment, or turn the assumption into
   a thrown error with a message. If any of these removes the need for the
   comment, do it and delete the comment. Changing code to delete a comment
   is in scope, always.
2. **Is it still needed?** If it restates the code, describes history, or
   describes something derivable from the code, delete it.
3. **Is it too long?** Cut to the single constraint a reader cannot infer.
   One line is the target; two is the ceiling for anything but a file header.

## C1: No Inappropriate Information

No metadata. Author names, change history, ticket numbers, PR numbers,
version numbers, dates: Git holds those. A comment is a technical note about
the code as it is now.

## C2: Delete Obsolete Comments

A comment describing code that no longer exists or works differently is
worse than none. Delete on sight.

## C3: No Redundant Comments

```ts
// Bad - the code already says this
i += 1; // increment i
user.save(); // save the user

/** Add a new account. */        // Bad - restates the name
addAccount(data) { ... }

// Good - explains the one thing the code cannot
i += 1; // display is 1-indexed
```

A JSDoc/TSDoc block that paraphrases the signature is redundant. Delete it.
Prefer better names to doc blocks.

## C4: Write Comments Well — and Briefly

If a comment survives, write it well: precise words, correct grammar, no
rambling. **Proportion rule:** a comment must not be longer than the code it
explains. A five-line comment above a three-line function is a defect —
either the function needs a better name, or the comment needs to lose four
lines.

## C5: Never Commit Commented-Out Code

Delete it. Git remembers.

## C6: No Decision Archives

A comment states the constraint, not the story. Not: the alternatives that
were rejected, why they were rejected, the bug that motivated the change,
what the code used to do, which incident prompted it. That is PR-description
material. If a future reader needs the story, `git log -L` gives it to them.

```ts
// Bad - an archive
// We tried keepAlive here but sockets leaked because createConnection closes
// over one target, and a pooled socket cannot be reused for another host,
// which is what caused the leak in the proxy path. So keepAlive is off.
const agent = new Agent({ keepAlive: false });

// Good - the constraint
// Sockets close over one target; pooling would leak them.
const agent = new Agent({ keepAlive: false });

// Better - no comment
const agent = new Agent({ keepAlive: false }); // one target per socket
```

## C7: Step Labels Mean "Extract a Function"

```ts
// Bad
// Refresh expired tokens
...12 lines...
// Fetch profiles in parallel
...8 lines...

// Good
await refreshExpiredTokens(accounts);
const profiles = await fetchProfiles(accounts);
```

A comment that labels a block inside a function is the name of a function
that has not been extracted yet. Extract it.

## C8: File Headers Are One Sentence

A module header says what the module is. Not how it works, not its history,
not the three other modules it is different from. If the header is longer
than a few lines, the module either does too much or the header does.

## C9: Field and Parameter Trailers

```ts
this.mode = 'normal';    // normal | select | add
```

A short trailing comment on a field is acceptable when it carries a domain
fact (a value set, a unit). A trailer that names the field again is not.
A union type or an enum beats the comment when the language allows it.

## The Goal

Read the file with the comments hidden. If it is unclear, fix the code, not
the comment. If it is clear, the comment was never needed.
