# pazmo-story-to-dev

AI에게 일을 맡길 때 사람이 확인하는 건 두 가지예요. **내 요청을 맞게 이해했나**, **실제로 띄운 앱에서 그렇게 동작하나.** 그 사이는 Claude가 원래 하던 대로 해요.

```
Story + QA 목록 → 사람 승인 → QA 스크립트(실패 확인) → 구현(순정, 스크립트 통과) → 독립 리뷰(백그라운드) ∥ 로컬 QA
  → dev 머지(켰을 때만) → dev QA → 사람에게 보고
```

비용과 시간을 아끼는 규칙:

- 승인된 QA 시나리오 중 HTTP 응답·CLI 출력·브라우저 테스트로 확인되는 건 구현 전에 `qa/<slug>.sh` 같은 스크립트로 만들어요. 로컬 QA도 dev QA도 같은 스크립트를 주소만 바꿔 돌려요. dev에서는 CI가 돌리니 모델 토큰이 들지 않고, 실패했을 때만 Claude가 원인을 봐요.
- 리뷰는 Claude Code에 내장된 `code-review` 스킬을 강도를 정해서 불러요. 기본 `medium`, 돈·인증 같은 사람 결정 항목이 있으면 `high`, 지적은 5개까지.
- 리뷰는 읽기만 하니 백그라운드로 돌리고, 그동안 로컬 QA를 해요.
- QA는 HTML이나 API 응답으로 확인되면 `curl`, JS나 클릭이 필요할 때만 브라우저를 써요. 스크린샷은 화면 모양이 바뀌는 시나리오에만 찍어요.
- 고친 뒤에는 고친 코드가 닿는 시나리오만 다시 돌려요.
- 작은 변경(해석이 갈리는 곳이 없고, 한 모듈 안에서 끝나고, 돈·인증 같은 위험 영역을 건드리지 않음)은 Story 파일 없이 채팅으로 바뀌는 점과 QA 1~3줄만 보여 주고 승인받아요. 승인 절차는 그대로예요.

## 왜 이렇게 가볍나

이전 [ai-workflow-kit](https://github.com/syjkim0125/ai-workflow-kit)은 단계 순서, 모델 나눠 쓰기, 그래프 실행기로 모델을 이끌었어요. 요즘 모델은 그런 안내 없이도 잘 구현해요. 모델이 아무리 좋아져도 대신할 수 없는 건 두 가지예요. 요청이 두 가지로 읽힐 때 무엇을 뜻했는지 아는 사람, 그리고 실제 앱에서 그렇게 동작하는지 보여 주는 증거. 그래서 그 두 가지만 남겼어요.

## 들어 있는 것

| 파일 | 내용 |
|---|---|
| `skills/story-qa/SKILL.md` | 여섯 단계 |
| `skills/story-qa/assets/STORY.md` | Story 양식: 목표, 해석이 갈리는 곳, MUST/OUT, QA 시나리오 |
| `skills/story-qa/assets/QA-ENV.md` | 저장소마다 하나 두는 QA 환경 문서 양식 (`docs/qa.md`) |
| `skills/story-qa/assets/qa-check.sh` | HTTP로 확인하는 QA 스크립트 예시 (`BASE_URL`만 바꿔 로컬·dev에서 실행) |
| `skills/story-qa/assets/qa-dev.yml` | dev 배포를 기다렸다가 QA 스크립트를 돌리고, 실패하면 revert PR을 여는 GitHub Actions 양식 |
| `skills/story-qa/assets/qa-dev-triage.yml` | (선택) dev QA가 실패했을 때만 Claude가 원인을 revert PR에 남기는 양식 |
| `skills/story-qa/references/risks.md` | 돈·이관·인증·외부 연동·저장 데이터: AI가 고르지 않고 사람이 정할 것 |

## 설치

Claude Code:

```sh
claude plugin marketplace add syjkim0125/pazmo-story-to-dev
claude plugin install pazmo-story-to-dev@pazmo-story-to-dev
```

새 세션에서 `/story-qa <요청>`으로 시작해요. 다른 플러그인과 이름이 겹치면 `/pazmo-story-to-dev:story-qa <요청>`을 써요.

## 저장소마다 할 일

`docs/qa.md`를 [QA-ENV.md](skills/story-qa/assets/QA-ENV.md) 양식으로 둬요. 없으면 첫 실행 때 AI가 README와 스크립트로 초안을 만들고 모르는 칸을 물어요.

- 운영 환경은 QA에 쓰지 않아요.
- `Auto-merge`는 기본 `off`예요. 사람이 `on`으로 바꿔야 AI가 로컬 QA 통과 뒤 dev 브랜치로 PR을 머지해요. main에는 절대 머지하지 않아요.
- dev QA가 실패하면 AI는 고치지 않고 보고와 revert PR까지만 해요. 되돌릴지는 사람이 정해요.
- dev QA를 CI로 돌리려면 `qa-dev.yml`을 `.github/workflows/`에 복사하고 저장소 변수 `DEV_BASE_URL`, `DEV_VERSION_PATH`(배포된 커밋이 보이는 경로, 예: `/version`)를 정해요. 실패 원인 분석까지 원하면 `qa-dev-triage.yml`과 `ANTHROPIC_API_KEY` 시크릿을 더해요.
