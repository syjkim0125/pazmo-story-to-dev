#!/usr/bin/env bash
# QA checks for docs/stories/<slug>.qa.md. Copy to qa/<slug>.sh and replace the example checks.
# Run: BASE_URL=http://localhost:3000 bash qa/<slug>.sh
# Prints PASS/FAIL per scenario id; exits 1 when any check fails.
set -u
BASE_URL="${BASE_URL:?set BASE_URL, e.g. BASE_URL=http://localhost:3000}"
failed=0

fetch() { curl -sS --max-time 15 -w '\n%{http_code}' "$BASE_URL$1"; }

# expect <id> <path> <status> <text that must appear>
expect() {
  local out code body
  out=$(fetch "$2") || { echo "FAIL $1 $2: request failed"; failed=1; return; }
  code=${out##*$'\n'}; body=${out%$'\n'*}
  if [ "$code" != "$3" ]; then echo "FAIL $1 $2: status $code, expected $3"; failed=1
  elif ! grep -qF -- "$4" <<<"$body"; then echo "FAIL $1 $2: missing \"$4\""; failed=1
  else echo "PASS $1 $2: $(grep -oF -- "$4" <<<"$body" | head -1)"; fi
}

# reject <id> <path> <status> <text that must not appear>
reject() {
  local out code body
  out=$(fetch "$2") || { echo "FAIL $1 $2: request failed"; failed=1; return; }
  code=${out##*$'\n'}; body=${out%$'\n'*}
  if [ "$code" != "$3" ]; then echo "FAIL $1 $2: status $code, expected $3"; failed=1
  elif grep -qF -- "$4" <<<"$body"; then echo "FAIL $1 $2: shows \"$4\""; failed=1
  else echo "PASS $1 $2: no \"$4\""; fi
}

# One line per script scenario; the id matches the QA Story's scenario id.
expect Q1 "/orders?user=u1" 200 "New notice text"
reject Q3 "/orders?user=u2" 200 "New notice text"

exit $failed
