# Three Phases Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the single `story-qa` skill with `/story` (feature Story → stock development → QA and security started automatically) and `/qa` (rerun), backed by two plugin agents.

**Architecture:** Markdown skills and plugin agent files, no runtime code. `/story` runs phase 1 in the main session, then starts `qa-writer`, waits for the person's approval of the QA Story, then starts `qa-runner` and a security-review subagent in one message. A bash check script (`scripts/check.sh`) pins the package's structure and the rules each file must state; a live run on a sample app proves the flow.

**Tech Stack:** Claude Code plugin format (skills, agents, `.claude-plugin/`), Codex plugin manifest, bash, `claude -p` for smoke runs, `@pazmo/cli` for the security scan.

**Spec:** `docs/superpowers/specs/2026-11-24-three-phase-design.md`

## Global Constraints

- Public repository: no company names, internal task ids, or measurement numbers in any file. `scripts/check.sh` enforces a deny list.
- Version `0.3.0` in `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, `.codex-plugin/plugin.json`.
- Both skills: `disable-model-invocation: true`; they start only from their slash command.
- Production is never a QA target. The agent never merges into the production branch; it merges into the integration branch only when `docs/qa.md` says `Auto-merge: on`; it pushes only for that merge or when `Preview` is on.
- Scanner call, fixed text: `PAZMO_NO_TELEMETRY=1 npx -y @pazmo/cli@0.1.2 scan . --json`. Nothing installs a scanner, or any version of it, found elsewhere.
- QA agents never read source code, tests, the diff, or the branch's commit log.
- Report lines stay Korean, in the order the spec's Report block gives.
- Instruction files are written in English; the person-facing text the agent writes follows the person's language.

## Review Focus

1. The app cannot start locally (missing env, port taken, build error): the runner reports every scenario as not run with the error, and does not grep bundles or read code to stand in. → pinned in Task 4's checks and Task 7's smoke run (broken start command).
2. The working tree is dirty when QA would start: `/story` commits first; `qa-runner` stops with "uncommitted changes" instead of running on a mix. → Task 4 check, Task 3 check.
3. The person corrects the QA Story: `qa-writer` runs again with the person's words, and nothing runs until a new approval. → Task 3 check, Task 7 smoke (one correction reply).
4. The scanner cannot run (no Node 20+, unsupported OS, offline first run): the report says `스캐너 not run: <reason>` and `security-review` still runs. → Task 3 check.
5. `/qa` on a Story whose QA Story is already approved: no new writer run, no new approval, saved scripts reused. → Task 5 check, Task 7 smoke.

---

### Task 1: Spike — plugin agents and built-in skills from a subagent

Throwaway. Settles the one unknown the spec names before anything depends on it.

**Files:**
- Create (outside the repo, in a temp dir): `spike-plugin/.claude-plugin/plugin.json`, `spike-plugin/agents/echo.md`, `spike-plugin/skills/go/SKILL.md`

**Interfaces:**
- Produces: a yes/no for each question below, written into the plan's Task 1 notes before Task 3 starts.

- [ ] **Step 1: Build the spike plugin.** `echo` agent: frontmatter `name: echo`, `description: test agent`, `omitClaudeMd: true`; body: "Reply with ECHO-OK and the first line of the prompt you got." `go` skill: "Start the agent `spike:echo` with the prompt `hello`, then start a fresh general-purpose subagent that runs the built-in `security-review` skill on this repository and returns its first finding or NONE. Print both results."
- [ ] **Step 2: Run it.** In a scratch git repo with one committed file: `claude -p --plugin-dir <spike-plugin> "/spike:go" --output-format stream-json --verbose > spike.jsonl`
- [ ] **Step 3: Read the transcript.** Expected: a `Task`/`Agent` tool_use with `subagent_type` `spike:echo` and a result containing `ECHO-OK`; a subagent transcript line with a `Skill` call for `security-review`. Record: (a) scoped name works, (b) subagent can run a built-in skill, (c) `omitClaudeMd` accepted without error.
- [ ] **Step 4: Decide.** If (a) fails, the skills start `general-purpose` subagents and tell them to read `agents/qa-*.md` from the plugin folder as their instructions; note this in Task 3 and Task 5. If (b) fails, the review subagents follow the old "Other hosts" prompt (read the diff themselves). Nothing to commit.

### Task 2: Check script and package skeleton

**Files:**
- Create: `scripts/check.sh`
- Modify: `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, `.codex-plugin/plugin.json`
- Move: `skills/story-qa/references/risks.md` → `skills/story/references/risks.md`; `skills/story-qa/assets/{QA-ENV.md,qa-check.sh,qa-dev.yml,qa-dev-triage.yml}` → `skills/qa/assets/`
- Delete: the rest of `skills/story-qa/`

