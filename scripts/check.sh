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
