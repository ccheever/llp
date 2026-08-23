# LLP 0000: Linked Literate Programming

**Type:** Explainer
**Status:** Active
**Systems:** LLP
**Role:** Root
**Author:** Charlie Cheever / Claude
**Date:** 2026-04-01
**Revised:** 2026-08-22 (LLP v2 per [LLP 0011](./0011-llp-v2-overlays-and-sub-llps.rfc.md): sub-LLPs, overlays, flat corpus; earlier simplified per [LLP 0009](./0009-capability-invariant-core.rfc.md), absorbed LLP 0006)

## Summary

This document specifies a lightweight system for linking code to its design rationale through machine-readable references to document sections. Instead of embedding verbose explanations in source files, code carries thin pointers — standardized comments that reference specific sections of LLP documents. Agents and humans follow these links to retrieve deeper context on demand.

The system is organized in two layers:

**LLP Core** defines the minimum contract every LLP-enabled project needs:

1. **LLP documents** — numbered, living design documents that capture the thinking behind a software system, consumable and modifiable by both humans and agents
2. **A reference syntax** — a standard comment format (`@ref`) pointing from code to document sections
3. **Attachment semantics** — rules for what code construct a `@ref` binds to
4. **Section anchors** — stable targets in LLP documents that references point to

**LLP Extensions** are optional capabilities that layer on top of the core:

5. **Relation types** — optional semantic qualifiers (`implements`, `constrained-by`, `tests`, `explains`) on references
6. **`ref-check`** — a single-file deterministic checker that validates references and metadata, suitable for CI
7. **Annotated source views** — on-demand literate-programming views organized by design intent rather than compiler order

