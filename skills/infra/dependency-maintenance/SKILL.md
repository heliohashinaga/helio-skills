---
name: dependency-maintenance
description: "Use when merging bot dependency PRs. Triage, rebase, merge."
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [dependabot, renovate, dependencies, vulnerabilities, pr-triage, rebasing, github, ci]
    category: software-development
    related_skills: [github]
---

# Dependency Maintenance

Work a backlog of bot dependency-update PRs (Dependabot, Renovate) to
green `main`: inventory, unblock, merge in order, rebase between merges.
Use `gh` for all remote reads; verify every remote claim fresh — never
report CI green without `gh pr checks`, never claim merged without
`state,mergedAt`. Present work in small batches and get approval per
batch before merging.

## When to Use

- A repo has open Dependabot/Renovate update PRs to triage and merge.
- A vulnerability-fix backlog (security bumps, advisory-driven PRs).
- Bot PRs are red and the cause may be on the default branch or a
  version conflict between the bumped packages.

## Procedure

### 1. Inventory per repo

```bash
gh pr list --repo OWNER/REPO --author app/dependabot --limit 20 \
  --json number,title,mergeable,mergeStateStatus,statusCheckRollup
```

Triage into three buckets:
- **CLEAN + green** — mergeable now.
- **UNSTABLE (checks failing)** — diagnose before touching; the fix may
  belong on the default branch, not on the bot branch.
- **Superseded** (old patch-range bump shadowed by a newer bump of the
  same package) — leave until the newer one merges, then let the bot
  close it.

### 2. Unblock the default branch first

When every bot PR fails on the SAME lint/type error, the cause is a
pre-existing break on the default branch, not the bump. Fix it via a
normal branch + PR, verify checks green, merge, then rebase the bot PRs
so they inherit the fix.

### 3. Merge in order, one at a time

1. Security fixes first (the PR body quotes the advisory/GHSA).
2. Then smallest → largest.
3. After EACH merge, re-read the remaining PRs: `mergeStateStatus`
   flips to `UNKNOWN` while the host recomputes, then settles to `CLEAN`
   or `DIRTY`/`CONFLICTING`. Never merge on a stale `CLEAN` read taken
   before the previous merge.

### 4. Rebase via comment, verify fresh checks

```bash
gh pr comment N --repo OWNER/REPO --body "@dependabot rebase"
```

Lockfile PRs (`pnpm-lock.yaml`, `uv.lock`, `package-lock`) conflict with
each other by design — expect `DIRTY` after each merge and rebase again.
After every rebase, wait for NEW check runs on the rebased SHA (`gh pr checks N`); checks shown before the rebase belong to the old base and do not count. When a newer patch of the same package exists, prefer `@dependabot recreate` over debugging the old version — the bot reacts with delay, so do other work instead of blocking.

Done means: open bot-PR list empty (allow a polling delay after the
last merge), every merge verified with `state,mergedAt`.

### 5. Diagnose failures from saved logs

Save failed logs to scratch, then filter — raw output carries carriage
returns and per-line prefixes that defeat naive matching:

```bash
gh run view RUN_ID --repo OWNER/REPO --log-failed > "$SCRATCH/ci.log" 2>&1
grep -a -n "error TS\|F[0-9]\{3\}\|E[0-9]\{3\}\|FAILED\|AssertionError" "$SCRATCH/ci.log"
```

Read the lines AROUND the match (file:line + rule code), not just the
summary count — runners print "Found N errors" with zero detail.

## Pitfalls

- Align dual transitive versions, never cast the boundary — when the log
  shows `Type '.../pkg@NEW.../X.T' is not assignable to type
  '.../pkg@OLD.../X.T'`, two copies of one transitive package resolve at
  once. Bump the lagging direct dependency until the lockfile holds a
  single version of it; pushing the companion bump onto the bot branch
  is allowed and keeps the fix with the bump (bot branches accept
  maintainer pushes).
- Consolidate mutually-blocking bumps: when every bump PR fails on a version-downgrade error because a transitive floor rose above a direct pin, merge them as one aligned PR covering all pending bumps PLUS the direct pins the bot didn't touch. Check the framework SDK reference too, not just package lines.
- Prove the bump caused it: green baseline on the default branch plus red on the bump branch with identical tests; confirm against recent default-branch CI history.
- Crash sits in framework code above user code: a user-land provider shim cannot interpose, so patch at the source (`pnpm patch`, `pnpm patch-commit`) with a TODO naming the upstream fix.
- Formatter that passed with no code changes is SDK drift: run the formatter locally, commit the result.
- Preserve line endings on bulk manifest edits: check per-file originals before sed-editing and restore after; trust `git diff --name-only` over `git status` under autocrlf noise and commit by path.
- Distinguish alert-API 403 causes — `dependabot/alerts` returns 403 both
  when the token lacks the `security_events` scope and when alerts are
  disabled for the repo. Read the response message before declaring
  alerts missing; without that scope the open bot-PR list is the working
  substitute for the alert list. Same scope gap blocks `gh run rerun --failed` and repo-settings PATCH — fall back to the browser instead of retrying the API.

## Automation

- `dependabot.yml` groups: batch safe bumps, keep breaking majors solo (`groups: {name: {patterns: ["*"]}, update-types: [minor, patch]}`). Use ONE group for ecosystems with diamond conflicts so versions align in a single PR. Add an entry per manifest directory — a missing entry means silent zero coverage, so confirm update runs exist for every directory.
- Auto-merge workflow (`templates/dependabot-automerge.yml`): `pull_request_target` gated on actor `dependabot[bot]` → fetch-metadata → skip semver-major → `gh pr checks --watch --fail-fast` → squash-merge. Needs no branch protection.
- Weekly digest: list open bot PRs per repo with check status; report green-pending-auto-merge vs blocked-with-cause vs majors-needing-decision. Never merge red.

## pnpm patch (JS shims for lagging published deps)

`pnpm patch pkg@version`, edit the copy, then `pnpm patch-commit <dir>` — commits `patches/`, the workspace `patchedDependencies` entry, and the lockfile hash. Mark the patch with a TODO naming the upstream fix that retires it. `patch-commit` spawns a `pnpm` binary internally, so `pnpm` must resolve on PATH.

## More pitfalls

- Read the real browser error, not the test-runner's mapped stack — bundle positions misattribute the crash. Drive the failing page with a throwaway Playwright script that prints console errors and pageerrors; the true frame (e.g. `useRouter` inside a framework boundary) names the fix.
- `gh run rerun` needs `actions:write`; when the token lacks it, an empty commit on the branch is the retrigger. Removing a permanently-red CI job outright requires rewiring every `needs:` that names it, or the workflow fails to parse.
- After running a repo formatter for a CI whitespace gate, commit only files with real content diffs — formatters rewrite line endings repo-wide, so gate the commit on `git diff --numstat`, not on `git status`.
- A failure in a gate the diff cannot affect earns ONE empty-commit retrigger; merge only on a green rerun, never on the red run.
- Watch main CI after merging: integration/deploy jobs often run on main only, so a green PR does not imply a green main. A main-only failure predating the change (check push-event history) is pre-existing — report it, do not chase it inside the dep batch without approval.
