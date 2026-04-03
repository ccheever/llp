# LLP 0000: Linked Literate Programming

**Type:** Explainer
**Status:** Draft
**Systems:** LLP
**Role:** Root
**Author:** Charlie Cheever / Claude
**Date:** 2026-04-01

## Summary

This document specifies a lightweight system for linking code to its design rationale through machine-readable references to document sections. Instead of embedding verbose explanations in source files, code carries thin pointers — standardized comments that reference specific sections of LLP documents. Agents and humans follow these links to retrieve deeper context on demand.

The system is organized in two layers:

**LLP Core** defines the minimum contract every LLP-enabled project needs:

1. **LLP documents** — numbered, living design documents that capture the thinking behind a software system, consumable and modifiable by both humans and agents
2. **A reference syntax** — a standard comment format (`@ref`) pointing from code to LLP document sections
3. **Attachment semantics** — rules for what code construct a `@ref` binds to
4. **Section anchors** — stable targets in LLP documents that references point to

**LLP Extensions** are optional capabilities that layer on top of the core:

5. **Relation types** — optional semantic qualifiers (`implements`, `constrained-by`, `tests`, `explains`) on references
6. **Validation tooling** — a pipeline of composable tools that extract references, validate targets, generate indices, and produce annotated views
7. **Annotated source generation** — on-demand literate programming views organized by design intent rather than compiler order
8. **Bidirectional index** — auto-generated reverse maps showing which code implements each document section

The most novel capability is annotated source generation: given `@ref` annotations, the system can produce a literate programming view organized by design intent rather than compiler order — the promise of literate programming without the maintenance burden of interleaving prose and code in source files.

## Motivation

### Agents need context but source comments are a poor vehicle

AI agents working on unfamiliar code face a dilemma: read everything (slow, token-expensive) or read nothing and infer intent (fast, error-prone). Inline comments help but they have fundamental problems:

- **They go stale.** Comments don't break the build when the code they describe changes.
- **Long comments are wasteful.** A 15-line comment explaining a design tradeoff costs tokens every time an agent reads that file, whether it needs that context or not.
- **They lack structure.** A comment can't express how much context an agent should pull in, or whether the rationale lives in a broader system design vs. a specific implementation decision.

### Design rationale exists but code doesn't point to it

Any project of sufficient complexity accumulates design knowledge — in people's heads, in Slack threads, in docs that get written and forgotten. The codebase references this knowledge informally — a comment like `// See the auth design doc` or a test file named `state-migration-rfc.test.tsx` — but these references are ad hoc:

- They don't point to specific sections, so an agent has to read the entire document to find the relevant part.
- There's no machine-readable format, so tooling can't validate them.
- There's no way to know *how much* context to pull in — is this a "read the whole doc" reference or a "read this one paragraph" reference?

### Humans reviewing AI-generated code need breadcrumbs

As agents write more code, humans reviewing that code need efficient ways to understand *why* a particular approach was taken. AI-generated code is characteristically "locally plausible but globally constrained" — the mechanism looks correct in isolation, but the real question is whether it satisfies cross-cutting invariants that aren't visible in the immediate context. A reference to a specific document section shifts code review from "what on earth is this doing?" to "does this satisfy the intended constraint?" — a far more productive question.

---

## LLP Core

The core defines four concepts. These are sufficient on their own — a project can adopt LLP without any of the extensions.

### 1. LLP documents

LLP documents are the prose side of a software system — they capture the thinking, rationale, plans, constraints, and decisions that aren't encoded directly in code. They are numbered markdown files that live alongside the codebase.

#### Living documents

LLP documents are **living documents**, not immutable records. Active LLPs should be kept up to date as the system evolves. When an LLP is no longer current but still worth preserving for migration or historical context, mark it `Superseded` or `Tombstoned` as appropriate. When it is no longer worth keeping in the tree, delete it. Git provides the history.

This is a deliberate departure from systems like ADRs where documents are append-only. A stale design document that no longer matches the code is actively harmful — it misleads agents and humans alike. Historical context can still be preserved, but it should be explicit via metadata and location rather than lingering as silently stale guidance.

#### For humans and agents

