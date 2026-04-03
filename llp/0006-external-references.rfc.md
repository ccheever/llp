# LLP 0006: External and Non-Markdown References

**Type:** RFC
**Status:** Draft
**Systems:** LLP
**Author:** Charlie Cheever / Claude
**Date:** 2026-04-03
**Related:** LLP 0000

## Summary

Extend `@ref` to support URLs and non-markdown artifacts as first-class reference targets — state machine diagrams, Figma mocks, external specs, images, and any other document that captures design intent but isn't a numbered LLP markdown file.

## Motivation

LLP currently defines three reference target forms: LLP document numbers (`LLP NNNN#anchor`), file paths (`docs/vendor/openid-spec.md#token-validation`), and project-defined shorthands (`SPEC#binary-header`). All of these assume the target is a text file in the repo, or at least addressable as one.

In practice, design rationale lives in many places that aren't markdown:

- **State machine diagrams.** A camera app's lifecycle is best documented as a hierarchical state machine. The code implementing state transitions should point to the authoritative diagram, not a prose approximation of it.
- **Figma mocks.** UI code implements a specific design. The reference should point to the Figma frame, not a screenshot that will go stale.
- **External specifications.** Code implementing OAuth, Protobuf, or a hardware protocol spec should reference the canonical external document, not a local copy that may drift.
- **Visual artifacts in the repo.** Architecture diagrams (`.svg`, `.png`), sequence diagrams (`.mermaid`), data flow charts — these are legitimate design documents that code may implement.
- **Issue trackers and discussion threads.** Sometimes the "why" behind a decision is in a GitHub issue or a Linear ticket, not a formal LLP.

The common thread: there are forms of specification beyond prose markdown, and `@ref` should be able to point to them.

## Design

### URL references

A `@ref` target can be an absolute URL:

```typescript
// @ref https://www.figma.com/file/abc123/Main?node-id=42:108 — Login screen layout
export function LoginScreen() {

// @ref https://datatracker.ietf.org/doc/html/rfc6749#section-4.1 — OAuth 2.0 authorization code flow
async function handleAuthCallback(code: string): Promise<TokenSet> {

// @ref https://github.com/org/repo/issues/347 — Why we buffer before flush
function flushBuffer(buf: SharedArrayBuffer): void {
```

URLs are recognized by the `https://` (or `http://`) prefix. The fragment (`#section-4.1`) is part of the URL and works as a section anchor, same as it does for LLP documents.

### Non-markdown file references

File paths already work in `@ref` (the spec shows `docs/vendor/openid-spec.md#token-validation`). This RFC clarifies that any file type is valid, not just markdown:

```rust
// @ref docs/diagrams/camera-lifecycle.svg — Camera state machine
pub fn transition_camera_state(current: State, event: Event) -> State {

// @ref docs/architecture/data-flow.mermaid#ingestion — Ingestion pipeline
fn ingest_batch(records: Vec<Record>) -> Result<()> {

// @ref assets/specs/binary-header-format.png — Wire format diagram
fn parse_header(bytes: &[u8]) -> Result<Header> {
```

For non-text files, fragment anchors (`#section`) are only meaningful if the format supports them (SVG does, PNG doesn't, Mermaid can via diagram node IDs). When a format doesn't support fragments, omit the anchor and reference the whole artifact.

### Relation types apply unchanged

External references support the same optional relation types as LLP references:

```typescript
// @ref https://www.figma.com/file/abc123/Main?node-id=42:108 [implements] — Login screen layout
// @ref docs/diagrams/camera-lifecycle.svg [constrained-by] — Must follow state machine transitions
```

### Validation behavior

External references change the validation calculus:

| Target type | Extract | Resolve | Notes |
|-------------|---------|---------|-------|
| `LLP NNNN#anchor` | Yes | Full (check doc + section exist) | Existing behavior |
| File path | Yes | Full (check file exists, optionally check anchor) | Existing behavior; extended to non-markdown |
| URL | Yes | Reachability check (optional, off by default) | URLs can go stale but checking is slow and flaky |
| Shorthand | Yes | Expand then resolve per target type | Existing behavior (unchanged) |

URL reachability checking should be opt-in (e.g., `ref-check resolve --check-urls`) and probably run periodically rather than on every CI build. A stale URL is a warning, not an error — the code is still correct even if the Figma link changed.

For non-markdown files, validation checks that the file exists but cannot validate fragment anchors in most binary formats. The `resolve` stage should report "file exists, anchor unchecked" rather than false positives.

### Annotated source generation

For external targets, the annotated source view can't inline the referenced content the way it does for LLP markdown sections. Instead, it should render the reference as a clickable link with the gloss:

```
┌─ https://www.figma.com/file/abc123/Main?node-id=42:108 ─┐
│ Login screen layout                                      │
│ [Figma link — content not inlined]                       │
└──────────────────────────────────────────────────────────┘
export function LoginScreen() {
```

For in-repo image files (`.svg`, `.png`), a dev server integration could render the image inline. For Mermaid diagrams, it could render them. This is a progressive enhancement, not a requirement.

## Alternatives considered

### Wrapping external references in LLP documents

Instead of pointing `@ref` at URLs directly, require every external reference to go through an LLP document that embeds or links to the external artifact. For example, LLP 0042 would contain a Figma embed, and code would reference `LLP 0042#login-screen`.

**Rejected because:** This adds indirection that doesn't carry its weight for simple cases. If the code implements a Figma mock, the most useful reference is to the Figma frame itself. An intermediate LLP document that just wraps the link adds a maintenance burden without adding context. However, for complex external artifacts that need prose explanation, wrapping in an LLP is still a good practice — this RFC doesn't prevent that, it just doesn't require it.

### A separate annotation prefix for external references

Use `@extref` or `@link` instead of `@ref` for non-LLP targets.

**Rejected because:** The value of `@ref` is that it's one grep-able prefix for all design rationale links. Splitting it fragments the system. The target format (LLP number vs. URL vs. path) already distinguishes the reference type — no need for a separate prefix.

### Only supporting URLs, not file paths to non-markdown

Limit this RFC to URL support and keep file-path references markdown-only.

**Rejected because:** In-repo diagrams and images are common design artifacts. Excluding them from `@ref` would force projects to either host them externally (adding friction) or reference them informally in comments (losing traceability).

## Implementation plan

1. **Spec update (LLP 0000).** Add URL syntax and non-markdown file paths to the reference syntax section. Clarify that file-path references are not limited to markdown.
2. **Extract stage.** Update the `ref-check extract` parser to recognize URL targets. The regex needs to handle `https://...` with query strings and fragments.
3. **Resolve stage.** Add file-existence checks for non-markdown paths. Add opt-in URL reachability checking.
4. **Annotate stage.** Render external references as links with gloss text instead of inlined prose.

Step 1 can land immediately. Steps 2-4 depend on the validation tooling (LLP 0000 §6) being implemented.

## Open questions

1. **Should URL reachability checking be on or off by default?** Off is safer (no network calls in CI, no flaky failures) but means stale URLs accumulate silently.

2. **Should there be a convention for archiving external artifacts?** If a Figma mock is deleted, the `@ref` breaks with no recourse. A convention like "export a PDF snapshot to `docs/snapshots/`" would provide durability. But mandating it might be too heavy.

3. **Fragment anchors in non-text formats.** SVG supports `#elementId`, Mermaid can use node IDs, but most binary formats don't support fragments. Should the spec define conventions for anchor-like addressing in specific formats, or leave this to projects?
