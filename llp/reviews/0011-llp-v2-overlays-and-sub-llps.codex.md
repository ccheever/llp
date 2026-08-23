# Reviews of LLP 0011 + LLP 0011.000 — GPT (Codex) family

Lockstep cluster (RFC + its curation-pass guide). Every round section is the reviewer's output verbatim; orchestrator notes are marked as such.

## Round 1 — 2026-08-22

**Provider / runtime:** OpenAI Codex CLI (`codex-cli 0.149.0`), model `gpt-5.6-sol`, reasoning effort `ultra` (`-c model_reasoning_effort=ultra`), sandbox `read-only`
**Method:** cli-runner (`codex exec -C <capsule> --skip-git-repo-check`, non-interactive; prompt told it not to look for `llp/reviews`). Exit 0; body from `-o`.
**Revision reviewed:** commit `ceafa66`; 0011 sha256 `14d25242728854ee02b0ff6b2918b827b4a55dffa3b50f45d2b467eb894e581c`, 0011.000 sha256 `53d1d7efad64cec51871babcab61c83961441f38897e12bc3a89f9042c37d59d`; capsule `a6836bf5644b85333634e5b1c196d7bd9eb15c16ce81ec4a7202038252015589` (tree minus `llp/reviews/`, plus `OVERLAYS.txt`); instructions sha256 `b3e6607b8f1eb3b951a3b67500d2ba53a4a3f90eb6be7cb94d411574612569b8`.
**Blindness:** structural — the capsule contained no review artifacts. Same instructions to both families; altitude rule included.

### Review (verbatim)

## Summary

The proposal has a strong conceptual decomposition: dotted identities, attention separate from lifecycle, and promote → archive → realign are valuable foundations. However, the foundation predicate, `current/` semantics, and symlink-only representation do not work consistently under the parallel, cross-platform environments the governing documents assume. Filesystem lifecycle, compatibility, allocation, and adoption rules also contain unresolved contradictions. The checker passes this capsule and rejects the supplied fixture as expected, but that does not resolve these decision defects.

## Concerns

1. **Severity:** MATERIAL · **Target:** both · **Claim:** The foundation admission test cannot deterministically select the kernel on which realignment depends. · **Evidence:** `llp/0011-llp-v2-overlays-and-sub-llps.rfc.md` §Design / Overlays asks whether deletion makes the project “unrecreatable” with code intact; `llp/0011.000-curation-pass.guide.md` §Promote broadens this to losing “something unrecoverable,” while asserting RFCs usually fail. `llp/0009-capability-invariant-core.rfc.md` §Design / The kernel says rationale and rejected alternatives are precisely unrecoverable from code, so unique RFCs pass the latter test; if reconstruction means executable behavior, intact code makes nearly every document fail. Pairwise retesting is also unsafe for overlapping documents because both may be proposed for removal while the other still exists. · **Resolution criteria:** Define exactly what must be reconstructable, whether historical rationale counts, and how dependencies and redundancy are evaluated; require the proposed final foundation set to be collectively sufficient; provide decisive examples covering an RFC, a current-truth spec, overlapping documents, and LLP 0005.

2. **Severity:** MATERIAL · **Target:** 0011.000 · **Claim:** Foundation-only realignment can knowingly contradict another binding `Active` document. · **Evidence:** `llp/0011.000-curation-pass.guide.md` §Realign calls foundation “the truth,” forbids realignment against anything outside it, yet concedes that a non-foundation `Active` spec remains binding. No promotion or realignment step checks whether that spec contradicts foundation or defines which one wins. · **Resolution criteria:** Before proposing code changes, check prospective foundation claims against all binding `Active` normative documents; reconcile, fold, update, or supersede conflicts, or define an explicit precedence rule.

3. **Severity:** MATERIAL · **Target:** both · **Claim:** `current/` cannot satisfy its stated global attention predicate. · **Evidence:** `llp/0011-llp-v2-overlays-and-sub-llps.rfc.md` §Design / Overlays says membership holds iff someone is thinking about a document and prescribes `rm` when a conversation ends; `llp/0011.000-curation-pass.guide.md` §Archive repeats that model. Under the parallel-agent assumption in `llp/0009-capability-invariant-core.rfc.md` §Model assumptions, one worker can remove the single link while another remains active, and branch-local links are invisible elsewhere. Banning `Superseded` documents also prevents representing active migration work, recoupling attention to truth status. · **Resolution criteria:** Define the authoritative scope and ownership, lease, or multi-worker removal semantics, including branches and worktrees; alternatively redefine `current/` as a versioned, curated working set rather than an exact statement of live attention.