Throughout the corpus, content is either **contract** (normative: what must be true) or **recipe** (advisory: one way to do it, marked as such and safe to skip) — see [Contracts and recipes](#contracts-and-recipes).

## Motivation

### Agents need context but source comments are a poor vehicle

AI agents working on unfamiliar code face a dilemma: read everything (slow, noisy) or read nothing and infer intent (fast, error-prone). Inline comments help but they have fundamental problems: they go stale without breaking the build; long comments cost attention every time the file is read, whether the context is needed or not; and they can't express how much context to pull in or where the deeper rationale lives.

### Design rationale exists but code doesn't point to it

Any project of sufficient complexity accumulates design knowledge — in people's heads, in chat threads, in docs that get written and forgotten. The codebase references this knowledge informally (`// See the auth design doc`), but these references don't point to specific sections, aren't machine-readable, and can't be validated.

The gap is permanent, and it does not close as models improve: the *why* behind code — the rejected alternative, the contractual constraint, the lesson from an incident — is information the code does not contain. A more capable model doesn't recover unrecorded rationale; it produces a more convincing guess. Writing the rationale down, and linking it from the point of use, is the only fix.

### Humans reviewing AI-generated code need breadcrumbs

As agents write more code, humans reviewing that code need efficient ways to understand *why* a particular approach was taken. AI-generated code is characteristically "locally plausible but globally constrained" — the mechanism looks correct in isolation, but the real question is whether it satisfies cross-cutting invariants that aren't visible in the immediate context. A reference to a specific document section shifts review from "what on earth is this doing?" to "does this satisfy the intended constraint?" — a far more productive question.

---

## LLP Core

The core defines four concepts. These are sufficient on their own — a project can adopt LLP without any of the extensions.

### 1. LLP documents

LLP documents are the prose side of a software system — they capture the thinking, rationale, plans, constraints, and decisions that aren't encoded directly in code. They are numbered markdown files that live alongside the codebase.

#### Living documents

LLP documents are **living documents**, not immutable records. Active LLPs should be kept up to date as the system evolves. When an LLP is no longer current but still worth preserving for migration or historical context, mark it `Superseded` or `Tombstoned` as appropriate — in the header, never by moving the file. When it is no longer worth keeping in the tree, delete it. Git provides the history.

This is a deliberate departure from systems like ADRs where documents are append-only. A stale design document that no longer matches the code is actively harmful — it misleads agents and humans alike.

#### For humans and agents

LLP documents are designed to be read, written, and modified by both humans and AI agents. An agent implementing a feature reads the relevant LLP to understand the design intent. A human reviewing agent-generated code follows `@ref` links back to the LLP to verify the agent understood the constraints.

#### Numbering

Filenames follow the grammar `NNNN(.NNN)*-slug.type.md`: a four-digit number from one global sequence, optionally followed by dotted three-digit child segments, then a slug and the lowercased document type (e.g. `0042-authentication.rfc.md`, `0042.000-session-tokens.spec.md`). The zero-depth form `NNNN-slug.type.md` is the common case. Encoding the type in the filename makes it visible in directory listings and diffs without opening the file.

**Identity.** The full (dotted) number is the document's identity: it appears in the title (`# LLP 0042.000: …`), in `@ref LLP 0042.000#anchor`, and in `Related:` lines. Numbers at every level are allocated in creation order and are **never reused — including numbers of documents later deleted**. An allocator that derives the next number from the tree must also consult history (git) for deleted ones.

**Sub-LLPs.** `0042.000` is the first child of LLP 0042, `0042.000.000` its first grandchild, to any depth. Children are numbered `000`, `001`, … in creation order under their parent; nothing is reserved. The parent must exist (`ref-check` gates this), and a parent with children is tombstoned rather than deleted. Position is fixed at birth: a document is never re-parented by renaming — link to it from where it also belongs. Each sub-LLP has its own `Status:` and lifecycle; the tree is a naming relationship, not a promotion unit. Depth is unbounded; two levels cover nearly everything, and deeper is a smell. A typical use: an RFC at `0042`, the spec pinning down what was accepted at `0042.000`, the execution plan at `0042.001`.

**Allocation on branches.** A number allocated on a branch is provisional until integration: if two branches allocate the same number (at any level), the later-integrated document renumbers, rewriting every reference to it, before merge. `ref-check`'s duplicate-number gate is what catches the collision.

#### Filesystem organization

**Path is not lifecycle.** An LLP lives under `llp/` and keeps its path for its whole life; its lifecycle is carried by its `**Status:**` header and by the two overlays below, never by where it sits. Nothing is moved to change its state. (Documents may still be *deleted* when no longer worth keeping — see [Living documents](#living-documents) — their numbers stay allocated.)

```
llp/
  0000-project-overview.explainer.md
  0003-binary-protocol.explainer.md
  0015-message-compression.rfc.md
  0015.000-compression-format.spec.md
  0009-legacy-sync-design.decision.md      # Status: Tombstoned — still here
  current/                                  # symlinks: what's being worked on
    0015-message-compression.rfc.md -> ../0015-message-compression.rfc.md
    0015.000-compression-format.spec.md -> ../0015.000-compression-format.spec.md
  foundation/                               # symlinks: the kernel
    0000-project-overview.explainer.md -> ../0000-project-overview.explainer.md
    0003-binary-protocol.explainer.md -> ../0003-binary-protocol.explainer.md
  reviews/                                  # review artifacts (LLP 0005), not LLPs
```

Grouping subdirectories under `llp/` are valid but meaningless — `@ref LLP 0003#focus-trapping` doesn't encode a path, so documents can be regrouped without breaking `LLP`-form references (path-form references and markdown links do break on a move, which is one more reason not to move things). Sub-LLP numbering, not directories, is how related documents are grouped; this repo keeps `llp/` flat. `current/`, `foundation/`, and `reviews/` are reserved names and are not document directories.

The root document of a project is an **Explainer** carrying `**Role:** Root`; LLP 0000 is the entry point, and belongs in `foundation/` from the moment it is `Active`.

#### Current and foundation

Two directories under `llp/` hold **links only** — each entry names one document in `llp/` by relative path. The document is the file; the link is a tag. Adding or removing a link never touches the document.

| Overlay | What an entry means | How it changes |
|---|---|---|
| `llp/current/` | The project's **declared working set**: this document is in play — being written, revised, discussed, or implemented. Committed and branch-scoped like any other file; an entry is a claim the project makes, not a live sensor of anyone's attention. | Link a document when work on it starts (new LLPs are linked by default); remove the link when the work is done. Removal is the whole archive operation. On a shared branch, remove only links for work you own or that the curation pass has judged idle. |
| `llp/foundation/` | The **kernel**: the smallest set of documents from which the project's design could be recreated — see the admission test below. | Promotion is an editing act: fold what survived from proposals into the living document, then link the living document. Demotion is removing the link. `foundation/` may be empty (a fresh adoption whose root is still `Draft`). |

**Representation.** The canonical entry is a relative symlink (`ln -s ../0042-x.rfc.md llp/current/0042-x.rfc.md`). A regular file whose entire content is that same relative path is equivalent — it is exactly what git materializes on a checkout without symlink support (`core.symlinks=false`), so overlays survive Windows checkouts and archive transports unchanged. Absolute targets are invalid. Dotfiles in an overlay are ignored; an absent overlay directory means an empty overlay, and the skills create it on first use.

**Admission test for foundation.** "Recreate" means the *design*, not a runnable tree: the decisions still in force, the constraints code must satisfy, and the rationale that keeps those decisions from being silently re-made. History — rejected alternatives, superseded designs, the record of how a decision was reached — is not kernel unless the decision is one the project would otherwise re-litigate. So: the root explainer, principles, and current-truth specs typically pass; accepted RFCs typically fail (their surviving decisions belong folded into a living document); guides pass only when the procedure they describe is itself a design commitment. The test is set-level: the proposed foundation must be *collectively* sufficient, and removals are tested one at a time against the proposed set, re-testing after each removal — never pairwise. Too small is a failure too: if orienting from `foundation/` alone would miss a binding constraint, something is missing.

**Rules gated by `ref-check`:** every overlay entry resolves, by relative path, to an LLP under `llp/`; `Tombstoned` documents appear in neither overlay; `foundation/` entries are `Active`; `Superseded` documents may appear in `current/` (a migration in progress is work) but not in `foundation/`.

**Curation contract.** A curation pass runs its verbs in order — **promote**, then **archive**, then **realign** — and proposes; a human applies. Realign compares code to `foundation/` only. Before any realignment is proposed, each foundation claim it relies on is checked against every other binding `Active` normative document; a conflict is resolved *in the same pass* by updating, folding, or superseding the non-foundation document (foundation wins) — or by recognizing the foundation claim as wrong and fixing foundation — never by proposing code against a known contradiction. Cadence, heuristics, and output format are advisory and live in [LLP 0011.000](./0011.000-curation-pass.guide.md); `llp-maintain --intent curate` runs it.

Orientation order for an agent is `foundation/` → `current/` → the `@ref` targets in scope; `ls` answers both. `ls llp/foundation` should read as a newcomer's table of contents and stay small; `ls llp/current` is the project's statement of what is in play.

#### Metadata header

Every LLP begins with a small metadata header directly below the title — a plain markdown block, not YAML frontmatter, so it reads well in any renderer and parses line-by-line.

Required fields: `**Type:**`, `**Status:**`, `**Systems:**` (one or more systems this LLP applies to), `**Author:**`, `**Date:**` (`YYYY-MM-DD`).

Optional fields: `**Role:** Root` (entry-point document), `**Revised:** YYYY-MM-DD` (last substantive revision), `**Related:**` (nearby documents worth reading with this one).

#### Types and statuses

All LLP documents live in one unified system, classified by metadata rather than split across directories (`rfcs/`, `docs/`, `adrs/`). **Type** classifies content; **Status** classifies lifecycle. They are orthogonal.

The **standard types** — projects can use a subset or define their own:

| Type | What it is |
|------|-----------|
| **RFC** | A design proposal — the "what" and "why" of an approach, open for discussion |
| **Spec** | Normative requirements the code must follow — the "must" and "must not" |
| **Decision** | A specific choice and its rationale, like an ADR |
| **Plan** | Execution or implementation steps — the "how" and "when" |
| **Explainer** | Teaching material — helps someone understand a subsystem or concept |
| **Principles** | Core beliefs that guide decisions — the "always" and "never" |
| **Guide** | Usage documentation — how to use, configure, or work with something |
| **Issue** | A bug, problem, or investigation — what's wrong and what we know |
| **Research** | Findings from exploration or analysis — what was learned and how confident we are |

The **standard statuses**:

| Status | What it means |
|--------|---------------|
| **Draft** | In progress; not yet the settled guidance |
| **Review** | The author has opted this document into a formal review loop (see [LLP 0005](./0005-rfc-process.guide.md)) |
| **Accepted** | Approved for implementation; design stable, code not yet written |
| **Active** | Current guidance |
| **Superseded** | Replaced by newer guidance but kept for migration context; say what replaced it in `**Superseded by:**`. May sit in `current/` while the migration is in progress; never in `foundation/` |
| **Tombstoned** | Rejected or superseded; read for history only. Its `@ref`s are not validated (it may cite things that no longer exist), and it may not appear in `current/` or `foundation/` |

Note that "not current" is not a status. A finished, correct document that nobody is discussing is simply `Active` and absent from `current/`. `Tombstoned` is reserved for documents whose claims should no longer be believed.

`Review` and `Accepted` are mainly used by proposal-type documents (RFCs, Specs, Plans). Other types typically move directly from `Draft` to `Active`. How much review a document gets before promotion is the author's call, proportional to stakes — see LLP 0005.

#### The Systems field

The `**Systems:**` field makes LLP queryable: an agent working on protocol code can ask "which LLPs cover `Protocol`?" and get RFCs, specs, and explainers in one result. Guidelines: match your real architecture; keep the vocabulary consistent (`Auth`, not sometimes `Authentication`); stay flat unless you need dot-notation hierarchy; multiple systems per document are normal; evolve the vocabulary as the system grows.

### 2. Reference syntax

Code references use the following format:

```
@ref <target>[#anchor] [relation] — Optional short gloss
```

The `@ref` prefix makes references grep-able and distinguishable from casual mentions in prose. The gloss after the em dash is optional, ≤80 characters, and summarizes what the section explains. The optional `[relation]` qualifier is an extension (see [§5](#5-relation-types)).

**All target forms:**

| Target form | Example | Resolves to |
|---|---|---|
| LLP number | `@ref LLP 0012 — Auth subsystem` | A whole LLP document |
| LLP number + anchor | `@ref LLP 0074#focus-trapping — Tab-escape prevention` | A specific section |
| Repo path (any file type) | `@ref docs/diagrams/camera-lifecycle.svg — State machine` | A file in the repo |
| Repo path + anchor | `@ref docs/vendor/openid-spec.md#token-validation` | A section of an in-repo doc |
| Project shorthand | `@ref SPEC#binary-header — Header layout` | A project-defined label, expanded per project convention |
| URL | `@ref https://datatracker.ietf.org/doc/html/rfc6749#section-4.1 — OAuth code flow` | An external resource |

In context:

```rust
// @ref LLP 0074#focus-trapping — Focus trapping prevents tab-escape from modals
pub fn trap_focus_in_modal(node: NodeId) -> Result<()> {
```

#### Non-markdown and external targets

Design rationale doesn't only live in markdown: state-machine diagrams, Figma frames, external specifications, and issue threads are legitimate reference targets.

- **Any in-repo file type is a valid path target** (`.svg`, `.png`, `.mermaid`, …). Fragment anchors are only meaningful where the format supports them (SVG element ids, Mermaid node ids); otherwise omit the anchor and reference the whole artifact.
- **URLs are valid targets**, recognized by the `https://` (or `http://`) prefix; the URL's own fragment serves as the anchor. URLs can go stale, so validation treats them lightly (see [§6](#6-validation-ref-check)). For complex external artifacts that need prose explanation, wrapping them in an LLP is good practice but never required.
- **Shorthands** (`SPEC#binary-header`) compress recurring targets. The mapping from label to target is project-defined; until a project documents one, tooling lists shorthand refs as unchecked rather than failing them.

A single `@ref` prefix covers all of these — one grep finds every rationale link, and the target form distinguishes the kind.

#### Multiple references

A code region can carry multiple references:

```rust
// @ref LLP 0003#opcode-ordering — OpCode ordering guarantees
// @ref LLP 0012#batching — Reconciler batching strategy
fn flush_and_reconcile(buffer: &SharedMemoryBuffer) -> Result<()> {
```

User-facing documentation uses the same prefix (`@ref guides/navigation.md#tab-persistence`), creating a navigable chain: **code** ↔ **LLP documents** ↔ **user-facing docs**.

### 3. Attachment semantics

A `@ref` annotation attaches to a specific code construct:

1. **Contiguous `@ref` lines attach to the next syntactic node** — a function, class, struct, constant, or other declaration.
2. **Doc-comment `@ref` lines attach to the file or module** (e.g., `//!` in Rust, a module-level docstring in Python, or the first comment block before any code).
3. **Otherwise, attach to the next non-comment line.**

A blank line between a `@ref` and its target breaks the attachment — the annotation becomes free-floating and should be flagged. Place annotations directly above the code they describe.

### 4. Section anchors in LLP documents

References can use either **heading slugs** (`#focus-trapping`) or **numbered sections** (`#3.1`). Heading slugs are the recommended default: they survive restructuring, so a living document can be reordered and merged freely without breaking any `@ref` in the codebase. Numbered sections are compact and suit stable, spec-like documents where structure is settled; the tradeoff is that inserting a section means renumbering and updating references. Mixing within a document is fine.

---

## LLP Extensions

Everything in this section is optional and independently adoptable.

### 5. Relation types

A `@ref` can carry a **relation type** qualifying the link:

| Relation | Meaning |
|----------|---------|
| `implements` | This code realizes the referenced design |
| `constrained-by` | This code is shaped by constraints documented there |
| `tests` | This code tests the behavior described there |
| `explains` | This code is the subject of the referenced explanation |

```typescript
// @ref LLP 0003#opcode-ordering [implements] — Creates before updates before deletes
export function flushOpCodeBuffer(buffer: SharedArrayBuffer): void {
```

No relation means a general association — the default and most common case. Add relations when the distinction matters for indexing or retrieval; most references work fine without them.

### 6. Validation: ref-check

`ref-check` is a single-file, dependency-free checker (in this repo's root) for the places where no agent is in the loop: CI and pre-commit. Run it from a project root:

```bash
./ref-check            # check this repo
./ref-check --root X   # check another tree
```

**What it checks, per target form:** `LLP NNNN[#anchor]` — the document exists and, when given, the anchor heading exists. `path[#anchor]` — the file exists (any type); anchors are checked in markdown targets and reported `unchecked` for non-text formats. Shorthands — listed as unchecked unless the project defines a mapping. URLs — shape-validated, never fetched. **Corpus-wide:** metadata headers parse; the filename's `type` matches `**Type:**`; LLP numbers (dotted included) are unique and every sub-LLP's parent exists; overlay entries are relative links to LLPs under `llp/` (symlink or path-content file), no `Tombstoned` document is in an overlay, no `Superseded` document is in `foundation/`, and `foundation/` entries are `Active` (see [Current and foundation](#current-and-foundation)); a malformed `LLP`-prefixed target (`LLP 0011.00`, `LLP 10000`) is an error, not an unchecked shorthand; no `[inferred]` claim survives in an `Accepted`/`Active` document (see [Provenance](#provenance-for-generated-rationale)).

**Severity:** broken references, malformed metadata, duplicate or orphaned numbers, overlay violations, and `[inferred]`-past-`Draft` exit non-zero. Anything requiring judgment — stale glosses, orphaned annotations, doc/code drift — is deliberately *not* gated; that's interactive work for an agent plus a human (the `llp-maintain` skill).

Possible future stages — a bidirectional code↔doc index, a deterministic annotated-source renderer, suspect-link detection on section edits — would extend the same scan. None is committed; see LLP 0009.

### 7. Annotated source views

The most novel idea LLP inherits from literate programming: present code in the order that makes sense for *understanding* — grouped by the design intent it implements — rather than the order the compiler demands. Because prose lives in LLP documents and code carries `@ref` pointers, this "woven" view can be generated on demand instead of maintained by hand.

> **Recipe (advisory)** — any capable agent can produce this view from a prompt; no tooling required:
>
> *"Read `<file>` and the LLP sections its `@ref` annotations point to. Produce a rationale-order view: group the file's constructs by the LLP section they reference, in the order those sections appear in their documents; under each group, quote the referenced prose, then list the constructs (name, line number, signature). Put unreferenced constructs in a final 'Unreferenced' group. Flag any `@ref` that doesn't resolve."*
>
> Sample output shape:
>
> ```
> ━━ LLP 0074#focus-management — Focus trapping, restoration, custom order ━━
>   "When a modal is presented, focus must be trapped within it…"
>   trap_focus_in_modal (line 42) · restore_focus (line 88) · set_focus_order (line 121)
>
> ━━ Unreferenced ━━
>   format_timestamp (line 17) · internal_helper (line 201)
> ```

Treat an LLM-rendered view as a draft (it can misattribute); a deterministic renderer is a possible future `ref-check` stage.

---

## Conventions

### When to add a reference

- **Do** reference when: the code implements a non-obvious documented decision; the code is part of a cross-cutting system; the approach would look wrong without context; the domain is one where locally-plausible code is globally constrained (protocols, security boundaries, concurrency, migrations, billing).
- **Don't** reference when: the code is straightforward; the "why" is obvious from the "what"; the code is volatile and still being prototyped.
- **Rule of thumb:** if an agent might "simplify" this code in a way that would break the design intent, it needs a reference.

### Density and accuracy

There is no minimum annotation density, and accuracy beats coverage: a vague `@ref LLP 0074` on every file in a module is worse than no reference. Every `@ref` should tell you something you wouldn't know from reading only the code and filename.

### Maintenance

When modifying code that carries a `@ref`: check whether the referenced section still describes the code; if they've diverged, update the LLP (design changed) or the reference (code now implements something else); remove references that no longer apply. The documents follow the same principle — when the system evolves, update the document or mark it `Superseded`/`Tombstoned`.

### Contracts and recipes

Corpus content is either **contract** — normative statements of what must be true (document shapes, the reference grammar, lifecycle rules, behavioral protocols) — or **recipe** — advisory how-to that exists because it currently helps (pipelines, scaffolds, worked prompts). Recipes are marked with a `> **Recipe (advisory)**` blockquote and are safe to skip for runtimes that don't need them; they are deleted when the failure they prevent stops being observed. The sorting rule is [LLP 0004's capability test](./0004-design-principles.principles.md#the-capability-test).

### Provenance for generated rationale

When an agent generates LLP content by reading code (typically during retrofit), observation and inference must not blur:

- Generated rationale is tagged `[observed]` (evidenced directly in code or tests — say where), `[confirmed]` (verified by a named human, with date), or `[inferred]` (an unverified hypothesis).
- A document containing `[inferred]` claims stays `Draft`; ratify each to `[confirmed]` or delete it before promotion. This is the one rule `ref-check` gates mechanically.
- Never assert recovered "why" as fact — the tag *is* the honesty. The say-where and name-a-human obligations bind authors and are checked in review, not by the gate.

### Agent policy

Agents should add `@ref` annotations when they implement or modify code that realizes a documented, non-obvious design decision — preferring specific references over broad mechanical annotation, and updating or removing references the code no longer matches.

### Git workflow

LLP changes follow the code they document: the `@ref` and the doc update land in the same commit as the code change that motivated them. A commit that only updates LLP documents is a drift signal (occasional cleanup is fine; co-evolution is the norm). Merge conflicts in LLP documents are resolved like any markdown conflict — and are a chance to reconcile divergent thinking.

## End-to-end example

A minimal project:

```
my-project/
  llp/
    0000-my-project.explainer.md
    0001-auth-design.decision.md
  src/auth.py
  AGENTS.md
```

**`llp/0001-auth-design.decision.md`:**

```markdown
# LLP 0001: Authentication Design

**Type:** Decision
**Status:** Active
**Systems:** Auth
**Author:** J. Dev
**Date:** 2026-01-15

## Token strategy

Sessions use short-lived JWTs, rotated on privilege escalation to
prevent session fixation.

## Database choice

Chose PostgreSQL over DynamoDB for transactional guarantees across
the auth/billing boundary.
```

**`src/auth.py`:**

```python
# @ref LLP 0001 — Auth subsystem

# @ref LLP 0001#token-strategy [constrained-by] — Tokens rotate on privilege change
def rotate_on_escalation(session: Session) -> Session:
    ...

# @ref LLP 0001#database-choice [constrained-by] — PostgreSQL for txn guarantees
def get_db_pool(config: DBConfig) -> ConnectionPool:
    ...
```

`./ref-check` validates that LLP 0001 exists, that `#token-strategy` and `#database-choice` resolve to headings, and that the corpus metadata is well-formed.

## Adopting LLP

The adoption workflow — greenfield scaffolding and brownfield retrofit — lives in [LLP 0001](./0001-adopting-llp.guide.md), and the `llp-adopt` skill automates it. The principles in brief: don't over-annotate volatile early code; boy-scout-rule references in as you touch files; start with module-level refs for orientation; write LLPs when you actually make decisions, not preemptively; start flat and add structure when warranted.

## Non-goals

- **Replacing comments.** Normal comments remain right for local observations; `@ref` connects code to documented rationale.
- **Mandating coverage.** "Every function must have a reference" would bury the useful references in noise.
- **Literate programming as authoring format.** Prose and code are never interleaved in source files; the annotated view is generated output.

## Open questions

1. **Cross-file references.** Should a directory be able to declare "everything here implements LLP NNNN" without per-file annotations (a `.refs` manifest)?
2. **Shorthand mappings.** Where a project declares them is undefined until a real project needs one — see [LLP 0009](./0009-capability-invariant-core.rfc.md#open-questions).

## Prior art

A comprehensive survey is in [LLP 0003](./0003-prior-art.research.md). The most direct influences: **Knuth's WEB** (explanation-order presentation) and **Ramsey's noweb** (the value is cross-referencing and human-order presentation; keep tooling simple); **Jupyter and Eve** (cautionary tales for interleaving prose and code — LLP generates the woven view instead); **ADRs and Oxide RFDs** (repo-resident decision docs; LLP adds living documents and code-to-section links); **Diátaxis** (typed documents have different quality criteria); **requirements traceability** (linking code to rationale measurably reduces defects; the cost problem is solved by putting links in the code); **AI-era context studies** (verbose always-loaded context files hurt agent performance — the empirical case for pointers over prose).

The key synthesis: the minimum viable literate programming system is cross-references plus human-order presentation. Source files carry pointers, not prose; tooling keeps the pointers honest. No prior system links code to design rationale at section granularity with validated, machine-readable references — that is the gap LLP fills.
