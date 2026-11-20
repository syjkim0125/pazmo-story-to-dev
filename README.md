# story-qa-kit

AI에게 일을 맡길 때 사람이 확인하는 건 두 가지예요. **내 요청을 맞게 이해했나**, **실제로 띄운 앱에서 그렇게 동작하나.** 그 사이는 Claude가 원래 하던 대로 해요.

```
Story + QA 목록 → 사람 승인 → 구현(순정) → 독립 리뷰 → 로컬 QA
  → dev 머지(켰을 때만) → dev QA → 사람에게 보고
```

## 왜 이렇게 가볍나

이전 ai-workflow-kit(5.x)은 단계 순서, 모델 나눠 쓰기, 그래프 실행기로 모델을 이끌었어요. 같은 작업 6개를 각 10번씩 비교해 보니, 비용을 줄인 kit은 순정 Opus와 품질이 같았고(1대1 5승 5패) 시간은 1.8~2.3배 걸렸어요. kit이 진 이유의 절반은 요청 해석이었어요. 사람이 Story를 한 번 보면 잡을 수 있는 종류예요. 그래서 사람이 보는 부분만 남겼어요.

## 들어 있는 것

| 파일 | 내용 |
|---|---|
| `skills/story-qa/SKILL.md` | 여섯 단계 |
| `skills/story-qa/assets/STORY.md` | Story 양식: 목표, 해석이 갈리는 곳, MUST/OUT, QA 시나리오 |
| `skills/story-qa/assets/QA-ENV.md` | 저장소마다 하나 두는 QA 환경 문서 양식 (`docs/qa.md`) |
| `skills/story-qa/references/risks.md` | 돈·이관·인증·외부 연동·저장 데이터: AI가 고르지 않고 사람이 정할 것 |

## 설치

Claude Code:

```sh
claude plugin marketplace add <이 저장소 경로 또는 URL>
claude plugin install story-qa-kit@story-qa
```

새 세션에서 `/story-qa <요청>`으로 시작해요.

## 저장소마다 할 일

`docs/qa.md`를 [QA-ENV.md](skills/story-qa/assets/QA-ENV.md) 양식으로 둬요. 없으면 첫 실행 때 AI가 README와 스크립트로 초안을 만들고 모르는 칸을 물어요.

- 운영 환경은 QA에 쓰지 않아요.
- `Auto-merge`는 기본 `off`예요. 사람이 `on`으로 바꿔야 AI가 로컬 QA 통과 뒤 dev 브랜치로 PR을 머지해요. main에는 절대 머지하지 않아요.
- dev QA가 실패하면 AI는 고치지 않고 보고와 revert PR까지만 해요. 되돌릴지는 사람이 정해요.
