---
name: rust-clean-code
description: Write, refactor, or review Rust for correctness, idiomatic design, maintainability, and soundness. Use for Rust source, Cargo manifests, crate APIs, tests, async code, unsafe code, or Rust-focused reviews. Do not use for changes with no Rust-related surface unless explicitly requested.
---

# Rust Clean Code

Produce the smallest clear design that preserves behavior and makes invalid states difficult to represent. Apply Clean Code principles through Rust's type system and ecosystem rather than importing Java rules mechanically. Treat repository conventions, the pinned toolchain, MSRV, compatibility promises, and task scope as constraints.

## Establish the contract

- Read repository instructions plus relevant `Cargo.toml`, toolchain, rustfmt, Clippy, and CI configuration before judging code.
- Identify whether the crate is a library, binary, proc macro, embedded target, or FFI boundary. Calibrate panic policy, API stability, allocation, `unsafe`, and `no_std` expectations accordingly.
- Inspect the requested diff and enough surrounding code and tests to understand invariants. Do not turn a focused task into an unrelated rewrite.
- If a diff has no Rust source, Cargo metadata, generated bindings, build script, or Rust toolchain/CI impact, state that Rust-specific review is not applicable. Do not invent Rust findings; review broader files only if the user also requested a general review.

## Names and structure

- Follow Rust casing and ecosystem vocabulary. Use intention-revealing names whose length matches scope; avoid encodings, vague suffixes such as `Data` or `Manager`, and names that hide side effects.
- Follow `as_`/`to_`/`into_`, `iter`/`iter_mut`/`into_iter`, conversion-trait, getter, and constructor conventions.
- Keep functions cohesive and at a consistent abstraction level. Prefer guard clauses where they improve the happy path. Extract only a stable concept or meaningful duplication; avoid numeric rules for function length or argument count.
- Keep related code close and public surface narrow. Delete dead and commented-out code. Let rustfmt own formatting.
- Prefer direct code over speculative traits, generic parameters, helper layers, or macros. A small amount of duplication can be clearer than the wrong abstraction.

## Types, ownership, and APIs

- Model domain states with structs, enums, newtypes, and validated constructors. Avoid boolean blindness, sentinel values, stringly typed states, and public fields that bypass invariants.
- Prefer ownership and borrowing that express lifetime and mutation needs directly. Avoid needless `clone`, allocation, `Arc`, `Mutex`, interior mutability, or `'static` bounds; accept their cost at real ownership boundaries.
- Use visibility narrowly. Implement or derive common traits only when their semantics are honest. Prefer standard traits such as `From`, `TryFrom`, `AsRef`, `FromIterator`, and `Extend` over ad hoc equivalents.
- Treat public API changes as semver-sensitive. Check re-exports, trait implementability, exhaustiveness, auto traits, feature combinations, MSRV, and downstream type inference or coherence effects.
- Keep dependencies and enabled features minimal. Prefer the standard library when adequate, but do not recreate a mature crate solely to avoid a dependency.

## Control flow and failures

- Use iterators or explicit control flow according to whichever communicates intent better. Avoid clever chains, gratuitous collection, panic-prone indexing, and conversions that hide truncation or overflow.
- Return `Result` for recoverable failure and retain actionable source and context. Keep structured errors at library boundaries; broad dynamic errors can be appropriate at application boundaries.
- Do not panic on caller-controlled input in libraries. Use `unwrap` or `expect` only when an invariant makes failure impossible, with the invariant evident in code or expressed by a useful `expect` message.
- Make cleanup and state transitions correct on every early return and error path. Avoid fallible or unexpectedly blocking work in `Drop`.

## Unsafe, async, and performance

- Treat `unsafe` as a proof obligation. Minimize its scope, document each required invariant with a `// SAFETY:` comment, and expose a safe boundary only when every caller is protected. Check validity, alignment, initialization, aliasing, provenance, lifetimes, layout, unwinding, and thread safety as applicable.
- In async and concurrent code, make cancellation, blocking work, lock scope, backpressure, task ownership, error observation, and shutdown behavior explicit. Do not hold a synchronous or nonessential lock across `.await`.
- Make I/O, time, randomness, environment, and global state explicit enough to test.
- Optimize demonstrated hot paths and obvious algorithmic defects. Reduce copies and allocations where clarity survives; require measurement for non-obvious micro-optimization.

## Comments, docs, and tests

- Prefer code that explains itself. Comments should preserve intent, external constraints, invariants, or safety reasoning—not narrate syntax, record history, or retain obsolete code.
- Document public contracts and non-obvious behavior. Include `# Errors`, `# Panics`, and `# Safety` where applicable, plus examples that show why an API is useful.
- Test observable behavior, failure paths, and boundaries. Add regression tests for bugs. Keep tests deterministic, independent, and free of arbitrary sleeps or private implementation coupling.

## Verification

Use repository commands first. When no equivalent policy exists and the toolchain supports them, prefer:

```text
cargo fmt --all -- --check
cargo clippy --workspace --all-targets --all-features -- -D warnings
cargo test --workspace --all-targets --all-features
cargo test --workspace --doc
```

Do not assume `--all-features` is valid for mutually exclusive or target-specific features. Run the supported feature and target matrix when the change depends on it. Use Miri, sanitizers, Loom, fuzzing, benchmarks, or semver tooling only when risk warrants them and the repository supports them.

Clippy is evidence, not a substitute for reasoning. Its default groups are useful. Enable `pedantic` selectively or as established locally; never enable all of `restriction` or `nursery` by reflex. Scope and justify suppressions.

## Review checklist

Apply only the checks touched by the change:

- Trace normal, empty, malformed, boundary, partial-failure, cancellation, retry, and cleanup paths.
- Check overflow, lossy casts, indexing, UTF-8 or byte boundaries, units, equality, ordering, and time assumptions.
- Check needless copying, retained resources, reference cycles, stale state, races, deadlocks, lock order, task leaks, and blocking work in async contexts.
- Audit every panic and unsafe precondition reachable from ordinary runtime input.
- Check API naming, visibility, trait semantics, docs, semver, MSRV, features, target portability, build scripts, dependency impact, and licenses.
- Require focused tests for new behavior and repaired defects.

Report only actionable findings introduced or exposed by the change. Rank correctness, soundness, security, data loss, deadlock, and API breakage above style. Give the exact location, triggering scenario, consequence, and smallest credible fix. Separate confirmed defects from questions. If no finding remains, say so and list meaningful checks run and unverified risks.

## Primary references

- [The Rust Programming Language](https://doc.rust-lang.org/book/)
- [Rust API Guidelines](https://rust-lang.github.io/api-guidelines/checklist.html)
- [Rust Style Guide](https://doc.rust-lang.org/style-guide/)
- [Clippy documentation](https://doc.rust-lang.org/clippy/)
- [Rust Reference: undefined behavior](https://doc.rust-lang.org/reference/behavior-considered-undefined.html)
- [The Rustonomicon](https://doc.rust-lang.org/nomicon/)

Use current official documentation when a lint, edition, compiler behavior, or tool invocation may have changed.
