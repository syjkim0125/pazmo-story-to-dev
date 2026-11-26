# One command, three sizes: plan once, build alone, review once

Status: approved 2026-11-25; amended the same day (one command, the AI sizes the work)

Research behind this draft: [docs/research/2026-11-25-epic-planning.md](../../research/2026-11-25-epic-planning.md). Section numbers below (R3.1, R4c) point into it. Each design rule is marked **evidence** (a finding supports it) or **choice** (no direct evidence; the reason is given).

## Why

The kit's direction changed. A person now plans at the level of what to build and why, for a whole Epic. The AI decides every detail: implementation, how to split the Epic into tasks, and the build. QA and the security review run on their own. The person checks the result once, when the Epic is done.

Two things the kit has measured shape the design. On current models a plain agent session already matches kit-driven code quality, so the kit has to earn its place through direction and product quality. And the one failure measured so far was a Story, written by the AI, that picked a narrower reading than the person wanted; the build was then narrow too.

An amendment the same day: a person should not have to pick a command by guessing how big the work is. One command takes any request, the AI sizes it, and the size sets how much process runs. What follows describes large work (an Epic) in full; the Sizes section says what medium and small work leave out.

With a person present only at the start and the end, three things carry the weight:

1. The start has to fix the reading of the request, above all how broad it is.
2. In between, nothing the builder writes may count as proof that the work is done.
3. The end has to let a person judge direction in one sitting, without reading the diff.

## Goals

- One command, `/story`, for any request. After reading the code and before any edit, the AI sizes the work as small, medium or large.
- For medium and large work: one approval before any code, on one plan the person can read in a few minutes. Small work starts without waiting, from a one-line restatement.
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
- A command per size. The person never has to size the work before asking.

## Anti-goals (a failure even if it works)

- An intake that interrogates. Questions the person cannot answer, or that the repository answers, are a defect.
- Scope breadth settled by an assumption the AI wrote down and nobody read.
- A final review that is the builder's own account of why it was right.
- "Verified" on anything that was not run. The kit's rule stands: a check that cannot run is reported as not run, with the reason, and nothing stands in for it.
- A person asked to approve tasks, Stories or QA documents one by one during the build.
- Sizing down to skip a guard. In doubt the size goes up, and anything under `references/risks.md` is at least medium.
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
| **A. One command, `/story`; the AI sizes the work (picked by the owner in the amendment)** | The person never guesses the size. Size is judged after the code is read, which is when it can be known. One set of files to keep. | `/story` changes for 0.3.0 users: medium work goes from two approvals to one. A wrong size removes or adds process. |
| B. Add `/epic`, keep `/story` (the first pick, withdrawn) | 0.3.0 users unaffected. | Two commands overlap on small work, and the person has to choose between them. |
| C. A command per size (`/epic`, `/story`, `/task`) | Explicit. | The person sizes the work before the code is read. A wrong guess runs too much process or too little. |

**Choice**: no evidence was found on how well a model sizes work. The release measurement checks it.

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
| A. One approval covers the plan and the checks: `qa-writer` runs before the approval (the first pick, withdrawn after a live run) | The person sees the scenarios with the plan. | The writer runs while scope items are still open, so its scenarios are rewritten after the answers, and the approval message grew to about 45 lines in the run. |
| B. Keep a separate approval after the build | As in 0.3.0. | A second person step in the middle, which the new direction rules out. |
| **C. `qa-writer` runs after the approval; scenarios may come only from what the person approved; a one-line summary and the gaps are shown, and only a gap that blocks every check is asked (picked by the owner)** | The writer runs once, on a settled plan. Each scope item carries the example it would add, so one reply can answer and approve. | The person does not read the scenarios before the build; the guard is the rule that a scenario maps to an approved example, an Unchanged item or a quality bar, plus the black-box reading rule. |

**Evidence** in part: people judge intent well from concrete checks (R3.1, TiCoder), and the person still approves those in the plan. Dropping the look at the scenarios themselves is a **choice**, made from one live run.

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
| B. Every check on all medium and large work | Uniform. | Runs that check nothing, and "not run" noise. |
| C. Only checks the person asks for | Cheapest. | Quality bars are exactly what a "what and why" request leaves out. |