4. **Severity:** MATERIAL · **Target:** 0011 · **Claim:** Symlink-only overlays lack a portable canonical representation. · **Evidence:** `llp/0011-llp-v2-overlays-and-sub-llps.rfc.md` §Design / Overlays makes relative symlinks the only representation, and `skills/llp-create/SKILL.md` §Invariants hard-codes `ln -s`. Relative links survive repository relocation, but checkouts that materialize symlinks as ordinary files and transports that strip them lose or invalidate membership; `ref-check`’s overlay block rejects ordinary files. No supported-platform boundary or synchronized fallback is defined. · **Resolution criteria:** Define a portable canonical representation with symlinks as an optional view, or explicitly constrain supported transports and provide deterministic reconstruction, validation, and actionable preflight diagnostics.

5. **Severity:** MATERIAL · **Target:** 0011 · **Claim:** The corpus retention and physical-layout contract is internally contradictory. · **Evidence:** `llp/0011-llp-v2-overlays-and-sub-llps.rfc.md` §Summary says every LLP remains directly under `llp/` “forever,” and §Flat corpus calls the corpus “flat and append-only,” then immediately permits subdirectories. `llp/0000-linked-literate-programming.explainer.md` §Living documents explicitly permits deletion and rejects append-only records. Deleting a parent also orphans surviving children despite their claimed independent lifecycles, while deleting the highest child lets the tree-based allocator reuse its number. · **Resolution criteria:** Choose one precise retention/layout contract. If deletion remains allowed, retract “forever/append-only,” preserve retired allocations, and define ancestor deletion; if permanence is intended, remove the governing deletion rule and enforce true flatness consistently.

6. **Severity:** MATERIAL · **Target:** 0011 · **Claim:** The blanket backward-compatibility claim is false. · **Evidence:** `llp/0011-llp-v2-overlays-and-sub-llps.rfc.md` §Summary says every v1 `@ref` keeps working, while §Compatibility moves files out of `llp/tombstones/`. Repo-path references are valid target forms under `llp/0000-linked-literate-programming.explainer.md` §Reference syntax, so `@ref llp/tombstones/<file>` and ordinary relative Markdown links break. Previously permitted grouping directories named `current/` or `foundation/` also become reserved and cease validating as ordinary document directories. · **Resolution criteria:** Either preserve legacy paths through compatibility links/non-semantic directories, or narrow the claim and specify a checked migration that rewrites path references, Markdown links, and reserved-name collisions.

7. **Severity:** MATERIAL · **Target:** 0011 · **Claim:** Fixed-at-birth child identity is incompatible with the specified allocator under parallel creation. · **Evidence:** `llp/0011-llp-v2-overlays-and-sub-llps.rfc.md` §Sub-LLP numbering requires creation-order, never-reused identities fixed at birth; `skills/llp-create/SKILL.md` §Invariants uses tree-local `max + 1`. `llp/0009-capability-invariant-core.rfc.md` §Open questions acknowledges branch collisions, while LLP 0010’s ship plan serializes only within one invocation. Two agents can therefore both create `P.000`, and merge repair necessarily changes an identity or violates uniqueness. · **Resolution criteria:** Define atomic reservation, or declare branch identities provisional until integration and specify deterministic collision renumbering with complete reference rewriting.

8. **Severity:** MATERIAL · **Target:** 0011 · **Claim:** Fresh adoption has no conforming bootstrap state. · **Evidence:** `llp/0000-linked-literate-programming.explainer.md` §Filesystem organization says the root is always in foundation, while §Current and foundation requires foundation entries to be `Active`. `skills/llp-adopt/SKILL.md` §Invariants requires every generated document—including a new root—to remain `Draft`, and its Workflow and Artifact do not create the overlays or root link. `skills/llp-orient/SKILL.md` assumes they exist, while `ref-check` silently skips absent overlay directories. · **Resolution criteria:** Define the Draft-root bootstrap and v1-to-v2 opt-in state, then align adoption, README quick start, orientation, and validation so a fresh installation either conforms or fails clearly.

9. **Severity:** DETAIL · **Target:** context(0000/ref-check/skill) · **Claim:** The advertised deterministic gates have concrete fail-open cases. · **Evidence:** In `ref-check`’s `parse_target`, malformed LLP-shaped inputs such as `LLP 0011.00` or `LLP 10000` fail the LLP regex and are treated as unchecked shorthand `LLP`, not errors. Its overlay block also accepts absolute symlinks despite the relative-only rule. The supplied broken-ref fixture tests valid dotted syntax and missing targets, not these malformed forms. · **Resolution criteria:** Reserve the `LLP` prefix so malformed LLP-shaped references fail, reject absolute overlay links, and add isolated fixture assertions for both cases.

