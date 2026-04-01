# LLP 0000: Linked Literate Programming

**Type:** RFC
**Status:** Draft
**Systems:** LLP
**Role:** Root
**Author:** Charlie Cheever / Claude
**Date:** 2026-04-01

## Summary

This document specifies a lightweight system for linking code to its design rationale through machine-readable references to document sections. Instead of embedding verbose explanations in source files, code carries thin pointers — standardized comments that reference specific sections of LLP documents. Agents and humans follow these links to retrieve deeper context on demand.

The system introduces five concepts:

1. **LLP documents** — numbered, living design documents that capture the thinking behind a software system, consumable and modifiable by both humans and agents
2. **A reference syntax** — a standard comment format (`@ref`) pointing from code to LLP document sections
3. **Validation tooling** — a pipeline of composable tools that extract references, validate targets, generate indices, and produce annotated views
4. **A bidirectional index** — auto-generated reverse maps showing which code implements each document section
5. **Annotated source generation** — on-demand "literate programming" views that interleave referenced prose with code, in either file order or rationale order

The goal is to make codebases self-documenting without embedding prose in source files, to give agents efficient access to design rationale at the right level of detail, to keep the link between design documents and implementation honest over time, and to create a navigable chain from code through design rationale to user-facing documentation.

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

### Humans reading AI-generated code need breadcrumbs

As agents write more code, humans reviewing that code need efficient ways to understand *why* a particular approach was taken. AI-generated code is characteristically "locally plausible but globally constrained" — the mechanism looks correct in isolation, but the real question is whether it satisfies cross-cutting invariants that aren't visible in the immediate context. A reference to a specific document section shifts code review from "what on earth is this doing?" to "does this satisfy the intended constraint?" — a far more productive question.

## Design

### 1. LLP documents

LLP documents are the prose side of a software system — they capture the thinking, rationale, plans, constraints, and decisions that aren't encoded directly in code. They are numbered markdown files that live alongside the codebase.

#### Living documents

LLP documents are **living documents**, not immutable records. They should be kept up to date as the system evolves, or deleted when no longer relevant. Git provides the history — the document itself always represents current thinking.

This is a deliberate departure from systems like ADRs where documents are append-only. A stale design document that no longer matches the code is actively harmful — it misleads agents and humans alike. Better to update it or delete it.

#### For humans and agents

LLP documents are designed to be read, written, and modified by both humans and AI agents. They serve as shared context between human and AI collaborators. An agent implementing a feature reads the relevant LLP to understand the design intent. A human reviewing agent-generated code follows `@ref` links back to the LLP to verify the agent understood the constraints.

#### Numbering

LLP documents are identified by zero-padded numbers: `LLP 0000` through `LLP 9999`. Filenames follow the pattern `NNNN-slug.md` (e.g., `0042-authentication.md`).

If a project exceeds 9999 documents, all existing documents are renumbered to 5 digits (`00000`-`99999`). If 99999 is exceeded, expand to 6 digits, and so on. The number width is always uniform across the project.

#### Filesystem organization

LLP documents live in an `llps/` directory (or whatever a project chooses). They can be flat or grouped into subdirectories for human convenience:

```
llps/
  0001-project-overview.md
  protocol/
    0003-binary-protocol.md
    0015-message-compression.md
    0028-header-format.md
  auth/
    0017-session-management.md
    0042-token-rotation.md
```

Directories are not numbered — they're just organizational buckets. The LLP number is the identity; the directory is just storage. `@ref LLP 0003#2.1` doesn't encode the directory path, so documents can be reorganized freely without breaking references.

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

The root document is usually an **Explainer** that orients readers to the project or subsystem. In projects where the system itself is still being designed, the root document may also be the governing **RFC**. The important part is that LLP 0000 is the entry point and carries `**Role:** Root`.

#### Metadata header

Every LLP begins with a small metadata header directly below the title. LLP uses a plain markdown metadata block, not YAML frontmatter. This keeps the format easy to read in any markdown renderer and easy for lightweight tooling to parse line-by-line.

Required fields:

- `**Type:**` — the document kind
- `**Status:**` — the document lifecycle state
- `**Systems:**` — one or more systems, domains, or subsystems this LLP applies to
- `**Author:**` — the primary author or editors
- `**Date:**` — creation date in `YYYY-MM-DD`

Optional fields:

- `**Role:** Root` — marks an overview document that serves as the entry point for a project or subsystem
- `**Revised:** YYYY-MM-DD` — last substantive revision date
- `**Related:** LLP 0007, docs/foo.md` — nearby documents worth reading with this one

#### Types

LLP documents can take many forms. Rather than splitting them across directories (rfcs/, plans/, docs/), they all live in one unified system, classified by metadata:

