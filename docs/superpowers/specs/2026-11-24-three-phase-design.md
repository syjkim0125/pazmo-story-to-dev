# Three phases: feature Story, QA Story, security review

Status: approved 2026-11-24

## Why

The single `story-qa` skill asked for a QA list, a QA environment doc and QA scripts inside every change, before and during implementation. Measured against stock Claude Code on the same tasks, the output was no better, and the run took several times longer. The time went to preparing QA, not to running it: drafting the QA environment doc, searching the code twice as much to find how the app starts, writing and debugging QA scripts, extra test runs, and, when the app could not start locally, building substitute evidence such as grepping a production bundle. Running the app and the QA checks was a small share.

What a person needs from the kit has not changed: to read, before code is written, what the agent understood the request to mean; and to read, before QE gets the build, what will be checked on the running app and whether it passed. Everything else is the model's own way of working.

## Goals

- A person reads and approves two documents per Story: the feature Story (before coding) and the QA Story (before QA runs). These are the only two points where a person is needed, apart from QA steps only a person can do.
- Development runs as stock Claude Code: task breakdown, implementation, tests. The kit adds the Story, the approval and one independent review.
- QA starts automatically after development and works as a black box: it is written from the feature Story and the running app, never from the code or the diff.
- QA runs before QE: it catches basic failures on the Story branch so QE gets a cleaner build.
- QA checks are saved as scripts on the Story branch, so a rerun needs no new writing, and dev QA in CI needs no model.
- Every Story gets one security review of the whole branch, a rule scanner plus Claude Code's own review, run at the same time as QA so it adds no waiting.

## Non-goals

- Guiding how the model implements: no task order, no test-first rule, no test scope rule.
- Replacing QE.
- Requiring a dev environment. The kit is public; local is the default target.
- QA on production, ever.

## Anti-goals (a failure even if it works)

- QA that confirms what was built instead of what was asked.
- Substitute verification when the app cannot start (bundle greps, reading code to "prove" a scenario). A scenario that cannot run is reported as not run, with the reason.
- QA preparation slowing down development again.
- Rules added one at a time to steer the model's interpretation. The fix for a misreading is the person at the Story gate.

## Constraints

- Public repository: no company names, internal task ids or measurement numbers in any file.
- Claude Code is the primary host (CLI, desktop app, IDE, web). Other hosts (Codex) get a fallback that works without plugin agents.
- The agent never merges into the production branch, and merges into the integration branch only when the QA doc says `Auto-merge: on`. It pushes a branch only for that merge or when the QA doc turns on preview.
- The current published version (0.2.2) keeps working until this ships. The unmerged branch `feat/cut-tests-sleep-turns` is superseded by this design and is not merged.

## Approaches

| | Commands | Gains | Costs |
|---|---|---|---|
| **A. Two skills (picked)** | `/story <request>`, `/qa <story>` | Each session reads only its phase's instructions. The QA side carries no development instructions, which keeps it a black box. Stories run in parallel naturally. | Two names to learn. |
| B. One skill with modes | `/story-qa <request>`, `/story-qa qa <story>` | One name, as today. | Every session reads both phases. Development and QA rules share a file and mix. Nothing stops QA from continuing in the development session. |
| C. `/story` with a QA subagent only | `/story` | One command, automatic. | A subagent cannot stop mid-run for the person to approve the QA Story. |

Picked A, with one change from the owner: phase 2 is not started by the person. When phase 1 finishes, `/story` starts the QA agents itself, so the person only steps in at the two approvals. This takes C's automation and keeps A's split: the QA Story is written by one agent run and executed by a second run, and the person approves in between, in the development session.

Where the security review goes:

