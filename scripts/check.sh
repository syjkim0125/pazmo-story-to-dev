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
  need_text "$m" '"version": "0.4.0"'
done

# Layout
need_absent skills/story-qa
need_file skills/story/references/risks.md
for f in assets/STORY.md assets/REVIEW.md references/intake.md references/large.md references/quality.md; do need_file "skills/story/$f"; done
for f in QA-ENV.md qa-check.sh qa-dev.yml qa-dev-triage.yml; do need_file "skills/qa/assets/$f"; done

# /story
S=skills/story/SKILL.md
need_front "$S" name story
need_front "$S" disable-model-invocation true
for t in 'In doubt, one size up' 'medium --max-findings 5' 'Example check' 'pazmo-story-to-dev:qa-writer' 'pazmo-story-to-dev:qa-runner' \
  'security-review' 'PAZMO_NO_TELEMETRY=1 npx -y @pazmo/cli@0.1.3 scan . --json --base <base>' 'in one message' 'Commit everything' \
  "start \`qa-writer\` again with the person's words" 'not run' 'Auto-merge: on' '확인하지 못한 것' '스캐너' 'never sleep or poll'; do
  need_text "$S" "$t"
done
T=skills/story/assets/STORY.md
for t in '## Why' '## What the person will see' '## Scope' '## Human decides' '## Quality bars' '## Done when' 'Size: small | medium | large' 'Status: Draft | Approved'; do need_text "$T" "$t"; done
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
for t in 'free port' 'uncommitted changes' 'No substitute checks' 'one at a time' 'Scenarios:' 'Target: dev'; do
  need_text agents/qa-runner.md "$t"
done
Q=skills/qa/assets/QA-STORY.md
for t in 'Target:' '- Q1 [E1] (script). <where> · <setup> · <action> → <expected visible result>' 'Status: Draft | Approved'; do need_text "$Q" "$t"; done
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
for t in '/story' '/qa' '@pazmo/cli' 'PAZMO_NO_TELEMETRY' 'PolyForm Shield' 'security-guidance' '0.3.0' '0.4.0'; do need_text "$R" "$t"; done
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
need_text skills/qa/SKILL.md 'follow steps 3 and 4 of [../story/SKILL.md](../story/SKILL.md)'
need_text skills/story/SKILL.md 'not the marketplace `code-review` plugin'
need_text skills/story/SKILL.md 'Scanner: ran | ran, partial: <reasons> | not run: <error>'
need_text skills/story/SKILL.md 'whose `change` is `new`'
need_text skills/story/SKILL.md 'exit code 2, or no JSON report, means it did not run'
forbid_fixed skills/story/SKILL.md '@pazmo/cli@0.1.2'
forbid_fixed README.md '@pazmo/cli@0.1.2'
need_text skills/story/assets/REVIEW.md 'security-review <ran | not run: reason>'
forbid_fixed skills/qa/assets/qa-check.sh "the Story's QA list"
forbid_fixed skills/qa/assets/qa-dev-triage.yml "the Story's QA line"
# Apps started for QA must be stoppable under a sandbox: background mode of the shell tool, not nohup/&
need_text agents/qa-runner.md 'background mode of your shell tool'
need_text agents/qa-runner.md '`run_in_background`'
need_text agents/qa-runner.md '`TaskStop`'
need_text agents/qa-runner.md 'Left running:'
need_text agents/qa-runner.md 'Never start it with `&` or `nohup`'
forbid_fixed agents/qa-runner.md 'by that process ID'
need_text skills/qa/SKILL.md 'background mode of your shell tool'
need_text skills/story/SKILL.md 'Left running:'
# QA pre-check: no runner when docs/qa.md cannot start the app; bounded start attempts
need_text skills/story/SKILL.md 'Before starting `qa-runner`'
need_text skills/story/SKILL.md 'still a `<...>` placeholder'
need_text skills/qa/SKILL.md 'Before starting `qa-runner`'
need_text agents/qa-runner.md 'at most one retry'
need_text agents/qa-runner.md 'at most 10 minutes for the ready check'