LLP documents are designed to be read, written, and modified by both humans and AI agents. They serve as shared context between human and AI collaborators. An agent implementing a feature reads the relevant LLP to understand the design intent. A human reviewing agent-generated code follows `@ref` links back to the LLP to verify the agent understood the constraints.

#### Numbering

LLP documents are identified by zero-padded numbers: `LLP 0000` through `LLP 9999`. Filenames follow the pattern `NNNN-slug.type.md`, where `type` is the lowercased document type (e.g., `0042-authentication.rfc.md`, `0007-error-handling.guide.md`). Encoding the type in the filename makes it visible in directory listings, tab-completion, and diffs without opening the file.

#### Filesystem organization

LLP documents live in an `llp/` directory. They can be flat or grouped into subdirectories for human convenience:

```
llp/
  0001-project-overview.explainer.md
  protocol/
    0003-binary-protocol.explainer.md
    0015-message-compression.rfc.md
    0028-header-format.spec.md
  auth/
    0017-session-management.guide.md
    0042-token-rotation.rfc.md
  tombstones/
    0009-legacy-sync-design.decision.md
```

Directories are not numbered — they're just organizational buckets. The LLP number is the identity; the directory is just storage. `@ref LLP 0003#focus-trapping` doesn't encode the directory path, so documents can be reorganized freely without breaking references.

`tombstones/` is a reserved bucket for LLPs that are no longer part of current guidance but are still worth keeping around for historical or migration context. Tombstoned LLPs remain referenceable by number, but they should be excluded from default "current LLP" views and should not be mistaken for active guidance.

When an LLP grows large enough that subtopics split into their own LLPs, the **lowest-numbered document** in a subdirectory is the root — it provides the overview and explains how the pieces fit together. This usually happens naturally (the root was written first, subtopics split off later). If it doesn't, documents can be renumbered to achieve it.

The root document should indicate its role in the metadata header:

```markdown
# LLP 0003: Binary Protocol

**Type:** Explainer
**Status:** Active
**Systems:** Protocol
**Role:** Root
**Author:** ...
**Date:** ...
```

Not every subdirectory needs a root. A directory might just be a loose grouping of related LLPs with no hierarchy. That's fine — the convention only applies when there's a natural parent/child relationship.

The root document of a project is typically an **Explainer** that orients readers to the system. The important part is that LLP 0000 is the entry point and carries `**Role:** Root`.

#### Metadata header

Every LLP begins with a small metadata header directly below the title. LLP uses a plain markdown metadata block, not YAML frontmatter. This keeps the format easy to read in any markdown renderer and easy for lightweight tooling to parse line-by-line.

Required fields:

- `**Type:**` — the document kind (what kind of content this is)
- `**Status:**` — the document lifecycle state (where it is in its lifecycle)
- `**Systems:**` — one or more systems, domains, or subsystems this LLP applies to
- `**Author:**` — the primary author or editors
- `**Date:**` — creation date in `YYYY-MM-DD`

Optional fields:

- `**Role:** Root` — marks an overview document that serves as the entry point for a project or subsystem
- `**Revised:** YYYY-MM-DD` — last substantive revision date
- `**Related:** LLP 0007, docs/foo.md` — nearby documents worth reading with this one

#### Types and statuses

LLP documents can take many forms. Rather than splitting them across directories (rfcs/, plans/, docs/), they all live in one unified system, classified by metadata:

```markdown
# LLP NNNN: Title

**Type:** RFC | Spec | Decision | Plan | Explainer | Principle | Guide | Issue | Research
**Status:** Draft | Review | Accepted | Active | Superseded | Tombstoned
**Systems:** Auth, Protocol, Reconciler, ...
**Author:** ...
**Date:** ...
```

**Type** classifies what kind of content the document contains. **Status** classifies where it is in its lifecycle. These are orthogonal — an RFC can be Draft or Active; a Spec can be Active or Superseded.

The following are the **standard types** — a core set that covers the most common kinds of design documents. Projects don't need to use all of them, and can define their own types beyond this list.

