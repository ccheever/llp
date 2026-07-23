# Reviews of LLP 0010 — GPT (Codex) family

## Round 1 — 2026-07-22

**Reviewer family:** GPT
**Provider / runtime:** OpenAI Codex CLI (`codex-cli 0.145.0`), model `gpt-5.6-sol`, reasoning effort `ultra`, sandbox `read-only`, session `019f8d63-0401-79b3-9981-67aa3cb90945`
**Date:** 2026-07-22
**Redacted:** no (nothing to redact; repository markdown only)
**Method:** cli-runner (`codex exec`, non-interactive, workdir `/Users/ccheever/projects/llp`)
**Revision under review:** `llp/0010-skill-install-super-refine-ship.rfc.md`, sha256 `189b502b7705755e9483714ab69bf9d6990e289a2e98f0b34566fa030e8ff3f7` (untracked; pre-first-commit draft)

Orchestrator verification notes (outside the verbatim body):

- Spot-checked and **confirmed**: `skills/llp-maintain/SKILL.md` still pins `source: ccheever/llp@v0.2.0` but was modified after the `v0.2.0` tag (commit `c52c4e8`), so a fresh copy of HEAD would immediately read as a local fork under the RFC's three-way check (§3.3's counterexample). Confirmed: llp-maintain's Checks already include noting stale `source:` pins (§3.11). Confirmed: LLP 0008 states no skill depends on `ref-check`; CI runs only `ref-check.yml`; the seven-to-five consolidation history is as cited (§3.1, §3.9, §3.10).
- Disposition on §3.1/§4 "split into three RFCs": not adopted as a split. The round-2 revision instead makes the three parts independently acceptable within one RFC (per-part acceptance, per-part capability-test rationale, install profiles). Splitting into new LLPs would expand scope beyond what the author authorized for this refine loop; the author can still request a split.
- All other material concerns (3.2–3.11) addressed by revision; see the document's revision note.

The review body below is preserved verbatim.

---

## 1. **Overall assessment**

The proposal addresses three real problems, and each contains a useful core idea: copied skills need a managed update path; high-stakes documents benefit from an explicit dual-family convergence loop; and end-to-end task execution needs stronger safety invariants than an improvised prompt.

It is not yet a good implementation plan. The RFC bundles three independently risky systems—package distribution, cross-provider review orchestration, and autonomous Git delivery—without resolving their distinct trust, lifecycle, transaction, and recovery requirements. The updater cannot bootstrap or migrate the current five-skill installation coherently; `llp-super-refine` conflicts with the governing meaning of `Review`; and `llp-ship` can push a tree that was never tested or reviewed in its integrated form. These are design defects, not optional polish.

The best path is to split the proposal into independently acceptable RFCs, preserve the strong invariants, and redesign each workflow around an auditable transaction: a content-addressed release transaction for skills, an immutable review-round transaction for refinement, and an integration-branch transaction for shipping.

## 2. **Strengths**

- The updater’s local-fork check is exactly the right instinct. Comparing the installed copy with its claimed baseline before proposing an update protects deliberate project customization and follows the “show a diff; never clobber” posture of LLP 0008 §Distribution and Security & trust (LLP 0010 §1 “Installation and updates”).

- Keeping application out of `llp-maintain` preserves a valuable boundary. The current maintenance contract is explicitly “propose, never apply,” and a mutating package-update workflow should not weaken that guarantee (`skills/llp-maintain/SKILL.md` §Invariants; LLP 0010 §1).

- `llp-super-refine` preserves the most important review invariants: fresh reviser-versus-reviewer separation, two mutually blind families, actual artifacts, fail-closed behavior when a reviewer is unavailable, and no transition to `Accepted` (LLP 0010 §2; LLP 0005 §§The multi-model loop, Honesty rules, Review artifacts).

- The coupling-aware distinction between independent loops and lockstep rounds is a thoughtful response to multi-document review. It recognizes that parallelism and coherence are competing concerns rather than assuming one topology always works (LLP 0010 §2 “Multi-document coordination”).

- `llp-ship` identifies several genuine long-horizon agent failure modes and states worthwhile protections: no fabricated verification, no sole self-review, no force-push, no silent stash, preservation of unrelated changes, and explicit per-task outcomes (LLP 0010 §3 “Invariants”).

- Requiring code, LLP documents, and `@ref` annotations to co-evolve is consistent with LLP’s durable value proposition (LLP 0010 §§Summary, Execute; LLP 0004 §Co-evolve code and docs).

- Retaining thin, policy-citing skill contracts is directionally correct. The proposed contracts remain adapters rather than the only home of policy (LLP 0010 §Consequences; LLP 0009 §Skills become deletable adapters).

## 3. **Concerns**

### 3.1 The five-to-eight expansion is not reconciled with the active architecture

**Severity:** MATERIAL

**Evidence:** LLP 0008 §§The five skills, Modes instead of more skills, and History records the seven-to-five consolidation as deliberate. LLP 0009 §Skills become deletable adapters calls the five-skill partition “correct and recent,” while its Phase 4 leaves real consumer adoption as the outstanding empirical proof obligation. RFC 0010 nevertheless moves directly from five to eight always-installed skills. `llp-super-refine` is facially a specialization of review, the updater overlaps adoption and distribution, and the RFC itself concedes that `llp-ship` is only incidentally LLP-specific (LLP 0010 §Open questions 1 and 4). Claims that super-refine is materially better and that update/ship are frequent are not backed by a linked Research LLP, usage counts, failure data, or comparative runs. The proposal also does not apply LLP 0004’s capability test to each addition.

**Resolution criteria:** Make the three additions independently acceptable, preferably as separate RFCs. For each, provide usage evidence, apply the capability test, compare a new skill with a mode or optional adapter, and state which existing LLP 0008/0009 decision is being superseded and why. Resolve whether all consumers receive all eight skills or whether LLP should publish profiles such as core, advanced review, and delivery.

### 3.2 Installation and migration are not implementable as written

**Severity:** MATERIAL

**Evidence:** LLP 0010 §§Summary and Consequences say five skills become eight, while §1 says `llp-adopt` installs seven without explaining whether it installs itself. The updater enumerates only installed skills, so a five-skill consumer cannot discover additions, removals, or renames—and cannot acquire the new updater through that updater. It also does not reconcile the five-skill `AGENTS.md` managed block that LLP 0008 §Distribution makes part of skill routing. A standalone copied `skills/llp-adopt/SKILL.md` contains neither the sibling skill payloads nor a defined acquisition mechanism; `README.md` §Skills currently assumes a prior clone followed by `cp`, and LLP 0008 §Bootstrap explicitly says there are no installation scripts.

**Resolution criteria:** Define an authoritative versioned release manifest containing the exact skill inventory, paths, managed-block template, and add/remove/rename semantics. Specify whether `llp-adopt` installs itself, how a standalone adopter acquires the bundle, how existing v0.2 five-skill consumers bootstrap the updater, and what happens offline. Demonstrate a clean-room install and migration using only the documented prerequisites.

### 3.3 An informational pin is being promoted into an unsafe package-manager trust root

**Severity:** MATERIAL

**Evidence:** LLP 0008 §Distribution and LLP 0009 §§The cuts, Skills become deletable adapters explicitly describe `source:` as informational. LLP 0010 §1 instead uses that self-declared value to choose a network origin, reconstruct a baseline, select a newer release, and write executable agent instructions. The format identifies neither a host nor an immutable commit or content digest; “newer tag,” prerelease handling, breaking upgrades, moved tags, and annotated-tag peeling are undefined. `ref-check` does not validate `source:` or release integrity.

The repository already provides a counterexample: `skills/llp-maintain/SKILL.md` still declares `source: ccheever/llp@v0.2.0`, but HEAD commit `c52c4e8` changed that file after the v0.2.0 release. A user following the README and copying current HEAD would therefore be classified immediately as a local fork against its declared pin.

Updates are also described per skill, without bundle atomicity or rollback, even though the contracts and hand-offs form one coupled release. LLP 0008’s runtime table further makes Codex installation user-global, so an update initiated from one repository may alter behavior in every repository.

**Resolution criteria:** Establish the trusted origin independently of installed content. Resolve human-readable versions to immutable commits and verify a manifest plus per-tree hashes before presenting or applying changes. Define version ordering, compatibility channels, moved/deleted-tag behavior, directory-level fork detection, project-versus-user scope, and private/offline sources. Stage and validate the complete bundle, apply it atomically, retain a prior receipt or backup, and specify rollback and interrupted self-update behavior.

### 3.4 `llp-super-refine` reverses the governing meaning of `Review`

**Severity:** MATERIAL

**Evidence:** LLP 0010 §2 runs the formal loop while a document may remain `Draft`, then treats convergence as authorization for `Draft → Review`. LLP 0005 §Lifecycle defines `Review` as the author’s opt-in to the formal loop—not the state reached after that loop converges—and says no tool changes status unilaterally. LLP 0008 §Non-goals and `skills/llp-review/SKILL.md` §Invariants likewise say review never touches `Status`. A human invoking a command is not necessarily the document author, and consent to external review is not automatically authority to revise design or change lifecycle state.

**Resolution criteria:** Preserve current semantics: the author opts into `Review` before the formal loop, and convergence produces a recommendation that the document is ready for the author to accept. The skill should not change status itself. If invocation is intended to grant explicit transition authority, amend LLP 0005 and LLP 0008, require an author-authorized flag or confirmation, and explain why the transition occurs after rather than before review. In all variants, stop when a material concern requires a human product or design choice.

### 3.5 The claimed same-revision, mutually blind convergence is not auditable or bounded

**Severity:** MATERIAL

**Evidence:** LLP 0010 §2 requires both families to mark “the same revision” ready, but its provenance fields omit a commit, blob hash, payload digest, round identifier, and cluster revision vector. Concurrent reviewers may therefore see different target or dependency states. Mutual blindness is asserted but no snapshot or filesystem restriction prevents a reviewer from reading a current-round artifact. Redaction can also produce different payloads, while a repository-scoped external CLI can read or echo secrets outside the nominal target.

Lockstep reviews create an unresolved artifact problem: one holistic review covers several LLPs, while LLP 0005 §Review artifacts names one family artifact per LLP. The “one more round” cross-consistency rule is not a fixed-point algorithm; if that round causes another revision, dependents are invalidated again. “Any number of targets” is also incompatible with finite reviewer context, as the RFC’s own §Open questions 5 acknowledges. No round, cost, time, oscillation, or contradictory-review limit is defined.

The claimed Exact source contains useful safeguards that this RFC omits: a readiness definition, revision identity, factual spot-checks, and explicit stops for fundamental redesign or human decisions (`/Users/ccheever/projects/exact/.claude/skills/llp-super-refine/SKILL.md` §§Review brief, Loop, Failure and scope boundaries).

**Resolution criteria:** Create an immutable round manifest recording the exact sanitized payload or snapshot digest, target and dependency hashes, topology, reviewer sessions, redaction, and per-document plus cluster verdicts. Launch both reviewers against that snapshot and buffer both results before exposing either artifact. Define a cluster-artifact convention without duplicating or overcounting reviews, canonical family identifiers, a context-fit preflight, terminal states and a human-approved budget, and invalidation propagation until the complete revision vector reaches a no-change fixed point. External reviews should receive an explicit egress manifest or curated snapshot rather than unrestricted repository access.

### 3.6 `llp-ship` conflates task selection, design acceptance, and permission to publish

**Severity:** MATERIAL

