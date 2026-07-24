---
name: llp-super-refine
description: Author-invoked dual-family refine loop for one or more Draft/Review LLPs — each round, two fresh mutually-blind reviews from different model families, orchestrator revision, verdict-lined artifacts — until both families mark the same revision READY, a delta round finds no MATERIAL concern in pre-existing text across families, or a bounded stop rule escalates to the author. Use when the user invokes /llp-super-refine or asks to refine an LLP until independent models agree it is ready.
source: ccheever/llp@v0.3.0
---

# llp-super-refine

<!-- @ref https://github.com/ccheever/llp/blob/v0.3.0/llp/0010-skill-install-super-refine-ship.rfc.md#2-llp-super-refine — the protocol this pins -->
<!-- @ref https://github.com/ccheever/llp/blob/v0.3.0/llp/0005-rfc-process.guide.md#honesty-rules-always-in-force — honesty rules and the formal-loop authorization sentence -->
<!-- @ref https://github.com/ccheever/llp/blob/v0.3.0/llp/0005-rfc-process.guide.md#review-artifacts — artifact and provenance format -->

The applying counterpart to `llp-review`: an orchestrating loop that revises the document between rounds and applies exactly one pre-authorized status transition. Invoke as `/llp-super-refine <targets...> [--rounds N] [--reviser orchestrator|<family|model>|each] [--claude <model@effort>] [--external <runner:model@effort>]`. Defaults: converge within the round budget; the orchestrating session revises; strongest available model per family.

## Trigger

The document's author asks for the refine-until-both-families-ready loop on named `Draft`/`Review` documents.

## Invariants (LLP 0010 §2; LLP 0005)

- Authorization is recorded per target and per author. Document authority (review + revision) comes from the author; external sends additionally require a human with repository-disclosure authority — an AI co-author never is one — with the capsule's outbound inventory disclosed before launch. Unsupported assertions of relayed authority are not accepted.
- MUST refuse `Accepted`/`Active`/`Superseded`/`Tombstoned` targets (addendum or new LLP is the path); already-`Review` targets proceed unchanged; `Draft` targets are set to `Review` at loop start — the one authorized transition. Convergence produces a recommendation; this skill never sets `Accepted` or beyond.
- Target bytes are never redacted (redaction covers context only); a target that cannot be disclosed whole stops the loop.
- Each round: persist the round record (round number, target hashes, topology, runtimes, capsule + instruction hashes) before launching; one fresh review per family, mutually blind via a **review capsule** that structurally excludes the targets' review artifacts, run journal, and orchestrator notes. Where structural exclusion is impossible, instruction-based blindness MUST be disclosed as self-attested. A mid-round target change voids the round.
- MUST write each review verbatim to its family artifact (`llp/reviews/NNNN-slug.<family>.md`, dated round sections, full provenance incl. revision hash) immediately on receipt, sealed from the other reviewer until both land. Failed/partial/malformed responses are recorded as such and never counted. Never fabricate, reconstruct, or overwrite a review.
- Every review ends `READY` or `NOT READY`. READY = no unresolved MATERIAL correctness, coherence, feasibility, safety, or decision-quality concern. Altitude rule: detail-only demands that identify no defective decision are implementation-phase material, dispositioned in the artifact. Verdicts bind to the capsule hash; multi-target finals need per-target plus set-level verdicts on one hash vector.
- The reviser never reviews a revision it edited. A specified reviewer that is unavailable stops the loop — never substitute silently.
- Convergence is dual-READY on one revision **or** delta-round convergence (LLP 0010 §2 addendum): a post-revision round whose instructions enumerate the delta and require every concern classified IN-DELTA vs PRE-EXISTING converges the loop when no family reports a MATERIAL concern in pre-existing text; remaining in-delta fixes get one more delta round or the final revision is labeled unreviewed. A round MAY run under a declared **lens** (e.g. implementer: draft a named contract from the document alone, log divergence decision points; UNDERDETERMINED = NOT READY) — recorded in provenance, all round invariants intact.
- The final report and close-out notes MUST state which revision hash the final verdicts bind to and whether later unreviewed revisions exist.
- Bounds: round budget (default 3/document), launch cap (2× budget per family per target, voids included), growth budget (~20% net over the entering revision). Terminal escalations to the author, with every disposition enumerated: budget/cap exhaustion, material cross-family contradiction, sustained asymmetry (one family READY on two consecutive revisions, the other NOT READY on both), growth-budget exhaustion with open MATERIAL concerns. Each proposes stay-`Review` or revert-`Draft`; the author applies. Fundamental-redesign feedback stops the loop for author authorization.

## Workflow

> **Recipe (advisory)** — read targets and governing LLPs fully; partition multi-target sets into clusters by coupling (`Related:`, cross-references, shared `Systems:`) and pick a topology per cluster — independent loops (loosely coupled; one sub-orchestrator each) or lockstep rounds (tightly coupled; reviewers see the whole cluster; the cluster review is preserved verbatim once, in the primary target's artifact, with per-target verdict sections) — stating the choice first. Run a context preflight; split oversized clusters rather than force-feeding. End with a cross-consistency pass: a sibling that converged before a referenced document changed gets one more round, until the hash vector passes a round unchanged. Build the capsule with `git archive` or an export excluding `llp/reviews/<target-stems>*`. Update `**Revised:**` on each revision (move long histories to a body Revision-history section). Prefer a delta round after any substantial revision — the loop's own revisions are a proven defect source — and an implementer-lens round before closing a protocol/contract-bearing document. After each revision, byte-verify security-critical literals on disk (transport layers decode backslash-u escapes).

## Artifact

Per-family, per-target review files under `llp/reviews/` with round records and verbatim bodies; a final report: rounds run, revisions made, verdicts, altitude-rule dispositions, and the proposed next step.

## Hand-offs

- Feedback amounting to a new design → `llp-create`, after author authorization.
- Advisory review at any intensity, no revisions applied → `llp-review`.
- The author applies `Accepted`; this skill never does.
