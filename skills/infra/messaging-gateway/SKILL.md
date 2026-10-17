---
name: messaging-gateway
description: "Use when connecting Hermes to chat platforms."
version: 1.0.0
author: Hermes Agent + curator
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [hermes, gateway, messaging, discord, telegram, debugging]
---

# Messaging Gateway Setup & Debugging

Connect a chat platform to the Hermes gateway and verify it end to end.
For full platform references, check the docs index at
`https://hermes-agent.nousresearch.com/docs/llms.txt` first.

## When to Use

Any request to connect Hermes to a chat platform (Discord, Telegram, Slack,
WhatsApp, …) or to diagnose why an already-configured platform is not
connecting or responding.

## Procedure

1. Resolve the real Hermes home from `$HERMES_HOME` (on Windows it is
   `%LOCALAPPDATA%\hermes`, not `~/.hermes`) — never hardcode the path.
2. Confirm credentials exist in `$HERMES_HOME/.env` without printing secrets:
   check presence and shape only (e.g. count characters and dot-separators).
3. Before pointing a cron job at a platform, confirm that platform's home
   channel key exists in `$HERMES_HOME/.env` (e.g. `DISCORD_HOME_CHANNEL`):
   list key names only, never values — a bare `deliver: <platform>` target
   resolves to the home channel and the run fails when the key is missing.
4. Run `hermes gateway status` for the baseline (running vs stopped, recent health).
5. Test with a bounded foreground-style run: start `hermes gateway run` as a
   background process, wait ~25s, run `hermes gateway status` again, then kill
   the background process. `status` surfaces per-platform errors under
   "Recent gateway health" — that output is the test verdict. For a cron
   delivery change, prefer firing the job once via the cron `run` action and
   reading the delivery verdict from its outcome instead of waiting for the
   next scheduled tick.
6. Report what changed, what the verdict was, and the single next step.

## Pitfalls

- Validate a Discord bot token by shape before restarting the gateway: a real
  bot token is long (~70+ chars) with two dots separating three parts, copied
  from Developer Portal application > Bot > Token — a 32-char dotless value is
  the Client Secret from the General Information page and always fails login
  with `Improper token has been passed`, because the portal shows several
  similar-looking credentials on different tabs.
- Never print a credential value to check it: pipe through a redacting
  transform (length and separator counts only), since terminal output persists
  in transcripts and logs.
- A successful-looking `.env` edit means nothing until the gateway re-reads it:
  always re-run the test loop after a credential change instead of assuming
  the running (or stopped) gateway picked it up.
- A bare cron `deliver: <platform>` means that platform's home channel, not
  "the platform in general" — the run fails with `no delivery target
  resolved` when `<PLATFORM>_HOME_CHANNEL` is absent, even with a valid bot
  token, because token presence and delivery routing are independent checks.
  Fix with `/sethome` in the target channel or an explicit
  `deliver: <platform>:<channel_id>` target.
- Multi-target cron delivery (e.g. `deliver: telegram,discord`) broadcasts
  one-way and disables `attach_to_session` continuity — keep a single target
  for conversational jobs, or split one job per platform when replies must
  stay threaded.
- Format Discord deliveries as plain-markdown only: put bare URLs on their own
  lines, because plain messages do not render `[text](url)` masked links
  (only rich embeds do) — a masked link arrives as literal bracket text nobody
  can click. Same reason: bullets and emoji headers instead of tables, which
  Discord does not render.
