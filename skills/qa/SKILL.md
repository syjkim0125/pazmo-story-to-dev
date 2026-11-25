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
2. When the QA Story exists and says `Status: Approved`, this run skips `qa-writer` and the approval: go to step 3. It reuses the saved scripts.
   When there is none, follow steps 3 to 5 of [../story/SKILL.md](../story/SKILL.md): the QA Story and its approval, QA and the security review at the same time, and fix and rerun. Then report as that skill's Report says.
3. Before starting `qa-runner`, check `docs/qa.md` as step 4 of [../story/SKILL.md](../story/SKILL.md) says; when it cannot start the app, report and stop. Start the agent `pazmo-story-to-dev:qa-runner` with `QA Story: docs/stories/<slug>.qa.md`, `Repository: <repository path>`, and always pass `Target: <target>`. For `preview`, push the branch first, only when `docs/qa.md` turns preview on. Commit any scripts it wrote.
4. Report the runner's table, then what was not run and why (`없음` when empty). Steps that need a person: ask for them, then start `qa-runner` again with `Scenarios: <ids>`.

On a rerun of an approved QA Story, fixing a failure is not part of `/qa`: report it, and the person or the development session fixes it.

## Hosts without plugin agents

When the host cannot start these agents, do their work here under the same rules. Read only the Story, the QA Story, `docs/qa.md`, the README and the files that say how to start the app. Write the QA Story with at least one scenario per MUST, one for Unchanged and one where the change must not show, each marked `script`, `agent` or `person`. After approval, write `qa/<slug>.sh` with one check per `script` scenario carrying its id and exact expected text. Start the app on a free port with the background mode of your shell tool (in Claude Code: Bash with `run_in_background`, stopped with `TaskStop`; never `&` or `nohup`), run the checks and the `agent` scenarios, stop that task and check the port is free. If the app cannot start, report every scenario as not run, with no substitute checks. Then run the security checks of step 4 of [../story/SKILL.md](../story/SKILL.md) yourself, after QA.