| Type | What it is |
|------|-----------|
| **RFC** | A design proposal — the "what" and "why" of an approach, open for discussion |
| **Spec** | Normative requirements the code must follow — the "must" and "must not" |
| **Decision** | A specific choice and its rationale — what was decided and why, like an ADR |
| **Plan** | Execution or implementation steps — the "how" and "when" |
| **Explainer** | Teaching material — helps someone understand a subsystem or concept |
| **Principle** | Core beliefs and values that guide decisions — the "always" and "never" |
| **Guide** | Usage documentation — how to use, configure, or work with something |
| **Issue** | A bug, problem, or investigation — what's wrong and what we know |
| **Research** | Findings from exploration, experiments, or comparative analysis — what was learned and how confident we are |

The distinction between types handles questions like "is 'we chose PostgreSQL over DynamoDB' an RFC or a Decision?" If the document is proposing the choice for discussion, it's an RFC. If the choice is settled and the document records what was decided, it's a Decision. If it specifies requirements that implementations must follow, it's a Spec.

The following are the **standard statuses**:

| Status | What it means |
|--------|---------------|
| **Draft** | In progress and not yet the settled guidance |
| **Review** | Draft is complete and undergoing multi-model review (see [LLP 0005](./0005-rfc-process.guide.md)) |
| **Accepted** | Approved for implementation; design is stable but code isn't written yet |
| **Active** | Current guidance |
| **Superseded** | Replaced by newer guidance but still kept in-tree for migration or compatibility context |
| **Tombstoned** | Historical context kept under `llp/tombstones/`; no longer current guidance |

`Review` and `Accepted` are primarily used by proposal-type documents (RFCs, Specs, Plans) that go through a formal review process before implementation. See [LLP 0005](./0005-rfc-process.guide.md) for the full authoring and review workflow. Other document types typically move directly from `Draft` to `Active`.

A project might also define its own types — for example, **Postmortem** (an incident retrospective) or anything else that fits the project's needs. The standard types are conventions, not constraints.

This replaces the traditional pattern of scattering knowledge across `rfcs/`, `docs/plans/`, `docs/`, `adrs/`, etc. The metadata is the taxonomy; the directory is just storage.

#### The Systems field

The `**Systems:**` field is what makes LLP a queryable knowledge system rather than just a folder of numbered markdown files. An agent working on protocol code can query "show me all LLPs where Systems includes 'Protocol'" and get RFCs, specs, explainers, and research notes in one result.

Guidelines for defining systems:

- **Match your architecture.** Systems should map to real subsystems, domains, or bounded contexts in your code. If you have an `auth/` package, `Auth` is a system.
- **Keep the vocabulary consistent.** Use the same system name across all documents that describe the same subsystem. Don't mix `Auth` and `Authentication`.
- **Stay flat unless you need hierarchy.** Most projects work fine with a flat list of systems. If you need hierarchy (e.g., `Protocol.Compression`), use dot-notation, but only when the distinction matters for querying.
- **Multiple systems are normal.** A document about how auth tokens interact with the protocol layer naturally belongs to both `Auth` and `Protocol`.
- **Evolve the vocabulary.** As the system grows, system names will shift. Update the metadata when it happens.

### 2. Reference syntax

Code references use the following format:

```
@ref LLP NNNN#anchor — Optional short gloss
```

