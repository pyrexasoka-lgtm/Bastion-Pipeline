#!/usr/bin/env bash
# Shared commit policy used by the commit-msg hook and by CI (scripts/check-authorship.sh).
# Source this file; it defines functions only.

policy_root() { git rev-parse --show-toplevel; }

# Prints one "name<TAB>email" line per identity in .github/allowed-author ("Name <email>").
# The first identity is the current one; later lines keep older commits valid.
allowed_identities() {
  grep -Ev '^\s*(#|$)' "$(policy_root)/.github/allowed-author" | tr -d '\r' \
    | sed -E 's/^(.*) <([^>]+)>.*$/\1\t\2/'
}

# Conventional Commit title, plus git-generated Merge and Revert titles.
TITLE_RE='^((feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert|security)(\([a-z0-9._/-]+\))?!?: [^[:space:]].{0,70}|Merge .+|Revert ".+")$'

# check_message <file>: rejects trailers and bad titles. Returns 1 on violation.
check_message() {
  local file="$1" title
  if grep -Eiq '^\s*Co-authored-by:' "$file"; then
    echo "Rejected: Co-authored-by trailers are not allowed." >&2; return 1
  fi
  if grep -Eiq '^\s*(Generated-by|Assisted-by):|^\s*Signed-off-by:.*(\[bot\]|\bbot\b)' "$file"; then
    echo "Rejected: tool attribution trailers are not allowed." >&2; return 1
  fi
  title="$(grep -Ev '^\s*(#|$)' "$file" | head -n1 | tr -d '\r')"
  if [[ ! "$title" =~ $TITLE_RE ]]; then
    echo "Rejected: title must be a Conventional Commit, e.g. 'fix(app): reject empty titles' (max 72 chars). Got: '$title'" >&2
    return 1
  fi
}

# check_identity <name> <email>: passes when the pair matches any identity in .github/allowed-author.
check_identity() {
  local name email
  while IFS=$'\t' read -r name email; do
    [[ "$1" == "$name" && "$2" == "$email" ]] && return 0
  done < <(allowed_identities)
  echo "Rejected: author '$1' with this email is not listed in .github/allowed-author." >&2
  return 1
}
