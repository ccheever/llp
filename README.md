# Linked Literate Programming (LLP)

**Let AI agents operate autonomously — in accordance with your taste, wishes, and decisions.**

LLP is a simple system of numbered markdown documents and links — between documents, and from code into specific document sections. It gives autonomous agents a durable source of truth for how you want your software built, while letting every session read *just* what it needs instead of stuffing its context window with a giant corpus.

## Three core ideas

### 1. Autonomous agents, guided by your taste and decisions

You want agents to work independently without re-explaining your preferences every session — and without them quietly breaking the principles, invariants, and taste calls that make the software *yours*.

Code alone never carries the *why* behind it: the rejected alternative, the subtle tradeoff, the product judgment, the constraint that shouldn't be "cleaned up." Smarter models don't recover unrecorded decisions; they just make more convincing guesses. Unstructured agent "memory" isn't much better — when you change your mind, echoes of the old decision linger and keep steering new code.

LLP puts your decisions, principles, and design specs in living markdown documents right in the repo, versioned alongside the code. When your thinking changes, you update the document, and autonomous sessions act on the new intent.

### 2. Simple: numbered markdown documents and links

There is no database, no custom editor, no proprietary format, and no interleaving prose inside source files. Just plain markdown files in `llp/` with permanent numbers:

```text
llp/
  0000-my-project.explainer.md
  0001-authentication.decision.md
  0001.000-token-rotation.spec.md
  current/       # links to what's in play right now
  foundation/    # links to the small kernel of enduring design truth
```

Permanent numbers let humans and agents refer to any decision — and any section inside it — with precision (`LLP 0001#token-strategy`, `LLP 0001.000#rotation`), in prose, reviews, PRs, commits, and code. Documents link freely to each other, dotted sub-LLPs (`0001.000`) nest specs or plans under a parent without moving files, and two lightweight link directories (`foundation/` and `current/`) separate enduring design truth from active work.

### 3. Read just what you need, not a giant corpus

Dumping an entire documentation tree or a bloated instructions file into every session fills up the context window and degrades agent performance. Reading nothing leaves the agent guessing.

Because LLP documents link to each other and source code carries thin, one-line `@ref` pointers to the exact sections that govern it, a session loads *only* the decisions relevant to the task at hand:

```ts
// @ref LLP 0001#token-strategy — Rotate session tokens on privilege escalation
export function escalatePrivilege(session: Session): Session {
```

An agent starts with the small kernel (`llp/foundation/` and `llp/current/`), then follows `@ref` links in the files it's touching and cross-links between documents to pull in just the context in scope. Review shifts from "what is this code doing?" to "does it still satisfy the referenced decision?" — and docs don't rot into a forgotten wiki because agents actively work from them.

> **Rule of thumb:** if an agent might "simplify" a piece of code in a way that would break your design intent, it needs a `@ref`.

## From Knuth to Norman Ramsey: where LLP fits

LLP takes its name and core intuition from the literate programming tradition — and solves the practical bottleneck that kept literate programming out of everyday software engineering.

**Donald Knuth and WEB (1984).** Knuth introduced *literate programming* with WEB (used to write TeX and METAFONT) and later CWEB (with Silvio Levy, 1987). His central insight was that programs should be written primarily for humans to read, structured in the order that makes sense for *explanation* rather than the order the compiler demands. In WEB, prose and named code chunks lived together in one file: `tangle` rearranged the chunks into compilable source code, and `weave` typeset them into a cross-referenced book via TeX. The results were remarkable, yet almost no teams beyond Knuth adopted WEB — writing, refactoring, and collaborating inside a tightly coupled macro and typesetting system was too heavy for day-to-day codebases.

**Norman Ramsey and noweb (1994).** A decade later, Norman Ramsey asked which parts of Knuth's system actually delivered the value. In *"Literate Programming Simplified"* (IEEE Software, 1994), he stripped WEB down to **noweb**: language-independent, no pretty-printer, no macro processor — just named chunks, automatic cross-referencing, and a small pipeline of composable Unix-style filters. Ramsey showed that most of WEB's complexity was incidental; the real power was **simplicity, cross-referencing, and human-order presentation**. Even so, noweb — and later interleaved formats from Literate Haskell (`.lhs`) and Org-mode Babel to Jupyter notebooks and Eve — still asked teams to interleave prose and code in the same source files, creating friction with editors, diffs, refactoring, and large multi-file systems where concepts and code map many-to-many.

