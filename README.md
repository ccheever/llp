# Linked Literate Programming (LLP)

A lightweight system for linking code to its design rationale through machine-readable references. Instead of embedding verbose explanations in source files, code carries thin pointers — standardized comments that reference specific sections of LLP documents. Agents and humans follow these links to retrieve deeper context on demand.

## The core idea

```rust
// @ref LLP 0042#3.1 — Session tokens must be rotated on privilege escalation
pub fn escalate_privilege(session: &Session) -> Result<Session> {
```

The `@ref` comment is a machine-readable pointer to a specific section of an LLP document. It tells both humans and AI agents exactly where to find the rationale for this code — without embedding a paragraph of explanation in the source file.

## Why

- **AI agents need context but comments are a poor vehicle.** They go stale, long ones waste tokens, and they can't express structure.
- **Design rationale exists but code doesn't point to it.** Projects accumulate knowledge in documents — but references from code are ad hoc and unvalidatable.
- **Humans reviewing AI-generated code need breadcrumbs.** A reference to a specific document section shifts review from "what is this doing?" to "does this satisfy the constraint?"

## LLP documents

LLP documents are numbered markdown files (`0000-slug.md`, `0001-slug.md`, ...) that capture the thinking behind a software system — the rationale, plans, constraints, and decisions that aren't encoded directly in code. They are:

- **Living documents.** They should be kept up to date as the system evolves, or deleted when no longer relevant. Git provides the history; the document always represents current thinking.
- **For humans and agents.** Both can read, write, and modify LLP documents. They serve as shared context between human and AI collaborators.
- **One unified system.** Proposals, plans, explainers, specs, guides, decision records — all are LLP documents, classified by metadata rather than scattered across directories.

### Numbering

Documents use zero-padded numbers: `LLP 0000` through `LLP 9999`. If a project exceeds 9999 documents, all are renumbered to 5 digits (`00000`-`99999`), and so on.

## Quick start

### 1. Write an LLP document

```markdown
# LLP 0003: Binary Protocol

**Type:** Spec
**Status:** Active
**Systems:** Protocol, Reconciler

## 2. Message format

### 2.1 OpCode ordering

Creates are always processed before updates, and updates before deletes...
```

### 2. Add references to your code

```typescript
// @ref LLP 0003#2.1 — OpCode ordering: creates before updates before deletes
export function flushMessageBuffer(buffer: SharedArrayBuffer): void {
  // ...
}
```

### 3. Validate references

```bash
ref-check extract src/ | ref-check resolve
```

## Adopting LLP in an existing project

You don't need to annotate everything at once:

1. **Write LLPs for your key design decisions.** Start with the subsystems most often misunderstood or where agents are most likely to make mistakes.
2. **Add `@ref` to module entry points.** For each major module, add a top-level reference to its governing LLP.
3. **Add references during normal development.** When touching a file, add references for non-obvious design decisions.
4. **Rule of thumb:** if an AI agent might "simplify" this code in a way that would break the design intent, it needs a reference.

## Starting a new project with LLP

1. **Write LLP documents alongside code.** Even lightweight docs with numbered sections provide valuable reference targets.
2. **Reference as you go.** When implementing a design decision, add the `@ref` immediately — this is when the connection is freshest.
3. **Keep references specific.** `@ref LLP 0005#3.2` is useful. `@ref LLP 0005` without a section is less so.

## What's in this repo

- **[LLP 0000: Linked Literate Programming](./0000-linked-literate-programming.md)** — The full specification.
- **Tooling** (planned) — A pipeline of composable tools for extracting, validating, and indexing `@ref` annotations.

## Reference syntax at a glance

| Element | Format | Example |
|---------|--------|---------|
| LLP reference | `@ref LLP NNNN#S — gloss` | `@ref LLP 0005#3.1 — Why we batch writes` |
| LLP (broad) | `@ref LLP NNNN` | `@ref LLP 0012 — Auth subsystem` |
| Path reference | `@ref path/to/doc.md#S` | `@ref docs/vendor/spec.md#4 — Token format` |
| Doc bridge | `@doc path#S — gloss` | `@doc guides/auth.md#tokens — Public token docs` |

## Prior art

LLP draws on Knuth's literate programming, Ramsey's noweb (composable pipeline, minimal syntax), Architecture Decision Records, and doc-comment systems like Rust's `///` and JSDoc's `@see`. The key insight from Ramsey: the minimum viable literate programming system is just cross-references and human-order presentation. See the [full specification](./0000-linked-literate-programming.md#prior-art) for the complete discussion.

## License

MIT
