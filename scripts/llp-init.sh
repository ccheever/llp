#!/bin/sh

set -eu

SCRIPT_NAME=${0##*/}
MANAGED_START='<!-- BEGIN LLP INIT MANAGED BLOCK -->'
MANAGED_END='<!-- END LLP INIT MANAGED BLOCK -->'

dry_run=0
skip_agent_instructions=0
project_name=''
author_name=''

temp_root=$(mktemp -d "${TMPDIR:-/tmp}/llp-init.XXXXXX")

usage() {
  cat <<EOF
Usage: $SCRIPT_NAME [--name <name>] [--author <name>] [--no-agent-instructions] [--dry-run]

Bootstrap Linked Literate Programming (LLP) in the current git repository.

Options:
  --name <name>                Project name for LLP 0000
  --author <name>              Author name for LLP metadata
  --no-agent-instructions      Skip AGENTS.md / CLAUDE.md creation and updates
  --dry-run                    Print planned actions without writing files
  --help                       Show this help
EOF
}

info() {
  printf '%s\n' "$*"
}

warn() {
  printf 'warning: %s\n' "$*" >&2
}

die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

make_temp_file() {
  tmp_path=$(mktemp "$temp_root/file.XXXXXX")
  printf '%s\n' "$tmp_path"
}

cleanup() {
  rm -rf "$temp_root"
}

trap cleanup EXIT INT TERM HUP

while [ "$#" -gt 0 ]; do
  case "$1" in
    --name)
      [ "$#" -ge 2 ] || die "--name requires a value"
      project_name=$2
      shift 2
      ;;
    --author)
      [ "$#" -ge 2 ] || die "--author requires a value"
      author_name=$2
      shift 2
      ;;
    --no-agent-instructions)
      skip_agent_instructions=1
      shift
      ;;
    --dry-run)
      dry_run=1
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      die "unknown argument: $1"
      ;;
  esac
done

git_root=$(git rev-parse --show-toplevel 2>/dev/null) || die "run $SCRIPT_NAME from the root of a git repository"
current_dir=$(pwd -P)
repo_root=$(cd "$git_root" && pwd -P)
[ "$current_dir" = "$repo_root" ] || die "run $SCRIPT_NAME from the root of a git repository"

title_case_words() {
  printf '%s' "$1" | awk '
    {
      gsub(/[^[:alnum:]]+/, " ")
      for (i = 1; i <= NF; i++) {
        word = $i
        first = substr(word, 1, 1)
        rest = substr(word, 2)
        if (i > 1) {
          printf " "
        }
        printf "%s%s", toupper(first), tolower(rest)
      }
      printf "\n"
    }
  '
}

slugify() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9][^a-z0-9]*/-/g; s/^-//; s/-$//'
}

write_temp_from_command() {
  temp_file=$1
  shift
  "$@" > "$temp_file"
}

write_file_from_temp() {
  source_file=$1
  target_file=$2
  description=$3

  if [ -e "$target_file" ] || [ -L "$target_file" ]; then
    if cmp -s "$source_file" "$target_file" 2>/dev/null; then
      info "unchanged: $target_file"
      return 0
    fi
  fi

  if [ "$dry_run" -eq 1 ]; then
    info "would $description: $target_file"
    return 0
  fi

  cat "$source_file" > "$target_file"
  info "$description: $target_file"
}

ensure_directory() {
  directory=$1

  if [ -d "$directory" ]; then
    return 0
  fi

  if [ "$dry_run" -eq 1 ]; then
    info "would create directory: $directory"
    return 0
  fi

  mkdir -p "$directory"
  info "created directory: $directory"
}

ensure_empty_file() {
  target_file=$1

  if [ -e "$target_file" ]; then
    return 0
  fi

  if [ "$dry_run" -eq 1 ]; then
    info "would create file: $target_file"
    return 0
  fi

  : > "$target_file"
  info "created file: $target_file"
}