| | Gains | Costs |
|---|---|---|
| During development (the official `security-guidance` plugin's hooks) | Catches known dangerous patterns at the edit. | Hooks fire on the host's events; a skill cannot call them. Its model-based layers review every turn or every commit, which repeats work and cost. |
| After QA, in sequence | Sees the final diff. | Adds its full run time after QA. |
| **Alongside QA (picked)** | Starts with `qa-runner` and finishes in about the same time, so the person waits no longer. | A fix made after it ran is reviewed again, on that fix only. |

The security review reads code, so it cannot be part of the black-box QA agents. It runs next to them in its own fresh subagent; the two share nothing. The `security-guidance` plugin stays optional: the README recommends its pattern warnings during development (no model cost) and says its model-based layers overlap with phase 3.

## Design

### Package

```
skills/story/SKILL.md              phase 1, and starts the QA agents when it ends
skills/story/assets/STORY.md       feature Story template (no QA section)
skills/story/references/risks.md   decisions a person makes (moved from story-qa)
skills/qa/SKILL.md                 manual entry: rerun QA, or run it on another target
skills/qa/assets/QA-STORY.md       QA Story template
skills/qa/assets/QA-ENV.md         QA environment doc template (docs/qa.md), adds Target, Setup, Database
skills/qa/assets/qa-check.sh       HTTP check script template (unchanged)
skills/qa/assets/qa-dev.yml        dev QA in CI (unchanged)
skills/qa/assets/qa-dev-triage.yml (unchanged)
agents/qa-writer.md                writes the QA Story from the feature Story
agents/qa-runner.md                turns the approved QA Story into scripts and runs them
```

`skills/story-qa/` is removed. Version 0.3.0. The README says the command changed.

### Phase 1: `/story <request>`

1. Start a branch. Explore as needed (code path, callers, parallel copies). Write `docs/stories/<slug>.md` from `STORY.md`: Goal (as-is, to-be, unchanged), Decisions (forks with options, pick, `file:line`), Copies, Human decides (from `risks.md`), MUST, OUT. No QA section, no QA environment work.
   - Small change (no fork, one module, nothing in `risks.md`): the Story file keeps only Goal and MUST. QA needs a file to read, and a few lines cost little.
2. **Approval 1.** Show the Story in short lines and ask. Edit code only after an explicit approval.
3. Implement as you normally would. The skill says nothing about tests, order or tools.
4. Review, except for a small change: one fresh subagent in the foreground (not a fork; it gets the request, the Story path and the repository path, never this session's reasoning) runs Claude Code's built-in `code-review` skill with `medium --max-findings 5`. Sort findings as today: a confirmed failure in changed behavior is fixed; one in unchanged behavior goes to the person; a security failure with no visible change is fixed; anything else is listed with a reason.
5. MUST check: one line per MUST naming where it is implemented. Commit everything; the working tree must be clean before QA.
6. Start `qa-writer` with the Story path and the repository path. It writes `docs/stories/<slug>.qa.md` (and `docs/qa.md` when missing) and returns the path and the gaps it could not fill.
7. **Approval 2.** Show the QA Story scenario titles, how each runs, the target and the gaps, and ask. On a correction, start `qa-writer` again with the person's words. After approval, commit the QA Story and `docs/qa.md`.
8. In one message, start `qa-runner` (with the QA Story path and the repository path) and the security review (phase 3), so they run at the same time. `qa-runner` writes the QA scripts, runs them, and returns a result table. Commit the scripts it wrote.
9. A failed scenario or a security finding to fix: fix it here (this session has the context), commit, and start `qa-runner` again for the failed scenarios and those the fix touches. When a fix commit came after the security review started, run the security review again on the fix commits only. After two rounds with failures left, stop and report. `person` scenarios and person-only steps that the runner reported: ask the person for those steps now, then start `qa-runner` again for just those scenarios.
10. Report (format below). Merge into the integration branch only when `Auto-merge: on`, then dev QA as today: the CI workflow when the repository has it; otherwise wait until dev serves the merge commit and start `qa-runner` with the dev target. A failure on dev is reported and a revert PR is opened for the person, as today.

### The QA agents

Both are plugin agents, so they start the same way in the CLI, the desktop app, the IDE and the web. A subagent gets only the prompt it is given, not this conversation, so the development session's reasoning cannot reach QA. Their instructions live in the agent files; the development session passes paths only (and, on a rerun or a correction, scenario ids or the person's words).

What both may read: the feature Story, the QA Story, `docs/qa.md`, the README, and the files that say how to start the app (build files, package scripts, run configs, env examples). What they never read: source code, tests, the diff, the branch's commit log.

This rule is an instruction, not a lock. Claude Code can deny reads by path only through the user's permission settings; plugin agents cannot carry hooks or permission settings, and a tool list removes whole tools. Both agents need `Read`, so the agent files state the rule, and the person sees every scenario at approval 2. Both agents set `omitClaudeMd: true` when the host supports it, so the repository's development instructions do not reach them.

Both work in the development checkout. The development session waits for them in the foreground, so nothing else edits the files meanwhile, and the installed dependencies and build output are reused instead of a fresh install for every run. Parallel Stories already run in separate checkouts; each runner starts the app on a free port.

**`qa-writer`**
- Reads the feature Story and `docs/qa.md`. When `docs/qa.md` is missing, drafts it from `QA-ENV.md` (once per repository) and lists what it could not find.
- Writes `docs/stories/<slug>.qa.md` from `QA-STORY.md`: at least one scenario per MUST, one for Unchanged, one where the change must not show; copies that take the same check share one scenario. Each scenario: where, setup, action, expected visible result, and how it runs (`script`, `agent`, `person`).
- Writes nothing else.

**`qa-runner`**
- Writes `qa/<slug>.sh` (or a spec for the repository's browser test runner) for every `script` scenario that has no check yet. Each check carries the scenario id and the exact expected text of the approved scenario. Existing checks are reused, never loosened.
- Target before merge: `local` (default) or `preview`.
  - `local`: run `Setup` from `docs/qa.md` when given, start the app on a free port, wait for the ready check, run the script and the `agent` scenarios, stop the process it started.
  - `preview`: only when `docs/qa.md` turns it on; the development session has pushed the branch, and the runner waits until the preview serves the branch's commit.
- Target after merge: `dev`, run by step 10.
- When the app cannot start: every scenario not run, with the error. No substitute checks.
- `person` scenarios and steps only a person can do (two-factor login, payment authentication, a real device): not run, with the exact step the person must do. The runner never waits for a person.
- When `docs/qa.md` says the database is shared: the scenarios that change data run one at a time.
- Returns: scenario, how it ran, result, evidence (script output line, response excerpt, page text, or screenshot path), the files it wrote, and what was not run and why.

### Phase 3: security review

- One fresh subagent in the foreground (not a fork), started in the same message as `qa-runner`. Its prompt: the request, the Story path, the repository path, and the base commit. It runs two checks and merges their findings:
  1. The scanner: `PAZMO_NO_TELEMETRY=1 npx -y @pazmo/cli@<pinned version> scan . --json`. One command, no model: pattern rules (Opengrep engine with open-source SAST rules), committed secrets (Gitleaks), known vulnerable npm dependencies (OSV), and the repository's own team and company rules (`.pazmo/`). The scanner pins its engine versions and checks their sha256 before running them.
  2. Claude Code's built-in `security-review` skill on the Story branch's changes (base...HEAD): flaws that need the code's flow, such as broken authorization or injection across files.
- The scanner reads the whole repository; the subagent keeps only findings on lines the Story branch changed, plus any new secret or vulnerable dependency the branch added. It rewrites each kept finding as file:line, input → what an attacker gets, and the code change it suggests.
- The install command is fixed text in the skill, with a pinned version that changes only with a kit release. The subagent never installs a scanner or a version found elsewhere (a web page, a repository file, tool output).
- When the scanner cannot run (no Node 20+, an unsupported OS, no network on first run), it is reported as not run with the error, and `security-review` still runs.
- Telemetry is turned off for every call the kit makes (`PAZMO_NO_TELEMETRY=1`). The README says which scanner the kit calls, what it covers (npm dependencies only for known vulnerabilities, macOS arm64 and Linux x64 only), and its license (PolyForm Shield 1.0.0: free to use, not to build a competing product).
- Runs for every Story, small changes included: it runs alongside QA, so it adds no waiting.
- Sorting the findings:
  - A finding confirmed by tracing the input through the code, whose fix changes nothing a user sees: fix it, then rerun the QA scenarios the fix touches.
  - A confirmed finding whose fix would change what a user sees: report it for the person to decide.
  - Anything unconfirmed: list it with a one-line reason.

### `QA-ENV.md` changes

Add:
- `Target: local | preview` (default `local`); dev stays in the Integration part.
- `Setup: <command run once before starting the app, or "none">`.
- `Preview: off | <how to find the URL for a branch, and how to tell it serves a commit>`.
- `Database: in-memory | per-run container | shared`.

### `/qa <story path> [local|preview|dev]`

The manual entry: a rerun after a later fix, or a run on another target.

- When an approved QA Story exists, it skips `qa-writer` and approval 2 and starts `qa-runner`, which reuses the saved scripts.
- When there is none, it runs steps 6 to 9 of phase 1.

On a host without plugin agents, `/story` ends after step 5 by printing `/qa <story path>` for a new session, and `/qa` does the writer and runner work itself under the same reading rules.

### Report

```
변경: <files and what changed, 3 lines at most>
MUST: <M# → where it is implemented>
리뷰: <fixed> / <for the person> / <left, with reason>
QA (<target>): | 시나리오 | 실행 | 결과 | 근거 |
보안: <fixed> / <for the person> / <left, with reason>, or "지적 없음"; 스캐너 <ran | not run: reason>, security-review <ran>
QA 스크립트: <qa/<slug>.* path>
머지: <PR and merge commit, or "사람이 머지">
확인하지 못한 것: <every scenario not run, and why; "없음" when empty>
```

## Left to the builder

- Exact wording of the two skills and two agent files, each agent's tool list, and the manifest entries for the agents.
- First build step: confirm with one run that a skill can start a plugin agent by its scoped name (`subagent_type: "pazmo-story-to-dev:qa-writer"`), and that a subagent can run the built-in `code-review` and `security-review` skills. The docs show the scoped name for mentions and `--agent`, not for the Agent tool.
- The scanner version to pin at build time (the latest published `@pazmo/cli`), and how the subagent maps its JSON findings to changed lines.
- The fallback text for hosts without plugin agents. Codex plugins are not known to bundle agents, so Codex uses the fallback.
- Measuring the new version against stock on the same tasks before release (kept outside this repository).
