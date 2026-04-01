# LLP 0001: Setting Up LLP in a New Repository

**Type:** Guide
**Status:** Draft
**Systems:** LLP
**Author:** Charlie Cheever / Claude
**Date:** 2026-04-01

## Summary

This document describes the process of bootstrapping LLP in a new project from day one — creating the directory structure, writing initial documents, configuring agent instructions, and establishing habits that keep the system useful as the codebase grows.

## 1. Create the LLP directory

Create an `llp/` directory. Flat is fine to start. Subdirectories can be added later when there are enough documents in a domain to warrant grouping.

```
mkdir llp
```

## 2. Write LLP 0000: the root document

Every LLP-enabled project should have a root document that orients readers — human or agent — to the project's purpose, architecture, and key design decisions. This is typically `0000-<project-name>.md`.

LLP 0000 is typically an **Explainer** overview — the entry point for the corpus. It should carry `**Role:** Root`.

This document doesn't need to be long. A few sections covering:

- What the project does and why it exists
- High-level architecture (major subsystems and how they relate)
- Key constraints or invariants that aren't obvious from the code

Even a half-page overview is valuable. It gives agents a starting point and gives humans a place to point new team members.

## 3. Write LLPs for early design decisions

As you make design decisions during initial development — choosing a database, picking a framework, deciding on an API shape — capture the non-obvious ones in LLP documents. The bar is low: if the decision has a "why" that isn't self-evident, it's worth a short LLP.

These early documents tend to be RFCs or Principles:

- **RFC** for specific technical choices: "We chose SQLite over Postgres because this is a single-node CLI tool and embedded storage eliminates a deployment dependency."
- **Principle** for recurring values: "We prefer explicit configuration over convention-based magic because this codebase will be maintained primarily by agents that benefit from direct traceability."

Don't write documents preemptively. Write them when you actually make the decision, while the reasoning is fresh.

## 4. Add @ref annotations as you write code

The best time to add a reference is immediately after writing code that implements a documented decision. The connection is fresh and accurate. Deferring annotation means you'll forget or get it wrong.

A practical habit: when you finish implementing something covered by an LLP, add the `@ref` before moving on. This takes seconds and saves significant context-reconstruction time later.

```typescript
// @ref LLP 0005#2 — Event sourcing: append-only log, no in-place mutation
export function appendEvent(log: EventLog, event: Event): EventLog {
  // ...
}
```

## 5. Configure agent instructions

Create an `AGENTS.md` (or `CLAUDE.md`, or your agent's equivalent) that tells agents about LLP:

- Where LLP documents live
- To read relevant LLPs before making changes in areas they cover
- To add `@ref` annotations when implementing documented decisions
- To update LLP documents when the design changes

This is the mechanism that makes LLP self-reinforcing: agents that are told about the system will maintain it as they work. The guardrail is the same one described in LLP 0000: add `@ref` only when the connection is specific and non-obvious.

## 6. Don't over-invest upfront

See [LLP 0000's adoption principles](./0000-linked-literate-programming.md#adoption-principles) for the full list. The key pitfalls for greenfield projects:

- **Writing too many documents before there's code.** Documents without implementing code are speculation. Write just enough to capture decisions you've actually made.
- **Annotating everything.** Early code is volatile. Wait until a module's design stabilizes before annotating heavily.
- **Perfect prose.** A rough LLP with stable section targets is more valuable than a polished document that never gets written.

## 7. Suggested first documents

A typical new project benefits from 3-5 initial LLPs:

1. **LLP 0000** (usually Explainer, sometimes RFC) — Root overview and entry point
2. **LLP 0001** (Principle or RFC) — Core design philosophy or key technical choice
3. **LLP 0002+** (RFC or Research) — Individual design decisions or findings as they arise

The numbering will grow organically. Don't plan the numbering scheme — just take the next number.

## 8. Validation tooling

Validation tooling (`ref-check`) is optional at project start. When the project is small, broken references are easy to spot manually. Add CI validation when the codebase is large enough that manual tracking becomes unreliable — typically when you have 10+ LLP documents or multiple contributors.

Start local (`ref-check extract | ref-check resolve`) if you want early feedback without CI noise.
