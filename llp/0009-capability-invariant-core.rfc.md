# LLP 0009: The Capability-Invariant Core

**Type:** RFC
**Status:** Active
**Systems:** LLP
**Author:** Charlie Cheever / Claude
**Date:** 2026-06-10
**Revised:** 2026-07-23 (distribution machinery reclassified per [LLP 0010](./0010-skill-install-super-refine-ship.rfc.md) — see Addendum. Earlier: 2026-06-10, post GPT-family review — see `llp/reviews/0009-capability-invariant-core.gpt.md`; accepted by the author and implemented the same day)
**Related:** LLP 0000, LLP 0003, LLP 0004, LLP 0005, LLP 0008

## Summary

LLP should be reorganized around one question: **which parts of this system would still earn their keep if the model were flawless?** The parts that would — the document corpus, the `@ref` grammar, the living-document lifecycle, the review honesty rules, the provenance rules — exist because design rationale is *information the code does not contain*, and no model capability recovers information that was never written down. Those parts form the **kernel**, stated as contracts. Everything that exists because models currently err — step-by-step recipes, mechanical pipelines, output-format specifications, distribution machinery — is **shell**: advisory, explicitly marked, and deletable as capability arrives, without breaking anything.

Concretely, this RFC proposes: replace the `llp-spec:` vendoring/skew machinery with pinned upstream URLs and cut the mechanics-recipe layer from LLP 0008; shrink the provenance system to its three-marker kernel and move it into LLP 0000; replace the ~300 lines of *planned* validation-tooling spec with one small *built* checker (`ref-check` v1) and a one-paragraph future note; fold LLP 0006 into LLP 0000; merge LLP 0001 and 0002 into a single adoption guide; demote LLP 0005's mandatory multi-model review loop to stakes-scaled, author-judged guidance; rewrite the five core skills as contracts (trigger · invariants · artifact · hand-offs) at ≤60 lines each; delete the `llp-list` and `ref-story` skills; and correct document statuses so the corpus obeys its own lifecycle rules. The current-guidance system — documents plus skills — shrinks by roughly half (the documents alone by roughly a third). Nothing a consuming project depends on — the `@ref` syntax, the numbering, the metadata header, the statuses — changes at all.

## Motivation

### The model trajectory splits LLP's value in two

LLP was designed when agents needed help finding context, computing `max + 1`, and staying inside a workflow. Frontier models need much less of that help; models two generations on will need almost none of it. But the trajectory does not make LLP pointless — it makes it *asymmetric*:

**What decays.** Retrieval scaffolding (a strong agent finds and reads `llp/` from a one-line pointer), mechanical-determinism recipes (frontier models rarely flub arithmetic or filename formatting), token-economy arguments (context got cheap; only the signal-to-noise argument survives), and recipe-style skills written like pseudo-code for a 2024 model.

**What appreciates.** The epistemic gap is permanent: the contractual 30-second retry cap, the rejected alternative, the incident that motivated the weird code — these are facts, not inferences, and a smarter model doesn't close the gap, it papers over it with *more convincing invented rationale*. Provenance markers and multi-model review are defenses against a failure mode that grows with capability. Meanwhile, as agents write a larger share of the code, the share of the codebase whose rationale was never in any human's head grows — the documents become the only place intent exists at all, and prose becomes the primary steering surface. The headline thesis ("keep humans in markdown") gets stronger with every model generation.

### The corpus currently mixes the two

Today `llp/` + `skills/` total ~3,100 lines, and roughly a third specifies machinery whose only justification is "models might get this wrong" or "this might be needed someday": the `llp-spec:` namespace with vendoring, pinning, and skew detection (a package manager for markdown, none of it built); a claim-marker grammar with ids, Evidence-matching rules, and a two-layer enforcement taxonomy (unused); ~300 lines specifying a validation pipeline that doesn't exist; 350 lines of recipe-style utility skills that restate what a capable model improvises from one sentence. Meanwhile the root spec itself is marked `Draft` — by LLP's own rules, unmarked drift.

The fix is not deletion of LLP's substance. It is sorting every line by the question above, keeping the kernel as normative contract, and making the shell honest about what it is.

## Model assumptions

These are the assumptions this design is built against. Stating them makes the design reviewable — if an assumption is wrong, the affected decision is traceable.

