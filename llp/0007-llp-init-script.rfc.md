# LLP 0007: `llp init` Bootstrap Script

**Type:** RFC
**Status:** Accepted
**Systems:** LLP
**Author:** Charlie Cheever / Claude
**Date:** 2026-04-06
**Revised:** 2026-04-06
**Related:** LLP 0000, LLP 0001, LLP 0002

## Summary

A standalone script (e.g. `npx llp-init`, `curl | sh`, or a checked-in `scripts/llp-init.sh`) that bootstraps LLP in a new repository with a single command. It creates the directory structure, generates a template LLP 0000, and configures agent instructions without requiring an AI agent to clone the repo, read the codebase, or spend tokens on setup.

## Motivation

Today, setting up LLP in a new repo requires either (a) manually following the steps in LLP 0001, or (b) asking an AI agent to read this repo, understand LLP, and replicate the structure. Both have friction:

- **Manual setup** means copying boilerplate, remembering the metadata format, getting the filename convention right (`NNNN-slug.type.md`), and writing agent instructions from scratch. It's 10-15 minutes of work that's the same every time.
- **Agent-assisted setup** is expensive: the agent needs to clone or read the LLP repo, understand the spec, then generate files in the target repo. This burns tokens and time on a task that's entirely mechanical.

A script eliminates both problems. Run one command, get a correctly structured LLP directory with sensible defaults. The human (or agent) can then focus on the interesting part: writing the actual design content.

This tool is primarily for greenfield or nearly empty repositories. In an existing codebase it can still be a useful first step to create the scaffolding, but it does **not** replace the retrofit process in LLP 0002 because it does not read the codebase, identify subsystems, or extract existing design rationale.

## Design

### Invocation

The script should support at least these invocation methods:

```bash
# Option A: npx (if published to npm)
npx llp-init

# Option B: curl one-liner (no dependencies)
curl -fsSL https://raw.githubusercontent.com/.../llp-init.sh | sh

# Option C: run from a local clone of the LLP repo
./scripts/llp-init.sh

# Option D: copy the script into the target repo
cp /path/to/llp-init.sh ./scripts/ && ./scripts/llp-init.sh
```

The script runs in the current working directory and assumes it's the root of a git repository.

### Repository scope

The script is a **greenfield bootstrap tool**. Its default mental model is "this repo is new enough that a placeholder LLP 0000 is useful."

For an established repository, the script may still be run as a scaffolding step, but it should emit a clear warning that:

- the generated LLP 0000 is only a placeholder
- retrofitting still requires the codebase-reading workflow from LLP 0002
- the script is creating scaffolding, not performing retrofit analysis

The warning should be advisory rather than blocking. This keeps the tool useful as a first step in retrofit work without pretending it has solved the retrofit problem.

### What it creates

```
llp/
  0000-<project-name>.explainer.md    # Root document (template)
  tombstones/                          # Empty, with .gitkeep
AGENTS.md                             # Canonical agent instructions
CLAUDE.md -> AGENTS.md                # Symlink when safe to create
```

#### LLP 0000 template

The root document is generated with placeholder content that the user fills in:

```markdown
# LLP 0000: <Project Name>

**Type:** Explainer
**Status:** Draft
**Systems:** Core
**Role:** Root
**Author:** <git user.name>
**Date:** <today>

## Overview

<!-- What does this project do? Why does it exist? -->

## Architecture

<!-- What are the major subsystems? How do they relate? -->

## Key decisions

<!-- What non-obvious choices have been made? Link to specific LLPs as they're written. -->
```

The script infers `<Project Name>` from the directory name (converting `my-cool-project` to `My Cool Project`). `<git user.name>` comes from `git config user.name`. `<today>` is the current date in `YYYY-MM-DD`.

If `git config user.name` is unset and `--author` is not provided, the script should use a visible placeholder such as `<Author Name>` and print a warning rather than silently writing an empty field.

#### Agent instruction files

`AGENTS.md` is the canonical generated instruction file. `CLAUDE.md` exists for tool compatibility and should normally be a symlink to `AGENTS.md`.

Behavior:

- If neither file exists, create `AGENTS.md` and then create `CLAUDE.md` as a symlink to it.
- If `AGENTS.md` exists and `CLAUDE.md` does not, update `AGENTS.md` and create the symlink.
- If `CLAUDE.md` is already a symlink to `AGENTS.md`, only update `AGENTS.md`.
- If `CLAUDE.md` exists as a separate regular file, create or update `AGENTS.md` and insert or update the LLP instructions in **both** files, with a warning that the files have diverged.
- Never replace an existing regular file with a symlink automatically.

The generated LLP instructions should live inside an explicit managed block, for example:

