# 최종 리뷰: <same title as the plan>

Plan: docs/stories/<slug>.md
열어 보기: <URL, or the command that starts it> (<how to get access>)

## 1 의도
- 왜: <the plan's Why, word for word>
- 결과: <the plan's Outcome, word for word>
- 만든 것: E1 됨 · E2 됨 · E3 일부: <what is missing> · E4 안 됨: <why>
- 더한 것: <built but in no example, or 없음>
- 뺀 것: <in scope but not built, or 없음>

## 2 해 보기
1. <do this> → <you should see this>   [ ]
2. <do this> → <you should see this>   [ ]

그다음: 사용자라면 처음 할 일을 직접 해 보세요.

## 3 결정
- D<n>. <X>로 정함 (<Y> 대신). 틀렸다면 <Z>가 보임. 확인: 해 보기 <n>번.   유지 / 바꾸기
- 나머지: docs/stories/<slug>.decisions.md

## 4 근거
- QA (<target>): | 시나리오 | 실행 | 결과 | 근거 |
- 품질: 접근성 위반 <n> (기준 0) · 키보드 <result> · 성능 <value> (기준 <bar>) · 코드 건강 <new warnings>
- 보안: <fixed> / <for the person> / <left, with reason>, or "지적 없음"; 스캐너 <ran | not run: reason>, security-review <ran | not run: reason>
- 리뷰: <fixed> / <for the person> / <left, with reason>
- QA 스크립트: <qa/<slug>.* path>

## 5 사람이 정할 것
- <each flag: what, the options, what it blocked; or 없음>

## 6 확인하지 못한 것
- <each check not run and why · each step only a person can do · what can only be known after launch · what was picked after the question budget ran out; or 없음>

## 7 판단
수락 / 고쳐서 수락: <…> / 방향이 다름: <E# 또는 범위 항목>

---
Status: Draft | Accepted

<!--
Rules for writing this file:
- Section 1 quotes the plan, then says 됨, 일부 or 안 됨 per example. 더한 것 and 뺀 것 are always present.
- Section 2 has one step per example: one thing to do, one thing to see. The person does them on the running build.
- Section 3 lists at most seven decisions, ordered by cost to reverse (one-way first) and then by effect on users. Each is a question with where to check it, never a justification.
- Section 4 is numbers and links from the runner and the subagents, next to their bars. Do not summarize them in your own words.
- Sections 5 and 6 stay even when empty: 없음.
- Never write "verified" for something that was not run. Field performance, translation quality and the success metric are after launch only.
-->