**Evidence:** LLP 0010 §3 accepts RFCs and Plans as task references without checking their status, while LLP 0005 §§Lifecycle, Implementation says implementation begins once an RFC is `Accepted`. The RFC also treats choosing tasks at invocation as “human review” and defaults to pushing an unseen result directly to `origin main`. That is neither code review nor informed publication approval, especially when natural-language triggering is allowed and the repository may be shared but unprotected.

A merely clean local base can also contain unrelated unpushed commits. The default push would publish those commits despite the invariant that unrelated commits remain untouched.

**Resolution criteria:** Require proposal-shaped tasks to be `Accepted`, or stop for explicit author authorization without silently changing status. Make delivery an explicit mode such as `local`, `pr`, or `direct`; default to local or PR unless repository-local policy authorizes direct pushes. Before direct delivery, show the exact commit set, verification receipt, review receipt, upstream ahead/behind state, and destination. Build from a recorded upstream/base SHA and require explicit consent for any pre-existing local commits that would be included.

### 3.7 `llp-ship` never verifies or reviews the exact integrated tree it pushes

**Severity:** MATERIAL

**Evidence:** LLP 0010 §3 “Execute, per lane” tests and reviews each lane before merging lanes sequentially into the base, then pushes. Independently passing lanes can fail together; conflict resolutions and review-driven fixes change the diff after review; and a later failure leaves a partially mutated base. There is no final integrated test, `ref-check`, or independent review keyed to the commit being published. Parallel lanes that create LLPs also encounter the known `max + 1` collision left open by LLP 0009 §Open questions 1.

**Resolution criteria:** Record an exact starting SHA and integrate all lanes on a run-specific integration branch or worktree. Review conflict resolutions, rerun review after material fixes, run the complete aggregate validation suite on the final tree, and bind the final review and verification receipts to its commit SHA. Only then fast-forward or publish the base. Define whether multi-task delivery is atomic or permits explicitly reported partial delivery, and define renumber-on-integration behavior for concurrent LLP creation.

### 3.8 Cleanup and PR fallback are unsafe or infeasible

**Severity:** MATERIAL

**Evidence:** LLP 0010 §3 requires every created worktree and temporary branch to be removed on success, failure, or abort. A failed lane may contain dirty files or unique commits; removing its branch can destroy the only practical recovery reference and forensic state. A killed session cannot guarantee cleanup. The proposed PR fallback also requires provider-specific tooling, credentials, and a successfully pushed topic branch; an authentication or network rejection may make both the base push and PR impossible, and an open PR’s branch cannot immediately be cleaned up.

**Resolution criteria:** Persist a run-owned resource and recovery ledger before creating branches or worktrees. Clean only state that is clean and durably integrated; never remove dirty worktrees or branches with unique commits without explicit approval. On failure, preserve or archive the work, report exact branch/commit recovery instructions, and retain the pre-run base SHA. Treat PR creation as a capability-checked attempt, not a universal guarantee; unsupported delivery should end honestly as `blocked`.

### 3.9 The advertised project scope contradicts the required workflow

**Severity:** MATERIAL

**Evidence:** LLP 0010 §Open questions 3 says non-Git projects merely reduce to a sequential lane, but the promised artifact still requires branches, commits, merges, pushes, and cleanup. Section 3 also mandates the project’s tests “plus `ref-check`,” while LLP 0008 §Summary says no skill depends on `ref-check` and LLP 0001 §Phased rollout makes it optional. A general repository may also lack a test command, independent reviewer capability, `origin`, or `main`.

**Resolution criteria:** Either limit `llp-ship` to Git repositories with explicit delivery prerequisites or define a separately named local execute-and-verify contract that truthfully omits commit, merge, and publish guarantees. Add a preflight that discovers and states the base, remote, validation commands, `ref-check` applicability, reviewer availability, credentials, and task acceptance criteria before mutation. Missing mandatory capabilities must stop or produce an explicitly degraded outcome.

### 3.10 The RFC lacks an implementation and verification plan proportionate to its risk

**Severity:** MATERIAL

**Evidence:** LLP 0005 §Authoring workflow says a good RFC is specific enough to implement and ordinarily includes an implementation plan. RFC 0010 has Consequences but no phases, migration order, release sequence, acceptance criteria, fixtures, or failure tests. Its procedural commands and orchestration recipes are also not classified as normative contracts or visibly advisory recipes, contrary to LLP 0004 §Contracts over recipes and LLP 0009 §The shell.

Current CI only runs `ref-check` and a broken-reference fixture (`.github/workflows/ref-check.yml`). `ref-check` validates reference and metadata syntax; it does not validate source pins, the 60-line limit, release contents, update atomicity, review snapshots, or shipping behavior (`ref-check` lines 137–224).

**Resolution criteria:** Add independently landable phases and adversarial acceptance matrices. Installation tests should cover clean install, rerun, additions/removals, local forks, malformed or moved releases, offline/private origins, partial writes, rollback, and project/global scope. Refinement tests should cover identical snapshots, blindness, redaction, reviewer failure, non-convergence, cluster invalidation, and unauthorized status changes. Shipping tests should cover lane-pass/integration-fail, conflicts, material review fixes, remote advancement, local ahead commits, push rejection, missing reviewers, dirty aborts, and crash recovery. Mark exact commands and heuristics as advisory where appropriate, and add a deterministic release validator for manifests, pins, policy links, line caps, and tagged contents.

### 3.11 The stated distribution gap is partly stale

**Severity:** NON-BLOCKING

**Evidence:** LLP 0010 §Motivation says nothing checks pins, and §Consequences says `llp-maintain` will gain stale-pin detection. The current `skills/llp-maintain/SKILL.md` §Checks already says to note installed `source:` pins that lag upstream, matching LLP 0008 §Distribution. What is missing is reliable installation, suite reconciliation, and approved application—not all detection.

**Resolution criteria:** Correct the motivation and consequences to distinguish already-specified advisory detection from the unbuilt acquisition and update transaction. Also update `**Revised:**` whenever super-refine materially changes a document and define where current model instantiations live without baking temporary model IDs into durable family policy.

## 4. **Suggestions**

- Split RFC 0010 into three RFCs with independent acceptance and rollout. Their only commonality is that they happen to be expressed as skills; their threat models and evidence requirements are otherwise different.

- Treat skills as a content-addressed release bundle rather than unrelated markdown files. A manifest plus consumer lock/receipt could describe the canonical origin, immutable commit, exact inventory, per-tree hashes, managed-block version, compatibility schema, and local overrides.

- Put package synchronization behind a small deterministic primitive and keep `llp-update-skills` as its human-consent and explanation layer. This slightly revisits the no-CLI posture, but origin resolution, hashing, atomic replacement, and rollback are mechanical facts—the class of work LLP 0008 says the harness should compute.

- Consider `llp-super-refine` as an explicit `llp-review --mode converge` profile unless usage data demonstrates that a separate trigger materially improves reliability. Represent each run as a review-session manifest, with a dependency graph or strongly connected components determining invalidation.

- Make `llp-ship` a transaction state machine: immutable base snapshot → lane branches → integration branch → aggregate verification → final independent review → one delivery action. A persistent run ledger then supports direct push, PR, local-only delivery, resume, rollback, and crash recovery through one coherent model.

- Publish installation profiles instead of forcing eight descriptions everywhere: a small core LLP workflow, an optional advanced-review profile, and an optional delivery/operations profile.

## 5. **Open questions**

1. Which of these capabilities are genuinely part of LLP’s first-party core, and which should remain modes, consumer-local skills, or general agent tooling?

2. What is the exact installed unit: one independent skill, an eight-skill suite, or a named profile—and does `llp-adopt` install and update itself?

3. What authority establishes the trusted source and immutable release identity, and how are local forks, new skills, removals, breaking releases, and rollback represented?

4. Does `Review` continue to mean “the author opted into formal review,” or is this RFC intentionally proposing a lifecycle change? Who is authorized to grant that transition?

5. What exact payload may each external reviewer see, how is it secret-scanned and hashed, and what round, cost, time, or oscillation limit triggers human escalation?

6. What constitutes an independent code review for `llp-ship`, and how is the review bound to the exact integrated commit eventually delivered?

7. Is multi-task shipping atomic, or may successful tasks land when another task fails? What recovery state must remain in either case?

8. Is direct base-branch push ever the portable default, or should it require an explicit flag or repository-local policy after the final diff is known?

9. Is `llp-ship` restricted to Git and LLP-enabled repositories, or is a separate, weaker non-Git/non-LLP completion contract intended?

10. What empirical evidence—usage frequency, prevented failures, convergence quality, token footprint—would justify reversing the recent five-skill consolidation?

## 6. **Readiness verdict**

NOT READY — The proposal still has unresolved material defects in distribution trust and bootstrap, review lifecycle and convergence, integrated verification, publication authorization, and failure recovery.

---

## Round 2 — 2026-07-22

**Reviewer family:** GPT
**Provider / runtime:** OpenAI Codex CLI (`codex-cli 0.145.0`), model `gpt-5.6-sol`, reasoning effort `ultra`, sandbox `read-only`, session `019f8d73-f25c-7a11-b0e0-117498b55b07`
**Date:** 2026-07-22
**Redacted:** no (nothing to redact; repository markdown only)
**Method:** cli-runner (`codex exec`, non-interactive, workdir `/Users/ccheever/projects/llp`; instructed not to read `llp/reviews/0010-*`)
**Revision under review:** `llp/0010-skill-install-super-refine-ship.rfc.md`, sha256 `75929b35dcb327ba3af8c87b173340922718cfaa9e0103a1ee039c431a411fe3` (post-round-1 revision)

Orchestrator verification notes (outside the verbatim body):

- Spot-checked: the concern that the revised §2 buffered both reviews before writing either artifact is an accurate reading of the revised text, and its crash-loses-a-review consequence is real. The `Status: Draft`-during-formal-loop observation about this document itself is accurate (this loop runs under the `exact` prototype skill, which sets `Review` only at convergence). The claim citing OpenAI documentation for repo-scoped `.agents/skills` locations could not be verified offline this round and is treated as plausible-unverified; the revision responds by making the runtime-location table advisory and install-time-confirmed rather than normative.
- Disposition, "split into umbrella plus three RFCs" (concern 1): the alternative resolution branch was taken — the round-3 revision removes the per-part independence claim and makes the RFC accept or reject as one unit, with independently landable implementation phases. Splitting would create new LLPs, which exceeds this loop's authorized scope; the author can still request it.
- Disposition, "draft all three SKILL.md contracts before acceptance" (concern 10): partially adopted — the revision enumerates each contract's normative invariants in the RFC and makes contract-drafting the first step of each implementation phase, with a stop-and-report rule if any contract cannot carry its invariants within the line cap. Full pre-acceptance contract drafts were not added to the RFC.

The review body below is preserved verbatim.

---

1. **Overall assessment**

The proposal addresses real problems and contains strong safety instincts, but it combines three independently decidable systems whose lifecycle, trust, and transaction semantics are not yet complete. Installation/update is the most compelling part; `llp-super-refine` has a promising review protocol but cannot yet prove its advertised convergence; `llp-ship` needs a substantially tighter Git state machine before it is safe to implement.

2. **Strengths**

- The motivation is unusually honest. The stale-pin example is real—`skills/llp-maintain/SKILL.md` declares `v0.2.0` while HEAD differs—and the claimed benefit of super-refine is explicitly labeled experiential rather than measured (`LLP 0010 §Motivation`; `skills/llp-maintain/SKILL.md`; `LLP 0009 §Phase 4`).

- The update design correctly fails closed, protects local forks, verifies fetched bytes, presents a complete diff, and refuses to guess when verification fails (`LLP 0010 §1, “Update”`; `LLP 0008 §Distribution, “Security & trust”`).

