# LLP 0002: Retrofitting LLP into an Existing Codebase

**Type:** Guide
**Status:** Draft
**Systems:** LLP
**Author:** Charlie Cheever / Claude
**Date:** 2026-04-01

## Summary

This document describes the process of adopting LLP in a substantial existing repository — one with meaningful history, accumulated design decisions, and code that predates any formal rationale documentation. The core challenge is extracting implicit knowledge from the codebase and making it explicit in LLP documents, then linking the two together.

This is a bigger undertaking than greenfield setup. It involves reading and understanding the existing codebase, identifying the design decisions embedded in it, writing documents that capture those decisions, and annotating code with references. Agents are essential to making this tractable at scale.

## 1. Understand the codebase first

Before writing any LLP documents, develop a map of the system. This means reading:

- **The directory structure.** What are the major subsystems? How is the code organized?
- **Entry points.** Where does execution start? What are the public APIs?
- **The dependency graph.** What depends on what? Where are the boundaries?
- **Git history.** What has changed recently? What areas are actively developed? What areas are stable? `git log --stat` and `git shortlog -sn` reveal where activity concentrates.
- **Existing documentation.** READMEs, wikis, doc comments, ADRs, design docs — anything that already captures rationale. This is source material for LLP documents, not something to discard.

An agent can do much of this work. A prompt like "Read the codebase and produce a high-level architecture summary identifying major subsystems, their responsibilities, and how they interact" is a reasonable starting point. The output becomes the seed for LLP 0000.

## 2. Identify subsystems and draw boundaries

From the codebase reading, identify the 5-15 major subsystems or domains. These become the natural units for LLP documents. Common patterns:

- Each top-level directory or package is a subsystem
- A subsystem boundary is where the abstraction changes (e.g., "protocol parsing" vs. "business logic" vs. "persistence")
- Cross-cutting concerns (auth, logging, error handling) are their own subsystems

Don't aim for a perfect decomposition. The goal is a working map that can be refined as understanding deepens.

## 3. Write the root document (LLP 0000)

Write an overview document covering:

- What the project does
- The major subsystems and how they relate
- Key architectural constraints (why is it structured this way?)
- Any global invariants that aren't obvious from the code

This document is the entry point for any agent or human encountering the codebase for the first time. It should be written to minimize the "cold start" problem — after reading LLP 0000, a reader should know where to look for anything.

LLP 0000 is typically an **Explainer** overview — the entry point for the corpus. It should carry `**Role:** Root`.

## 4. Write LLPs for key subsystems

For each major subsystem, write an LLP document covering:

- **What it does** and why it exists as a separate concern
- **Key design decisions** — the non-obvious choices and their rationale
- **Invariants** — what must always be true for this subsystem to work correctly
- **Boundaries** — what this subsystem owns and what it delegates

Prioritize subsystems that are:

- **Frequently misunderstood.** Where do bugs cluster? Where do new contributors (human or agent) make mistakes?
- **Non-obvious.** Where would reading the code alone lead to wrong conclusions?
- **Cross-cutting.** Where does behavior depend on coordinated assumptions across multiple files?
- **Actively developed.** Where is current work happening? Those areas benefit most from documented rationale immediately.

### Using agents for document generation

An agent can draft LLP documents by reading source code, but the drafts need human review. The agent sees the "what" clearly but may infer the "why" incorrectly — it can describe what the code does, but the actual rationale may involve constraints the code doesn't express (performance requirements, legal constraints, compatibility commitments, lessons from past incidents).

A productive workflow:

1. Agent reads the subsystem code and produces a draft LLP
2. Human reviews, corrects the rationale, and adds context the agent couldn't infer
3. Agent refines the document based on human feedback

This is faster than writing from scratch and catches more than either human or agent alone.

## 5. Annotate code with @ref references

Once LLP documents exist with stable section targets, annotate the code that implements them. This is the step that closes the loop — without references, the documents are just prose sitting in a directory.

