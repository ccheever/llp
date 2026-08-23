# LLP 0011: LLP v2 — Sub-LLPs, Current and Foundation Overlays, Path Is Not Lifecycle

**Type:** RFC
**Status:** Review
**Systems:** LLP
**Author:** Charlie Cheever / Claude
**Date:** 2026-08-22
**Revised:** 2026-08-22 r3 (round-2 delta: title and compatibility wording; adapters re-synced; 0009/0010 open question closed) · 2026-08-22 r2 (round-1 revision, both families' concerns folded — see Revision history) · 2026-08-22 (status corrected Accepted → Review: the initial acceptance had no review behind it; entered the LLP 0010 §2 super-refine loop with LLP 0011.000, lockstep)
**Related:** LLP 0000, LLP 0004, LLP 0009, LLP 0011.000

## Summary

Three changes to the LLP corpus model, together called **LLP v2**. They are additive: every v1 filename, header, `@ref LLP NNNN` reference, and status value keeps its meaning; the breaks are confined to a one-time migration — moving `tombstones/` and renaming any grouping directory that collides with a reserved name (see Compatibility).

1. **Sub-LLPs.** A document can be numbered under a parent — `0011.000-slug.spec.md` is the first child of `LLP 0011`, `0011.000.000-…` its grandchild — to arbitrary depth. The dotted number is the document's identity; `@ref LLP 0011.000#anchor` resolves it.
2. **Two link overlays.** `llp/current/` is the project's declared working set — links to the documents in play; `llp/foundation/` links the small kernel of living documents from which the design could be recreated. Adding or removing a link is the whole operation.
3. **Path is not lifecycle.** A document keeps its path for life; lifecycle is carried entirely by `**Status:**` and the overlays. `llp/tombstones/` is gone. Nothing is moved to change its state.

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

`llp/current/` and `llp/foundation/` contain only links into `llp/`: relative symlinks, or equivalently regular files whose content is the relative path — what git materializes where symlinks are unsupported (`core.symlinks=false`), so overlays survive Windows checkouts and archive transport. The link is a tag; the file it names is the document.

| Overlay | What an entry means | Mutation |
|---|---|---|
| `current/` | The **declared working set**: a committed, branch-scoped claim that this document is in play — not a live sensor of anyone's attention. | Link when work starts (new LLPs link here by default); remove when done. On a shared branch, remove only links for work you own or that a curation pass judged idle. |
| `foundation/` | The **kernel**: the smallest set from which the project's *design* — decisions in force, constraints on code, the rationale that keeps decisions from being re-made — could be recreated. Set-level test; history is not kernel. | Promotion is an editing act: fold what survived from RFCs into the living doc, then link it. Demotion is removing the link. May be empty at bootstrap. |

The normative text — representation, admission test, gated rules (`Tombstoned` in neither overlay; foundation `Active` only; `Superseded` allowed in `current/` because a migration is work), the curation contract — is LLP 0000 [Current and foundation](./0000-linked-literate-programming.explainer.md#current-and-foundation). Overlays change nothing about a document's status, number, or path; `ls llp/` is still the whole corpus. Why links rather than a header field: membership is a property of the *project*, not the document, and `ls` answers with no parser. Why not a list in LLP 0000: the overlay *is* the list.

### Path is not lifecycle

A document keeps its path for life. Grouping subdirectories stay valid but meaningless (LLP 0000 never required flatness; this repo is flat by choice); `reviews/`, `current/`, and `foundation/` are reserved. Deletion remains allowed, as LLP 0000 always said — numbers of deleted documents stay allocated, and a parent with children is tombstoned rather than deleted. The `Tombstoned` status keeps its meaning — *superseded or rejected; read for history only* — with a precise consequence: never in either overlay, body exempt from `@ref` validation. `Superseded` stays as the softer form for migration context. The v1 *path* exemption for `llp/tombstones/` in `ref-check` is replaced by a *status* exemption.

Child numbers, like top-level numbers, are allocated by creation order from the tree; on branches they are provisional until integration, and a collision is repaired by renumbering the later-integrated document (LLP 0000 [Numbering](./0000-linked-literate-programming.explainer.md#numbering)). This is the v1 rule extended to one more level, not a new exposure.

### The curation pass

The overlays only stay meaningful if they are periodically tended. The pass has three verbs, in order:

- **Promote** — fold settled decisions into foundation documents; link newly foundational docs; unlink what no longer passes the admission test.
- **Archive** — unlink from `current/` everything nobody is actively working on. Tombstone what turned out wrong.
- **Realign** — diff the code against what foundation now says and propose the code changes. This is `llp-maintain`'s drift check inverted: not "does the code still match the doc" but "does the doc now demand a code change." Foundation is the comparison target, but not blindly: a foundation claim is first checked against every other binding `Active` document, and a contradiction is resolved in the same pass (foundation wins, or foundation is wrong and gets fixed) before any code change is proposed.

The procedure, cadence, and checklist are [LLP 0011.000](./0011.000-curation-pass.guide.md), the first sub-LLP in this corpus. `llp-maintain` gains a `curate` intent that runs it (proposing, never applying, as always).

## Compatibility

| v1 thing | v2 |
|---|---|
| `NNNN-slug.type.md` | Unchanged; it's the zero-depth case of the grammar. |
| `@ref LLP NNNN#anchor` | Unchanged. |
| Metadata header | Unchanged; no new required fields. |
| `Status:` values | Unchanged set; `Tombstoned` loses its "lives under `tombstones/`" clause. |
| `llp/tombstones/` | Removed. Files move to `llp/` **once**, keeping their numbers — the one breaking change: path-form `@ref`s and markdown links into `tombstones/` must be rewritten in the migration commit (`ref-check` catches the former; grep for the latter). The path exemption becomes a status exemption. |
| Reserved names | `current/`, `foundation/` join `reviews/`; a v1 corpus using either as a grouping directory must rename it before adopting v2. |
| LLP 0005 umbrella-RFC directories | Replaced by sub-numbering. Existing directory layouts keep validating. |
| LLP 0009 kernel item 3 | Amended: lifecycle is status-only; "tombstones under `llp/tombstones/`" no longer holds (noted in 0009). |
| Fresh adoption | `llp-adopt` creates both overlays; a `Draft` root lives in `current/` and enters `foundation/` when it becomes `Active`. |
| Skills | `llp-create` links new docs into `current/` (creating it if absent); `llp-orient` reads the overlays first; `llp-maintain` gains `curate`. Contracts otherwise unchanged. |

## Alternatives considered

- **Underscore separator (`0000_000`).** Reads as a single opaque token and doesn't suggest hierarchy. Dot sorts identically and is the conventional "child of" notation.
- **Reserved child ranges or re-parenting.** Both invite arguing about where a document "belongs" — the taxonomy trap LLP 0000 avoids by making directories meaningless. Creation-order children plus fixed position keep the number a name, not a classification.
- **Keep `tombstones/` alongside the overlays.** Two mechanisms for one axis; the directory's only remaining job (signalling "not current") is done better by absence from `current/`.
- **Drop `Tombstoned` entirely and rely on overlay absence.** Loses the distinction between *finished and correct* and *rejected or wrong*, which an agent that greps into an old document needs. The header value is free; keep it.
- **A `foundation/` of copies, or a generated `FOUNDATION.md` digest.** Copies drift; a digest is a second document to maintain. Links are the only zero-maintenance option.
- **A different name than `current/`** (`in-play/`, `working/`), since `Active` already means "current guidance." Considered; `current/` kept because "the current set" is the phrase people actually reach for, and the status table now says outright that *not current* is not a status.
- **`current/` as a live attention predicate** ("iff someone is thinking about it") — the round-1 draft. Unsatisfiable with parallel agents and branches; replaced by the declared-working-set meaning.

## Open questions

1. Whether `foundation/` should have a size ceiling (a line budget like LLP 0009's) or only the admission test. Start with the test; add a budget if it balloons.
2. Whether `current/` entries should expire automatically (e.g. `llp-maintain curate` proposes unlinking anything not touched in N days). Proposed as advisory in LLP 0011.000; revisit after a few passes.

## Revision history

- **r3 (2026-08-22)** — round-2 delta revision; both families' punch-list PARTIALs and in-delta concerns folded (dispositions in the journal).
- **r2 (2026-08-22)** — round-1 revision; every codex and grok concern folded or recorded. Per-concern dispositions: `llp/reviews/0011-…superrefine-journal.md`.

## Status

Designed 2026-08-22 in a conversation between the authors and implemented the same day (grammar and overlay checks in `ref-check`, tombstones flattened, LLP 0000 and the skills revised, this document and LLP 0011.000 written) ahead of review; in `Review` as of the same date. Acceptance is the author's call after the loop. The open proof obligation after that is the first few curation passes on this corpus.
