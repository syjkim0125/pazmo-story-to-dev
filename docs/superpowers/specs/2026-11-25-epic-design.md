# Epic: plan once, build alone, review once

Status: approved 2026-11-25

Research behind this draft: [docs/research/2026-11-25-epic-planning.md](../../research/2026-11-25-epic-planning.md). Section numbers below (R3.1, R4c) point into it. Each design rule is marked **evidence** (a finding supports it) or **choice** (no direct evidence; the reason is given).

## Why

The kit's direction changed. A person now plans at the level of what to build and why, for a whole Epic. The AI decides every detail: implementation, how to split the Epic into tasks, and the build. QA and the security review run on their own. The person checks the result once, when the Epic is done.

Two things the kit has measured shape the design. On current models a plain agent session already matches kit-driven code quality, so the kit has to earn its place through direction and product quality. And the one failure measured so far was a Story, written by the AI, that picked a narrower reading than the person wanted; the build was then narrow too.

With a person present only at the start and the end, three things carry the weight:

1. The start has to fix the reading of the request, above all how broad it is.
2. In between, nothing the builder writes may count as proof that the work is done.
3. The end has to let a person judge direction in one sitting, without reading the diff.

## Goals

- One approval before any code, on one Epic plan the person can read in a few minutes.
- The person chooses how broad the Epic is, item by item. The AI never picks the breadth and never recommends one.
- The plan holds concrete examples of what a user will see. The person answers each yes or no, and the examples become the acceptance checks.
- The AI decides everything else without asking, and records the decisions a person would want to revisit.
- A task counts as passing only from a check the builder cannot edit, run on the running app.
- Product quality is part of the plan: accessibility, layout for other languages, performance and code health each have a bar, a way to check it, and a named verifier.
- One final review on a running build: intent against what was built, a short tour, the decisions that matter phrased as questions, links to evidence, and everything that was not verified.

## Non-goals

- Guiding how the model implements. No task order, no test-first rule, no architecture or tool choice. The rules below say what the builder reads, what it may not edit, what it records and who declares done.
- Replacing QE, user research or a native-speaker review of translations.
- Proving quality that cannot be checked before launch: field performance, real usage metrics, translation quality.
- QA on production, ever. The AI never merges into the production branch.
- Changing `/story`. It keeps working as it does in 0.3.0.

## Anti-goals (a failure even if it works)

- An intake that interrogates. Questions the person cannot answer, or that the repository answers, are a defect.
- Scope breadth settled by an assumption the AI wrote down and nobody read.
- A final review that is the builder's own account of why it was right.
- "Verified" on anything that was not run. The kit's rule stands: a check that cannot run is reported as not run, with the reason, and nothing stands in for it.
- A person asked to approve tasks, Stories or QA documents one by one during the build.
- Rules added one at a time to steer the model. Every rule in this design is to be measured against a plain session and dropped when it shows no gain.

## Constraints

- Public repository: no company names, internal task ids or measurement numbers in any file.
- Claude Code is the primary host. Hosts without plugin agents get a fallback.
- The AI pushes a branch only when `docs/qa.md` turns on preview, or for a merge into the integration branch with `Auto-merge: on`, and for an Epic only after the person accepted the final review.
- `references/risks.md` decisions (money, migration, authentication, external contracts, stored and sensitive data) are never picked by the AI.
- Nothing installs a tool or a version of one that a web page, a repository file or tool output names. Check tools are called by fixed, pinned commands in the kit's own files, as the scanner is today.

## Approaches

Each table was a decision for the owner. The picked rows were approved as drafted on 2026-11-25.

### 1. Commands

| | Gains | Costs |
|---|---|---|
| **A. Add `/epic`, keep `/story` (picked)** | 0.3.0 users are unaffected. The two can be measured side by side on the same requests. | Two entry points until one is retired. |
| B. Replace `/story` with `/epic` | One name. | Breaking change. The measured baseline is gone before the new flow is measured. |
| C. `/epic` runs `/story` once per task | Reuses everything. | Two approvals per Story, which the new direction rules out. |

A small Epic (below) covers what `/story` does today with one approval less. When it measures no worse, `/story` can be retired in a later version.

