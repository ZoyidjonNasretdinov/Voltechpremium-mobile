---
trigger: model_decision
description: "Load for TypeScript, Next.js, React, NestJS, API, database, authentication, WebSocket, or frontend/backend integration tasks."
---
# TypeScript / Next.js / NestJS rules

- Follow existing package manager, module boundaries, API contracts, and validation patterns.
- Inspect `package.json` scripts and the lockfile before running commands or adding dependencies.
- Validate untrusted input at API boundaries; keep authorization on the server, not only in the UI.
- Check loading, empty, error, retry, offline, and permission states where relevant.
- For WebSockets, check reconnect/backoff, duplicate subscriptions, cleanup, payload size, auth expiry, and optimistic UI consistency.
- For images/uploads, check file type/size validation, responsive sizing, caching, and graceful failure.
- Run only scripts that actually exist in `package.json`; use the project's package manager.
- Do not report TypeScript, lint, test, or build checks as passing unless they were run successfully.
