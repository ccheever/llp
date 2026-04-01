# LLP 0005: RFC Authoring and Review Process

**Type:** Guide
**Status:** Draft
**Systems:** LLP
**Author:** Charlie Cheever / Claude
**Date:** 2026-04-01
**Related:** LLP 0000, LLP 0004

## Summary

This document defines the authoring workflow, multi-model review process, and expanded lifecycle for LLP documents of type **RFC**. The review process is also recommended for **Spec** and **Plan** documents — any LLP that proposes a design others will implement.

## Motivation

An RFC's purpose is to capture a design decision *before* implementation, so that flaws surface cheaply in prose rather than expensively in code. But a single author (human or AI) has blind spots. The Exact project demonstrated that requiring review from multiple AI model families — not just the one that wrote the draft — catches substantially more issues than single-reviewer workflows. Each model family has different strengths: one catches practical concerns the other glosses over; the author catches things neither model knows about (business context, user needs, taste). The combination produces better designs than any single reviewer.

## Lifecycle for RFCs

RFC-type LLPs use an expanded set of statuses beyond the standard four:

| Status | Meaning |
|--------|---------|
| `Draft` | Under active discussion. May change substantially. |
| `Review` | Draft is complete and undergoing multi-model review. |
| `Accepted` | Approved for implementation. Design is stable. |
| `Active` | Fully implemented in the codebase. Equivalent to "Implemented." |
| `Superseded` | Replaced by a newer LLP. Link to the replacement. |
| `Tombstoned` | Historical context, no longer current guidance. |

Typical progression: `Draft` -> `Review` -> `Accepted` -> `Active`.

Not every RFC reaches `Accepted`. Some are `Tombstoned` when the idea is rejected or deprioritized. That's fine — briefly note why in the document.

Rules:
- New RFCs start as `Draft`.
- A draft moves to `Review` when it's ready for multi-model review. Small RFCs can skip `Review` and go directly from `Draft` to `Accepted`.
- A draft or review becomes `Accepted` once the review loop is complete and the author is satisfied.
- An accepted RFC becomes `Active` when the implementation is done and merged.
- If a later RFC replaces this one, set status to `Superseded` and add: `**Superseded by:** LLP NNNN`.
- Once accepted, an RFC should not have its design section materially changed. If the design evolves during implementation, write a new LLP or add a dated addendum at the end (e.g., `## Addendum (2026-04-15): ...`).
- Update `**Revised:**` when making substantive changes to a draft.

`Review` and `Accepted` are available to any LLP type but are most natural for RFCs, Specs, and Plans — documents that propose something to be implemented.

## Authoring workflow

RFCs are written collaboratively with AI. The typical flow:

### 1. Discuss

Hash out the idea interactively with Claude. Cover motivation, constraints, trade-offs, and rough design. The goal is to clarify thinking, not to produce polished prose.

### 2. Draft

Claude writes the RFC based on the discussion. The author reviews and edits. A good RFC covers:

1. **Summary** — One paragraph. What is this RFC proposing?
2. **Motivation** — Why is this needed? What problem does it solve?
3. **Design** — The proposed solution. Be specific enough that someone (or an agent) could implement it.
4. **Alternatives considered** — What else was considered and why was it rejected?
5. **Implementation plan** — Phases, ordering, dependencies.
6. **Open questions** — Unresolved issues that need answers before or during implementation.

Not every section is required. A small, focused RFC might just have Summary, Motivation, and Design.

### 3. Review

The draft must be reviewed by at least two AI models in addition to the author:

**(a) The author.** Read it critically. Does it make sense? Are there gaps?

**(b) A non-Claude model** (GPT, Gemini, or whatever the current best alternative is). Paste the RFC and ask for a critical review. Look for blind spots, unstated assumptions, and alternative approaches the draft doesn't consider.

**(c) A Claude model** in a fresh session (not the one that wrote the draft). Same goals — different context, different blind spots.

The principle: get critical review from at least two model families. As the frontier shifts, update which models you use — the point is cognitive diversity, not specific model names.

**Standard review prompt.** When requesting a model review, use this prompt (or a close variant):

> What do you think of this proposal? Is it a good idea? Do we have a good plan here? How would you change it to make it better? What would you add or take away or change? Is anything definitely or possibly wrongheaded here? Do you have any novel ideas that you think might make this way better even if they are a bit non-standard? What are the key open questions we need to answer to refine this?

### 4. Iterate

Address feedback from all reviewers. The author decides which feedback to incorporate and when the RFC is good enough. Model reviewers are required *inputs*, not *approvers* — the author is the final decision-maker.

### 5. Accept

The author updates the status to `Accepted`. Currently Charlie is the sole maintainer and accepts all RFCs. As contributors grow, acceptance authority may be delegated.

## Review artifacts

Model review responses should be saved alongside the project for reference. Name them after the LLP and the reviewing model:

```
llp/reviews/
  0042-widget-api.gpt.md
  0042-widget-api.claude.md
  0042-widget-api.gemini.md
```

These are reference material, not LLP documents — they don't get numbers or metadata headers. They exist so that future readers can see what concerns were raised and how they were addressed.

## When to skip formal review

Not every RFC needs the full multi-model review loop. Skip it when:

- The RFC is small and focused (a single, well-bounded decision)
- The design space is well-understood and there are no contentious trade-offs
- The RFC codifies an existing, proven approach rather than proposing something new

Use judgment. The review loop exists to catch blind spots on complex designs, not to bureaucratize obvious choices.

## Implementation

Once an RFC is accepted:

- The implementer (human or AI) should reference the LLP number in commit messages and PR descriptions (e.g., "Implements LLP 0042").
- Code that implements the RFC should carry `@ref` annotations pointing to specific sections, per the standard LLP conventions.
- When the implementation is complete and merged, update the RFC status to `Active`.

## Large RFCs

When an RFC covers a complex system with multiple independently reviewable sub-topics, it can use a directory structure:

```
llp/
  NNNN-slug.md              <- symlink to slug/README.md
  slug/                     <- directory named after the slug
    README.md               <- umbrella RFC (architecture, motivation, overall design)
    MMMM-sub-topic.md       <- sub-RFCs, each with their own LLP number
    ...
```

- The **umbrella RFC** lives as `slug/README.md` and covers overall architecture and motivation.
- The top-level `NNNN-slug.md` is a **symlink** to `slug/README.md`, keeping the number discoverable in flat listings.
- **Sub-RFCs** get their own LLP numbers from the global sequence and can be accepted, reviewed, or tombstoned independently.
- Use a directory when the RFC would exceed ~800 lines and the sub-topics have independent review/implementation timelines. Don't use one when all parts must be accepted together.

## Applicability to other LLP types

While this document focuses on RFCs, the same review process applies well to:

- **Specs** — normative requirements benefit from adversarial review to find gaps and contradictions
- **Plans** — implementation plans benefit from review to catch sequencing issues and missing dependencies

For these types, the `Review` and `Accepted` statuses are available but optional. Use them when the stakes warrant it.

**Explainers, Guides, Principles, Decisions** generally don't need formal multi-model review — they capture existing knowledge rather than proposing new designs. Normal editorial review is sufficient.