## Design

### Sizes

The AI reads the request and the code, then sizes the work before any edit. It shows the size and the reason in one line. The person can change it with a word.

| | Small | Medium | Large (an Epic) |
|---|---|---|---|
| It is this size when | all hold: one reading; every edited file in one module (one directory or package, one copy); nothing in `risks.md`; at most two examples | neither small nor large | any holds: more than five examples; more than one user flow; a new subsystem (a new service, data store or external integration) |
| Start | one-line restatement, no waiting | the plan draft in one message, one approval | the intake conversation, then one approval |
| Plan file | Why and the examples | adds Scope, Human decides, Quality bars | adds Users, Success after launch, Operability |
| Build | main session | main session | one fresh builder per task (phase 3) |
| Code review subagent | none | one | one, at the end |
| QA | only when a user would see the change: its examples | every example, once | per example as it completes, and all at the end |
| Security | the scanner | the scanner and `security-review` | the same |
| End | a short report | the review, usually a few minutes | the review, about half an hour |

Rules:

- The size comes from the criteria in the table, not from how the request sounds.
- In doubt, one size up.
- Anything under `risks.md` is at least medium.
- During the work the AI may raise the size (the change turned out to reach further) and says so. It never lowers it.

(**Choice**: the tiers extend the small-change rule the kit already has. The start gate is kept wherever readings can differ, which is where the evidence for it lies, R3.1.)

### Package

```
skills/story/SKILL.md               /story: size, plan, build, checks, review (rewritten)
skills/story/assets/STORY.md        plan template for all sizes (rewritten)
skills/story/assets/REVIEW.md       final review template
skills/story/references/intake.md   the questions, when each is asked, the stop rule
skills/story/references/large.md    the build loop for large work: tasks, builders, lock check, flags
skills/story/references/quality.md  quality checks: which run by default, and the code-reading ones
skills/story/references/risks.md    unchanged
agents/qa-writer.md                 scenarios per example, per Unchanged item, per quality bar
agents/qa-runner.md                 also runs the black-box quality checks
skills/qa/SKILL.md                  wording follows the new step numbers
scripts/check.sh                    checks for the new files and rules
README.md                           one command, three sizes; what changed from 0.3.0
```

Version 0.4.0. Large-work instructions live in `references/large.md`, so a session doing small or medium work does not read them.

### Files of one piece of work

```
docs/stories/<slug>.md             the plan; after approval the builder never edits it
docs/stories/<slug>.qa.md          the QA Story, written by qa-writer from the plan
docs/stories/<slug>.decisions.md   decisions the AI made, each "proposed" until the review (medium, large)
docs/stories/<slug>.tasks.json     the AI's own split of the work, with status per task (large)
docs/stories/<slug>.review.md      the final review (medium, large)
qa/<slug>.sh (or .spec.*)          QA scripts, written only by qa-runner
```

The paths `/qa` takes are the same as in 0.3.0.

### Phase 1: intake

Large work runs this as a conversation. Medium work puts questions 1 to 4 into one message together with the plan draft, plus any triggered question, so one reply can answer and approve. Small work skips it.

Before asking anything, the main session reads the request and the repository, then drafts:

- a one-paragraph restatement: who has what problem today, and what is different for them afterwards;
- two or three readings of the request, from the smallest that fits the words to the fullest a reasonable person could mean, each as a list of things a user would see;
- where the readings differ in something a user would see, and where the request contradicts itself;
- the `risks.md` lenses that match.

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

Rules:

