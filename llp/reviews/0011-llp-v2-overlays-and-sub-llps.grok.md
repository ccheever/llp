# Reviews of LLP 0011 + LLP 0011.000 — xAI (Grok) family

Lockstep cluster (RFC + its curation-pass guide). Every round section is the reviewer's output verbatim; orchestrator notes are marked as such.

## Round 1 — 2026-08-22

**Provider / runtime:** Grok CLI (`~/.grok/bin/grok`), model `grok-4.6`, reasoning effort `xhigh`, `--permission-mode dontAsk --no-plan --no-subagents --disable-web-search`, headless `--output-format streaming-json`
**Method:** cli-runner; instructions + targets + governing context inlined in one 173 KB prompt file with a full terminal ban. *Orchestrator note:* the CLI offloaded the oversized prompt to its own session store and the model read it back with its `read_file` tool in six chunks (the only tool calls; all targeting its own prompt file — no terminal, no other file access). The first two sentences of the body are the model narrating that. Exit 0; body = concatenated `text` events. Final turn usage: 26,277 output tokens of which 24,153 reasoning.
**Revision reviewed:** commit `ceafa66`; 0011 sha256 `14d25242728854ee02b0ff6b2918b827b4a55dffa3b50f45d2b467eb894e581c`, 0011.000 sha256 `53d1d7efad64cec51871babcab61c83961441f38897e12bc3a89f9042c37d59d`; capsule `a6836bf5644b85333634e5b1c196d7bd9eb15c16ce81ec4a7202038252015589` (tree minus `llp/reviews/`, plus `OVERLAYS.txt`); instructions sha256 `b3e6607b8f1eb3b951a3b67500d2ba53a4a3f90eb6be7cb94d411574612569b8`.
**Blindness:** structural — the capsule contained no review artifacts. Same instructions to both families; altitude rule included.

### Review (verbatim)

The full review capsule was truncated in the message; I'll load the offloaded prompt so the review is based on the complete inlined text.The rest of the capsule is still offloaded; I’ll keep loading the prompt file so the review covers the truncated sections.## Summary

LLP v1 mixed “not under discussion” with “wrong” by moving files, and it gave related RFC/spec/plan documents no identity relationship except `Related:`. v2 splits those axes cleanly: dotted sub-numbers as fixed-at-birth names, `Status:` as truth, and two symlink overlays as attention versus kernel. Normative rules in LLP 0000, overlay/parent gates in `ref-check`, and the create/orient/maintain skills line up with the RFC on the rules that are supposed to be mechanical. The curation guide actually implements the three verbs the RFC names, in the claimed order, as propose-only recipe around those rules. Remaining gaps are portability and edge-case specification, not a broken split of the design.

## Concerns

1. **Severity:** DETAIL · **Target:** both · **Claim:** Overlay membership is specified as POSIX symlinks and hard-gated with `os.path.islink`, with no decided fallback for git-on-Windows (symlinks checked out as text files), zip/capsule transport, or an emptied `current/` that git will not track. · **Evidence:** LLP 0011 **Overlays**: “contain only symlinks into `llp/` (relative, so they survive a repo move).” `ref-check`: “if not os.path.islink(entry): … overlay entry is not a symlink.” LLP 0011.000 **Archive**: archive is `rm` the link; overlays “hold links, not documents,” so a `.gitkeep` would fail the same gate. The capsule’s `OVERLAYS.txt` already exists “in case symlinks did not survive transport.” · **Resolution criteria:** State the portability contract (git symlink support required, or accept a regular file whose contents are the relative target). Exempt dotfiles or otherwise keep empty overlay dirs representable in git. Have `llp-create` create `llp/current/` if it is missing.

2. **Severity:** DETAIL · **Target:** 0011 · **Claim:** Compatibility overclaims a clean drop of the tombstone exemption and does not record the amendment to LLP 0009’s kernel lifecycle. · **Evidence:** LLP 0011 **Compatibility**: “`llp/tombstones/` | Removed. … `ref-check` drops the exemption.” LLP 0000 **Types and statuses** and `ref-check` still exempt Tombstoned *bodies* from `@ref` validation; what was dropped is the directory skip. LLP 0009 **The kernel**, item 3, still says “tombstones under `llp/tombstones/`.” LLP 0010’s addendum on 0009 is the existing pattern for this kind of kernel edit; 0011 **Related** lists 0009 but **Compatibility** does not. · **Resolution criteria:** Say that the path exemption is replaced by a status exemption, and add a Consequences/Compatibility row that 0009 kernel item 3 is amended to status-only lifecycle.

