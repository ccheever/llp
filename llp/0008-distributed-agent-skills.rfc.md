# LLP 0008: Distributed Agent Skills

**Type:** RFC
**Status:** Active
**Systems:** LLP, Agents
**Author:** Charlie Cheever / Codex
**Date:** 2026-06-08
**Revised:** 2026-08-25 (retrofit golden path is survey → interview → draft; scoped package adoption per [LLP 0001](./0001-adopting-llp.guide.md)) · 2026-07-23 (distribution loop closed per [LLP 0010](./0010-skill-install-super-refine-ship.rfc.md): `llp-adopt` gains an install step and update mode backed by tagged releases and per-installation receipts; the skill set grows to seven as core-plus-flags. Earlier: 2026-06-10, revised down to its surviving decisions per [LLP 0009](./0009-capability-invariant-core.rfc.md) — the `llp-spec:` namespace, mechanics-recipe layer, provenance machinery, and fixture-harness plans were cut; see that RFC's cuts table)
**Related:** LLP 0000, LLP 0001, LLP 0004, LLP 0005, LLP 0009, LLP 0010

## Summary

LLP ships a small set of first-party **agent skills** — plain-markdown `SKILL.md` files under `skills/` — that make recurring LLP workflows repeatable across projects and agent runtimes. A **core** of five covers the loop: `llp-orient` (load governing context before coding), `llp-create` (author one LLP), `llp-review` (run the LLP 0005 loop honestly), `llp-adopt` (bring LLP to any repo or package — and install/update the skills themselves), and `llp-maintain` (drift, refs, provenance, retirement — propose, never apply). Two opt-in flags add `llp-super-refine` (dual-family refine-until-ready) and `llp-ship` (tasks done end to end) — see [LLP 0010](./0010-skill-install-super-refine-ship.rfc.md).

Two decisions shape the design:

- **Skills orchestrate; the harness computes.** Mechanical facts (the next LLP number, which files changed, whether an anchor exists) come from the harness's own exact tools — `Glob`, `Grep`, `Read`, shell pipelines — not from model recall and not from a bespoke `llp` CLI. Skills carry the *cognitive* work: reading rationale, drafting prose, synthesizing reviews.
- **Skills are deletable adapters, not the home of policy** (LLP 0009). Every MUST in a `SKILL.md` cites the LLP section it comes from; the skill is the per-runtime entry point and the corpus is authoritative. Deleting `skills/` must cost convenience, never correctness.

The keystone is `llp-orient`: "load the governing rationale before you touch the code" is the behavior LLP exists to make cheap. Because ambient skill-triggering is the least reliable invocation path across runtimes, the orient-first *rule* is carried by the always-in-context `AGENTS.md` managed block; the skill is the elaboration that rule routes to.

The one thing the harness cannot do — gate CI, where no agent is in the loop — is served by the `ref-check` checker ([LLP 0000 §6](./0000-linked-literate-programming.explainer.md#6-validation-ref-check)), which no skill depends on.

## Motivation

The guides (LLP 0001, 0005) describe the workflows. A skill adds three things a guide can't supply on its own:

1. **A trigger** — the agent reliably knows *when* to run the workflow, not just how.
2. **Pinned invariants** — the MUST/MUST-NOT lines (never fabricate a review, propose-don't-apply, never overwrite user prose) that must not be improvised or drift between sessions.
3. **A stable artifact shape** — context packs, review files, co-evolution checklists that look the same every run.

Without pinned skills, every agent re-derives the process from the docs and small variations accumulate: inconsistent scaffolding, shallow retrofits that invent rationale, missing review artifacts.

## Non-goals

- **Not auto-accepting or auto-promoting documents.** Status transitions are proposed, never applied unilaterally (LLP 0005).
- **Not bulk or mechanical annotation.** `@ref` proposals are specific, justified, and applied only after approval (LLP 0004).
- **Not running review unprompted, and never recording a review that didn't happen.**
- **Not replacing the guides.** Skills point at LLP 0000/0001/0005; they don't restate them.
- **Not shipping a bespoke `llp` CLI** (see Alternatives).

## The skills — core five, plus flags

Each skill is a contract: *Trigger · Invariants · Artifact · Hand-offs*. Recipes inside skills are marked advisory. The **core** profile is the five workflow skills; the `review-plus` and `delivery` flags add the two below the line (LLP 0010).

| Skill | Primary trigger | Cognitive work | Artifact / gate |
|---|---|---|---|
| **`llp-orient`** | before touching a subsystem with documented design — carried by the `AGENTS.md` rule | find governing LLPs, follow `@ref`s and `Related:` one hop, distill active constraints | read-only context pack |
| **`llp-create`** | "capture this decision / write a new LLP" | pick type, draft type-appropriate sections from the conversation | a new `Draft` LLP; prefers extending a covering doc |
| **`llp-review`** | a doc enters `Review`, or review is requested | run the LLP 0005 loop, summarize concerns, help revise | artifacts under `llp/reviews/`; never fabricates, never touches `Status` |
| **`llp-adopt`** | "bring LLP to this repo or package" / "update the LLP skills" | `scaffold`: structure + root doc; `retrofit`: survey → interview → draft, migrate, propose `@ref`s; `install`/`update`: pinned skill copies with receipts (LLP 0010 §1) | new files and managed blocks only; generated docs stay `Draft` with provenance tags; receipts, never clobbered forks |
| **`llp-maintain`** | pre-PR · audit · reconcile · retire | detect code/doc drift, validate refs interactively, draft reconciliations | findings and proposals; **never applies** |
| **`llp-super-refine`** (`review-plus`) | author invokes the dual-family refine loop | orchestrate mutually-blind reviews from two model families per round, revise between rounds, reconcile verdicts | verdict-lined, hash-stamped artifacts; bounded rounds; escalates to the author (LLP 0010 §2) |
| **`llp-ship`** (`delivery`) | a human hands over tasks to be done end to end | plan lanes, implement, integrate, verify + review the exact integrated SHA, deliver per repo policy | run ledger + report; SHA-bound gates; never force-pushes, never deletes recoverable work (LLP 0010 §3) |

**Modes instead of more skills.** `llp-adopt` spans one spectrum (how much existing design knowledge there is to mine) with `scaffold` and `retrofit` modes, plus the `install`/`update` modes that keep distributed copies current (LLP 0010 folded a once-planned `llp-update-skills` skill in here — adopt already does verified, diff-shown, receipt-writing work, and the posture boundary that matters is maintain's, not adopt's); `llp-maintain` spans four maintenance moments (`pre-pr`, `audit`, `reconcile`, `retire-proposal`) distinguished by scope and artifact. The propose-only line is what lets one skill cover four moments without becoming a mega-skill — maintain *notes* a stale pin; `/llp-adopt update` applies.

**Hand-offs:** orient → create/review (task needs new design) or maintain (broken ref found); create → adopt (no corpus yet); adopt → orient (corpus exists), review (ratify generated docs), maintain (ongoing health); maintain → review (a reconciliation is really new design) and stale pins → `/llp-adopt update`; super-refine → create (feedback is a new design) and the author for `Accepted`.

**Harness mechanics.** For facts, prefer a pipeline whose output *is* the answer — e.g. next LLP number:

> **Recipe (advisory)** — `ls llp | grep -oE '^[0-9]{4}' | sort -n | tail -1`, then +1; for nested trees, glob `llp/**/[0-9]*.md`, exclude `reviews/`, take max. Runtimes without a shell use their glob/grep/read primitives the same way.

## Distribution

Distribution is files — a skill directory copied into the runtime's skill location — but the copying is managed: `llp-adopt`'s **install step** copies skills from a **tagged release** of this repo and writes a **receipt** beside the installation (origin, tag, resolved commit, profile flags, per-file content hashes); its **update mode** (`/llp-adopt update`) three-way-checks installed copies against the receipt, presents the full diff, and applies approved updates as a set — forks are never clobbered, and cannot-verify writes nothing. The install unit is a profile: **core** (the five skills below) plus additive flags **review-plus** (`llp-super-refine`) and **delivery** (`llp-ship`). Full design, trust model, and threat model: [LLP 0010 §1](./0010-skill-install-super-refine-ship.rfc.md#1-installation-and-updates-llp-adopt-extended).

The runtime locations (advisory; confirmed against runtime docs at install time):

| Runtime | Skill directory (per runtime docs; verify) |
|---|---|
| Claude Code | project `.claude/skills/<name>/`, user `~/.claude/skills/<name>/` |
| Cursor | `.cursor/skills/<name>/` |
| Codex | `$CODEX_HOME/skills/<name>/` |
| No skills mechanism | the `AGENTS.md` routing block alone |

**Policy citations survive copying.** A copied skill resolves relative links against the wrong tree and bare `LLP NNNN` against the consuming project's corpus. So skills cite their governing policy as **pinned upstream URLs** (e.g. `https://github.com/ccheever/llp/blob/v0.2.0/llp/0005-rfc-process.guide.md#honesty-rules-always-in-force`) and carry an informational `source: <owner>/<repo>@<tag>` frontmatter line. Staleness detection is comparing that pin to upstream releases (`llp-maintain` can note it); offline section resolution is not promised — a project that needs it vendors a snapshot and rewrites URLs to paths itself. This replaced the former `llp-spec:` namespace and vendoring machinery (LLP 0009).

**The `AGENTS.md` routing block.** A managed region that carries the orient-first rule in always-loaded context — deliberately not relying on ambient skill-fire — plus a one-line index of the skills. `llp-adopt` (or a human) writes and updates only this block, never user prose:

```markdown
<!-- BEGIN LLP SKILLS MANAGED BLOCK -->
Before editing a subsystem with documented design, orient first: read its
governing LLP, and for non-trivial work invoke `llp-orient`.

Skills: orient = context before coding · create = author one LLP · review = LLP 0005 loop
        · adopt = set up LLP in any repo or package · maintain = drift / pre-PR / reconcile / retire checks
<!-- END LLP SKILLS MANAGED BLOCK -->
```

**Security & trust.** Skills are code distribution: confirm before writing user/global directories (project-local may proceed); never overwrite a skill you didn't write — show a diff and ask; prefer copies over symlinks for vendored skills.

**Bootstrap.** `llp-adopt`'s scaffold mode creates `llp/`, the root LLP, and the managed blocks through the harness's own `Write`/`Edit` tools — there are no install scripts. Managed blocks are explicit (`BEGIN`/`END` markers), reruns are idempotent, and user prose outside the blocks is never overwritten.

## Golden paths

- **Greenfield:** `llp-adopt` (scaffold) → `llp-create` for the first real decisions → code with `@ref`s → `llp-review` where stakes warrant.
- **Retrofit:** `llp-adopt` (retrofit): survey → interview → draft root + at most two subsystem docs (all `Draft`, provenance-tagged) → human ratifies → `llp-maintain` ongoing. Scope is a directory (package or repo); skills walk up to the nearest `llp/` (LLP 0001).
- **Daily:** `llp-orient` before the change → code + `@ref` → `llp-maintain --intent pre-pr` → `llp-review` if the change is new design.

## Alternatives considered

- **A dedicated `llp` CLI.** Rejected: the deterministic layer already exists in every agent runtime as glob/grep/read plus shell pipelines. A bespoke binary added a language/packaging decision, per-platform installs, a versioning contract, and a standing skill↔CLI skew problem. The one genuinely non-interactive need (CI) is served by `ref-check`.
- **Fourteen fine-grained skills** (an early draft). Rejected: trigger ambiguity, token bloat, a maintenance surface needing a skill to maintain skills.
- **One mega-skill / router.** Rejected for trigger clarity; a thin dispatcher remains a possible later convenience.
- **The `llp-spec:` namespace + vendored spec snapshots** (this RFC's original distribution design). Replaced by pinned upstream URLs per LLP 0009 — the vendoring/skew machinery solved a documentation-grade problem with CI-grade rigor, and none of it was built.
- **An MCP server for the mechanical checks.** Deferred: harness tools are the portable baseline; an MCP wrapper over `ref-check` is a possible later adapter.

## History

A first cut shipped seven skills (`llp-init`, `llp-init-retrofit`, `llp-create`, `llp-list`, `llp-review`, `ref-check`, `ref-story`); they were consolidated to the five above (init + init-retrofit → `llp-adopt`; interactive ref-checking → `llp-maintain`; deterministic ref-checking → the `ref-check` program, since a `SKILL.md` can't be a CI gate). The `llp-list` and `ref-story` utilities were later deleted under LLP 0009's capability test — listing is a grep, and the rationale-order view is a prompt (preserved as the recipe in LLP 0000 §7).

## Open questions

1. **Router skill.** If trigger overlap mis-fires in practice (`llp-maintain --intent pre-pr` vs. a final orient; `llp-create` vs. `llp-adopt` on a near-empty repo), add a thin `llp` dispatcher — or not. Decide from usage.
2. **`llp.json`.** A machine-readable project config (`allowed_systems`, shorthand mappings, redaction rules for review) remains attractive and deferred; review config should name model *families*, never pinned model IDs.
3. **Token footprint.** Always-loaded skill descriptions plus the routing block have a standing cost — the failure mode the AGENTS.md research in LLP 0003 measures. Trim descriptions if real usage shows the rule alone suffices (this is also LLP 0009's open question about `llp-orient`'s eventual collapse).
