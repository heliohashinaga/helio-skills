# Helio Skills

A collection of production-grade skills, agents, and extensions for [pi](https://github.com/earendil-works/pi) — a coding agent harness for parallel AI-assisted development.

## 📁 Structure

```
helio-skills/
├── link-skills.sh   # Link this repo's skills into ~/.pi/agent/skills
├── skills/          # Reusable capabilities, grouped by category
│   ├── engineering/ # Languages, frameworks, workflow, review, docs
│   ├── infra/       # Host/OS, email, deps, file hygiene
│   └── productivity/# Authoring, thinking, organization
├── templates/       # Seed files (agent-config: tracker / labels / domain docs)
├── agents/          # Read-only subagent definitions
└── extensions/      # pi extensions (commands, renderers, lifecycle hooks)
```

| Component | Purpose | Example |
|---|---|---|
| **Skills** | Capabilities loaded into pi sessions | `nextjs`, `python`, `rust` |
| **Agents** | Read-only subagents for delegation | `worker-complex`, `retro` |
| **Extensions** | Commands, renderers, lifecycle hooks | `devloop`, `orchestration-advisor` |

---

## 🎯 Skills

Skills are grouped by **category in the repo** and **flattened at install** (one link per skill).
See [Install Skills](#install-skills).

### Engineering

Languages, frameworks, and code-quality capabilities.

| Skill | Description |
|---|---|
| **dotnet** | .NET/C# — `dotnet build`, xUnit, ASP.NET Core, EF Core, NuGet |
| **python** | Python — pyproject.toml, uv, ruff, pytest, asyncio, src layout |
| **rust** | Rust — Cargo, modules, `Result`/`?`, Clippy, rustfmt |
| **typescript** | TypeScript — strict config, ESM, feature-based modules, Zod |
| **vuejs** | Vue 3 — Composition API, Vite, Pinia, Vitest |
| **nextjs** | Next.js (App Router) + React 19 — RSC, Server Actions, i18n |
| **langgraph** | LangGraph 1.x — state graphs, reducers, checkpointing, HITL |
| **clean-code** | Clean-code standards: naming, small functions, honest comments |
| **design-system** | Token-based styling, accessible primitives, Storybook conventions |
| **playwright** | E2E, visual and Storybook test conventions |
| **security** | OWASP checklist, secret scanning, SAST, SSRF/authz checks |
| **docs** | README, ADR, runbooks, API documentation |
| **gitmoji** | Gitmoji + Conventional Commits for commit messages |
| **speckit** | Spec Kit — spec-driven development workflow (`/speckit.*`) |
| **multi-agent-orchestration** | Safe parallel subagents — one writer, fresh review |
| **triage** | Move issues and PRs through triage roles into agent-ready briefs |
| **code-review** | Two-axis review of a diff — Standards and Spec, in parallel sub-agents |
| **implement-spec** | Implement a spec's tickets on one integration branch |
| **to-tickets** | Break a plan or spec into tracer-bullet tickets with blocking edges |
| **wayfinder** | Plan work too big for one session as a map of decision tickets |

**Links**: [`skills/engineering/`](skills/engineering/) · [`skills/engineering/README.md`](skills/engineering/README.md) (upstream sources)

---

### Infra

Host/OS triage, email automation, dependency and file hygiene.

| Skill | Description |
|---|---|
| **dependency-maintenance** | Triage, rebase and merge bot dependency PRs (Dependabot/Renovate) |
| **gmail-operations** | Bulk Gmail API work: census, bulk label/archive |
| **messaging-gateway** | Connect a chat platform to the Hermes gateway end-to-end |
| **parallel-execution-sizing** | Size parallel workers to host capacity |
| **windows-app-triage** | Diagnose a Windows app missing from the apps list |
| **windows-host-triage** | Triage Windows RAM, disk, or app leftovers |

**Links**: [`skills/infra/`](skills/infra/)

---

### Productivity

Skill authoring, thinking tools, and organization.

| Skill | Description |
|---|---|
| **writing-for-agents** | Levers for agent-consumed docs: pointers, hierarchy, pruning |
| **create-skill** | Workflow for creating a skill: capture, scaffold, draft, test |
| **improve-skill** | Audit and refactor an existing skill against the writing levers |
| **pre-mortem** | Assume the project failed; work backwards to the causes |
| **para-method** | Classify notes into the four PARA folders |
| **show-me** | Explain visually: diagrams, call trees, UI flows as HTML |

**Links**: [`skills/productivity/`](skills/productivity/)

---

## 🤖 Agents

Read-only subagent definitions used by extensions for delegated work.

| Agent | Purpose | Used By |
|---|---|---|
| `feature-planner` | Scopes and validates task slices | devloop |
| `task-qa` | Validates planner output | devloop |
| `worker-simple` | Implements simple slices | devloop |
| `worker-complex` | Implements complex slices | devloop |
| `reviewer-simple` | Light code review | devloop |
| `reviewer-complex` | Full code review | devloop |
| `tester-simple` | Light test verification | devloop |
| `tester-complex` | Full test verification | devloop |
| `security-triage` | Security gate triage | devloop |
| `security-reviewer` | Deep security review | devloop |
| `integrator` | Final integration + PR | devloop |
| `retro` | Post-run retrospective | devloop |

**Links**:
- [`agents/`](agents/) — All agent definitions

---

## 🧩 Extensions

pi extensions that register commands, renderers, and lifecycle hooks.

### Devloop

Automated devloop: runs a task/phase/range through a gate-based pipeline using delegated subagents, with stacked-PR chaining and retrospectives.

- ✅ 5 commands: `/devloop`, `/devloop-stop`, `/devloop-cleanup`, `/devloop-retro`, `/devloop-smoke`
- ✅ Gate pipeline: planner → task-qa → code → review → test → security → documentation → integrate
- ✅ Stacked-PR chaining, live TUI widget, per-run retrospectives
- ✅ 195 tests, TypeScript strict

**Links**:
- [`extensions/devloop/README.md`](extensions/devloop/README.md)

---

### Orchestration Advisor

Detects machine capacity and recommends orchestration strategy.

- ✅ Sequential / hybrid / parallel recommendation
- ✅ Integration with devloop orchestration decisions

**Links**:
- [`extensions/orchestration-advisor/`](extensions/orchestration-advisor/)

---

## 🔗 Integration

### Install Skills

Link this repo's skills into Pi's skill directory (`~/.pi/agent/skills`). Entries are
**links** (junction on Windows, symlink elsewhere) — nothing is copied, so `git pull`
keeps them current:

```bash
bash link-skills.sh
```

The destination is **flat** (one entry per skill) even though the repo is categorized,
because that is what the harnesses expect. Override the destination with
`PI_SKILLS_DIR=/path/to/skills bash link-skills.sh`.

### Install Extensions

```bash
# Devloop
ln -s $(pwd)/extensions/devloop ~/.pi/agent/extensions/devloop

# Orchestration Advisor
ln -s $(pwd)/extensions/orchestration-advisor ~/.pi/agent/extensions/orchestration-advisor
```

### Install Agents

```bash
# Link agents to pi's agents directory
ln -s $(pwd)/agents/* ~/.pi/agent/agents/
```

---

## 📋 License

MIT