```markdown
<!-- BEGIN LLP INIT MANAGED BLOCK -->
...
<!-- END LLP INIT MANAGED BLOCK -->
```

On rerun, the script replaces only the contents of that block. User-authored content outside the block is left untouched. If a file already contains LLP guidance outside the managed block, the script should warn rather than attempting to merge or rewrite that prose heuristically.

The generated instructions should include:

- Where LLP documents live and the filename convention
- Instruction to read relevant LLPs before making changes in areas they cover
- Instruction to add `@ref` annotations when implementing documented decisions
- Instruction to update LLP documents when the design changes
- Instruction to avoid mechanical `@ref` annotations
- Instruction to prefer updating an existing LLP over creating a new one when the topic is already covered
- The standard document types and metadata format

This content should be derived from the instructions in this repo's own agent instruction files, adapted to be generic.

### Flags and options

Keep it minimal. The script should work with zero arguments for the common case.

| Flag | Default | Description |
|------|---------|-------------|
| `--name <name>` | Inferred from directory | Project name for LLP 0000 |
| `--author <name>` | `git config user.name` | Author name for metadata |
| `--no-agent-instructions` | off | Skip `AGENTS.md` / `CLAUDE.md` creation and modification |
| `--dry-run` | off | Print what would be created without writing files |

### Idempotency

The script should be safe to run multiple times:

- If `llp/` already exists, skip creating it (and warn)
- If `llp/0000-*.md` already exists, skip creating it (and warn)
- If the managed LLP block already exists in `AGENTS.md` or `CLAUDE.md`, replace that block in place rather than appending
- If `CLAUDE.md` is missing and safe to create, create it as a symlink to `AGENTS.md`
- If `CLAUDE.md` is a separate regular file, update the managed block in both files and warn that they are not symlinked
- Never overwrite existing files
- Never modify user-authored content outside the managed block

### Language and dependencies

The script should be a POSIX shell script with no dependencies beyond `git`, `date`, and standard Unix utilities (`mkdir`, `cat`, `sed`, `grep`). This makes it runnable on any developer machine or CI environment without installing anything.

A Node.js wrapper (`npx llp-init`) can exist as a convenience that downloads and runs the shell script, but the shell script is the source of truth.

## Alternatives considered

### A Yeoman/cookiecutter/copier template

Template engines are powerful but add a dependency and require the user to install the tool first. For generating 2-3 files with simple variable substitution, a shell script is more portable and faster. If LLP's bootstrapping needs grow significantly (generating per-subsystem documents, integrating with CI), a template engine might make sense later.

### An interactive wizard

A TUI that asks questions ("What's your project name?", "What are your major subsystems?") and generates documents based on answers. This is appealing but over-engineers the initial setup. The script generates a minimal scaffold; the interesting decisions happen when the human fills in the templates. An interactive mode could be a future addition (`--interactive`).

### An AI-powered init that reads the codebase

The script could invoke an AI to read the codebase and generate a more complete LLP 0000. This is appealing for retrofitting (LLP 0002) but wrong for a bootstrap script: it requires API keys, costs money, takes time, and the output still needs human review. The script should be instant, free, and offline. Agent-assisted retrofit/document generation is a separate tool.

### Including the script in the LLP repo vs. publishing separately

The script should live in this repo (`scripts/llp-init.sh`) as the source of truth, and optionally be published to npm or as a GitHub release artifact for easier access. Keeping it in-repo means it evolves with the spec.

## Implementation status

1. **Shell script implemented.** `scripts/llp-init.sh` is the source-of-truth bootstrap script. It creates `llp/`, a template LLP 0000, the managed LLP instruction block in `AGENTS.md`, and `CLAUDE.md -> AGENTS.md` when safe.
2. **Docs updated.** `README.md`, LLP 0001, and LLP 0002 now point to the script and describe its role as a greenfield bootstrapper rather than a retrofit solution.
3. **Manual verification completed.** The script has been exercised in temporary git repositories for the main file-layout cases: empty repo, `AGENTS.md` only, `CLAUDE.md` only, diverged `AGENTS.md` and `CLAUDE.md`, rerun idempotency, `--dry-run`, and missing `git config user.name`.
4. **Optional wrapper still open.** A thin npm wrapper remains optional future work if `npx llp-init` becomes a primary distribution path.

## Open questions

1. **Should the script also generate a starter LLP 0001?** A template for the first design decision (empty, with the right metadata) might lower the barrier further. Or it might just be noise that the user deletes.

2. **Distribution: what's the right primary channel?** Options: `npx`, `brew`, `curl | sh`, GitHub Releases binary, or just "copy the script." The answer probably depends on where LLP adoption concentrates.