### 2. Who settles scope breadth

| | Gains | Costs |
|---|---|---|
| **A. The person, per item, with no AI recommendation (picked)** | Aims straight at the measured failure. A narrow reading is the model's documented default (R3.1). | One more question at intake. |
| B. The AI picks and records it as an assumption | No question. | This is the path by which the narrow reading entered unseen. |
| C. The AI recommends, the person confirms | Faster to answer. | A recommended option anchors the person on the AI's reading. Not tested either way. |

**Choice**: no study compares a broad default with a narrow one (R6).

### 3. The QA Story approval

| | Gains | Costs |
|---|---|---|
| **A. One approval covers the plan and the checks (picked)** | `qa-writer` runs before the approval, so the person sees the scenario titles and the gaps in the same message as the plan. No second wait. | A correction to the plan runs the writer again. |
| B. Keep a separate approval after the build | As today. | A second person step in the middle, which the new direction rules out. |
| C. No person sees the scenarios | Fastest. | Loses the kit's guard that QA checks what was asked. |

**Evidence** in part: people judge intent well from concrete checks (R3.1, TiCoder). That one approval can replace two is a **choice**.

### 4. How the build runs

| | Gains | Costs |
|---|---|---|
| A. One session builds everything, state in files | Closest to stock. Cheapest. | Long runs showed overreach, early "done" and drift in vendor reports (R3.2). |
| **B. The main session hands one task at a time to a fresh builder subagent (picked)** | Each task starts from the plan, not from a long history. The main session stays small enough to hold the whole Epic. The lock check runs between tasks. | Each builder explores the repository again. Context shared between tasks has to travel through files. |
| C. Several builders in parallel | Wall-clock time. | Parallel peers collapsed throughput in one vendor report and make conflicting implicit decisions (R3.2). |

**Evidence** in part: the practice in B is convergent vendor reporting with no ablation (R3.2). It is also the rule closest to the kit's non-goal. The release measurement compares A, B and a plain session; B is dropped if it shows no gain.

### 5. When acceptance checks run

| | Gains | Costs |
|---|---|---|
| A. Once, at the end | Cheapest. | A wrong direction is found after everything is built on it. |
| **B. When the tasks that serve an example are all built, and all of them again at the end (picked)** | "Passing" always comes from the runner. Problems surface while the builder's work is recent. Scripts are written once and reruns are cheap. | The app is started several times. |
| C. After every task | Earliest signal. | Most tasks finish no example on their own; many runs would check nothing. |

**Choice**, shaped by the kit's own result that the cost of QA was in preparing it, not in running it.

### 6. Where the person does the final review

| | Gains | Costs |
|---|---|---|
| **A. What `docs/qa.md` says: preview URL when preview is on, else the main session starts the app locally and gives the address (picked)** | Works with no extra setup. | Local review needs the person at that machine. |
| B. Always merge into the integration branch first and review there | A shared URL. | Unreviewed work lands on a shared branch. Unreviewed merges go with more maintenance burden (R3.4). |

### 7. Which quality checks run

| | Gains | Costs |
|---|---|---|
| **A. The plan's quality bars decide. The AI proposes defaults by kind of Epic; the person only changes them (picked)** | No question for the person. An API-only Epic gets no accessibility run. | A default the person did not look at can be too low or too high. |
| B. Every check on every Epic | Uniform. | Runs that check nothing, and "not run" noise. |
| C. Only checks the person asks for | Cheapest. | Quality bars are exactly what a "what and why" request leaves out. |

## Design

### Package

```
skills/epic/SKILL.md               /epic: intake, plan, build loop, Epic-end checks, final review
skills/epic/assets/EPIC.md         Epic plan template
skills/epic/assets/REVIEW.md       final review template
skills/epic/references/intake.md   the questions, when each is asked, the stop rule
skills/epic/references/quality.md  quality checks: how each runs, its threshold, who verifies
skills/story/references/risks.md   unchanged; /epic links to it
agents/qa-writer.md                also accepts `Epic: <path>`
agents/qa-runner.md                also runs the black-box quality checks
skills/qa/SKILL.md                 also accepts an Epic path
scripts/check.sh                   checks for the new files and rules
README.md                          /epic, and when to use it instead of /story
```

