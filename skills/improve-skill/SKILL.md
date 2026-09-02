---
name: improve-skill
description: Audit and refactor an existing skill — find variance bugs, prune dead load, sharpen triggers, fix structure.
disable-model-invocation: true
---

# Improve Skill

Audit an existing skill against the writing levers, then refactor it. The audit finds the failures; the refactor fixes the class, not the instance.

Read [`writing-for-agents`](../writing-for-agents/SKILL.md) first if available — every check below is one of its levers applied as a diagnostic. When the skill targets pi, also read [`references/pi.md`](../create-skill/references/pi.md) for frontmatter and discovery rules to audit against. When **creating** a skill from scratch rather than auditing one, use the `create-skill` skill instead.

The rubric below is the audit's list of questions; `create-skill` carries the current line-count target and the review checklist a skill should pass — audit against **that** as the single source of truth, not a number copied here.

## Audit

Read the whole skill (SKILL.md plus every file it points at), then run these checks. Each is a question; a "no" is a finding.

**Trigger (the description):**
- Does the description state what the skill does _and_ list its trigger branches? "All when-to-use lives in the description" — check the body isn't carrying trigger information the description lacks.
- Are the branches distinct, or synonyms of one branch written twice?
- Is it pushy enough? Undertriggering is the default failure — would the agent catch the adjacent phrasings a real user types?
- If `disable-model-invocation: true`, is the description human-facing (one-line summary, triggers stripped)? If absent, should the skill be user-invoked instead — does anything but a human ever need to reach it?

**Body:**
- **No-ops**: sentence by sentence — does this change behaviour versus the model's default? Delete what fails.
- **Sediment**: is every line still relevant to what the skill does today, or are stale layers settling?
- **Duplication**: is any meaning stated in two places (within the skill, or restating the environment — `package.json`, `--help`, directory layout)? Keep one source of truth; cache only what the environment cannot confess.
- **Negations**: prohibitions without a paired positive target? Reframe to what to do.
- **Sprawl**: is SKILL.md carrying reference only some branches need? Push it behind a pointer. Use the line-count target from `create-skill` as the fatigue signal, not a number restated here.
- **Buried steps**: if the skill has steps, is flat reference burying them? Disclose the reference so the steps stay visible.
- **Completion criteria**: does every step end on a checkable, demanding condition? Vague bounds invite premature completion.
- **Leading words**: passages restating one idea in many words, begging to collapse into a single token?
- **Structure**: deterministic operations reinvented per run that belong in `scripts/`? Templates or output files inline that belong in `assets/`?

**Pointers:**
- Every reference file reachable through a pointer that states _when_ to read it? A pointer that names the target but not the branch is a variance bug.
- Any must-have material sitting behind a weakly worded pointer? Sharpen the wording first; inline only if sharpening fails.

**Template:**
- Does the skill follow the standard template (`Quick start` → `Workflows` → `Advanced features`)? If not, is the deviation justified — or is it just a skill that grew without the leash?
- Does it pass the `create-skill` review checklist? Run it on this skill the same way it would be run on any other.

## Refactor

1. List the findings, ordered by cost: trigger failures first (the skill never fires, everything else is moot), then body failures, then structure.
2. Confirm with the user before editing — the audit is the deliverable they signed up for; the refactor is the follow-through.
3. Fix the class of failure, not the instance: one no-op deleted is a prune; the habit that wrote it is the finding.
4. Generalize, don't overfit: reframe rigid MUSTs into explained reasoning; replace fiddly patches with a better pattern.
5. After editing, re-run the audit on the diff: every line removed should have paid no load; every line added should earn it.

## Verify

If the skill produces verifiable output, run it on 2–3 realistic prompts before and after the refactor and compare — the refactor should change the _process_, not degrade the output. If subjective, ask the user to review the diff instead.

## Reference

- [`create-skill`](../create-skill/SKILL.md) — the creation workflow, template, and review checklist this skill audits against
- [writing-for-agents](../writing-for-agents/SKILL.md) — the writing levers every check here applies
