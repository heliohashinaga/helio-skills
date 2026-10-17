# Engineering Skills

Skills in this directory are derived from [Matt Pocock's skills repo](https://github.com/mattpocock/skills) (MIT, © Matt Pocock).

## Why they are copied

The upstream versions declare a hard dependency on a run-once, manually-invoked setup skill (`/setup-matt-pocock-skills`) that each consumer says *"if not provided, tell the user to run this first"* — stalling until someone runs it per repo. That setup skill is also reachable only by typing its name; no other skill can fire it.

These variants remove that dependency. The per-repo configuration (issue tracker, label vocabulary, domain docs) is resolved inline — **the local-markdown tracker by default**, overridable in `docs/agents/issue-tracker.md` and `docs/agents/triage-labels.md` — so each skill runs with no setup step and installs on its own. The seed config files live in the repo at [`templates/agent-config/`](../templates/agent-config/) (issue-tracker GitHub / GitLab / local, `triage-labels.md`, `domain.md`).

## Adapted skills

- `triage` — roles, state machine, flow, `AGENT-BRIEF.md`, `OUT-OF-SCOPE.md`
- `code-review` — Standards + Spec review in parallel sub-agents
- `implement-spec` — implement a spec's tickets on one integration branch
- `to-tickets` — break a plan/spec into tracer-bullet tickets with blocking edges
- `wayfinder` — plan work too big for one session as a map of decision tickets
