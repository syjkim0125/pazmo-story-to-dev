# <Epic | Story>: <outcome in one line>

<!-- Title: Epic for large work, Story otherwise. Small keeps: Why, What the person will see. Medium adds: Scope, Human decides, Quality bars, Done when. Large adds: Users, Success after launch, Operability. Delete the sections the size does not keep, except a section whose intake question was asked. The footer stays at every size. -->

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
- QA reaches these states by: <test data, a test account, or a switch no production user can see; delete when every state is reachable as the app is>

## Scope
- Smallest reading: <one line>
- A fuller reading adds:
  - [ ] S1. <item>: <file:line and what exists today> → would add: <where · action → visible result>
  - [ ] S2. <item> → would add: <where · action → visible result>
  - [ ] S3a / S3b. <two readings that exclude each other; the person picks one>
- Chosen by <person> on <date>: <the ids that are in; "open" until they answer>
- Out of scope:
  - O1. <item>: <why, or "declined by <person>">
- Unchanged:
  - <what must stay exactly as it is, with the exact text a user sees today where QA should check it>

## Human decides
- H1. <a decision from references/risks.md> → <the person's answer | open, blocks <what>>

## Quality bars
| Area | Bar | Checked by | Tag |
|---|---|---|---|
| <from references/quality.md> | <threshold> | script \| agent \| code-reading check \| person at the final review \| after launch only | <`[quality: …]` from references/quality.md, or none> |

## Success after launch
- Primary metric: <what would tell you this worked>
- Must not get worse: <one to three guardrails>
- Events to record: <name: when it fires | none>
- Personal data: <what is collected, kept how long, how deleted | none>

## Operability
- Release: all at once | behind a switch | staged
- Roll back when: <the signal you propose, for the person to confirm>

## Done when
- Every E# passes on the running app, on checks the builder cannot edit
- Every quality bar passes, or is listed as not verified with the reason
- Security review: no confirmed finding open
- Every Human decides item is answered
- The person has done the final review

---
Size: small | medium | large
Status: Draft | Approved
Owner: <the person who made the request; `git config user.name` unless they say otherwise>
