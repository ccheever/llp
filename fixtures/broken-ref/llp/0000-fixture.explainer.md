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

- `src/main.py`: one resolving reference (to this doc and to the valid
  sub-LLP `0000.000`) and two broken ones (missing LLP, missing anchor).
- `0001.000-orphan.spec.md`: a sub-LLP whose parent does not exist.
- `current/0042-nope.rfc.md`: a dangling overlay link.
- `0000.000` (Tombstoned) linked from both `current/` and `foundation/`.
- `foundation/` linking this doc is fine (Active), and is the one
  overlay entry that must *not* be reported.

## Real section

An anchor a reference can legitimately target (the other is `0000.000#child-section`).
