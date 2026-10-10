# Focused Audit and Fix

1. Inspect `git status --short`, identify the stack, and locate relevant source, tests, and configuration. Do not edit yet.
2. Reproduce the issue if feasible. Separate confirmed facts from hypotheses and identify the root cause.
3. Present a short plan with files likely to change and the smallest relevant checks.
4. Implement a minimal fix. Preserve unrelated behavior and user changes; avoid new dependencies unless needed.
5. Run the narrowest relevant formatter, analyzer/linter, and tests. Broaden checks only when useful.
6. If a check fails, inspect the actual output and change the diagnosis. After two unsuccessful attempts, stop looping and report evidence plus the next step.
7. Review `git diff --check`, `git diff --stat`, and the full diff for accidental changes, secrets, debug code, mock production data, or weakened tests.
8. Report root cause, changed files, checks actually run and their results, and remaining risks. Never claim unverified success.