```markdown
# LLP NNNN: Title

**Type:** RFC | Plan | Explainer | Principle | Guide | Issue
**Status:** Draft | Active | Superseded | Deleted
**Systems:** Auth, Protocol, Reconciler, ...
**Author:** ...
**Date:** ...
```

The following are the **standard types** — a core set that covers the most common kinds of design documents. Projects don't need to use all of them, and can define their own types beyond this list. Over time, this set may evolve as real-world usage patterns emerge.

| Type | What it is |
|------|-----------|
| **RFC** | A design proposal — the "what" and "why" of an approach, open for discussion |
| **Plan** | Execution or implementation steps — the "how" and "when" |
| **Explainer** | Teaching material — helps someone understand a subsystem or concept |
| **Principle** | Core beliefs and values that guide decisions — the "always" and "never" |
| **Guide** | Usage documentation — how to use, configure, or work with something |
| **Issue** | A bug, problem, or investigation — what's wrong and what we know |

A project might also define its own types — for example, **Spec** (normative requirements the code must follow), **Decision** (a specific choice and its rationale, like an ADR), **Postmortem** (an incident retrospective), or anything else that fits the project's needs. The standard types are conventions, not constraints.

This replaces the traditional pattern of scattering knowledge across `rfcs/`, `docs/plans/`, `docs/`, `adrs/`, etc. The metadata is the taxonomy; the directory is just storage. An agent working on protocol code can query "show me all LLPs where Systems includes 'Protocol'" and get RFCs, plans, and explainers in one result.

### 2. Reference syntax

Code references use the following format:

```
@ref LLP NNNN#SECTION — Optional short gloss
```

