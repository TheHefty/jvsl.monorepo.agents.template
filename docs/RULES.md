# Rules

Ground rules for a monorepo built on this template. They are short on purpose: each one exists
because breaking it has already cost something, and the reason is given so you can tell when a rule
stops applying.

## Branches and review

- **The default branch is protected. There is no direct push to it** — every change goes through a
  pull request, including a one-line doc fix and a submodule bump. The rule applies to
  administrators too; force-pushes and branch deletion are blocked.
- **Approvals are a project's own call**, but the PR is not optional even when you are the only
  maintainer. It is what gives a change a reviewable diff and a place to say why.
- **Head branches are deleted on merge.** Don't rely on a merged branch still existing — see the
  submodule rule below for what that costs when you do.

## Commits and releases

- **Conventional commits are load-bearing, not decoration.** Releases are cut by release-please
  from the commit history: only `feat` and `fix` reach the changelog, and a release is proposed
  only when one of them lands. A `chore` that should have been a `fix` is a release that never
  happens.
- **Write the commit message for the person who will read it during an incident**, not for the
  diff. The diff already says what changed; the message is where why belongs.

## The template submodule

- **Bump `.code-server/` to a tag, never to a bare commit.** A commit reachable only from a branch
  becomes unreachable once that branch is squash-merged and deleted, and then every fresh clone
  fails its `git submodule update`. Tags are permanent; branches are not.
- **Read the template's `CHANGELOG.md` when a bump crosses versions.** The template ships behaviour
  changes, not only features.
- **Rerun `.code-server/setup` after a bump.** The image is what carries the change, and it is
  never updated in place — a bumped pointer with a stale image means the repo and the environment
  describe different systems.
- **Never hand-edit `.code-server/Dockerfile`.** It is generated from the fragments and regenerated
  on every `setup`; an edit there is lost without warning.

## Dependencies fetched at build time

- **Pin a version and verify a digest.** `releases/latest` means the image can change under a
  project on a rebuild that changed nothing in it. This is not hypothetical: an `ai-jail` release
  turned network access into an explicit opt-in, and the environment lost its network on the next
  rebuild, presenting as a host networking fault that did not exist.
- **A tag is not immutable either** — it can be repointed and its assets replaced. The digest is
  what makes the build fail instead of installing something else.
- **Bumping such a pin is a deliberate step**, and the release notes are part of it.

## Secrets

- **Nothing secret goes in the repository or in the image.** Not an API key, not a token, not a
  `.env` carrying real values.
- **`CLAUDE_CONFIG_DIR` (`/config/.claude`) is not a candidate for version control**, not even
  partially: it holds credentials, conversation history and session transcripts.
- **A credential reaches the agent only when you hand it one**, through an explicit environment
  passthrough. Scope it to what it needs and give it an expiry — the agent's environment is a
  place a secret can be read from and echoed into a transcript.

## The agent's sandbox

- **`claude` runs sandboxed by default.** The wrapper on PATH re-execs the CLI inside `ai-jail`;
  `/usr/bin/claude` stays reachable by absolute path when you deliberately want it unjailed.
- **A project's `.ai-jail` can tighten the sandbox, never widen it.** Capability opt-ins are
  refused from project config by design, so that cloning a repository cannot grant itself
  anything. Anything that widens the map is decided in the image, which is the operator's side of
  that line.
- **Treat a widening as a decision, not a workaround.** If a task needs a grant, say which grant
  and why, in the change that introduces it.

## Long-term memory

- **`ai-memory` is off until a project asks for it**, by carrying an `.ai-memory.toml` marker.
  Without one, nothing listens and no lifecycle event is emitted at all.
- **Memory is per project.** The server lives in the project's own container; two projects never
  see each other's.
- **No LLM provider is configured by default**, so captured prompts and tool excerpts stay on the
  machine. Adding one is a decision about where that content goes.

## Documentation

- **A Markdown file stays under 50 KiB.** Past that it stops being read and starts being skimmed,
  which is worse than being short: it still looks authoritative. A diff that size is not reviewed
  either, it is approved.
- **When a file reaches the limit, split it and link** — do not compress the prose until it fits.
  The length was the signal; deleting the explanations that made it long throws away the part
  worth keeping.
- **`CHANGELOG.md` is exempt.** It only grows, it is written by release-please rather than by a
  person, and blocking a release commit on it would teach everyone to reach for `--no-verify` —
  which turns off every other check at the same time.
- **The check is `scripts/check-md-size.sh`**, wired to `.githooks/pre-commit`. Enable it per
  clone with `git config core.hooksPath .githooks`; git config is not versioned, so no commit can
  turn it on for you. There is no CI in a consuming repo to catch this afterwards, so an unenabled
  hook means the rule is only as real as the person remembering to run the script.

## Verification

- **Changes under `.code-server/` are verified by the template's own CI**, which builds an image
  per stack. Make them there, in the template's repository, and consume the result through a bump.
- **A consuming repo has no CI of its own**, so a PR in it is mergeable the moment it opens.
  Nothing will stop a broken change: the discipline has to come from whoever opens it.