- Profiles are a sensible response to skill-count pressure. Keeping super-refine and delivery opt-in limits always-loaded descriptions while preserving a coherent core workflow (`LLP 0010 §1, “Install”`; `LLP 0008 §Open questions, “Token footprint”`).

- Super-refine preserves the central honesty rules: reviewers are fresh and blind, both inspect the same recorded revision, the reviser never reviews, unavailable families are not silently substituted, and convergence only recommends acceptance (`LLP 0010 §2, “Round protocol” and “Bounds and escalation”; `LLP 0005 §Honesty rules`).

- The multi-document design correctly recognizes that naïve parallel review loses cross-document coherence. Clustering, lockstep rounds, and invalidating stale sibling convergence are directionally sound (`LLP 0010 §2, “Multi-document coordination”`).

- Ship correctly privileges integrated verification over lane-local success, requires a distinct reviewer, forbids force-push, preserves dirty or uniquely committed state, and incorporates orient-first and code/doc co-evolution (`LLP 0010 §3, “Execute and integrate” and “Invariants”; `LLP 0004 §Co-evolve code and docs`).

- The implementation plan is risk-ordered and includes adversarial acceptance cases—forks, moved tags, non-convergence, integration-only failures, rejected pushes, and interrupted runs—rather than testing only happy paths (`LLP 0010 §Implementation plan`).

3. **Concerns**

- **MATERIAL — One document status cannot represent three independently acceptable decisions.**

  **Evidence:** The Summary says each part may independently be accepted, deferred, or tombstoned, but the document has one `Status:` field. LLP lifecycle transitions apply to documents, not sections; LLP 0005 recommends separately numbered documents for independently reviewable sub-topics (`LLP 0010 §Summary`; `LLP 0005 §Lifecycle for RFCs` and §Large RFCs).

  **Resolution criteria:** Either split this into an umbrella plus three numbered RFCs with explicit dependencies and independent statuses, or remove the independence claim and accept or reject the design as one unit. The implementation must not infer component status from prose inside an otherwise `Accepted` document.

