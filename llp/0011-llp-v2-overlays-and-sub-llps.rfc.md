# LLP 0011: LLP v2 — Sub-LLPs, Current and Foundation Overlays, Flat Corpus

**Type:** RFC
**Status:** Review
**Systems:** LLP
**Author:** Charlie Cheever / Claude
**Date:** 2026-08-22
**Revised:** 2026-08-22 (status corrected Accepted → Review: the initial acceptance had no review behind it; entered the LLP 0010 §2 super-refine loop with LLP 0011.000, lockstep)
**Related:** LLP 0000, LLP 0004, LLP 0009, LLP 0011.000

## Summary

Three changes to the LLP corpus model, together called **LLP v2**. They are backward compatible: every v1 filename, header, `@ref`, and status keeps working.

1. **Sub-LLPs.** A document can be numbered under a parent — `0011.000-slug.spec.md` is the first child of `LLP 0011`, `0011.000.000-…` its grandchild — to arbitrary depth. The dotted number is the document's identity; `@ref LLP 0011.000#anchor` resolves it.
2. **Two symlink overlays.** `llp/current/` holds links to the documents being actively worked on or discussed; `llp/foundation/` holds links to the small kernel of living documents that define the project. Adding or removing a link is the whole operation.
3. **A flat corpus.** Every LLP lives directly under `llp/`, forever. `llp/tombstones/` is gone; lifecycle is carried entirely by `**Status:**` and the overlays. Nothing is moved to change its state.

