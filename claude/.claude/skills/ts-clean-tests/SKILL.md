---
name: ts-clean-tests
description: Write, repair, or refactor TypeScript tests that protect observable behavior and regressions without flakiness or implementation coupling. Use for coverage gaps, boundary cases, async tests, skipped or focused tests, and test design.
metadata:
  source: "ertugrul-dmr/clean-code-skills (https://github.com/ertugrul-dmr/clean-code-skills)"
  date_added: "2026-09-11"
---

# Clean TypeScript Tests

Write tests that provide proportionate confidence in observable behavior. Favor meaningful failure signals over assertion counts, coverage percentages, or rigid testing rituals.

## Work in Project Context

Before changing tests, inspect the implementation, public types, callers, nearby tests, test configuration, and package scripts. Follow the project's existing runner, assertion style, fixture conventions, and test layers; do not introduce another test framework or dependency unless requested.

Run the narrowest relevant test before and after a change when practical, then run the affected suite in proportion to the change. Never weaken an assertion, delete a failing test, or update a snapshot merely to make the suite pass without understanding the behavioral difference.

## T1: Test Observable Behavior and Risk

Prioritize public contracts, important failure modes, regressions, and boundaries. Avoid testing private implementation details or adding tests for trivial code unless that behavior is a meaningful contract.

Each test should protect a behavior that matters, reveal a plausible failure, or document an intentional edge case. “Test everything that could possibly break” is not a workable stopping condition.

## T2: Cover Boundaries and Equivalence Classes

Select cases from materially different behavior classes. Depending on the contract, useful candidates include empty and singleton inputs, exact limits, values immediately around limits, missing or malformed data, duplicates, ordering, and success and failure paths. Do not enumerate combinations that exercise the same behavior.

Before:

```ts
test("clamps a value", () => {
  expect(clamp(5, 0, 10)).toBe(5);
});
```

After:

```ts
it.each([
  { caseName: "below the minimum", value: -1, expected: 0 },
  { caseName: "at the minimum", value: 0, expected: 0 },
  { caseName: "inside the range", value: 5, expected: 5 },
  { caseName: "at the maximum", value: 10, expected: 10 },
  { caseName: "above the maximum", value: 11, expected: 10 },
])("clamps a value $caseName", ({ value, expected }) => {
  expect(clamp(value, 0, 10)).toBe(expected);
});
```

## T3: Preserve Regression Evidence

When fixing a bug, reproduce the externally observable failure with a test when practical, then keep that test after the fix. Add nearby cases only when they share the same risky condition or root cause; do not turn “bugs cluster” into exhaustive permutation testing.

A regression test should fail for the original defect and pass for the intended behavior. Avoid assertions tied only to the implementation that happened to contain the bug.

## T4: Keep One Behavior Per Test

“One behavior” is more useful than “one assertion.” Multiple assertions are appropriate when they jointly describe one outcome; split a test when it contains unrelated actions, contracts, or reasons to fail.

Use test names that state the scenario and expected behavior. Keep setup focused on the behavior under test so failures remain easy to diagnose.

```ts
test("activation records the active state and activation time", () => {
  const user = createUser();
  const activatedAt = new Date("2026-09-14T10:00:00Z");

  user.activate(activatedAt);

  expect(user.isActive).toBe(true);
  expect(user.activatedAt).toEqual(activatedAt);
});
```

## T5: Make Async and Time-Based Tests Deterministic

Await or return every asynchronous operation and assert expected rejections explicitly. Control time, randomness, environment variables, network responses, and other nondeterministic inputs at an appropriate boundary. Avoid arbitrary sleeps and retries that conceal races.

Restore fake timers, spies, global stubs, and mutated process state after each test. Use the equivalent APIs from the project's runner.

Before:

```ts
test("a session expires", async () => {
  const session = new Session({ ttlMs: 100 });
  await new Promise((resolve) => setTimeout(resolve, 110));

  expect(session.isExpired()).toBe(true);
});
```

After using Vitest's existing timer support:

```ts
afterEach(() => {
  vi.useRealTimers();
});

test("a session expires when its TTL elapses", () => {
  vi.useFakeTimers();
  vi.setSystemTime(new Date("2026-09-14T10:00:00Z"));
  const session = new Session({ ttlMs: 100 });

  vi.advanceTimersByTime(100);

  expect(session.isExpired()).toBe(true);
});
```

## T6: Keep Tests Independent and Choose Doubles Deliberately

Tests must not depend on execution order or state leaked by another test. Create or reset mutable state explicitly.

Use stubs or fakes at slow or nondeterministic boundaries when a unit test is the right layer. Do not mock the subject under test or assert internal call sequences unless the interaction itself is the contract. Test adapters against a realistic integration when compatibility with a database, filesystem, service, or runtime is the risk; an in-memory fake is useful only when its semantics are trustworthy.

## T7: Use Coverage as a Diagnostic

Use the repository's existing coverage command and configuration. Coverage can reveal unexercised branches, but an uncovered line does not automatically justify a test, and a covered line does not prove useful behavior.

Do not add a coverage tool or chase an arbitrary percentage unless the task or project policy requires it. Investigate meaningful gaps first, especially error paths and conditional branches.

## T8: Treat Skips, Focused Tests, and Snapshots as Signals

Do not leave `.only` or equivalent focused tests in committed code. A skip or todo should be intentional and actionable, with a concrete condition or tracking reference when the project uses them; vague “flaky, fix later” notes are not enough. Prefer placing environment-dependent behavior in the appropriate integration suite over permanently skipping it.

Review snapshot differences as behavioral changes. Update a snapshot only after confirming the new output is intended, and prefer focused assertions when a broad snapshot would obscure the contract.

## T9: Test Runtime and Type Contracts at the Right Layer

Runtime tests cannot prove compile-time TypeScript constraints. When public type behavior matters, use the project's existing type-test mechanism, such as `expectTypeOf`, `tsd`, or checked `@ts-expect-error` cases. Test the corresponding runtime behavior separately when it also has a runtime contract.

Avoid `any` in tests merely to bypass the type system. Represent untrusted inputs as `unknown` at the boundary, and use fixture builders that create valid defaults while allowing each test to override only relevant fields.

## T10: Keep Feedback Fast Enough for the Test Layer

Unit tests should be fast enough to run frequently, while integration and end-to-end tests may reasonably cost more. Use measured suite bottlenecks and project budgets rather than a universal per-test threshold.

Do not replace a valuable integration test with a shallow mock solely for speed. Choose the cheapest test layer that still exercises the risk being protected.
