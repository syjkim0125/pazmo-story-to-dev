#!/usr/bin/env bash
# Structure and rule checks for the plugin. Run from anywhere: bash scripts/check.sh
set -u
cd "$(dirname "$0")/.."

fails=0
checks=0
fail() { echo "FAIL: $*"; fails=$((fails + 1)); }

need_file() { checks=$((checks + 1)); [ -f "$1" ] || fail "missing file $1"; }
need_absent() { checks=$((checks + 1)); [ ! -e "$1" ] || fail "should not exist: $1"; }
need_text() { checks=$((checks + 1)); [ -f "$1" ] && grep -qF -- "$2" "$1" || fail "$1 lacks: $2"; }
forbid_fixed() { checks=$((checks + 1)); [ -f "$1" ] && ! grep -qF -- "$2" "$1" || fail "$1 should not contain: $2"; }
frontmatter() { awk -v k="$2" 'NR==1&&$0!="---"{exit} NR>1&&$0=="---"{exit} NR>1{ if (index($0, k": ")==1) { print substr($0, length(k)+3); exit } }' "$1" 2>/dev/null; }
need_front() { checks=$((checks + 1)); [ "$(frontmatter "$1" "$2")" = "$3" ] || fail "$1 frontmatter $2 should be '$3' (got '$(frontmatter "$1" "$2")')"; }

# Manifests
for m in .claude-plugin/plugin.json .claude-plugin/marketplace.json .codex-plugin/plugin.json; do
  checks=$((checks + 1))
  python3 -m json.tool "$m" >/dev/null 2>&1 || fail "$m is not valid JSON"
  need_text "$m" '"version": "0.3.0"'
done

# Layout
need_absent skills/story-qa
need_file skills/story/references/risks.md
for f in QA-ENV.md qa-check.sh qa-dev.yml qa-dev-triage.yml; do need_file "skills/qa/assets/$f"; done

# /story
S=skills/story/SKILL.md
need_front "$S" name story
need_front "$S" disable-model-invocation true
for t in 'Small change' 'medium --max-findings 5' 'MUST check' 'pazmo-story-to-dev:qa-writer' 'pazmo-story-to-dev:qa-runner' \
  'security-review' 'PAZMO_NO_TELEMETRY=1 npx -y @pazmo/cli@0.1.2 scan . --json' 'in one message' 'Commit everything' \
  "start \`qa-writer\` again with the person's words" 'not run' 'Auto-merge: on' '확인하지 못한 것' '스캐너' 'never sleep or poll'; do
  need_text "$S" "$t"
done
T=skills/story/assets/STORY.md
for t in '## Goal' '## Decisions' '## Human decides' '## MUST' '## OUT' 'Status: Draft | Approved'; do need_text "$T" "$t"; done
forbid_fixed "$T" '## QA'

# QA agents
for a in qa-writer qa-runner; do
  A=agents/$a.md
  need_front "$A" name "$a"
  need_front "$A" omitClaudeMd true
  need_text "$A" 'never read source code, tests, the diff'
  need_text "$A" 'Open only these files'
done
need_text agents/qa-writer.md 'docs/stories/<slug>.qa.md'
checks=$((checks + 1)); frontmatter agents/qa-writer.md tools | grep -q Bash && fail "qa-writer must not have Bash"
for t in 'free port' 'uncommitted changes' 'No substitute checks' 'one at a time' 'stop the process it started' 'Scenarios:' 'Target: dev'; do
  need_text agents/qa-runner.md "$t"
done
Q=skills/qa/assets/QA-STORY.md
for t in 'Target:' '- Q1 [M1] (script). <where> · <setup> · <action> → <expected visible result>' 'Status: Draft | Approved'; do need_text "$Q" "$t"; done
E=skills/qa/assets/QA-ENV.md
for t in 'Target: local | preview' 'Setup:' 'Preview:' 'Database: in-memory | per-run container | shared'; do need_text "$E" "$t"; done

# /qa
Q=skills/qa/SKILL.md
need_front "$Q" name qa
need_front "$Q" disable-model-invocation true
checks=$((checks + 1)); frontmatter "$Q" argument-hint | grep -qF '[local|preview|dev]' || fail "$Q argument-hint lacks [local|preview|dev]"
for t in 'Status: Approved' 'skips `qa-writer`' 'reuses the saved scripts' 'never read source code' 'pazmo-story-to-dev:qa-runner' 'never sleep or poll'; do
  need_text "$Q" "$t"
done

# README
R=README.md
for t in '/story' '/qa' '@pazmo/cli' 'PAZMO_NO_TELEMETRY' 'PolyForm Shield' 'security-guidance' '0.3.0'; do need_text "$R" "$t"; done
checks=$((checks + 1)); [ "$(grep -c '/story-qa' "$R")" -le 1 ] || fail "$R mentions /story-qa outside the change note"

# Final-review fixes
need_text skills/story/SKILL.md 'Fix the app, never the QA Story or anything under `qa/`'
need_text skills/story/SKILL.md 'answers to gaps go in the `Correction:` line'
need_text agents/qa-writer.md 'also update the `docs/qa.md` fields it answers'
need_text agents/qa-runner.md "Target: the prompt's \`Target:\` line, else the QA Story's \`Target:\`, else \`local\`"
need_text skills/qa/SKILL.md 'always pass `Target: <target>`'
need_text agents/qa-runner.md 'within 30 minutes'
need_text skills/qa/SKILL.md 'only when `docs/qa.md` turns preview on'
need_text agents/qa-runner.md 'Write only under `qa/`'
need_text agents/qa-runner.md 'start no subagents'
need_text agents/qa-runner.md 'temp directory outside the repository'
need_text skills/story/SKILL.md 'if the error is in code this branch changed'
need_text skills/story/SKILL.md 'On `Not run: uncommitted changes`'
need_text skills/qa/SKILL.md 'follow steps 3 to 5 of [../story/SKILL.md](../story/SKILL.md)'
need_text skills/story/SKILL.md 'not the marketplace `code-review` plugin'
need_text skills/story/SKILL.md 'Scanner: ran | not run: <error>'
need_text skills/story/SKILL.md 'security-review <ran | not run: reason>'
forbid_fixed skills/qa/assets/qa-check.sh "the Story's QA list"
forbid_fixed skills/qa/assets/qa-dev-triage.yml "the Story's QA line"

# Public repository: no internal names, no measurement claims
files=$(git ls-files --cached --others --exclude-standard | grep -v '^scripts/check.sh$')
if [ -f .deny-list ]; then
  while IFS= read -r word; do
    [ -z "$word" ] && continue
    checks=$((checks + 1))
    hits=$(printf '%s\n' "$files" | while IFS= read -r f; do [ -f "$f" ] && grep -qiF -- "$word" "$f" && echo "$f"; done)
    [ -z "$hits" ] || fail "deny-listed name in: $(echo $hits)"
  done < .deny-list
else
  echo "WARN: no .deny-list"
fi
checks=$((checks + 1))
hits=$(printf '%s\n' "$files" | while IFS= read -r f; do [ -f "$f" ] && grep -qiE '[0-9]+(\.[0-9]+)?x (slower|faster|longer)' "$f" && echo "$f"; done)
[ -z "$hits" ] || fail "measurement claim in: $(echo $hits)"

if [ "$fails" -gt 0 ]; then echo "$fails failed of $checks checks"; exit 1; fi
echo "OK $checks checks"
