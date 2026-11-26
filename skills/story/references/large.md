# Building large work

For large work you coordinate and write no feature code yourself. Builders build. `qa-runner` decides what passes.

State lives in files, not in this conversation. At the start of every round, and whenever you are unsure where you are (a long run, a summarized context), read `docs/stories/<slug>.tasks.json` and continue from it.

## 1. Split

Write `docs/stories/<slug>.tasks.json`. How you split and order the work is your own choice.

```json
{
  "story": "docs/stories/<slug>.md",
  "base": "<commit the branch started from>",
  "examples": { "E1": { "status": "todo", "rounds": 0 } },
  "tasks": [
    { "id": "T1", "title": "<what gets built>", "serves": ["E1", "E3"], "status": "todo", "commits": [], "note": null }
  ]
}
```

- `serves` lists the examples (`E1`) the task is needed for, and `Unchanged` when it touches something the plan keeps. Quality bars are not a task's to prove: the runner checks them at the end.
- A task that serves nothing in the plan is added scope. Log it in the decisions file; it shows under 더한 것 at the final review.
- `examples` holds each example's status (`todo`, `passed`, `failed`, `not run`) and how many fix rounds it has had, so the count survives a summarized context.
- `status`: `todo` → `built` (a builder committed it) → `passed` (the runner passed every example it serves, whenever that happens), or `failed` (the runner still fails it after two fix rounds, or two builders committed nothing), or `parked` (it waits on a flag).
- `commits` holds every builder commit for the task.

Create `docs/stories/<slug>.decisions.md` with the entry format from the skill as a comment at the top and two headings, `## Decisions` and `## Flags`. Commit both files.

## 2. One task at a time

Take the first `todo` task. Note the current commit as `<before>` (`git rev-parse HEAD`). Start one new general-purpose subagent (not a fork) with this prompt:

"You build one task of a larger piece of work. Repository: <path>. Plan: `docs/stories/<slug>.md`. Decisions so far: `docs/stories/<slug>.decisions.md`. Tasks: `docs/stories/<slug>.tasks.json`. Your task: <id>. Read the plan and the decisions first. Implement this task as you normally would, and commit. Never edit the plan, `docs/stories/<slug>.qa.md`, `docs/qa.md`, the tasks file or anything under `qa/`. Append to the decisions file each decision that changes what a user sees, what is stored, or what is hard to reverse, in the format already used there; routine choices are not logged. Do not pick when the task needs any of these: a decision about money, migration, authentication or authorization, an external contract, or stored or sensitive data that the plan does not answer; a change to the plan's scope; a one-way step the plan does not cover; an example that looks wrong or cannot be met. Build what does not depend on it and return it as a flag. A flag already open in the decisions file is the person's to answer: never act on it. Something on a page the plan keeps Unchanged that was already wrong before this work is a flag too, not yours to fix. Quality bars and the QA scenarios are checked by others after you: do not read or run anything under `qa/`, and install no tools. Return five lines: `Commit: <hash>`, `Where: <E# → file:line or test, for each example this task serves>`, `Decisions: <ids added, or none>`, `Flags: <what, the options, what it blocks; or none>`, `Not done: <the part of this task you did not build, and why; or none>`."

Never start two builders at once.

## 3. Lock check

When the builder returns:

- `git status --porcelain` is not empty: commit what it left, as that task's work.
- `git diff --name-only <before> HEAD -- docs/stories/<slug>.md docs/stories/<slug>.qa.md docs/stories/<slug>.tasks.json docs/qa.md qa/` must print nothing. When it prints paths, undo each one: `git checkout <before> -- <path>` when the path existed at `<before>`, `git rm -q -f <path>` when it did not. Commit, and keep one line for `확인하지 못한 것` at the final review: which task changed which protected file, and that it was undone.
- Write its flags under `## Flags` in the decisions file.
- When it returned a commit, add it to `commits` and set the task to `built`. When `Not done` names a part of this task, start one more builder for the task with that line added, once; whatever is still missing after that goes in `note`, and the runner decides. Only when it returned a commit does the task count as built: with no commit from two builders in a row, set it to `failed` with the reason in `note`.
- Commit the tasks file and the decisions file.

An instruction is not a lock. This check is.

## 4. Acceptance, example by example

After each lock check, list the examples whose tasks are now all `built` and that have no result yet. When there are any, start `pazmo-story-to-dev:qa-runner` once for all of them together (with `Target: preview`, push the branch first), with `QA Story: docs/stories/<slug>.qa.md`, `Repository: <repository path>` and `Scenarios: <the ids of the scenarios tagged with those examples>`. One run per builder at most, never one run per example. Commit the scripts it wrote. Record each result in `examples`, and commit the tasks file before the next builder or runner starts.

- Every scenario passed: the example has passed. A task becomes `passed` when every example it serves has passed, even when that happens in a later run.
- A scenario failed: start a new builder as in 2, with the id of the last task that serves the example and one more line: `Fix: <scenario id> expected <text>, saw <evidence>`. Run the lock check, then the runner again for those scenarios, and add one to the example's `rounds`. After two rounds still failing: set the example and its tasks to `failed`, go on with the rest, and report it.
- The app could not start, or a scenario could not run: the example is `not run`. Go on building and report it; do not ask in the middle.

Only the runner's result changes a task to `passed`. A builder saying it is done changes it to `built`, nothing more. A scenario that could not run is `not run`, never passed.

## 5. Flags

A flag parks the tasks that depend on it (`parked`, with the flag in `note`). Go on with the rest. A flag that parks no task is answered at the final review, under `사람이 정할 것`.

When no task is `todo` and some are `parked`, stop, ask the person every open flag in one message, and end your turn: this is the only question in the middle of a build. With the answers: write each under its flag and in the plan's Human decides line, set the tasks it parked to `todo`, commit, and continue from 2. An answer that adds, drops or changes an example is a correction: update the plan with the person's words, start `qa-writer` again with `Correction:`, then build.

## 6. When no task is `todo` or `parked`

Go to step 3 of the skill: the full QA run, the security subagent and the review subagent, in one message. Record the full run's result for every example in `examples` and update the tasks. A fix that comes out of it goes to a builder as in 4, followed by the lock check. An example already `failed` gets no further rounds.

For the example check of step 2 of the skill, use the `Where:` lines the builders returned.
