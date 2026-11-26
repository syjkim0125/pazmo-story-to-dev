# Intake

Large work runs this as a conversation, one question at a time. Medium work asks questions 1 to 4 through the plan draft itself and adds a later question only when its trigger holds. Small work skips this file.

## Before asking anything

Read the request and the repository, then draft for yourself:

- a one-paragraph restatement: who has what problem today, and what is different for them afterwards;
- two or three readings of the request, from the smallest that fits the words to the fullest a reasonable person could mean, each as a list of things a user would see;
- where the readings differ in something a user would see, and where the request contradicts itself;
- the lenses of [risks.md](risks.md) that match.

## Questions

Give options to choose from wherever you can.

| # | Question | Asked when |
|---|---|---|
| 1 | "Here is what I understood: who has what problem today, and what will be different when this is done. Is that right?" | Always |
| 2 | "The smallest version that fits your words is A. A fuller version would also include B, C, D. Which of these are in?" The person answers per item. | Always |
| 3 | "Here is what a user will see. Yes, no, or change it?" Large work usually has five to nine examples, with at least two at the edge of scope and one that must not happen. Medium work has as many as the request needs, with at least one at the edge of scope. | Always |
| 4 | "These are out of scope. Is anything you expect in neither list?" | Always |
| 5 | Each matching decision from `risks.md`, one at a time | A lens matches |
| 6 | "Who uses this? Is there a group that must not be excluded: age, assistive technology, language or region?" | The work has a user interface and the repository does not say |
| 7 | "After launch, what would tell you this worked? What must not get worse?" | Once, for large work; with no answer, propose one for a yes or no |
| 8 | "Can this reach everyone at once, or must it be possible to turn it off?" This is the same question as the rollback item of `risks.md`: ask it once. | It changes a flow existing users rely on, or a lens matched |
| 9 | "Your request says X and also Y. Which holds?" | You found a contradiction |

## Rules

- Question 2 shows every reading as a list of things a user would see. Recommend none and mark none as the default. An item nobody answered stays open; never move it to Out of scope yourself.
- An example has the form `where · action → visible result`.
- Never ask about language, framework, libraries, architecture, data model, file layout, how to split or order the work, test strategy, naming, check tools, or anything the repository answers. You decide those.
- A choice that looks technical but falls under `risks.md`, such as which payment provider to use, is the person's.
- Ask a `risks.md` item only when it changes this work's behavior.

What `docs/qa.md` lacks to start the app or log in is not asked here: `qa-writer` reports it as gaps, and they are shown at the approval.

## When to stop asking

Stop when all three hold:

- every sentence of the request maps to an example, to Out of scope with a reason, or to a Human decides item;
- the readings no longer differ in anything a user would see;
- every matched risk item has an answer, or is recorded as open with what it blocks.

Budget: five questions beyond the first four, not counting risk items. Past the budget, pick, and list the pick under `확인하지 못한 것` at the final review. Scope items and risk items are never picked this way.

More than nine examples means the work is too large for one final review. Propose a split into separate Epics and let the person pick the first.

## Then

Write the whole plan as one file and show it. The build starts from the file, not from this conversation.
