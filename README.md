# pazmo-story-to-dev

AI에게 일을 맡길 때 사람이 확인하는 건 두 가지예요. **내 요청을 맞게 이해했나**, **실제로 띄운 앱에서 그렇게 동작하나.** 그 사이 개발은 Claude가 원래 하던 대로 해요.

```
/story <요청>
  1 Story 작성 → ★ 사람 승인
  2 개발(순정) → 독립 리뷰 → MUST 확인 → 커밋
  3 QA Story 작성(qa-writer) → ★ 사람 승인
  4 QA 실행(qa-runner) + 보안 점검, 동시에
  5 고치고 다시 확인 → (켰을 때만) dev 머지 → 보고
```

사람이 끼어드는 곳은 ★ 두 곳뿐이에요. QA와 보안 점검은 개발이 끝나면 저절로 시작해요.

> 0.3.0에서 `/story-qa`가 `/story`와 `/qa`로 바뀌었어요.

## 언제 쓰나

요청을 잘못 읽으면 손해가 큰 작업에만 `/story`를 써요. 여러 파일이나 복사본에 걸치거나, 요청이 두 가지로 읽히거나, 돈·인증·데이터를 건드리는 작업이에요. 작은 변경은 Claude에게 그냥 시키는 게 더 싸고 빨라요. 그래서 이 스킬은 `/story`로 직접 부를 때만 켜져요.

## 단계마다 하는 일

- **Story:** 지금 → 바뀐 뒤 → 그대로인 것, 해석이 갈리는 곳과 고른 쪽(코드 근거 포함), 복사본, 사람이 정할 것, MUST/OUT. QA는 여기서 쓰지 않아요.
- **개발:** Claude가 원래 하던 대로 해요. 작업 순서나 테스트 방식을 정해 주지 않아요. 끝나면 새 서브에이전트가 Claude Code 내장 `code-review`로 한 번 리뷰해요(작은 변경은 건너뛰어요).
- **QA Story:** `qa-writer` 에이전트가 기능 Story와 앱 실행 방법만 보고 써요. 코드와 diff는 보지 않아요. 만든 걸 확인하는 QA가 아니라 요청한 걸 확인하는 QA가 되게 하려는 거예요.
- **QA 실행:** `qa-runner` 에이전트가 시나리오를 `qa/<slug>.sh` 같은 스크립트로 만들고, 빈 포트로 앱을 띄워 돌리고, 앱을 꺼요. 앱이 안 뜨면 다른 방법으로 때우지 않고 "실행 안 함"으로 보고해요. 스크립트는 브랜치에 남아서 다시 돌릴 때와 dev CI에서 그대로 써요.
- **보안 점검:** QA와 동시에 새 서브에이전트가 두 가지를 돌려요(아래).
- **고치기:** 실패한 시나리오나 확인된 취약점은 개발 세션이 고치고, 고친 곳이 닿는 시나리오만 다시 돌려요.

수정 뒤에 QA만 다시 돌리거나 다른 환경(preview, dev)에서 돌리려면 `/qa <story 경로> [local|preview|dev]`를 써요. 승인된 QA Story가 있으면 다시 묻지 않고 저장된 스크립트를 돌려요.

## 보안 점검