- **MATERIAL — The installation scope and trust model are unresolved and rely on a stale runtime assumption.**

  **Evidence:** A per-repository receipt is called the trust root while user-global installations can affect every repository; the same receipt also stores repository-specific delivery policy. Open question 4 admits that one receipt cannot safely describe both scopes (`LLP 0010 §1, “Release manifest and install receipts,” “Install,” and §Open questions 4`). Moreover, current Codex documentation identifies repository-scoped `.agents/skills` and user-scoped `$HOME/.agents/skills`; it does not make `$CODEX_HOME/skills` the only user-global location assumed by LLP 0008 and this RFC ([OpenAI, “Build skills” §Where to save skills](https://learn.chatgpt.com/docs/build-skills#where-to-save-skills); `LLP 0008 §Distribution`). A project-controlled receipt must not authorize mutation of user-global state. Finally, a manifest and payload fetched from the same tag prove mutual consistency, not publisher authenticity.

  **Resolution criteria:** Define a versioned runtime-adapter matrix with project and user scopes; colocate installation receipts with the installation they describe; move delivery policy into separate repository configuration supporting `local | pr | direct`; and prohibit repository state from authorizing global writes. State the threat model explicitly: if compromised upstream accounts/tags are out of scope, say so; otherwise require an authenticated release mechanism such as verified signed tags or an equivalent trusted channel.

- **MATERIAL — “Atomic update” and rollback are not implementable from the specified mechanism.**

  **Evidence:** The update spans skill files, additions/removals/renames, a receipt, and `AGENTS.md`, potentially across repository and user-global filesystems (`LLP 0010 §1, “Update,” step 4). Ordinary file writes cannot make that set physically atomic. Writing the receipt last still leaves partial new content that the old receipt will classify as local forks after interruption. Retaining a prior receipt preserves hashes, not the previous bytes needed for rollback. The RFC acknowledges that a deterministic synchronizer would make this mechanical but defers it (`LLP 0010 §1, “Alternatives”`).

  **Resolution criteria:** Specify a recoverable transaction protocol: hash algorithm and byte canonicalization; staging location; write-ahead journal; ownership state for forked, removed, and renamed paths; commit point; backups or guaranteed old-content retrieval; locking; and resume/rollback behavior after every possible interruption. Define whether “atomic” means physical atomicity or receipt-mediated logical atomicity. If that cannot be made portable in a ≤60-line instruction contract, add a small deterministic sync helper and narrowly revisit the no-CLI decision.

- **MATERIAL — Super-refine cannot yet prove bounded, independent convergence on one final revision.**

  **Evidence:** `READY` is syntactically required but semantically undefined, so a review could contain a material concern and still end with that token. Multi-document convergence requires “mutual consistency,” but does not require both families to issue a set-level verdict over the same final vector of hashes; the orchestrator may become the sole consistency judge (`LLP 0010 §2, “Round protocol” and “Multi-document coordination”`). Reviewers are barred only from seeing the peer’s current-round review, not prior review artifacts, author/reviser conversation, or differing repository context. Void rounds “restart,” but it is unspecified whether void, partial, malformed, failed, or cross-consistency attempts consume the three-round budget.

  **Resolution criteria:** Define `READY` as no unresolved MATERIAL correctness, coherence, feasibility, safety, or decision-quality concern. Bind both families’ per-target and set-level verdicts to the identical final hash vector. Give reviewers identical hash-manifested input bundles that exclude all target-review artifacts and reviser notes. Track every launch in a bounded attempt ledger; void, partial, failed, and malformed attempts must consume a defined budget and can never count toward convergence.

- **MATERIAL — The review artifact protocol can lose reviews that actually happened.**

  **Evidence:** The round manifest is supposed to be recorded before launch, but neither artifact is written until both results have been collected (`LLP 0010 §2, “Round protocol”`). A crash or second-family failure can therefore erase the durable record of the first completed review, contrary to LLP 0005’s rule that every review leaves an artifact. Cluster reviews are also described as verbatim while siblings receive only content the orchestrator deems relevant, creating ambiguity about editorial alteration and per-target verdicts (`LLP 0005 §Honesty rules and §Review artifacts`).

  **Resolution criteria:** Persist the round manifest before launching. Seal and hash each response immediately on receipt while withholding it from the peer; later append every received response to the canonical artifact marked complete, partial, malformed, or void. Preserve a cluster response verbatim exactly once, require reviewer-authored per-target sections and verdicts, and cross-reference it without orchestrator-authored excerpts being presented as review text.

- **MATERIAL — Blanket external-model consent and status authority are insufficiently bounded.**

  **Evidence:** One invocation authorizes every external send in every round and may change multiple documents from `Draft` to `Review`, including documents with different authors or authorization relayed by an unspecified party (`LLP 0010 §2 opening paragraph`). LLP 0005 requires external sends to be explicit human actions and preserves author authority; the existing skill prohibits status changes and external sends without explicit action (`LLP 0005 §Lifecycle and §Honesty rules`; `skills/llp-review/SKILL.md §Invariants`). A note in a skill cannot silently narrow corpus policy because skills are adapters rather than the home of policy (`LLP 0008 §Summary`; `LLP 0009 §Skills become deletable adapters`).

  **Resolution criteria:** Record authorization per target and author after disclosing the provider/runtime, exact payload, redaction policy, maximum launches, and target set. Any expansion requires renewed authorization. Define what proves relayed authority. Prefer requiring the author to set each document to `Review`; otherwise revise the authoritative lifecycle policy explicitly rather than only adding a delegation line to `llp-review`.

- **MATERIAL — Ship’s base-branch and delivery semantics are contradictory and race-unsafe.**

  **Evidence:** A single-task run may skip worktrees, `Execute and integrate` says the base always advances, but PR mode says only the integration branch is pushed. No compare-and-swap check ensures that local or remote base still equals the preflight SHA. An integration branch cut from a locally ahead base can publish unrelated pre-existing commits merely by making them remotely reachable, despite the invariant forbidding that (`LLP 0010 §3, “Trigger and preflight,” “Plan phase,” “Execute and integrate,” “Delivery modes,” and “Invariants”`). Installation records only `pr` or `direct`, so the least-privilege `local` policy cannot be persisted (`LLP 0010 §1, “Install”`).

  **Resolution criteria:** Keep base immutable during all execution, including single-task runs. PR mode must leave base untouched. Local/direct mode may advance base only by fast-forward with an expected-old-SHA check. Re-resolve local and upstream refs immediately before delivery; if either changed, reintegrate and rerun all gates or block. Compute the outbound commit closure before any push and require every newly published commit to be run-owned or specifically authorized. Persist `local | pr | direct` as repository policy and test all race cases.

- **MATERIAL — Ship lacks a final-SHA evidence and recovery state machine.**

  **Evidence:** Material review findings are “fixed and re-verified,” but re-review of the changed commit is not explicit, so the review may not cover the final SHA (`LLP 0010 §3, “Execute and integrate”`). The run ledger lives in an unspecified scratch area with no schema, locking, state transitions, reconciliation source, or definition of “durably integrated” (`§3, “Plan phase” and “Invariants”). Multi-task failure semantics are also absent: it is unclear whether one failed lane blocks the batch or permits silent partial delivery. This repository’s canonical verification includes both a successful `ref-check` and a deliberately failing fixture, illustrating why “tests plus ref-check” is not itself a complete suite description (`.github/workflows/ref-check.yml`).

  **Resolution criteria:** Define a SHA-indexed state machine such as `PREPARED → CANDIDATE(SHA) → VERIFIED(SHA) → REVIEWED(SHA) → DELIVERED`. Any commit, formatter mutation, conflict fix, base change, or review fix invalidates both gates. The reviewer must not implement its own findings; fixes return to an implementing session and the replacement SHA is re-reviewed. Define a durable ledger schema and location, reconcile it against authoritative Git refs/worktree metadata, and specify crash recovery. Make multi-task delivery atomic by default, requiring renewed human approval and full re-gating for any reduced subset.

- **MATERIAL — The `Accepted` gate and parallel LLP-number handling are not safe as written.**

  **Evidence:** `Task gating` requires `Accepted` and then immediately permits “ship it anyway” while leaving status unchanged, knowingly creating implementation from a document still claiming to be unsettled (`LLP 0010 §3, “Task gating”; `LLP 0005 §Lifecycle and §Implementation`; `LLP 0004 §Living documents`). The integration plan also resolves parallel `max + 1` collisions by renumbering at merge. A missed reference to the renamed document can silently resolve to the other lane’s colliding LLP, so `ref-check` may pass while the reference points to the wrong rationale (`LLP 0010 §3, “Execute and integrate”; `LLP 0009 §Open questions 1`; `ref-check`).

  **Resolution criteria:** Require author-applied `Accepted` before any base/PR delivery. If speculative implementation is desired, define a non-delivering experiment mode. Prevent number collisions through serialized allocation, reserved lane ranges, or temporary identities resolved at integration; then update code references, metadata, prose references, and task mappings, with an acceptance test proving no semantically misbound reference survives.

- **MATERIAL — The contract/recipe boundary and the new skill partition are not justified.**

  **Evidence:** Consequences declares “everything procedural above” advisory, but the design sections present much of it as protocol without the required recipe marker (`LLP 0010 §Consequences`; `LLP 0004 §Contracts over recipes`; `LLP 0009 §The shell`). It is therefore unclear whether same-revision review, lane isolation, update ordering, and exact-SHA gates are binding or optional. `llp-super-refine` also has the same trigger domain, posture, artifacts, and hand-offs as `llp-review`, while LLP 0008 explicitly favors modes where posture is shared (`LLP 0010 §2`; `LLP 0008 §The five skills`; `skills/llp-review/SKILL.md`). Exact model pins are unmarked shell content despite LLP 0008 saying review configuration should name families rather than pinned IDs.

  **Resolution criteria:** Separate each section into an explicit normative contract and visibly marked advisory recipe. Draft all three actual ≤60-line `SKILL.md` contracts before acceptance to demonstrate that no safety rule is lost. Prefer `llp-review --mode super-refine`; if a separate skill remains, add a concrete “Why a separate skill” argument grounded in distinct trigger/posture/artifact evidence. Move model/runtime defaults into dated advisory configuration or per-run provenance.

- **NON-BLOCKING — The RFC’s own stated prototype does not match the proposed protocol’s labels.**

  **Evidence:** Metadata says `Status: Draft` while `Revised:` says it completed round 1 of “super-refine,” although §2 says that invocation changes the status to `Review`. The same line names `.fable` and `.codex` artifacts, while the protocol requires family-named artifacts and itself describes Fable as a model and Codex as a runtime (`LLP 0010 metadata and §2`; `LLP 0005 §Review artifacts`).

  **Resolution criteria:** State that the cited round was a pre-protocol prototype and does not count as a conforming acceptance test, or reconcile the status and canonical family names. Before acceptance, run and cite one test under the final protocol without relying on the prototype.

- **NON-BLOCKING — Expanding `ref-check` is in tension with its current boundary.**

  **Evidence:** `ref-check` is already 247 lines, while LLP 0009 targets a ≤250-line single-purpose checker, and LLP 0004 says new capabilities should be composable stages rather than monolithic expansion (`LLP 0010 §Consequences`; `LLP 0009 §The one program`; `LLP 0004 §Composable pipelines over monolithic tools`).

  **Resolution criteria:** Either demonstrate a refactored `ref-check` that retains its size and purpose, or implement release validation as a separate composable `skill-release-check` stage.

4. **Suggestions**

- Split the proposal and promote by evidence: installation/update first; super-refine as an `llp-review` mode; ship as an experimental delivery-profile skill until its transaction tests pass.

- Model installation as a lockfile plus scoped runtime adapters: one repository policy file, one receipt per physical installation, and one append-only transaction journal.

- Treat each super-refine `READY` result as a revocable lease on an exact input-hash vector, not a permanent property of a document. For oversized clusters, record review coverage over the document dependency graph’s edges.

- Model ship as a SHA-indexed transaction. Git refs and `git worktree list --porcelain` should remain authoritative; the ledger should record intent and evidence rather than becoming a competing source of truth.

- Reserve LLP numbers before parallel lane execution, or use temporary lane-local identities and allocate final numbers only during integration.

- Consider separating a generic harness-owned task-shipping engine from a thin LLP adapter that adds orient-first, lifecycle gating, co-evolution, and `ref-check`. This would keep LLP’s first-party surface focused while making the general workflow reusable.

- Turn the RFC’s evidence obligation into explicit promotion gates: invocation/misfire counts for skill partitioning, convergence/round statistics for super-refine, and prevented publication/recovery failures for ship.

5. **Open questions**

- Are the three parts intended to have genuinely independent lifecycle statuses, and if so why are they one RFC?

- What threat model does skill update cover: accidental drift and transport corruption only, or compromised upstream accounts/tags as well?

- What are the authoritative installation scopes and locations for each supported runtime, and where do repository policy and installation receipts live?

- What precise transaction and recovery algorithm makes an interrupted multi-file update safe?

- Does super-refine authorization cover named providers and a fixed payload/budget, or any later “strongest available” reviewer?

- What exactly constitutes `READY` for a document set, and must both families issue a set-level verdict over the same final hash vector?

- Are reviewers prohibited from seeing all prior target-review artifacts, or only the peer’s current-round response?

- Is super-refine materially a separate trigger/posture/artifact, or simply a high-intensity mode of `llp-review`?

- Is a multi-task ship invocation atomic by default, and when does PR mode become `done`: PR creation, required-check completion, or merge?

- What local ref, remote, target branch, and expected old SHA define ship’s compare-and-swap boundary?

- Where does the ship ledger live, what state transitions does it record, and what reachability condition permits cleanup?

- Is independent code review mandatory for every ship run or configurable by repository policy and stakes?

- What usage evidence is sufficient to satisfy LLP 0009 Phase 4 before expanding the first-party system from five skills to eight?

6. **Readiness verdict**

NOT READY

Unresolved material concerns remain in lifecycle granularity, update trust and atomicity, review consent and convergence, and Git delivery safety.
---

## Round 3 — 2026-07-22

**Reviewer family:** GPT
**Provider / runtime:** OpenAI Codex CLI (`codex-cli 0.145.0`), model `gpt-5.6-sol`, reasoning effort `ultra`, sandbox `read-only`, session `019f8da5-2e1c-7790-a6ff-250c15c249d5`
**Date:** 2026-07-22
**Redacted:** no (nothing to redact; repository markdown only)
**Method:** cli-runner (`codex exec`, non-interactive, workdir `/Users/ccheever/projects/llp`; instructed not to read `llp/reviews/0010-*`). A first round-3 attempt was killed before producing output; per the never-fabricate rule it is not counted or recorded as a review — this session is the round-3 review.
**Revision under review:** `llp/0010-skill-install-super-refine-ship.rfc.md`, sha256 `a8da7b53bb891f4068f4af7e9c5b6a698b1c88acab92a54aa3a024f1baebbf7c` (post-round-2 revision; same revision as Fable round 3)

Orchestrator verification notes (outside the verbatim body):

- Spot-checked and **confirmed** decision-level defects: concern 5's authorization contradiction is real (§1 forbids repo state authorizing external writes; §3 treats recorded policy as push authorization); concern 8's `Accepted`→`Active` gap is real (ship completes implementations but never applies the factual lifecycle transition LLP 0005 defines); concern 9's Phase-2 standalone docs phase does contradict the RFC's own co-evolution commitment; concern 3's non-Draft-target gap matches Fable round 3's independent finding; concern 4's blindness-mechanism gap matches Fable round 3's C1 (both families converged on a review-capsule/exclusion fix).
- Disposition under the author's altitude direction (given 2026-07-22, mid-loop): the author directed that demands resolving only to additional specification detail — without identifying a defective decision — are implementation-phase material, and that document growth is bounded. Accordingly, the decision kernels of concerns 1, 2, 6, and 7 are adopted as one-to-two-sentence invariants (single-flight exclusivity per installation/repo; revalidate approved state immediately before mutating; any fork aborts a coupled update; truthful mode-specific partial outcomes — never `blocked` after a successful external effect; REVIEWED requires an explicit no-material-findings verdict bound to the exact SHA; verification runs on clean checkouts). The remaining machinery those concerns specify (lock/lease formats, journal state tables, private-ref event logs, receipt schema fields, attestation stores, failure-injection matrices) is dispositioned to the implementation phases, where the contract-first rule and acceptance tests govern it. Concerns 10 and 11 repeat round-2 items already dispositioned (contracts drafted per-phase with a blocking-finding escape; one-unit acceptance reaffirmed by the author's process direction).

The review body below is preserved verbatim.

---

## 1. **Overall assessment**

The proposal contains three genuinely valuable ideas: receipt-backed skill installation, a bounded dual-family refinement loop, and exact-commit delivery gates. The motivation is credible, and the RFC shows unusually good instincts about honesty, author authority, fail-closed behavior, and preserving recoverable work.

It is not yet a good implementation plan. All three systems depend on durable control state, but that state is underspecified in the places where correctness matters most: concurrent updates, external-model authorization, crash recovery, shared worktrees, and partially completed remote delivery. Several guarantees are therefore stronger than the mechanisms supporting them. The design should be revised around explicit state machines, immutable input snapshots, compare-and-swap ownership, and truthful partial outcomes.

## 2. **Strengths**

- The distribution problem is real and concretely demonstrated. The repository confirms that `skills/llp-maintain/SKILL.md` changed after `v0.2.0` while retaining that source pin, exactly as described in `LLP 0010 §Motivation`.

- Recording both a human-readable tag and its resolved commit is sound. Failing closed when the old tag moved, the target cannot be fetched, or content cannot be verified is the correct posture (`LLP 0010 §1 “Releases and receipts”` and “Update”).

- Rejecting a same-tree hash manifest is well reasoned: Git supplies content integrity, while an in-tree manifest would not add authenticity. Keeping release validation separate from the deliberately narrow `ref-check` also follows composable-pipeline guidance (`LLP 0010 §1 “Alternatives”`; `LLP 0004 §Composable pipelines over monolithic tools`; `ref-check`).

- Folding update into `llp-adopt` preserves the important posture boundary: `llp-maintain` detects and proposes, while an explicitly approved adoption/update operation may apply (`LLP 0010 §1 “Update”; LLP 0008 §The five skills`).

- The separation between advisory `llp-review` and applying `llp-super-refine` is principled. Super-refine still cannot accept a document on the author’s behalf (`LLP 0010 §2 “Authorization”; LLP 0005 §Lifecycle for RFCs`).

- Super-refine’s fresh sessions, family diversity, verbatim artifacts, explicit malformed-response handling, launch caps, and exact final hash-vector objective are strong design choices (`LLP 0010 §2 “Round protocol,” “Bounds and escalation,” and “Multi-document coordination”`).

- Ship’s exact-SHA invalidation rule is excellent. Requiring every new commit, formatter change, or conflict resolution to re-enter verification and review prevents stale evidence from being reused (`LLP 0010 §3 “Execute, integrate, gate”`).

- The non-delivering experiment mode, outbound-closure check, prohibition on silent stashing and force-pushing, and preservation of dirty worktrees or unique commits are appropriately conservative (`LLP 0010 §3 “Task gating,” “Delivery modes,” and “Invariants”`).

- The contract-first stop rule is the right response to LLP 0009: if the invariants cannot survive in a readable ≤60-line adapter, implementation stops instead of silently weakening policy (`LLP 0010 §Consequences`; `LLP 0009 §Skills become deletable adapters`).

## 3. **Concerns**

1. **MATERIAL — The installation transaction is neither concurrency-safe nor completely recoverable.**

   **Evidence:** The update protocol checks installed hashes, presents a diff, backs up files, moves staged files, and writes the receipt as the commit point (`LLP 0010 §1 “Update”`). It defines no per-installation lock, expected-old-receipt compare-and-swap, or revalidation after approval. Two updaters can therefore interleave, or a user can edit a file between the hash check and the move, allowing the updater to overwrite a newly created fork. Journal phases, atomic receipt replacement, deletion of newly added paths during rollback, and recovery-before-new-run behavior are also unspecified. Consequently, “the old receipt plus backups always suffice” is not established.

   **Resolution criteria:**

   - Define one exclusive lock or lease per canonical installation.
   - Bind approval to a digest of the old receipt and complete target inventory, then revalidate both immediately before mutation.
   - Require recovery or rollback of an existing journal before another update begins.
   - Define durable journal states covering preparation, completed backup, application, receipt commit, and cleanup, including whether every path previously existed.
   - Atomically replace journals and receipts and mutate only receipt-owned paths that still match their expected state.
   - Treat unreceipted collisions, unexpected file types, and symlink/path escapes as aborting conflicts.
   - Add kill-point tests at every state transition, two-updater tests, and an edit-between-approval-and-apply test.

2. **MATERIAL — The receipt cannot represent the mixed installations the update algorithm permits.**

   **Evidence:** A forked file is excluded while the remaining files update, after which one receipt records one release tag and commit; two lines later, the RFC says skills are a coupled release and updates apply the whole set (`LLP 0010 §1 “Update”`). A locally forked `llp-adopt` can therefore remain based on release A while its peers move to release B, although the receipt appears to describe release B. The schema also records one singular profile even though `review-plus` and `delivery` appear independently additive, and one example receipt path cannot distinguish multiple runtime installations in the same repository (`LLP 0010 §1 “Install receipts” and “Install”; LLP 0008 §Distribution`).

   “Newest” is likewise undefined: eligible tag namespace, semantic ordering, prereleases, downgrade and ancestry rules, cross-major compatibility, and old-updater/new-receipt compatibility are absent.

   **Resolution criteria:**

   - Prefer aborting the whole coupled update when any managed file is forked; offer explicit replace, preserve, or merge preparation before retrying.
   - If mixed state remains supported, record per-file upstream baseline, actual installed hash, fork status, and compatibility state, and never report the profile fully updated.
   - Define a versioned receipt schema keyed by installation identity, including runtime, scope, canonical destination, profile set, managed path inventory, origin, tag, resolved commit, hash algorithm, file type/mode, receipt schema, and updater protocol version.
   - Define profile composition, addition, removal, and downgrade behavior.
   - Define eligible release tags, ordering, ancestry, prerelease policy, cross-major confirmation, and self-update compatibility.
   - Reconcile the receipt’s coupled-release meaning with `source:`-pin staleness detection in `skills/llp-maintain/SKILL.md §Checks`.
   - Test multiple runtimes in one repo, global plus project-local installs, profile transitions, and mixed/forked states.

3. **MATERIAL — Super-refine’s authorization and lifecycle boundary are incomplete.**

   **Evidence:** LLP 0005 currently requires external-model sends to be explicit human actions, and the current `llp-review` contract stops before arranging further external input (`LLP 0005 §Honesty rules`; `skills/llp-review/SKILL.md §§Invariants–Workflow`). LLP 0010 changes this to one invocation authorizing many sends, but supplies only a paraphrase of the future LLP 0005 amendment. A non-author may establish authority merely by stating whose authorization they relay. The authorization names targets and a redaction policy, but reviewers later receive “the repo,” so the actual exposed files are not bounded.

   The loop revises targets but does not reject `Accepted`, `Active`, `Superseded`, or `Tombstoned` documents, despite LLP 0005 requiring an addendum or new LLP for material post-acceptance changes. Multi-target loop startup can also crash after changing only some statuses.

   **Resolution criteria:**

   - Include the exact proposed LLP 0005 amendment and limit bounded preauthorization specifically to this formal loop unless ordinary `llp-review` is intentionally changed too.
   - Record durable human authorization containing run ID, every author or delegated authority source, targets, topology, exact providers/runtimes, reviewer-visible file allowlist, redaction transform, and hard launch/cost cap.
   - Do not accept an agent’s unsupported assertion of relayed authority.
   - Require renewed authorization for any provider, runtime, input scope, topology, target, redaction, or cap expansion.
   - Make the workflow explicitly human-invoked and non-auto-triggering where runtimes support that control.
   - Permit revision only for `Draft` or already-`Review` targets; route later statuses to an addendum or new LLP.
   - Make authorization recording and all initial status transitions a recoverable loop-start operation completed before any reviewer launch.

4. **MATERIAL — Super-refine’s blindness, evidence, crash, concurrency, and budget guarantees are not implementable as written.**

   **Evidence:** Only target hashes are recorded, although reviewers see broader repository context, prompts, instructions, and redacted content (`LLP 0010 §2 “Round protocol”`). Changes to governing documents can therefore alter the review without changing the recorded hash vector. Persisting one family’s review into a shared working tree also makes it visible to another running reviewer unless access is mechanically isolated.

   Prelaunch manifests are written into family review artifacts even though LLP 0005 and the current review contract define those as artifacts of reviews actually received. A crash after provider completion can still lose a response held only in process memory. Independent sub-orchestrators have no per-target ownership, artifact-append CAS, or atomic launch-quota reservation.

   Finally, a cluster too large for reviewer attention is split, yet convergence still requires full-set verdicts over the complete hash vector. Per-document round budgets and per-target launch caps do not define how one cluster call, void round, retry, or mandatory consistency pass is charged (`LLP 0010 §2 “Bounds and escalation” and “Multi-document coordination”`).

   **Resolution criteria:**

   - Build one immutable, read-only review capsule per round containing the exact target bytes, governing context, prompt/instruction version, and redaction transform; exclude `.git`, prior review artifacts, ledgers, and orchestrator notes.
   - Hash the complete capsule and bind both family verdicts to that digest.
   - If redaction removes load-bearing material, prohibit an unqualified `READY` verdict for the unredacted source.
   - Put authorization and operational state in a separate run journal rather than pre-creating review artifacts.
   - Durably reserve each launch before sending, stage raw responses before acknowledging receipt, and import them exactly once into append-only family artifacts.
   - Add ordered per-target leases or equivalent CAS and atomically reserve launch quota across sub-orchestrators.
   - Specify one accounting table for cluster calls, independent calls, retries, voids, unknown outcomes, and consistency passes, reserving capacity for the final pass.
   - Reject oversized full-set reviews or explicitly define a weaker hierarchical guarantee; do not claim whole-set review when no reviewer saw the whole set.
   - Add crash, concurrent-invocation, duplicate-response, and blindness-canary acceptance tests.

5. **MATERIAL — The repository policy has a direct authorization contradiction.**

   **Evidence:** Section 1 says repo-local state “MUST NOT authorize writes outside the repo,” immediately after defining `.llp/policy.json`. Section 3 then treats recorded `pr` or `direct` policy as sufficient authorization to push or create a PR (`LLP 0010 §1 “Install”; §3 “Delivery modes”`). A stale, malicious, or task-modified repository file can therefore appear to escalate a run to external writes. Policy precedence, the trusted revision from which policy is read, and the exact permitted remote/ref are undefined.

   **Resolution criteria:**

   - Make repository policy a displayed default or ceiling, not sufficient authority for external writes; require explicit same-run human authorization for `pr` and `direct`.
   - Alternatively, narrow “outside the repo” explicitly and supply a defensible trust model for repository-authorized remote writes.
   - Read policy from the recorded base commit and show any working-tree discrepancy.
   - Define an authority lattice in which system, organization, and runtime restrictions dominate; task text never grants authority.
   - Bind each external action to an exact remote name, fetch/push URL, base ref, provider/runtime, and redaction posture, and revalidate those facts immediately before acting.

6. **MATERIAL — Ship’s ledger and delivery operations need a recoverable saga, not an implied transaction.**

   **Evidence:** `.llp/ship-runs/<run-id>.json` is a working-tree example with no canonical shared location, lock, CAS, atomic-write rule, or single-writer semantics (`LLP 0010 §3 “Plan phase”`). It can dirty the base, differ among worktrees, or enter the candidate accidentally. The required run-owned commit set, delivery intent, remote response identifiers, and gate attestations are not explicitly persisted.

   Local and remote base advancement cannot be atomic. A local-first direct delivery can leave local base advanced after push rejection; a remote-first delivery can succeed before a crash or failed local update. PR delivery has a similar push-success/PR-creation-failure window. Retrying without reconciliation can duplicate external effects, while reporting `blocked` after a successful push is false. `DELIVERED` also conflates local advancement, PR publication, and remote base advancement.

   Number reservation only serializes lanes inside one invocation; it does not resolve collisions with another ship run, clone, or human, despite claiming to resolve LLP 0009 OQ1 for this workflow.

   **Resolution criteria:**

   - Place operational state in the Git common directory or a private Git-ref namespace shared across worktrees and excluded from candidate history.
   - Use append-only or CAS state transitions and persist task snapshots, planned and created refs/worktrees, run-owned commits, gate evidence, delivery intent, external identifiers, and terminal facts.
   - Model delivery as an idempotent saga with explicit partial states; reconcile local refs, advertised remote refs, and existing PRs before retrying.
   - Define which side is authoritative after partial direct success and how the other side is repaired.
   - Define newly reachable commits relative to freshly advertised refs on the pinned remote and require every such commit to be run-owned or explicitly authorized.
   - Use mode-specific terminal facts such as `LOCAL_BASE_ADVANCED`, `PR_OPENED`, and `REMOTE_BASE_ADVANCED`.
   - Narrow number-reservation safety to one invocation or add a shared reservation mechanism with a declared same-clone or cross-clone scope.
   - Add concurrent-run and crash-after-each-external-operation tests.

7. **MATERIAL — `VERIFIED(SHA)` and `REVIEWED(SHA)` do not yet prove a deliverable commit.**

   **Evidence:** `REVIEWED` is defined as a review having occurred, not as an explicit verdict that no material concern remains. The run report need only contain findings and dispositions, not the verbatim review, exact scope, provenance, or durable evidence of reviewer independence (`LLP 0010 §3 “Execute, integrate, gate”`).

   “Full verification suite” is also undefined: command discovery, no-test repositories, skipped checks, timeouts, and failures are not specified. Tests or formatters can mutate tracked files without changing the candidate SHA, so a command can pass on a working tree different from the commit that will be delivered.

   **Resolution criteria:**

   - Replace `REVIEWED` with a pass condition requiring an explicit verdict of no unresolved material finding, or a specifically recorded human waiver.
   - Persist the verbatim review, prompt/scope, exact base and candidate SHAs, reviewer provenance, independence assertion, verdict, and dispositions before granting the gate.
   - Freeze the verification command list and its authoritative source during preflight.
   - Define no-tests, skipped, timeout, malformed, and unavailable outcomes.
   - Run verification and review against clean isolated checkouts and verify index/tracked-tree cleanliness before and after every command.
   - Store content-addressed verification and review attestations keyed by `(base SHA, candidate SHA)`.
   - Require every new candidate SHA to obtain new attestations.

8. **MATERIAL — Task gating and document lifecycle do not cohere.**

   **Evidence:** Ship gates only RFCs, Plans, and Specs by type, while LLP 0005 applies to any document proposing a design others will implement. A proposal-shaped Issue or Decision can bypass the rule. Linear and filesystem tasks are mutable but are not snapshotted, and task contents are not explicitly subordinate to human and repository policy (`LLP 0010 §3 “Trigger and preflight,” “Task gating,” and “Plan phase”; LLP 0005 §Summary`).

   More seriously, ship “never changes a document’s status,” but a completely implemented `Accepted` proposal should become `Active`. Leaving it `Accepted` after local or direct delivery violates LLP 0005’s lifecycle and LLP 0004’s co-evolution rule; fixing it later requires an ungated follow-up commit (`LLP 0005 §Lifecycle for RFCs`; LLP 0004 §Co-evolve code and docs`).

   **Resolution criteria:**

   - Snapshot every task’s content, source, and revision/hash in the run ledger.
   - Treat task content as requirements, never as authorization to expand scope or external effects.
   - Gate proposal-shaped LLPs semantically, regardless of metadata type, while recognizing that an explicit human free-text instruction may itself authorize implementation.
   - Define eligibility for every lifecycle state.
   - Distinguish author-only approval transitions from the factual `Accepted → Active` transition.
   - Specify how complete versus partial implementations and PR versus local/direct outcomes update or defer `Active` without violating co-evolution.
   - Include any justified status update in the exact candidate that is verified, reviewed, and delivered.

9. **MATERIAL — The implementation phases violate the RFC’s own co-evolution promise and omit critical acceptance cases.**

   **Evidence:** Phase 1 changes `llp-adopt` installation behavior, while Phase 2 defers LLP 0008/0009/README/AGENTS reconciliation. This contradicts both `LLP 0010 §Consequences` and `LLP 0004 §Co-evolve code and docs`. Phase 2 would advertise super-refine and ship before Phases 3 and 4 implement them. It also omits LLP 0001, the active guide underlying `llp-adopt`. The LLP 0005 authorization change is scheduled before the super-refine implementation despite §2 saying they land together.

   Acceptance tests cover useful happy paths, but not simultaneous updates/runs, filesystem containment, every crash point, local/direct partial success, remote-identity changes, mutating or absent tests, malformed reviewer results, policy escalation, status activation, or cross-run numbering collisions.

   **Resolution criteria:**

   - Eliminate the standalone documentation phase.
   - Land each feature with its contract, governing LLP revisions, active guide changes, README/AGENTS index, hand-offs, release metadata, and tests in the same coherent phase and tag.
   - Land the LLP 0005 authorization amendment only with the conforming super-refine implementation.
   - Add a failure-injection matrix covering every durable-state and external-action boundary.
   - Require tests to prove that every interruption ends in an old, new, recoverable, or truthfully partial state; no unique commit is lost, no stale gate survives, and no unauthorized commit becomes reachable.

10. **NON-BLOCKING — The ≤60-line adapter constraint is plausible but unproven for these state machines.**

    **Evidence:** The current contracts are 39–48 lines; `llp-adopt` is already 40 lines. Super-refine and ship introduce substantially more authorization, recovery, and gate invariants than the present skills (`skills/*/SKILL.md`; LLP 0010 §Consequences`).

    **Resolution criterion:** Draft all three revised contracts before acceptance, verify the physical line limit and policy citations, and confirm that every high-salience MUST remains visible without compressing unreadable pseudo-code into long lines.

11. **NON-BLOCKING — Accepting all three systems as one decision has weak decision granularity.**

    **Evidence:** The RFC says it is accepted as one unit while its phases land independently and a component may later be cut. Section 3 also acknowledges that ship is a general task engine only incidentally LLP-specific (`LLP 0010 §Summary, §Implementation plan, and Open question 3`). Installation, formal document refinement, and remote code delivery have different evidence, risk, and adoption timelines.

    **Resolution criterion:** Prefer an umbrella document plus independently accepted child RFCs, or state a concrete invariant that makes all-or-nothing acceptance necessary. At minimum, keep the install profile additions experimental until each has its own observed-use evidence.

12. **NON-BLOCKING — Contract and recipe classification is not consistently visible.**

    **Evidence:** The opening rule says Invariants and MUST statements are contract, while advisory mechanics are recipe. Several load-bearing round, transaction, and gate bullets are neither labeled advisory nor phrased as MUST; conversely, topology heuristics and current-model defaults are mixed into normative-looking sections (`LLP 0010 §Summary and §§1–3`; LLP 0004 §Contracts over recipes`).

    **Resolution criterion:** Label each protocol subsection normative or advisory. Keep authorization, containment, exact-input binding, boundedness, evidence, recovery, and delivery safety normative; mark model selection, topology heuristics, telemetry fields, and tuning defaults as advisory recipes.

## 4. **Suggestions**

- Use one common control-state pattern across all three systems: immutable input snapshot, append-only event journal, compare-and-swap ownership, content-addressed evidence, and explicit terminal or partial states. The domains remain separate, but reviewers and implementers learn one recovery model.

- Add a small release descriptor without file hashes. Git supplies integrity; the descriptor can carry profile membership, release channel, receipt schema, minimum updater protocol, and supported runtime adapters without recreating the rejected manifest.

- Use private Git refs for ship state and possibly super-refine run state. A ref pointing to an event-log commit or blob is shared across worktrees, does not dirty candidate history, and supports expected-old updates.

- Replace `local | pr | direct` as the primitive policy with capabilities such as `update_local_base`, `push_run_branch`, `open_pr`, and `push_base`. Modes can remain named presets, while policy intersection and escalation become explicit.

- Bind review and verification to content-addressed attestations. Super-refine verdicts bind to a complete review-capsule digest; ship attestations bind to `(base SHA, candidate SHA)`.

- Make the high-risk skills manually invocable in runtimes that support such metadata, with behavioral confirmation as the portable fallback.

- Treat local forks as merge inputs, not partially updated live installations: generate a merge candidate or patch, leave the installation untouched, and rerun after resolution.

- Turn the acceptance plan into a failure-injection matrix derived from each state transition. This is a better fit for the proposal’s actual risks than a list of representative scenarios.

## 5. **Open questions**

1. Are `review-plus` and `delivery` composable capability flags, mutually exclusive profiles, or a hierarchy?

2. What exactly identifies an installation and determines its canonical receipt location across runtime, project/user scope, and destination root?

3. Does any fork abort a coupled update, or is mixed state intentionally supported and represented?

4. What is an eligible release tag, what does “newest compatible” mean, and how does an old self-updater cross a receipt or protocol version boundary?

5. What durable evidence proves an author or delegate authorized a super-refine run, and exactly which files may leave the machine?

6. Can the reviewer runners durably stream responses, or must the “completed review survives a crash” guarantee be weakened?

7. If a multi-document set cannot fit in one reviewer’s effective context, should the invocation be rejected or should the guarantee explicitly become hierarchical rather than full-set?

8. Is concurrency promised only among lanes, among invocations in one clone, or across clones and humans?

9. Does invoking `/llp-ship` authorize implementation only, or also pushing a branch, opening a PR, or pushing the base?

10. What constitutes the full verification suite, and may a repository with no trustworthy tests deliver?

11. When exactly does `Active` become true in local, direct, and PR workflows, especially for partial implementations?

12. If portable shell/Git primitives cannot reliably implement these state machines through a ≤60-line adapter, is a small deterministic state helper an acceptable narrow revision to LLP 0008/0009’s no-CLI decision?

13. What evidence threshold should move super-refine and ship from experimental profiles to recommended first-party workflows: convergence quality, prevented failures, recovery success, cost, or some combination?

## 6. **Readiness verdict**

NOT READY — Unresolved material contradictions in authority, transaction and concurrency semantics, evidence binding, crash recovery, remote delivery, lifecycle handling, and phase coherence prevent the proposal’s safety guarantees from being correct or testable as written.
---

## Round 4 — 2026-07-22

**Reviewer family:** GPT
**Provider / runtime:** OpenAI Codex CLI (`codex-cli 0.145.0`), model `gpt-5.6-sol`, reasoning effort `ultra`, sandbox `read-only`, session `019f8db9-ba59-7040-86a6-d510c2650e12`
**Date:** 2026-07-22
**Redacted:** no (nothing to redact; repository markdown only)
**Method:** cli-runner (`codex exec`, non-interactive, workdir `/Users/ccheever/projects/llp`; instructed not to read `llp/reviews/0010-*`; prompt included the document's altitude rule, identically for both families this round)
**Revision under review:** `llp/0010-skill-install-super-refine-ship.rfc.md`, sha256 `4cffd06d7c271640cbd9d5339b641861d3485367aea02455c6fb3f1c35bafaa5` (post-round-3 revision; same revision as Fable round 4, which returned READY)

Orchestrator verification notes (outside the verbatim body):

- Spot-checked and **confirmed** as decision-level defects introduced by earlier revisions: the partial-delivery contradiction ("never `blocked` after a succeeded effect" vs. "PR-creation failure ends the task `blocked`") is verbatim in the round-4 revision; the fork-resolution path does contradict the coupled-release sentence beside it; the `Accepted` → `Active` application does conflict with LLP 0005's "no tool changes Status unilaterally" without an amendment; LLP 0009 is absent from the co-evolution list while 0001/0005/0008 are present; and the authorship-vs-disclosure-authority gap is real (this document's own metadata lists an AI co-author).
- Disposition: all six MATERIAL concerns adopted as decision-level fixes in the round-5 revision (LLP 0009 added to the supersession/co-evolution list; egress authority separated from document authority with targets never redacted — undisclosable targets stop the loop; verdicts bound to the capsule hash; fork-keeping defined as detaching the file from the managed set with the remainder coupled; ship now *proposes* `Accepted` → `Active`, never applies it; delivery reports per-effect facts so a blocked task never conceals a succeeded effect). The evidence demand inside concern 1 (observed usage before expansion) remains held by OQ1/OQ5 as in prior rounds' dispositions.

The review body below is preserved verbatim.

---

1. **Overall assessment**

This is a strong, unusually safety-conscious proposal. Installation receipts close a real distribution gap; super-refine turns a proven practice into an auditable protocol; and ship’s exact-SHA gates address recurring delivery failures well. The implementation phases are concrete and testable.

It is not ready as written, however. Several load-bearing rules conflict with existing LLP policy or with other clauses in this RFC. The most important gaps concern external-disclosure authority, truthful review coverage under redaction, forked-install semantics, lifecycle authority, and partial-delivery state.

2. **Strengths**

- The updater specifies meaningful safety outcomes rather than pretending file copying is trivial: full diffs, approved-state revalidation, no clobbering of local changes, write-nothing verification failures, recoverability, and a receipt commit point (LLP 0010 §1, “Update,” steps 3–5). The current `skills/llp-maintain/SKILL.md` still declares `source: ccheever/llp@v0.2.0` while differing from that tag, so the provenance gap in §Motivation is real.

- Folding update into `llp-adopt` preserves the important posture boundary—`llp-maintain` proposes while `llp-adopt` applies approved changes—and follows LLP 0008 §“Modes instead of more skills.”

- Super-refine preserves the essential LLP 0005 authority boundary: explicit invocation opts a target into review, while convergence remains only a recommendation and never accepts a document (§2, “Authorization”). Its immediate artifact persistence, failed-response accounting, reviewer blindness disclosures, launch caps, and exact-revision verdicts are strong applications of LLP 0005 §“Honesty rules.”

- The round protocol is notably rigorous: both families receive the same capsule, reviewer sessions are fresh, no session reviews a revision it edited, malformed reviews do not count, and multi-document verdicts bind to a declared revision vector (§2, “Round protocol” and “Multi-document coordination”).

- Ship’s immutable base, namespaced branches, clean-checkout verification, independent integrated-diff review, expected-old-SHA delivery, outbound-closure check, and preservation of unique commits form a credible safety kernel (§3, “Execute, integrate, gate” and “Invariants”).

- The risk-ordered phases have unusually good acceptance scenarios, including interrupted updates, approval/apply races, asymmetric review outcomes, integration-only failures, base movement, and partial external effects (§Implementation plan).

- Keeping release validation out of `ref-check` preserves the checker’s deliberately narrow deterministic role (`ref-check`, lines 8–20; LLP 0004 §“Composable pipelines over monolithic tools”).

3. **Concerns**

- **MATERIAL — The RFC reverses LLP 0009’s active architecture without reconciling it.**

  **Evidence:** LLP 0009 §Summary and §“The shell” classify distribution machinery as capability-graded shell. Its cuts replace package-manager-like vendoring and skew machinery with informational pins, its accepted skill architecture contains five skills, and its Phase 4 leaves real-consumer evidence as the outstanding proof obligation. LLP 0010 instead introduces releases, profiles, receipts, per-file hashes, coupled transactions, journals, and seven total skills (§Summary, §1, and §Consequences). It schedules updates to LLP 0001, 0005, and 0008, but not LLP 0009. The current README §Skills and all five existing contracts reflect the active five-skill design.

  **Resolution criteria:** Explicitly identify which LLP 0009 decisions this RFC supersedes; apply the capability test separately to durable facts such as release identity, authorization, no-clobbering, and recovery versus replaceable mechanics such as tag selection, receipt schema, and staging; provide the observed evidence that justifies reversing the prior tradeoff or label Phase 1 as a reversible pilot; and update LLP 0009 in the implementing phase so two active documents do not give conflicting guidance.

- **MATERIAL — Document authorship is incorrectly treated as repository-disclosure authority.**

  **Evidence:** §2 “Authorization” says the author’s invocation authorizes every external-model send, while “Round protocol” defines the capsule as an export of the tree. An LLP author may be an AI co-author, contributor, or contractor without authority to disclose repository contents; this RFC itself lists `Charlie Cheever / Claude` as authors. Redacting secrets does not address confidential source, licensed material, or other non-secret disclosure restrictions. LLP 0005 §“Honesty rules” requires external sends to be explicit human actions, not merely actions attributable to any metadata author.

  **Resolution criteria:** Separate document authority from data-egress authority. Status/revision authorization may come from the document author, but each provider and outbound data scope must be authorized by a named human principal or durable repository policy with disclosure authority. Default capsules should contain only targets and explicitly selected governing evidence, with the exact outbound inventory shown before launch. Missing authority must stop the send.

- **MATERIAL — Redaction is incompatible with the unqualified exact-hash convergence claim.**

  **Evidence:** §2 permits default redaction, records both original target hashes and a capsule hash, defines `READY` without a visibility qualification, and later says both families’ final verdicts cover the exact final target hash vector. A reviewer cannot review target bytes or relevant context it was not shown. Claiming otherwise overstates what occurred, contrary to LLP 0005’s honesty rule.

  **Resolution criteria:** Bind verdicts to the canonical reviewer-visible capsule and sanitized target hashes. Record exclusions or a deterministic redaction mapping, scope `READY` to visible material, and never claim full-target coverage when target content was withheld. Alternatively, prohibit target redaction and stop when a target cannot be disclosed.

- **MATERIAL — Per-file fork resolution contradicts the coupled-release invariant.**

  **Evidence:** §1 “Update,” step 3 says any receipt mismatch aborts because mixed-release installs are unsupported, but offers “keep the fork and stop tracking that file” as a resolution path. Updating the remaining profile after untracking one member produces exactly the mixed managed/unmanaged state the preceding sentence prohibits, and target-profile completeness can no longer be verified.

  **Resolution criteria:** Choose one coherent model: keeping a fork detaches and freezes the entire installation; the fork is moved outside the managed profile while a conforming member is restored; or a supported override layer is designed with explicit compatibility and receipt semantics. Per-file untracking must not silently resume a supposedly coupled update.

- **MATERIAL — Ship’s automatic `Accepted` → `Active` transition conflicts with current lifecycle policy.**

  **Evidence:** LLP 0005 §“Lifecycle for RFCs” says no tool changes status unilaterally, and LLP 0008 §Non-goals likewise says status transitions are proposed rather than applied. Section 3 “Task gating” creates an exception for ship, but the generic task invoker need not be the LLP author or lifecycle owner. Whether a candidate “completely implements” a design is judgment-bearing, and the current REVIEWED gate only asserts that no material code-review finding remains; it does not expressly certify completeness against the LLP. The planned LLP 0005 amendment covers super-refine authorization only.

  **Resolution criteria:** Either make ship propose the transition, or require explicit authorization from the document’s author or designated lifecycle owner and add a completeness verdict against the accepted LLP. Amend LLP 0005 and LLP 0008 to document the exception and its authority boundary.

- **MATERIAL — Partial external success has contradictory terminal semantics.**

  **Evidence:** §3 “Delivery modes” says a run is “never `blocked` after an external effect actually succeeded,” then says a successful branch push followed by PR-creation failure ends the task `blocked`. Section 3 “Invariants” offers only done, blocked, or failed per task. These rules cannot all hold and leave retry behavior ambiguous.

  **Resolution criteria:** Define orthogonal task, run, and external-effect states—for example, task `blocked`, run `PARTIAL`, effect `branch-pushed`—or choose one unambiguous terminal rule. The ledger must record each effect independently, and retries must reconcile those facts before acting.

- **NON-BLOCKING — Contract and recipe content is not consistently classifiable at a glance.**

  **Evidence:** The Summary classifies `MUST` clauses and Invariants lists as contract and marked examples as recipe, but authorization, status refusals, capsule equality, task gating, and delivery rules also appear as unmarked declarative prose. LLP 0004 §“Contracts over recipes” requires immediate classification.

  **Resolution criteria:** Label complete blocks as contract or advisory recipe and audit every safety-critical declarative sentence for explicit normative status. This is non-blocking at RFC altitude because it need not change a decision.

- **NON-BLOCKING — The current lifecycle metadata needs clarification.**

  **Evidence:** The RFC remains `Draft`, while its `Revised:` field and §2 note describe three rounds of invocation-authorized dual-family prototype review. LLP 0005 defines `Review` as the formal-loop status, although the note also says the prototype was non-conforming.

  **Resolution criteria:** The author should either move the document to `Review` or explicitly characterize the prior rounds as informal prototype feedback that did not constitute an LLP 0005 formal loop.

4. **Suggestions**

- Split this into an umbrella plus separately accepted distribution, super-refine, and ship RFCs. Their implementation timelines and failure domains are independent, and `llp-ship` is already acknowledged as only incidentally LLP-specific.

- Express each new capability as a small safety kernel plus a separately versioned advisory strategy profile. Authorization, provenance, no-clobbering, exact-SHA gates, and recovery belong in the kernel; round counts, growth percentage, reviewer selection, and worktree topology should remain tunable recipes.

- Preserve each reviewer-visible capsule as a retrievable Git object, commit, or compact bundle rather than retaining only its hash. A hash identifies lost evidence but cannot reconstruct it.

- Model delivery as an append-only effect ledger. Facts such as `branch_pushed`, `pr_opened`, `remote_base_advanced`, and `local_base_reconciled` compose better than a single overloaded terminal status.

- Add acceptance cases for altered receipt origins, actual migration from the released v0.2.0 contract, user-global installations shared by conflicting repositories, unauthorized co-author invocation, redacted target content, lifecycle-transition refusal, and every partial delivery ordering.

5. **Open questions**

1. What observed consumer evidence is sufficient to overturn LLP 0009’s decision that distribution machinery is deletable shell?
2. Who is authorized to approve external disclosure, and how is that authority represented portably across repositories and runtimes?
3. Is convergence a claim about original targets, sanitized targets, or the complete reviewer-visible capsule?
4. What supported state results when a consumer intentionally forks one managed skill file?
5. How are versions and profile flags arbitrated when a runtime provides only one user-global skill directory shared by many repositories?
6. Who decides that an Accepted LLP is completely implemented, and what evidence must the reviewer examine before `Active` is justified?
7. Should `llp-ship` become a generic delivery engine with a thin LLP adapter rather than part of the LLP skill family?
8. Are the three-round, 20% growth, and two-revision asymmetry defaults strategy telemetry to tune, or intended long-lived policy?

6. **Readiness verdict**

NOT READY

The RFC has unresolved material conflicts in governing-policy reconciliation, authorization, review coverage, update consistency, lifecycle authority, and partial-delivery semantics.
---

## Round 5 — 2026-07-23

**Reviewer family:** GPT
**Provider / runtime:** OpenAI Codex CLI (`codex-cli 0.145.0`), model `gpt-5.6-sol`, reasoning effort `ultra`, sandbox `read-only`, session `019f8dc6-a347-7290-875d-ab06c643e7da`
**Date:** 2026-07-23
**Redacted:** no (nothing to redact; repository markdown only)
**Method:** cli-runner (`codex exec`, non-interactive, workdir `/Users/ccheever/projects/llp`; instructed not to read `llp/reviews/0010-*`; prompt included the document's altitude rule, identically for both families this round)
**Revision under review:** `llp/0010-skill-install-super-refine-ship.rfc.md`, sha256 `e6d5b5e5693f5cc06972a18733b29b2812bc077f61a2f48a17671820085064e1` (post-round-4 revision; same revision as Fable round 5, which returned READY — the Fable family's second consecutive READY)

Orchestrator verification notes (outside the verbatim body):

- **Loop terminal state: sustained asymmetric disagreement.** Under the author's mid-loop direction (one family READY on two consecutive revisions while the other is NOT READY on both → stop and escalate), this round ends the loop. No further rounds were run; the disagreement, concern dispositions, and proposed next steps were escalated to the author in the session report.
- Spot-checks: concern 1 is **confirmed** — the quoted LLP 0005 amendment sentence ("An author's explicit invocation … authorizes that loop's external-model sends…") does contradict the two-authority separation in the same section; a wording defect introduced in round 5's revision. Concern 4's premise (a PR merger need not be the document author) is correct. Concern 2 identifies a genuine design tension in the detachment rule; concern 3's scope point (non-git task effects unmodeled) is fair; concern 5 is a policy-philosophy disagreement (mandatory review as invariant vs. capability-graded intensity) on which the two families now disagree directly — Fable round 5 rated the same design READY.
- Standing cross-family dissent, recurring in all five Codex rounds and absent from Fable's later rounds: split the RFC into independently accepted documents. Dispositioned each round to one-unit acceptance per the author's process direction; recorded here as unresolved reviewer dissent for the author's final decision.

The review body below is preserved verbatim.

---

1. **Overall assessment**

This is a strong proposal addressing three real workflows. Installation/update has a compelling observed need; super-refine is unusually rigorous about review honesty; and ship’s exact-SHA gates are substantially safer than ad hoc agent execution. The implementation phases and adversarial acceptance tests are also excellent.

The parts are not equally ready. Several authorization and compatibility rules contradict the guarantees they are meant to enforce, particularly around external disclosure, ship effects, lifecycle authority, and per-file detachment. Those are RFC-level decision defects, not requests for implementation detail. `llp-ship` is the least mature and least intrinsically LLP-specific component, making the all-or-nothing acceptance boundary costly.

2. **Strengths**

- The distribution gap is real and correctly scoped. Repository history confirms the motivating example: `skills/llp-maintain/SKILL.md` changed after `v0.2.0` while still declaring that source pin, and `ref-check` correctly does not treat release drift as its responsibility. This supports LLP 0010 §Motivation and preserves the narrow validator boundary in LLP 0009 §The one program.

- The install transaction specifies the right safety outcomes: receipt-scoped ownership, local drift detection, full-diff approval, immediate pre-mutation revalidation, recoverability to either endpoint, and “cannot verify → write nothing” (LLP 0010 §1, “Releases and receipts” and “Update,” steps 3–5).

- The trust model is candid rather than overstated. It distinguishes accidental drift and transport corruption from compromised upstream identity, detects moved tags, and calls the receipt an editable attestation rather than proof (LLP 0010 §1, “Releases and receipts”).

- Super-refine strongly operationalizes LLP 0005’s honesty rules. Pre-launch round persistence, capsule and target hashes, structural blindness where possible, immediate artifact writes, failed-launch accounting, exact-byte verdict binding, and prohibition on reviewer/reviser identity overlap make the review claim auditable without pretending provenance is cryptographic proof (LLP 0010 §2, “Round protocol”; LLP 0005 §Honesty rules and §Review artifacts).

- Super-refine mostly preserves author sovereignty: convergence is a recommendation, never acceptance; material disagreement is escalated instead of adjudicated by the orchestrator; and terminal status dispositions remain author actions (LLP 0010 §2, “Authorization” and “Bounds and escalation”; LLP 0005 §Lifecycle for RFCs).

- Ship’s `CANDIDATE(SHA) → VERIFIED(SHA) → REVIEWED(SHA) → DELIVERED` model is excellent. Clean-checkout verification, reviewer/implementer separation, re-gating after findings, base re-resolution, expected-old-SHA updates, and outbound-commit-closure checks are strong invariants (LLP 0010 §3, “Execute, integrate, gate”).

- Partial external success is represented truthfully. Recording `branch-pushed` even when PR creation fails avoids collapsing a non-atomic external workflow into a false success/failure binary (LLP 0010 §3, “Delivery modes”).

- The implementation plan is risk-ordered and meaningfully adversarial. Interrupted updates, edit-after-approval races, asymmetric reviews, integration-only failures, moved bases, partial remote success, and preservation of unique commits are valuable acceptance cases (LLP 0010 §Implementation plan).

- The contract-first rule and same-phase documentation reconciliation directly respect the thin-adapter and co-evolution principles (LLP 0010 §Consequences; LLP 0004 §Co-evolve code and docs; LLP 0009 §Skills become deletable adapters).

3. **Concerns**

- **MATERIAL — Super-refine’s proposed policy sentence contradicts its own two-authority model.**

  **Evidence:** LLP 0010 §2, “Authorization,” first distinguishes document-author authority from repository-disclosure authority, requires both, and correctly states that an AI co-author is never disclosure authority. The exact sentence proposed for LLP 0005 then says an author’s invocation “authorizes that loop’s external-model sends and revisions.” Authorship therefore grants egress in the policy home even when the author lacks disclosure authority. This also conflicts with LLP 0005 §Honesty rules and `skills/llp-review/SKILL.md §Invariants`, which require external disclosure to be an explicit human action.

  **Resolution criteria:** Separate the normative authorities. Author invocation may authorize target selection, `Review`, and revision scope; external sends require recorded authorization from a human holding repository-disclosure authority for the outbound inventory, providers, redaction posture, and maximum launch/egress budget. One invocation may satisfy both only when the invoker explicitly acts in both capacities. Add a negative acceptance case in which author authority exists but disclosure authority does not, and nothing is sent.

- **MATERIAL — Per-file detachment recreates the mixed-release state that coupled updates prohibit.**

  **Evidence:** LLP 0010 §1, “Update,” step 3 says a fork aborts the update because skills reference one another and mixed-release installations are unsupported. It then permits an arbitrary file to be detached permanently while updated managed files continue to load beside it, calling the remainder “a complete coupled set … minus its detached members.” Ownership labels do not provide compatibility. The current contracts already contain cross-skill hand-offs throughout `skills/llp-adopt/SKILL.md`, `llp-create`, `llp-orient`, `llp-maintain`, and `llp-review`; detaching `llp-adopt` can additionally strand the updater itself.

  **Resolution criteria:** Choose a coherent compatibility boundary: detach/fork the entire profile; remove or namespace detached members so they are not part of the loaded runtime set; or define a stable dependency/compatibility contract and permit only dependency-closed detachment. Without a validated boundary, any detached member must block further managed updates or convert the installation to fully user-managed. Phase 1 must test an upstream cross-skill change after detachment.

- **MATERIAL — Ship’s authority model does not safely cover either its default delivery behavior or its generic task scope.**

  **Evidence:** The invocation syntax makes `--mode` optional; the repo policy is simultaneously called a default and ceiling but “not itself authorization”; and with no policy the default becomes `pr`, which pushes a branch and opens a PR (LLP 0010 §1, “Install”; §3, “Trigger and preflight” and “Delivery modes”). Merely stating a derived mode at preflight is not affirmative authorization. Ship also accepts Linear tickets, LLPs, filesystem tasks, and free text, while modeling authority only for git delivery. Such tasks can entail deployments, database mutations, package publication, tracker changes, or other effects. The correct rule that task content cannot grant authority leaves those effects unauthorized but not explicitly unsupported. Reviewer egress is similarly absent from ship’s preflight model.

  **Resolution criteria:** Separate suggested default, allowed-mode policy, and per-run authority. A bare invocation may plan and prepare a local candidate but must not create an external effect until the exact mode and effect inventory are affirmatively approved, unless the invocation explicitly named that mode. Either restrict ship to repository mutations plus the specified git delivery effects, blocking everything else, or inventory and authorize every external system separately with reconciliation rules. Reviewer provider/trust boundary and any additional disclosure must also be included. Add negative tests for bare invocation, task-embedded authority, undisclosed reviewer egress, and an unapproved non-git effect.

- **MATERIAL — PR-mode `Active` promotion can bypass the document author.**

  **Evidence:** LLP 0010 §3, “Task gating,” says ship never applies lifecycle transitions and that status belongs to the author, but then permits ship to create an `Accepted → Active` commit whose merge is endorsed by “the human merging.” The merger need not be the LLP author. LLP 0005 §Lifecycle for RFCs says the author decides and no tool changes status unilaterally.

  **Resolution criteria:** Keep promotion report-only unless the document author has durably authorized that exact status edit. A merger may apply it only when they are the author or the project has explicitly delegated lifecycle authority to them. Add an acceptance case showing that a non-author merger cannot promote the document merely by merging the implementation PR.

- **MATERIAL — Ship classifies a model-error-prevention mechanism as an invariant without justifying why it survives the capability test.**

  **Evidence:** LLP 0010 §3 blocks delivery when no reviewer is available and calls REVIEWED a same-family “error-catching pass.” Its Invariants make that pass mandatory. LLP 0004 §The capability test and LLP 0009 §The shell classify mechanisms that exist to prevent model error as capability-graded recipe, while LLP 0009 §The review norm fixes honesty but deliberately does not fix review intensity. Exact-SHA binding and truthful evidence are durable; an unconditional second-model error-catching quota is not yet shown to be.

  **Resolution criteria:** Either define REVIEWED as a durable separation-of-authority/governance attestation required even for a flawless implementer, explaining who relies on it and why, or make review intensity an explicit repo/run policy and mark the same-family pass as capability-graded. Whenever review is selected, exact-SHA binding, reviewer independence, and honest reporting can remain invariant.

- **NON-BLOCKING — Holistic and compositional multi-document readiness need distinct semantics.**

  **Evidence:** LLP 0010 §2, “Round protocol,” requires final per-target and set-level verdicts to bind to one capsule. “Multi-document coordination” permits oversized clusters to be split because no reviewer can inspect the whole set with adequate attention and correctly forbids claiming a whole-set review that did not occur. It nevertheless uses the same convergence/READY terminology for the resulting per-loop-plus-consistency-pass assurance.

  This is non-blocking at RFC altitude because compositional review is a coherent decision; the remaining problem is accurately specifying its claim.

  **Resolution criteria:** Give the result a distinct label such as `COMPOSITIONALLY READY`, persist a coverage graph showing which targets and dependency edges each capsule/verdict covered, and bind every component to the final hash vector. If ordinary READY is intended to mean holistic review, oversized clusters must instead refuse global convergence.

- **NON-BLOCKING — The tagged release still needs a mechanically extractable profile inventory and installation identity.**

  **Evidence:** A tag authenticates a tree’s bytes, but it does not by itself identify which paths constitute each profile. LLP 0010 §1 derives membership, adds, removals, and renames from the target tag’s natural-language adopt contract. LLP 0008 §Summary assigns mechanical facts to exact harness operations. In addition, the receipt fields omit runtime and canonical target path even though LLP 0008 §Distribution permits independently drifting installations for multiple runtimes.

  This is implementation-phase material because the no-separate-authentication-manifest decision remains feasible.

  **Resolution criteria:** Before Phase 1 ships, define a canonical profile inventory, schema version, installation identifier, runtime/scope, and target root. This can be a strict tagged Markdown block, path convention, or tiny data file; it need not claim authenticity beyond the containing git tag.

- **NON-BLOCKING — Local/direct delivery can prune the only durable gate evidence.**

  **Evidence:** LLP 0010 describes ship ledgers as local and prunable, while local/direct review findings, verification results, and verdicts live only in that ledger (§1, “Releases and receipts”; §3, “Execute, integrate, gate” and “Delivery modes”). After pruning, a directly delivered SHA can retain no inspectable evidence of the gates.

  **Resolution criteria:** Preserve a compact immutable attestation keyed to the delivered SHA before pruning—task snapshot identifiers, verification commands/results, reviewer provenance/verdict, dispositions, and external effects—while allowing bulky logs and recovery state to remain prunable. Alternatively, explicitly narrow the claimed long-term audit guarantee.

4. **Suggestions**

- Split this into an umbrella plus independently accepted installation, super-refine, and ship RFCs, or at least justify the all-or-nothing acceptance dependency. The implementation phases are expressly independent, and ship has a different evidence base, risk profile, and domain boundary from the other two (LLP 0010 §Summary and §Implementation plan).

- Define a shared, local run charter or capability envelope used by super-refine and ship: target/base hashes, author authority, disclosure authority, permitted providers or git/external effects, launch/effect budget, expiry, and effect ledger. Hash it into capsules and reports. This would unify authorization rather than letting each skill invent a subtly different model.

- Replace per-file detachment with an immutable managed baseline plus an explicit whole-profile overlay. Updates can attempt to reapply the overlay against the new baseline and block on conflicts without pretending the result is an untouched coupled release.

- Separate ship’s evidence into three composable attestations: mechanical verification, independent design/code review, and human release authority. Repositories could require the appropriate combination without conflating “tests passed,” “a reviewer approved this SHA,” and “someone authorized publication.”

- Keep release and workflow recipes in the corpus, with skills pointing to them. LLP 0010 §Consequences currently places a release checklist in the adopt contract’s recipe; LLP 0004 §Contracts over recipes and LLP 0009 §The shell prefer the corpus as the recipe’s home.

- Pilot `llp-ship` as an experimental generic delivery protocol before making it a first-party LLP skill. Its LLP-specific layer is relatively thin: orient, Accepted gating, co-evolution, and `@ref` handling. A generic engine plus thin LLP adapter may be a cleaner eventual boundary.

- Record whether the `exact` adoption satisfies LLP 0009 Phase 4’s outstanding empirical proof obligation. If it does, publish the Research LLP; if not, state why adding two more shell skills before that evidence is justified.

5. **Open questions**

- How is document-author authority established when metadata lists multiple human and AI co-authors, and what durable evidence proves disclosure authority without pretending the metadata authenticates anyone?

- What exact maximum number of sends and bytes is disclosed before super-refine begins, including failed, void, retry, and cross-consistency launches?

- Is ship intentionally limited to repository changes and git delivery, or is it intended to execute arbitrary external task effects?

- Can policy express “default local, PR allowed, direct forbidden,” or is the single default-and-ceiling value intentionally less expressive?

- Who may authorize `Active`: only the named author, a role delegated in repo policy, or any maintainer who merges the implementation?

- What is the supported compatibility unit for installations: file, skill directory, profile, or whole release?

- Does READY mean one reviewer inspected the entire final target set, or may it represent a composition of per-target and dependency-edge verdicts?

- Why must every ship delivery receive a same-family model review, and what observation would allow that requirement to be relaxed under the capability test?

- What audit evidence must survive ship-ledger reconciliation and pruning, especially after direct delivery?

- What concrete usage evidence would justify retaining, simplifying, or removing super-refine and ship under LLP 0010 §Open questions and LLP 0009 Phase 4?

6. **Readiness verdict**

NOT READY

The RFC still has unresolved material contradictions in disclosure and lifecycle authority, coupled-update compatibility, and ship’s effect and review policy.