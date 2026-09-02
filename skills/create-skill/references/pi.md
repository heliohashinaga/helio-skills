# Pi-specific skill mechanics

Creating a skill **for pi** (`~/.pi/agent/skills/`): discovery, frontmatter, commands, and validation. Source of truth: `docs/skills.md` in the pi package — check it before trusting anything here that could have changed.

## Discovery locations

- Global: `~/.pi/agent/skills/`, `~/.agents/skills/`
- Project (trusted repos only): `.pi/skills/`, `.agents/skills/` in cwd and ancestors up to the git root
- Packages: `skills/` dirs or `pi.skills` entries in `package.json`
- Settings `skills` array (files or dirs, e.g. reuse `~/.claude/skills`), and `--skill <path>` CLI flag

In `~/.pi/agent/skills/` and `.pi/skills/`, a bare `.md` file at the root with valid frontmatter is itself a skill; directories are found recursively via their `SKILL.md`. In `.agents/skills/` locations, root `.md` files are ignored — only nested ones count.

**Symlinks work** and are the standard pattern here: keep the skill in a git repo and link it in (`ln -s <repo>/skills/<name> ~/.pi/agent/skills/<name>`).

## Frontmatter (pi)

| Field | Notes |
|---|---|
| `name` | Required. 1–64 chars, lowercase `a-z 0-9 -`, no leading/trailing/consecutive hyphens. Pi does **not** require it to match the directory name (the Agent Skills standard does). |
| `description` | Required. Max 1024 chars. The entire trigger mechanism — a skill without one is not loaded. |
| `license`, `compatibility`, `metadata` | Optional; `compatibility` max 500 chars. |
| `allowed-tools` | Optional, experimental: space-delimited pre-approved tools. |
| `disable-model-invocation` | `true` hides the skill from the system prompt; only `/skill:name` reaches it (the user-invoked choice — see `writing-for-agents/SKILL-MECHANICS.md`). |

Unknown fields are ignored. Most violations warn but still load; a missing `description` does not load. Name collisions across locations keep the first found.

## Invocation

- **Model-invoked** (default): name + description live in the system prompt as XML; the agent `read`s the full SKILL.md when the description matches — but models don't always do this, so descriptions carry the weight.
- **User-forced**: `/skill:<name>` loads it explicitly; arguments are appended as `User: <args>`. Requires `enableSkillCommands` (on by default; toggle in `/settings`).

## Repo layout used in pi-agent-skills

- One folder per skill under `skills/`, symlinked into `~/.pi/agent/skills/`.
- Sibling cross-references use relative paths (`../writing-for-agents/SKILL.md`), valid from either location since the symlink preserves the layout.