A periodic **curation pass** — promote, archive, realign — keeps the overlays honest and pulls the code toward what foundation says. The procedure is [LLP 0011.000](./0011.000-curation-pass.guide.md); the normative rules are in [LLP 0000](./0000-linked-literate-programming.explainer.md#1-llp-documents).

## Motivation

**Related documents had no structural relationship.** An RFC, the spec that pins it down, and the plan that executes it got three unrelated numbers from the global sequence, and the only link between them was a `Related:` line. LLP 0005 already reached for directories to group umbrella RFCs with sub-RFCs; sub-numbering does the same job without moving files.

**"Not current" and "wrong" were conflated.** v1 expressed "no longer current guidance" by physically moving a file to `llp/tombstones/`. That broke relative links, made `ref-check` carry exemptions, and forced one decision — *is this dead?* — where there are really two: *is anyone thinking about this right now?* and *are its claims still true?* A finished, correct spec that nobody is discussing is not a tombstone.

**There was no answer to "what is this project, minimally?"** A corpus of ten documents is navigable; a corpus of two hundred is not, and an agent orienting on it needs to know which handful are load-bearing. `Role: Root` marked one entry point. Foundation generalizes that to a kernel with an explicit admission test.

## Design

### Sub-LLP numbering

- Filename grammar: `NNNN(.NNN)*-slug.type.md`. The top-level segment is four digits from the global sequence, as before; each child segment is three digits, numbered `000`, `001`, … in creation order under its parent. Dot is the separator: `0011.000` reads as "child of 0011" and sorts correctly in a directory listing.
- The full dotted number is the identity. It appears in the title (`# LLP 0011.000: …`), in `@ref` targets, and in `Related:` lines. Numbers, at every level, are never reused.
- A child's parent must exist. `ref-check` gates this.
- **Position is fixed at birth.** A document is never re-parented by renaming; if it turns out to belong elsewhere, link to it from there. This is what keeps sub-numbering from becoming taxonomy curation.
- Depth is unbounded but two levels should cover nearly everything. `0011.000.000.000` is legal and a smell.
- Children are not a lifecycle unit: each has its own `Status:` and is promoted, archived, or tombstoned on its own. This replaces LLP 0005's directory-per-umbrella-RFC recipe.

### Overlays

`llp/current/` and `llp/foundation/` contain only symlinks into `llp/` (relative, so they survive a repo move). The file a link points at is the document; the link is a tag.

| Overlay | Membership test | Mutation |
|---|---|---|
| `current/` | Someone — human or agent — is working on or thinking about this document now. | `ln -s` when you start; `rm` the link when the conversation ends. Creating a new LLP links it here by default. |
| `foundation/` | Deleting this document would make the project unrecreatable from the rest of foundation plus the code. | Promotion is an editing act, not just a link: fold what survived from RFCs into the living doc, then link the living doc. Demotion is `rm`. |

Rules `ref-check` gates: every overlay entry is a symlink to an LLP under `llp/`; `Tombstoned`/`Superseded` documents appear in neither; foundation entries are `Active`.

What the overlays are *not*: they do not change a document's status, number, or path; `ls llp/` is still the whole corpus; and nothing else in the system (skills, `@ref`, the header) needs to know a document's overlay membership to function. An agent orients by reading `foundation/` first, then `current/`, then whatever the `@ref`s in scope point at.

Why symlinks rather than a header field: the set is a property of the *project's attention*, not of the document, so it shouldn't dirty the document when it changes; and `ls` answers the question with no parser. Why not `Related:`-style lists in LLP 0000: a central list is one more thing to keep in sync, and the overlay *is* the list.

### Flat corpus, status-only lifecycle

`llp/` is flat and append-only. The `Tombstoned` status keeps its meaning — *superseded or rejected; read for history only* — and gains a precise consequence: such a document may not appear in either overlay, and its body is exempt from `@ref` validation (it may cite things that no longer exist). `Superseded` stays as the softer form for migration context.

Subdirectories under `llp/` remain allowed for human grouping (LLP 0000 never required flatness), but they carry no meaning and this repo stops using them. `reviews/`, `current/`, and `foundation/` are the three reserved names.

### The curation pass

The overlays only stay meaningful if they are periodically tended. The pass has three verbs, in order:

- **Promote** — fold settled decisions into foundation documents; link newly foundational docs; unlink what no longer passes the admission test.
- **Archive** — unlink from `current/` everything nobody is actively working on. Tombstone what turned out wrong.
- **Realign** — diff the code against what foundation now says and propose the code changes. This is `llp-maintain`'s drift check inverted: not "does the code still match the doc" but "does the doc now demand a code change."

The procedure, cadence, and checklist are [LLP 0011.000](./0011.000-curation-pass.guide.md), the first sub-LLP in this corpus. `llp-maintain` gains a `curate` intent that runs it (proposing, never applying, as always).

## Compatibility

| v1 thing | v2 |
|---|---|
| `NNNN-slug.type.md` | Unchanged; it's the zero-depth case of the grammar. |
| `@ref LLP NNNN#anchor` | Unchanged. |
| Metadata header | Unchanged; no new required fields. |
| `Status:` values | Unchanged set; `Tombstoned` loses its "lives under `tombstones/`" clause. |
| `llp/tombstones/` | Removed. Files move to `llp/` once, keeping their numbers; `ref-check` drops the exemption. |
| LLP 0005 umbrella-RFC directories | Replaced by sub-numbering. Existing directory layouts keep validating. |
| Skills | `llp-create` links new docs into `current/`; `llp-orient` reads the overlays first; `llp-maintain` gains `curate`. Contracts otherwise unchanged. |

## Alternatives considered

- **Underscore separator (`0000_000`).** Reads as a single opaque token and doesn't suggest hierarchy. Dot sorts identically and is the conventional "child of" notation.
- **Reserved child ranges or re-parenting.** Both invite arguing about where a document "belongs" — the taxonomy trap LLP 0000 avoids by making directories meaningless. Creation-order children plus fixed position keep the number a name, not a classification.
- **Keep `tombstones/` alongside the overlays.** Two mechanisms for one axis; the directory's only remaining job (signalling "not current") is done better by absence from `current/`.
- **Drop `Tombstoned` entirely and rely on overlay absence.** Loses the distinction between *finished and correct* and *rejected or wrong*, which an agent that greps into an old document needs. The header value is free; keep it.
- **A `foundation/` of copies, or a generated `FOUNDATION.md` digest.** Copies drift; a digest is a second document to maintain. Links are the only zero-maintenance option.

## Open questions

1. Whether `foundation/` should have a size ceiling (a line budget like LLP 0009's) or only the admission test. Start with the test; add a budget if it balloons.
2. Whether `current/` entries should expire automatically (e.g. `llp-maintain curate` proposes unlinking anything not touched in N days). Proposed as advisory in LLP 0011.000; revisit after a few passes.

## Status

Designed 2026-08-22 in a conversation between the authors and implemented the same day (grammar and overlay checks in `ref-check`, tombstones flattened, LLP 0000 and the skills revised, this document and LLP 0011.000 written) ahead of review; in `Review` as of the same date. Acceptance is the author's call after the loop. The open proof obligation after that is the first few curation passes on this corpus.
