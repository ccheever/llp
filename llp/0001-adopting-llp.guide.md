# LLP 0001: Adopting LLP

**Type:** Guide
**Status:** Active
**Systems:** LLP
**Author:** Charlie Cheever / Claude
**Date:** 2026-04-01
**Revised:** 2026-08-25 (unit of adoption, interview-before-draft retrofit, rewritten Phase 1, per [LLP 0001.000](./0001.000-retrofit-interview.guide.md). Earlier: 2026-07-23, skill-install step per [LLP 0010](./0010-skill-install-super-refine-ship.rfc.md); 2026-06-10, merged with the former LLP 0002 retrofit guide, per [LLP 0009](./0009-capability-invariant-core.rfc.md))
**Related:** LLP 0000, LLP 0001.000, LLP 0010

## Summary

This guide covers bringing LLP to any repository **or package**. Greenfield and brownfield are not two processes — they are two ends of one spectrum: *how much design knowledge already exists to mine*. A fresh tree needs structure and habits (**scaffold**); an established codebase additionally needs comprehension, a maintainer interview, drafting, migration, and annotation (**retrofit**). The `llp-adopt` skill automates both modes; this guide is the underlying workflow.

## Choosing a mode

Inspect the **adoption root** first (see [Unit of adoption](#unit-of-adoption)). Is there already an `llp/` directory on the walk (extend it — don't start a second setup layer)? Are there agent-instruction files? How much code and documentation exists *inside that root*?

- **Little or no code/docs to mine** → scaffold.
- **Substantial existing code, docs, or history** → retrofit. Retrofit is scaffold plus comprehension; everything in the scaffold section applies to both.

## Unit of adoption

The unit of adoption is a **directory with a coherent API or ownership boundary** — a git repo, a publishable package in a monorepo, or an app — not automatically the git root.

**Resolution.** Walk from cwd (or the path in scope) toward the git root. Collect every ancestor that contains `llp/` and every ancestor that matches a package marker. Then:

1. If an `llp/` exists on the walk, **extend it** — never a second setup layer at the same root — unless the user passed `--scope cwd` or `--scope <path>` *and* that path is strictly inside the existing corpus root (explicit nest).
2. Else use the **nearest package root**. A package marker is any one of: `expo-module.config.json` (or equivalent native-module manifest); `package.json` plus at least two of `src/`, `ios/`, `android/`, `plugin/`; `package.json` `repository.directory` pointing at this directory relative to the git root. Markers are tested on each ancestor, not only cwd — `packages/foo/ios/Current` resolves to `packages/foo`, not the monorepo root.
3. Else, if the start is the git root, use it. If no ancestor matched, ask once, defaulting to the git root.

Prefer the nearest package over the git root. Defaulting a random subdirectory to the git root is the monorepo-drowning failure.

**Corpus-root discovery for every skill.** `llp-orient`, `llp-create`, `llp-review`, `llp-maintain`, `llp-super-refine`, and `llp-adopt` resolve the corpus as the nearest `llp/` walking up from the path in scope. They number and write against that root. Missing corpus means *no `llp/` on that walk*, not "cwd has no `llp/`." Adopt's closing message names the root so the next invoke does not guess.

**Confirm before work.** One line, before any write or full survey: the resolved root, scaffold vs retrofit, interview on or off.

**File-count brake.** If the source-file count under the resolved root exceeds the documented brake (the number is recipe in [LLP 0001.000](./0001.000-retrofit-interview.guide.md)), halt and re-ask scope. Do not survey it. The brake is a mis-detect backstop, not the primary heuristic.

**Nested corpora.** `llp/` at a package is a separate corpus. Numbers are local to the root. `ref-check` skips a nested `llp/` when run from a parent; check the child with `ref-check --root <adoption-root>` ([LLP 0000 §6](./0000-linked-literate-programming.explainer.md#6-validation-ref-check)).

**`AGENTS.md`.** Default: write the managed block at the **adoption root** only. A git-root pointer is an extra confirm, default no.

**Skills and receipts.** Skills install at the user/global location or the **git root**, never per-package. Receipts and `.llp/policy.json` resolve at the git root or the user-global install ([LLP 0010.000](./0010.000-skill-installation-and-updates.spec.md)). A scoped `.llp/` holds only the adopt journal (`adopt-run.md`) and its gitignore — never a skills receipt. `--persist-run` defaults off; the journal is gitignored unless the maintainer opts in.

**Later parent corpus.** Nested corpora stay nested until an explicit per-package promotion (remap numbers, rewrite `@ref`s, delete the nested `llp/`). Until then a parent 0000 points at children with **path or URL** refs, never `LLP NNNN` (numbers are per-root). Promotion is one package at a time; mixed nested/folded state is expected. The procedure is a sketch, not a `llp-maintain` intent in this revision.

## Shared spine (both modes)

1. **Create `llp/` at the adoption root.** Flat is fine to start; add subdirectories only when a domain has enough documents to warrant grouping. Include `current/` and `foundation/` overlay directories.
2. **Write LLP 0000, the root document** — typically an `Explainer` carrying `**Role:** Root`: what the project does and why, the major subsystems and how they relate, and key constraints or invariants that aren't obvious from the code. Even a half-page is valuable; it gives agents a starting point and humans a place to point newcomers. Generated roots stay `Draft` and are linked into `current/`; they enter `foundation/` when the author makes them `Active`.
3. **Configure agent instructions.** Add or update `AGENTS.md` *at the adoption root* so agents know: where LLP documents live; to read relevant LLPs before changing areas they cover; to add `@ref` annotations when implementing non-obvious documented decisions; to update LLPs when the design changes; and to flag code that contradicts its referenced LLP. When a tool expects `CLAUDE.md`, symlink it to `AGENTS.md` rather than maintaining divergent copies. This is what makes LLP self-reinforcing: agents told about the system maintain it as they work.
4. **Reruns are idempotent.** Setting up twice must not duplicate files or instruction blocks. Bare `/llp-adopt` at a root that already has `llp/` **extends** (never a second 0000). `--resume` continues a mid-run journal.
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

**Interview, then draft.** Retrofit does not draft LLPs until a maintainer interview has run, or the user passed `--skip-interview`. `--skip-interview` does **not** lower provenance: every *why* stays `[observed]` or `[inferred]`; nothing is `[confirmed]` without a named human and a date; documents stay `Draft`. Skip-interview is not a way to ship. The survey and question recipe lives in [LLP 0001.000](./0001.000-retrofit-interview.guide.md). **Every interview question names an evidence card** — ungrounded questions are a defect.

### 1. Understand the codebase first

Before writing documents, build an **evidence deck**, not a draft LLP 0000: directory structure and major subsystems; entry points and public APIs; git history path-limited to the adoption root; existing documentation — READMEs, wikis, ADRs, design docs, and user-facing pages the package already points at are *source material*, not noise. Claims in the deck are `[observed]` with a path or SHA. Never recover *why* in the survey. Do not walk outside the adoption root except a single hop to user-facing docs the package already links.

### 2. Identify subsystems and draw a shortlist

From the survey, identify **5–10 subsystem names** for the interview — typically packages, abstraction boundaries (parsing vs. business logic vs. persistence), and cross-cutting concerns (auth, logging, error handling). This is a shortlist, not a writing plan. A working map beats a perfect decomposition.

### 3. Interview, then write the root document

Survey output is cards. The interview extracts the *why* the code cannot express (rejected alternatives, incidents, contractual "don't simplify this"). Answers become `[confirmed]` `(Name, YYYY-MM-DD)`. "I don't know" is valid: keep the claim `[observed]` or `[inferred]`; do not invent.

Then write LLP 0000 to minimize cold-start cost: after reading it, a newcomer should know where to look for anything. Draft from `[confirmed]` claims first, then `[observed]` structure, then a short `[inferred]` section labelled as such — or omit it. Write at most two subsystem docs, and only if the interview produced a cluster that would bury 0000. Follow-on docs are `llp-create`. Ratification is `llp-review` / `llp-super-refine` — adopt does not change `Status`.

### 4. Annotate in layers — never all at once

A bulk annotation pass produces low-quality references. Instead:

1. **Propose** a `@ref` list in the adoption plan. Apply only after approval.
2. **Module-level references** at the top of each major file pointing to its governing LLP — high value, low effort, immediate orientation for agents. Not applied in Phase 1.
3. **Key function references** next. Section-level references on functions implementing specific, non-obvious decisions — where the "why" isn't visible in the "what."
4. **Boy scout rule continuously.** When touching a file, add or update references for the code you're changing.

Agents can propose annotations ("read LLP 0005 and `src/auth/tokens.py`; propose `@ref`s where the connection is specific and non-obvious") — review them, since an agent may misattribute which section a function implements.

### 5. Migrate existing documentation

- **Convert valuable docs to LLPs:** assign numbers, add the metadata header, ensure stable section targets, and update content to current reality.
- **Delete or tombstone stale ones.** A 2019 design doc that no longer matches the code is harmful; git keeps the history.
- **Link, don't duplicate:** if an external spec or user-facing API page is authoritative, `@ref` it rather than copying it into an LLP.

### 6. Phased rollout

**Phase 1 quality bar** — a first pass is good enough to refine when all of these are true:

1. A newcomer or agent who reads only LLP 0000 knows what the package is, where the code lives, and where to look next (named subsystems, even if those docs do not exist yet).
2. **5–10 don't-simplify constraints** are `[confirmed]` with name and date, or explicitly listed as unanswered.
3. Every architectural *why* that was not confirmed is tagged `[inferred]` or omitted. Fluent untagged rationale is a defect.
4. User-facing docs are linked, not forked.
5. `@ref`s are **proposed**, not applied.
6. The corpus is `Draft`. `foundation/` is empty. `current/` links the new docs. No speculative LLPs 0003–0015.

- **Phase 1 (a session or two):** survey + interview, LLP 0000, 0–2 subsystem docs if the interview produced a cluster that would bury 0000, a proposed `@ref` list, `AGENTS.md` at the adoption root.
- **Phase 2 (ongoing):** remaining subsystem LLPs via `llp-create`; module-level refs project-wide; function-level refs where development is active.
- **Phase 3 (continuous):** boy-scout annotation; agent-assisted sprints for complex subsystems; refine documents as understanding deepens.
- **Phase 4 (when the corpus warrants it):** `ref-check` in CI (`--root` at the adoption root).

## Common pitfalls

- **Treating adoption as a one-time project.** LLP is a practice; set-up-and-walk-away decays like any documentation.
- **Agent-generated documents without an interview** (or an equivalent named-human pass). Agents describe *what* reliably and infer *why* unreliably. Asynchronous review of a skip-interview draft counts; a wall of untagged *why* does not. That is what the provenance tags make visible.
- **Documenting the entire history.** Active LLPs represent current thinking; reconstruct only the decisions that still shape the code today.
- **A reference is only worth adding if it's accurate and specific.** Every `@ref` should tell you something you wouldn't know from the code and filename alone.
- **Surveying the git root of a monorepo.** The unit of adoption is the package (or other coherent directory). Confirm the root before the survey.
