---
name: story-qa
description: Use when a developer asks for a product or code change and wants to confirm the request was understood before it is built and checked on the running app afterwards, or asks for a Story, a QA list, or end-to-end QA of a change.
argument-hint: "[request]"
---

# Story and QA

The human checks two things: that you understood the request, and that the running app does it. Everything between those two checks is your normal way of working.

```
1 STORY + QA LIST  →  human approves  →  2 QA SCRIPT (fails), IMPLEMENT (passes)  →  3 REVIEW (background) ∥ 4 LOCAL QA
  →  5 MERGE TO DEV (only when the QA doc turns it on)  →  6 DEV QA  →  human approves
```

Write to the human in their language.

## 1. Story and QA list (before any code edit)

Start a new branch from the integration branch (or the default branch). Explore the code as much as you need: the code path, callers, tests, parallel copies (sibling folders or files that hold the same feature for another brand, site, platform or locale), and how the app is started.

**Small change.** After exploring, check three things: the request has no fork (the Decisions part would be empty), every file the change edits sits in one module (one directory or package, and only one copy), and it touches nothing in [references/risks.md](references/risks.md). When all three hold, write no Story file: show the human in chat today → after → unchanged, the file you will edit, and 1–3 QA lines with how each runs, then ask for approval and end your turn. After approval, follow steps 2–6 with those lines as the approved QA list (give them to the reviewer in place of the Story path); write `qa/<slug>.sh` only when the QA doc says `Auto-merge: on`, otherwise run the lines directly in step 4. When any of the three does not hold, write the Story.

Write `docs/stories/<slug>.md` from [assets/STORY.md](assets/STORY.md): keep its headings, write the content in the human's language. Its parts:

- **Goal:** As-is, To-be, Unchanged.
- **Decisions:** a fork is a place where the request reads more than one way in this code and the readings show different results to some user: two signals that could mean the request's word, several copies, several screens. Each fork gives the options, your pick and the `file:line` that supports it. Copies: the change covers every copy unless the request or the code names one; a narrower pick is a fork with its reason.
- **Human decides:** a decision listed in [references/risks.md](references/risks.md) (money, migration, auth, external contract, stored data) is never picked by you; list it under Human decides.
- **MUST / OUT:** every sentence of the request maps to a MUST, or to OUT with the reason.
- **QA:** the scenarios you will run on the running app in step 4, written now from the request. At least one per MUST and per copy, one for Unchanged, and at least one where the change must not show. Each scenario: where (URL, screen, command), setup (account, data, flags), action, expected visible result, and how it runs:
  - `script`: the expected result shows in an HTTP response or CLI output, or the repository has a browser test runner (such as Playwright) for a screen.
  - `agent`: it needs a browser and the repository has no browser test runner, or it is about how the screen looks.
  - `person`: it needs two-factor login, payment authentication or a real device.

QA environment: read the repository's QA doc (`docs/qa.md`, or the file `CLAUDE.md`/`AGENTS.md` names). If there is none, draft `docs/qa.md` from [assets/QA-ENV.md](assets/QA-ENV.md) using the README and scripts, and put what a scenario needs but you could not find (login, test accounts, external sandboxes) under Human decides. Dev details belong there only when the QA doc says `Auto-merge: on`. Production is never a QA environment.

When the QA doc says `Auto-merge: on` and the repository has no `.github/workflows/qa-dev.yml`, offer adding it from [assets/qa-dev.yml](assets/qa-dev.yml) as a Human decides item; it runs the QA scripts on dev without a model.

Show the human, one line each: the Story path; today → after → unchanged; each fork with your pick; the copies; each Human decides item; the QA environment; the QA scenario titles with how each runs. Ask for approval and end your turn. Edit code only after an explicit approval. On a correction, update the Story and QA list, show them again and ask again.

## 2. QA script, then implement

Before editing code, turn every `script` scenario into a check that reads its base URL from `BASE_URL`:

- HTTP: copy [assets/qa-check.sh](assets/qa-check.sh) to `qa/<slug>.sh`, one `expect` or `reject` line per scenario.
- Screen: `qa/<slug>.spec.*` for the repository's browser test runner.
- CLI: `qa/<slug>.sh` lines that run the command and `grep` its output.

Each check carries the scenario id and the expected text of the approved QA line. Start the app and run the script: the scenarios the change adds fail, Unchanged passes (RED). A change scenario that passes now does not test the change: fix the check.