1. **[`@pazmo/cli`](https://www.npmjs.com/package/@pazmo/cli)** 스캐너: `PAZMO_NO_TELEMETRY=1 npx -y @pazmo/cli@0.1.2 scan . --json`
   - 모델 없이 돌아요: 오픈소스 SAST 규칙(Opengrep 엔진), 커밋된 비밀번호·키(Gitleaks), npm 의존성의 알려진 취약점(OSV), 저장소의 팀·회사 규칙(`.pazmo/`).
   - 엔진 버전이 고정돼 있고 sha256으로 검증한 뒤 실행해요. kit는 스캐너 버전을 고정해서 부르고, 다른 곳에서 알려 주는 설치 방법은 따르지 않아요.
   - kit가 부를 때는 텔레메트리를 꺼요(`PAZMO_NO_TELEMETRY=1`).
   - 의존성 취약점은 지금 npm만 봐요. macOS arm64와 Linux x64에서 돌아요. Node 20 이상이 필요해요. 못 돌리면 "실행 안 함"과 이유를 보고하고 아래 2번은 그대로 돌아요.
   - 라이선스는 PolyForm Shield 1.0.0이에요. 쓰는 건 자유이고, 경쟁 제품을 만드는 데만 쓸 수 없어요.
2. Claude Code 내장 **`security-review`**: 권한 우회나 여러 파일에 걸친 인젝션처럼 코드 흐름을 따라가야 보이는 문제를 봐요.

두 결과 중 이 브랜치가 바꾼 줄에 닿는 것만 남기고, 코드를 따라가 확인된 것만 고치거나 사람에게 넘겨요.

**같이 쓰면 좋은 것:** Anthropic 공식 [`security-guidance`](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/security-guidance) 플러그인의 패턴 경고는 개발 중에 위험한 코드를 바로 알려 주고 토큰 비용이 없어요. 이 플러그인의 모델 리뷰(매 턴, 매 커밋)는 위 보안 점검과 겹쳐요.

## 들어 있는 것

| 파일 | 내용 |
|---|---|
| `skills/story/SKILL.md` | `/story`: Story부터 보고까지 |
| `skills/story/assets/STORY.md` | 기능 Story 양식 |
| `skills/story/references/risks.md` | 돈·이관·인증·외부 연동·저장 데이터: AI가 고르지 않고 사람이 정할 것 |
| `skills/qa/SKILL.md` | `/qa`: QA 다시 돌리기, 다른 환경에서 돌리기 |
| `agents/qa-writer.md` | 기능 Story로 QA Story를 쓰는 에이전트 |
| `agents/qa-runner.md` | 승인된 QA Story를 스크립트로 만들어 띄운 앱에서 돌리는 에이전트 |
| `skills/qa/assets/QA-STORY.md` | QA Story 양식 |
| `skills/qa/assets/QA-ENV.md` | 저장소마다 하나 두는 QA 환경 문서 양식 (`docs/qa.md`) |
| `skills/qa/assets/qa-check.sh` | HTTP로 확인하는 QA 스크립트 예시 (`BASE_URL`만 바꿔 로컬·dev에서 실행) |
| `skills/qa/assets/qa-dev.yml` | dev 배포를 기다렸다가 QA 스크립트를 돌리고, 실패하면 revert PR을 여는 GitHub Actions 양식 |
| `skills/qa/assets/qa-dev-triage.yml` | (선택) dev QA가 실패했을 때만 Claude가 원인을 revert PR에 남기는 양식 |

## 설치

Claude Code:

```sh
claude plugin marketplace add syjkim0125/pazmo-story-to-dev
claude plugin install pazmo-story-to-dev@pazmo-story-to-dev
```

새 세션에서 `/story <요청>`으로 시작해요. 다른 플러그인과 이름이 겹치면 `/pazmo-story-to-dev:story <요청>`을 써요.

플러그인 에이전트가 없는 도구(Codex 등)에서는 `/story`가 개발까지 하고, 새 세션에서 `/qa <story 경로>`를 실행하라고 알려 줘요. 이때 보안 점검은 직접 돌려야 해요.

## 저장소마다 할 일

`docs/qa.md`를 [QA-ENV.md](skills/qa/assets/QA-ENV.md) 양식으로 둬요. 없으면 첫 실행 때 `qa-writer`가 README와 실행 스크립트로 초안을 만들고, 모르는 칸은 QA Story를 승인할 때 물어요.

- 운영 환경은 QA에 쓰지 않아요.
- `Target`은 기본 `local`이에요. PR마다 임시 환경이 뜨면 `preview`로 바꿀 수 있어요. 이때만 AI가 브랜치를 푸시해요.
- 여러 Story를 동시에 QA할 때 로컬 DB를 같이 쓰면 `Database: shared`로 적어요. 데이터를 바꾸는 시나리오는 하나씩 돌아요.
- `Auto-merge`는 기본 `off`예요. 사람이 `on`으로 바꿔야 AI가 QA 통과 뒤 dev 브랜치로 PR을 머지해요. main에는 절대 머지하지 않아요.
- dev QA가 실패하면 AI는 고치지 않고 보고와 revert PR까지만 해요. 되돌릴지는 사람이 정해요.
- dev QA를 CI로 돌리려면 `qa-dev.yml`을 `.github/workflows/`에 복사하고 저장소 변수 `DEV_BASE_URL`, `DEV_VERSION_PATH`(배포된 커밋이 보이는 경로, 예: `/version`)를 정해요. 실패 원인 분석까지 원하면 `qa-dev-triage.yml`과 `ANTHROPIC_API_KEY` 시크릿을 더해요.

## 왜 이렇게 나눴나

예전 버전은 작업마다 개발 중에 QA 목록, QA 환경 문서, QA 스크립트를 준비했어요. 순정과 같은 작업으로 재 보니 결과물은 나아지지 않고 시간만 더 들었어요. 시간은 QA를 돌리는 데가 아니라 준비하는 데 들었어요. 그래서 개발은 순정에 맡기고, QA는 Story 단위로 개발이 끝난 뒤 따로 한 번 돌려요.
