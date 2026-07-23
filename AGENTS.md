# Agent Instructions

This project uses **Linked Literate Programming (LLP)** as defined in [LLP 0000](./llp/0000-linked-literate-programming.explainer.md). Read that document before making substantial changes.

## LLP documents

- LLP documents live in `llp/` and follow the numbering convention `NNNN-slug.type.md` (e.g. `0001-foo.guide.md`, `0003-bar.research.md`). Numbers are never reused.
- When creating a new LLP, use the next available number and include the standard metadata header (`Type`, `Status`, `Systems`, `Author`, `Date`; optional `Role`, `Revised`, `Related`).
- Standard types: **RFC**, **Spec**, **Decision**, **Plan**, **Explainer**, **Principles**, **Guide**, **Issue**, **Research**. Define others if none fit.
- Review intensity is stakes-scaled and author-judged ([LLP 0005](./llp/0005-rfc-process.guide.md)): setting `Status: Review` is the opt-in to a formal multi-model loop; the honesty rules (never fabricate a review, artifacts under `llp/reviews/`, the author decides) always apply.
- LLP documents are living documents. Update them when the system evolves; move historical-but-useful ones to `llp/tombstones/` marked `Tombstoned`. Don't leave stale docs unmarked.
- Corpus content is contract or recipe: advisory how-to is marked `> **Recipe (advisory)**` and is deletable; normative rules are not (LLP 0004, "Contracts over recipes").

## @ref annotations

- When writing or modifying code that implements a non-obvious design decision documented in an LLP, add an `@ref` annotation: `// @ref LLP NNNN#section — short gloss`
- When modifying code that already carries a `@ref`, check that the referenced section still applies. Update or remove it if not.
- Don't annotate mechanically. A reference should tell you something you wouldn't know from reading only the code and filename.
- Run `./ref-check` to validate references and metadata deterministically (CI runs it on every push). Drift that takes judgment is `llp-maintain`'s job.

## Agent skills

This repo ships LLP workflow skills under `skills/` (see the README's Skills section). The orient-first rule below is the ambient guidance; the skills are what it routes to.

<!-- BEGIN LLP SKILLS MANAGED BLOCK -->
Before editing a subsystem with documented design, orient first: read its
governing LLP, and for non-trivial work invoke `llp-orient` to assemble a
context pack of the constraints the change must respect.

Skills: orient = context before coding · create = author one LLP · review = LLP 0005 loop, scaled to stakes · adopt = set up LLP in any repo, install/update the skills · maintain = drift / pre-PR / reconcile / retire checks · super-refine = dual-model refine-until-ready
<!-- END LLP SKILLS MANAGED BLOCK -->

## Working on this project

- Read relevant LLP documents before implementing features or fixing bugs in the areas they cover.
- If you make a design decision worth documenting, write or update an LLP for it.
- Prefer updating an existing LLP over creating a new one when the topic is already covered.
- Land doc updates in the same commit as the code change that motivated them (co-evolution, LLP 0004).
