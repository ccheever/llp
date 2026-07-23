# LLP 0005: RFC Authoring and Review Process

**Type:** Guide
**Status:** Active
**Systems:** LLP
**Author:** Charlie Cheever / Claude
**Date:** 2026-04-01
**Revised:** 2026-07-23 (formal-loop authorization sentence added, per [LLP 0010](./0010-skill-install-super-refine-ship.rfc.md). Earlier: 2026-06-10, review intensity made stakes-scaled and author-judged, per [LLP 0009](./0009-capability-invariant-core.rfc.md))
**Related:** LLP 0000, LLP 0004, LLP 0010

## Summary

This document defines the authoring workflow, the review norm, and the expanded lifecycle for LLP documents of type **RFC** — also applicable to **Spec** and **Plan** documents, or any LLP that proposes a design others will implement.

The review norm in one line: **honesty rules are fixed; review intensity is the author's call, proportional to stakes.** A foundational architecture document may deserve round after round of review across multiple model families until no substantive issues remain. An experimental prototype design may reasonably get none. Review until you're happy — not until a quota is met.

## Lifecycle for RFCs

RFC-type LLPs use an expanded set of statuses:

| Status | Meaning |
|--------|---------|
| `Draft` | Under active discussion. May change substantially. |
| `Review` | The author has opted this document into a formal review loop. |
| `Accepted` | Approved for implementation. Design is stable. |
| `Active` | Fully implemented in the codebase. |
| `Superseded` | Replaced by a newer LLP. Link to the replacement. |
| `Tombstoned` | Historical context, no longer current guidance. |

Typical progression: `Draft` → (`Review` →) `Accepted` → `Active`. `Review` is optional — setting it is the explicit opt-in to a formal loop; documents can go straight from `Draft` to `Accepted` when the author judges they've had enough scrutiny. Not every RFC reaches `Accepted`; some are `Tombstoned` when the idea is rejected — briefly note why in the document.

Rules:

- New RFCs start as `Draft`. Update `**Revised:**` on substantive changes.
- The author decides when a document is done being reviewed and moves it to `Accepted`. Reviews are inputs, never approvals — no reviewer, human or model, accepts on the author's behalf, and no tool changes `Status` unilaterally.
- An accepted RFC becomes `Active` when the implementation is done and merged.
- Once accepted, an RFC's design section shouldn't materially change. If the design evolves during implementation, write a new LLP or add a dated addendum (`## Addendum (YYYY-MM-DD): …`).
- If a later RFC replaces this one, set `Superseded` and add `**Superseded by:** LLP NNNN`.

## Authoring workflow

RFCs are written collaboratively with AI:

1. **Discuss.** Hash out the idea interactively — motivation, constraints, trade-offs, rough design.
2. **Draft.** A good RFC covers: Summary, Motivation, Design (specific enough to implement from), Alternatives considered, Implementation plan, Open questions. Small RFCs may need only the first three.
3. **Review** — as much as the stakes warrant (below).
4. **Iterate.** Address the feedback you find compelling; the author is the final decision-maker.
5. **Accept.** The author updates the status when satisfied.

## How much review to buy

Review effort should be proportional to what a mistake would cost, and the right amount changes as models change — reviews get more valuable against confident-but-wrong content *and* cheaper to run — so this guide deliberately sets no quota. Calibrate roughly:

- **Foundational / load-bearing** (architecture the codebase will grow around, normative specs, anything expensive to reverse): multiple review rounds, multiple model families, repeat until no substantive issues remain. Consider re-reviewing after major revisions.
- **Ordinary proposals** (a bounded design with real trade-offs): one round from a different model family than the one that drafted it, plus the author's critical pass, is usually enough.
- **Experimental / low-stakes** (prototypes, codifications of proven practice, easily reversed choices): the author's own read may be all it's worth. Skipping formal review is a legitimate choice, not a shortcut.

### The multi-model loop (recommended technique for high stakes)

A single author — human or AI — has blind spots, and different model families catch different ones. When stakes warrant it, get critical review from **at least two model families plus the author**: (a) the author reads critically; (b) a non-Claude model (GPT, Gemini, or the current best alternative) reviews; (c) a Claude model in a fresh session — never the session that authored the draft — reviews. The requirement is cognitive diversity across *families*, not specific model names; update which models you use as the frontier shifts.

**Standard review prompt** (or a close variant):

> What do you think of this proposal? Is it a good idea? Do we have a good plan here? How would you change it to make it better? What would you add or take away or change? Is anything definitely or possibly wrongheaded here? Do you have any novel ideas that you think might make this way better even if they are a bit non-standard? What are the key open questions we need to answer to refine this?

## Honesty rules (always in force)

However much or little review a document gets, these are fixed:

- **Never fabricate a review.** A review that didn't happen is never recorded, summarized, or counted — by a human or an agent.
- **Reviews that happen leave artifacts** (below), so future readers can see what was raised and how it was addressed.
- **Reviewers advise; the author decides.** Nobody accepts or rejects on the author's behalf.
- **Sending content to an external model is an explicit human action**, never automatic; redact secrets and prefer a local runner for sensitive material. An author's explicit invocation of a formal review loop (e.g. `/llp-super-refine`, [LLP 0010 §2](./0010-skill-install-super-refine-ship.rfc.md#2-llp-super-refine)) constitutes the `Review` opt-in and authorizes the loop's revisions within its disclosed budget; the loop's external-model sends require authorization from a human with repository-disclosure authority — supplied by the same invocation when the invoker holds both capacities.

## Review artifacts

Save each review under `llp/reviews/`, one file per reviewing model family, named after the LLP and the family:

```
llp/reviews/
  0042-widget-api.gpt.md
  0042-widget-api.claude.md
```

These are reference material, not LLP documents — no LLP number, no LLP metadata block. Each opens with a short **provenance header**:

```markdown
**Reviewer family:** <Claude | GPT | Gemini | …>
**Provider / runtime:** <e.g. pasted manually | claude-code sub-agent | cli-runner>
**Date:** YYYY-MM-DD
**Redacted:** <yes/no>
**Method:** <manual | sub-agent | cli-runner>
```

The header is auditable self-attestation, not proof: tooling can check that an artifact exists and is well-formed, but cannot verify that a `manual` review actually occurred — which is exactly why the never-fabricate rule is behavioral. A re-review by the same family gets a dated section in the same file rather than overwriting it.

## Implementation

Once an RFC is accepted: reference the LLP number in commit messages and PR descriptions ("Implements LLP 0042"); carry `@ref` annotations from implementing code to specific sections; update the status to `Active` when the implementation is complete and merged.

## Large RFCs

When an RFC covers multiple independently reviewable sub-topics, use a directory: an umbrella RFC at `slug/NNNN-slug.rfc.md` (architecture, motivation, overall design) plus sub-RFCs with their own numbers from the global sequence, each accepted or tombstoned independently. All files keep the standard `NNNN-slug.type.md` shape — never an unnumbered `README.md`. Use a directory when the RFC would exceed ~800 lines *and* the sub-topics have independent timelines; don't when all parts must be accepted together.

## Applicability to other LLP types

The same norm applies to **Specs** (adversarial review finds gaps and contradictions) and **Plans** (review catches sequencing issues) — `Review`/`Accepted` are available when stakes warrant. **Explainers, Guides, Principles, and Decisions** capture existing knowledge rather than proposing new designs; ordinary editorial review is usually sufficient.