**How LLP fits in.** Linked Literate Programming takes Ramsey's simplification one step further for normal repos and autonomous agents: **separate prose from code completely, and connect them with links.** Prose lives in numbered markdown documents; code stays in ordinary source files carrying thin `@ref` pointers. You keep what Knuth and Ramsey were after — explanation-first design narrative, precise cross-referencing, language independence, and simple composable tooling (`ref-check`) — with zero build-system or file-format overhead. Knuth's "woven" view (reading code grouped by design intent instead of compiler order) becomes an on-demand output rather than an authoring constraint. And in the agent era, the reader isn't just a human reading a typeset book — it's also an autonomous agent traversing the links to load only the decisions that govern the code it's about to write.

For the full intellectual lineage — including ADRs, Oxide RFDs, Zettelkasten, traceability, and AI context studies — see [LLP 0003: Prior Art and Influences](./llp/0003-prior-art.research.md).

## Basic example

A minimal project layout:

```text
my-project/
  llp/
    0000-my-project.explainer.md
    0001-authentication.decision.md
    0001.000-token-rotation.spec.md
    current/
      0001.000-token-rotation.spec.md -> ../0001.000-token-rotation.spec.md
    foundation/
      0000-my-project.explainer.md -> ../0000-my-project.explainer.md
      0001-authentication.decision.md -> ../0001-authentication.decision.md
  src/
    auth.py
  AGENTS.md
```

**A numbered LLP document (`llp/0001-authentication.decision.md`):**

```markdown
# LLP 0001: Authentication Design

**Type:** Decision
**Status:** Active
**Systems:** Auth
**Author:** J. Dev
**Date:** 2026-01-15
**Related:** LLP 0000, LLP 0001.000

## Token strategy

Sessions use short-lived JWTs, rotated on privilege escalation to prevent
session fixation. Rotation mechanics are specified in
[LLP 0001.000](./0001.000-token-rotation.spec.md#rotation-flow).

## Database choice

Use PostgreSQL rather than a document store so auth state and billing updates
can share a single transaction.
```

**Source code pointing into exact sections (`src/auth.py`):**

```python
# @ref LLP 0001 — Auth subsystem

# @ref LLP 0001#token-strategy — Rotate tokens on privilege escalation
def escalate_privilege(session: Session) -> Session:
    ...

# @ref LLP 0001#database-choice [constrained-by] — Postgres for auth/billing txns
def get_db_pool(config: DBConfig) -> ConnectionPool:
    ...
```

When an agent is asked to modify `escalate_privilege`, it sees `@ref LLP 0001#token-strategy`, reads that section (and follows the link to `LLP 0001.000#rotation-flow` if needed), and leaves the rest of the corpus unread.

## Reference syntax at a glance

| Target | Format | Example |
|--------|--------|---------|
| LLP section | `@ref LLP NNNN#anchor — gloss` | `@ref LLP 0001#token-strategy — Rotate on privilege change` |
| Sub-LLP section | `@ref LLP NNNN.NNN#anchor — gloss` | `@ref LLP 0001.000#rotation-flow — Token rotation sequence` |
| With relation | `@ref LLP NNNN#anchor [rel] — gloss` | `@ref LLP 0001#database-choice [constrained-by] — Postgres txns` |
| Whole LLP | `@ref LLP NNNN` | `@ref LLP 0001 — Auth subsystem` |
| Repo file | `@ref path/to/file#anchor` | `@ref docs/vendor/spec.md#tokens — Token format` |
| External URL | `@ref https://…` | `@ref https://datatracker.ietf.org/doc/html/rfc6749#section-4.1` |

Optional relation qualifiers: `implements`, `constrained-by`, `tests`, `explains`. Heading slugs (`#token-strategy`) are the default anchor style so living documents can be reordered without breaking references.