**Interfaces:**
- Produces: `scripts/check.sh` with helpers `need_file <path>`, `need_text <path> <fixed string>`, `forbid_text <path-or-dir> <regex>`, `frontmatter <path> <key>` (prints the value). Exit 0 when every check passes, 1 otherwise, printing one `FAIL: ...` line per failure and `OK n checks` at the end. Later tasks append their checks to this file.

- [ ] **Step 1: Write `scripts/check.sh` with the skeleton checks.** Checks: the three manifests parse as JSON (`python3 -m json.tool`) and carry `"version": "0.3.0"`; `skills/story-qa` does not exist; `skills/story/references/risks.md` and the four `skills/qa/assets/` files exist; no file from `git ls-files --cached --others --exclude-standard` matches a line of `.deny-list` (case-insensitive) or the pattern `[0-9]+(\.[0-9]+)?x (slower|faster|longer)`. `.deny-list` holds the internal names, one per line; it is added to `.gitignore` and written by the person running the plan, so the names never enter the repository. When `.deny-list` is missing the script prints `WARN: no .deny-list` and still runs the other checks.
- [ ] **Step 2: Run it.** `bash scripts/check.sh` → expected: FAIL lines for version and missing paths.
- [ ] **Step 3: Move files and bump versions.** Add `.deny-list` to `.gitignore`. `git mv` the files above, `git rm -r skills/story-qa`, set `0.3.0` and the description "A feature Story a human approves, stock development, then QA and a security review that start on their own." in the three manifests.
- [ ] **Step 4: Run it.** `bash scripts/check.sh` → `OK`.
- [ ] **Step 5: Commit.** `git commit -m "chore: 0.3.0 skeleton — story and qa skills replace story-qa"`

### Task 3: `/story` skill

**Files:**
- Create: `skills/story/SKILL.md`, `skills/story/assets/STORY.md`
- Modify: `scripts/check.sh`

**Interfaces:**
- Consumes: agent names `pazmo-story-to-dev:qa-writer`, `pazmo-story-to-dev:qa-runner` (Task 4), or the Task 1 fallback.
- Produces: the Story file at `docs/stories/<slug>.md` with headings `Goal`, `Decisions`, `Human decides`, `MUST`, `OUT` and footer `Status: Draft | Approved`; the QA Story path convention `docs/stories/<slug>.qa.md`; the prompt fields passed to the agents: `Story: <path>`, `Repository: <path>`, and on reruns `Scenarios: <Q ids>` or `Correction: <person's words>`.

- [ ] **Step 1: Add checks.** `frontmatter skills/story/SKILL.md name` = `story`; `disable-model-invocation` = `true`; `need_text` in `skills/story/SKILL.md` for each of: `Small change`, `medium --max-findings 5`, `MUST check`, `qa-writer`, `qa-runner`, `security-review`, `PAZMO_NO_TELEMETRY=1 npx -y @pazmo/cli@0.1.2 scan . --json`, `in one message`, `Commit everything`, `start \`qa-writer\` again with the person's words`, `not run`, `Auto-merge: on`, `확인하지 못한 것`, `스캐너`; `skills/story/assets/STORY.md` contains `## Goal`, `## MUST`, `Status: Draft | Approved` and does not contain `## QA`.
- [ ] **Step 2: Run it.** `bash scripts/check.sh` → FAIL lines for the new checks.
- [ ] **Step 3: Write `STORY.md`.** The current template minus the `## QA` section and the QA lines of `Human decides`.
- [ ] **Step 4: Write `SKILL.md`.** Phase 1 steps 1–10, phase 3, the Report block, and the fallback for hosts without plugin agents, as the spec words them. Under 120 lines. Phase 1 steps say nothing about tests, task order or tools.
- [ ] **Step 5: Run it.** `bash scripts/check.sh` → `OK`.
- [ ] **Step 6: Commit.** `git commit -m "feat: /story — feature Story, stock development, QA and security started on their own"`

### Task 4: QA agents and QA templates

**Files:**
- Create: `agents/qa-writer.md`, `agents/qa-runner.md`, `skills/qa/assets/QA-STORY.md`
- Modify: `skills/qa/assets/QA-ENV.md`, `scripts/check.sh`

**Interfaces:**
- Consumes: the prompt fields from Task 3.
- Produces: `qa-writer` returns `QA Story: <path>` and `Gaps: <list or none>`. `qa-runner` returns a table `| 시나리오 | 실행 | 결과 | 근거 |`, `Scripts: <paths written>`, `Not run: <scenario — reason>`. QA Story scenario line format: `- Q<n> [M<n>|Unchanged|not shown] (script|agent|person). <where> · <setup> · <action> → <expected>`.