3. **Severity:** DETAIL · **Target:** both · **Claim:** “Flat corpus” is written as a hard location rule and as “subdirectories remain allowed” at the same time. · **Evidence:** LLP 0011 **Summary**: “Every LLP lives directly under `llp/`, forever.” Same document, **Flat corpus, status-only lifecycle**: “Subdirectories under `llp/` remain allowed for human grouping (LLP 0000 never required flatness)… this repo stops using them.” LLP 0000 **Filesystem organization** repeats both sentences. `ref-check` walks nested `llp/` dirs and only reserves `current/`, `foundation/`, and `reviews/`. · **Resolution criteria:** Make the contract one sentence: path is not lifecycle; grouping dirs are meaningless but valid; this repo happens to be flat. Keep reserved names.

4. **Severity:** DETAIL · **Target:** 0011.000 · **Claim:** The foundation admission test is pointed at the right question but is not yet operational enough to pick a stable kernel, and the guide only names the over-inclusion failure. · **Evidence:** LLP 0011.000 **Promote**: “would deleting this, with the rest of foundation and the code intact, lose something unrecoverable?” LLP 0009 **Model assumptions** A6: rationale is information the code does not contain, so “plus the code” can be read as emptying foundation or as promoting every unique Active spec. **Anti-patterns** covers “Foundation as a trophy case” but not a kernel so small that orientation misses still-binding Active specs (the binding reminder is only in **Realign**). LLP 0011 **Open questions** item 1 correctly defers a size ceiling. · **Resolution criteria:** Define what must remain recreatable (design intent, not a runnable tree). Add the too-small failure. One worked pass on this corpus would satisfy the RFC’s own proof obligation.

5. **Severity:** DETAIL · **Target:** 0011.000 · **Claim:** The advisory staleness glob does not match sub-LLP filenames, so the heuristic as written will not see `0011.000-…`. · **Evidence:** LLP 0011.000 **Archive**, recipe: ``git log -1 --format=%cs -- llp/NNNN-*``. LLP 0011 **Sub-LLP numbering**: identity is `NNNN(.NNN)*-slug.type.md`. · **Resolution criteria:** Key the path off the full dotted number (or a glob that includes dots), still as a prompt rather than a rule.

6. **Severity:** DETAIL · **Target:** context(0000/ref-check) · **Claim:** Two overlay rules are stated in 0000 and 0011 but are not what `ref-check` actually gates, and §6’s short list drops `Superseded`. · **Evidence:** LLP 0011 **Overlays**: links are “relative”; LLP 0000 **Filesystem organization**: “The root document … is always in `foundation/`.” `ref-check` resolves with `os.path.abspath` and does not reject absolute links or a missing Root entry. LLP 0000 **§6 Validation**: “overlay entries are symlinks to non-tombstoned LLPs and foundation entries are Active”; **Current and foundation** (and `ref-check`) also ban `Superseded`. · **Resolution criteria:** Either gate relative links and Root-in-foundation, or stop saying “all” of those rules are gated. Mention `Superseded` in the §6 sentence.

7. **Severity:** MINOR · **Target:** both · **Claim:** Naming the attention overlay `current/` collides with `Active` as “current guidance,” which is the confusion the RFC is trying to retire. · **Evidence:** LLP 0000 **Types and statuses**: Active is “Current guidance,” then “Note that ‘not current’ is not a status.” LLP 0011 **Motivation**: the two questions are “is anyone thinking about this right now?” vs “are its claims still true?” · **Resolution criteria:** Keep the two overlays; consider `in-play/` (or similar) so “current” is not doing both jobs. Not blocking.

8. **Severity:** MINOR · **Target:** context(0000) · **Claim:** The lead numbering sentence is still v1-only and then contradicted by the sub-LLP paragraph. · **Evidence:** LLP 0000 **Numbering**: “identified by zero-padded numbers: `LLP 0000` through `LLP 9999`. Filenames follow the pattern `NNNN-slug.type.md`,” immediately followed by “The full grammar is `NNNN(.NNN)*-slug.type.md`.” · **Resolution criteria:** Lead with the full grammar; keep `NNNN-slug.type.md` as the zero-depth case, matching LLP 0011 **Compatibility**.

