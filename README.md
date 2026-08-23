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
| Path reference | `@ref path/to/file#anchor` | `@ref docs/vendor/spec.md#tokens — Token format` |
| URL reference | `@ref https://…` | `@ref https://datatracker.ietf.org/doc/html/rfc6749#section-4.1` |

## The problem

Living codebases carry an enormous amount of implicit knowledge: the decisions, principles, and constraints behind why things are the way they are. Today that knowledge lives in Notion pages, Google Docs, Slack threads, and the heads of senior engineers. When an AI agent writes new code, it can't see any of it — and no model capability closes that gap, because the *why* behind code is information the code doesn't contain. A smarter model doesn't recover unrecorded rationale; it produces a more convincing guess.

Some AI harnesses address this with "memory" — ambient notes the agent accumulates. That helps, but it's unstructured and hard to curate: when you change your mind, remnants of the old decision linger and keep influencing new code. LLP is the structured, explicit version of that idea. Decisions live in markdown documents in the repo, versioned like code. When a decision changes, you update the document, and the next thing the AI writes reflects the new intent — not an echo of the old one.

## The core idea

Humans stay in markdown. That's where they read fastest, argue most clearly, and make the decisions that matter. The code itself, and most of the review, can be left to AI — but the AI needs to know *why* the code exists in the form it does. LLP gives it that, via thin pointers from code to the exact section of the exact document that explains a given decision:

```rust
// @ref LLP 0042#token-strategy — Session tokens must be rotated on privilege escalation
pub fn escalate_privilege(session: &Session) -> Result<Session> {
```

The `@ref` comment is a machine-readable link. An agent reviewing this function follows it to the rationale and checks whether a proposed change still satisfies the constraint. Review shifts from "what is this doing?" to "does this still match the referenced decision?" — and the documentation can't drift into stale-wiki territory without the code starting to drift with it, because the documentation *is* what the agents work from.

## Quick start

**1. Create an `llp/` directory (with `current/` and `foundation/` subdirectories) and a root document, linked into `current/` while you write it and into `foundation/` once it's `Active`:**

```markdown
# LLP 0000: My Project

**Type:** Explainer
**Status:** Draft
**Systems:** Core
**Role:** Root
**Author:** ...
**Date:** YYYY-MM-DD

## Overview
What the project does and why.

## Architecture
Major subsystems and how they relate.
```

**2. Reference decisions from the code that implements them:**

```typescript
// @ref LLP 0000#architecture — Widget service boundary
export function handleWidgetRequest(req: Request): Response {
```

**3. Validate references and metadata** with [`ref-check`](./ref-check) — a single-file, dependency-free checker suitable for CI (this repo runs it on every push):

```bash
./ref-check
```

For drift that takes judgment — code that no longer matches its referenced section, docs gone stale — use the `llp-maintain` skill interactively.

The full workflow (greenfield and retrofit) is in [LLP 0001](./llp/0001-adopting-llp.guide.md), and the `llp-adopt` skill automates it.

## Skills

Seven skills cover the LLP loop — each a plain-markdown directory under [`skills/`](./skills/) with a `SKILL.md` contract (trigger · invariants · artifact · hand-offs). Claude Code consumes them directly; other agent tools can adopt the same shape. The managed way in is `/llp-adopt`, whose install step copies skills **from a tagged release** and writes a receipt so `/llp-adopt update` can later diff and update them without clobbering local edits ([LLP 0010.000](./llp/0010.000-skill-installation-and-updates.spec.md)). The install unit is a profile: **core** (the five below) plus opt-in flags **review-plus** (`llp-super-refine`) and **delivery** (`llp-ship`). Hand-copying still works:

```bash
git clone --branch v0.4.0 --depth 1 https://github.com/ccheever/llp
cp -r llp/skills/llp-orient ~/.claude/skills/   # or all of skills/
```