Version 0.4.0. `/story` and its files are untouched.

### Files of one Epic

```
docs/epics/<slug>/EPIC.md        the approved plan; the builder never edits it
docs/epics/<slug>/EPIC.qa.md     the QA Story, written by qa-writer from the plan
docs/epics/<slug>/tasks.json     the AI's own split of the work, with status per task
docs/epics/<slug>/decisions.md   decisions the AI made, each "proposed" until the final review
docs/epics/<slug>/REVIEW.md      the final review
qa/<slug>.sh (or .spec.*)        QA scripts, written only by qa-runner
```

### Phase 1: intake

Before asking anything, the main session reads the request and the repository, then drafts:

- a one-paragraph restatement: who has what problem today, and what is different for them afterwards;
- two or three readings of the request, from the smallest that fits the words to the fullest a reasonable person could mean, each as a list of things a user would see;
- where the readings differ in something a user would see, and where the request contradicts itself;
- the `risks.md` lenses that match;
- what `docs/qa.md` lacks to start the app and log in.

Questions, one at a time, with options where possible:

| # | Question | Asked when |
|---|---|---|
| 1 | Is this restatement right? | Always |
| 2 | The smallest version is A. A fuller one also has B, C, D. Which are in? Answered per item. | Always |
| 3 | Here is what a user will see: five to nine examples, at least two at the edge of scope and one that must not happen. Yes, no, or change it? | Always |
| 4 | These are out of scope. Is anything you expect in neither list? | Always |
| 5 | Each matching `risks.md` decision | A lens matches |
| 6 | Who uses this, and is there a group that must not be excluded (age, assistive technology, language, region)? | The Epic has a user interface and the repository does not say |
| 7 | After launch, what would tell you this worked, and what must not get worse? | Once; with no answer, the AI proposes one for a yes or no |
| 8 | Can this reach everyone at once, or must it be possible to turn it off? | It changes a flow existing users rely on, or a lens matched |
| 9 | The request says X and also Y. Which holds? | A contradiction was found |
| 10 | What `docs/qa.md` lacks to start the app or log in | Those fields are missing |

Rules:

- Question 2 shows both readings as lists of user-visible items. No item is marked as recommended or default. An item nobody answered stays open; the AI never moves it to out of scope. (**Choice**, approach 2.)
- An example has the form `where · action → visible result`. (**Evidence**: R3.1, examples a person answers yes or no.)
- Questions 5 to 10 are asked only on their trigger. (**Evidence**: asking by default has a measured cost, R3.1.)
- Never ask the person about language, framework, libraries, architecture, data model, file layout, task split or order, test strategy, naming, which check tool, or anything the repository answers. A choice that looks technical but falls under `risks.md`, such as which payment provider, is the person's. (**Evidence**: questions the user cannot answer are wasted, R3.1.)
- Stop asking when every sentence of the request maps to an example, to out of scope with a reason, or to a Human decides item; the readings no longer differ in anything a user would see; and every matched risk item is answered or recorded as open with the tasks it blocks.
- Budget: five questions beyond the first four, not counting risk items. Past it the AI picks and lists the pick for the final review. Scope breadth and risk items are never picked this way. (**Choice**: no study gives the value of one more question.)
- More than nine examples means the Epic is too large for one review. Propose a split into Epics and let the person pick the first. (**Choice**.)

### Phase 2: the plan and the one approval

1. Start a branch. Write `docs/epics/<slug>/EPIC.md` from the template: Why, Users, What the person will see (E1…), Scope (smallest reading, fullest reading, what the person chose, out of scope, unchanged), Human decides, Quality bars, Success after launch, Operability, Done when. Content in the person's language.
2. Quality bars: the AI fills defaults by the kind of Epic (see Quality checks). Each row has the bar, the check and who verifies: script, agent, person at the final review, or after launch only.
3. Start `qa-writer` with `Epic: docs/epics/<slug>/EPIC.md` and the repository path. It writes `EPIC.qa.md`: at least one scenario per example, one per Unchanged item, one per quality bar that a script or agent verifies, and nothing else. It returns gaps.
4. **Approval.** Show, one line each: the plan path; today → after; what is in and what is out; each example; each Human decides item; the quality bars that differ from the defaults; the scenario titles with how each runs; the gaps. Ask once. On a correction, update the plan, start the writer again with the person's words, show it again.
5. After approval: `Status: Approved` on the plan and on the QA Story, commit both. The build starts from these files, not from the conversation. (**Evidence**: instructions spread over turns degrade results, R3.1.)