## Quick start and usage

**1. Create `llp/` with `current/` and `foundation/` overlays, and write a root document.** Start the root as `Draft` and link it into `llp/current/`; once it's `Active`, link it into `llp/foundation/` (`foundation/` starts empty):

```bash
mkdir -p llp/current llp/foundation
```

```markdown
<!-- llp/0000-my-project.explainer.md -->
# LLP 0000: My Project

**Type:** Explainer
**Status:** Draft
**Systems:** Core
**Role:** Root
**Author:** Your Name
**Date:** YYYY-MM-DD

## Overview

What this project does, who it's for, and the principles that govern it.

## Architecture

Major subsystems and how they fit together.
```

```bash
ln -s ../0000-my-project.explainer.md llp/current/0000-my-project.explainer.md
```

**2. Write new LLPs as you make real decisions** — not preemptively. Use the next available number (`0001`, `0002`, … or `0001.000` for a child spec/plan), link related documents to each other, and drop `@ref` comments on code that implements non-obvious constraints.

**3. Point your agents at `llp/`.** Add a brief note to `AGENTS.md` / `CLAUDE.md` telling agents to orient on `llp/foundation/` and `llp/current/`, follow `@ref`s in files they edit, and keep docs updated alongside code changes — or install the LLP skills below with `/llp-adopt`.

**4. Validate links and metadata with [`ref-check`](./ref-check).** It's a single-file, zero-dependency Python checker built for local runs and CI (this repo runs it on every push):

```bash
./ref-check                     # validate the current directory
./ref-check --root path/to/pkg  # validate another repo or nested package
./ref-check --verbose           # also show informational / unchecked notes
```

`ref-check` verifies that every `@ref` resolves to a real document, heading anchor, or path; metadata headers and filenames match; LLP numbers are unique and sub-LLPs have parents; overlays are valid; and no `[inferred]` claims remain in `Accepted`/`Active` documents. Drift that requires judgment (code diverging from its referenced section, stale docs) is handled interactively with `llp-maintain`.

See [LLP 0001: Adopting LLP](./llp/0001-adopting-llp.guide.md) for the full greenfield and brownfield retrofit workflow (automated by `/llp-adopt`).

## Skills

Seven skills cover the LLP workflow — each a plain-markdown directory under [`skills/`](./skills/) with a `SKILL.md` contract (trigger · invariants · artifact · hand-offs). Claude Code consumes them directly; other agent tools can adopt the same shape.

The managed way in is `/llp-adopt`, which installs skills **from a tagged release** and writes a receipt so `/llp-adopt update` can later diff and update them without clobbering local edits ([LLP 0010.000](./llp/0010.000-skill-installation-and-updates.spec.md)). The install unit is a profile: **core** (the first five below) plus opt-in flags **review-plus** (`llp-super-refine`) and **delivery** (`llp-ship`). Hand-copying also works:

```bash
git clone --branch v0.5.2 --depth 1 https://github.com/ccheever/llp
cp -r llp/skills/llp-orient ~/.claude/skills/   # or all of skills/
```