emit_llp_0000() {
  cat <<EOF
# LLP 0000: $project_name

**Type:** Explainer
**Status:** Draft
**Systems:** Core
**Role:** Root
**Author:** $author_name
**Date:** $(date +%F)

## Overview

<!-- What does this project do? Why does it exist? -->

## Architecture

<!-- What are the major subsystems? How do they relate? -->

## Key decisions

<!-- What non-obvious choices have been made? Link to specific LLPs as they're written. -->
EOF
}

emit_managed_agent_block() {
  cat <<'EOF'
<!-- BEGIN LLP INIT MANAGED BLOCK -->
# Agent Instructions

This project uses **Linked Literate Programming (LLP)**. Read LLP 0000 before making substantial changes.

## LLP documents

- LLP documents live in `llp/` and follow the numbering convention `NNNN-slug.type.md` (e.g. `0001-foo.guide.md`, `0003-bar.research.md`).
- When creating a new LLP, use the next available number and include the standard metadata header (`Type`, `Status`, `Systems`, `Author`, `Date`; optional `Role`, `Revised`, `Related`).
- Standard types: **RFC**, **Spec**, **Decision**, **Plan**, **Explainer**, **Principle**, **Guide**, **Issue**, **Research**. You may define others if none of these fit.
- RFCs (and optionally Specs/Plans) commonly use the expanded lifecycle: `Draft` -> `Review` -> `Accepted` -> `Active`.
- LLP documents are living documents. Update them when the system evolves. If an LLP is historical but still useful, move it under `llp/tombstones/` and mark it `Tombstoned`. Don't leave stale docs around unmarked.

## @ref annotations

- When writing or modifying code that implements a non-obvious design decision documented in an LLP, add an `@ref` annotation: `// @ref LLP NNNN#section — short gloss`
- When modifying code that already carries a `@ref`, check that the referenced section still applies. Update or remove it if not.
- Don't annotate mechanically. A reference should tell you something you wouldn't know from reading only the code and filename.

## Working on this project

- Read relevant LLP documents before implementing features or fixing bugs in the areas they cover.
- If you make a design decision worth documenting, write or update an LLP for it.
- Prefer updating an existing LLP over creating a new one when the topic is already covered.
<!-- END LLP INIT MANAGED BLOCK -->
EOF
}

contains_llp_guidance_heuristic() {
  target_file=$1
  grep -Eq 'Linked Literate Programming|@ref LLP|NNNN-slug\.type\.md|llp/tombstones|LLP documents' "$target_file" 2>/dev/null
}

append_block_to_file() {
  target_file=$1
  block_file=$2
  output_file=$3

  if [ -s "$target_file" ]; then
    cat "$target_file" > "$output_file"
    printf '\n\n' >> "$output_file"
    cat "$block_file" >> "$output_file"
  else
    cat "$block_file" > "$output_file"
  fi
}

replace_block_in_file() {
  target_file=$1
  block_file=$2
  output_file=$3

  awk -v start="$MANAGED_START" -v end="$MANAGED_END" -v replacement="$block_file" '
    function print_replacement(    line) {
      while ((getline line < replacement) > 0) {
        print line
      }
      close(replacement)
    }

    $0 == start && !replaced {
      print_replacement()
      skipping = 1
      replaced = 1
      next
    }

    skipping {
      if ($0 == end) {
        skipping = 0
      }
      next
    }

    { print }
  ' "$target_file" > "$output_file"
}

upsert_managed_block() {
  target_file=$1
  block_file=$2

  if [ ! -e "$target_file" ] && [ ! -L "$target_file" ]; then
    write_file_from_temp "$block_file" "$target_file" "create file"
    return 0
  fi

  has_start=0
  has_end=0

  if grep -Fq "$MANAGED_START" "$target_file" 2>/dev/null; then
    has_start=1
  fi
  if grep -Fq "$MANAGED_END" "$target_file" 2>/dev/null; then
    has_end=1
  fi

  if [ "$has_start" -eq 1 ] && [ "$has_end" -eq 1 ]; then
    temp_output=$(make_temp_file)
    # @ref LLP 0007#idempotency — Re-run updates only the managed block, preserving user prose outside it.
    replace_block_in_file "$target_file" "$block_file" "$temp_output"
    write_file_from_temp "$temp_output" "$target_file" "update managed LLP block"
    return 0
  fi

  if [ "$has_start" -eq 1 ] || [ "$has_end" -eq 1 ]; then
    warn "found incomplete LLP managed block in $target_file; leaving the file unchanged"
    return 0
  fi

  if contains_llp_guidance_heuristic "$target_file"; then
    warn "$target_file appears to already contain LLP guidance outside the managed block; appending a managed block at the end"
  fi

  temp_output=$(make_temp_file)
  append_block_to_file "$target_file" "$block_file" "$temp_output"
  write_file_from_temp "$temp_output" "$target_file" "append managed LLP block"
}