Where:
- `LLP NNNN` is the document number (zero-padded to match the project's current width)
- `#SECTION` is a section number (e.g., `#3`, `#3.2`, `#3.2.1`) or a `#heading-slug` anchor
- The `#` delimiter follows the existing convention for markdown heading anchors and URL fragments
- The gloss after the em dash is optional, <=80 characters, and summarizes what the section explains

In context:

```rust
// @ref LLP 0074#5.1 — Focus trapping prevents tab-escape from modals
pub fn trap_focus_in_modal(node: NodeId) -> Result<()> {
```

```typescript
// @ref LLP 0003#2.1 — OpCode ordering guarantees
function flushOpCodeBuffer(buffer: SharedArrayBuffer): void {
```

The `@ref` prefix makes references grep-able and distinguishable from casual mentions in prose comments.

#### Multiple references

A code region can carry multiple references:

```rust
// @ref LLP 0003#2.1 — OpCode ordering guarantees
// @ref LLP 0012#3 — Reconciler batching strategy
fn flush_and_reconcile(buffer: &SharedMemoryBuffer) -> Result<()> {
```

#### Referencing non-LLP documents

The system can also reference documents that aren't part of the LLP numbering scheme — external specs, files by path, or project-defined shorthands:

```rust
// @ref docs/vendor/openid-spec.md#4.3 — Token validation requirements
// @ref SPEC#2.1 — Binary header layout
```

Shorthand labels like `SPEC` can be defined in a project-level configuration file that maps them to actual file paths.

#### User-facing documentation: `@doc` references

A parallel reference type connects code to user-facing documentation:

```typescript
// @ref LLP 0051#3 — Tab state persists across navigation
// @doc guides/navigation.md#tab-persistence — User-facing explanation of tab behavior
export function persistTabState(tabId: string, state: SerializableState): void {
```

`@doc` references work identically to `@ref` but target public-facing documents. The validation tooling treats them the same way. This creates a navigable chain: **code** <-> **LLP documents** <-> **user-facing docs**.

### 3. Section anchors in LLP documents

For this system to work, LLP documents need stable section targets. References can use either **numbered sections** (`#3.1`) or **heading slugs** (`#focus-trapping`). Both are first-class; projects and individual documents can use whichever fits.

**Numbered sections** (`## 3. Foo`, `### 3.1 Bar`) are compact in references and read naturally in hierarchically structured documents like specs and proposals. The tradeoff is stability: inserting a section between 3.1 and 3.2 means renumbering (or resorting to 3.1.1). The validation tooling catches broken references when this happens, so it's a mechanical fix rather than a silent breakage.

**Heading slugs** (`## Focus trapping`, referenced as `#focus-trapping`) survive restructuring — you can reorder sections freely without breaking references. The tradeoff is verbosity: `@ref LLP 0051#persistent-tab-state-across-navigation` is painful in a code comment. Best for documents that are more fluid, like explainers and guides.

In practice, numbered sections are conventional for LLPs that have a natural hierarchy, and heading slugs work well for everything else. Mixing within a single document is fine.

### 4. Validation tooling (pipeline architecture)

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

### 5. Annotated source generation

The `annotate` pipeline stage generates read-only views of source files by pulling in referenced LLP text inline. These are never checked in, never edited — they're the "literate programming" output without the literate programming maintenance burden.

#### File-order view

The simplest mode: walk the source file top-to-bottom, inserting referenced prose above each annotated function:

```
┌─ LLP 0074#5.1: Focus trapping ─────────────────────────┐
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

The deeper idea, drawn from Knuth and Ramsey's literate programming: present code in the order that makes sense for human understanding, not the order the compiler demands. The annotator groups functions by the LLP section they reference, even if they're scattered across the file:

```
━━━ LLP 0074#3: Implicit semantics ━━━━━━━━━━━━━━━━━━━━━━

  Components carry default roles without developer opt-in.
  A <Pressable> is a button; a <TextInput> is a textbox.

  pub fn infer_role(node: &RenderNode) -> Option<SemanticRole> { ... }
  pub fn default_label(node: &RenderNode) -> Option<String> { ... }

━━━ LLP 0074#5: Focus management ━━━━━━━━━━━━━━━━━━━━━━━━

  Focus trapping, restoration, and custom focus order.

  pub fn trap_focus_in_modal(node: NodeId) -> Result<()> { ... }
  pub fn restore_focus(saved: FocusState) -> Result<()> { ... }
  pub fn set_focus_order(nodes: &[NodeId]) -> Result<()> { ... }

━━━ Unreferenced ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  fn internal_helper() { ... }
```

This is a generated *story* about the file, organized by design intent rather than language syntax. For a complex file implementing three different LLP sections, this view makes the structure legible in a way that scrolling through 500 lines of source never will.

Both views are available via the CLI (`ref-check annotate --order=file <file>` or `--order=rationale`) and optionally through a dev server integration.

### 6. Bidirectional index

The validation tooling already parses every `@ref` in the codebase. As a byproduct, it generates a **reverse index**: for each LLP section, which source files reference it.

Example auto-generated output:

```markdown
## Implementation Map (auto-generated)

| Section | Referenced by |
|---------|--------------|
| #2.1 OpCode ordering | `src/protocol.rs:42`, `src/reconciler.ts:118` |
| #3 Reconciler batching | `src/reconciler.ts:203` |
| #5.1 Focus trapping | `src/semantics.rs:87` |
```

This closes the navigation loop: code points to LLPs (via `@ref`), and LLPs point back to code (via the index). An agent implementing a new section can immediately see what already exists. A human reviewing an LLP can click through to every place it's been realized.

The index is always generated, never hand-edited. It updates on every `ref-check` run.

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

The validation tooling assists with this but does not enforce it.

LLP documents themselves follow the same principle: when the system evolves, update the document. Don't leave stale design docs lying around — they actively mislead.

### Agent policy

Agents should be instructed to add `@ref` annotations when they implement or modify code that realizes a documented, non-obvious design decision. That instruction should come with two guardrails:

1. Prefer specific references over broad, mechanical annotation.
2. Update or remove existing references when the code no longer matches them.

This keeps LLP self-reinforcing without turning it into a noisy checklist.

## Examples

### Rust — module-level + specific references

```rust
//! Accessibility semantics tree.
//!
//! @ref LLP 0074 — Accessibility subsystem design
//! @ref LLP 0019#6 — Agent/accessibility convergence

use crate::tree::NodeId;

// @ref LLP 0074#5.1 — Focus trapping prevents tab-escape from modals
pub fn trap_focus_in_modal(node: NodeId) -> Result<()> {
    // ...
}

// @ref LLP 0074#3.2 — Implicit semantics: Pressable -> button role
pub fn infer_role(node: &RenderNode) -> Option<SemanticRole> {
    // ...
}
```

### TypeScript — protocol boundary

```typescript
// @ref LLP 0003 — Binary Protocol
// @ref LLP 0012 — Reconciler

// @ref LLP 0003#2.1 — OpCode ordering: creates before updates before deletes
// @ref SPEC#4.3 — Binary header: 4-byte magic, 2-byte version, 2-byte count
export function flushOpCodeBuffer(buffer: SharedArrayBuffer): void {
  // ...
}
```

### Minimal — just a specific note

```typescript
// @ref LLP 0051#3 — Tab state persists across navigation to prevent data loss
function persistTabState(tabId: string, state: SerializableState): void {
  // ...
}
```

### Python

```python
# @ref LLP 0017#4 — Chose PostgreSQL over DynamoDB for transactional guarantees
# @ref LLP 0023#2.3 — Connection pooling strategy
def get_db_pool(config: DBConfig) -> ConnectionPool:
    ...
```

## Adopting LLP

### In an existing project

Converting an existing codebase to LLP is tractable if done incrementally.

1. **Write LLPs for your key design decisions.** Start with the subsystems that are most often misunderstood or where agents are most likely to make mistakes. These don't need to be exhaustive — even a short LLP with numbered sections is a useful reference target.

2. **Add `@ref` to module entry points.** For each major directory or module, add a top-level reference to its governing LLP. This is low-effort, high-value — it immediately gives agents subsystem orientation.

3. **Add specific references during normal development.** Don't do a bulk annotation pass. Adopt a "boy scout rule": when touching a file, add `@ref` annotations for non-obvious design decisions. This spreads the work naturally.

4. **Agent-assisted annotation sprints.** For complex subsystems, an agent can be tasked: "Read LLP 0074 and `src/semantics.rs`. Identify functions that implement specific sections and propose `@ref` annotations." The agent reads both the LLP and the code, proposes references, and a human reviews them.

### In a new project

1. **Write LLPs alongside code.** Even lightweight documents with numbered sections provide valuable reference targets.
2. **Reference as you implement.** When writing code that implements a design decision, add the `@ref` immediately — this is when the connection is freshest.
3. **Instruct your agents.** Configure `CLAUDE.md` (or equivalent) to tell AI agents to add `@ref` annotations when implementing LLP-documented decisions.

### Quality gate

A reference is only worth adding if it's *accurate and specific*. A vague `@ref LLP 0074` on every file in a module is worse than no reference — it tells you nothing you couldn't infer from the directory name. The standard: every `@ref` should tell you something you wouldn't know from reading only the code and filename.

## Non-goals

- **Replacing comments.** Normal code comments remain appropriate for local observations that don't trace to an LLP. `@ref` is for connecting code to documented rationale, not for replacing all comments.
- **Mandating coverage.** This is not a "every function must have a reference" system. That would create noise and make the useful references harder to find.
- **Literate programming as authoring format.** We are explicitly not interleaving prose and code in source files. The annotated source view is a generated output, not an authoring format.
- **Replacing LLP documents.** The explanatory content lives in LLPs. The reference system only creates pointers.

## Open questions

1. **Should the checker run in CI from day one, or start as a local-only tool?** CI integration adds visibility but might create noise during the initial adoption period when few references exist.

2. **Is `@ref` the right prefix, or would something shorter (`@see`) or longer (`@llp-ref`) be better?** `@ref` is concise and broadly applicable. `@see` collides with JSDoc.

3. **Should the rationale-order view be the default for annotated source, or should file-order be the default?** Rationale-order is more useful for understanding but less useful for locating specific code.

4. **How should references interact with code that spans multiple files?** A cross-cutting concern touches many files. Should there be a way to declare "all files in this directory implement this LLP" without annotating each one? (A `.refs` manifest file, perhaps.)

5. **Should references carry metadata about _why_ they exist?** For example, distinguishing "this code maintains a documented invariant" from "this code implements a specific decision" from "this code is constrained by a documented requirement." See the discussion in the next section.

## Deferred: altitude tags

An earlier draft included "altitude tags" (`@system`, `@tactical`) to classify how much context an agent should pull in. This was deferred in favor of keeping the syntax minimal — the presence or absence of a section number already carries a similar signal. May be revisited if experience shows that agents need stronger hints about context scope.

## Prior art

- **Knuth's Literate Programming (WEB/CWEB):** The original — interleave prose and code, generate both documentation and executable. Beautiful but high-maintenance; the tight coupling between prose and code makes refactoring painful. The core insight that code should be presentable in explanation order, not compiler order, directly inspires the rationale-order annotated view.
- **Ramsey's noweb:** Norman Ramsey's [simplified literate programming tool](https://www.linuxjournal.com/article/2188) (1994) stripped WEB down to two primitives (named chunks and references) and a pipeline architecture of composable filters. His [IEEE Software paper](https://mirror.gutenberg-asso.fr/tex.loria.fr/litte/ieee.pdf) "Literate Programming Can Be Simple and Extensible" demonstrated that most of WEB's complexity was inessential — the value came from cross-referencing and human-order presentation, not from prettyprinting or macro expansion. The pipeline architecture and the principle that the system must be simple enough that people actually use it are directly drawn from Ramsey's work.
- **Docco / Literate CoffeeScript:** Side-by-side code and comments. Lighter than Knuth but still embeds all prose in source files.
- **Rust `//!` module docs and `///` doc comments:** Good for API documentation but not for linking to external design rationale.
- **Architecture Decision Records (ADRs):** Similar spirit — document decisions, reference from code. But ADRs are typically immutable and standalone, lacking machine-readable cross-references and becoming stale over time. LLP documents are living by contrast.
- **`@see` in JSDoc/Javadoc:** Points to related code, not to design documents. No section granularity.

This system takes the "thin reference" approach from Ramsey's insight: the minimum viable literate programming system is just cross-references and human-order presentation. Source files carry pointers, not prose. The prose lives in LLP documents. The tooling keeps the pointers honest and can generate the "woven" literate view on demand.
