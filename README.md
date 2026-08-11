# Postponed Todos

Postponed Todos is a low-pressure todo app for things you still care about, but are not ready to schedule yet.

## Why it exists
Some tasks matter, but not enough to force onto today’s calendar.

They end up scattered across notes, rewritten in different apps, or quietly turning into guilt. Postponed Todos gives them a better place to live: captured now, surfaced later, without pretending everything needs an exact due date.

## Core ideas
- **Postponed tasks** — things you want to keep, but not force into urgency yet
- **Low-pressure resurfacing** — the app brings a few things back gently when they may be easier to re-engage with
- **Holding box** — a calmer shelf for tasks you want to set down for longer without deleting them

## Current prototype
This repo contains the Flutter client for an early product prototype.

Today’s prototype focuses on one loop:
1. capture a task
2. let it cool down
3. revisit it through gentle recommendations
4. move it into a holding box when it needs a longer pause
5. restore, complete, or drop it later

## What you can try
- **Home**
  - gentle recommendation cards
  - holding-box revisit suggestions
- **Quick add**
  - capture a task from the shared floating action button
  - optionally leave a note and edit it later
- **Postponing hub**
  - browse active postponed tasks
  - switch between lightweight filters
- **Holding box**
  - review tasks intentionally set aside
  - restore them when they feel relevant again
- **Task detail**
  - inspect note and timing metadata
  - snooze, move to holding box, restore, complete, or drop

## Quick trial
### Recommended local run
```bash
flutter pub get
flutter run -d macos
```

### Acceptable fallback
If you just want to explore the prototype quickly:
```bash
flutter run -d chrome
```

### Suggested 5-minute walkthrough
1. Add one task with **Quick add**
2. Go back to **Home** and look at the recommendation surface
3. Open **미루는 중** and switch the lightweight filters
4. Open **보류함** to see the calmer holding-box flow
5. Open a task detail screen and inspect the available actions

## Local checks
### Test
```bash
flutter test
```

### Analyze
```bash
flutter analyze
```

## Notes
- The product is intentionally not a heavy productivity dashboard.
- Web is a flow preview only: its in-memory repository intentionally does not persist user data after refresh. Do not use it as a personal-data product.
- Native mobile is the supported local-data experience. Android releases require a private `android/key.properties` based on `android/key.properties.example`; debug signing is never used for release output.

## Roadmap
- keep tuning resurfacing so suggestions feel helpful without becoming noisy
- refine copy and interaction details for an even calmer tone
- add richer explanation/history around why a task resurfaced
- continue validating whether the holding-box flow reduces pressure better than standard snoozing