Then implement as you normally would, tests included, until the script passes (GREEN). The approved QA list and the expected results in the script are fixed: when the code cannot meet a scenario, stop and tell the human instead of changing the scenario.

## 3. Review

A fresh reader reviews the diff; you do not review your own work. Review only reads, so start it in the background and run step 4 while it works.

Start one background subagent whose prompt is:

- Claude Code: "Read `docs/stories/<slug>.md` for the intended behavior. Run the `code-review` skill with exactly the arguments `<level> --max-findings 5` and return its findings." (It reviews the branch's committed and uncommitted changes.) This is the `code-review` skill built into Claude Code, not the marketplace `code-review` plugin (a separate multi-agent command that comments on a PR). Level: `high` when the Story has a Human decides item from [references/risks.md](references/risks.md), otherwise `medium`. When a MUST touches authentication, payment or secrets, the same subagent also runs the built-in `security-review` skill.
- Other hosts: "Read the request, `docs/stories/<slug>.md` and `git diff <base>...<story branch>`; return at most 5 findings, each as input → wrong result."

When the findings arrive, sort each by what it touches:

- A concrete failure (this input → this wrong result) in behavior the Story changes: fix it.
- A concrete failure in behavior the Story keeps (Unchanged or OUT): report it for the human to decide.
- A security failure (injection, broken auth, exposed secret) whose fix changes nothing a user sees: fix it, wherever it is.
- Anything else: list it with a one-line reason for leaving it.

After a fix from review, rerun the QA script and only the `agent` scenarios that exercise the code the fix changed.

## 4. Local QA

Start the app locally as the QA doc says. Run the QA script against it (`BASE_URL=<local base URL> bash qa/<slug>.sh`, or the runner command); its output is the evidence for the `script` scenarios. Run the `agent` scenarios through the real interface, with the first tool that can show the expected result:

| The expected result is | Tool | Evidence |
|---|---|---|
| in the HTML or API response | HTTP client (`curl`) | the matching response excerpt |
| only after JS runs, or after a click or input | browser tool | page text (accessibility snapshot or `innerText`) |
| how the screen looks (layout, color, image) | browser tool | screenshot |
| CLI output | the command | output excerpt |

A step that needs a person (two-factor login, payment authentication, a real device): ask the human for that step only, then continue. A failing scenario: fix, then rerun the QA script, that scenario, and the `agent` scenarios that exercise the code the fix changed; leave other passed `agent` scenarios as they are. Stop the app when done.

## 5. Merge to the integration branch

Only when the QA doc says `Auto-merge: on`, and only after every local scenario passed and no review finding with a concrete failure is open:

1. Commit (the QA script included), push the branch, and open a PR into the QA doc's integration branch (for example `dev`). The PR body is the Story path plus the local QA table.
2. Merge it when the repository's CI passes. CI fails: fix and push again; still failing after two attempts: stop and report.

Otherwise (`Auto-merge: off` or missing): stop after local QA and report. The branch stays as the repository's commit rules say, and the human merges.

Never merge into the production branch (`main`, `master`, or what the QA doc names).

## 6. Dev QA

The `script` scenarios on dev:

- The repository has `.github/workflows/qa-dev.yml`: it waits until dev runs the merged commit and runs the script there. Read its result (`gh run list --workflow qa-dev.yml --commit <merge commit>`, then `gh run watch <id>`) instead of running the script yourself.
- Otherwise: wait until dev runs the merged commit (the QA doc says how to check, for example a version endpoint showing the commit), then run `BASE_URL=<dev base URL> bash qa/<slug>.sh`.

Run the `agent` and `person` scenarios on dev as in step 4. A scenario that passed locally and fails on dev: do not fix on the integration branch; report it with the evidence, and open a revert PR for the human to merge or close (the workflow opens one itself).

## Report

Show the human, in this order, then ask for approval:

```
변경: <files and what changed, 3 lines at most>
QA: | 시나리오 | 실행 (script/agent/person) | 로컬 | dev | 근거 (script output line, response excerpt, page text, or screenshot path) |
QA 스크립트: <qa/<slug>.* path, RED → GREEN result>
머지: <PR link and merge commit, or "사람이 머지">
리뷰: <findings fixed> / <findings for the human to decide> / <findings left, with reason>
테스트: <passed>/<total>, <command>
확인하지 못한 것: <every scenario or part not run, and why>
```

A run that stopped after local QA writes `-` in the dev column. Keep `확인하지 못한 것` even when it is empty: write `없음`.