A small Epic (one reading, no user interface, no risk lens, at most three examples) keeps only Why, What the person will see, Scope and Done when, and is built in the main session without builder subagents. Everything else applies.

### Phase 3: the build loop

The main session coordinates and writes no feature code itself, except for a small Epic.

1. **Split.** Write `tasks.json`: for each task an id, a title, the examples or quality bars it serves, and a status (`todo`, `built`, `passed`, `failed`, `parked`). The split and the order are the AI's own. A task that serves nothing in the plan is added scope: it is recorded in `decisions.md` and shown under "added" at the final review.
2. **Build one task.** Start one new general-purpose subagent (not a fork) with the plan path, `decisions.md`, `tasks.json`, the task id and the repository path. Its instructions:
   - Read the plan and `decisions.md` first.
   - Implement this task as you normally would. Commit.
   - Never edit the plan, the QA Story or anything under `qa/`.
   - Append to `decisions.md` each decision that changes what a user sees, what is stored, or what is hard to reverse. Routine choices are not logged.
   - When the task needs a `risks.md` decision the plan does not answer, a change to scope, a one-way step the plan does not cover, or when a check looks wrong: do not pick. Return it as a flag.
   - Return the commit, the decisions added, the flags, and what you could not do.
3. **Lock check.** After each builder returns, the main session compares the commits it made against the plan, the QA Story and `qa/`. Any change there is reverted and recorded for the final review. (**Evidence**: read-only tests blocked test edits; LLM monitors alone caught only part of the cheating, R3.2. An instruction is not a lock, as the current spec already says.)
4. **Acceptance.** When every task serving an example is `built`, start `qa-runner` with `Scenarios:` for that example. Commit the scripts it wrote. Pass: those tasks become `passed`. Fail: a new builder gets the runner's evidence and fixes the app; after two rounds the example is marked failed, the loop goes on, and the failure is reported. Only the runner's result changes a task to `passed`. (**Evidence**: features were marked passing without end-to-end verification; an agent's own "done" is not reliable, R3.2.)
5. **Flags.** A flagged decision parks the tasks that depend on it and the loop continues with the rest. When everything left is parked, stop and ask the person; this is the only contact in the middle. Otherwise flags are answered at the final review. (**Evidence**: a sanctioned way to stop and hand over cut cheating sharply on realistic tasks, R3.2. Parking instead of stopping is a **choice**.)

Decision entry in `decisions.md`:

```markdown
D7. <the decision in one line>                               Status: proposed
- Chosen: <option>
- Instead of: <option b>; <option c>
- Because: <one line tied to the plan: Why, an E#, or a quality bar>
- You would notice it is wrong if: <something the person can see on the running app>
- To reverse: cheap | costly | one-way
- Kept true by: <test or check name | nothing>
```

Entries stay `proposed` until the final review. (**Evidence** in part: most decision records in open-source repositories were created as accepted, which records no deliberation, R3.4. Explanations raise acceptance whether or not they are right, and help only when they make checking cheap, R3.5; hence "you would notice" in place of a justification.)

### Phase 4: Epic-end checks

When no task is `todo`, start these in one message:

- `qa-runner` on every scenario, including the black-box quality checks;
- the security subagent as today (scanner and `security-review` on base...HEAD), which also runs the code-reading quality checks;
- one new subagent running the built-in `code-review` skill on the whole branch.

Findings are sorted as `/story` sorts them today. Fixes go to a builder, then the scenarios the fix touches run again. After two rounds with failures left, stop fixing and report them.

### Quality checks

Defaults by kind of Epic. The plan can raise, lower or remove any of them. A check that cannot run is "not run", with the reason.

| Check | Runs for | How | Bar | Verifier |
|---|---|---|---|---|
| Acceptance examples | every Epic | `qa-runner` scripts and agent scenarios | every E# passes | script, agent |
| Accessibility rule scan | Epics with a web interface | axe-core on each route and key state the examples reach (dialog open, form error, empty) | 0 violations at WCAG 2.2 A and AA | script |
| Keyboard and focus walk | Epics with a web interface | the runner tabs through the core flow in a browser | every control reachable; focus visible and not fully hidden; Escape closes overlays and focus returns | agent, with screenshots |
| Narrow screen and large text | Epics with a web interface | browser at 320 px width and at 200% text | no horizontal scroll; no clipped text | script |
| Empty, loading and error states | Epics with data views | the runner forces each state | each data view shows all of them; an error says how to fix and keeps the input | agent |
| Performance, lab | only when the plan sets a budget | Lighthouse, mobile profile, median of 5 runs | LCP ≤ 2.5 s, CLS ≤ 0.1, and the plan's blocking-time and size budgets | script |
| Layout for other languages | only when the plan lists locales, or the repository already translates | search for hard-coded text in new code; a pseudo-locale run | none; no overflow | script (code-reading side) and agent |
| Code health | every Epic | the repository's own linter and static analysis, compared with the base branch | no new warnings | script (code-reading side) |
| Planned events | only when the plan lists events | the acceptance run asserts each fires | every listed event seen | script |
| Screen reader on the core flow | Epics with a web interface | a person, at the final review | the person can complete it | person |
| Field performance, translation quality, the success metric | — | real users | — | after launch only |

Why these lines are drawn where they are:

- A rule scan is a floor. In the one large dataset, a vendor's own, automation found a little over half of accessibility issues by volume and touched under a third of the criteria; keyboard and focus problems were found by hand (R3.3). So the walk is separate, and its result is evidence for the person, not a gate proven reliable.
- Lab numbers are not field numbers, and interaction latency cannot be measured without real input (R3.3). Field performance is listed as after launch, never as verified.
- An LLM usability review is left out of this version. The two studies of it disagree by a wide margin (R3.3). It may come back later as an advisory list, never as a gate.
- Black-box checks belong to `qa-runner`. Checks that read code belong to the security subagent, so the QA agents still never read source.

### Phase 5: the final review

The main session writes `docs/epics/<slug>/REVIEW.md` from the runner's and reviewers' returns, makes the build reachable (approach 6), and shows this. It should take about half an hour.

```
Epic: <title>                              열어 보기: <URL, or how to start it> (<access>)
1 의도        왜: <plan의 Why 그대로>   결과: <plan의 Outcome 그대로>
  만든 것     E1 됨 · E2 됨 · E3 일부: <빠진 것> · E4 안 됨: <이유>
  더한 것     <계획에 없는데 만든 것, 없으면 "없음">      뺀 것: <범위인데 안 만든 것, 없으면 "없음">
2 해 보기     1. <하기> → <보여야 하는 것> [ ]   2. …   그다음: 사용자라면 처음 할 일을 직접 해 보세요.
3 결정        D7. <X>로 정함 (<Y> 대신). 틀렸다면 <Z>가 보임. 확인: 해 보기 3번.   유지 / 바꾸기
4 근거        QA <표와 스크립트 경로> · 접근성 위반 <n> (기준 0) · 성능 <값> (기준 <값>) · 보안 <결과> · 리뷰 <결과>
5 사람이 정할 것   <빌드 중 멈춘 결정과 그 때문에 못 만든 것, 없으면 "없음">
6 확인하지 못한 것  <안 돌린 검사와 이유 · 사람만 할 수 있는 단계 · 출시 뒤에만 알 수 있는 것 · 질문 예산을 넘겨 AI가 고른 것>
7 판단        수락 / 고쳐서 수락: <…> / 방향이 다름: <E# 또는 범위 항목>
```

Rules:

- Section 1 quotes the plan word for word, then states built, partly or not per example. "Added" and "dropped" are always present. (**Evidence**: reviewers ask about intent less when an agent wrote the change, and agent changes bundle several objectives more often, R3.5.)
- Section 2 has one step per example, each a thing to do and a thing to see, then one open prompt. The person acts on the running build. (**Evidence** in part: checking has to be cheap for a person not to over-trust, R3.5. No study compares review formats.)
- Section 3 lists at most seven decisions, ordered by cost to reverse and then by effect on users, each as a question with where to check it. The rest are linked. (**Choice** on the count and order.)
- Section 4 is links and numbers from the runners, next to their bars. The main session does not summarize them in its own words.
- Sections 5 and 6 are kept even when empty: `없음`.
- The person's call: **accept** turns the decisions to `accepted` and the plan to `Status: Accepted`. **Accept with changes** turns each change into tasks; they run through phase 3, the scenarios they touch run again, and only the changes are shown again. **Wrong direction** goes back to intake with the named example or scope item; the plan is corrected and approved again before any more code.
- Merge only after acceptance. With `Auto-merge: on`, open a PR into the integration branch and merge when CI passes, then dev QA as today. Never the production branch.

### `qa-writer` and `qa-runner` changes

- `qa-writer` accepts `Epic: <path>` in place of `Story: <path>` and writes `docs/epics/<slug>/EPIC.qa.md`. Scenario tags name the example (`[E1]`), `[Unchanged]`, or the quality bar (`[a11y-scan]`, `[keyboard]`). It adds no scenario that maps to none of these.
- `qa-runner` gains the black-box quality checks. Tools are called by fixed, pinned commands written in the agent file; when the repository already has a browser test runner with the same check, that is used. A tool that cannot run (no browser, no network on first use) makes that check "not run".
- Both keep their reading rule: the plan, the QA Story, `docs/qa.md`, the README, run files, seed data. Never source, tests, the diff or the commit log.

### `/qa <epic path> [local|preview|dev]`

As today for a Story: with an approved QA Story it reruns the saved scripts on the target.

### Hosts without plugin agents

`/epic` runs intake and the plan, builds in the main session, and ends by telling the person to run `/qa docs/epics/<slug>/EPIC.md` in a new session. The final review is written after that run. The security checks and the code-reading quality checks are run by the person, as today.

## What this draft leaves out of the research proposals, and why

- **Advisory LLM usability review and persona walkthrough** (R4d): conflicting or missing evidence; cost with no gate value. Later, if wanted.
- **Names, personal fields, dates and plural checks** (R4d): too dependent on the stack for a first version. They can be added as plan-specific examples.
- **Server latency under load**: needs seeded data and a load tool per repository. A plan can state it as an example a person checks.
- **Reliability target and error budget in the plan** (R4b): kept as one optional line under Operability; no outcome evidence, and it means little before there are users.
- **A fresh-context check of every task against the plan** (R4c): the runner per example and the review at the end cover it at lower cost. To revisit if the measurement shows drift between tasks.

## Left to the builder

- The exact wording of `skills/epic/SKILL.md`, the two templates and the two reference files.
- First build step: confirm with one run that the main session can start builder subagents one after another across a long Epic, and what happens to the loop when the main session's context is compacted. If state does not survive, the loop must restart from `tasks.json` alone.
- The pinned commands for the rule scan and the lab performance run, how the runner finds a browser, and the "not run" text when it cannot.
- How the lock check lists the commits of one builder and reverts only the protected paths.
- The level and finding limit for the Epic-end `code-review` run.
- Whether `tasks.json` needs a schema check in `scripts/check.sh`, and the checks for every rule above.
- The fallback text for hosts without plugin agents.

## Measuring before release

Kept outside this repository. On the same Epic-sized requests, compare a plain session, `/epic` with one building session (approach 4A) and `/epic` with a builder per task (4B):

- direction: how many of the person's intended examples pass on checks written from the intended reading, including the ones a narrow reading would miss;
- what was added and dropped without being asked;
- quality: rule-scan violations, keyboard walk result, new static-analysis warnings;
- cost: time, tokens, and how long the person spent at intake and at the final review.

A rule that does not improve direction or quality over the plain session is removed, not tuned.
