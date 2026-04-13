# Linked Literate Programming (LLP)

**Keep humans in markdown. Let AI write and review the code.**

LLP is infrastructure for codebases where humans work at the level they're good at — English prose, design decisions, principles, tradeoffs — and AI handles the code and most of the review. It's a structured way to give AI agents the context they need so that what they produce stays consistent with what the humans (and other AIs) behind the project actually want.

## The problem

Living codebases carry an enormous amount of implicit knowledge: the decisions, principles, and constraints behind why things are the way they are. Today that knowledge lives in Notion pages, Google Docs, Slack threads, half-finished wiki articles, and the heads of senior engineers. When an AI agent writes new code, it can't see any of it.

Some AI harnesses address this with "memory" — ambient notes the agent accumulates over time. That helps, but it's unstructured and hard to curate. When you change your mind about a decision, remnants of the old one linger in memory and keep influencing new code. You can't cleanly version it, review it, or hand it to someone else.

LLP is the structured, explicit version of that idea. Decisions live in markdown documents in the repo. They are versioned like code. When a decision changes, you update the document, and the next thing the AI writes reflects the new intent — not an echo of the old one.

## The core idea

Humans stay in markdown. That's where they read fastest, argue most clearly, and make the decisions that actually matter. A plan refined a few times at the markdown level almost always produces better software — and less slop — than the same plan worked out directly in code.

The code itself, and most of the review, can be left to AI. The catch is that the AI needs to know *why* the code exists in the form it does. LLP gives it that, via thin pointers from code to the exact section of the exact document that explains a given decision:

```rust
// @ref LLP 0042#token-strategy — Session tokens must be rotated on privilege escalation
pub fn escalate_privilege(session: &Session) -> Result<Session> {
```

The `@ref` comment is a machine-readable link. An agent reviewing this function can follow it to the rationale and check whether a proposed change still satisfies the constraint. A human can follow it too — but the point is that they mostly shouldn't have to.

## What this buys you

- **Humans review less code, and get better results.** Review shifts from "what is this doing?" to "does this still match the decisions in the docs?" — and most of that check can be done by an agent following `@ref` links.
- **Decisions are versioned, not ambient.** When you change your mind, you update the document. There is no lingering memory of the old decision drifting through the AI's next suggestions.
- **Plans get refined where refinement is cheap.** Markdown is the right medium for iterating on a design. LLP makes the planning artifact first-class instead of a throwaway.
- **Context transfers.** A new agent — or a new engineer — picks up the project by reading the LLP documents, not by absorbing tribal knowledge.

## The killer feature: rationale-order views

Because `@ref` annotations link code to design intent, LLP can generate literate-programming-style views of a file organized by *why* rather than by compiler order:

```
━━━ LLP 0074#implicit-semantics ━━━━━━━━━━━━━━━━━━━━━━━━━

  Components carry default roles without developer opt-in.

  pub fn infer_role(node: &RenderNode) -> Option<SemanticRole> { ... }
  pub fn default_label(node: &RenderNode) -> Option<String> { ... }

━━━ LLP 0074#focus-management ━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Focus trapping, restoration, and custom focus order.

  pub fn trap_focus_in_modal(node: NodeId) -> Result<()> { ... }
  pub fn restore_focus(saved: FocusState) -> Result<()> { ... }

━━━ Unreferenced ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  fn internal_helper() { ... }
```

A generated *story* about the file, organized by design intent rather than language syntax — the promise of literate programming without the maintenance burden. (Tooling for this is planned, not yet implemented.)

## Quick start

**1. Create an `llp/` directory and write your first LLP document:**

```markdown
# LLP 0000: My Project

**Type:** Explainer
**Status:** Active
**Systems:** Core
**Role:** Root
**Author:** ...
**Date:** YYYY-MM-DD

## Overview

What the project does and why.

## Architecture

Major subsystems and how they relate.
```

**2. Add references from your code to the decisions behind it:**

```typescript
// @ref LLP 0000#architecture — Widget service boundary
export function handleWidgetRequest(req: Request): Response {
  // ...
}
```

**Rule of thumb:** if an AI agent might "simplify" this code in a way that would break the design intent, it needs a reference.

**3. Validate references** (planned tooling):

```bash
ref-check extract src/ | ref-check resolve
```

## Reference syntax at a glance

| Element | Format | Example |
|---------|--------|---------|
| LLP reference | `@ref LLP NNNN#anchor — gloss` | `@ref LLP 0005#token-strategy — Why we rotate tokens` |
| With relation | `@ref LLP NNNN#anchor [rel] — gloss` | `@ref LLP 0005#token-strategy [implements] — Token rotation` |
| LLP (broad) | `@ref LLP NNNN` | `@ref LLP 0012 — Auth subsystem` |
| Path reference | `@ref path/to/doc.md#anchor` | `@ref docs/vendor/spec.md#tokens — Token format` |

## What's in this repo

- **[LLP 0000: Linked Literate Programming](./llp/0000-linked-literate-programming.explainer.md)** — The root specification: core concepts, extensions, conventions, and examples.
- **[LLP 0001: Setting Up LLP in a New Repository](./llp/0001-greenfield-setup.guide.md)** — Greenfield adoption guide.
- **[LLP 0002: Retrofitting LLP into an Existing Codebase](./llp/0002-retrofitting-llp.guide.md)** — Existing-repo adoption guide.
- **[LLP 0003: Prior Art and Influences](./llp/0003-prior-art.research.md)** — Survey of systems, papers, and ideas that inform LLP's design.
- **[LLP 0004: Design Principles](./llp/0004-design-principles.principles.md)** — Core principles behind LLP's design.
- **Tooling** (planned) — A pipeline of composable tools for extracting, validating, and indexing `@ref` annotations.

## License

MIT