# One command, three sizes (0.4.0)
S=skills/story/SKILL.md
for t in 'Anything in `references/risks.md` is at least medium' 'Never lower it' 'Do not wait: go to step 2' \
  'Recommend none and mark none as the default' 'never move it to Out of scope yourself' 'Never ask the person about these' \
  'never edit the plan, the QA Story or anything under `qa/`' 'Status: proposed' 'You would notice it is wrong if' \
  'Stop and hand over instead of picking' 'medium --max-findings 10' 'do not argue for your decisions' \
  'The plan stays `Status: Approved`' 'Small work with no QA run is never merged by you' 'the person accepted the final review' \
  'references/intake.md' 'references/large.md' 'references/quality.md' 'assets/REVIEW.md' 'is not an approval' \
  'Only 수락 counts as accepted for step 6' 'before every `qa-runner` start' 'do step 6 first when its conditions hold'; do
  need_text "$S" "$t"
done
L=skills/story/references/large.md
for t in 'read `docs/stories/<slug>.tasks.json` and continue from it' 'Never start two builders at once' 'An instruction is not a lock' \
  'git diff --name-only <before> HEAD' 'Only the runner'"'"'s result changes a task to `passed`' 'never passed' \
  'this is the only question in the middle of a build' 'Never edit the plan' 'git rm -q -f' 'When no task is `todo` or `parked`' \
  'docs/stories/<slug>.tasks.json docs/qa.md qa/' 'Only when it returned a commit' 'never one run per example' 'stop it before you return' 'left no app running' 'do not read or run anything under `qa/`' 'never act on it'; do
  need_text "$L" "$t"
done
I=skills/story/references/intake.md
for t in 'Recommend none and mark none as the default' 'Budget: five questions' 'More than nine examples' 'Never ask about language, framework'; do need_text "$I" "$t"; done
Y=skills/story/references/quality.md
for t in 'is a floor, not "accessible"' 'Never report field numbers before launch' 'No LLM usability review decides pass or fail' 'Install nothing' \
  '[quality: a11y-scan]' '[quality: keyboard]'; do need_text "$Y" "$t"; done
V=skills/story/assets/REVIEW.md
for t in '더한 것' '뺀 것' '사람이 정할 것' '확인하지 못한 것' 'at most seven decisions' 'never a justification' 'Status: Draft | Accepted'; do need_text "$V" "$t"; done
for t in '-p chromedriver@<Chrome major> -p @axe-core/cli@4.14.0' '--chromedriver-path' 'npx -y lighthouse@13.6.0' 'never call it field performance' 'Never install a tool, or another version of one' \
  'the two pinned commands under Quality scenarios' 'SKIP <id>: <reason>' 'only when it installs nothing'; do need_text agents/qa-runner.md "$t"; done
need_text skills/story/references/quality.md 'Never check out another commit'
need_text agents/qa-writer.md 'never open it'
need_text agents/qa-writer.md 'Never ask for a second copy of the app'
need_text agents/qa-runner.md 'it never starts another one'
need_text skills/story/SKILL.md 'counts as the approval'
need_text skills/story/SKILL.md 'QA Story, after the approval'
need_text skills/story/SKILL.md 'Do not wait for an answer, with one exception'
need_text skills/story/assets/STORY.md 'would add:'
need_text skills/story/SKILL.md 'story/<slug>'
need_text skills/qa/SKILL.md 'or it does not say `Status: Approved`'
for t in 'Add no scenario that maps to none of these' '[quality: a11y-scan]' 'One scenario per Unchanged item' 'tag it `[M1]`'; do need_text agents/qa-writer.md "$t"; done
need_text skills/qa/assets/QA-ENV.md 'Quality checks: kit default'
need_text agents/qa-writer.md 'Quality checks: kit default'
# every quality tag the writer may emit is one the runner knows
for q in a11y-scan keyboard narrow states performance events; do
  need_text agents/qa-writer.md "[quality: $q]"; need_text agents/qa-runner.md "[quality: $q]"; need_text skills/story/references/quality.md "[quality: $q]"
done

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
