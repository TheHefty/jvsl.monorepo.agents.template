# Rules

Ground rules for a monorepo built on this template. They are short on purpose: each one exists
because breaking it has already cost something, and the reason is given so you can tell when a rule
stops applying.

## Security

### Secrets

- **Nothing secret goes in the repository or in the image.** Not an API key, not a token, not a
  `.env` carrying real values.
- **`CLAUDE_CONFIG_DIR` (`/config/.claude`) is not a candidate for version control**, not even
  partially: it holds credentials, conversation history and session transcripts.
- **A credential reaches the agent only when you hand it one**, through an explicit environment
  passthrough. Scope it to what it needs and give it an expiry — the agent's environment is a
  place a secret can be read from and echoed into a transcript.

### The agent's sandbox

- **`claude` runs sandboxed by default.** The wrapper on PATH re-execs the CLI inside `ai-jail`;
  `/usr/bin/claude` stays reachable by absolute path when you deliberately want it unjailed.
- **A project's `.ai-jail` can tighten the sandbox, never widen it.** Capability opt-ins are
  refused from project config by design, so that cloning a repository cannot grant itself
  anything. Anything that widens the map is decided in the image, which is the operator's side of
  that line.
- **Treat a widening as a decision, not a workaround.** If a task needs a grant, say which grant
  and why, in the change that introduces it.

### Dependencies fetched at build time

- **Pin a version and verify a digest.** `releases/latest` means the image can change under a
  project on a rebuild that changed nothing in it. This is not hypothetical: an `ai-jail` release
  turned network access into an explicit opt-in, and the environment lost its network on the next
  rebuild, presenting as a host networking fault that did not exist.
- **A tag is not immutable either** — it can be repointed and its assets replaced. The digest is
  what makes the build fail instead of installing something else.
- **Bumping such a pin is a deliberate step**, and the release notes are part of it.

### Long-term memory

- **`ai-memory` is off until a project asks for it**, by carrying an `.ai-memory.toml` marker.
  Without one, nothing listens and no lifecycle event is emitted at all.
- **Memory is per project.** The server lives in the project's own container; two projects never
  see each other's.
- **No LLM provider is configured by default**, so captured prompts and tool excerpts stay on the
  machine. Adding one is a decision about where that content goes.

## Testing

### Test-first

**TDD is the default on every project.** Write the failing test, watch it fail, make it pass,
refactor. Not tests written alongside, and not tests written after and committed in a convincing
order.

- **Watching it fail is the load-bearing step, and the one that gets skipped.** A test that has
  never failed has proven nothing: it may assert nothing, assert the wrong thing, or exercise code
  that was already there. Red first is what makes green mean something.
- **A bug fix starts with the reproduction.** Write the test that fails for the reported reason,
  in the terms of the report, before touching the fix. It is the only proof that what was fixed is
  what was broken, and it is what stops the bug returning unannounced later.
- **The three failure scenarios are the first tests.** "Pair Programming Mode" in
  [`../CLAUDE.md`](../CLAUDE.md) requires naming the three worst ways a change fails before
  writing it; test-first is how those stop being a paragraph. Name them, write them as failing
  tests, then build the thing that turns them green.
- **A spike is allowed, and it is thrown away.** Exploring to answer a design question does not
  need tests — it needs to not survive. What ships is written test-first from the beginning; the
  spike is not laundered into it by adding tests afterwards.
- **If something genuinely cannot be written test-first, say so in the pull request** and say why.
  Some things only fail against a real host, and shell glue is sometimes cheaper to verify by
  running it. That is an answer. Silence is not, and neither is a test that was written last and
  arranged to look first.

### What runs, and where

Nothing in a consuming repo runs a test for you. What discipline exists has to be carried by
whoever opens the change.

- **Changes under `.code-server/` are verified by the template's own CI**, which builds an image
  per stack. Make them there, in the template's repository, and consume the result through a bump.
- **A consuming repo has no CI of its own**, so a PR in it is mergeable the moment it opens.
  Nothing will stop a broken change: the discipline has to come from whoever opens it.
- **A test here is a `*.test.sh` beside the thing it exercises**, driving the real script rather
  than a copy of its logic, and exiting non-zero on failure. `scripts/check-md-size.test.sh` is
  the local example; the template's `packages.test.sh` and
  `core/cont-init/30-editor-defaults.test.sh` are the ones with a CI job behind them.
- **A local hook is not CI.** It is opt-in per clone and skippable with `--no-verify`, so treat it
  as a reminder for the author, never as a gate the repository enforces.

What a change must cover, and when, is in "Pair Programming Mode" in
[`../CLAUDE.md`](../CLAUDE.md) — that is a rule about how work is done rather than about what this
repository contains, and stating it twice in full would let the two drift.

## Development conventions

### Branches and review

- **The default branch is protected. There is no direct push to it** — every change goes through a
  pull request, including a one-line doc fix and a submodule bump. The rule applies to
  administrators too; force-pushes and branch deletion are blocked.
- **Approvals are a project's own call**, but the PR is not optional even when you are the only
  maintainer. It is what gives a change a reviewable diff and a place to say why.
- **Head branches are deleted on merge.** Don't rely on a merged branch still existing — see the
  submodule rule below for what that costs when you do.

### Commits and releases

- **Conventional commits are load-bearing, not decoration.** Releases are cut by release-please
  from the commit history: only `feat` and `fix` reach the changelog, and a release is proposed
  only when one of them lands. A `chore` that should have been a `fix` is a release that never
  happens.
- **Write the commit message for the person who will read it during an incident**, not for the
  diff. The diff already says what changed; the message is where why belongs.

### The template submodule

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

## Documentation

- **A Markdown file stays under 50 KiB.** Past that it stops being read and starts being skimmed,
  which is worse than being short: it still looks authoritative. A diff that size is not reviewed
  either, it is approved.
- **When a file reaches the limit, split it into a folder** named for its subject, one file per
  top-level section, with a `README.md` inside that indexes them — GitHub and most viewers open a
  folder at its `README.md`, so the index is what a reader lands on. `docs/RULES.md` at 50 KiB
  would become `docs/rules/` holding `security.md`, `testing.md` and the rest.
- **Split on the section boundaries, not on the byte count.** A file cut where it happened to
  reach 50 KiB leaves half an argument in each piece, and the reader has to reassemble what the
  author already had whole.
- **Do not compress the prose until it fits.** The length was the signal; deleting the
  explanations that made it long throws away the part worth keeping and leaves rules with no
  reasons, which is how a rule outlives its reason.
- **A split is only done when the inbound links are updated with it.** A Markdown link to a moved
  file does not fail, it just goes nowhere, and nothing here checks them. Either fix every
  reference in the same change, or leave the old path in place as a one-line pointer to the new
  index — never as a second copy of the content, because the copy nobody edits is the one someone
  reads.
- **`CHANGELOG.md` is exempt.** It only grows, it is written by release-please rather than by a
  person, and blocking a release commit on it would teach everyone to reach for `--no-verify` —
  which turns off every other check at the same time.
- **The check is `scripts/check-md-size.sh`**, wired to `.githooks/pre-commit`. Enable it per
  clone with `git config core.hooksPath .githooks`; git config is not versioned, so no commit can
  turn it on for you. There is no CI in a consuming repo to catch this afterwards, so an unenabled
  hook means the rule is only as real as the person remembering to run the script.