- Question 2 shows both readings as lists of user-visible items. No item is marked as recommended or default. An item nobody answered stays open; the AI never moves it to out of scope. (**Choice**, approach 2.)
- An example has the form `where · action → visible result`. (**Evidence**: R3.1, examples a person answers yes or no.)
- What `docs/qa.md` lacks to start the app or log in is not an intake question: `qa-writer` reports it as gaps right after the approval, and a gap that blocks every check is asked before the build starts.
- Questions 5 to 9 are asked only on their trigger. (**Evidence**: asking by default has a measured cost, R3.1.)
- Never ask the person about language, framework, libraries, architecture, data model, file layout, task split or order, test strategy, naming, which check tool, or anything the repository answers. A choice that looks technical but falls under `risks.md`, such as which payment provider, is the person's. (**Evidence**: questions the user cannot answer are wasted, R3.1.)
- Stop asking when every sentence of the request maps to an example, to out of scope with a reason, or to a Human decides item; the readings no longer differ in anything a user would see; and every matched risk item is answered or recorded as open with the tasks it blocks.
- Budget: five questions beyond the first four, not counting risk items. Past it the AI picks and lists the pick for the final review. Scope breadth and risk items are never picked this way. (**Choice**: no study gives the value of one more question.)
- More than nine examples means the Epic is too large for one review. Propose a split into Epics and let the person pick the first. (**Choice**.)

### Phase 2: the plan and the one approval

1. Start a branch. Write `docs/stories/<slug>.md` from the template: Why, Users, What the person will see (E1…), Scope (smallest reading, fullest reading, what the person chose, out of scope, unchanged), Human decides, Quality bars, Success after launch, Operability, Done when. Content in the person's language.
2. Quality bars: the AI fills defaults by the kind of Epic (see Quality checks). Each row has the bar, the check and who verifies: script, agent, person at the final review, or after launch only.
3. **Approval.** Show, one line each: the plan path; today → after; the scope items still to choose, each with the example it would add; each example; each Human decides item; what is out of scope; the quality bars. Ask once. A reply that answers every open item and changes no example is the approval. On a correction, update the plan and show only what changed.
4. After approval: `Status: Approved` on the plan, commit. The build starts from the file, not from the conversation. (**Evidence**: instructions spread over turns degrade results, R3.1.)
5. Start `qa-writer` with `Story: docs/stories/<slug>.md` and the repository path. It writes `docs/stories/<slug>.qa.md`: at least one scenario per example, one per Unchanged item, one per quality bar that a script or agent verifies, and nothing else. The main session marks it approved, tells the person in one line how many scenarios there are and which gaps remain, and goes on. Only a gap about starting the app, logging in or reaching an example's starting state is asked, because it blocks every check.

Small work writes only Why and the examples, shows the one-line restatement and the size, and goes on without waiting.

### Phase 3: the build loop (large work)

For large work the main session coordinates and writes no feature code itself. Small and medium work is built in the main session as it normally would be; of the rules below, the decision log, the flags and the ban on editing the plan, the QA Story and `qa/` still apply.

1. **Split.** Write `docs/stories/<slug>.tasks.json`: for each task an id, a title, the examples or quality bars it serves, and a status (`todo`, `built`, `passed`, `failed`, `parked`). The split and the order are the AI's own. A task that serves nothing in the plan is added scope: it is recorded in `decisions.md` and shown under "added" at the final review.
2. **Build one task.** Start one new general-purpose subagent (not a fork) with the plan path, `decisions.md`, `tasks.json`, the task id and the repository path. Its instructions:
   - Read the plan and `decisions.md` first.
   - Implement this task as you normally would. Commit.
   - Never edit the plan, the QA Story or anything under `qa/`.
   - Append to `decisions.md` each decision that changes what a user sees, what is stored, or what is hard to reverse. Routine choices are not logged.
   - When the task needs a `risks.md` decision the plan does not answer, a change to scope, a one-way step the plan does not cover, or when a check looks wrong: do not pick. Return it as a flag.
   - Return the commit, the decisions added, the flags, and what you could not do.
