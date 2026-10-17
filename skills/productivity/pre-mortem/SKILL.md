---
name: pre-mortem
description: "Pre-mortem a plan: assume it failed, work back to why."
---

# Pre-Mortem

Assume the project or decision **has already failed**, and work backwards to why — before it
happens. Use it before starting a project, migrating stacks, signing a contract, or any
irreversible call; when something seems too good to be true; and for medium/high-cost calls
(money, time, reputation).

## Workflow

1. **Define scope** — which project/decision? What's the deadline? Who are the stakeholders?
2. **Write the failure** — "6 months from now, this failed because...". Write 3–5 distinct reasons.
3. **Classify each reason** — probability (low/medium/high) × impact (minor/major/critical).
4. **Generate mitigations** — for every medium/high-probability reason: what you do now, what you do if it happens, and the early-warning signal that tells you it's happening.
5. **Validate with a skeptic** — put it in front of someone who disagrees with the idea. Done when they have added at least one reason you missed; zero new reasons means the analysis is incomplete.

## Output format

```
## Pre-Mortem: [project name]

**Date:** [today] | **Review deadline:** [X weeks/months]

### Predicted failures

| # | Cause | Probability | Impact | Mitigation |
|---|-------|-------------|--------|------------|
| 1 | ... | High | Critical | ... |
| 2 | ... | Medium | Major | ... |
| 3 | ... | Low | Minor | ... |

### Early warning signals
- [ ] ...

### Plan B (if it fails)
- ...

### Review on: [date]
```

## Example

**Project:** "Migrate from a spreadsheet to a paid finance app"

- Failure 1: "Historical data loss during migration" → High/Critical → backup + manual validation before deleting
- Failure 2: "App doesn't support dollar accounts" → Medium/Major → test with real data before signing up
- Failure 3: "Forget to log expenses for two weeks and lose the habit" → High/Major → keep the old spreadsheet running in parallel for a month

## Pitfalls

- **Stay on the failure side.** Aim every reason at what will go wrong; a pre-mortem is not a brainstorm about what makes it work.
- **Include the causes you'd rather not say.** The embarrassing ones ("I lose the habit") are the most predictive, so write them down.
- **Re-run it at each milestone.** The reasons shift as the project moves; a pre-mortem is a checkpoint, not a one-off.
- **Monitor what you can't mitigate.** An uncontrollable cause still earns an early-warning signal, even with no mitigation.
