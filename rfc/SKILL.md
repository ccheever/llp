---
name: rfc
description: Create, review, and list Exact RFCs using the repo's RFC 0001 process.
---

# rfc

Use this skill when the user wants help creating, reviewing, or listing RFCs in
this repository.

## Ground Rules

- Search both `rfcs/` and `docs/site/content/rfcs/` when numbering or locating RFCs.
- If `docs/site/content/rfcs/` does not exist, treat it as empty.
- Numbered RFC filenames are `NNNN-slug.md`.
- Valid statuses: `Draft`, `Review`, `Accepted`, `Implemented`, `Superseded`, `Shelved`, `Withdrawn`.
- Normalize status values when matching:
  - strip ` vN`
  - strip trailing parenthetical notes
  - compare case-insensitively

Standard review prompt:

```text
What do you think of this proposal? Is it a good idea? Do we have a good plan here? How would you change it to make it better? What would you add or take away or change? Is anything definitely or possibly wrongheaded here? Do you have any novel ideas that you think might make this way better even if they are a bit non-standard? What are the key open questions we need to answer to refine this?
```

## Modes

### `/rfc create <title>`

1. Scan existing numbered RFCs in both RFC directories.
2. Pick the next number.
3. Build the slug:
   - lowercase
   - replace non-alphanumerics with `-`
   - collapse repeated `-`
   - trim edge `-`
4. Create `rfcs/NNNN-slug.md` with minimal scaffold:

```markdown
# RFC NNNN: <Title>

**Status:** Draft
**Author:** Charlie Cheever / Claude
**Date:** YYYY-MM-DD
**Revised:** YYYY-MM-DD
**Related:** 

## Summary

## Design
```

5. Then help draft the RFC from the current conversation context.

### `/rfc review <identifier>`

Identifier may be:

- a number like `0036`
- a slug like `intent-level-authoring`
- omitted, in which case list Draft/Review RFCs and ask which one

Review workflow:

1. Locate the RFC in `rfcs/` or `docs/site/content/rfcs/`
2. Read the full file
3. Review it using the standard review prompt
4. Present the review with findings first:
   - overall assessment
   - strengths
   - concerns
   - suggestions
   - open questions
5. Save the review artifact under:

```text
notes-archive/ai-reviews/{slug}.round-{N}.claude.md
```

Artifact rules:

- strip leading `NNNN-` from the RFC filename when deriving `{slug}`
- strip trailing `.md`
- increment `{N}` based on existing `*.claude.md` review files

If the RFC is still `Draft`, suggest updating it to `Review` after the review.
Always remind the user that the process also requires a GPT review.

### `/rfc list [status]`

1. Scan both RFC directories
2. Extract and normalize `**Status:**`
3. Group RFCs by normalized status
4. Sort numbered RFCs ascending, then unnumbered RFCs alphabetically
5. If a status filter was provided, show only that group

Render numbered RFCs as:

```text
0038  exact-inspect-skill
0039  rfc-skill
----  unnumbered-rfc
```

## Scope Limits

- Do not accept or reject RFCs on the user's behalf.
- Do not claim the GPT review is done unless the user actually provided it.
- Do not renumber existing unnumbered RFCs unless the user is actively updating one.