Where:
- `LLP NNNN` is the document number (zero-padded to match the project's current width)
- `#anchor` is a heading slug (e.g., `#focus-trapping`) or a section number (e.g., `#3`, `#3.2`)
- The `#` delimiter follows the existing convention for markdown heading anchors and URL fragments
- The gloss after the em dash is optional, <=80 characters, and summarizes what the section explains

In context:

```rust
// @ref LLP 0074#focus-trapping — Focus trapping prevents tab-escape from modals
pub fn trap_focus_in_modal(node: NodeId) -> Result<()> {
```

```typescript
// @ref LLP 0003#opcode-ordering — OpCode ordering guarantees
function flushOpCodeBuffer(buffer: SharedArrayBuffer): void {
```

The `@ref` prefix makes references grep-able and distinguishable from casual mentions in prose comments.

#### Multiple references

A code region can carry multiple references:

```rust
// @ref LLP 0003#opcode-ordering — OpCode ordering guarantees
// @ref LLP 0012#batching — Reconciler batching strategy
fn flush_and_reconcile(buffer: &SharedMemoryBuffer) -> Result<()> {
```

#### Referencing non-LLP documents

The system can also reference documents that aren't part of the LLP numbering scheme — external specs, user-facing docs, files by path, or project-defined shorthands:

```rust
// @ref docs/vendor/openid-spec.md#token-validation — Token validation requirements
// @ref SPEC#binary-header — Binary header layout
```

Shorthand labels like `SPEC` can be defined in a project-level configuration file that maps them to actual file paths.

#### User-facing documentation also uses `@ref`

User-facing documentation uses the same `@ref` prefix as technical rationale. The target path and gloss make the distinction clear:

```typescript
// @ref LLP 0051#tab-persistence — Tab state persists across navigation
// @ref guides/navigation.md#tab-persistence — User-facing explanation of tab behavior
export function persistTabState(tabId: string, state: SerializableState): void {
```

Using a single prefix keeps the syntax and tooling simple. This still creates a navigable chain: **code** <-> **LLP documents** <-> **user-facing docs**.

### 3. Attachment semantics

A `@ref` annotation attaches to a specific code construct. The attachment rules are:

1. **Contiguous `@ref` lines attach to the next syntactic node.** One or more consecutive `@ref` comment lines immediately followed by a function, class, struct, constant, or other declaration attach to that declaration.

2. **Doc-comment `@ref` lines attach to the file or module.** `@ref` annotations in a file's leading doc-comment (e.g., `//!` in Rust, a module-level docstring in Python, or the first comment block before any imports or code) attach to the file or module as a whole.

3. **Otherwise, attach to the next non-comment line.** When a `@ref` doesn't fall into the above categories, it attaches to the next line of actual code.

A blank line between a `@ref` annotation and its target breaks the attachment — the annotation becomes free-floating (and should be flagged by validation tooling). Place annotations directly above the code they describe.

```rust
// Attaches to trap_focus_in_modal:
// @ref LLP 0074#focus-trapping — Focus trapping prevents tab-escape
pub fn trap_focus_in_modal(node: NodeId) -> Result<()> { ... }

// Both attach to flush_and_reconcile (contiguous block):
// @ref LLP 0003#opcode-ordering — OpCode ordering guarantees
// @ref LLP 0012#batching — Reconciler batching strategy
fn flush_and_reconcile(buffer: &SharedMemoryBuffer) -> Result<()> { ... }
```

```rust
//! @ref LLP 0074 — Accessibility subsystem design
//!
//! This module implements the accessibility semantics tree.
// ↑ Attaches to the module.
```

### 4. Section anchors in LLP documents

For this system to work, LLP documents need stable section targets. References can use either **heading slugs** (`#focus-trapping`) or **numbered sections** (`#3.1`). Both are supported; heading slugs are recommended as the default.

**Heading slugs** (`## Focus trapping`, referenced as `#focus-trapping`) are the preferred default for most LLP documents. They survive restructuring — you can reorder, insert, and merge sections freely without breaking any `@ref` in the codebase. This matters because LLP documents are living documents that evolve with the system. A restructured LLP that triggers a 40-file code change to update numbered references is real friction — exactly the kind that kills adoption.

**Numbered sections** (`## 3. Foo`, `### 3.1 Bar`, referenced as `#3` or `#3.1`) are compact in references and read naturally in hierarchically structured documents. They are appropriate for stable, spec-like documents where the structure is unlikely to change. The tradeoff is that inserting a section means renumbering and updating all references.

In practice, heading slugs work well for most LLP documents — RFCs, explainers, decisions, guides. Numbered sections suit specs and formal proposals where the structure is settled. Mixing within a single document is fine.

---

## LLP Extensions

Everything in this section is optional. A project can use LLP Core — documents, references, attachment semantics, and anchors — without adopting any extensions. Extensions are designed to be adopted independently.

### 5. Relation types

A `@ref` can optionally carry a **relation type** that qualifies the nature of the link between the code and the referenced document section.

Format:

```
@ref LLP NNNN#anchor [relation] — Optional gloss
```

Standard relation types:

| Relation | Meaning |
|----------|---------|
| `implements` | This code realizes the referenced design |
| `constrained-by` | This code is shaped by constraints documented in the referenced section |
| `tests` | This code tests the behavior described in the referenced section |
| `explains` | This code is the subject of the referenced explanation |

If no relation type is specified, the reference is a general association — the default and most common case. Relation types are most valuable for indexing and agent retrieval: an agent looking for "all code constrained by this requirement" gets a more precise answer than "all code referencing this section."

```typescript
// @ref LLP 0003#opcode-ordering [implements] — Creates before updates before deletes
export function flushOpCodeBuffer(buffer: SharedArrayBuffer): void {

// @ref LLP 0017#database-choice [constrained-by] — Must use PostgreSQL for transactional guarantees
def get_db_pool(config: DBConfig) -> ConnectionPool:

// @ref LLP 0051#tab-persistence [tests] — Tab state persists across navigation
describe('tab persistence', () => {
```

Most references work fine without relation types. Add them when the distinction matters — typically in codebases large enough for automated indexing and agent retrieval to be valuable.

### 6. Validation tooling (planned)

> **Note:** The tooling described in this section is planned but not yet implemented. The pipeline design is specified here to guide implementation; LLP Core works without it.

Following Norman Ramsey's noweb design principle — small composable filters rather than a monolithic tool — the validation system is a pipeline of four independent stages. Each stage has a clear input and output, and can be used standalone or chained.

| Stage | Command | Input | Output |
|-------|---------|-------|--------|
| **Extract** | `ref-check extract` | Source files | Structured list of all `@ref` annotations with file, line, target, gloss |
| **Resolve** | `ref-check resolve` | Extracted refs + document tree | Per-ref status: valid, broken, orphaned |
| **Index** | `ref-check index` | Extracted refs | Bidirectional map (code -> docs, docs -> code) as JSON |
| **Annotate** | `ref-check annotate <file>` | Source file + resolved refs + document tree | Annotated source view with referenced prose interleaved |

An agent needing to understand a file's design context calls only `extract`. The CI pipeline calls `extract | resolve`. A dev server chains `extract | index` to serve the bidirectional map. No stage depends on the output format of another — they communicate via a simple JSON intermediate representation.

This architecture means new capabilities (e.g., a "which LLP sections have no implementing code?" report) are just new pipeline stages, not modifications to a monolithic tool.

**Severity levels in CI:**

- **Broken references** (target document or section doesn't exist) are **errors**. A broken link is objectively wrong — the referenced rationale is unreachable.
- **Orphaned references** (code changed substantially near a reference) are **warnings**. Staleness is a judgment call — the reference might still be valid even if surrounding code changed.
- **Coverage gaps** are **informational only**. Never a gate.

### 7. Annotated source generation (planned)

> **Note:** This is planned tooling, not yet implemented.

The `annotate` pipeline stage generates read-only views of source files by pulling in referenced LLP text inline. These are never checked in, never edited — they're the "literate programming" output without the literate programming maintenance burden.

#### File-order view

The simplest mode: walk the source file top-to-bottom, inserting referenced prose above each annotated function:

```
┌─ LLP 0074#focus-trapping ──────────────────────────────┐
│ Modal dialogs must trap focus to prevent keyboard       │
│ users from tabbing into obscured content. On iOS,       │
│ VoiceOver handles this natively; on web, we must        │
│ manage it manually using a focus sentinel pattern.      │
└─────────────────────────────────────────────────────────┘
pub fn trap_focus_in_modal(node: NodeId) -> Result<()> {
    // implementation...
}
```

#### Rationale-order view

This is the most novel capability of LLP, drawn from Knuth and Ramsey's literate programming: present code in the order that makes sense for human understanding, not the order the compiler demands. The annotator groups functions by the LLP section they reference, even if they're scattered across the file:

```
━━━ LLP 0074#implicit-semantics ━━━━━━━━━━━━━━━━━━━━━━━━━

  Components carry default roles without developer opt-in.
  A <Pressable> is a button; a <TextInput> is a textbox.

  pub fn infer_role(node: &RenderNode) -> Option<SemanticRole> { ... }
  pub fn default_label(node: &RenderNode) -> Option<String> { ... }

━━━ LLP 0074#focus-management ━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Focus trapping, restoration, and custom focus order.

  pub fn trap_focus_in_modal(node: NodeId) -> Result<()> { ... }
  pub fn restore_focus(saved: FocusState) -> Result<()> { ... }
  pub fn set_focus_order(nodes: &[NodeId]) -> Result<()> { ... }

━━━ Unreferenced ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  fn internal_helper() { ... }
```

This is a generated *story* about the file, organized by design intent rather than language syntax. For a complex file implementing three different LLP sections, this view makes the structure legible in a way that scrolling through 500 lines of source never will.

Both views are available via the CLI (`ref-check annotate --order=file <file>` or `--order=rationale`) and optionally through a dev server integration.

### 8. Bidirectional index (planned)

> **Note:** This is planned tooling, not yet implemented.

The validation tooling parses every `@ref` in the codebase. As a byproduct, it can generate reverse indices for any referenced document set. The most important one is the LLP implementation map: for each LLP section, which source files reference it.

Example auto-generated output:

```markdown
## Implementation Map (auto-generated)

| Section | Referenced by |
|---------|--------------|
| #opcode-ordering | `src/protocol.rs:42`, `src/reconciler.ts:118` |
| #batching | `src/reconciler.ts:203` |
| #focus-trapping | `src/semantics.rs:87` |
```

This closes the navigation loop: code points to LLPs (via `@ref`), and LLPs point back to code (via the index). An agent implementing a new section can immediately see what already exists. A human reviewing an LLP can click through to every place it's been realized.

The index is always generated, never hand-edited. It updates on every `ref-check` run.

---

## Conventions

### When to add a reference

- **Do** reference when: the code implements a non-obvious design decision documented in an LLP; the code is part of a cross-cutting system; the approach would look wrong or overengineered without context; the code is in a domain where AI generates locally plausible code that is globally constrained (protocol handling, performance-critical paths, security boundaries, concurrency, data model migrations, billing/accounting logic).
- **Don't** reference when: the code is straightforward; the "why" is obvious from the "what"; a standard library API is being used in the standard way; the code is volatile and still being prototyped (references to rapidly changing code create maintenance drag — add them when the design stabilizes, not during exploratory iteration).
- **Rule of thumb:** if an agent might "simplify" this code in a way that would break the design intent, it needs a reference.

### Density

There is no minimum annotation density. References are added where they provide value, not as a checklist exercise. A well-designed module might have a couple of broad references at the top and a handful of specific references on non-obvious functions. A trivial utility file might have zero.

### Maintenance

When modifying code that carries a `@ref`:

1. Check whether the referenced section still describes what the code does.
2. If the code has diverged from the LLP, either update the LLP (if the design changed) or update the reference (if the code now implements a different section).
3. If the referenced section no longer applies, remove the reference.

LLP documents themselves follow the same principle: when the system evolves, update the document. If a document is no longer current but still useful, mark it `Superseded` or move it to `llp/tombstones/` with `**Status:** Tombstoned`. Don't leave stale guidance lying around unmarked.

### Agent policy

Agents should be instructed to add `@ref` annotations when they implement or modify code that realizes a documented, non-obvious design decision. That instruction should come with two guardrails:

1. Prefer specific references over broad, mechanical annotation.
2. Update or remove existing references when the code no longer matches them.

This keeps LLP self-reinforcing without turning it into a noisy checklist.

### Git workflow

LLP changes should follow the code they document:

- **Commit together.** When a code change implements a design documented in an LLP, the `@ref` annotation should land in the same commit as the code. When a design change requires updating an LLP document, the document update should land with the code change that motivated it.
- **Don't batch LLP updates separately.** A commit that only updates LLP documents with no corresponding code change is a signal that the documents drifted. Occasional cleanup commits are fine, but the norm should be co-evolution.
- **Merge conflicts in LLP documents are normal.** Resolve them the same way you'd resolve any markdown conflict — the content matters, not the formatting. If two branches modify the same LLP section, the merge is a chance to reconcile divergent thinking.

## End-to-end example

A minimal project using LLP:

```
my-project/
  llp/
    0000-my-project.md
    0001-auth-design.md
  src/
    auth.py
  CLAUDE.md
```

**`llp/0000-my-project.md`** — root explainer:

```markdown
# LLP 0000: My Project

**Type:** Explainer
**Status:** Active
**Systems:** Core
**Role:** Root
**Author:** J. Dev
**Date:** 2026-01-15

## Overview

My Project is a REST API for managing widgets.

## Architecture

Two subsystems: authentication (LLP 0001) and widget management.
```

**`llp/0001-auth-design.md`** — auth design decision:

```markdown
# LLP 0001: Authentication Design

**Type:** Decision
**Status:** Active
**Systems:** Auth
**Author:** J. Dev
**Date:** 2026-01-15

## Token strategy

Sessions use short-lived JWTs. Tokens are rotated on privilege
escalation to prevent session fixation.

## Database choice

Chose PostgreSQL over DynamoDB for transactional guarantees
across the auth/billing boundary.
```

**`src/auth.py`** — annotated source:

```python
# @ref LLP 0001 — Auth subsystem

# @ref LLP 0001#token-strategy [constrained-by] — Tokens rotate on privilege change
def rotate_on_escalation(session: Session) -> Session:
    ...

# @ref LLP 0001#database-choice [constrained-by] — PostgreSQL for txn guarantees
def get_db_pool(config: DBConfig) -> ConnectionPool:
    ...
```

**Expected `ref-check extract` output** (planned tooling):

```json
[
  {"file": "src/auth.py", "line": 1, "target": "LLP 0001", "section": null, "relation": null, "gloss": "Auth subsystem"},
  {"file": "src/auth.py", "line": 3, "target": "LLP 0001", "section": "token-strategy", "relation": "constrained-by", "gloss": "Tokens rotate on privilege change"},
  {"file": "src/auth.py", "line": 7, "target": "LLP 0001", "section": "database-choice", "relation": "constrained-by", "gloss": "PostgreSQL for txn guarantees"}
]
```

## Code examples

### Rust — module-level + specific references

```rust
//! Accessibility semantics tree.
//!
//! @ref LLP 0074 — Accessibility subsystem design
//! @ref LLP 0019#agent-convergence — Agent/accessibility convergence

use crate::tree::NodeId;

// @ref LLP 0074#focus-trapping — Focus trapping prevents tab-escape from modals
pub fn trap_focus_in_modal(node: NodeId) -> Result<()> {
    // ...
}

// @ref LLP 0074#implicit-semantics — Implicit semantics: Pressable -> button role
pub fn infer_role(node: &RenderNode) -> Option<SemanticRole> {
    // ...
}
```

### TypeScript — protocol boundary

```typescript
// @ref LLP 0003 — Binary Protocol
// @ref LLP 0012 — Reconciler

// @ref LLP 0003#opcode-ordering [implements] — Creates before updates before deletes
// @ref SPEC#binary-header — Binary header: 4-byte magic, 2-byte version, 2-byte count
export function flushOpCodeBuffer(buffer: SharedArrayBuffer): void {
  // ...
}
```

### Minimal — just a specific note

```typescript
// @ref LLP 0051#tab-persistence — Tab state persists across navigation to prevent data loss
function persistTabState(tabId: string, state: SerializableState): void {
  // ...
}
```

### Python

```python
# @ref LLP 0017#database-choice [constrained-by] — Chose PostgreSQL for transactional guarantees
# @ref LLP 0023#connection-pooling — Connection pooling strategy
def get_db_pool(config: DBConfig) -> ConnectionPool:
    ...
```

## Adopting LLP

### In an existing project

Converting an existing codebase to LLP is tractable if done incrementally:

1. **Write LLPs for your key design decisions.** Start with the subsystems that are most often misunderstood or where agents are most likely to make mistakes. These don't need to be exhaustive — even a short LLP with stable section targets is a useful reference target.

2. **Add `@ref` to module entry points.** For each major directory or module, add a top-level reference to its governing LLP. This is low-effort, high-value — it immediately gives agents subsystem orientation.

3. **Add specific references during normal development.** Don't do a bulk annotation pass. Adopt a "boy scout rule": when touching a file, add `@ref` annotations for non-obvious design decisions. This spreads the work naturally.

4. **Agent-assisted annotation sprints.** For complex subsystems, an agent can be tasked: "Read LLP 0074 and `src/semantics.rs`. Identify functions that implement specific sections and propose `@ref` annotations." The agent reads both the LLP and the code, proposes references, and a human reviews them.

See [LLP 0001](./0001-greenfield-setup.guide.md) for detailed greenfield setup steps and [LLP 0002](./0002-retrofitting-llp.guide.md) for a detailed retrofit guide.

### Adoption principles

These apply whether starting from scratch or retrofitting:

- **Don't over-annotate.** Early code is volatile. Wait until a module's design stabilizes before annotating heavily.
- **Boy scout rule.** When touching a file, add or update references for the code you're changing. This spreads annotation work naturally.
- **Start with module-level refs.** Broad references at the top of each major file provide immediate subsystem orientation for agents with minimal effort.
- **Don't write docs preemptively.** Write LLPs when you actually make decisions, while the reasoning is fresh.
- **Start flat.** Add subdirectories when you have enough documents to warrant grouping, not before.

### Quality gate

A reference is only worth adding if it's *accurate and specific*. A vague `@ref LLP 0074` on every file in a module is worse than no reference — it tells you nothing you couldn't infer from the directory name. The standard: every `@ref` should tell you something you wouldn't know from reading only the code and filename.

## Non-goals

- **Replacing comments.** Normal code comments remain appropriate for local observations that don't trace to an LLP. `@ref` is for connecting code to documented rationale, not for replacing all comments.
- **Mandating coverage.** This is not a "every function must have a reference" system. That would create noise and make the useful references harder to find.
- **Literate programming as authoring format.** We are explicitly not interleaving prose and code in source files. The annotated source view is a generated output, not an authoring format.
- **Replacing LLP documents.** The explanatory content lives in LLPs. The reference system only creates pointers.

## Open questions

1. **How should references interact with code that spans multiple files?** A cross-cutting concern touches many files. Should there be a way to declare "all files in this directory implement this LLP" without annotating each one? (A `.refs` manifest file, perhaps.)

2. **Should the rationale-order view be the default for annotated source, or should file-order be the default?** Rationale-order is more useful for understanding but less useful for locating specific code.

## Prior art

LLP draws on a long lineage of literate programming, design documentation, code traceability, and knowledge management systems. A comprehensive survey is in [LLP 0003](./0003-prior-art.research.md); this section highlights the most direct influences.

### Literate programming

- **Knuth's WEB/CWEB (1984):** The original — interleave prose and code, generate both documentation and executable. The insight that code should be presentable in explanation order directly inspires the rationale-order annotated view. But tight coupling makes refactoring painful.
- **Ramsey's noweb (1994):** Stripped WEB to two primitives and a pipeline architecture. Key finding: the value comes from cross-referencing and human-order presentation, not prettyprinting or macro expansion. The pipeline architecture and simplicity principle are directly inherited by LLP.
- **Docco / Marginalia:** Side-by-side code-and-comment viewers with zero adoption cost. Proved the most adopted literate-adjacent tools are the lightest.
- **Jupyter notebooks:** Proved massive demand for connecting explanation to code, but also demonstrated the problems of interleaving prose and code in one file. LLP explicitly rejects the interleaved model.
- **Eve language (2014–2018):** The strongest cautionary tale against literate programming as authoring format. Validates LLP's design of generating literate views on demand.

### Design documentation

- **Architecture Decision Records (Nygard, 2011):** Similar spirit but ADRs are immutable, lack machine-readable cross-references, and accumulate without consolidation.
- **Oxide Computer RFDs:** The closest precedent to LLP's living-document philosophy. LLP adds code-to-document linking that RFDs lack.
- **Diátaxis (Procida):** Validates LLP's typed document system — different types have different quality criteria.

### Code annotation and traceability

- **Requirements traceability (DO-178C, ASPICE):** Proves linking code to rationale has measurable engineering value. LLP avoids overhead by putting links in the code itself.
- **Kythe (Google):** Validates LLP's pipeline architecture and intermediate JSON format.
- **Swimm.io:** Proves automated staleness detection is tractable.

### AI-era context management

- **ETH Zurich study on AGENTS.md (2026):** Found agents spent 14–22% more tokens parsing verbose context files. Empirical case for LLP's "pointers, not prose" design.
- **Codified Context (2026):** Three-tier architecture (hot/warm/cold) maps directly to LLP: the `@ref` is hot, the referenced section is warm, the full document is cold.

### The key synthesis

The minimum viable literate programming system is just cross-references and human-order presentation. Source files carry pointers, not prose. The prose lives in LLP documents. Tooling keeps the pointers honest and can generate the "woven" literate view on demand. No prior system links code to design rationale at section granularity with validated, machine-readable references — this is the gap LLP fills.
