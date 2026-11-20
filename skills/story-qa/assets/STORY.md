# Story: <observable outcome>

## Goal
1. As-is: <what happens today and why it is a problem>
2. To-be: <what happens after the change>
3. Unchanged: <what must stay exactly as it is>

## Decisions
- D1. <where the request reads more than one way>
  - Options: <a> / <b>
  - Pick: <a>, because <file:line and what it shows>
- Copies: <every copy found, and which ones change>

## Human decides
- <a choice from references/risks.md, or a QA environment gap; delete the section when empty>

## MUST
- M1. <condition or case>
  1. <observable result>

## OUT
- O1. <excluded item>: <why>

## QA
Environment: <local or staging, from docs/qa.md>
Script: qa/<slug>.sh (or qa/<slug>.spec.ts)
- Q1 [M1] (script). <where> · <setup> · <action> → <expected visible result>
- Q2 [Unchanged] (script). <where> · <setup> · <action> → <expected visible result>
- Q3 [not shown] (script). <where> · <setup> · <action> → <the change does not appear>
- Q4 [M2] (agent | person). <where> · <setup> · <action> → <expected visible result>

---
Status: Draft | Approved
Owner: <the person who made the request>
