# Reviews of LLP 0010 — Claude (Fable) family

## Round 1 — 2026-07-22

**Reviewer family:** Claude
**Provider / runtime:** claude-code fresh general-purpose sub-agent, model `claude-fable-5`, max effort (inherited from orchestrating session)
**Date:** 2026-07-22
**Redacted:** no (nothing to redact; repository markdown only)
**Method:** sub-agent (fresh session; did not author or revise the draft)
**Revision under review:** `llp/0010-skill-install-super-refine-ship.rfc.md`, sha256 `189b502b7705755e9483714ab69bf9d6990e289a2e98f0b34566fa030e8ff3f7` (untracked; pre-first-commit draft)

The review body below is preserved verbatim.

---

# Review: LLP 0010 — Installed Skills, Super-Refine, and Ship

**Reviewer family:** Claude (Claude Fable 5, fresh session, did not author the draft)
**Date:** 2026-07-22
**Documents read:** LLP 0010 (full), LLP 0004, 0005, 0008, 0009, all five `skills/*/SKILL.md`, README.md, AGENTS.md, `ref-check`, `llp/reviews/`, `llp/tombstones/`, git tags (`v0.2.0`)

---

## 1. Overall assessment

This is a well-constructed RFC that extends a deliberately minimal system in three directions, and it mostly earns each extension on the system's own terms. The strongest part is the argument for `llp-update-skills` as a separate skill (§1, "This is deliberately a skill of its own") — the posture argument (never-applies vs. applies-after-approval) is exactly the kind of invariant-boundary reasoning LLP 0008/0009 established, and wedging an applying intent into `llp-maintain` really would weaken that skill's defining line. The three-way fork check is the right core mechanism for the update loop. Super-refine's honesty scaffolding (fresh mutually-blind sessions, per-family artifacts, stop-don't-substitute) is faithful to LLP 0005 and in places stronger than it.

Three things keep it from ready: the `Draft` → `Review` convergence transition misreads LLP 0005's own status semantics; the super-refine loop has no termination or disagreement-escalation rule (and the external-send authorization for later rounds is unstated); and `llp-ship`'s push-to-main *default* is defended for the authoring repo but will be distributed, via the very install loop this RFC builds, into repos whose maintainers never read the defense. All three have cheap resolutions.

## 2. Strengths

- **The update-skills separation argument (§1, ¶"This is deliberately a skill of its own").** Three independent reasons (trigger clarity, posture, frequency), each grounded in a prior decision — the posture reason correctly identifies that `llp-maintain`'s "never applies" line (LLP 0008 §The five skills; `skills/llp-maintain/SKILL.md` invariant 1) is load-bearing for its four-mode design and must not be diluted. This is the RFC at its best.
- **The three-way check (§1, Update step 3).** Diffing installed-copy vs. *pinned* upstream before proposing anything, and treating divergence as "the project owns it now," is the correct fork-safety semantics and extends LLP 0008's "never overwrite a skill you didn't write" rule naturally.
- **Honesty plumbing in super-refine (§2, ¶2).** Fresh reviewer sessions per round, reviser ≠ reviewer, verbatim bodies with provenance and orchestrator notes kept outside them, appended dated round sections, and hard-stop on family unavailability — all consistent with LLP 0005 §Honesty rules and §Review artifacts, and the stop-rather-than-substitute rule is a genuinely good tightening.
- **Ship's invariant list (§3, Invariants).** These are precisely the "behavioral protocols that appreciate with capability" LLP 0009 says to pin (A5, A6): no fabricated verification, no sole self-review, no force-push with a stated fallback, cleanup on failure, don't touch unrelated state, honest per-task reporting. This passes the capability test where the surrounding workflow prose is shell.
- **Alternatives are handled honestly (§1 Alternatives).** Symlinks, plugin marketplace, and submodules are each dispatched with reference to prior decisions rather than re-litigated.
- **Consequences and co-evolution (§Consequences).** Deferring the LLP 0008/README/AGENTS.md revisions to land with the implementation, not the RFC, is correct LLP 0004 practice, and demoting `exact` to a consumer closes a real ownership loop.
- **Open question 5 (lockstep context size)** shows the author already sees the main scaling risk in the multi-document design.

## 3. Concerns

### C1. The `Draft` → `Review` convergence transition contradicts LLP 0005's status semantics — MATERIAL (coherence)

**Evidence.** §2 says: "Convergence authorizes exactly one status transition: `Draft` → `Review`." But LLP 0005's lifecycle table defines `Review` as "The author has opted this document into a formal review loop," and §Lifecycle says setting `Review` **is** the opt-in. Under those semantics the opt-in moment is *invocation* of super-refine, not convergence — a document that has just been declared ready by two independent families and then gets stamped `Review` reads to every future reader as "currently under review," the opposite of its actual state. The transition is also in tension with `skills/llp-review/SKILL.md` ("MUST NOT change `**Status:**`") and LLP 0005's "no tool changes `Status` unilaterally" — the RFC's implicit defense (explicit human invocation = authorization) is plausible but never stated.

**Resolution.** Pick one and say it explicitly: (a) invocation sets `Draft` → `Review` (invocation is the opt-in per LLP 0005), and convergence *proposes* `Accepted` to the author — this is the reading most coherent with the existing corpus; (b) status stays `Draft` throughout and convergence produces only a readiness report; or (c) revise LLP 0005's status semantics in the same change. In all cases, state where the human-authorization for a status write comes from.

### C2. Push-to-main as the distributed default — MATERIAL (safety / decision-quality)

**Evidence.** §3 defaults `llp-ship` to pushing the merged result to `origin main`, defended in §3's closing paragraph as "a deliberate author choice for solo-maintainer repos." The defense is coherent *for this repo*. But §1 of the same RFC builds the machinery that installs these skills, unmodified, into arbitrary consuming repos — and §Consequences puts `llp-ship` in the standard eight-skill set that `llp-adopt` offers to install. A team repo therefore receives, by default, a skill whose default is merging multiple lanes of agent-written, agent-reviewed code directly to shared `main`. The mitigations (`--no-push`, branch-protection fallback) both require the invoker to already know the risk. Defaults travel; RFC prose does not.

**Resolution.** Any of: make push destination/behavior a per-repo setting written at install time (with `llp-adopt` asking once — solo repos answer "push," teams answer "PR"); or default to push only when the repo shows solo-maintainer signals (single author in `git log`, no branch protection) and to PR otherwise, stating which was chosen; or require a one-time confirmation on first push in a given repo. The RFC just needs to move the choice from "flag the invoker must remember" to "decision the repo makes once."

### C3. Super-refine has no termination or disagreement rule, and round-N external sends are unauthorized on paper — MATERIAL (feasibility / process safety)

**Evidence.** §2 loops "until both families independently mark the same revision ready," and the cross-consistency pass can trigger further rounds whose revisions can re-trigger siblings. Nothing bounds the loop, and nothing says what happens when the two families make *contradictory* material demands (a real occurrence in multi-family review) — the orchestrator "revises to address material concerns" cannot satisfy both. Separately, LLP 0005 §Honesty rules: "Sending content to an external model is an explicit human action, never automatic." One human invocation plausibly authorizes the whole loop, but the RFC never says so — and round 6's Codex call is otherwise automatic by the letter of the rule. Finally, "mark the same revision ready" presupposes a verdict the reviewers emit, but no verdict protocol is defined (LLP 0005's standard prompt asks eight questions and no readiness verdict).

**Resolution.** Add three sentences: a round cap or budget with escalate-to-author on non-convergence; an explicit rule that cross-family contradictions are surfaced to the author rather than resolved by orchestrator fiat; and a statement that invoking `/llp-super-refine` constitutes the LLP 0005 human authorization for all rounds' external sends (with redaction still default). Define the verdict format (e.g., a required final `READY` / `NOT READY` line in each review body) so convergence is a checkable fact, not an interpretation.

### C4. "The seven skills" — NON-BLOCKING (internal inconsistency)

**Evidence.** The Summary says the system grows "from five skills to eight"; §1 says `llp-adopt` "offers to install the seven skills." Presumably eight minus `llp-adopt` itself (or minus something else) — but it's never said, and a reader implementing the install step can't know which skill is excluded or why. **Resolution:** state the number and the exclusion rationale, or just say "the skill set."

### C5. The frequency justification for `llp-update-skills` is asserted, not observed — NON-BLOCKING (decision-quality)