create_claude_symlink() {
  if [ -e CLAUDE.md ] || [ -L CLAUDE.md ]; then
    return 0
  fi

  if [ "$dry_run" -eq 1 ]; then
    info "would create symlink: CLAUDE.md -> AGENTS.md"
    return 0
  fi

  ln -s AGENTS.md CLAUDE.md
  info "created symlink: CLAUDE.md -> AGENTS.md"
}

warn_if_non_greenfield() {
  first_extra=$(find . -mindepth 1 -maxdepth 1 \
    ! -name .git \
    ! -name llp \
    ! -name AGENTS.md \
    ! -name CLAUDE.md \
    ! -name README \
    ! -name README.md \
    ! -name LICENSE \
    ! -name LICENSE.md \
    ! -name .gitignore \
    ! -name .editorconfig \
    ! -name .github \
    -print | sed 's|^\./||' | head -n 1)

  [ -n "$first_extra" ] || return 0

  # @ref LLP 0007#repository-scope — Established repos get an advisory warning because this script only scaffolds LLP.
  warn "repository already contains '$first_extra'; this script creates LLP scaffolding but does not perform retrofit analysis"
}

repo_name_from_directory=$(title_case_words "${repo_root##*/}")
if [ -z "$project_name" ]; then
  project_name=$repo_name_from_directory
fi

project_slug=$(slugify "$project_name")
[ -n "$project_slug" ] || die "project name '$project_name' does not produce a usable LLP filename slug"

if [ -z "$author_name" ]; then
  author_name=$(git config user.name 2>/dev/null || true)
fi

if [ -z "$author_name" ]; then
  author_name='<Author Name>'
  warn "git config user.name is unset; using placeholder author name"
fi

warn_if_non_greenfield

if [ -d llp ]; then
  warn "llp/ already exists; leaving it in place"
fi
ensure_directory llp
ensure_directory llp/tombstones
ensure_empty_file llp/tombstones/.gitkeep

existing_llp_0000=''
for candidate in llp/0000-*.md; do
  if [ -e "$candidate" ]; then
    existing_llp_0000=$candidate
    break
  fi
done

if [ -n "$existing_llp_0000" ]; then
  warn "$existing_llp_0000 already exists; skipping LLP 0000 creation"
else
  llp_0000_path="llp/0000-${project_slug}.explainer.md"
  llp_temp=$(make_temp_file)
  write_temp_from_command "$llp_temp" emit_llp_0000
  write_file_from_temp "$llp_temp" "$llp_0000_path" "create file"
fi

if [ "$skip_agent_instructions" -eq 1 ]; then
  info "skipped agent instruction files"
  exit 0
fi

agent_block=$(make_temp_file)
write_temp_from_command "$agent_block" emit_managed_agent_block

# @ref LLP 0007#agent-instruction-files — AGENTS.md is canonical; CLAUDE.md is a symlink when safe and a separately managed file otherwise.
upsert_managed_block AGENTS.md "$agent_block"

if [ -e CLAUDE.md ] || [ -L CLAUDE.md ]; then
  if [ -e AGENTS.md ] && [ CLAUDE.md -ef AGENTS.md ]; then
    info "CLAUDE.md already points at AGENTS.md"
  else
    warn "CLAUDE.md exists separately from AGENTS.md; updating the managed LLP block in both files"
    upsert_managed_block CLAUDE.md "$agent_block"
  fi
else
  create_claude_symlink
fi
