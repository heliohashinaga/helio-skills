# Credits

This skill is a standalone adaptation of **`triage`** from
[Matt Pocock's skills repo](https://github.com/mattpocock/skills) (MIT,
© Matt Pocock). The roles, the state machine, the triage flow, `AGENT-BRIEF.md`
and `OUT-OF-SCOPE.md` are reproduced from it — the prose is largely
word-for-word.

The seed templates in [`references/`](references/) (issue-tracker GitHub /
GitLab / local, `triage-labels.md`, `domain.md`) come from the same repo's
**`setup-matt-pocock-skills`** skill.

## Why this copy exists

Upstream, `triage` carries a hard dependency on `/setup-matt-pocock-skills`:
it cannot map its label vocabulary or know where issues live until that setup
skill has run once per repo. This variant removes that dependency — the
per-repo config is resolved inline (read the file if present, otherwise fall
back to a complete default) and the setup skill's templates are embedded under
`references/`, so the skill installs and runs on its own.

Content copied in rather than pointed at is what makes a standalone install
possible; this file is the attribution a dependency would otherwise have
carried. The remaining reference to `grilling` / `domain-modeling` is
soft — the skill degrades to an inline equivalent when they aren't installed.
