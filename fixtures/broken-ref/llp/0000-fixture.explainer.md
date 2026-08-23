# LLP 0000: Fixture Project

**Type:** Explainer
**Status:** Active
**Systems:** Fixture
**Role:** Root
**Author:** ref-check fixture
**Date:** 2026-06-10

## Overview

A deliberately broken tree. `ref-check --root fixtures/broken-ref` must exit
non-zero, reporting exactly these errors:

- `src/main.py`: two resolving references (this doc; the valid sub-LLP
  `0000.000`) and three broken ones (missing LLP, missing anchor, malformed
  number `LLP 0000.00`).
- `0001.000-orphan.spec.md`: a sub-LLP whose parent does not exist.
- `current/0042-nope.rfc.md`: a dangling overlay link.
- `0000.000` (Tombstoned) linked from both `current/` and `foundation/`.
- `current/abs-0000-fixture.explainer.md`: an absolute symlink.
- `foundation/` linking this doc (Active) and `current/0000-fixture.explainer.md`
  — a *regular file* containing the relative path, git's `core.symlinks=false`
  form — are the two overlay entries that must *not* be reported.

## Real section

An anchor a reference can legitimately target (the other is `0000.000#child-section`).
