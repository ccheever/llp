# LLP 0010: Installed Skills, Super-Refine, and Ship

**Type:** RFC
**Status:** Active
**Systems:** LLP, Agents
**Author:** Charlie Cheever / Claude
**Date:** 2026-07-22
**Revised:** 2026-08-23 (normative surface extracted to LLP 0010.000/.001/.002 per the first LLP 0011.000 curation pass; this RFC is now the rationale record; missing §3 heading restored) · 2026-08-20 (§2 addendum from the exact LLPs 0507–0513 run, author-directed: scope-freeze + punch-list delta rounds as the default late-loop phase for decidable documents — freeze after the round-2 revision for `Type: Spec`, corrections-only revisions with new closure recorded as obligations, per-family punch-list delta reviews over a shrinking surface, finding classification (persistent / new-on-new-content / bar-inflation) feeding the freeze-vs-detail-horizon-vs-escalation choice; current-instantiation defaults updated — Fable 5 xhigh author/reviser, codex `gpt-5.6-sol`@ultra + `grok-4.6`@xhigh reviewers unless otherwise specified, with the grok full-terminal-ban launch rule) 2026-07-23 (five rounds of dual-family refine review, ending in a sustained-asymmetry stop — Fable READY twice consecutively, Codex NOT READY — with the dissents resolved by author decision: `direct` push restored as ship's default, review intensity made tunable policy, `Active` promotion open to any deliverer, the LLP 0005 sentence's two-authority wording fixed, per-file detachment kept. Earlier rounds: update folded into `llp-adopt`; manifest dropped for tag-native verification; blindness made structural; asymmetric-verdict stop, altitude rule, growth budget, and reviewer/reviser/rounds options added — see `llp/reviews/0010-*.{fable,codex}.md`). 2026-07-24: §2 addendum from the snapback LLP 0090 run — delta-round convergence as a second positive terminal, the detail-horizon stop for non-converging reviewers, lens rounds (implementer lens), mandatory final-revision disclosure
**Related:** LLP 0004, LLP 0005, LLP 0008, LLP 0009

## Summary

Three additions to the skills system, growing it from five skills to seven — two new skills plus a new mode of an existing one. This RFC is accepted or rejected **as one unit** (one document, one `Status:`, per LLP 0005); its implementation phases land independently, and if a part is later cut, that is recorded as a dated addendum or a superseding LLP, never inferred from prose.

