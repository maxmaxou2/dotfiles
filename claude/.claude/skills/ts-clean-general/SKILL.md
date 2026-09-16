---
name: ts-clean-general
source: "ertugrul-dmr/clean-code-skills (https://github.com/ertugrul-dmr/clean-code-skills)"
date_added: "2026-09-11"
description: Use when writing, fixing, editing, or reviewing TypeScript code quality. Enforces Clean Code's core principles—DRY, single responsibility, clear intent, no magic numbers, proper abstractions.
when_to_use: |
  Also trigger on: duplicated logic across files or branches (G5), magic numbers or hardcoded strings (G25), long if/else chains that should be union types plus polymorphism (G23), chained property access like `a.b.c.d` or long optional-chain trains (G36), functions juggling multiple responsibilities (G30), clever one-liners whose intent is not obvious (G16).
---

# General Clean Code Principles

## Critical Rules

**G3: Handle Boundary Conditions**

The empty case, the single-element case, and the last index are part of the contract. Say so in the return type.

```ts
// Bad - empty input returns -Infinity
function highestScore(scores: number[]): number {
  return Math.max(...scores);
}

// Good - the caller cannot ignore the empty case
function highestScore(scores: number[]): number | null {
  return scores.length === 0 ? null : Math.max(...scores);
}
```

**G5: DRY (Don't Repeat Yourself)**

Every piece of knowledge has one authoritative representation.

```ts
// Bad - one fact, spelled three times
const caTotal = subtotal * 1.0825;
const nyTotal = subtotal * 1.07;

// Good - the table is the single source of truth, keys included
const TAX_RATES = { CA: 0.0825, NY: 0.07 } as const;
type TaxedState = keyof typeof TAX_RATES;

function calculateTotal(subtotal: number, state: TaxedState): number {
  return subtotal * (1 + TAX_RATES[state]);
}
```

`Record<string, number>` would claim every string key yields a number, so `"TX"` would type-check and return `NaN`. Deriving the key type from the data makes it a compile error.

**G9: Delete Dead Code**

Unreachable branches, unused exports, commented-out blocks. Git remembers them; readers should not have to.

```ts
type Status = "active" | "closed";

// Bad - the third branch outlived the variant it handled
function label(status: Status): string {
  if (status === "active") return "Active";
  if (status === "closed") return "Closed";
  return "Pending";
}

// Good
function label(status: Status): string {
  return status === "active" ? "Active" : "Closed";
}
```

**G16: No Obscured Intent**

Don't be clever. Be clear.

```ts
// Bad - what does this do?
return ((x & 0x0f) << 4) | (y & 0x0f);

// Good - obvious intent
return packCoordinates(x, y);
```

**G23: Prefer Polymorphism to If/Else**

```ts
// Bad - will grow forever
function calculatePay(employee: {
  type: "SALARIED" | "HOURLY" | "COMMISSIONED";
  salary?: number;
  hours?: number;
  rate?: number;
  base?: number;
  commission?: number;
}): number {
  if (employee.type === "SALARIED") {
    return employee.salary ?? 0;
  } else if (employee.type === "HOURLY") {
    return (employee.hours ?? 0) * (employee.rate ?? 0);
  } else if (employee.type === "COMMISSIONED") {
    return (employee.base ?? 0) + (employee.commission ?? 0);
  }
  return 0;
}

// Good - each variant carries exactly its own fields
type Employee =
  | { kind: "salaried"; salary: number }
  | { kind: "hourly"; hours: number; rate: number }
  | { kind: "commissioned"; base: number; commission: number };

function calculatePay(employee: Employee): number {
  switch (employee.kind) {
    case "salaried":
      return employee.salary;
    case "hourly":
      return employee.hours * employee.rate;
    case "commissioned":
      return employee.base + employee.commission;
  }
}
```

In TypeScript the discriminated union is the polymorphism. The optional fields in the bad version are what forced every read through `?? 0`; the union deletes both the optionals and the defaults. Add a fourth variant and the switch no longer returns `number` on every path, so the build breaks at the one place that must change.

**G25: Replace Magic Numbers with Named Constants**

```ts
// Bad
if (elapsedTime > 86400) {
  // ...
}

// Good
const SECONDS_PER_DAY = 86400;
if (elapsedTime > SECONDS_PER_DAY) {
  // ...
}
```

**G30: Functions Should Do One Thing**

If you can extract another function, your function does more than one thing.

**G36: Law of Demeter (Avoid Train Wrecks)**

```ts
// Bad - reaching through multiple objects
const outputDir = context.options.scratchDir.absolutePath;

// Good - one dot
const outputDir = context.getScratchDir();
```

## Enforcement Checklist

When reviewing AI-generated code, verify:
- [ ] No duplication (G5)
- [ ] Clear intent, no magic numbers (G16, G25)
- [ ] Polymorphism over conditionals (G23)
- [ ] Functions do one thing (G30)
- [ ] No Law of Demeter violations (G36)
- [ ] Boundary conditions handled (G3)
- [ ] Dead code removed (G9)
