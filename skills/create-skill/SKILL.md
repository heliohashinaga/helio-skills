---
name: create-skill
description: Create, edit, or improve pi/agent skills (SKILL.md) — capture intent, draft from the template, test, iterate.
disable-model-invocation: true
---

# Create Skill

A skill is a folder with a `SKILL.md`: YAML frontmatter (`name`, `description`) plus Markdown instructions. The skill's job is to make a behaviour repeatable across runs — the agent takes the same _process_ every time, not the same output.

Read [`writing-for-agents`](../writing-for-agents/SKILL.md) first if available: it carries the levers (context pointers, the two loads, information hierarchy, leading words, pruning) that make the writing predictable. This skill carries the workflow: capture, draft, test, iterate.

When the skill targets **pi**, read [`references/pi.md`](references/pi.md) for discovery locations, pi's frontmatter rules, `/skill:name` commands, and the symlink install pattern. When **auditing or refactoring** an existing skill rather than creating one, use the `improve-skill` skill instead.

## Capture intent

Scaffold the new skill folder from [`assets/SKILL-TEMPLATE.md`](assets/SKILL-TEMPLATE.md), then answer these before filling it in:

1. What should the agent be able to do with this skill?
2. When should it trigger — which user phrases, contexts, branches?
3. What does a good output look like? If the skill produces something verifiable (file transforms, fixed workflow steps), plan test cases; if subjective (writing style), plan qualitative review instead.
4. Does the skill need to be reached by the agent on its own (model-invoked) or only by a human typing its name (user-invoked)? See the invocation choice in [`writing-for-agents/SKILL-MECHANICS.md`](../writing-for-agents/SKILL-MECHANICS.md).

Mine the current conversation first: if the user says "turn this into a skill", the tools used, the sequence of steps, and the corrections the user made are the spec.

## Structure

```
skill-name/            # kebab-case, matches the name field
├── SKILL.md           # required: frontmatter + instructions
├── scripts/           # deterministic, repeatable operations (optional)
├── references/        # docs loaded on demand via pointers (optional)
└── assets/            # templates and files used in output (optional)
```

- Keep `SKILL.md` lean — under ~500 lines. When material serves only some branches, push it to `references/` behind a context pointer that states when to read it.
- When several branches need the same deterministic operation (a transform, a scaffold, a validator), write it once in `scripts/` and point at it, instead of making every run reinvent it.
- Organize references by variant when the skill spans domains (one file per framework/tool), so a run loads only its own branch.

## Write the description

The description is the skill's only always-loaded pointer and its entire triggering mechanism. All "when to use" information lives here, not in the body:

- Imperative, starting with what it does, then "Use when..." with the concrete trigger branches.
- Distinct branches only — synonyms of one branch are one branch written twice.
- Slightly pushy beats undertriggering: name the adjacent phrasings the agent should catch even when the user never says the skill's name.

## Write the body

- Imperative steps, each ending on a checkable completion criterion.
- Explain the _why_ behind instructions rather than stacking MUSTs — the agent generalizes from reasons and rote from rules.
- Include concrete input/output examples for any fixed format the skill produces.
- Cache what the environment cannot confess (unwritten conventions, the reason behind a choice, gotchas); never restate what `package.json`, `--help`, or the directory layout already says.

## Test and iterate

1. Draft 2–3 realistic test prompts — what a real user would actually type, including messy phrasing and near-miss cases that should _not_ trigger.
2. Run the skill on them (ideally against a baseline without the skill) and review outputs with the user.
3. Generalize from feedback: fix the class of failure, not the instance. If all test runs independently rebuild the same helper, promote it to `scripts/`.
4. Prune between iterations: every line pays context load, so delete what doesn't change behaviour versus the default.
5. Repeat until feedback is empty or progress stalls.

## Reference

- [Matt Pocock — writing-for-agents](https://github.com/mattpocock/skills/tree/main/skills/productivity/writing-for-agents)
- [Anthropic — skill-creator](https://github.com/anthropics/skills/blob/main/skills/skill-creator/SKILL.md)
- [agentskills.io — best practices](https://agentskills.io/skill-creation/best-practices)