10. **Severity:** DETAIL · **Target:** 0011.000 · **Claim:** The contract/recipe boundary is misleading. · **Evidence:** `llp/0011.000-curation-pass.guide.md` §Summary calls everything following the governing rules “recipe,” but later states correctness-bearing imperatives such as fixed order, propose-only behavior, and foundation-only realignment without the advisory marker. `skills/llp-maintain/SKILL.md` §Invariants elevates those rules to MUSTs, although LLP 0009 says policy must not live only in skills. · **Resolution criteria:** Home the minimal curation contract normatively—ordering, propose-only posture, conflict safety, and realignment scope—and visibly mark cadence, heuristics, and output formatting as advisory.

## Strengths

- Keep the sortable `NNNN(.NNN)*` grammar, full-number identity, parent-existence check, and prohibition on re-parenting.
- Keep the conceptual separation between correctness status and project attention, after tightening the definition of attention.
- Keep fold-before-link and promote → archive → realign; that order appropriately prevents realigning against a knowingly stale foundation.
- Keep deterministic checks separate from judgment-bearing maintenance. The supplied fixture correctly exercises dotted references, missing parents, overlay status violations, and broken targets.

## Verdicts

0011 — NOT READY. Capsule hash `a6836bf5644b85333634e5b1c196d7bd9eb15c16ce81ec4a7202038252015589` has unresolved MATERIAL concerns in overlays, lifecycle, compatibility, allocation, and adoption.

0011.000 — NOT READY. Capsule hash `a6836bf5644b85333634e5b1c196d7bd9eb15c16ce81ec4a7202038252015589` has unresolved MATERIAL concerns in foundation selection, attention archiving, and conflict-safe realignment.

Set — NOT READY. Capsule hash `a6836bf5644b85333634e5b1c196d7bd9eb15c16ce81ec4a7202038252015589` does not yet define a coherent, portable, concurrency-safe corpus-and-curation contract.
## Round 2 (delta round) — 2026-08-22

**Provider / runtime:** as round 1.
**Method:** as round 1, plus: received `DELTA.diff` (ceafa66→c46cdd2) and this family's own round-1 punch list only.
**Revision reviewed:** commit `c46cdd2` (r2); 0011 `fb859be2fd25a3e21cc801f93ded5ce803860495bd9be274695cc02f88193c09`, 0011.000 `5b764484eaac460c092895d1e6b9d4480c777676467fb5c58d4a14ea90d48087`; capsule `214b70aed287970243017f7215fd2d2cd3507ac47de306f448edefff08c99a0c`.

### Review (verbatim)

## Punch list verification

1 · VERIFIED · LLP 0000 and 0011.000 define design recreation, set-level removal testing, the too-small failure, and worked examples.

2 · PARTIAL · The broad conflict rule landed, but 0011.000 narrows its procedure to selected document types outside foundation.

3 · PARTIAL · Declared-working-set semantics and `Superseded` support landed, but 0011.000 retains the former attention predicate and overlay ban.

4 · PARTIAL · The checker and fixture accept path-content files, but AGENTS.md and `llp-orient` still require symlinks.

5 · PARTIAL · Deletion, permanent allocation, parent retention, and grouping rules landed, but `llp-create` can reuse a deleted highest number.

6 · PARTIAL · Compatibility discloses reserved-name collisions, but 0011 still calls tombstone migration “the only break.”

7 · PARTIAL · Renumber-on-integration is specified, but Active LLP 0009 and LLP 0010 still describe the choice as unresolved.

8 · PARTIAL · The Draft-root bootstrap exists, but the public quick start and skill text remain contradictory or nonconforming.

9 · VERIFIED · Malformed `LLP` targets and absolute overlay links are rejected, and the fixture exercises both successfully.

10 · PARTIAL · The contract and explicit When/Output recipe markers landed, but other how-to mechanics remain only blanket-classified as recipe.

## Concerns

1. **Severity:** MATERIAL · **Scope:** IN-DELTA · **Target:** 0011.000 · **Claim:** The conflict check is narrower than its governing contract. · **Evidence:** `llp/0000-linked-literate-programming.explainer.md`, “Current and foundation,” requires checking “every other binding `Active` normative document”; `llp/0011.000-curation-pass.guide.md`, “Realign,” limits the search to “specs, decisions, principles outside foundation,” reinforced by step 5’s “non-foundation `Active` spec.” · **Resolution criteria:** Cover all binding Active normative content, inside and outside foundation, with document types explicitly non-exhaustive.

2. **Severity:** MATERIAL · **Scope:** IN-DELTA · **Target:** 0011.000 · **Claim:** Archive still implements the superseded live-attention and overlay rules. · **Evidence:** `llp/0011.000-curation-pass.guide.md`, “Archive,” says current contains “exactly what someone is thinking about” and that “Tombstoned and Superseded documents can't be in either overlay”; “Anti-patterns” repeats “what's being thought about.” · **Resolution criteria:** Use declared-working-set language throughout; prohibit Tombstoned from both overlays while permitting Superseded in current during migration.