3. **Lock check.** After each builder returns, the main session compares the commits it made against the plan, the QA Story, `docs/qa.md` and `qa/`. Any change there is undone and recorded for the final review. (**Evidence**: read-only tests blocked test edits; LLM monitors alone caught only part of the cheating, R3.2. An instruction is not a lock, as the current spec already says.)
4. **Acceptance.** When every task serving an example is `built`, start `qa-runner` with `Scenarios:` for that example. Commit the scripts it wrote. Pass: those tasks become `passed`. Fail: a new builder gets the runner's evidence and fixes the app; after two rounds the example is marked failed, the loop goes on, and the failure is reported. Only the runner's result changes a task to `passed`. (**Evidence**: features were marked passing without end-to-end verification; an agent's own "done" is not reliable, R3.2.)
5. **Flags.** A flagged decision parks the tasks that depend on it and the loop continues with the rest. When only parked tasks are left, stop and ask the person every open flag in one message; this is the only contact in the middle. With the answers the parked tasks are built. A flag that parks nothing is answered at the final review. (**Evidence**: a sanctioned way to stop and hand over cut cheating sharply on realistic tasks, R3.2. Parking instead of stopping is a **choice**.)

Decision entry in `docs/stories/<slug>.decisions.md`:

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

### Phase 4: checks at the end

Large work, when no task is `todo`; medium work, when the build is committed. Start these in one message:

- `qa-runner` on every scenario, including the black-box quality checks;
- the security subagent as today (scanner and `security-review` on base...HEAD), which also runs the code-reading quality checks;
- one new subagent running the built-in `code-review` skill on the whole branch.

Findings are sorted as `/story` sorts them today. Fixes go to a builder, then the scenarios the fix touches run again. After two rounds with failures left, stop fixing and report them.

Small work starts the scanner only, and `qa-runner` only when a user would see the change.

### Quality checks

Defaults by kind of work, for medium and large. Small work runs none of these beyond its own examples. The plan can raise, lower or remove any of them. A check that cannot run is "not run", with the reason.

| Check | Runs for | How | Bar | Verifier |
|---|---|---|---|---|
| Acceptance examples | all medium and large work | `qa-runner` scripts and agent scenarios | every E# passes | script, agent |
| Accessibility rule scan | work with a web interface | axe-core on each URL the examples reach, as loaded; a state that needs a click first only through the repository's own browser test runner | 0 violations at WCAG 2.2 A and AA | script |
| Keyboard and focus walk | work with a web interface | the runner tabs through the core flow in a browser | every control reachable; focus visible and not fully hidden; Escape closes overlays and focus returns | agent, with screenshots |
| Narrow screen and large text | work with a web interface | the runner opens each URL in a browser at 320 px width and at 200% text | no horizontal scroll; no clipped text | agent |
| Empty, loading and error states | work with data views | the runner forces each state | each data view shows all of them; an error says how to fix and keeps the input | agent |
| Performance, lab | only when the plan sets a budget | Lighthouse, mobile profile, median of 5 runs | LCP ≤ 2.5 s, CLS ≤ 0.1, and the plan's blocking-time budget | script |
| Text for other languages | only when the plan lists locales, or the repository already translates | search for hard-coded text in the lines the branch changed | none | code-reading check |
| Code health | all medium and large work | the repository's own linter and static analysis, run on HEAD and read on the lines the branch changed | no warning on those lines | code-reading check |
| Planned events | only when the plan lists events | the runner reads the browser's network log while the example runs | every listed event seen | agent |
| Screen reader on the core flow | work with a web interface | a person, at the final review | the person can complete it | person |
| Field performance, translation quality, the success metric | — | real users | — | after launch only |

Why these lines are drawn where they are:

- A rule scan is a floor. In the one large dataset, a vendor's own, automation found a little over half of accessibility issues by volume and touched under a third of the criteria; keyboard and focus problems were found by hand (R3.3). So the walk is separate, and its result is evidence for the person, not a gate proven reliable.
- Lab numbers are not field numbers, and interaction latency cannot be measured without real input (R3.3). Field performance is listed as after launch, never as verified.
- An LLM usability review is left out of this version. The two studies of it disagree by a wide margin (R3.3). It may come back later as an advisory list, never as a gate.
- Black-box checks belong to `qa-runner`. Checks that read code belong to the security subagent, so the QA agents still never read source.

### Phase 5: the final review

For medium and large work the main session writes `docs/stories/<slug>.review.md` from the runner's and reviewers' returns, makes the build reachable (approach 6), and shows this. For large work it should take about half an hour; for medium work, a few minutes. Small work ends with a short report instead: what changed, what was checked, the scanner result, and what was not verified.

```
<Epic | Story>: <title>                    열어 보기: <URL, or how to start it> (<access>)
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
- The person's call: **accept** turns the decisions to `accepted` and the review file to `Status: Accepted`; the plan stays `Status: Approved`, which other tools may read. **Accept with changes** turns each change into tasks; they run through phase 3, the scenarios they touch run again, and only the changes are shown again, with the call asked again; only a plain accept counts for the merge. **Wrong direction** goes back to intake with the named example or scope item; the plan is corrected and approved again before any more code.
- Merge only after acceptance. With `Auto-merge: on`, open a PR into the integration branch and merge when CI passes, then dev QA as today. Never the production branch.

### `qa-writer` and `qa-runner` changes

- `qa-writer` reads the plan as it read the Story. It writes at least one scenario per example (`[E1]`), one per Unchanged item (`[Unchanged]`), and one per quality bar that a script or agent verifies (`[quality: a11y-scan]`, `[quality: keyboard]`). It adds no scenario that maps to none of these.
- `qa-runner` gains the black-box quality checks. Tools are called by fixed, pinned commands written in the agent file; when `docs/qa.md` names the repository's own command for a check, that is used. A tool that cannot run (no browser, no network on first use) makes that check "not run".
- Both keep their reading rule: the plan, the QA Story, `docs/qa.md`, the README, run files, seed data. Never source, tests, the diff or the commit log.

### `/qa <story path> [local|preview|dev]`

Unchanged in use: with an approved QA Story it reruns the saved scripts on the target. Without one it starts `qa-writer`; when the plan is approved the scenarios need no further approval, and for an older or unfinished Story it shows them and asks.

### Hosts without plugin agents

`/story` sizes the work, runs intake and the plan, builds in the main session at every size, and ends by telling the person to run `/qa docs/stories/<slug>.md` in a new session. The final review is written after that run. The `/qa` session runs the security checks and the review after QA, and the person pastes its report back for the final review.

## What this draft leaves out of the research proposals, and why

- **Advisory LLM usability review and persona walkthrough** (R4d): conflicting or missing evidence; cost with no gate value. Later, if wanted.
- **Names, personal fields, dates and plural checks** (R4d): too dependent on the stack for a first version. They can be added as plan-specific examples.
- **Server latency under load**: needs seeded data and a load tool per repository. A plan can state it as an example a person checks.
- **Reliability target and error budget in the plan** (R4b): kept as one optional line under Operability; no outcome evidence, and it means little before there are users.
- **A pseudo-locale run with an overflow check, a bundle-size budget, and a rule scan of states behind a click** where the repository has no browser test runner: each needs support from the repository that the kit cannot assume. Code health is read on changed lines instead of compared with the base, so that nothing checks out another commit while QA runs in the same working tree.
- **A fresh-context check of every task against the plan** (R4c): the runner per example and the review at the end cover it at lower cost. To revisit if the measurement shows drift between tasks.

## Left to the builder

- The exact wording of `skills/story/SKILL.md`, the two templates and the three reference files.
- How the size line reads, and the words by which a person changes the size.
- First build step: confirm with one run that the main session can start builder subagents one after another across a long Epic, and what happens to the loop when the main session's context is compacted. If state does not survive, the loop must restart from `tasks.json` alone.
- The pinned commands for the rule scan and the lab performance run, how the runner finds a browser, and the "not run" text when it cannot.
- How the lock check lists the commits of one builder and reverts only the protected paths.
- The level and finding limit for the Epic-end `code-review` run.
- Whether `tasks.json` needs a schema check in `scripts/check.sh`, and the checks for every rule above.
- The fallback text for hosts without plugin agents.

## Measuring before release

Kept outside this repository. On the same Epic-sized requests, compare a plain session, `/story` on large work with one building session (approach 4A) and with a builder per task (4B):

- direction: how many of the person's intended examples pass on checks written from the intended reading, including the ones a narrow reading would miss;
- what was added and dropped without being asked;
- quality: rule-scan violations, keyboard walk result, new static-analysis warnings;
- cost: time, tokens, and how long the person spent at intake and at the final review;
- sizing, on requests of every size: how often the AI's size matches the size a person would give, and what a too-small size let through.

A rule that does not improve direction or quality over the plain session is removed, not tuned.