| # | Assumption (frontier +2 generations) | Design consequence |
|---|---|---|
| A1 | Agents locate and read relevant docs from minimal pointers, unprompted | Orientation needs a one-line ambient rule, not elaborate retrieval scaffolding |
| A2 | Mechanical tasks (numbering, formatting, anchor checks) are near-perfect in-context | Pipeline recipes become advisory hints, not architecture |
| A3 | Context is corpus-scale and cheap; cost ceases to be the argument for thin pointers | "Pointers, not prose" survives on signal/curation grounds only |
| A4 | Agents run long-horizon and in parallel fleets | Drift accelerates; co-evolution and deterministic CI checks *appreciate*; doc numbering meets concurrency (open question) |
| A5 | Confabulated rationale becomes indistinguishable from real rationale by inspection | Provenance and multi-model review *appreciate* |
| A6 | **The epistemic gap is permanent:** no capability recovers unrecorded decisions, external constraints, or rejected alternatives | The corpus + `@ref` is the durable product; this is the only assumption the kernel bets on |
| A7 | Harnesses, skill formats, and slash commands keep churning across generations | Durable value lives in plain markdown in the repo; skills are thin per-runtime adapters, never the home of policy |

Today's models sit between A1–A3 being false and true: they benefit from some shell, and small local models benefit from more of it. The design therefore *marks and shrinks* the shell rather than deleting all of it now — but anything that fails both tests ("flawless models wouldn't need it" *and* "today's models don't need it either") is deleted immediately.

## Design

### Two new principles (added to LLP 0004)

**Contracts over recipes.** Normative content states *what must be true* — document shapes, reference grammar, lifecycle rules, behavioral protocols. How-to content — recipes, pipelines, scaffolds, output formats — is advisory, visibly marked, and deletable. A skill, guide, or spec section must be classifiable at a glance as one or the other.

**The capability test.** The companion to the simplify test, applied to LLP itself: *would this still earn its keep if the model were flawless?* If yes — it carries information the code doesn't, or coordinates humans and agents across time — it is kernel. If it exists to prevent model error, it is shell: keep it only while the error is real, mark it, and delete it when measurement says the error is gone.

### The kernel (normative; capability-invariant)

Seven items. Each is a contract; none depends on model capability.

1. **The corpus.** Numbered living documents (`NNNN-slug.type.md`) with the plain-markdown metadata header (`Type`, `Status`, `Systems`, `Author`, `Date`; optional `Role`, `Revised`, `Related`). Types and statuses as currently defined in LLP 0000 — unchanged.
2. **The reference grammar.** `@ref <target>[#anchor] [relation] — gloss`, attachment semantics, heading-slug anchors by default. **Every target form LLP 0000 defines today is retained:** `LLP NNNN` (anchor optional), repo paths to any file type (anchor optional), project-defined shorthands like `SPEC#x` (anchor optional; the mapping mechanism stays project-defined), and URLs — this RFC folds LLP 0006's normative content (URL and non-markdown targets) into LLP 0000 §2, where it always belonged. Simplifying the spec's prose must never narrow its grammar; the full enumeration is restated under Compatibility.
3. **The lifecycle.** Living documents; `Draft → (Review → Accepted →) Active → Superseded/Tombstoned`; tombstones under `llp/tombstones/`; stale guidance is never left unmarked. Statuses in this repo are corrected to obey this (see Implementation plan, Phase 0).
4. **The orient-first rule.** One ambient sentence, carried by the always-in-context agent-instructions file: *before editing a subsystem with documented design, read its governing LLP.* This is the keystone habit. Everything beyond the sentence is shell.
5. **The co-evolution norm.** Docs and the code they describe change in the same commits; a docs-only change is a drift signal. (Unchanged from LLP 0000/0004; restated here because under A4 it becomes the main defense against accelerated drift.)
6. **The review norm.** Honesty is kernel; intensity is not. Reviews that happen leave artifacts under `llp/reviews/` with the provenance header; no review is ever fabricated or recorded that didn't occur; model reviewers advise and the author decides; setting a document to `Review` is the explicit opt-in to a formal loop. How *much* review a document gets is the author's call, proportional to stakes: a foundational architecture document may warrant round after round across model families until no substantive issues remain; an experimental prototype may warrant none — review until you're happy, not until a quota is met. The optimal dial also moves as models change (A5 makes review both more valuable against confabulation and cheaper to run), which is exactly why the kernel fixes the honesty rules and not a process. LLP 0005's multi-model loop (≥2 families plus the author) is demoted from requirement to recommended technique for high-stakes documents, and is revised accordingly.
7. **The provenance kernel.** Reduced from LLP 0008's machinery to three rules that fit in three lines:
   - Generated rationale is tagged: `[observed]` (evidenced in code/tests — say where), `[confirmed]` (a named human, with date), or `[inferred]` (a hypothesis).
   - A document containing `[inferred]` claims stays `Draft`; ratify to `[confirmed]` or delete before promotion.
   - Never assert recovered "why" as fact — the tag *is* the honesty.

   Only the middle rule is machine-gated (`ref-check` fails on `[inferred]` in an `Accepted`/`Active` document); the say-where and name-a-human obligations bind authors and are checked by reviewers and `llp-maintain`, not by the gate — stating that plainly beats inventing a checkable grammar nothing uses yet. The claim-id grammar, `## Evidence` matching rules, and the error/warn taxonomy are dropped until a real retrofit proves they're needed. A project that wants them can adopt them as a local convention; the kernel doesn't mandate them.

