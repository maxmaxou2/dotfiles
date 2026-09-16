---
name: ts-clean-names
description: Improve TypeScript identifiers when naming or renaming code, or reviewing cryptic, encoded, ambiguous, misleading, or side-effect-hiding names. Preserve established project and domain conventions.
metadata:
  source: "ertugrul-dmr/clean-code-skills (https://github.com/ertugrul-dmr/clean-code-skills)"
  date_added: "2026-09-11"
---

# Clean TypeScript Names

Choose names from meaning, usage, and domain context rather than from a declaration in isolation.

## Work from Context

Before renaming an identifier, inspect its type, callers, tests, and surrounding domain language. Use symbol-aware rename tooling when available, or update and verify every reference.

Preserve names required by public APIs, serialized data, schemas, framework contracts, generated code, or external libraries unless changing that contract is explicitly in scope. Prefer the project's established vocabulary over a personal convention, and avoid rename-only churn when clarity would not materially improve.

## N1: Reveal Intent

A name should communicate the identifier's role and relevant domain meaning. Comments may explain the domain or the reason behind a decision; they should not be needed merely to decode a name.

```ts
// Unclear
const d = 86_400;

// Clear
const SECONDS_PER_DAY = 86_400;

// Unclear
function proc(values: number[]) {
  return values.filter((value) => value > 0);
}

// Clear
function filterPositiveNumbers(numbers: number[]) {
  return numbers.filter((number) => number > 0);
}
```

## N2: Name the Contract at the Right Abstraction Level

Describe stable behavior rather than incidental implementation. Mention a data structure or mechanism when callers depend on it; otherwise name the capability or domain result.

```ts
// Focuses on the generic container operation
function makeMap(users: User[]): Map<string, User> {
  return new Map(users.map((user) => [user.id, user]));
}

// Describes why the index exists
function indexUsersById(users: User[]): Map<string, User> {
  return new Map(users.map((user) => [user.id, user]));
}
```

## N3: Use Domain Language and Established Conventions

Prefer terms already used by the product, domain, standard library, or codebase. Use pattern names such as `Factory`, `Repository`, or `Adapter` only when the code fulfills that role; avoid vague containers such as `Manager`, `Helper`, or `Util` when a more precise concept exists.

```ts
function calculateMonthlyLoanPayment(
  principalCents: number,
  annualInterestRate: number,
  termMonths: number,
) {
  // ...
}
```

## N4: Remove Ambiguity Without Padding Names

Include distinctions that a reader needs, such as units, direction, ownership, or lifecycle state. Name length should follow from the context needed for clarity, not from scope alone. Short conventional names are acceptable in tiny, obvious scopes.

```ts
function renameFile(sourcePath: string, destinationPath: string) {
  // ...
}

const requestTimeoutMs = 5_000;
const MAX_RETRY_ATTEMPTS = 5;

const total = numbers.reduce((sum, number) => sum + number, 0);
```

## N5: Avoid Type and Scope Encodings

Do not repeat information already expressed by TypeScript's types or lexical scope. Hungarian notation such as `strName`, `arrUsers`, and `nCount` adds noise. Meaningful qualifiers such as `priceCents`, `timeoutMs`, or `userIds` are domain information, not type encodings.

```ts
const name = "Alice";
const users: User[] = [];
const count = 0;

interface UserRepository {
  findById(userId: string): Promise<User | undefined>;
}
```

Do not mechanically remove an `I` interface prefix when the project consistently uses it or when it is part of a public API. Consistency and compatibility outweigh a general style preference.

## N6: Match Names to TypeScript Roles

- Use noun phrases for types, interfaces, classes, and values representing entities.
- Use verb phrases for functions and methods.
- Use predicates such as `isExpired`, `hasAccess`, `canRetry`, or `shouldRefresh` for booleans.
- Prefer `onSave` for a supplied event callback and `handleSave` for the implementation that responds to it when that distinction matches the codebase.
- Add an `Async` suffix only when it distinguishes an asynchronous operation from a synchronous counterpart or follows an established project convention.

## N7: Expose Caller-Relevant Behavior

Function names should set accurate expectations about results and caller-visible effects. Distinguish operations such as finding, loading, creating, updating, or ensuring when the distinction matters. Transparent implementation details such as memoization do not need to be enumerated in the name.

```ts
// Misleading: this may create persisted state
async function getPreferences(userId: string): Promise<UserPreferences> {
  const preferences = await preferenceStore.find(userId);
  return preferences ?? preferenceStore.create(userId);
}

// Clear: creation is part of the contract
async function getOrCreateUserPreferences(
  userId: string,
): Promise<UserPreferences> {
  const existingPreferences = await preferenceStore.find(userId);
  return existingPreferences ?? preferenceStore.create(userId);
}
```

If an accurate name becomes unwieldy because a function performs unrelated operations, split the behavior instead of encoding every step into the name.
