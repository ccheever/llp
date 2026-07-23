---
name: llp-create
description: Create a new LLP document with the next available number, the NNNN-slug.type.md filename convention, and a scaffolded metadata header — or extend an existing LLP when one already covers the topic.
source: ccheever/llp@v0.3.0
---

# llp-create

<!-- @ref https://github.com/ccheever/llp/blob/v0.3.0/llp/0000-linked-literate-programming.explainer.md#1-llp-documents — numbering, metadata, types, statuses -->
<!-- @ref https://github.com/ccheever/llp/blob/v0.3.0/llp/0008-distributed-agent-skills.rfc.md#the-five-skills — skill contract -->

Author one LLP in a corpus that already exists. Handles numbering, filename, and the metadata scaffold so the author can focus on content.

Invoke as `/llp-create <title>`, or bare and the skill asks.

## Trigger

"Capture this decision" / "write an LLP for this" — during or after a design conversation.

## Invariants

- MUST check for a covering document first: `Grep` the `**Systems:**` and `**Related:**` headers across `llp/` and propose *extending* an existing LLP over creating a new one when the topic is already covered.
- MUST derive the next number from the tree — `max(existing) + 1`, zero-padded — scanning the whole `llp/` tree including subdirectories and `tombstones/`. Numbers are never reused and never invented.
- MUST name the file `NNNN-slug.type.md` with the lowercased type matching the header's `**Type:**`, and start every new LLP as `Draft`.
- MUST NOT overwrite an existing file — if the name collides, stop and ask.
- MUST NOT silently pick a document type when the choice is ambiguous — propose one and confirm.

## Workflow

> **Recipe (advisory)** — next number: `ls llp | grep -oE '^[0-9]{4}' | sort -n | tail -1` (+1); for nested trees glob `llp/**/[0-9]*.md` and exclude `reviews/`. Slug: lowercase, non-alphanumerics → `-`, collapse repeats, keep it under ~6 words. Type cues: proposal → `rfc`; requirements → `spec`; settled choice → `decision`; steps → `plan`; teaching → `explainer`; always/never → `principles`; how-to → `guide`; bug → `issue`; findings → `research`. Scaffold sections: Summary · Motivation · Design · Open questions (Decisions use Context/Options/Decision/Consequences; Research uses Findings/Confidence).

## Artifact

A new `Draft` LLP with a complete metadata header (`Type`, `Status`, `Systems`, `Author`, `Date`; `Related:` where relevant) — plus an offer to draft the body from the current conversation. Confirm the assigned number and path back to the user.

## Hand-offs

- No corpus to add the document to → `llp-adopt`.
- The document is foundational or contentious → `llp-review`, scaled to stakes (LLP 0005).