1. **Close the distribution loop.** [LLP 0008](./0008-distributed-agent-skills.rfc.md#distribution) decided that skills reach consuming projects as pinned copies, and llp-maintain's contract already *notes* stale pins — but nothing installs the copies and nothing applies updates. `llp-adopt` gains an **install step** and an **update mode**, backed by tagged releases and per-installation receipts.
2. **`llp-super-refine`** — the author-authorized "refine until two independent model families both say ready" loop, proven on single documents in the `exact` project, specified here with auditable rounds, bounded budgets, and a multi-document design.
3. **`llp-ship`** — hand it one or more tasks and it plans, executes in isolated lanes, verifies and reviews the exact integrated commit, and delivers via the repo's chosen delivery mode.

All three inherit the standing rules: skills are ≤60-line contracts citing their governing policy (LLP 0009), review honesty is absolute (LLP 0005), and docs co-evolve with code (LLP 0004). Each part pins behavioral protocol — consent around writes, honesty around review, safety around delivery — which is what the capability test says survives model improvement. Throughout this document, **Invariants lists and anything phrased as MUST are contract; mechanics phrased as "e.g." or marked *(advisory)* are recipe** (LLP 0004, "Contracts over recipes"). Contract clauses state outcomes; how an implementation achieves them is phase work unless a MUST says otherwise.

## Motivation

**Distribution is half-built.** Today a consuming project gets LLP skills by someone hand-copying directories. Staleness *detection* is already specified — llp-maintain's audit notes a `source:` pin that lags upstream — but nothing installs the copies, nothing verifies what an installed copy corresponds to, and nothing applies an update. Without the full loop, every consuming repo silently forks the skills the day they're copied. (The authoring repo itself demonstrates the verification gap: `skills/llp-maintain/SKILL.md` was edited after the `v0.2.0` tag it pins, so a copy of HEAD would immediately diverge from its declared pin.)

**Super-refine earned promotion.** The dual-model refine-until-ready loop has run repeatedly in `exact` and produces materially better documents than single-pass review — this claim is experiential, not yet measured; the loop's artifacts under `llp/reviews/` are the evidence trail a future Research LLP can mine. Related LLPs are usually drafted together; the multi-document generalization is the part that needs design, so it belongs in the first-party corpus.

**Ship pins down a recurring improvisation.** "Take these tickets and do them end to end" is already a common request; each time, the agent re-improvises worktree strategy, verification depth, and cleanup. The failure modes — fabricated verification, self-review rubber-stamping, orphaned worktrees, unauthorized publication — are exactly the kind of invariants LLP 0008 says skills exist to pin.

## Design

The normative surface of each part was extracted on 2026-08-23 into a sub-LLP spec, so that binding policy lives in foundation documents rather than only in this RFC plus `SKILL.md` MUSTs (LLP 0009; first curation pass under LLP 0011.000). What remains below is rationale, rejected alternatives, and history. **Where this document and a spec differ, the spec governs.**

### 1. Installation and updates (`llp-adopt`, extended)

**Contract:** [LLP 0010.000](./0010.000-skill-installation-and-updates.spec.md). In one line: a release is a git tag; an install writes a receipt beside itself; an update three-way-checks, shows one diff, revalidates before mutating, and never clobbers a fork.

**Why a mode of `llp-adopt`, not a separate skill.** An earlier revision made this a separate `llp-update-skills` skill; review showed the separation argument didn't hold: adopt already performs verified, diff-shown, receipt-writing update work in its bootstrap and migration paths, and a separate skill would duplicate that surface while growing the always-loaded core (LLP 0008, "Modes instead of more skills"). The posture boundary that matters — llp-maintain *never applies*, adopt applies after an approved diff — is preserved: llp-maintain's audit keeps its stale-pin note and hands off here.

**Alternatives.** Symlinks: rejected in LLP 0008. Plugin marketplace: single-runtime; possible later adapter. Submodules/subtrees: a second repo inside every consumer for a handful of markdown files. A per-release hash manifest file: dropped in review — the tag's tree already content-addresses the release, and a manifest inside the tag it attests adds consistency, not authenticity; it returns only if per-file raw fetch (no git) becomes a supported channel. A deterministic sync CLI: would make staging/atomicity mechanical but re-opens LLP 0008's no-CLI decision; revisit narrowly if the transaction outcomes above prove error-prone to achieve with shell primitives.

### 2. `llp-super-refine`

**Contract:** [LLP 0010.001](./0010.001-super-refine-loop.spec.md) — authorization, round protocol, bounds, multi-document topology, delta/lens rounds, scope freeze, and the dated current instantiation.

**Why a separate skill.** It stays a separate skill rather than an `llp-review` mode on a posture line: `llp-review` gathers advice and **never applies anything**; super-refine is an orchestrating loop that *revises the document* between rounds and applies one pre-authorized status transition. Same reasoning that keeps apply-mode work out of llp-maintain. `llp-review` remains the right tool for advisory review at any intensity.

*Note:* this RFC's own refinement ran under the `exact` prototype of this skill (invocation-authorized, `.fable`/`.codex` artifact naming, instruction-based blindness disclosed in its artifacts, status change at convergence rather than loop start). It predates the protocol above and is not a conforming acceptance test; Phase 2 includes one.

**History of the protocol.** The 2026-07-24 addendum (delta-round convergence, lens rounds, detail-horizon stop, final-revision disclosure) was motivated by a six-round run in the snapback repository (its LLP 0090) and this RFC's own refinement: reviewer families are calibrated differently, one family may withhold `READY` indefinitely while its findings keep narrowing — across five observed loops the external family never emitted `READY` once — so dual-READY measures calibration as much as quality. The 2026-08-20 addendum (scope freeze, punch-list delta rounds, finding classification) was motivated by a seven-loop run in `exact` over spec-type targets (its LLPs 0507–0513; 42 sealed reviews): full-document rounds on specs stay productive yet cannot converge, because each round's totality closures add normative surface (+37%…+116% cumulative) that the next pass reviews at full depth; the fix is a bounded, shrinking review surface, not fewer rounds. The first run under the v2 corpus model (LLP 0011, 2026-08-22/23) converged dual-READY in three rounds using two punch-list delta rounds.

### 3. `llp-ship`

**Contract:** [LLP 0010.002](./0010.002-ship.spec.md) — preflight, task gating, plan/ledger, the SHA-indexed gates, delivery modes, invariants.

**Why the defaults are what they are.** Review intensity is tunable policy rather than an invariant because it is capability-graded (LLP 0004): the right default falls as models improve, while honesty — claimed review must be real, SHA-bound, independent — does not. `direct` is the no-policy default because shipping means shipping: the human invoking ship is choosing to push, and that invocation is the authorization (author decision, 2026-07-23, after a sustained-asymmetry stop in this RFC's own review). `Accepted` → `Active` is not author-restricted because LLP 0005 defines it as the factual completion transition, so the deliverer who completes the implementation may apply it — called out in the candidate so the delivering human knowingly endorses it.

## Consequences

- LLP 0008's five skills become seven, organized as core plus additive flags; its skills table, hand-offs, and the `AGENTS.md`/README skill index gain adopt's install/update mode, `super-refine = dual-model refine-until-ready`, and `ship = tasks done end to end`. LLP 0005 gains the quoted authorization sentence (§2). LLP 0001 (the adoption guide) gains the install step. **LLP 0009 is revised in the same phase**: this RFC supersedes its classification of distribution machinery as absent shell — receipts and the update transaction become first-party — while its capability test, the ≤60-line contract cap, and the five-skill *core* stand. Each of these lands **with the phase that implements it** — there is no standalone documentation phase (LLP 0004 co-evolution). The `.llp/policy.json` file is a partial instantiation of LLP 0008 OQ2's deferred `llp.json`; consolidating them later revises that answer, not a new surface.
- Two new skill directories, `skills/llp-super-refine/` and `skills/llp-ship/`, each a ≤60-line contract (Trigger · Invariants · Artifact · Hand-offs) citing this RFC and LLP 0005/0008 as pinned upstream URLs; `skills/llp-adopt/` grows its install step and update mode. **Contract-first rule:** each phase begins by drafting its contract; if a contract cannot carry its invariants within the line cap, that is a blocking finding brought back to the author, not a rule silently dropped.
- Release discipline on this repo, with a checklist in the adopt contract's recipe: bump `source:` pins and pinned URLs → commit → tag → push tag. Release validation, if ever automated, is a separate composable check — `ref-check` keeps its single purpose and size (LLP 0009).
- The `exact` project's `llp-super-refine` becomes a consumer of the first-party skill (a pinned copy with a receipt) instead of the origin.

## Implementation plan

Independently landable phases, risk-ordered; each starts with its contract draft and lands its own doc reconciliation (above):

1. **Receipts + install + update mode** (`llp-adopt`, LLP 0001/0008 updates, release checklist). Acceptance: clean-room install from a tag; idempotent rerun; a hand-edited skill aborts the coupled update with resolution paths; migration of a pre-receipt consumer (use `exact`); an interrupted update recovers to either endpoint; edit-between-approval-and-apply aborts; concurrent second run blocked; offline and moved-tag runs end "cannot verify, wrote nothing."
2. **`llp-super-refine`** (+ the LLP 0005 sentence, landing together). Acceptance: a conforming single-doc run with capsule-hashed, verdict-lined artifacts and the round record persisted pre-launch; a crash after one review leaves that review's artifact intact; forced non-convergence hits the budget and escalates; a sustained-asymmetry run stops after two consecutive one-sided READYs; a two-doc lockstep run yields per-target plus set-level verdicts on the final hash vector; refusal of an `Accepted` target.
3. **`llp-ship`** (riskiest, last). Acceptance: two-lane run delivering via `pr` with the report in the PR body; lane-passes/integration-fails caught at VERIFIED; a review finding produces a new SHA that re-enters gating; base moved mid-run triggers reintegration or `blocked`; a push-succeeds/PR-fails run reports `branch-pushed` alongside the blocked step; abort preserves ledger, recovery instructions, and unique commits; a non-`Accepted` proposal-shaped task stops at gating; a completed implementation includes a clearly-called-out `Accepted` → `Active` commit in the gated candidate; a run at intensity `none` delivers with "unreviewed" stated in its report.

## Open questions

1. **Skill-count pressure.** Core stays five, but flagged consumers load up to seven descriptions (LLP 0008's token-footprint question). Consolidation candidates should come from observed low usage once consumers exist — no skill is pre-exempt.
2. **Degraded super-refine.** When the external family is unavailable, the loop stops. Worth adding a *deferred-second-family* mode — single-family rounds to a provisional verdict, the document marked as owing one cross-family round before `Accepted` may be proposed? It preserves the guarantee's meaning while tolerating outages.
3. **Namespace.** `llp-ship` is general task execution, only incidentally LLP-flavored. It keeps the `llp-` prefix for family cohesion; a future split — generic shipping engine, thin LLP adapter — is plausible if non-LLP repos want it.
4. **Round-budget and growth-budget defaults.** Three rounds and ~20% are guesses from `exact` experience; the round records' telemetry should tune both, and could justify per-stakes defaults.
5. **Evidence obligation.** What usage data (invocation counts, convergence rates, asymmetric-stop frequency, prevented failures, token cost) should the first consuming repos collect so LLP 0009 Phase 4's proof obligation — and OQ1 here — can be answered with observations rather than predictions? Install receipts (origin, tag, date) are a natural longitudinal dataset.
