---
name: clean-code
description: |
  Write, review and refactor code to clean-code standards: readable, maintainable
  naming, small single-purpose functions, and honest comments. Distinguishes the
  deterministic *formatting* layer (delegated to formatters like Black/ruff) from
  the judgment-based *semantic* layer (naming, cohesion, dead-code removal that an
  LLM/reviewer must judge). Use when writing or reviewing functions, naming
  identifiers, removing redundant comments, or cleaning generated/refactored code.
---

# Clean Code Skill

Apply clean-code standards to code you write, review, or clean. Clean code is the
standard for *creating* readable, maintainable code — distinct from *refactoring*
(changing behavior *without* altering observable results) and from *formatting*
(deterministic style enforced by a formatter).

## The two layers (know which one you are in)

| Layer | Who/what handles it | Boundary |
|---|---|---|
| **Formatting** | A formatter (Black, ruff format, prettier, gofmt, rustfmt) | Deterministic; do NOT do this by hand or with an LLM — it invents style and is non-deterministic |
| **Semantic clean code** | Human/LLM judgment | The real value-add: naming, cohesion, comments, dead code |

**Rule of thumb**: never use an LLM to "format". Formatting belongs to the
project's formatter (run it in CI/editor). Apply judgment only to the semantic
layer.

## Principles

### Meaningful names (highest leverage)
- Name things for **what they are/do**, revealing intent — a reader should not
  need the body to know what a function does.
- Functions: verbs / verb phrases (`fetch_user`, `is_valid`, `compute_total`).
- Use the same vocabulary across related code (don't mix `get`/`fetch`/`load`
  for the same concept).
- Don't fear longer names when they clarify intent; keep names proportionate to
  scope.
- Avoid cryptic abbreviations, single-letter names (except trivial loop/local
  scope), and names that lie or are vague (`data`, `temp`, `stuff`).

### Small functions that do one thing
- A function should do **one** thing at one level of abstraction; extract the
  rest.
- Small + well-named > long + commented. Favor early returns over deep nesting.
- Prefer pure-ish functions (inputs → output, no hidden side effects).
- Keep the call graph shallow; avoid deep dependency chains when factoring.

### Honest comments
- Prefer code that reads clearly over comments that restate the code
  ("// increments i" is noise).
- Keep comments for **why** (intent, non-obvious constraints, trade-offs,
  references), not **what**.
- Remove or rewrite comments that contradict the code (lying comments).

### Duplication & dead code
- Flag duplicated blocks — extract once with a clear name.
- Remove unused imports, unused variables, and unreachable/dead code (many are
  lint-detected: e.g. ruff `F401`/`F841`); the LLM/reviewer catches the
  judgment-based ones.
- Delete commented-out code blocks.

## Language-agnostic
These principles apply across languages. Where a language idiom differs (e.g.
function vs method, naming case), defer to the language's convention — naming
(`camelCase`/`snake_case`/etc.) is set by the project/language, not invented here.

## Review checklist
Use before merging or when cleaning generated code:
- [ ] Ids are descriptive, intent-revealing, and consistent in vocabulary
- [ ] Functions are small and do one thing
- [ ] Comments state *why*, not re-state the code
- [ ] No dead code, unused imports/variables, or commented-out blocks
- [ ] No duplicated structure that should be extracted
- [ ] Formatting is left to the formatter (not hand/LLM-edited)

## Examples

**Before** (semantic problems; formatting is not the issue):
```python
def f(x, y):                       # vague name; one-letter args
    # get the thing and add it applied
    t = 0
    for i in range(len(x)):        # index loop -> harder to read
        t += x[i] * y[i]
    return t
```

**After** (naming + one thing + honest comment):
```python
def dot_product(left: list[float], right: list[float]) -> float:
    """Weighted sum of corresponding elements (only left length used)."""
    return sum(a * b for a, b in zip(left, right))
```

## Project conventions
A repository's own engineering guidelines (a project `AGENTS.md`, an architecture
skill, or a design-system skill) **override** this generic guidance — apply
project-specific naming, structure, and format rules first.