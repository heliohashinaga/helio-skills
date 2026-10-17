# Credits

This skill is a standalone adaptation of **`implement-spec`** from
[Matt Pocock's skills repo](https://github.com/mattpocock/skills) (MIT, © Matt Pocock).
The prose is reproduced from it — largely word-for-word.

## What changed

Upstream, `implement-spec` declares a hard dependency on `/setup-matt-pocock-skills`
(*“the issue tracker should have been provided to you”*). That setup skill is a run-once, manually invoked prerequisite per repo.

Here the config is resolved inline — **the local-markdown tracker by default**, overridable
per repo in `docs/agents/issue-tracker.md` / `docs/agents/triage-labels.md` — so the skill
runs with no setup step and installs on its own. The seed config files live in the repo at
[`templates/agent-config/`](../../../templates/agent-config/).
