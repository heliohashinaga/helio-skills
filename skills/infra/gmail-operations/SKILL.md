---
name: gmail-operations
description: "Use for bulk Gmail API work: census, bulk label/archive."
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [windows, linux, macos]
metadata:
  hermes:
    tags: [gmail, email, bulk, labels]
    related_skills: [email-inbox-triage]
---

# Gmail Operations

Bulk Gmail mailbox work through throwaway API scripts (census, bulk label/archive, dedup labels). Single-message reads/sends belong to the connector skill; this skill owns batch jobs the connector CLI cannot express.

## When to Use

- Labeling or archiving the whole inbox by rule (e.g. transactionals to Reference, promos to Reading).
- Counting the mailbox by category/sender before proposing a bulk action.
- Consolidating duplicate labels or inventorying filters.

## Procedure

1. Census first (read-only): count `in:inbox` by category (`category:promotions/social/updates/personal`), unread, and `has:attachment filename:pdf`; sample top senders. Never bulk-apply without this map.
2. Propose the bucket mapping with concrete numbers (what gets which label, what gets archived, what stays) and get explicit approval — archiving is reversible, but mislabeled hundreds are still hours to untangle.
3. Apply with a scratch script: `batchModify` in chunks of up to 1000; archiving is `removeLabelIds: [INBOX]`, never delete.
4. Verify with EXACT paginated counts (`messages.list` pages, not `resultSizeEstimate`) per label and for `in:inbox` — the estimate lags behind mutations and reports stale totals.

## Standing rules

- Run scripts with the Hermes venv python plus `PYTHONPATH="$HERMES_HOME/python-libs"` (google-api-python-client lives there); write the script with `write_file` under `$HERMES_HOME/cache/scratch/` and run it via `terminal` — never inline `-c` one-liners, shell quoting mangles them.
- Resolve label name→ID fresh inside every script run: users recreate labels in the Gmail UI, so an ID captured earlier in the session can point at a deleted label or lose to a same-name duplicate.
- Scope matrix: `gmail.modify` covers message label changes and label create/delete; `gmail.settings.basic` (filters) is NOT in the standard token — filter creation must be a manual Gmail-UI step or a re-auth with the extra scope.

## Pitfalls

- Trusting `resultSizeEstimate` right after a bulk mutation — it reports pre-mutation totals, so a correct run looks failed; always recount by pagination before reporting.
- Bulk-archiving unread transactionals that need action (bank alerts, bills) — route `is:unread` updates to `Action` and keep them in the inbox; only archive the read ones.
