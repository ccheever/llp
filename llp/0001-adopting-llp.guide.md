# LLP 0001: Adopting LLP

**Type:** Guide
**Status:** Active
**Systems:** LLP
**Author:** Charlie Cheever / Claude
**Date:** 2026-04-01
**Revised:** 2026-07-23 (added the skill-install step, per [LLP 0010](./0010-skill-install-super-refine-ship.rfc.md). Earlier: 2026-06-10, merged with the former LLP 0002 retrofit guide, per [LLP 0009](./0009-capability-invariant-core.rfc.md))
**Related:** LLP 0000, LLP 0010

## Summary

This guide covers bringing LLP to any repository. Greenfield and brownfield are not two processes — they are two ends of one spectrum: *how much design knowledge already exists to mine*. A fresh repo needs structure and habits (**scaffold**); an established codebase additionally needs comprehension, drafting, migration, and annotation (**retrofit**). The `llp-adopt` skill automates both modes; this guide is the underlying workflow.

## Choosing a mode

Inspect the repository first. Is there already an `llp/` directory (extend it — don't start a second setup layer)? Are there agent-instruction files? How much code and documentation exists?

- **Little or no code/docs to mine** → scaffold.
- **Substantial existing code, docs, or history** → retrofit. Retrofit is scaffold plus comprehension; everything in the scaffold section applies to both.

## Shared spine (both modes)

1. **Create `llp/`.** Flat is fine to start; add subdirectories only when a domain has enough documents to warrant grouping.
2. **Write LLP 0000, the root document** — typically an `Explainer` carrying `**Role:** Root`: what the project does and why, the major subsystems and how they relate, and key constraints or invariants that aren't obvious from the code. Even a half-page is valuable; it gives agents a starting point and humans a place to point newcomers.
3. **Configure agent instructions.** Add or update `AGENTS.md` so agents know: where LLP documents live; to read relevant LLPs before changing areas they cover; to add `@ref` annotations when implementing non-obvious documented decisions; to update LLPs when the design changes; and to flag code that contradicts its referenced LLP. When a tool expects `CLAUDE.md`, symlink it to `AGENTS.md` rather than maintaining divergent copies. This is what makes LLP self-reinforcing: agents told about the system maintain it as they work.
4. **Reruns are idempotent.** Setting up twice must not duplicate files or instruction blocks.
5. **Install the skills (optional but recommended).** `llp-adopt` offers to copy the LLP workflow skills from a tagged release of the upstream repo into your runtime's skill directory, writing a receipt (origin, tag, resolved commit, per-file hashes) beside the installation. The install unit is a profile — **core** (the five workflow skills) plus opt-in flags **review-plus** (`llp-super-refine`) and **delivery** (`llp-ship`, which also asks for the repo's delivery policy). Update later with `/llp-adopt update`: it diffs your installed copies against the receipt (a hand-edited skill is a fork — flagged, never overwritten) and against the newest release, and applies approved updates as a set. Design and trust model: [LLP 0010 §1](./0010-skill-install-super-refine-ship.rfc.md#1-installation-and-updates-llp-adopt-extended).

## Scaffold mode (greenfield)

### Capture decisions as you make them

As design decisions arise — a database choice, an API shape, a framework — capture the non-obvious ones in short LLPs while the reasoning is fresh. Early documents tend to be RFCs ("chose SQLite over Postgres because this is a single-node CLI tool"), Decisions, or Principles ("prefer explicit configuration over convention-based magic"). Don't write documents preemptively; speculation without code decays fast.

### Annotate as you write code

The best time to add a `@ref` is immediately after writing the code it describes — the connection is fresh and accurate. A practical habit: when you finish implementing something covered by an LLP, add the reference before moving on.

### Don't over-invest upfront

- **Too many documents before there's code** is speculation. Write just enough to capture decisions actually made.
- **Annotating everything** is noise. Early code is volatile; wait until a module stabilizes before annotating heavily.
- **Perfect prose** isn't the bar. A rough LLP with stable section targets beats a polished document that never gets written.

A typical new project does well with 3–5 initial LLPs: the root explainer, one Principles or RFC for the first non-obvious architectural choice, and further documents as real decisions arise. Take the next number; don't plan the numbering scheme.

## Retrofit mode (brownfield)

Retrofit is where agents are most dangerous: they describe *what* code does but invent *why*. Keep observation and inference visibly separate using the provenance rules in [LLP 0000 §Provenance](./0000-linked-literate-programming.explainer.md#provenance-for-generated-rationale) — every generated claim is `[observed]`, `[confirmed]`, or `[inferred]`, and documents with `[inferred]` claims stay `Draft` until a human ratifies them.

### 1. Understand the codebase first

Before writing documents, build a map: the directory structure and major subsystems; entry points and public APIs; the dependency graph and boundaries; git history (`git log --stat`, `git shortlog -sn`) to see where activity concentrates; and existing documentation — READMEs, wikis, ADRs, design docs are *source material*, not noise. An agent can do much of this: "read the codebase and produce an architecture summary identifying subsystems, responsibilities, and interactions" is a reasonable seed for LLP 0000.

### 2. Identify subsystems and draw boundaries

From the survey, identify the 5–15 major subsystems — typically top-level packages, abstraction boundaries (parsing vs. business logic vs. persistence), and cross-cutting concerns (auth, logging, error handling). A working map beats a perfect decomposition.

### 3. Write the root document, then key subsystem LLPs

Write LLP 0000 to minimize cold-start cost: after reading it, a newcomer should know where to look for anything. Then write LLPs for the subsystems that are frequently misunderstood (where do bugs cluster?), non-obvious (where would reading the code mislead?), cross-cutting (coordinated assumptions across files), or actively developed. For each: what it does and why it's a separate concern, key design decisions, invariants, and boundaries.

A productive drafting loop: the agent reads the subsystem and drafts; a human corrects the rationale and adds context the code can't express (performance requirements, contractual constraints, lessons from incidents); the agent refines. The agent sees the *what* clearly; the *why* needs the human pass.

### 4. Annotate in layers — never all at once

A bulk annotation pass produces low-quality references. Instead:

1. **Module-level references first.** A broad `@ref` at the top of each major file pointing to its governing LLP — high value, low effort, immediate orientation for agents.
2. **Key function references next.** Section-level references on functions implementing specific, non-obvious decisions — where the "why" isn't visible in the "what."
3. **Boy scout rule continuously.** When touching a file, add or update references for the code you're changing.

Agents can propose annotations ("read LLP 0005 and `src/auth/tokens.py`; propose `@ref`s where the connection is specific and non-obvious") — review them, since an agent may misattribute which section a function implements. Apply only after approval.

### 5. Migrate existing documentation

- **Convert valuable docs to LLPs:** assign numbers, add the metadata header, ensure stable section targets, and update content to current reality.
- **Delete or tombstone stale ones.** A 2019 design doc that no longer matches the code is harmful; git keeps the history.
- **Link, don't duplicate:** if an external spec is authoritative, `@ref` it rather than copying it into an LLP.

### 6. Phased rollout

- **Phase 1 (a session or two):** survey, LLP 0000, the 2–3 highest-priority subsystem LLPs, module-level refs for those, `AGENTS.md`.
- **Phase 2 (ongoing):** remaining subsystem LLPs; module-level refs project-wide; function-level refs where development is active.
- **Phase 3 (continuous):** boy-scout annotation; agent-assisted sprints for complex subsystems; refine documents as understanding deepens.
- **Phase 4 (when the corpus warrants it):** `ref-check` in CI.

## Common pitfalls

- **Treating adoption as a one-time project.** LLP is a practice; set-up-and-walk-away decays like any documentation.
- **Agent-generated documents without human review.** Agents describe *what* reliably and infer *why* unreliably — every generated LLP needs a human rationale pass (that's what the provenance tags make visible).
- **Documenting the entire history.** Active LLPs represent current thinking; reconstruct only the decisions that still shape the code today.
- **A reference is only worth adding if it's accurate and specific.** Every `@ref` should tell you something you wouldn't know from the code and filename alone.