| Skill | Slash command | What it does |
|-------|---------------|-------------|
| [`llp-orient`](./skills/llp-orient/SKILL.md) | `/llp-orient <path-or-task>` | Load only the governing LLP context before coding: `foundation/`, `current/`, `@ref`s in scope, and LLPs covering the relevant systems. Emits a compact context pack. Read-only. |
| [`llp-create`](./skills/llp-create/SKILL.md) | `/llp-create <title>` | Author one LLP — next number, filename, metadata scaffold. Prefers extending an existing LLP that already covers the topic. |
| [`llp-review`](./skills/llp-review/SKILL.md) | `/llp-review <llp>` | Run the LLP 0005 review loop, scaled to stakes. One provenance-tracked artifact per review actually received, under `llp/reviews/`. Never fabricates; never accepts on the author's behalf. |
| [`llp-adopt`](./skills/llp-adopt/SKILL.md) | `/llp-adopt` | Bring LLP to any repo or package — `scaffold` (fresh) or `retrofit` (survey, maintainer interview, provenance-tagged drafts), auto-detected — and install/update the skills themselves: `/llp-adopt update` diffs installed copies against their receipt and the newest release; forks are flagged, never clobbered. |
| [`llp-maintain`](./skills/llp-maintain/SKILL.md) | `/llp-maintain --intent <mode>` | Keep code and docs co-evolving: drift, ref repairs, provenance, retirements, and the curation pass. Modes: `pre-pr`, `audit`, `reconcile`, `retire-proposal`, `curate`. Proposes; never applies. |
| [`llp-super-refine`](./skills/llp-super-refine/SKILL.md) | `/llp-super-refine <llp...>` | Author-invoked dual-family refine loop: fresh, mutually-blind reviews from two model families each round, orchestrator revisions, verdict-lined artifacts — until both families say READY or a bounded stop rule escalates. Opt-in via the `review-plus` flag. |
| [`llp-ship`](./skills/llp-ship/SKILL.md) | `/llp-ship <ref...>` | Tasks done end to end: reuse worktrees, cap parallel lanes to machine capacity, implement on run branches, verify and review the exact integrated commit, deliver per repo policy (direct push default), retain reusable worktrees and preserve recoverable work. Opt-in via the `delivery` flag. |

The skills are deletable adapters: every MUST in a `SKILL.md` cites the LLP section it comes from (as a pinned upstream URL, so copies stay resolvable), and a runtime with no skills mechanism gets the same behavior from the `AGENTS.md` routing block plus the documents. See [LLP 0008](./llp/0008-distributed-agent-skills.rfc.md) for the design and [LLP 0009](./llp/0009-capability-invariant-core.rfc.md) for why the set is this small.

### Writing new skills

A skill is a directory with a `SKILL.md`: YAML frontmatter (`name`, `description`, optionally `source`) plus markdown instructions. Keep descriptions precise — they're the signal for invocation — and keep policy in LLP documents, with the skill citing it.

## What's in this repo

- **New to LLP?** [LLP 0000](./llp/0000-linked-literate-programming.explainer.md) — the root spec: documents, `@ref` grammar, lifecycle, conventions.
- **Adopting LLP in a project?** [LLP 0001](./llp/0001-adopting-llp.guide.md) — greenfield and retrofit, one guide; interview recipe in [LLP 0001.000](./llp/0001.000-retrofit-interview.guide.md).
- **The thinking behind it:** [LLP 0003](./llp/0003-prior-art.research.md) (prior art) and [LLP 0004](./llp/0004-design-principles.principles.md) (design principles).
- **Authoring and review process:** [LLP 0005](./llp/0005-rfc-process.guide.md) — stakes-scaled review with fixed honesty rules.
- **The skills design:** [LLP 0008](./llp/0008-distributed-agent-skills.rfc.md).
- **Why it's this simple:** [LLP 0009](./llp/0009-capability-invariant-core.rfc.md) — the capability-invariant core, and what was cut to get here.
- **LLP v2 — sub-LLPs, `current/` and `foundation/`:** [LLP 0011](./llp/0011-llp-v2-overlays-and-sub-llps.rfc.md), and the curation pass in [LLP 0011.000](./llp/0011.000-curation-pass.guide.md).
- **The skill contracts (foundation):** [LLP 0010.000](./llp/0010.000-skill-installation-and-updates.spec.md) install/update · [LLP 0010.001](./llp/0010.001-super-refine-loop.spec.md) super-refine · [LLP 0010.002](./llp/0010.002-ship.spec.md) ship — rationale in [LLP 0010](./llp/0010-skill-install-super-refine-ship.rfc.md).

All documents live flat under [`llp/`](./llp/); [`llp/foundation/`](./llp/foundation/) links the kernel and [`llp/current/`](./llp/current/) links what's in play ([LLP 0011](./llp/0011-llp-v2-overlays-and-sub-llps.rfc.md)); skills under [`skills/`](./skills/); the checker is [`ref-check`](./ref-check) with fixtures under [`fixtures/`](./fixtures/).

## License

MIT
