# LLP 0000: Nested-package parent

**Type:** Explainer
**Status:** Active
**Systems:** Fixture
**Role:** Root
**Author:** ref-check fixture
**Date:** 2026-08-25

## Overview

Parent corpus for the nested-package fixture. `packages/mod/` has its own
`llp/` and a broken `@ref`. `ref-check --root fixtures/nested-package` must
**pass** — the child tree is a separate corpus and is skipped, including
`packages/mod/src/`. `ref-check --root fixtures/nested-package/packages/mod`
must **fail** on the child's broken ref.
