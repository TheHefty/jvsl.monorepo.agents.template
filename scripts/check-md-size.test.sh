#!/usr/bin/env bash
# Exercises check-md-size.sh — the real script, in throwaway git repositories,
# not a reimplementation of its logic.
#
# The three cases are the three ways this check fails in a way nobody notices:
# it passes when it should not, it fails on the one file that is meant to be
# exempt (which trains everyone to use --no-verify), and it silently skips a
# path it could not parse.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT="$HERE/check-md-size.sh"

failures=0
check() {
    if [ "$2" = "$3" ]; then
        echo "ok   $1"
    else
        echo "FAIL $1"
        echo "     expected: $3"
        echo "     got:      $2"
        failures=$((failures + 1))
    fi
}

# A repository with one tracked file of $2 bytes at path $1.
make_repo() {
    local dir
    dir=$(mktemp -d)
    git -C "$dir" init -q
    git -C "$dir" config user.email t@t
    git -C "$dir" config user.name t
    printf '%s' "$dir"
}

big() { head -c "$1" /dev/zero | tr '\0' 'x'; }

run() { ( cd "$1" && bash "$SCRIPT" >/dev/null 2>&1 ); echo $?; }

# 1. An oversized file must fail. Without this the whole thing is decoration.
d=$(make_repo)
big 51201 > "$d/big.md"
git -C "$d" add -A
check "oversized .md fails" "$(run "$d")" 1
rm -rf "$d"

# ...and one just under the limit must not.
d=$(make_repo)
big 51200 > "$d/edge.md"
git -C "$d" add -A
check "exactly at the limit passes" "$(run "$d")" 0
rm -rf "$d"

# 2. CHANGELOG.md is exempt however large it gets.
d=$(make_repo)
big 200000 > "$d/CHANGELOG.md"
git -C "$d" add -A
check "oversized CHANGELOG.md is exempt" "$(run "$d")" 0
rm -rf "$d"

# ...and an untracked file is not the repository's problem. This is also what
# keeps a submodule's own files out of scope.
d=$(make_repo)
big 51201 > "$d/untracked.md"
check "untracked oversized .md is ignored" "$(run "$d")" 0
rm -rf "$d"

# 3. A path with a space must still be checked, not skipped by word splitting.
d=$(make_repo)
big 51201 > "$d/a file with spaces.md"
git -C "$d" add -A
check "oversized path containing spaces is caught" "$(run "$d")" 1
rm -rf "$d"

# A non-Markdown file of any size is none of this script's business.
d=$(make_repo)
big 200000 > "$d/blob.bin"
git -C "$d" add -A
check "oversized non-markdown file is ignored" "$(run "$d")" 0
rm -rf "$d"

if [ "$failures" -gt 0 ]; then
    echo "$failures check(s) failed"
    exit 1
fi
echo "all checks passed"
