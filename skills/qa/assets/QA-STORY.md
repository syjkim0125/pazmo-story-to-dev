# QA Story: <same title as the feature Story>

Feature Story: docs/stories/<slug>.md
Target: <local | preview, from docs/qa.md>
Script: qa/<slug>.sh (or qa/<slug>.spec.ts)

## Scenarios
- Q1 [E1] (script). <where> · <setup> · <action> → <expected visible result>
- Q2 [Unchanged] (script). <where> · <setup> · <action> → <expected visible result>
- Q3 [E4] (script). <where> · <setup> · <action> → <what must not happen does not happen>
- Q4 [E2] (agent | person). <where> · <setup> · <action> → <expected visible result>
- Q5 [quality: a11y-scan] (script). <each URL the examples reach> → 0 violations
- Q6 [quality: keyboard] (agent). <the core flow> → every control reachable, focus visible, Escape closes overlays

## Gaps
- <what a scenario needs that docs/qa.md does not say: login, test data, external sandbox; delete the section when empty>

---
Status: Draft | Approved
