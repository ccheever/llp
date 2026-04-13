# Linked Literate Programming (LLP)

**Keep humans in markdown. Let AI write and review the code.**

LLP is infrastructure for codebases where humans work at the level they're good at — English prose, design decisions, principles, tradeoffs — and AI handles the code and most of the review. It's a structured way to give AI agents the context they need so that what they produce stays consistent with what the humans (and other AIs) behind the project actually want.

> **Rule of thumb:** if an AI agent might "simplify" this code in a way that would break the design intent, it needs a reference.

## Reference syntax at a glance

| Element | Format | Example |
|---------|--------|---------|
| LLP reference | `@ref LLP NNNN#anchor — gloss` | `@ref LLP 0005#token-strategy — Why we rotate tokens` |
| With relation | `@ref LLP NNNN#anchor [rel] — gloss` | `@ref LLP 0005#token-strategy [implements] — Token rotation` |
| LLP (broad) | `@ref LLP NNNN` | `@ref LLP 0012 — Auth subsystem` |
| Path reference | `@ref path/to/doc.md#anchor` | `@ref docs/vendor/spec.md#tokens — Token format` |

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

**3. Validate references:**

```bash
/ref-check src/
```

See the [Claude Code skills](#claude-code-skills) section below for how to install and use the validation and review tooling.

## Claude Code skills

This repo ships a handful of Claude Code skills for working with LLP documents and references. They are plain markdown files under [`skills/`](./skills/) and can be installed into Claude Code as described in [Anthropic's skills documentation](https://docs.claude.com/en/docs/claude-code/skills).

### Installing

The skills are self-contained — each is a directory under `skills/` with a `SKILL.md` file. To install one into Claude Code:

```bash
# Copy the skill directory into your Claude Code skills location
cp -r skills/llp-create ~/.claude/skills/
```

(Or install all of them at once by copying the full `skills/` directory.) After installation, invoke them with the slash commands shown below.

### Available skills

| Skill | Slash command | What it does |
|-------|---------------|-------------|
| [`llp-create`](./skills/llp-create/SKILL.md) | `/llp-create <title>` | Create a new LLP document. Scans the existing `llp/` tree, picks the next available number, generates the filename and slug, and scaffolds the metadata header. Asks for type and systems tags if not clear from context. |
| [`llp-review`](./skills/llp-review/SKILL.md) | `/llp-review <llp>` | Review an LLP document using a standard prompt that asks about strengths, concerns, missing considerations, and open questions. Saves the review as a dated artifact under `notes-archive/llp-reviews/` so reviews accumulate over time. |
| [`llp-list`](./skills/llp-list/SKILL.md) | `/llp-list [status\|type\|system]` | List LLPs grouped by status or filtered by type, system, or author. Useful for "what's still in draft?" or "what LLPs cover the auth system?" |
| [`ref-check`](./skills/ref-check/SKILL.md) | `/ref-check [path]` | Extract and validate `@ref` annotations in a codebase. Reports broken references (to LLPs or sections that don't exist), warnings (references to tombstoned or superseded LLPs), and hints (gloss text that may be out of date). The foundational tool for everything downstream. |
| [`ref-story`](./skills/ref-story/SKILL.md) | `/ref-story <file>` | Generate a rationale-order view of a source file — the killer feature described above. Groups code constructs by the LLP sections that explain them, interleaves the prose from those sections, and produces a literate-programming-style narrative of the file. |

Every skill's `SKILL.md` is readable on its own — it describes the command surface, the workflow, and the edge cases the skill handles.

### Writing new skills

A Claude Code skill is just a directory with a `SKILL.md` file that has YAML frontmatter and markdown instructions. To add a new skill:

1. Create `skills/your-skill-name/SKILL.md`.
2. Add frontmatter:
   ```yaml
   ---
   name: your-skill-name
   description: One-sentence description of what the skill does and when to use it.
   ---
   ```
3. Write the instructions that Claude should follow when the skill is invoked.
4. Install it locally to test: `cp -r skills/your-skill-name ~/.claude/skills/`

The existing skills in this repo are examples of the structure. Keep descriptions precise — they are the signal Claude uses to decide whether to invoke the skill.

## What's in this repo

**Start here** depending on what you're trying to do:

- **New to LLP?** Read [LLP 0000](./llp/0000-linked-literate-programming.explainer.md) — the root specification for core concepts, extensions, conventions, and examples.
- **Setting up a new project with LLP?** Read [LLP 0001: Greenfield setup](./llp/0001-greenfield-setup.guide.md).
- **Adding LLP to an existing codebase?** Read [LLP 0002: Retrofitting LLP](./llp/0002-retrofitting-llp.guide.md).
- **Interested in the thinking behind LLP?** Read [LLP 0003: Prior art](./llp/0003-prior-art.research.md) and [LLP 0004: Design principles](./llp/0004-design-principles.principles.md).
- **Want to start using the tooling?** Install the [Claude Code skills](#claude-code-skills) above and run `/llp-list` in a project that already has LLPs.

All LLP documents live under [`llp/`](./llp/). All skills live under [`skills/`](./skills/).

## License

MIT
