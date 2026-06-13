#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

dry_run=0
do_fetch=1
do_commit=1
do_push=1
include_untracked=0
message=""
repos=()
committed_changes=0

usage() {
  cat <<'EOF'
Usage: scripts/update_yacl_remotes.sh [options]

Sync the parent YACL repo and nested examples/* Git repos.

Options:
  -n, --dry-run            Print actions without changing commits or remotes.
      --no-fetch           Do not fetch before comparing with upstream.
      --no-commit          Do not auto-commit dirty tracked files.
      --no-push            Do not push commits.
      --include-untracked  Include untracked files in auto-commits.
  -m, --message MESSAGE    Commit message to use for dirty repos.
      --repo PATH          Limit to one repo; repeatable. Use "." for YACL root.
  -h, --help               Show this help.

Default behavior:
  - discovers the YACL root plus examples/* directories that contain .git
  - commits modified/deleted tracked files, but ignores untracked files
  - fetches the repo remote, then pushes only if the local branch is ahead
  - skips repos that are behind or diverged, so no merge/rebase is done here
EOF
}

log() {
  printf '%s\n' "$*"
}

run() {
  log "+ $*"
  if (( ! dry_run )); then
    "$@"
  fi
}

relpath() {
  local path="$1"
  if [[ "$path" == "$ROOT" ]]; then
    printf '.'
  else
    printf '%s' "${path#$ROOT/}"
  fi
}

default_message_for() {
  local repo="$1"
  if [[ "$repo" == "$ROOT" ]]; then
    printf 'chore: sync yacl updates'
  else
    printf 'chore: sync %s updates' "$(basename "$repo")"
  fi
}

first_remote() {
  git -C "$1" remote | head -n 1
}

current_branch() {
  git -C "$1" branch --show-current
}

upstream_ref() {
  git -C "$1" rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' 2>/dev/null || true
}

remote_tracking_ref() {
  local repo="$1"
  local remote="$2"
  local branch="$3"
  local upstream="$4"

  if [[ -n "$upstream" ]]; then
    printf 'refs/remotes/%s' "$upstream"
  else
    printf 'refs/remotes/%s/%s' "$remote" "$branch"
  fi
}

has_dirty_files() {
  local repo="$1"
  if (( include_untracked )); then
    [[ -n "$(git -C "$repo" status --porcelain)" ]]
  else
    [[ -n "$(git -C "$repo" status --porcelain --untracked-files=no)" ]]
  fi
}

commit_dirty_files() {
  local repo="$1"
  local rel="$2"
  local commit_message="${message:-$(default_message_for "$repo")}"

  if ! has_dirty_files "$repo"; then
    return 0
  fi

  if (( ! do_commit )); then
    log "!! $rel has dirty files; --no-commit prevents syncing it."
    return 1
  fi

  log "== $rel: commit local changes =="
  if (( include_untracked )); then
    run git -C "$repo" add -A
  else
    run git -C "$repo" add -u
  fi

  if (( dry_run )); then
    log "+ git -C $repo diff --cached --check"
    log "+ git -C $repo commit -m \"$commit_message\""
    committed_changes=1
    return 0
  fi

  git -C "$repo" diff --cached --check
  if git -C "$repo" diff --cached --quiet; then
    log "-- $rel: no staged changes after applying staging policy."
    return 0
  fi
  run git -C "$repo" commit -m "$commit_message"
  committed_changes=1
}

sync_repo() {
  local repo="$1"
  local rel
  rel="$(relpath "$repo")"

  log ""
  log "## $rel"
  committed_changes=0

  local branch
  branch="$(current_branch "$repo")"
  if [[ -z "$branch" ]]; then
    log "!! $rel is in detached HEAD; skipped."
    return 1
  fi

  local remote
  remote="$(first_remote "$repo")"
  if [[ -z "$remote" ]]; then
    log "!! $rel has no remote; skipped."
    return 1
  fi

  commit_dirty_files "$repo" "$rel" || return 1

  local upstream
  upstream="$(upstream_ref "$repo")"
  local remote_branch="$branch"
  if [[ -n "$upstream" ]]; then
    remote="${upstream%%/*}"
    remote_branch="${upstream#*/}"
  fi

  if (( do_fetch )); then
    log "== $rel: fetch $remote =="
    run git -C "$repo" fetch "$remote"
  fi

  local tracking_ref
  tracking_ref="$(remote_tracking_ref "$repo" "$remote" "$branch" "$upstream")"

  if ! git -C "$repo" show-ref --verify --quiet "$tracking_ref"; then
    if (( do_push )); then
      log "== $rel: create upstream $remote/$remote_branch =="
      run git -C "$repo" push -u "$remote" "$branch:$remote_branch"
    else
      log "-- $rel: no tracking ref $tracking_ref and --no-push set."
    fi
    return 0
  fi

  local counts ahead behind
  counts="$(git -C "$repo" rev-list --left-right --count "HEAD...$tracking_ref")"
  ahead="${counts%%[[:space:]]*}"
  behind="${counts##*[[:space:]]}"
  if (( dry_run && committed_changes )); then
    ahead=$((ahead + 1))
  fi

  log "-- $rel: ahead=$ahead behind=$behind upstream=$remote/$remote_branch"

  if (( behind > 0 && ahead > 0 )); then
    log "!! $rel diverged from $remote/$remote_branch; resolve manually."
    return 1
  fi
  if (( behind > 0 )); then
    log "!! $rel is behind $remote/$remote_branch; pull/rebase manually."
    return 1
  fi
  if (( ahead == 0 )); then
    log "-- $rel: already synced."
    return 0
  fi

  if (( do_push )); then
    log "== $rel: push $ahead commit(s) =="
    run git -C "$repo" push "$remote" "$branch:$remote_branch"
  else
    log "-- $rel: push needed but --no-push set."
  fi
}

discover_repos() {
  if ((${#repos[@]})); then
    local explicit=()
    local item
    for item in "${repos[@]}"; do
      if [[ "$item" == "." ]]; then
        explicit+=("$ROOT")
      elif [[ "$item" = /* ]]; then
        explicit+=("$item")
      else
        explicit+=("$ROOT/$item")
      fi
    done
    printf '%s\n' "${explicit[@]}"
    return
  fi

  printf '%s\n' "$ROOT"
  find "$ROOT/examples" -mindepth 2 -maxdepth 2 -name .git -type d \
    | sed 's#/.git$##' \
    | sort
}

while (($#)); do
  case "$1" in
    -n|--dry-run)
      dry_run=1
      shift
      ;;
    --no-fetch)
      do_fetch=0
      shift
      ;;
    --no-commit)
      do_commit=0
      shift
      ;;
    --no-push)
      do_push=0
      shift
      ;;
    --include-untracked)
      include_untracked=1
      shift
      ;;
    -m|--message)
      message="${2:?missing message}"
      shift 2
      ;;
    --repo)
      repos+=("${2:?missing repo path}")
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown option: %s\n\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

failures=0
while IFS= read -r repo; do
  [[ -n "$repo" ]] || continue
  if [[ ! -d "$repo/.git" ]]; then
    log "!! $(relpath "$repo") is not a Git repo; skipped."
    failures=$((failures + 1))
    continue
  fi
  if ! sync_repo "$repo"; then
    failures=$((failures + 1))
  fi
done < <(discover_repos)

log ""
if (( failures )); then
  log "Done with $failures repo(s) needing manual attention."
  exit 1
fi

log "All selected repos are synced."
