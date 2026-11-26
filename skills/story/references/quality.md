# Quality checks

## Defaults for the plan's Quality bars (medium, large)

Put a row in the plan for each check whose "Runs for" matches this work. The person may raise, lower or remove any row at the approval. Do not ask about them.

| Area | Runs for | Bar | Checked by | Scenario tag |
|---|---|---|---|---|
| Accessibility rule scan | work with a web interface | 0 violations at WCAG 2.2 A and AA on each route the examples reach | script | `[quality: a11y-scan]` |
| Keyboard and focus | work with a web interface | on the core flow: every control reachable by Tab; focus visible and not fully hidden; Escape closes overlays and focus returns | agent | `[quality: keyboard]` |
| Narrow screen and large text | work with a web interface | at 320 px width and at 200% text: no horizontal scroll, no clipped text | agent | `[quality: narrow]` |
| Empty, loading and error states | work with data views (a list, a table, search results, or a page that loads a record) | each data view shows all three; an error says how to fix it and keeps the input | agent | `[quality: states]` |
| Performance, lab | only when the plan sets a budget | median of 5 runs, mobile profile: LCP ≤ 2.5 s, CLS ≤ 0.1, blocking time within the plan's budget | script | `[quality: performance]` |
| Planned events | only when the plan lists events | every listed event is seen when its example runs | agent | `[quality: events]` |
| Text for other languages | only when the plan lists locales, or the repository already has translation files | no user-facing text hard-coded in new code | code-reading check (b) below | none |
| Code health | all medium and large work | no warning from the repository's own linter and static analysis on the lines this branch changed | code-reading check (a) below | none |
| Screen reader on the core flow | work with a web interface | the person can complete it | person at the final review | none |
| Field performance, translation quality, the success metric | any | measured on real users | after launch only | none |

Rows with a scenario tag are run by `qa-runner` from the running app. `qa-writer` turns each into a scenario.

## What these checks do and do not show

- A check that could not run is `not run` with the reason. Nothing stands in for it.
- A rule scan with 0 violations is a floor, not "accessible": automated rules cover only part of WCAG, and keyboard and focus problems are mostly found by walking the flow. The keyboard walk is evidence for the person, with screenshots.
- Lab performance is not field performance. Interaction latency cannot be measured without real input. Never report field numbers before launch.
- Translation quality needs a reader of that language. Report it as after launch only, or as a step for the person.
- No LLM usability review decides pass or fail.

## Code-reading checks (item 4 of the security subagent's prompt)

Add this to the security subagent's prompt, word for word, with `<base>` filled in:

"(4) Quality checks that read code. (a) Code health: find the repository's own lint and static-analysis commands in its build files and CI config. Run them on HEAD without their fix mode, and report the warnings on lines changed in <base>...HEAD as file:line and rule. Never check out another commit and never leave a changed file behind: QA is running in this working tree. Install nothing. When there is no such command, or it cannot run, write the reason. (b) Only when the plan lists locales or the repository already has translation files: list user-facing text hard-coded in lines changed in <base>...HEAD, as file:line and the text. Add two lines to the start of your return: `Code health: ran | not run: <reason>` and `Hard-coded text: ran | not run: <reason> | not applicable`."