## Strengths

- The three-axis split is the right design: identity (dotted number, fixed at birth, never reused), truth (`Status:`), attention (`current/`), kernel (`foundation/`). That is the actual fix for tombstones conflating “idle” with “wrong.”
- Forbidding re-parenting, and making children independent lifecycle units, is what keeps sub-numbering from becoming taxonomy. Do not add reserved child ranges.
- Normative overlay/parent/status rules live in LLP 0000; 0011.000 is correctly a guide; the three-verb order and “unrecreatable without,” not “important,” are pinned as `llp-maintain curate` invariants. That is the 0004/0009 split done properly.
- `ref-check` matches the claimed mechanical gates: dotted uniqueness, parent exists, overlay entries are links to corpus LLPs, `Tombstoned`/`Superseded` in neither overlay, foundation is `Active`, Tombstoned bodies skipped. The broken-ref fixture is aimed at those new failures.
- Filename, header, `@ref LLP NNNN#anchor`, and the status *set* stay additive. Grouping directories still validate. Tombstone migration is a one-time move, then nothing moves again.
- Alternatives considered (underscore separator, copies/digests, dropping `Tombstoned`, keeping `tombstones/` beside overlays) are real, and the rejected options really are worse.

## Verdicts

**0011:** READY — The overlay/sub-LLP/status split is coherent with LLP 0000/0004/0009, and the mechanical rules match `ref-check` and the skills; leftover issues are specification and portability, not a wrong decision.

**0011.000:** READY — Promote → archive → realign, in that order, with propose-only output, is the procedure the RFC describes; the admission test needs sharpening but is not an infeasible choice.

**Set:** READY — No unresolved MATERIAL concern in capsule `a6836bf5644b85333634e5b1c196d7bd9eb15c16ce81ec4a7202038252015589`.

## Round 2 (delta round) — 2026-08-22

**Provider / runtime:** as round 1.
**Method:** as round 1, plus: received `DELTA.diff` (ceafa66→c46cdd2) and this family's own round-1 punch list only. *Orchestrator note:* prompt again offloaded by the CLI and read back via `read_file` (5 calls, all its own prompt file); the leading narration sentences are the model's.
**Revision reviewed:** commit `c46cdd2` (r2); 0011 `fb859be2fd25a3e21cc801f93ded5ce803860495bd9be274695cc02f88193c09`, 0011.000 `5b764484eaac460c092895d1e6b9d4480c777676467fb5c58d4a14ea90d48087`; capsule `214b70aed287970243017f7215fd2d2cd3507ac47de306f448edefff08c99a0c`.

### Review (verbatim)

I'll read the offloaded prompt file so the review can follow the required format using the full documents and punch list.The prompt was truncated mid-diff; I'll keep reading the rest of the inlined documents.The remaining governing docs and punch-list details are still further down; I'll keep reading them.I'll continue through the remaining skills, AGENTS.md, README, and the rest of the diff.I'll pull the remaining skill files, AGENTS.md, and README so I can check those against the punch list.## Punch list verification

1 · PARTIAL · Overlay portability is specified and gated (relative path-content files, fixture, `ref-check`), but `AGENTS.md` still requires “relative symlinks only” and `llp-orient` still treats overlays as “symlink directories.”
2 · VERIFIED · LLP 0009 kernel item 3 now strikes `llp/tombstones/` and cites 0011’s status-only lifecycle; 0011 states that the v1 path exemption becomes a status exemption.
3 · PARTIAL · The rule is now “path is not lifecycle,” with grouping subdirectories valid-but-meaningless and this repo flat by choice, but the 0011 title and LLP 0000 `**Revised:**` still name the third change a “flat corpus.”
4 · VERIFIED · LLP 0000 now defines a set-level design-recreation admission test (not a runnable tree; history is not kernel; too-small fails; never pairwise), and 0011.000 Promote steps 2, 4, and 5 restate it.
5 · VERIFIED · The Archive staleness heuristic now globs `"llp/<full dotted number>-"*` with the dotted example `llp/0011.000-*`.
6 · VERIFIED · Overlay entries must be relative; Root belongs in `foundation/` from the moment it is `Active`; §6 and the gated-rules paragraph allow `Superseded` in `current/` and forbid it in `foundation/`, matching `ref-check`.
7 · VERIFIED · Alternatives considered records a different name than `current/` and keeps `current/` as an author’s choice.
8 · VERIFIED · Numbering now leads with the filename grammar `NNNN(.NNN)*-slug.type.md`; the old “0000 through 9999” lead sentence is gone.