**Evidence.** §1: "it runs often, in every consuming repo" — but nothing installs skills into any consuming repo today (that's this RFC's point), so frequency is a prediction. Open question 1 then pre-exempts `llp-update-skills` from future consolidation *on the basis of* that predicted frequency, which is circular. LLP 0009 Phase 4 (real-consumer usage data) remains an open proof obligation. The other two justifications (trigger clarity, posture) stand on their own, so this doesn't sink the decision. **Resolution:** rest the promotion on posture + trigger clarity, and let open question 1 treat update-skills like every other skill — consolidation candidates come from observed usage, no pre-exemptions.

### C6. Update-fetch mechanics are hand-waved — NON-BLOCKING (feasibility)

**Evidence.** §1 step 2 names `git ls-remote --tags` (lists tags only); steps 3–4 require *content* at both the pinned tag and the newest tag, which needs raw-URL fetches, a shallow clone, or a tarball — plus defined behavior offline or when a tag has vanished upstream. Under 0008's "skills orchestrate; the harness computes" this is legitimately improvisable, but the offline/missing-tag *behavior* (degrade to "cannot verify, will not write" rather than guess) is an invariant, not a recipe, and should be stated. A lighter option worth one line: record a content hash at install time so fork detection (step 3) needs no network at all.

### C7. Ship's "independent review" is thinner than it sounds — NON-BLOCKING

**Evidence.** §3: the reviewing session is fresh but same-family, and the *orchestrator that planned the work* adjudicates which findings are "material" and fixed before merge — reviewer advises, interested party decides, then pushes (see C2). Proportionate for code at these stakes, and consistent with stakes-scaling, but the RFC should say plainly that this is same-family review and that the review artifact (does one exist? where?) records findings and their dispositions so "material findings are fixed" is auditable rather than asserted.

## 4. Suggestions

