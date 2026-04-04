# Postponed Todos

Postponed Todos is a low-pressure todo app for things you are not ready to schedule yet.

## Why it exists
Some tasks are clear enough to matter, but not clear enough to put on today’s calendar.

They sit in notes, get rewritten across apps, or quietly become guilt. Postponed Todos gives those tasks a better place to live: captured now, surfaced later, without pretending everything needs an exact due date.

## Core concepts
- **Postponed tasks**: things you still care about, but do not want to force into an urgent plan yet
- **Low-pressure resurfacing**: the app brings tasks back gently when they may be easier to re-engage with
- **Holding box**: a calmer space for tasks you want to set down for longer without deleting them

## Current status
This repo is the Flutter client for an early product prototype.

Today’s scope is focused on the core loop:
- capture a postponed task
- let it cool down
- surface it again with gentle recommendations
- move it into a holding box when it needs a longer pause
- restore, complete, or drop it later

## What is in the prototype now
- **Home**
  - summary of active / cooling / shelved tasks
  - recommendation cards for tasks that are ready to revisit
  - holding-box revisit suggestions for longer-paused items
- **Quick add**
  - add a task from the shared floating action button
  - optional note at capture time
- **Postponing list**
  - browse tasks that are still in the active postponed state
- **Holding box**
  - review tasks intentionally set aside
  - restore them when they feel relevant again
- **Task detail**
  - inspect note and timing metadata
  - snooze, move to holding box, restore, complete, or drop

## Run locally
```bash
flutter pub get
flutter run
```

## Test
```bash
flutter test
```

Optional checks:
```bash
flutter analyze
```

## Roadmap
- tune resurfacing rules so suggestions feel more helpful and less noisy
- refine copy and interaction details for a calmer emotional tone
- add richer history / explanation around why a task reappeared
- continue validating whether the holding-box flow reduces pressure better than standard snoozing
