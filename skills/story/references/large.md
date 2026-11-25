# Building large work

For large work you coordinate and write no feature code yourself. Builders build. `qa-runner` decides what passes.

State lives in files, not in this conversation. At the start of every round, and whenever you are unsure where you are (a long run, a summarized context), read `docs/stories/<slug>.tasks.json` and continue from it.

## 1. Split

Write `docs/stories/<slug>.tasks.json`. How you split and order the work is your own choice.

```json
{
  "story": "docs/stories/<slug>.md",
  "base": "<commit the branch started from>",
  "tasks": [
    { "id": "T1", "title": "<what gets built>", "serves": ["E1", "E3"], "status": "todo", "commit": null, "note": null }
  ]
}
```

- `serves` lists what the task is needed for: examples (`E1`), `Unchanged`, or a quality bar.
- A task that serves nothing in the plan is added scope. Log it in the decisions file; it shows under 더한 것 at the final review.
- `status`: `todo` → `built` (the builder committed it) → `passed` (the runner passed every example it serves), or `failed`, or `parked` (it waits on a flag).

Create `docs/stories/<slug>.decisions.md` with the entry format from the skill as a comment at the top and two headings, `## Decisions` and `## Flags`. Commit both files.

## 2. One task at a time

Take the first `todo` task. Note the current commit as `<before>` (`git rev-parse HEAD`). Start one new general-purpose subagent (not a fork) with this prompt:

"You build one task of a larger piece of work. Repository: <path>. Plan: `docs/stories/<slug>.md`. Decisions so far: `docs/stories/<slug>.decisions.md`. Tasks: `docs/stories/<slug>.tasks.json`. Your task: <id>. Read the plan and the decisions first. Implement this task as you normally would, and commit. Never edit the plan, `docs/stories/<slug>.qa.md`, the tasks file or anything under `qa/`. Append to the decisions file each decision that changes what a user sees, what is stored, or what is hard to reverse, in the format already used there; routine choices are not logged. Do not pick when the task needs any of these: a decision about money, migration, authentication or authorization, an external contract, or stored or sensitive data that the plan does not answer; a change to the plan's scope; a one-way step the plan does not cover; an example that looks wrong or cannot be met. Build what does not depend on it and return it as a flag. Return four lines: `Commit: <hash>`, `Decisions: <ids added, or none>`, `Flags: <what, the options, what it blocks; or none>`, `Not done: <what and why, or none>`."

Never start two builders at once.

## 3. Lock check

When the builder returns:

- `git status --porcelain` is not empty: commit what it left, as that task's work.
- `git diff --name-only <before> HEAD -- docs/stories/<slug>.md docs/stories/<slug>.qa.md docs/stories/<slug>.tasks.json qa/` must print nothing. When it prints paths, restore them with `git checkout <before> -- <paths>`, commit, and keep one line for `확인하지 못한 것` at the final review: which task changed which protected file, and that it was reverted.
- Write its flags under `## Flags` in the decisions file. Set the task to `built` with its commit. Commit the tasks file.

An instruction is not a lock. This check is.

## 4. Acceptance, example by example

When every task whose `serves` lists an example is `built`, check `docs/qa.md` as step 3 of the skill says, then start `pazmo-story-to-dev:qa-runner` with `QA Story: docs/stories/<slug>.qa.md`, `Repository: <repository path>` and `Scenarios: <the ids of the scenarios tagged with that example>`. Commit the scripts it wrote.

- Every scenario passed: the example has passed. A task becomes `passed` when every example it serves has passed.
- A scenario failed: start a new builder as in 2, with the task id and one more line: `Fix: <scenario id> expected <text>, saw <evidence>`. Run the lock check, then the runner again for those scenarios. After two rounds still failing: set the tasks to `failed`, go on with the rest, and report it.

Only the runner's result changes a task to `passed`. A builder saying it is done changes it to `built`, nothing more. A scenario that could not run is `not run`, never passed.

## 5. Flags

A flag parks the tasks that depend on it (`parked`, with the flag in `note`). Go on with the rest. Flags are answered at the final review, under `사람이 정할 것`. When every task left is parked, stop and ask the person now: this is the only question in the middle of a build.

## 6. When no task is `todo`

Go to step 3 of the skill: the full QA run, the security subagent and the review subagent, in one message. A fix that comes out of it goes to a builder as in 4, followed by the lock check.