- [ ] **Step 1: Add checks.** Both agents: frontmatter `name` equals the file stem, `omitClaudeMd: true`, `need_text` `never read source code, tests, the diff`; `qa-writer.md` has `docs/stories/<slug>.qa.md` and no `Bash` in `tools`; `qa-runner.md` has `free port`, `uncommitted changes`, `No substitute checks`, `one at a time`, `stop the process it started`; `QA-STORY.md` has `Target:` and the scenario line format above; `QA-ENV.md` has `Target: local | preview`, `Setup:`, `Preview:`, `Database: in-memory | per-run container | shared`.
- [ ] **Step 2: Run it.** `bash scripts/check.sh` → FAIL lines.
- [ ] **Step 3: Write the two agents and the templates** from the spec's "The QA agents" and "`QA-ENV.md` changes". `qa-writer` tools: `Read, Grep, Glob, Write`. `qa-runner` tools: `Read, Grep, Glob, Write, Edit, Bash` plus the browser tools the host offers (state "use a browser tool when the scenario needs one" rather than naming one).
- [ ] **Step 4: Run it.** `bash scripts/check.sh` → `OK`.
- [ ] **Step 5: Commit.** `git commit -m "feat: qa-writer and qa-runner agents, QA Story template"`

### Task 5: `/qa` skill

**Files:**
- Create: `skills/qa/SKILL.md`
- Modify: `scripts/check.sh`

**Interfaces:**
- Consumes: Task 4's agents and return formats; Task 3's Report block (reuse the `QA` and `확인하지 못한 것` lines).

- [ ] **Step 1: Add checks.** `frontmatter name` = `qa`, `disable-model-invocation` = `true`, `argument-hint` contains `[local|preview|dev]`; `need_text`: `Status: Approved`, `skips \`qa-writer\``, `reuses the saved scripts`, `never read source code`.
- [ ] **Step 2: Run it** → FAIL.
- [ ] **Step 3: Write `SKILL.md`** from the spec's `/qa` section, including the no-plugin-agent path where `/qa` does the writer and runner work itself under the same reading rules. Under 60 lines.
- [ ] **Step 4: Run it** → `OK`.
- [ ] **Step 5: Commit.** `git commit -m "feat: /qa — rerun QA or run it on another target"`

### Task 6: README

**Files:**
- Modify: `README.md`, `scripts/check.sh`

- [ ] **Step 1: Add checks.** README contains `/story`, `/qa`, `@pazmo/cli`, `PAZMO_NO_TELEMETRY`, `PolyForm Shield`, `security-guidance`, `0.3.0`; does not contain `/story-qa` except in the line that says the command changed.
- [ ] **Step 2: Run it** → FAIL.
- [ ] **Step 3: Rewrite README** (Korean, current tone): the three phases with the two ★ approvals; when to use; the security scanner (what it covers: npm dependencies only for known vulnerabilities, macOS arm64 and Linux x64, license, telemetry off); the optional `security-guidance` pattern warnings and that its model-based layers overlap with phase 3; the file table; install; "0.3.0에서 `/story-qa`가 `/story`와 `/qa`로 바뀌었어요".
- [ ] **Step 4: Run it** → `OK`.
- [ ] **Step 5: Commit.** `git commit -m "docs: README for the three phases"`

### Task 7: Smoke run on a sample app

**Files:**
- None in the repo. A sample app outside it: a small Node server with two brand copies of one page, `npm start` on `$PORT` printing `listening on <port>`, `npm test`, a git repo with one commit.

- [ ] **Step 1: Happy path.** `claude -p --plugin-dir <repo> "/pazmo-story-to-dev:story <a two-copy change request>"` with `--output-format stream-json`, then `--resume` replies: "승인", then after the QA Story "Q2 기대 결과를 <x>로 바꿔 줘", then "승인". Expected in the transcripts: a Story file; no code edit before the first approval; a review subagent; `qa-writer` started twice (second with `Correction:`); `qa-runner` and the security subagent started in the same assistant message; `qa/<slug>.sh` committed; the report has every line of the Report block and a `스캐너` result.
- [ ] **Step 2: Broken start.** Same app with `npm start` failing; run through to QA. Expected: every scenario `not run` with the start error; no `grep` of build output, no source reads by `qa-runner` (check its tool calls).
- [ ] **Step 3: Rerun.** `/pazmo-story-to-dev:qa docs/stories/<slug>.qa.md` on the happy-path app. Expected: no `qa-writer` call, no approval question, the saved script runs.
- [ ] **Step 4: Fix what failed** in the skill or agent files, rerun the failing step once, `bash scripts/check.sh` → `OK`, commit `fix: <what the smoke run showed>`.

### Task 8: Measure against stock (outside this repository)

Local only; numbers never enter this repository.

- [ ] **Step 1:** Vendor the branch head into the local eval harness as a new arm with prompt prefix `/pazmo-story-to-dev:story `, the same six tasks and repetitions as the last round.
- [ ] **Step 2:** Run, grade, report. Compare phase-1 time and cost with stock, and quality with stock and the previous arms. Report to the person before any release.