Those section targets can be either heading slugs (`#token-rotation`) or numbered sections (`#3.2`). Heading slugs are preferred for most documents because they survive restructuring — see [LLP 0000#section-anchors-in-llp-documents](./0000-linked-literate-programming.md#section-anchors-in-llp-documents).

### Annotation strategy

**Don't annotate everything at once.** A bulk annotation pass is tempting but produces low-quality references. Instead, use a layered approach:

#### Layer 1: Module-level references (do first)

Add broad references at the top of each major file or module pointing to its governing LLP:

```python
# @ref LLP 0005 — User authentication subsystem
# @ref LLP 0012 — Session management

from .tokens import rotate_token
```

This is high-value, low-effort. It immediately gives agents subsystem orientation when they open any file.

#### Layer 2: Key function references (do next)

Identify functions that implement specific, non-obvious design decisions and add section-level references:

```python
# @ref LLP 0005#token-rotation — Token rotation on privilege change prevents session fixation
def rotate_on_escalation(session: Session) -> Session:
    ...
```

Focus on functions where the "why" isn't obvious from the "what." An agent encountering this code should be able to follow the reference to understand the security rationale.

#### Layer 3: Ongoing maintenance (do continuously)

After the initial annotation pass, adopt the boy scout rule: when touching a file, add or update references for the code you're changing. This spreads the remaining annotation work naturally across normal development.

### Agent-assisted annotation

Agents can propose annotations given an LLP document and a source file:

> "Read LLP 0005 and `src/auth/tokens.py`. Identify functions that implement specific sections of the LLP and propose `@ref` annotations. Only propose references where the connection is specific and non-obvious."

The "specific and non-obvious" instruction is important. Without it, agents tend to annotate mechanically — putting `@ref LLP 0005` on every function in the auth module, which adds noise without value.

Review agent-proposed annotations for accuracy. The agent may misidentify which section a function implements, or propose a reference to a section that describes intent the function doesn't actually satisfy.

## 6. Migrate existing documentation

If the project has existing design documents, ADRs, RFCs, or wiki pages:

- **Convert valuable ones to LLPs.** Assign them numbers, add the standard metadata header, and ensure they have stable section targets, either numbered sections or heading slugs. The content may need updating to reflect current state — active LLPs represent current thinking; historical context should be marked explicitly with statuses like `Superseded` or `Tombstoned`.
- **Delete or archive stale ones.** A design doc from 2019 that no longer matches the code is harmful. Either update it to reflect reality or remove it. Git has the history if anyone needs the original.
- **Link, don't duplicate.** If an external document (a spec, a vendor doc) is authoritative, reference it with `@ref path/to/doc.md#section` rather than copying its content into an LLP.

## 7. Configure agent instructions

Add an `AGENTS.md` (or `CLAUDE.md`) that tells agents:

- LLP documents exist and where to find them
- To read relevant LLPs before modifying subsystems they cover
- To add `@ref` annotations when implementing documented decisions
- To update LLP documents when the design they describe changes
- To flag when code contradicts its referenced LLP section

## 8. Phased rollout

For large codebases, adopt LLP incrementally rather than all at once:

### Phase 1: Foundation (1-2 sessions)
- Read the codebase, write LLP 0000 (overview)
- Write LLPs for 2-3 highest-priority subsystems
- Add module-level `@ref` annotations for those subsystems
- Set up `AGENTS.md`

### Phase 2: Breadth (ongoing over 1-2 weeks)
- Write LLPs for remaining major subsystems
- Add module-level annotations project-wide
- Add key function annotations for the areas with most active development

### Phase 3: Depth (continuous)
- Boy scout rule: annotate as you touch files
- Agent-assisted annotation sprints for complex subsystems
- Refine and update documents as understanding deepens

### Phase 4: Tooling (when ready)
- Add `ref-check` validation to CI
- Generate bidirectional index
- Integrate annotated source views into dev workflow

## 9. Common pitfalls

See [LLP 0000's adoption principles](./0000-linked-literate-programming.md#adoption-principles) for general guidance. The pitfalls specific to retrofitting:

- **Treating it as a one-time project.** The initial setup is a sprint, but LLP is a practice. Documents and references need ongoing maintenance. If you set it up and walk away, it decays like any other documentation.
- **Agent-generated documents without human review.** Agents are good at describing what code does but unreliable at inferring why. Every agent-drafted LLP needs a human pass for rationale accuracy.
- **Trying to document the entire history.** Active LLPs represent current thinking. You don't need to reconstruct every historical decision — only the ones that still affect the code today.
