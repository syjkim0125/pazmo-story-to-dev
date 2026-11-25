# <Epic | Story>: <outcome in one line>

<!-- Small keeps: Why, What the person will see. Medium adds: Scope, Human decides, Quality bars, Done when. Large adds: Users, Success after launch, Operability. Delete the sections the size does not keep. -->

## Why
- Today: <who has what problem>
- Outcome: <what is different for them when this is done>

## Users
- <who uses it; any group that must not be excluded: age, assistive technology, languages, regions>

## What the person will see
- E1. <where> · <action> → <visible result>
- E2. <where> · <action> → <visible result>
- E3. (edge) <where> · <action> → <visible result>
- E4. (must not happen) <what never shows or happens>

## Scope
- Smallest reading: <one line>
- A fuller reading adds:
  - [ ] <item>: <file:line and what exists today>
  - [ ] <item>
- Chosen by <person> on <date>: <the items that are in>
- Out of scope:
  - O1. <item>: <why>
- Unchanged: <what must stay exactly as it is>

## Human decides
- H1. <a decision from references/risks.md> → <the person's answer | open, blocks <what>>

## Quality bars
| Area | Bar | Checked by | Tag |
|---|---|---|---|
| <from references/quality.md> | <threshold> | script \| agent \| code-reading check \| person at the final review \| after launch only | <`[quality: …]` from references/quality.md, or none> |

## Success after launch
- Primary metric: <what would tell you this worked>
- Must not get worse: <one to three guardrails>
- Events to record: <name: when it fires>
- Personal data: <what is collected, kept how long, how deleted | none>

## Operability
- Release: all at once | behind a switch | staged
- Roll back when: <signal and threshold>

## Done when
- [ ] Every E# passes on the running app, on checks the builder cannot edit
- [ ] Every quality bar passes, or is listed as not verified with the reason
- [ ] Security review: no confirmed finding open
- [ ] Every Human decides item is answered
- [ ] The person has done the final review

---
Size: small | medium | large
Status: Draft | Approved
Owner: <the person who made the request>
