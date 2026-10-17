# Scripts, verification, and editing

Read when **creating or changing** a skill's scripts, when **moving** a script, or
when **verifying** a refactor hasn't broken anything. These are authorship rules —
the library inventory and dedup are handled by the `skills-management` skill in the
agent's local store.

## Agent-runnable scripts

- No interactive prompt without a bypass (`--yes` / env): the agent hangs on `read -p`.
- Exit with a non-zero code on failure — a validator that always exits 0 hides the real
  break from whatever called it via cron.
- Build shell commands as an **array**, not an interpolated string: a user's path brings
  spaces and accents that break unquoted expansion.
- When the script gains a flag or changes usage, update the usage lines in `SKILL.md`
  and the pointers in `references/` **in the same pass** — stale usage routes the agent
  to a flag that no longer exists.
- A skill without `scripts/` still needs an executable flow: describe the conversational
  execution (what queries to run, what judgement to apply, what the output looks like) and
  **never** document a phantom command like `./skill` that points at nothing.
- When sibling scripts share the same parser or formatter, extract a shared module in
  **the base skill** (relative import between siblings, so the copies keep working) and
  re-run a real command per consumer, comparing before/after — the count must match the
  authoritative tool exactly.

## Documentation vs implementation

- When the doc describes a flag or subcommand the implementation doesn't have, **trim the
  doc to reality** by default. Implementing the missing surface is a new feature, with its
  own risk (e.g. a reconciliation `--apply` writes to the ledger), and needs separate
  approval. Never leave a documented command that fails.

## Verification (the step usually skipped)

- Verify the **output** against the authoritative source, not just the exit code:
  `exit 0` with zeros or blanks is the most common failure mode (unparsed include,
  inverted signal filter). Confirm a real number against the tool's own report before
  trusting any refactor.
- The same applies to a search with **zero results**: an empty list is not proof of
  absence. Before declaring a file, skill, or symbol unreferenced (or safe to delete),
  re-run the check by a second method — decoded walk, another tool, explicit review —
  and confirm the same zero, because a search that matches nothing silently (wrong scope,
  undecoded encoding, path form the tool rejects) flips the keep recommendation to delete.

## Moving or editing a script

- When moving a script, fix the depth assumptions it carries
  (`Path(__file__).parent*N`, names relative to CWD): they encode the old position and
  resolve to the wrong directory silently after the move. Resolve the project root via
  env-with-CWD-fallback and re-run from the real working directory, confirming identical
  behavior to before.
- Prefer `patch` for small edits to `SKILL.md`: `write_file` refuses the overwrite after
  any paginated read, so every small edit costs a full re-read.
