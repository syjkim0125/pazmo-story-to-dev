---
name: qa
description: Use when the developer runs /qa to rerun QA for a Story after a later fix, or to run it on another target (local, preview, dev).
argument-hint: "<docs/stories/<slug>.md or .qa.md> [local|preview|dev]"
disable-model-invocation: true
---

# QA for a Story

QA works from the Story and the running app; you never read source code, tests or the diff for it. Write to the person in their language. Start each agent, then wait for its result; never sleep or poll for it.

The argument names the feature Story or its QA Story (`docs/stories/<slug>.qa.md`), and optionally a target. Without a target, use `Target` from `docs/qa.md` (default `local`).

1. The working tree must be clean. If it is not, tell the person to commit first and stop.
2. When the QA Story exists and says `Status: Approved`, this run skips `qa-writer` and the approval: go to step 4. It reuses the saved scripts.
3. Otherwise start the agent `pazmo-story-to-dev:qa-writer` with `Story: docs/stories/<slug>.md` and `Repository: <repository path>`. Show the person each scenario title with how it runs, the target and the gaps, ask for approval and end your turn. On a correction, start `qa-writer` again with the line `Correction: <their words>`. After approval set `Status: Approved` and commit the QA Story and `docs/qa.md`.
4. Start the agent `pazmo-story-to-dev:qa-runner` with `QA Story: docs/stories/<slug>.qa.md`, `Repository: <repository path>`, and `Target: <target>` when it is not the default. For `preview`, push the branch first. Commit any scripts it wrote.
5. Report the runner's table, then what was not run and why (`없음` when empty). Steps that need a person: ask for them, then start `qa-runner` again with `Scenarios: <ids>`.

Fixing a failure is not part of `/qa`: report it, and the person or the development session fixes it.

## Hosts without plugin agents

When the host cannot start these agents, do their work here under the same rules. Read only the Story, the QA Story, `docs/qa.md`, the README and the files that say how to start the app. Write the QA Story with at least one scenario per MUST, one for Unchanged and one where the change must not show, each marked `script`, `agent` or `person`. After approval, write `qa/<slug>.sh` with one check per `script` scenario carrying its id and exact expected text. Start the app on a free port, run the checks and the `agent` scenarios, and stop the process you started. If the app cannot start, report every scenario as not run, with no substitute checks.