3. **Severity:** MATERIAL · **Scope:** IN-DELTA · **Target:** context(AGENTS.md, skills/llp-orient/SKILL.md) · **Claim:** Always-loaded and orientation guidance rejects the new portable overlay representation. · **Evidence:** LLP 0000, “Representation,” permits a symlink or path-content file; AGENTS.md, “LLP documents,” says “relative symlinks only,” and `llp-orient`, “Workflow,” calls both overlays “symlink directories.” · **Resolution criteria:** Describe overlays consistently as relative links and teach orientation to follow path-content files.

4. **Severity:** MATERIAL · **Scope:** IN-DELTA · **Target:** context(skills/llp-create/SKILL.md) · **Claim:** The shipped allocator violates permanent allocation after deletion. · **Evidence:** LLP 0000, “Numbering,” requires consulting history for deleted numbers; `llp-create`, “Invariants,” derives `max(existing)+1` from the current tree, while its recipe uses non-recursive `ls llp`. · **Resolution criteria:** Allocate against repository history or another durable allocation record, recursively accounting for grouping directories.

5. **Severity:** MATERIAL · **Scope:** IN-DELTA · **Target:** 0011 · **Claim:** The compatibility summary still makes a false single-break claim. · **Evidence:** `llp/0011-llp-v2-overlays-and-sub-llps.rfc.md`, “Summary,” calls tombstone migration “the only break”; “Compatibility” separately requires v1 `current/` or `foundation/` grouping directories to be renamed. · **Resolution criteria:** State both migration breaks consistently or narrowly qualify the single-break claim.

6. **Severity:** MATERIAL · **Scope:** IN-DELTA · **Target:** context(llp/0009-capability-invariant-core.rfc.md, llp/0010-skill-install-super-refine-ship.rfc.md) · **Claim:** Active governing documents leave branch allocation simultaneously settled and open. · **Evidence:** LLP 0000, “Allocation on branches,” mandates renumbering the later-integrated document; LLP 0009, “Open questions,” says to choose later and “Defer until observed”; LLP 0010, “Plan phase,” says cross-invocation collisions remain that open problem. · **Resolution criteria:** Mark LLP 0009’s question answered by LLP 0011 and update LLP 0010’s stale reference.

7. **Severity:** MATERIAL · **Scope:** IN-DELTA · **Target:** context(README.md, skills/llp-adopt/SKILL.md, skills/llp-orient/SKILL.md) · **Claim:** Advertised bootstrap paths remain inconsistent with the new root-overlay lifecycle. · **Evidence:** README.md, “Quick start,” creates an `Active` root without a foundation link; `llp-adopt`, “Artifact,” describes current as both empty and containing the root link; `llp-orient`, “Workflow,” says the root is always in foundation despite Draft bootstrap. · **Resolution criteria:** Make Quick start conform, state that only foundation is initially empty, and teach orientation to find a Draft root in current.

8. **Severity:** DETAIL · **Scope:** IN-DELTA · **Target:** 0011.000 · **Claim:** Mixed contract and recipe mechanics are not locally classifiable at a glance. · **Evidence:** LLP 0004, “Contracts over recipes,” requires visibly marked advisory how-to; `llp/0011.000-curation-pass.guide.md`, “Promote” and “Realign,” contain procedural mechanics outside recipe blocks despite only a blanket statement in “Summary.” · **Resolution criteria:** Mark non-contract procedures locally or split contract restatements from recipe steps.

9. **Severity:** DETAIL · **Scope:** IN-DELTA · **Target:** 0011.000 · **Claim:** A new worked example gives LLP 0009 the wrong status. · **Evidence:** `llp/0011.000-curation-pass.guide.md`, “Promote,” says “0009 fails (accepted…)”; `llp/0009-capability-invariant-core.rfc.md` has `Status: Active`. · **Resolution criteria:** Change the example to identify LLP 0009 as Active.

## Verdicts

0011: NOT READY — Capsule `214b70aed287970243017f7215fd2d2cd3507ac47de306f448edefff08c99a0c` retains unresolved MATERIAL compatibility and integration-coherence defects.

0011.000: NOT READY — Capsule `214b70aed287970243017f7215fd2d2cd3507ac47de306f448edefff08c99a0c` retains unresolved MATERIAL conflict-scan and archive-rule defects.

Set: NOT READY — Capsule `214b70aed287970243017f7215fd2d2cd3507ac47de306f448edefff08c99a0c` is not coherent across the targets and governing context while these MATERIAL concerns remain.