### The shell (advisory; capability-graded)

Everything else: the context-pack format, type-specific scaffolds, grep/pipeline recipes, listing and rendering conventions, per-runtime install notes. Shell content follows three rules:

- **Marked.** Shell sections open with `> **Recipe (advisory)** — skip if your runtime doesn't need it.` This makes future deletion a grep, not an archaeology project.
- **Homed in the corpus, not the skills.** Per A7, a recipe worth keeping lives in an LLP document; skills may point at it but never be its only home.
- **Deletable by criterion, not by vibe.** A recipe is deleted when the error it prevents stops being observed (e.g., once frontier-model runs stop flubbing next-number, the numbering recipe goes). Deletions are recorded in the owning doc's history; nothing else changes.

### The cuts

| Item (today) | Disposition | Where the value goes |
|---|---|---|
| `llp-spec:` namespace, vendoring, submodule-vs-snapshot, skew findings (LLP 0008) | **Replace with pinned upstream URLs** — none of it is built, and it solves a distribution problem at CI-grade rigor that exists at documentation-grade severity | Skill policy citations use pinned upstream URLs (a kernel form, resolvable from any install location) plus an informational `source: <owner>/<repo>@<tag>` frontmatter line. The downgrade is explicit: staleness = compare the pin to upstream releases (`llp-maintain` notes it when network allows); **offline section resolution is not promised** — a project that needs it vendors a snapshot and rewrites URLs to paths itself |
| Provenance machinery: claim ids, Evidence grammar, enforcement taxonomy (LLP 0008) | **Cut to kernel** (three rules, above), moved into LLP 0000 | Kernel item 7; optional local convention for the rest |
| Harness-mechanics recipe table, pipeline-vs-primitive-fallback analysis (LLP 0008) | **Cut to one advisory note** ("for facts, prefer a pipeline whose output is the answer — e.g. next number = `ls llp \| grep -oE '^[0-9]{4}' \| sort -n \| tail -1`") | Shell note in LLP 0000's conventions |
| LLP 0000 §6–8: ~300 lines of planned validation/annotation/index tooling | **Replace with built `ref-check` v1** + a one-paragraph note naming possible future stages | See "The one program" below |
| LLP 0006 (external references RFC) | **Fold into LLP 0000 §2, then tombstone** — its alternatives-considered record (e.g. why external artifacts aren't wrapped in LLPs) is worth keeping; number 0006 is never reused | Normative grammar into the kernel; the rationale record under `llp/tombstones/` |
| LLP 0001 + LLP 0002 (greenfield / retrofit guides) | **Merge into one adoption guide** (revise 0001 as `0001-adopting-llp.guide.md`; tombstone 0002) — mirroring the scaffold/retrofit modes the skill layer already unified | One guide, two modes, same shape as `llp-adopt` |
| LLP 0005's review quota ("must be reviewed by at least two AI models") | **Demote from requirement to stakes-scaled guidance** — many rounds for foundational architecture, little or none for experimental prototypes; the author judges, and the optimum moves with model capability | LLP 0005 revised: honesty rules, artifact format, and provenance header stay normative; the multi-model loop becomes the recommended technique for high-stakes documents |
| `llp-list` skill (133 lines) | **Delete.** Listing is a grep; today's models do it from one sentence, and `llp-maintain --intent audit` covers the curated view | One advisory line in the maintain skill |
| `ref-story` skill (216 lines) | **Delete.** The rationale-order view is the spec's most novel *idea* but it needs a prompt, not 216 lines of pseudo-code | A worked prompt example plus one sample output in LLP 0000's (shrunk) annotated-view section, so the literate payoff stays demonstrable |
| LLP 0008 itself (457 lines, in `Review`) | **Revise down to its surviving decisions** (~150–200 lines): five-skill architecture, skills-orchestrate/harness-computes, no bespoke CLI, the AGENTS.md routing block, condensed distribution table, pointer to the review protocol. 0008 is not yet `Accepted`, so material revision is legitimate | The durable architecture, minus the machinery this RFC removes |
| Fixture-harness and test-layer plans (LLP 0008) | **Cut to one fixture**: a tiny sample tree with a deliberately broken ref, used by `ref-check`'s own tests | Phase 3 |

### Skills become deletable adapters

The five-skill set (`orient` · `create` · `review` · `adopt` · `maintain`) survives — the 7→5 consolidation was correct and recent, and re-partitioning would be churn. What changes is what a `SKILL.md` *is*:

- **Contract form, ≤60 lines:** Trigger · Invariants (MUST/MUST NOT) · Artifact · Hand-offs. The current skills average ~123 lines because they restate workflow prose; the invariants are the only part that must not be improvised.
- **No policy lives only in a skill.** Every MUST in a `SKILL.md` cites the LLP section it comes from — as a **pinned upstream URL** (e.g. `https://github.com/<owner>/llp/blob/<tag>/llp/0005-rfc-process.guide.md#review-artifacts`), because a copied skill resolves relative links against the wrong tree and bare `LLP NNNN` against the consuming project's corpus. URLs are already a kernel target form, so this replaces `llp-spec:` with grammar that already exists. The skill is a per-runtime adapter (A7); the corpus is the home.
- **The layer is formally optional.** Deleting `skills/` entirely must cost convenience, not correctness: a runtime with no skills mechanism gets the same behavior from the agent-instructions block plus the corpus. This is the property that makes the system ready for harnesses that don't exist yet.

The invariants worth carrying (everything else in today's skills is shell): orient is read-only and scoped to the task; create derives the next number from the tree, never reuses one, and prefers extending a covering doc; review never fabricates, never records a review it wasn't given, never touches `Status`; adopt never overwrites user prose outside managed blocks, keeps generated docs `Draft` with provenance tags, and proposes annotations rather than applying them; maintain proposes and never applies.

### The one program: `ref-check` v1

The single place capability *can't* substitute is where there is no agent: CI and pre-commit. That carve-out was already in LLP 0000 §6 and LLP 0008 — but as ~300 lines of speculation. The simplest version of that spec is a program that exists:

- **One file, no dependencies** (stdlib-only script, target ≤250 lines), checked into this repo.
- **Scope:** scans `llp/**/*.md` and `skills/**/SKILL.md` (skills dogfood the grammar through their policy citations).
- **Checks — exactly these, per target form:** `LLP NNNN[#anchor]` — document exists, and the anchor heading exists when given. `path[#anchor]` — file exists (any type); anchors checked in markdown targets, reported `unchecked` for non-text formats. Shorthand — resolved only when the project documents a mapping; otherwise listed as unchecked, never failed (Open question 6). URL — shape-validated, never fetched. Corpus-wide: metadata headers parse; filename `type` matches `**Type:**`; LLP numbers are unique; no `[inferred]` marker in an `Accepted`/`Active` document.
- **Severity:** broken ref / bad metadata / `[inferred]`-past-`Draft` → exit 1; everything subtler (stale gloss, orphaned annotation, coverage) stays the agent's job via `llp-maintain` — judgment doesn't belong in the gate.
- **Replaces, not adds:** landing it deletes LLP 0000 §6's pipeline spec (extract/resolve/index/annotate stage table, severity model, JSON IR) in favor of `ref-check --help` plus a one-paragraph note that index/annotate views are possible future stages. Net spec change is strongly negative.

This is not a reversal of 0008's no-CLI decision: that decision rejected a CLI as the skills' deterministic *foundation*, and explicitly reserved a small non-interactive checker as the one legitimate program. This RFC just builds the reserved thing instead of continuing to describe it.

### Compatibility

**With consuming projects:** nothing breaks. Numbering, metadata, statuses, and review-artifact conventions are unchanged, and **every `@ref` target form remains valid**: `LLP NNNN`, `LLP NNNN#anchor`, repo path to any file type (with or without anchor), project-defined shorthand (with or without anchor), and URL. Simplifying the spec's prose must never narrow its grammar. A project that adopted LLP yesterday needs zero edits.

**With today's models:** the kernel requires no frontier capability — a mid-tier model follows an `@ref`, fills a scaffold, and obeys a MUST list. The shell that today's models still benefit from (numbering recipe, context-pack shape, type scaffolds) is kept, marked, and homed in the corpus. What is deleted now fails the test in *both* directions — today's models don't need 216 lines to render a rationale view or 133 to grep headers either.

**With +2-generation models:** the kernel is what they consume — a corpus of decisions they cannot infer, a grammar for finding it, a lifecycle that keeps it true, and protocols (review, provenance, propose-don't-apply) that constrain *behavior*, not capability. The shell shrinks toward zero on the deletion criteria without a redesign.

## Alternatives considered

- **Do nothing.** Rejected: the corpus carries ~1,300 lines of machinery for problems that are shrinking, its statuses violate its own lifecycle rules, and the "planned" hedges are a standing credibility cost.
- **Delete the skill layer now.** Premature: slash-command affordances and pinned invariants measurably help today's models, and the layer is cheap once cut to contracts. The design makes it *deletable later* instead.
- **Collapse five skills into one router.** Re-litigates LLP 0008's settled trade for marginal gain; trigger clarity still matters for today's runtimes. Revisit only if A1 fully arrives and the AGENTS.md rule alone proves sufficient (Open question 2).
- **Shrink the type/status taxonomy** (e.g., merge `Superseded` into `Tombstoned`, trim the nine types). Rejected: metadata is cheap, the distinctions are real, and taxonomy churn would break consuming projects for aesthetic gain — exactly the trade the compatibility contract forbids.
- **Keep LLP 0005's review quota mandatory.** Rejected: the right amount of review is a function of stakes and of current model capability, and both move. A fixed quota over-taxes experimental prototypes and under-serves foundational architecture (which may deserve far *more* than two reviews — rounds until no substantive issues remain). The durable invariants are honesty, artifacts, and author authority; intensity is a dial the author sets.
- **Rewrite the spec as a one-pager.** Attractive, and the README already serves as the one-page view. Rejected as the *normative* form: retrofit provenance, review protocol, and attachment semantics need precision a one-pager can't carry.
- **Keep specifying `ref-check` instead of building it.** Rejected: the spec is larger than the program. Building is the simplification.

## Implementation plan

Each phase is independently landable and leaves the repo consistent.

**Phase 0 — honesty pass (one commit).** Correct statuses to obey the lifecycle: LLP 0000, 0004 → `Active` (they are the operating guidance); 0001, 0002, 0005 → `Active`; 0003 already `Active`. No content changes. *Done when:* every document's `Status` matches how the repo actually treats it.

**Phase 1 — document surgery.** Fold 0006 into 0000 §2 and tombstone it. Slim 0000: drop §6–8 detail (pending Phase 3's replacement, mark §6 with a one-line "being replaced by ref-check v1, see LLP 0009"), deduplicate the adoption sections down to a pointer at the merged guide, move the provenance kernel in. Merge 0001+0002 into `0001-adopting-llp.guide.md` (scaffold/retrofit structure); tombstone 0002. Revise 0008 down to its surviving decisions and move it toward acceptance. Revise 0005 per the review norm: honesty rules and artifact conventions stay normative; the multi-model loop becomes recommended technique, scaled to stakes by the author ("review until you're happy"). Add the two principles to 0004. *Done when:* no normative section describes unbuilt machinery; no document mandates a review quota; current-guidance docs (excluding Research and tombstones, including this RFC) total ≤ ~1,250 lines.

**Phase 2 — skill surgery.** Rewrite the five `SKILL.md`s in contract form (≤60 lines each, every MUST citing its LLP source by pinned upstream URL, informational `source:` pin in frontmatter). Delete `llp-list` and `ref-story`. Update the AGENTS.md managed block and README skill table. *Done when:* `skills/` totals ≤ ~300 lines and deleting it would cost only convenience.

**Phase 3 — the program.** Implement `ref-check` v1 (one file, stdlib-only) with the checks and exit codes above, plus one broken-ref fixture and a CI invocation for this repo. Replace 0000 §6 with the short normative description of the *built* checker. *Done when:* `ref-check` runs green on this repo, red on the fixture, and the words "planned but not yet implemented" appear nowhere in the corpus.

**Phase 4 — proof, not prose.** Adopt the slimmed system in one real, active codebase. Every remaining open question is empirical; further spec revision before usage data is procrastination with extra steps. *Done when:* a consumer repo has a corpus, refs, and at least one `llp-maintain` cycle behind it, and the findings are recorded as a Research LLP.

## Acceptance criteria

| Measure | Today | Target |
|---|---|---|
| Current-guidance corpus (docs excl. Research + tombstones, incl. this RFC) | ~1,920 lines | ≤ ~1,250 |
| Skill layer | 866 lines / 7 skills | ≤ 300 lines / 5 skills |
| Normative sections describing unbuilt tooling | ~300 lines | 0 |
| Documents whose `Status` is accurate | 2 of 9 | all |
| Deterministic checks that actually run | 0 | `ref-check` v1 in CI |
| Kernel readable end-to-end | — | one sitting (≤ ~20 minutes) |

Sizes are rerunnable, not vibes: `wc -l llp/[0-9]*.md skills/*/SKILL.md`, minus the Research doc (`0003`) — `llp/tombstones/` and `llp/reviews/` fall outside the glob. Refresh the numbers after each phase.

## Open questions

1. **Numbering under concurrency (A4).** Parallel agent fleets will collide on `max + 1`. Convention to pick when it first happens: renumber-on-merge (cheap, since anchors — not numbers — carry most references' meaning) vs. reserving ranges per branch. Defer until observed.
2. **Does `llp-orient` eventually collapse into the one-line rule?** Measurable: when frontier runs reliably orient from the AGENTS.md sentence alone (compare context packs with and without the skill installed), the skill becomes a deletion candidate. Until measured, it stays.
3. **`ref-check` runtime.** Stdlib Python vs. single-file Node/Deno — pick at build time for whatever this repo and likely consumers already have; the constraint is "one file, no installs," not the language.
4. **Where does the shell's deletion log live?** Lightest viable answer: the owning document's git history plus a line in its `Revised` metadata. Anything heavier contradicts this RFC.
5. **Is `Accepted` worth keeping as distinct from `Active` once agents implement designs within hours of acceptance?** Lean yes (the gap still exists for humans deciding *whether* to build), but revisit with usage.
6. **Where do shorthand mappings live?** The grammar retains `SPEC#anchor`-style project shorthands for compatibility, but no mapping format has ever been defined (LLP 0008 deferred `llp.json`). `ref-check` v1 therefore skips unmapped shorthands rather than failing them. Define the mapping's home the first time a real project needs one — not before.

## Addendum (2026-07-23): LLP 0010 supersedes the distribution classification

[LLP 0010](./0010-skill-install-super-refine-ship.rfc.md), motivated by an *observed* failure (this repo's own `llp-maintain` skill drifted from the `v0.2.0` tag it pins), makes distribution first-party: `llp-adopt` gains an install step and update mode backed by tagged releases and per-installation receipts, and the skill set grows to seven as core-plus-flags (`llp-super-refine`, `llp-ship`). This supersedes the classification above of distribution machinery as absent shell — the receipts design is far smaller than the cut `llp-spec:` vendoring machinery, and the `source:` pin stays informational. The capability test, the ≤60-line contract form, the five-skill *core*, and everything else in this RFC stand. Phase 4 (real-consumer evidence, recorded as a Research LLP) remains the open proof obligation; LLP 0010 OQ5 names install receipts and run telemetry as its data sources.

## Addendum (2026-06-10): Phases 0–3 implemented

The author accepted this RFC after one GPT-family review round plus the author's own pass — a deliberate application of the review norm it introduces (foundational change, one substantive round, revise, accept). Phases 0–3 landed the same day: statuses corrected; LLP 0000 slimmed and made `Active` (0006 folded in and tombstoned); LLP 0001 and 0002 merged into the adoption guide (0002 tombstoned); LLP 0004 gained the two principles; LLP 0005 revised to the stakes-scaled review norm; LLP 0008 revised down to its surviving decisions; the five skills rewritten as contracts with pinned-URL citations; `llp-list` and `ref-story` deleted; `ref-check` v1 built with a broken-ref fixture and CI. Phase 4 — adoption in a real, active codebase, recorded as a Research LLP — is the open proof obligation.
