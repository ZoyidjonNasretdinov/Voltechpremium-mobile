---
trigger: model_decision
description: "Load for Flutter or Dart tasks, including UI, routing, state management, maps, GPS, performance, and crashes."
---
# Flutter / Dart rules

- Follow the repository's current state-management, routing, and folder conventions; do not introduce a new architecture casually.
- Check async lifecycle safety: mounted checks where needed, cancellation/disposal of controllers and subscriptions, and correct error states.
- For map/GPS work, check permission denied, permission permanently denied, unavailable location, stale/mock location, route failure, empty results, and widget disposal.
- Avoid unnecessary rebuilds, repeated network requests, duplicate listeners, and large synchronous work on the UI thread.
- Preserve existing API contracts and loading/empty/error states.
- Run `flutter analyze`; run `flutter test` if tests exist and relevant tests are feasible.
- Format only touched Dart files when practical: `dart format <changed-files>`.
- Do not claim runtime/device behavior is verified if only static analysis was run.