| Skill | Slash command | What it does |
|-------|---------------|-------------|
| [`llp-orient`](./skills/llp-orient/SKILL.md) | `/llp-orient <path-or-task>` | Load the governing LLP context before coding: root LLP, `@ref`s in scope, the LLPs covering the relevant systems. Emits a compact context pack. Read-only. |
| [`llp-create`](./skills/llp-create/SKILL.md) | `/llp-create <title>` | Author one LLP — next number, filename, metadata scaffold. Prefers extending an existing LLP that already covers the topic. |
| [`llp-review`](./skills/llp-review/SKILL.md) | `/llp-review <llp>` | Run the LLP 0005 review loop, scaled to stakes. One provenance-tracked artifact per review actually received, under `llp/reviews/`. Never fabricates; never accepts on the author's behalf. |
| [`llp-adopt`](./skills/llp-adopt/SKILL.md) | `/llp-adopt` | Bring LLP to any repo — `scaffold` (fresh) or `retrofit` (survey, draft provenance-tagged docs, propose a plan), auto-detected — and install/update the skills themselves: `/llp-adopt update` diffs installed copies against their receipt and the newest release; forks are flagged, never clobbered. |
| [`llp-maintain`](./skills/llp-maintain/SKILL.md) | `/llp-maintain --intent <mode>` | Keep code and docs co-evolving: drift, ref repairs, provenance, retirements, and the curation pass. Modes: `pre-pr`, `audit`, `reconcile`, `retire-proposal`, `curate`. Proposes; never applies. |
| [`llp-super-refine`](./skills/llp-super-refine/SKILL.md) | `/llp-super-refine <llp...>` | Author-invoked dual-family refine loop: fresh, mutually-blind reviews from two model families each round, orchestrator revisions, verdict-lined artifacts — until both families say READY or a bounded stop rule escalates. Opt-in via the `review-plus` flag. |
| [`llp-ship`](./skills/llp-ship/SKILL.md) | `/llp-ship <ref...>` | Tasks done end to end: plan lanes, implement in namespaced worktrees, verify and review the exact integrated commit, deliver per repo policy (direct push default), clean up without destroying recoverable work. Opt-in via the `delivery` flag. |

The skills are deletable adapters: every MUST in a `SKILL.md` cites the LLP section it comes from (as a pinned upstream URL, so copies stay resolvable), and a runtime with no skills mechanism gets the same behavior from the `AGENTS.md` routing block plus the documents. See [LLP 0008](./llp/0008-distributed-agent-skills.rfc.md) for the design and [LLP 0009](./llp/0009-capability-invariant-core.rfc.md) for why the set is this small.

### Writing new skills

A skill is a directory with a `SKILL.md`: YAML frontmatter (`name`, `description`, optionally `source`) plus markdown instructions. Keep descriptions precise — they're the signal for invocation — and keep policy in LLP documents, with the skill citing it.

## What's in this repo

- **New to LLP?** [LLP 0000](./llp/0000-linked-literate-programming.explainer.md) — the root spec: documents, `@ref` grammar, lifecycle, conventions.
- **Adopting LLP in a project?** [LLP 0001](./llp/0001-adopting-llp.guide.md) — greenfield and retrofit, one guide.
- **The thinking behind it:** [LLP 0003](./llp/0003-prior-art.research.md) (prior art) and [LLP 0004](./llp/0004-design-principles.principles.md) (design principles).
- **Authoring and review process:** [LLP 0005](./llp/0005-rfc-process.guide.md) — stakes-scaled review with fixed honesty rules.
- **The skills design:** [LLP 0008](./llp/0008-distributed-agent-skills.rfc.md).
- **Why it's this simple:** [LLP 0009](./llp/0009-capability-invariant-core.rfc.md) — the capability-invariant core, and what was cut to get here.
- **LLP v2 — sub-LLPs, `current/` and `foundation/`:** [LLP 0011](./llp/0011-llp-v2-overlays-and-sub-llps.rfc.md), and the curation pass in [LLP 0011.000](./llp/0011.000-curation-pass.guide.md).
- **The skill contracts (foundation):** [LLP 0010.000](./llp/0010.000-skill-installation-and-updates.spec.md) install/update · [LLP 0010.001](./llp/0010.001-super-refine-loop.spec.md) super-refine · [LLP 0010.002](./llp/0010.002-ship.spec.md) ship — rationale in [LLP 0010](./llp/0010-skill-install-super-refine-ship.rfc.md).

All documents live flat under [`llp/`](./llp/); [`llp/foundation/`](./llp/foundation/) links the kernel and [`llp/current/`](./llp/current/) links what's in play ([LLP 0011](./llp/0011-llp-v2-overlays-and-sub-llps.rfc.md)); skills under [`skills/`](./skills/); the checker is [`ref-check`](./ref-check) with its fixture under [`fixtures/`](./fixtures/).

## License

MIT
