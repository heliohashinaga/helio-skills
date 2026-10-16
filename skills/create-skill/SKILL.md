---
name: create-skill
description: "Create, edit or improve a SKILL.md — draft, test, iterate."
disable-model-invocation: true
---

# Create Skill

A skill is a folder with a `SKILL.md`: YAML frontmatter (`name`, `description`) plus Markdown instructions. The skill's job is to make a behaviour repeatable across runs — the agent takes the same _process_ every time, not the same output.

Why a skill: it packages a repeatable process so the model runs it the same way every run. Reach for it when the behaviour is worth fixing; skip it for a one-off task, or when you cannot name the process being repeated.

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

- Keep `SKILL.md` lean — under ~150 lines; treat 100 as the yellow flag. When only some branches need material, push it to `references/` behind a context pointer that states when to read it.
- When several branches need the same deterministic operation (a transform, a scaffold, a validator), write it once in `scripts/` and point at it, instead of making every run reinvent it. Scripts carry their own rules — agent-runnable, verification, and what to fix when you move one: read [`references/scripts.md`](references/scripts.md) before writing or moving a script.
- Organize references by variant when the skill spans domains (one file per framework/tool), so a run loads only its own branch.
- A sibling markdown file in the skill folder (flat, `UPPER-KEBAB.md`, no subfolder) is the idiomatic home for a **single document with a rigid format** the body references wholesale — e.g. `MISSION-FORMAT.md`. Use it over prose in the body when the format is long or shared; the body then points at it with a relative link.

## Write the description

The description is the skill's only always-loaded pointer and its entire triggering mechanism. All "when to use" information lives here, not in the body:

- Imperative, starting with what it does, then "Use when..." with the concrete trigger branches.
- Distinct branches only — synonyms of one branch are one branch written twice.
- Slightly pushy beats undertriggering: name the adjacent phrasings the agent should catch even when the user never says the skill's name.

Good vs bad description (the bad one gives the agent no way to tell this skill from any other):

```markdown
# Bad: "Helps with documents."

# Good: "Extract text and tables from PDF files, fill forms, merge documents.
#        Use when working with PDF files, or when the user mentions PDFs,
#        forms, or document extraction."
```

### Hard rules (the agent index)

Mechanical, not stylistic. Two agents read these skills (Hermes and Pi), and one
description serves both:

- **Maximum 60 characters total.** The Hermes skill index truncates past that, so
  a longer description loses its routing tail. Count it, don't eyeball it.
- **One line, plain scalar.** Never `description: |` or `description: >` — a
  block scalar defeats the length/index handling that expects one line.
- **Double-quote the value if it contains a colon**, otherwise the YAML is
  invalid. Watch the failure mode: Hermes' own loader parses an unquoted colon
  leniently and still lists the skill, while Pi and other strict YAML parsers
  silently drop it from the index with no error shown.
- **Validate with a strict parser** before calling the skill healthy:
  `python -c "import yaml,sys; print(yaml.safe_load(open(sys.argv[1]).read().split('---')[1]))" SKILL.md`.
  Loading it in the agent that authored it proves nothing.
- **When shortening drops information** the old description carried (a
  disambiguation, a version floor, a behaviour gate), move it into the body's
  opening line — the description is the trigger, the body is where the detail
  survives.
- **Pi's own limit is looser** (max 1024 chars) but the 60-char cap is the house
  rule for every library on this machine. Pi-specific frontmatter details live in
  [`references/pi.md`](references/pi.md).

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

## Review checklist

Before declaring the skill done, walk the draft through this:

- [ ] Description includes distinct trigger branches ("Use when..."), not just what the skill does
- [ ] `SKILL.md` under ~150 lines, split by branch into `references/`
- [ ] No time-sensitive information that will go stale
- [ ] Terminology consistent across the skill and with the writing levers
- [ ] Concrete input/output examples for any fixed format the skill produces
- [ ] References one level deep — no `references/` file that points at another

## Reference

- [Matt Pocock — writing-for-agents](https://github.com/mattpocock/skills/tree/main/skills/productivity/writing-for-agents) — the source of truth for writing principles. (Formerly `writing-great-skills`; replaced the now-retired `write-a-skill`.)
- [Anthropic — skill-creator](https://github.com/anthropics/skills/blob/main/skills/skill-creator/SKILL.md)
- [agentskills.io — best practices](https://agentskills.io/skill-creation/best-practices)
