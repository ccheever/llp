# Agent Instructions

This project uses **Linked Literate Programming (LLP)** as defined in [LLP 0000](./llp/0000-linked-literate-programming.md). Read that document before making substantial changes.

## LLP documents

- LLP documents live in `llp/` and follow the numbering convention `NNNN-slug.md`.
- When creating a new LLP, use the next available number and include the standard metadata header (`Type`, `Status`, `Systems`, `Author`, `Date`; optional `Role`, `Revised`, `Related`).
- Standard types: **RFC**, **Spec**, **Decision**, **Plan**, **Explainer**, **Principle**, **Guide**, **Issue**, **Research**. You may define others if none of these fit.
- LLP documents are living documents. Update them when the system evolves. If an LLP is historical but still useful, move it under `llp/tombstones/` and mark it `Tombstoned`. Don't leave stale docs around unmarked.

## @ref annotations

- When writing or modifying code that implements a non-obvious design decision documented in an LLP, add an `@ref` annotation: `// @ref LLP NNNN#section — short gloss`
- When modifying code that already carries a `@ref`, check that the referenced section still applies. Update or remove it if not.
- Don't annotate mechanically. A reference should tell you something you wouldn't know from reading only the code and filename.

## Working on this project

- Read relevant LLP documents before implementing features or fixing bugs in the areas they cover.
- If you make a design decision worth documenting, write or update an LLP for it.
- Prefer updating an existing LLP over creating a new one when the topic is already covered.
