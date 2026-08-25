#!/usr/bin/env bash
# Fails when a tracked Markdown file is larger than the limit in docs/RULES.md.
#
# CHANGELOG.md is exempt by design. It only grows, it is written by
# release-please rather than by a person, and blocking a release commit on it
# would teach everyone to reach for --no-verify — which disables every other
# hook along with this one.
#
# Only git-tracked files are examined. That is what keeps the submodule at
# .code-server/ out of scope without naming it: a submodule appears to the
# parent as a gitlink, not as files. It also keeps ignored and untracked files
# out, which is right — this is a rule about what the repository carries.
set -euo pipefail

LIMIT_KIB=50
LIMIT=$((LIMIT_KIB * 1024))

cd "$(git rev-parse --show-toplevel)"

failures=0

# -z and read -d '' rather than a for-loop over $(...): a path containing a
# space or a newline is a valid path, and word splitting turns it into a file
# that is silently never checked.
while IFS= read -r -d '' file; do
    case "$file" in
        *.md) ;;
        *) continue ;;
    esac
    [ "$(basename "$file")" = "CHANGELOG.md" ] && continue

    size=$(wc -c < "$file" | tr -d '[:space:]')
    if [ "$size" -gt "$LIMIT" ]; then
        printf 'too large: %s — %s bytes, limit %s\n' "$file" "$size" "$LIMIT" >&2
        failures=$((failures + 1))
    fi
done < <(git ls-files -z)

if [ "$failures" -gt 0 ]; then
    printf '\n%d Markdown file(s) over %d KiB. Split the document, or move the detail\ninto a linked one — see docs/RULES.md.\n' \
        "$failures" "$LIMIT_KIB" >&2
    exit 1
fi