## Concerns

1. **Severity:** MATERIAL · **Scope:** IN-DELTA · **Target:** 0011.000 · **Claim:** Archive still forbids `Superseded` from both overlays, which undoes the r2 rule that a migration in progress may sit in `current/`. · **Evidence:** 0011.000 §Archive step 3: “Tombstoned and Superseded documents can't be in either overlay — unlink them.” LLP 0000 §Current and foundation: “`Superseded` documents may appear in `current/` (a migration in progress is work) but not in `foundation/`.” 0011 §Overlays: “`Superseded` allowed in `current/` because a migration is work.” · **Resolution criteria:** Restate step 3 to match the gated rules: `Tombstoned` in neither overlay; `Superseded` out of `foundation/` always, and out of `current/` only when the migration is no longer in play.

2. **Severity:** DETAIL · **Scope:** IN-DELTA · **Target:** 0011.000 · **Claim:** Several 0011.000 lines still speak the r1 overlay meanings that this revision replaced. · **Evidence:** §Archive Goal: “`current/` contains exactly what someone is thinking about.” §Anti-patterns: “Current is what's being thought about”; trophy-case still uses “unrecreatable without.” §Promote Goal: “from which the project could be recreated” (no “design”). Contrast LLP 0000’s declared working set and design-recreation admission test. · **Resolution criteria:** Align those goal/anti-pattern lines with the declared-working-set and design-recreation wording, or mark them as loose slogans of that contract.

3. **Severity:** DETAIL · **Scope:** IN-DELTA · **Target:** context(AGENTS.md, llp-orient, llp-maintain, 0000 tree) · **Claim:** Adapter and ambient restatements were not updated to the r2 overlay representation or admission test. · **Evidence:** `AGENTS.md` §LLP documents: “hold relative symlinks only.” `skills/llp-orient/SKILL.md` §Workflow: “both are symlink directories”; “the root LLP is always there.” `skills/llp-maintain/SKILL.md` §Invariants: “admission test (unrecreatable without it).” LLP 0000 §Filesystem organization tree comments: “symlinks: what's being worked on” / “symlinks: the kernel.” · **Resolution criteria:** Restate overlays as relative links (symlink or path-content file), allow empty `foundation/` at bootstrap, and point the curate MUST at the 0000 admission test rather than the old one-line gloss.

4. **Severity:** DETAIL · **Scope:** IN-DELTA · **Target:** 0011 · **Claim:** The third change is “path is not lifecycle,” but the document still brands itself as a flat-corpus RFC. · **Evidence:** Title: “Sub-LLPs, Current and Foundation Overlays, Flat Corpus.” LLP 0000 header `**Revised:**`: “sub-LLPs, overlays, flat corpus.” Contrast 0011 §Summary item 3 and §Path is not lifecycle. · **Resolution criteria:** Drop “Flat Corpus” from the title and from 0000’s revision clause, or explicitly mark flatness as this repo’s choice rather than a v2 change.

5. **Severity:** DETAIL · **Scope:** IN-DELTA · **Target:** 0011.000 · **Claim:** The new conflict-check step narrows “every other binding `Active` normative document” to a parenthetical type list that omits still-binding RFCs, guides, and explainers. · **Evidence:** 0011.000 §Realign step 2: “grep the other `Active` normative documents (specs, decisions, principles outside foundation).” LLP 0000 §Curation contract: “every other binding `Active` normative document.” · **Resolution criteria:** Keep the 0000 set as the test; treat the type list as examples, or include every `Active` document that still binds.

## Verdicts

**0011:** READY — punch-list items on this RFC are VERIFIED or PARTIAL-but-DETAIL, and capsule `214b70aed287970243017f7215fd2d2cd3507ac47de306f448edefff08c99a0c` has no unresolved MATERIAL defect in 0011.

**0011.000:** NOT READY — Archive step 3 still bans `Superseded` from both overlays, contradicting the r2 membership contract on capsule `214b70aed287970243017f7215fd2d2cd3507ac47de306f448edefff08c99a0c`.

**Set:** NOT READY — 0011.000’s overlay-membership contradiction is unresolved MATERIAL on capsule `214b70aed287970243017f7215fd2d2cd3507ac47de306f448edefff08c99a0c`.
