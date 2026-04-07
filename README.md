# Linked Literate Programming (LLP)

A lightweight system for linking code to its design rationale through machine-readable references. Code carries thin pointers — standardized `@ref` comments that reference specific sections of LLP documents. Agents and humans follow these links to retrieve deeper context on demand.

## The core idea

```rust
// @ref LLP 0042#token-strategy — Session tokens must be rotated on privilege escalation
pub fn escalate_privilege(session: &Session) -> Result<Session> {
```

The `@ref` comment is a machine-readable pointer to a specific section of an LLP document. It tells both humans and AI agents exactly where to find the rationale — without embedding a paragraph of explanation in the source file.

**Rule of thumb:** if an AI agent might "simplify" this code in a way that would break the design intent, it needs a reference.

## The killer feature: rationale-order views

Given `@ref` annotations, LLP can generate literate programming views organized by design intent rather than compiler order — the promise of literate programming without the maintenance burden:

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

A generated *story* about the file, organized by design intent rather than language syntax. (Tooling for this is planned, not yet implemented.)

## Why

- **AI agents need context but comments are a poor vehicle.** They go stale, long ones waste tokens, and they can't express structure.
- **Design rationale exists but code doesn't point to it.** Projects accumulate knowledge in documents — but code references are ad hoc and unvalidatable.
- **Humans reviewing AI-generated code need breadcrumbs.** A reference to a specific document section shifts review from "what is this doing?" to "does this satisfy the constraint?"

## Quick start

**Fast path:** from the root of the repository you want to bootstrap, run:

```bash
curl -fsSL https://raw.githubusercontent.com/ccheever/llp/main/scripts/llp-init.sh | sh
```

Or run a checked-out copy of [`scripts/llp-init.sh`](./scripts/llp-init.sh) from that repository root.

The script creates `llp/`, a template `LLP 0000`, `AGENTS.md`, and `CLAUDE.md -> AGENTS.md`. It is primarily for new repositories; existing repos still need the retrofit workflow in [LLP 0002](./llp/0002-retrofitting-llp.guide.md).

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

**2. Add references to your code:**

```typescript
// @ref LLP 0000#architecture — Widget service boundary
export function handleWidgetRequest(req: Request): Response {
  // ...
}
```

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
- **[`scripts/llp-init.sh`](./scripts/llp-init.sh)** — Bootstrap script for creating LLP scaffolding in a new repository.
- **Additional tooling** (planned) — A pipeline of composable tools for extracting, validating, and indexing `@ref` annotations.

## License

MIT