1. **Pin the skill *set*, not just per-skill files.** Skills reference each other by name in hand-offs; per-skill pins allow mixed-version installs (e.g., `llp-maintain` from a tag before `llp-update-skills` existed, handing off to a skill that isn't installed). Have `llp-update-skills` treat the installed set as one unit at one tag, updating atomically, with per-skill forks excluded and flagged.
2. **Make convergence machine-checkable.** A required verdict line in each review artifact (as in C3) means the loop's exit condition, the artifact trail, and even a future `ref-check`-grade audit ("does every family artifact's last round say READY for the revision hash the doc now carries?") all become deterministic.
3. **Add a brief implementation plan.** LLP 0005 §Authoring workflow lists it for RFCs of this size, and the three parts have obviously independent phases (install/update is pure plumbing; super-refine is a port from `exact`; ship is the riskiest and could land last, or behind its own acceptance). Relatedly, consider whether the three parts should be separable at acceptance time — a reviewer could reasonably want parts 1–2 `Accepted` and part 3 iterated; a one-line note on whether the RFC accepts as a unit would pre-empt that.
4. **Give ship's model-facing defaults an "Alternatives considered" line.** PR-by-default was clearly considered (the fallback rule proves it) but never weighed in writing; §1 got an Alternatives paragraph and §3 didn't.
5. **State where the super-refine model pins live.** LLP 0008 open question 2 says config should "name model *families*, never pinned model IDs." §2 says families are named with "current pins recorded as the instantiation" — if the pins (`gpt-5.6-sol`, effort levels) live in the ≤60-line SKILL.md, they'll rot with every frontier release; the RFC (a living doc) or a project config is the better home, with the skill naming only families.
6. **Soften "on success *and* on failure or abort"** (§3 invariant 4) to something enforceable: a killed session cannot clean up. E.g., "MUST clean up on any path it controls, and MUST use identifiable worktree/branch names (`llp-ship/*`) so orphans from interrupted runs are discoverable and reclaimed on the next invocation."

## 5. Open questions

Beyond the RFC's own five (which are good, especially 2 and 5):

1. What is the reviewer verdict protocol, and is convergence defined against a specific revision (commit hash / `Revised:` date) so "both families marked *the same revision* ready" is well-defined? (C3)
2. Who authorizes the status write at convergence, and which transition is it? (C1)
3. Does `llp-adopt` install into project scope (`.claude/skills/`) or offer user scope too — and does the install default differ, given 0008's "project-local may proceed more freely" rule?
4. When the base branch moves under a long-running ship invocation (human pushes mid-run), what is the merge-back rule — rebase lanes, merge, or stop and ask?
5. Should `llp-ship` refuse or warn when a lane's diff touches files with `@ref`s whose governing LLPs weren't in its orient pass — i.e., is orient-first per lane an invariant or a recipe?
6. For repos without Linear/tickets, is free-text task input required to be restated back to the human before execution begins (a cheap misunderstanding gate the plan phase implies but doesn't require)?

## 6. Readiness verdict

**NOT READY** — the design is fundamentally sound and the additions are justified, but C1 (a status transition that contradicts LLP 0005's own semantics), C2 (a push-to-main default that will be distributed into repos that never saw its justification), and C3 (an unbounded refine loop with no disagreement-escalation rule and an unstated external-send authorization) are unresolved MATERIAL coherence, safety, and feasibility concerns — each resolvable with a few sentences of revision.

---

## Round 2 — 2026-07-22

**Reviewer family:** Claude
**Provider / runtime:** claude-code fresh general-purpose sub-agent, model `claude-fable-5`, max effort (inherited from orchestrating session)
**Date:** 2026-07-22
**Redacted:** no (nothing to redact; repository markdown only)
**Method:** sub-agent (fresh session; did not author or revise the draft; instructed not to read `llp/reviews/0010-*`)
**Revision under review:** `llp/0010-skill-install-super-refine-ship.rfc.md`, sha256 `75929b35dcb327ba3af8c87b173340922718cfaa9e0103a1ee039c431a411fe3` (post-round-1 revision)

Orchestrator verification notes (outside the verbatim body): the reviewer independently re-verified the `llp-maintain`-diverged-after-`v0.2.0` claim in git history (consistent with round 1's check). C1's factual premises confirmed: `llp-adopt`'s contract does apply changes, and the revised §1 does assign adopt the receipt-bootstrap and migration duties C1 cites. C6's premise (this document is under a formal dual-family loop while still `Draft`) is accurate as of this round.

The review body below is preserved verbatim.

---

# Review: LLP 0010 — Installed Skills, Super-Refine, and Ship

**Reviewer:** Claude (Fable 5), fresh session; independent of prior review artifacts (none read)
**Target revision:** `llp/0010-skill-install-super-refine-ship.rfc.md` at working-tree HEAD (Revised 2026-07-22)
**Verified against:** LLP 0004, 0005, 0008, 0009; `skills/*/SKILL.md`; `README.md`; `AGENTS.md`; `ref-check`; git history (the Motivation's claim that `skills/llp-maintain/SKILL.md` diverged after the `v0.2.0` tag is accurate — commit `c52c4e8` post-dates the tag and touches exactly that file).

---

## 1. Overall assessment

This is a strong, unusually honest RFC. It closes a real gap (LLP 0008's distribution story genuinely stops at "copy the directory"), promotes a practice with field experience behind it (super-refine), and pins invariants for a workflow that is currently improvised every time (ship). The three-part independence claim is genuine — each section has its own trigger, invariants, artifacts, and acceptance criteria, and none depends on another. The document is disciplined about its own epistemics ("experiential, not yet measured"; "a prediction, not an observation") and about LLP 0005 boundaries: super-refine's carefully scoped `Draft → Review` delegation and its never-sets-`Accepted` line are exactly right, and ship's task gating and honesty invariants are the correct MUSTs.

The main weaknesses are decision-quality gaps in Part 1, both of the same shape: the RFC does not confront the lightest-weight alternative that its own governing principles demand it consider. It cites LLP 0008's "Modes instead of more skills" to defend `llp-update-skills` against being folded into `llp-maintain` — but never asks the more natural question, whether it is a mode of `llp-adopt`, which the RFC itself has doing update-shaped work in two places. And it introduces a release manifest whose value over git's native content addressing is never argued, in a corpus whose signature move (LLP 0009) was cutting exactly this kind of machinery.

## 2. Strengths

- **Honest problem statement with verifiable evidence** (Motivation). The "distribution is half-built" claim is checkable and true, and the RFC uses this repo's own pin-divergence (`llp-maintain` edited after `v0.2.0`) as evidence — I verified it in git history. Motivating machinery with an observed failure rather than a predicted one is exactly the standard LLP 0009 sets.
- **The receipt as trust root, not frontmatter** (§1, trust model). Correctly identifies that the self-declared `source:` pin cannot anchor updates, keeps it informational (consistent with LLP 0008/0009), and makes fork detection a local, no-network hash comparison. The never-clobber-a-fork rule (§1 step 3) is the right ownership semantics.
- **"Cannot-verify never degrades to guess"** (§1 step 5). This is the LLP honesty ethos correctly extended to the package-manager domain.
- **Super-refine's status semantics** (§2). The `Draft → Review` transition at loop start is well-argued (the document *is* factually under formal review from that moment, matching LLP 0005's definition), the narrowing of `llp-review`'s MUST NOT is explicit and delegation-noted rather than silently contradicted, and the skill never touching `Accepted` preserves "reviewers advise; the author decides."
- **Round protocol auditability** (§2). Hash-stamped round manifests, mutual blindness enforced by collecting both results before either artifact is written, mandatory verdict lines making convergence a checkable fact, and reviser ≠ reviewer — this turns LLP 0005's honesty rules into checkable structure. Families in the contract, model pins in the living RFC, resolves LLP 0008's open question 2 the right way around.
- **Bounded loops with author escalation** (§2, Bounds). Round budgets, contradiction surfacing instead of orchestrator fiat, and stop-on-redesign are the right failure modes for an autonomous refine loop.
- **Ship's invariant set** (§3). The six MUSTs target precisely the observed failure modes named in Motivation (fabricated verification, rubber-stamp self-review, orphaned worktrees, unauthorized publication). "Verification and review must cover the exact integrated commit that ships" and the ledger-before-create rule are the two that matter most and both are present. The same-family disclosure on ship's review — explicitly *not* claiming §2's cross-family guarantee — is exactly the kind of honesty about guarantees this corpus values.
- **Implementation plan in risk order with real acceptance tests** (Implementation plan). Clean-room install, forced non-convergence, push-rejection-ends-blocked, abort-preserves-commits — these are falsifiable, and phase 4's separability means ship's risk doesn't hold the rest hostage.
- **Open questions are the right ones** (OQ 1–6), especially OQ6 turning LLP 0009 Phase 4's proof obligation into a concrete data-collection question.

## 3. Concerns

**C1. `llp-update-skills` vs. an update mode of `llp-adopt` — the obvious alternative is never considered.** — **MATERIAL** (decision quality)
Evidence: §1's "Why a separate skill" argues separation only against `llp-maintain` (posture: never-applies vs. applies), citing LLP 0008's "Modes instead of more skills." But `llp-adopt` *does* apply — and the RFC itself assigns adopt two update-shaped jobs: missing receipt → "offer to bootstrap one by re-running `llp-adopt`" (§1, update step 1), and pre-RFC consumers "migrate by re-running `llp-adopt` from a current release (idempotent; shows diffs; reconciles the `AGENTS.md` managed block…)" (§1, core profile). If re-running adopt already performs a verified, diff-shown, receipt-writing, managed-block-reconciling update in those two cases, the standalone skill covers only the happy path of the same operation. Folding update into adopt (`/llp-adopt --update` or auto-detected via an existing receipt) would cut the always-loaded core from six skills to five, directly relieving OQ1's acknowledged skill-count pressure. The trigger-clarity argument ("update the skills" ≠ "set up LLP here") is real but is exactly what modes already handle for `llp-maintain`'s four intents.
Resolution: add this alternative to §1's Alternatives and either adopt it or reject it with an argument that addresses adopt's *existing* update duties — the current posture argument doesn't, because it contrasts the wrong skill.

**C2. The release manifest's marginal value over git's own content addressing is unargued — and this corpus's governing principles make that omission load-bearing.** — **MATERIAL** (decision quality)
Evidence: §1 proposes `skills/manifest.json` (per-file hashes, inventory, template version), a release discipline ("any commit that changes a skill file must be followed by a new tagged release before that state is installable"), and a `ref-check` release-validation mode (Consequences). But a git tag already resolves to a commit that content-addresses the exact tree; a shallow clone or archive of the tag *is* the verified content, and the manifest ships inside the very tag it attests, so it adds no integrity the tag lacks (there is no signature). The receipt — not the manifest — is what fork detection uses (§1 step 3). The manifest's genuine residual value (per-file raw fetch without git; explicit adds/removes/renames metadata) is never stated as the justification, and the Alternatives section considers symlinks, marketplaces, submodules, and a sync CLI but not "receipt-only, git-native verification, no manifest." LLP 0009's cuts table removed `llp-spec:` vendoring precisely for "solving a distribution problem at CI-grade rigor that exists at documentation-grade severity"; a hash manifest plus release-cadence obligation plus a new `ref-check` mode for eight markdown files sits close to the same line, and the RFC reconciles with that cut only implicitly (via "the pin stays informational").
Resolution: either (a) add the receipt-only/git-native alternative and reject it explicitly — e.g., "raw per-file fetch on runtimes without git is a supported channel, and the manifest is what makes it verifiable" would be a legitimate argument — or (b) drop the manifest and let the tag's tree be the release definition, keeping only the receipt. Also state plainly how this squares with LLP 0009's vendoring cut (the honest answer — writes into consumer repos raise the severity above documentation-grade — deserves one sentence in the trust-model paragraph).

**C3. Delivery policy is stored in the install receipt, which OQ4 admits may not be repo-local.** — **NON-BLOCKING** (acknowledged, but should be settled before Phase 1)
Evidence: §1 (delivery profile) records the `pr`/`direct` answer "in the receipt"; §3 reads "the mode comes from repo policy recorded at install time." But OQ4 concedes the receipt's home is unsettled and that user-global installs (Codex) mean one receipt cannot describe many repos — and delivery policy is inherently per-repo. A user-global receipt holding a `direct` delivery policy would be a safety-relevant misconfiguration.
Resolution: decide that delivery policy is always repo-local (wherever the receipt lands), or split policy from receipt. One sentence fixes it; Phase 1 writes receipts, so it should be decided at acceptance, not during Phase 4.

**C4. Ship's review findings have no specified durable home.** — **NON-BLOCKING**
Evidence: §3 says the independent review's "findings and their dispositions are recorded in the run report," but the run ledger lives "under the run's scratch area" (Plan phase) — ephemeral by construction — and no home for the run report is named. For `pr` mode the PR description is a natural answer; for `direct` and `local` modes there is none. The auditability standard the rest of the RFC holds itself to (§2's artifacts, LLP 0005's "reviews that happen leave artifacts") suggests the report should land somewhere durable.
Resolution: name the run report's home per delivery mode (PR body for `pr`; a committed or explicitly-offered file for `direct`/`local`), or state deliberately that ship reviews are not archival like LLP-document reviews and why.

**C5. Model pins in the RFC body collide with LLP 0005's post-acceptance design freeze.** — **NON-BLOCKING**
Evidence: §2 places current model IDs "here, in this living document, so frontier churn revises the RFC, not the ≤60-line contract." But LLP 0005 says an accepted RFC's design section "shouldn't materially change" — post-acceptance pin updates would require dated addenda on every frontier churn, which is friction the design didn't intend.
Resolution: home the pins in a clearly non-normative appendix/addendum section of this RFC (exempt from the freeze by construction), or in the deferred `llp.json` (LLP 0008 OQ2 already points there).

**C6. The RFC is under a formal dual-family loop but still says `Status: Draft`.** — **NON-BLOCKING**
Evidence: the Revised line records "round 1 of dual-family super-refine review," and §2 of this very document holds that loop start authorizes `Draft → Review` because the document "is, from that moment, factually under formal review — matching LLP 0005's definition." By its own rule, this document should be `Review`.
Resolution: set `Status: Review`, or note why the manual (pre-skill) loop is treated differently.

## 4. Suggestions

- **Fold `llp-update-skills` into `llp-adopt`** (per C1) unless the rejection argument materializes. It resolves C1, shrinks OQ1's pressure, and honors "Modes instead of more skills" symmetrically.
- **Add a rollback verb, or state that git is the rollback.** §1 retains "the prior receipt as the rollback reference" but defines no procedure. For committed receipts in a git repo, one sentence ("rollback is `git revert` of the update commit; the retained receipt exists for uncommitted or user-global installs") closes the gap.
- **Record cost telemetry in the round manifest.** §2's round manifest is the natural place to capture per-round token/wall-clock cost and verdict outcomes — precisely the data OQ5 (round-budget tuning) and OQ6 (evidence obligation) say the system needs. Make the manifest feed the research it anticipates.
- **Note that ship's renumber-on-merge resolves LLP 0009 OQ1.** §3 quietly picks "renumber-on-merge" for the `max + 1` race. That's a fine choice, but land the corresponding note on LLP 0009's open question when this is implemented, per living-documents discipline.
- **Name the composition between §2 and §3.** Ship's "fresh independent session reviews the integrated diff" is a degenerate single-round, single-family instance of super-refine's reviewer primitive. Saying so enables a natural upgrade path — a repo can opt ship's integration review into cross-family for high-stakes runs — without new machinery.
- **Novel option for the trust model:** instead of a manifest, define a release as "the tag, period," and have `llp-adopt`/update compute and record hashes from the fetched tree into the receipt. Upstream-side verification then reduces to "the tag resolved to the commit the receipt names," which git gives you free. Keep the manifest only if per-file raw fetch is a channel you commit to supporting — and say that's why it exists.
- **Novel option for degraded super-refine (OQ2):** rather than a disclosed single-family mode, allow a *deferred-second-family* mode — the loop runs single-family to a provisional verdict, and the document is marked as owing one cross-family round before `Accepted` may be proposed. This preserves the guarantee's meaning (cross-family before acceptance) while not blocking iteration on an outage.

## 5. Open questions

Beyond the RFC's own OQ1–6 (which are well-chosen), the review surfaces:

1. Is `llp-update-skills` a skill or an adopt mode? (C1 — the RFC must answer this explicitly.)
2. What, precisely, does the manifest buy that the tag's content-addressed tree does not, and is that worth a standing release-cadence obligation on this repo? (C2)
3. Where does per-repo delivery policy live when the receipt is user-global? (C3)
4. Where does a ship run report live durably in `direct`/`local` modes? (C4)
5. When super-refine's lockstep cluster review is filed per-target, does a re-review of one sibling in the cross-consistency pass count against that sibling's budget only, or the cluster's? (§2 implies per-document; one clarifying sentence would prevent divergent implementations.)
6. Should ship's "reviewer availability" preflight requirement admit any degraded mode (e.g., deliver as `pr` with review explicitly outstanding), or is blocked the only honest outcome? Current text implies the latter; confirming it's intentional would pin the invariant.

## 6. Readiness verdict

**NOT READY** — the design is sound and the honesty engineering is excellent, but two MATERIAL decision-quality gaps in Part 1 (the unconsidered adopt-mode alternative for `llp-update-skills`, and the unargued manifest-vs-git-native trust model) must be resolved by argument or change before acceptance, since both go to whether the RFC obeys the corpus's own minimalism contracts (LLP 0008 "Modes instead of more skills," LLP 0009's capability test).

---

## Round 3 — 2026-07-22

**Reviewer family:** Claude
**Provider / runtime:** claude-code fresh general-purpose sub-agent, model `claude-fable-5`, max effort (inherited from orchestrating session)
**Date:** 2026-07-22
**Redacted:** no (nothing to redact; repository markdown only)
**Method:** sub-agent (fresh session; did not author or revise the draft; instructed not to read `llp/reviews/0010-*`)
**Revision under review:** `llp/0010-skill-install-super-refine-ship.rfc.md`, sha256 `a8da7b53bb891f4068f4af7e9c5b6a698b1c88acab92a54aa3a024f1baebbf7c` (post-round-2 revision)

Orchestrator verification notes (outside the verbatim body): C1's contradiction is an accurate reading of the round-2 revision — §2 simultaneously required total blindness, gave reviewers the repo, and persisted round manifests into `llp/reviews/` before launch. (This orchestration itself used the weak form: instruction-based exclusion, disclosed in these artifacts' Method lines.) C3's premise re-verified: `v0.2.0` is the only tag and `c52c4e8` post-dates it. The escaped `&lt;`/`&gt;` sequences in C1/C4 resolution text are the reviewer's output preserved verbatim.

The review body below is preserved verbatim.

---

# Review: LLP 0010 — Installed Skills, Super-Refine, and Ship

**Reviewer note on independence:** This review was produced without reading any `llp/reviews/0010-*` artifact. Claims about the repo were verified directly (git tags, skill files, `ref-check`, README/AGENTS.md, LLP 0004/0005/0008/0009).

## 1. Overall assessment

This is a strong, unusually honest RFC that closes three real gaps: the half-built distribution loop that LLP 0008 left open, the promotion of a proven-in-practice refine loop into the first-party corpus, and the pinning of an improvised end-to-end delivery workflow. The document is disciplined about its own system's rules — it states its contract/recipe boundary up front, homes new policy in LLP 0005 rather than in a skill (per LLP 0009), scales its machinery to a stated threat model, and repeatedly chooses honest failure (`blocked`, "cannot verify, wrote nothing") over improvisation. Its motivating example of the verification gap is verifiably true: `skills/llp-maintain/SKILL.md` was edited after the `v0.2.0` tag it pins (commit `c52c4e8`, the only post-tag skills change). The plan is risk-ordered with concrete, falsifiable acceptance tests per phase.

One coherence gap in the super-refine protocol is material: the "total blindness" guarantee has no stated mechanism and, read literally, contradicts the same section's instruction that reviewers receive the repo — which contains the prior review artifacts and the pre-persisted round manifests. Everything else I found is non-blocking polish or a legitimate open question.

## 2. Strengths

- **Tag-native trust model, manifest dropped** (§1 "Releases and receipts", Alternatives). Recognizing that a manifest inside the tag it attests adds consistency but not authenticity — and dropping it — is exactly the LLP 0009 capability-test discipline applied to this RFC's own earlier design. The explicitly stated threat model (accidental drift in scope; compromised upstream out of scope, moved tags detected-and-stopped) is the right honesty posture.
- **"Cannot-verify never degrades to guess"** (§1, update step 5) and its acceptance tests (Implementation plan, Phase 1: offline and moved-tag runs end "cannot verify, wrote nothing") turn a behavioral norm into a testable gate.
- **Update folded into `llp-adopt` as a mode** (§1 "Update"). The argument is sound: adopt already does verified, diff-shown, receipt-writing work; a separate skill would duplicate that surface and grow the always-loaded core, while the posture boundary that actually matters — maintain never applies, adopt applies after an approved diff — is preserved. Consistent with LLP 0008's "Modes instead of more skills."
- **SHA-indexed gates with re-entry semantics** (§3 "Execute, integrate, gate"). CANDIDATE/VERIFIED/REVIEWED/DELIVERED bound to exact commits, with any new commit invalidating both gates, is the correct antidote to the "verified something near what shipped" failure mode. The outbound-commit-closure check and the never-make-user-commits-remotely-reachable rule (§3 Invariants) show real thought about the nastiest git edge cases.
- **Task gating on `Accepted` and the experiment-run escape** (§3 "Task gating") correctly preserves LLP 0005's author authority — ship never changes a document's status.
- **Crash-honest review recording** (§2 Round protocol): writing each review to its artifact immediately on receipt, sealed rather than held in memory, directly serves LLP 0005's "reviews that happen leave artifacts," and the launch ledger with a hard cap bounds retries as well as rounds.
- **Policy homed in the corpus** (§2 Authorization): the one-sentence formal-loop authorization rule lands as a revision to LLP 0005 in the same change that implements the skill, keeping the skill an adapter per LLP 0009. Likewise the reserve-numbers-at-plan-time note lands in LLP 0009 OQ1 with the implementation (§3 Plan phase, Consequences) — clean co-evolution per LLP 0004.
- **Contract-first rule with a blocking-finding escape hatch** (Consequences): "if a contract cannot carry its invariants within the line cap, that is a blocking finding brought back to the author, not a rule silently dropped" pre-empts the most likely silent failure of the ≤60-line discipline.
- **Self-aware provenance** (§2 "Current instantiation" and the closing *Note*): dating the non-normative model roster and disclosing that this RFC's own refinement ran under a non-conforming prototype — and therefore doesn't count as the acceptance test — is exactly the honesty the corpus preaches.

## 3. Concerns

### C1 — Reviewer blindness has no mechanism and is internally contradictory as written. **MATERIAL**

Evidence: §2 Round protocol states "Blindness is total for review material: a reviewer sees neither the other current-round review nor **any** prior review artifact or orchestrator note for the targets," while the same section says "Reviewers receive the repo at that recorded revision" and requires the round manifest to be persisted **into each target's artifact file** (under `llp/reviews/`) *before* launching reviewers. The repo the reviewer receives therefore contains every prior round's verbatim reviews and the current manifests. Worse, the target document itself points readers at the artifacts — LLP 0010's own `Revised:` line says "see `llp/reviews/0010-*.{fable,codex}.md`". An implementer following the letter either hands over the artifacts (breaking the guarantee) or improvises an exclusion (unpinned behavior in the skill whose whole point is pinning). Note that instruction-based blindness ("do not read those files") is a materially weaker, self-attested guarantee than exclusion — the difference should be explicit, the way LLP 0005 is explicit that provenance headers are self-attestation, not proof.

Resolution criteria: one or two sentences in §2 specifying the mechanism — e.g., reviewers receive a checkout/export with `llp/reviews/&lt;target-stems&gt;*` removed (strong form), or blindness is achieved by instruction and disclosed as instruction-based in the round manifest and provenance (weak form, honestly labeled). Either resolves; silence does not.

### C2 — The update transaction mechanics are written as contract, straining the RFC's own contract/recipe rule and the ≤60-line budget. **NON-BLOCKING**

Evidence: The Summary pins the classification rule ("mechanics phrased as 'e.g.' or marked *(advisory)* are recipe"), but §1 update step 4's staging/journal/backup/move/receipt-commit sequence is phrased as bare imperative contract with no advisory marking. This is the same class of machinery — CI-grade rigor for a documentation-grade problem of copying a handful of markdown files — that LLP 0009's cuts table removed from LLP 0008, and it is the biggest threat to fitting `llp-adopt`'s grown contract (install step + profiles + receipts + update mode + transaction) inside 60 lines (current adopt contract: 40 lines). The same pressure applies to `llp-ship`'s contract (preflight, gating, ledger, delivery modes, race handling, atomicity). The escape hatch in Consequences covers the failure mode, which is why this is non-blocking.

Resolution criteria: reclassify the transaction *mechanics* (staging location, journal format, backup directory) as `&gt; **Recipe (advisory)**` homed in the corpus, keeping only the outcome invariants as contract ("an interrupted update is recoverable to either endpoint; the receipt write is the commit point; cannot-verify writes nothing") — or explicitly acknowledge in Consequences that the adopt contract is the most likely to trip the blocking-finding path.

### C3 — Release discipline is unenforced, and the release ordering has an undocumented chicken-and-egg step. **NON-BLOCKING**

Evidence: §1 declares "a commit that changes a skill file is not installable until a new tag is published," and the repo currently violates it (verified: `c52c4e8` edits `skills/llp-maintain/SKILL.md` after `v0.2.0`; `v0.2.0` is the only tag). Consequences defers automation ("if ever automated, a separate composable check") but specifies no manual process either. Additionally, skills carry `source: ccheever/llp@v0.2.0` pins and `v0.2.0` pinned URLs in their bodies; cutting a new release requires bumping those pins to a tag that does not yet exist at commit time (the URLs are dead until the tag is pushed). The failure mode is mild — a stale tag serves older-but-consistent content — hence non-blocking.

Resolution criteria: Phase 1 or 2 gains a short release checklist (bump `source:` pins and pinned URLs → commit → tag → push tag), and optionally names the separate composable release-check as a candidate rather than leaving enforcement entirely to memory.

### C4 — "Updates apply the whole set" is ambiguous against profiles, and profile definitions have no stated home. **NON-BLOCKING**

Evidence: §1 says "Skills are a coupled release … updates apply the whole set," but a core-only install should presumably update five skills, not seven. Relatedly, the receipt records "the installed profile," implying updates recompute profile membership from the new tag — but where profile→skill membership is authoritatively defined (upstream corpus? the adopt contract?) is unstated, and so is what happens when a tag changes a profile's composition.

Resolution criteria: one sentence defining "the set" as the installed profile as defined at the target tag, and naming where profile definitions live.

### C5 — The git posture of `.llp/` state is unstated. **NON-BLOCKING**

Evidence: §1 and §3 introduce `.llp/skills-receipt.json`, `.llp/policy.json`, and `.llp/ship-runs/&lt;run-id&gt;.json` (all "e.g."), but never say which are committed versus ignored. The design leans on the receipt being durable (trust root for updates, "git revert … where the installation is committed") and on policy being "a repo's recorded opt-in" — both argue for committed — while run ledgers are transient evidence. An uncommitted receipt silently vanishes on a fresh clone, degrading every later update to the "no receipt → fresh install" path.

Resolution criteria: state the intended posture (receipt and policy committed; ship-runs local/prunable), or add it to Open questions explicitly.

### C6 — Super-refine's behavior on non-`Draft` targets is undefined. **NON-BLOCKING**

Evidence: §2 Authorization authorizes exactly `Draft` → `Review` at loop start. Invoking on a document already in `Review` (plausible: resuming after budget exhaustion, which "leave[s] the documents in `Review`") or on an `Accepted`/`Active` document (where LLP 0005 forbids material design change outside an addendum or new LLP) is unaddressed — yet resumption after non-convergence is a state the design itself produces.

Resolution criteria: one sentence — idempotent on already-`Review` targets; refuse `Accepted`/`Active` targets, pointing at the addendum/superseding-LLP path.

### C7 — One-unit acceptance couples the mature install work to the riskiest part. **NON-BLOCKING**

Evidence: Summary declares the RFC "accepted or rejected as one unit," while the Implementation plan calls `llp-ship` "riskiest, last." This is within LLP 0005's letter (the Large-RFCs directory split applies at ~800 lines *and* independent timelines; this document is ~130 lines), and the addendum/superseding-LLP discipline for later cuts is stated — so this is a decision-risk flag, not a rule violation. If ship's design proves wrong during Phase 4, the accepted status of §1–§2 is undisturbed only via addendum bookkeeping.

Resolution criteria: none required beyond the author consciously reaffirming the bundling; the addendum discipline already stated is an adequate answer.

## 4. Suggestions

- **Review-clean export for blindness (fixes C1 mechanically).** Have the orchestrator hand reviewers an export of the tree at the recorded revision with `llp/reviews/` (or at least the targets' artifact stems) removed. It is one `git archive`-plus-exclusion away, converts the blindness guarantee from self-attested to structural, and costs a sentence in the RFC.
- **Hash the reviewer instruction set into the round manifest.** §2 asserts "Both reviewers get the same instruction set"; recording a content hash of the instructions alongside the target hashes makes that claim auditable for free and closes the last unaudited input to a round.
- **Endorse OQ2's deferred-second-family mode**, with a required artifact marker ("provisional single-family verdict; one cross-family round owed before `Accepted` may be proposed"). It preserves the guarantee's meaning under provider outage and is more honest than either silently stopping work or quietly substituting families.
- **Mine receipts for LLP 0009 Phase 4 evidence (ties to OQ6).** Receipts already record origin, tag, and date; across consuming repos they are a free longitudinal dataset (adoption latency, update cadence, fork frequency) — exactly the "observations rather than predictions" the proof obligation wants. Name receipts as the collection vehicle.
- **Annotated tags as human-readable release notes.** Since a release *is* a tag, putting the skill-visible changes in the tag annotation gives `llp-adopt update` a one-paragraph summary to show above the diff, at zero new machinery.
- **State whether concurrent runs are excluded.** Two simultaneous ship runs, or an update during a ship run, in one repo: the run ledger and update journal each protect their own transaction but nothing arbitrates between them. A one-line "runs are single-flight per repo; a live journal or unreconciled ledger blocks a new run" would pin it.

## 5. Open questions

1. Which blindness form does §2 actually promise — structural exclusion or disclosed instruction-based — and where is that recorded per round? (C1)
2. Where do install profiles live authoritatively, and what happens when a new tag changes a profile's membership? (C4)
3. What is the commit/ignore posture of `.llp/` state, and does the receipt's location need to be contract rather than "e.g." for a later `llp-adopt` version to reliably find it? (C5)
4. What does super-refine do when invoked on an already-`Review` or `Accepted` document? (C6)
5. Is the update transaction's journal/backup protocol contract or recipe — i.e., which parts must a conforming implementation reproduce versus merely achieve the outcome of? (C2)
6. Should the release discipline get even a deterministic advisory check (newest tag's skill tree vs. HEAD's) now, given the repo has already violated it once? (C3)
7. (The RFC's own OQ4, worth answering early) Should ship's REVIEWED gate be opt-in upgradeable to super-refine's cross-family primitive per repo policy, since the policy file introduced in §1 is the natural place to record that choice?

## 6. Readiness verdict

**NOT READY** — the design is close and largely excellent, but C1 (the total-blindness guarantee contradicts the reviewers-receive-the-repo instruction and pre-persisted artifacts, with no stated mechanism) is an unresolved MATERIAL coherence concern in super-refine's core protocol; a one-to-two-sentence mechanism fix would clear it.

---

## Round 4 — 2026-07-22

**Reviewer family:** Claude
**Provider / runtime:** claude-code fresh general-purpose sub-agent, model `claude-fable-5`, max effort (inherited from orchestrating session)
**Date:** 2026-07-22
**Redacted:** no (nothing to redact; repository markdown only)
**Method:** sub-agent (fresh session; did not author or revise the draft; instructed not to read `llp/reviews/0010-*`; prompt included the document's altitude rule, identically for both families this round)
**Revision under review:** `llp/0010-skill-install-super-refine-ship.rfc.md`, sha256 `4cffd06d7c271640cbd9d5339b641861d3485367aea02455c6fb3f1c35bafaa5` (post-round-3 revision, incorporating author direction of 2026-07-22)

Orchestrator verification notes (outside the verbatim body): the reviewer independently re-verified the tag/`c52c4e8` claim, the llp-maintain and llp-review contract invariants, and the ≤60-line status of all five existing contracts — all consistent with prior rounds' checks. Verdict: READY, with seven concerns all explicitly rated NON-BLOCKING.

The review body below is preserved verbatim.

---

# Review: LLP 0010 — Installed Skills, Super-Refine, and Ship

**Reviewer family:** Claude
**Provider / runtime:** claude-code sub-agent (Claude Fable 5)
**Date:** 2026-07-22
**Redacted:** no
**Method:** sub-agent (independent; no prior `llp/reviews/0010-*` artifacts read)

---

## 1. Overall assessment

This is a strong, unusually self-consistent RFC. It closes the genuinely half-built part of LLP 0008 (skills are distributed by hand-copying with no install, verify, or update path), promotes a practice-proven review loop into the first-party corpus, and pins the invariants of an end-to-end task-execution workflow that is currently re-improvised on every request. All three parts are argued in the system's own vocabulary — contracts over recipes (LLP 0004), skills as ≤60-line adapters citing policy (LLP 0009), review honesty as kernel (LLP 0005) — and the arguments mostly hold under checking rather than merely gesturing at the prior documents.

I verified the load-bearing factual claims against the repo: the `v0.2.0` tag exists and commit `c52c4e8` ("Fix llp-maintain skill metadata") postdates it, so the RFC's own example of the verification gap (§ Motivation, § Design 1) is real; `llp-maintain`'s contract does note stale `source:` pins without applying anything (`/Users/ccheever/projects/llp/skills/llp-maintain/SKILL.md`, Checks); `llp-review`'s contract does forbid touching `Status:` and applying anything (`/Users/ccheever/projects/llp/skills/llp-review/SKILL.md`), which supports the separate-skill argument for super-refine; LLP 0008's "Modes instead of more skills" supports folding update into `llp-adopt`; and the five existing contracts are all under the 60-line cap, so the contract-first rule has precedent of being achievable.

The hard problems are handled rather than hand-waved: the trust model for updates is stated with an explicit threat model and an explicit non-goal (compromised upstream); super-refine's authorization is reconciled with LLP 0005 by amending LLP 0005 rather than by letting a skill carry policy; ship's status transitions are split into author-authority (never applied) and factual (applied inside the gated candidate), which is a correct reading of LLP 0005's lifecycle. My concerns are edge-semantics and trade-off-visibility issues, none of which identifies a defective decision.

## 2. Strengths

- **Tag-as-release, receipt-as-trust-root (§ Design 1).** Dropping the manifest because git's content addressing already attests the tag's tree is the right call, and the stated re-entry condition (manifest returns only if raw-fetch-without-git becomes a channel) keeps the decision falsifiable. The receipt living *next to the installation it describes* cleanly avoids a global registry.
- **The self-incriminating example (§ Motivation).** Using this repo's own post-tag edit of `llp-maintain` as evidence of the verification gap is honest and verifiable — I verified it. This is the corpus practicing what it preaches.
- **Update folded into adopt with the posture boundary preserved (§ Design 1, "Update").** The reversal of the earlier separate-skill design is argued, not just asserted: adopt already does verified, diff-shown, receipt-writing work; maintain's *never-applies* line survives via hand-off. This is exactly LLP 0008's "modes instead of more skills."
- **Authorization semantics for super-refine (§ Design 2).** Recording consent per target/per author, scoping it to disclosed budget and providers, refusing `Accepted`-and-beyond targets, and landing the enabling rule as one sentence in LLP 0005 (because skills are adapters, not policy homes — LLP 0009) is the most carefully reasoned part of the document. Convergence producing a *recommendation*, never acceptance, preserves LLP 0005's "reviewers advise; the author decides."
- **Structural blindness with honest degradation (§ Design 2, round protocol).** The capsule (review artifacts and orchestrator notes structurally excluded, hash recorded pre-launch) makes blindness verifiable where possible, and where a runtime can't do it structurally, the fallback is *disclosed as self-attested* — mirroring LLP 0005's own provenance-header epistemology.
- **Asymmetric-verdict stop and altitude rule (§ Design 2, bounds).** Both are real convergence-failure modes: one family grinding forever on the other's nitpicks, and reviewers inflating spec-detail requests into blockers. The altitude rule with orchestrator disposition *recorded in the artifact* keeps the honesty trail intact.
- **Ship's gate design (§ Design 3).** SHA-indexed gates (VERIFIED and REVIEWED must hold for the *exact delivered SHA*, re-entry at CANDIDATE after any change), verification on a clean checkout with mutation-fails-the-gate, and "a review having occurred is not the gate; the verdict is" close precisely the fabrication and rubber-stamp failure modes the Motivation names. The mode-specific factual-outcome rule ("never `blocked` after an external effect actually succeeded") is a subtle and correct honesty requirement most such designs miss.
- **Authority layering (§ Design 3, preflight).** Policy file as default-and-ceiling, human invocation as the actual authorization, task content never escalating authority — this is the right prompt-injection posture for a skill that pushes to remotes.
- **The non-conforming-prototype disclosure (§ Design 2, note).** Admitting this RFC's own refinement ran under a pre-protocol prototype and does not count as the acceptance test is exactly the never-fabricate norm applied reflexively.

## 3. Concerns

**C1. "Keep the fork and stop tracking" re-creates the state the coupled abort exists to prevent. — NON-BLOCKING**
Evidence: § Design 1, step 3 aborts the coupled update because "skills reference each other; mixed-release installs are not a supported state," yet one sanctioned resolution path (keep the fork, stop tracking that file) leaves a divergent old-release file alongside newly updated skills indefinitely — a mixed state, now permanent. The implicit reading (a kept fork exits the managed set and becomes user-owned, so the *installation* is no longer mixed, just smaller) is coherent but unstated, and the fate of cross-references from still-managed skills to the forked one is unaddressed. Resolution: one or two sentences stating that stop-tracking removes the file from the managed set (receipt updated accordingly), that the resulting configuration is declared user-owned rather than supported-mixed, and how subsequent updates treat upstream changes to a de-tracked file. This adds specification detail to a sound decision (never clobber; human resolves), hence not MATERIAL under the document's own altitude rule.

**C2. `Review` status limbo after non-convergent termination. — NON-BLOCKING**
Evidence: § Design 2 sets each `Draft` target to `Review` at loop start ("factually under formal review from that moment"), but the terminal outcomes short of convergence (§ bounds; also `--rounds N` runs that end without convergence) leave the document's status unaddressed, and LLP 0005's lifecycle defines no `Review` → `Draft` transition. A document sitting at `Review` with no loop running is mildly dishonest state — the same class of problem Phase 0 of LLP 0009 existed to fix. Resolution: state what the loop does at every terminal outcome (e.g. escalation report proposes either staying `Review` pending author action or reverting to `Draft` — the author applies it), or state that LLP 0005 gains that transition alongside the quoted sentence. Detail, not a defective decision.

**C3. Cross-round reviewer freshness means no reviewer ever confirms a disposition. — NON-BLOCKING**
Evidence: § Design 2 — the capsule structurally excludes prior review artifacts, so round-N reviewers are blind not only to each other but to round-(N−1)'s concerns and the orchestrator's dispositions. The upside (each round judges the document on its merits; no anchoring) is real, and an unfixed concern will presumably recur. But dispositions — especially altitude-rule dispositions, where the orchestrator unilaterally declassifies a reviewer's MATERIAL concern to implementation-phase — are never seen by any reviewer, so a systematically mis-dispositioning orchestrator is caught only by the author reading artifacts. Resolution: the design should *state* this trade-off and its mitigation (dispositions are in the artifact; the escalation paths carry open concerns to the author) so the choice is visibly deliberate rather than an omission. Possibly also: the final escalation/convergence report enumerates every altitude-rule disposition made across the run.

**C4. Growth-budget conflict with material fixes has no stated outlet. — NON-BLOCKING**
Evidence: § Design 2, bounds — "additions must displace" is contract-shaped ("may not grow … beyond ~20%"), but the case where both families demand additions that genuinely exceed the budget and nothing is honestly displaceable has no named terminal outcome (the three escalations cover budget/cap, contradiction, and asymmetry — not growth-budget exhaustion). Resolution: name it — growth-budget exhaustion with open MATERIAL concerns escalates to the author like the other three. OQ4 already flags the constant as a guess; the missing piece is only the escape hatch.

**C5. Config surface fragmentation vs. the deferred `llp.json` (LLP 0008 OQ2). — NON-BLOCKING**
Evidence: § Design 1 and § Design 3 introduce `.llp/policy.json` (delivery mode, possibly reviewer specs per § Design 2), `.llp/skills-receipt.json`, and `.llp/ship-runs/` — while LLP 0008 OQ2's `llp.json` remains "deferred," and § Design 2 even points at it as a possible future home for reviewer config. Three adjacent config files accreting under `.llp/` is exactly how a deferred design gets built piecemeal without its open question ever being answered. The names are marked "e.g." (advisory), so this is not a contract defect. Resolution: one sentence in the Consequences or OQs acknowledging that `.llp/policy.json` is a partial instantiation of LLP 0008 OQ2 and that a future consolidation would be a revision of that answer, not a new surface.

**C6. Bundling three separable designs into one accept/reject unit. — NON-BLOCKING**
Evidence: § Summary declares one-unit acceptance; LLP 0005 § Large RFCs prescribes the directory-with-sub-RFCs form when sub-topics have "independent timelines" — which these visibly do (phases land independently, and ship is explicitly "riskiest, last"). The RFC stays under the ~800-line threshold and provides the cut-later escape hatch (dated addendum or superseding LLP), so the letter of LLP 0005 is satisfied and the choice is explicit. But the practical consequence is that a reviewer or author with doubts about ship alone cannot reject it without rejecting the (much lower-risk, immediately needed) distribution loop. Resolution: none required — the decision is stated and LLP-0005-conformant; I flag it because it concentrates decision risk, and the escape hatch's honesty depends on discipline that hasn't been exercised yet.

**C7. Ship's `Accepted` → `Active` flip involves a judgment call presented as factual. — NON-BLOCKING**
Evidence: § Design 3, task gating — "when a delivered candidate *completely implements* an `Accepted` document," ship includes the flip in the gated candidate. LLP 0005 does define the transition condition factually ("becomes `Active` when the implementation is done and merged"), but *whether* an implementation is complete is a judgment ship makes about its own work. The partial-implementation fallback (note partial state, leave status alone) and the human-visible run report bound the damage, and in `pr` mode a human merges the flip. Resolution: require the flip to be explicitly called out in the run report / PR body as a claim the human is endorsing at delivery, not buried in the diff — one sentence.

## 4. Suggestions

- **Add a receipt-time pin-consistency check (cheap, catches the release checklist failing).** At install/update, verify that the `source:` frontmatter pins and pinned policy URLs inside the fetched skills actually name the tag being installed. The Consequences section defines the release checklist (bump pins → commit → tag → push); this check is the mechanical detector for the checklist being skipped — the exact failure mode the `llp-maintain`-after-`v0.2.0` example already demonstrated once. It is a local string comparison against data the receipt flow already has.
- **Give `llp-ship` a plan-only mode** (`--plan` / dry run): run preflight and the plan phase, emit the ledger-shaped plan (lanes, task restatements, reserved LLP numbers, delivery mode, what would be gated), execute nothing. For a skill whose failure modes are all in execution, the cheapest trust-builder is letting humans read the plan first; it also gives Phase 3 a low-risk first acceptance artifact.
- **Adopt OQ2's deferred-second-family mode in this RFC rather than leaving it open.** The design is already fully sketched in the question itself (single-family rounds to a provisional verdict; document marked as owing one cross-family round before `Accepted` may be proposed), it preserves the guarantee's meaning exactly as stated, and outages of one family are a *certainty* over the skill's life, not an edge case. Deciding it now costs three sentences; leaving it open guarantees the first outage is handled by improvisation — the thing this whole corpus exists to prevent.
- **Have the convergence/escalation report enumerate altitude-rule dispositions** (see C3): a one-line-per-disposition table gives the author a direct view of the orchestrator's only unilateral power.
- **State the receipt's own integrity assumption in the threat model**: the receipt is the trust root and is a committed, editable file; a hand-edited receipt silently defeats fork detection. This is squarely inside "accidental drift" territory and worth one clause so the boundary is explicit.

## 5. Open questions

Beyond the RFC's own OQ list (which is honest and well-chosen — OQ5's receipts-as-longitudinal-telemetry is a genuinely good idea):

1. What happens to `Review` status at each non-convergent terminal outcome (C2)?
2. When a kept fork exits the managed set, how do later updates and cross-skill references treat it (C1)?
3. Is `.llp/policy.json` the beginning of `llp.json` (LLP 0008 OQ2), and who reconciles them (C5)?
4. For ship's REVIEWED gate, what observed error rate would justify flipping the default from same-family to the §2 cross-family primitive? (The RFC makes it opt-in via policy; a criterion for revisiting the default would make the choice capability-test-shaped, matching how LLP 0009 handles every other shell/kernel boundary.)
5. Does the launch ledger / run journal format need any stability guarantee across skill versions, given receipts must survive updates of the skill that reads them? (Likely phase work, but the update mode's own recoverability contract depends on reading journals written by the prior version.)

## 6. Readiness verdict

READY — every concern above resolves by adding specification detail or a disclosed sentence rather than by reversing a decision; the design's contracts are internally coherent, consistent with LLP 0004/0005/0008/0009, and its load-bearing factual claims check out against the repository.

---

## Round 5 — 2026-07-23

**Reviewer family:** Claude
**Provider / runtime:** claude-code fresh general-purpose sub-agent, model `claude-fable-5`, max effort (inherited from orchestrating session)
**Date:** 2026-07-23
**Redacted:** no (nothing to redact; repository markdown only)
**Method:** sub-agent (fresh session; did not author or revise the draft; instructed not to read `llp/reviews/0010-*`; prompt included the document's altitude rule, identically for both families this round)
**Revision under review:** `llp/0010-skill-install-super-refine-ship.rfc.md`, sha256 `e6d5b5e5693f5cc06972a18733b29b2812bc077f61a2f48a17671820085064e1` (post-round-4 revision)

Orchestrator verification notes (outside the verbatim body): the reviewer independently re-verified the tag/`c52c4e8` claim. Verdict: READY, with five concerns all explicitly rated NON-BLOCKING — the Fable family's second consecutive READY, on consecutive revisions.

The review body below is preserved verbatim.

---

# Review: LLP 0010 — Installed Skills, Super-Refine, and Ship

**Reviewer family:** Claude
**Provider / runtime:** claude-code sub-agent (Claude Fable 5)
**Date:** 2026-07-23
**Redacted:** no
**Method:** sub-agent

---

## 1. Overall assessment

This is a strong, unusually self-consistent RFC. It closes the three real gaps left after LLP 0009's simplification — distribution has no install/update loop, the proven dual-family refine practice lives outside the first-party corpus, and end-to-end task delivery is re-improvised every time — and it does so while staying inside the constraints those earlier documents established: skills as ≤60-line adapters (LLP 0009), policy homed in the corpus not in skills, modes instead of more skills (LLP 0008), honesty rules absolute (LLP 0005), contracts over recipes (LLP 0004). I verified its load-bearing factual claim directly: `skills/llp-maintain/SKILL.md` was indeed edited after the `v0.2.0` tag it pins (commit `c52c4e8`, the only skill-file commit after the tag), so the motivating verification gap is real, not rhetorical. The document's contract/recipe discipline is explicit and consistently applied, its phases are risk-ordered with concrete acceptance tests, and the places where it deliberately revises prior decisions (LLP 0009's classification of distribution machinery as shell; the LLP 0005 authorization sentence) are named and landed in the owning documents rather than smuggled in. My concerns are about proportionality and duplication, not defective decisions.

## 2. Strengths

- **The trust model is minimal and correct** (§1, "Releases and receipts"). Dropping the per-release manifest in favor of git's own content addressing is the right call — a manifest inside the tag it attests adds consistency, not authenticity, exactly as the Alternatives paragraph says. The stated threat model ("the receipt attests, it does not prove"; moved tags detected, not prevented) is honest about what a JSON file next to the installation can and cannot guarantee.
- **Update-as-adopt-mode** (§1, "Update") correctly applies LLP 0008's "Modes instead of more skills," and the posture boundary it preserves — llp-maintain notes staleness and never applies; adopt applies after an approved diff — matches the existing `skills/llp-maintain/SKILL.md` contract ("Proposes; never applies") exactly.
- **The two-authority separation in super-refine** (§2, "Authorization") — document author authorizes revision, a human with disclosure authority authorizes egress, an AI co-author is never a disclosure authority — is a genuinely careful decision that resolves the tension between LLP 0005's "sending content to an external model is an explicit human action" and a multi-round automated loop. Landing the authorization rule as a sentence in LLP 0005 itself, per LLP 0009's "skills are adapters, not policy homes," keeps the corpus coherent.
- **Verdict binding to the capsule hash** (§2, "Round protocol") makes the READY guarantee mean something specific: a verdict covers exactly the bytes the reviewer saw, and the no-target-redaction rule ("a target that cannot be disclosed whole stops the loop") closes the verdict-on-unseen-bytes loophole cleanly.
- **Ship's gate design** (§3) is honest where it would be easy to hand-wave: the REVIEWED gate is the *verdict*, not the review having occurred; the same-family limitation is disclosed rather than dressed up as §2's cross-family guarantee; partial external effects are recorded as individual facts a report may not contradict. The MUST list in §3 pins exactly the failure modes the Motivation names.
- **Ship never applies lifecycle transitions** (§3, "Task gating") — proposing `Accepted` → `Active` as a called-out commit the merging human endorses is precisely consistent with LLP 0005's "no tool changes `Status` unilaterally."
- **Self-aware process hygiene:** the note that this RFC's own refinement ran under a non-conforming prototype (§2, final note), the contract-first blocking rule for the 60-line cap (Consequences), and the accept-as-one-unit declaration with addendum discipline (Summary) all show the document obeying the system it extends.

## 3. Concerns

**C1 — Proportionality of the update-transaction contract. NON-BLOCKING.**
Evidence: §1 step 4 makes recoverable-to-either-endpoint, revalidate-before-mutation, and receipt-as-commit-point *contract*, and step 1 makes single-flight-per-installation contract — for an operation that copies a handful of markdown files, and whose repo-scoped case is committed to git (where the RFC itself notes rollback is `git revert`). LLP 0009 cut exactly this class of machinery as "CI-grade rigor for a documentation-grade problem." The RFC engages the tension openly (Consequences: "this RFC supersedes its classification…") and grounds the need in an observed failure, so the *decision* to make distribution first-party is sound; but the transactional MUSTs are mostly load-bearing only for uncommitted or user-global installs. Resolution: either scope the strong transactional clauses to installations not protected by version control, or add one sentence acknowledging that for committed installs the contract is satisfied trivially by git — so Phase 1 doesn't build journal/staging machinery the common case never needs. (Under the RFC's own altitude rule this is a proportionality judgment, not a defective decision — hence NON-BLOCKING.)

**C2 — Two independently specified blind-reviewer protocols. NON-BLOCKING.**
Evidence: §2's round protocol (fresh mutually blind sessions, verdict bound to capsule hash, reviewer never revises) and §3's REVIEWED gate (fresh independent session, verdict bound to SHA, reviewer never implements its own findings) are the same primitive — "independent session issues a hash-bound verdict on bytes it didn't write" — specified twice with different vocabulary. The RFC gestures at the connection ("repo policy MAY opt this gate into §2's cross-family primitive") but doesn't name the shared core. Resolution: one sentence in either section declaring the ship review gate an instance of the §2 verdict primitive (single-family, single-round degenerate case) would prevent the two specifications drifting apart during Phases 2–3. Spec-tightening only; not a defective decision.

**C3 — `--rounds N` status disposition is under-specified. NON-BLOCKING.**
Evidence: §2 "Invocation options" says status handling under `--rounds N` is "identical," and loop start sets `Draft` targets to `Review`; the four escalation outcomes each propose a status disposition, but a deliberately finite `--rounds` run that ends without convergence is none of the four terminal outcomes, leaving the document parked in `Review` with no stated proposed disposition. Resolution: state that a `--rounds` run's report also proposes stay-`Review`-or-revert-`Draft`. Pure specification detail; implementation-phase material under the RFC's own altitude rule.

**C4 — No consumer-initiated profile-shrink path. NON-BLOCKING.**
Evidence: §1 handles upstream adds/removals/renames ("the changeset for the installed profile *as defined at the target tag*") and per-file detachment, but a consumer who wants to drop a flag (e.g., remove `delivery` after installing it) has no stated path — detachment converts files to user-owned, which is not removal. Resolution: one sentence defining profile shrinkage (a receipt-recorded removal of the flag's files) in the Phase 1 contract. Implementation-phase detail.

**C5 — "Claude-family" hard-coded into the round protocol prose. NON-BLOCKING.**
Evidence: §2 round protocol says "one from the strongest available Claude-family model, one from the strongest available external family," while LLP 0008 OQ2 says review config "should name model *families*, never pinned model IDs," and LLP 0005 requires only "at least two model families." The RFC does say the skill contract names families only and quarantines the current instantiation in a dated non-normative subsection, so the design intent is right; but the normative round-protocol sentence bakes in Claude-as-one-family rather than "the orchestrating runtime's family plus one external family." Resolution: rephrase to runtime-relative wording so the protocol is portable to a non-Claude orchestrator. Wording fix, not a design defect.

## 4. Suggestions

- **Let ship's run ledgers and install receipts serve LLP 0009 Phase 4.** OQ5 already names receipts as a longitudinal dataset; go one step further and state that the Research LLP owed by LLP 0009's proof obligation should draw on ship run reports (gate outcomes, review findings caught, blocked runs) — ship is the first component that generates evidence of *prevented* failures as a side effect of running.
- **Add a tiny artifact linter as a separate composable check** (consistent with LLP 0004's "composable pipelines" and the RFC's own "release validation… is a separate composable check"): verify super-refine artifacts have a verdict line, a capsule hash, and a round header. It keeps the honesty rules behavioral while making malformed artifacts mechanically visible — the same split ref-check already embodies.
- **Endorse OQ2's deferred-second-family mode** with the "owing one cross-family round before `Accepted` may be proposed" marker recorded *in the document's review artifact*, so the debt is visible to any future reader, not just the author.
- **Record `git describe --tags` output (or equivalent) in the receipt** alongside the resolved commit — near-zero cost, and it makes "how far past the tag is upstream HEAD" answerable offline during llp-maintain's staleness note.
- **State the cross-tool concurrency posture in one line:** ship and super-refine are each single-flight per repo, but nothing stops a ship run from mutating a document mid-super-refine round (the round is voided by the target-hash check, which is the right outcome — say so explicitly so the void is understood as designed, not accidental).

## 5. Open questions

1. Should the strong update-transaction guarantees apply only to installations not protected by version control (C1), making the committed-repo case trivially conformant?
2. When a consumer's policy file records `local` as the ceiling and an invocation requests `pr`, is the run refused, or does the invocation renegotiate the ceiling with explicit confirmation? (§3 defines the ceiling but not the over-ceiling interaction.)
3. Does the growth budget (~20%) count escalation-mandated additions (e.g., a reviewer-demanded threat-model section) the same as voluntary elaboration, and is displacement measured per-round or per-run?
4. For ship's REVIEWED gate in `direct` mode — the solo-maintainer case with no PR gate — should repo policy be *encouraged* (not just permitted) to opt into the cross-family primitive, since that mode has the fewest human checkpoints?
5. The RFC's existing OQ3 (is `llp-ship` really LLP-scoped?) deserves an explicit decision criterion: what observed usage would trigger the generic-engine split?

## 6. Readiness verdict

READY — every concern I found is proportionality, wording, or specification detail that Phase work resolves without revisiting a decision; the design decisions themselves are coherent with LLP 0004/0005/0008/0009, grounded in a verified observed failure, and honest about their own limits.
