# Project Rules

- Preserve existing behavior, architecture, and user changes unless the task requires a change.
- Before editing, inspect `git status --short`, repository structure, and only files relevant to the task.
- Search for existing implementations before adding abstractions, dependencies, or duplicate code.
- For non-trivial work, give a concise plan before editing; do not dump a long repository summary.
- Make the smallest complete fix for the root cause; avoid unrelated refactors and formatting.
- Prefer focused diagnostics and tests before full builds. Do not repeat unchanged failing commands without a new hypothesis.
- Never invent test results. Clearly distinguish checks that passed, failed, or were not run.
- Never expose secrets or edit `.env` values. Never perform destructive Git actions, migrations, or broad deletions without approval.
- Before finishing, inspect `git diff --check` and `git diff --stat`; review the actual diff.
- Final report: root cause, files changed, checks actually run/results, remaining risks.
