---
trigger: model_decision
description: "Load for coding tasks where context efficiency, debugging, refactoring, tests, or code review matter."
---
# Token-efficient coding

- Do not read or summarize the entire repository for a localized task.
- Start with `git status --short`; use focused search (`rg`) to locate entry points and references.
- Read only the relevant source, types, tests, and configuration; expand scope only when dependencies require it.
- Do not paste huge logs. Extract the actionable error, relevant stack trace, and command.
- Avoid repeating the request or producing long plans. Use short findings and a prioritized plan.
- Do not repeatedly retry the same failure without changing the diagnosis.
- Prefer existing dependencies and patterns; justify new dependencies before adding them.
- Use targeted tests/analyzers before full builds.
- After changes, review `git diff --check`, `git diff --stat`, and the actual diff.
- Do not hide errors by swallowing exceptions, disabling lint rules, or weakening tests without justification.
- Report what was actually verified, and explicitly list anything not verified.
