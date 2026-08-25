# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Initialization

Two questions are settled before anything is built, and neither can be answered from an empty
repository. The first file written is the record of the answers.

**Which mode we are working in.** Ask, and let the user answer:

- **Pair Programming Mode** — the agent drives, the user navigates. The default when the answer is
  "just get on with it".
- **Navigator Mode** — the user drives, the agent navigates. For work the user wants to write
  themselves, with a second pair of eyes on it.

Both are described below. Ask once, at initialization; afterwards assume the mode last chosen and
do not re-open it every session. Either side can switch mid-session by saying so — that is a
sentence, not a negotiation.

**What the project is for.** When the template is added to a project (`git submodule add
https://github.com/TheHefty/jvsl.env.agents.code-server.git .code-server`), the domain, the goals
and any constraints already known are not visible in the repository, and guessing them wrong
misdirects everything built on top.

Do not improvise that interview. Invoke the `mattpocock-skills:grilling` skill and let it drive:
it works the open decisions as a tree and asks a whole round at a time, numbering each question
and attaching a recommended answer to it. That last part is what keeps it compatible with the rule
below — the obvious ones are accepted in a word rather than composed. The user's own entry points
into the same interview are `/grill-me` and `/grill-with-docs`. If the plugin is not installed,
run the interview yourself in that shape rather than skipping it: rounds of numbered questions,
each carrying your recommendation, and no project file touched until it ends.

**Then write the result up as the project's first RFC**, `docs/RFC/0001-*.md`, from
[`docs/RFC/0000-template.md`](docs/RFC/0000-template.md). What belongs in it is the decisions and
their reasons — purpose, the constraints that turned out to be real, what was considered and
dropped, and the three worst failure scenarios for the shape being chosen. Not a transcript: an
interview pasted into a file is a document nobody reads twice. Merge it `Accepted`. Everything
after is built on it, and it is the only place a later reader finds out why the project is shaped
this way.

Once it is settled, proceed under the chosen mode: update the base files (`README.md`, `CLAUDE.md`,
`docs/OVERVIEW.md`, `docs/RULES.md`, and the stack selection in `.code-server.stack.json` at the
consuming repo's root) to reflect the answers, and assemble an initial structure from them.

## What this repository is

A reference monorepo that has already adopted the code-server dev-container template. The template
itself — `core/`, `stacks/`, `start/`, `setup`, and the full design-rationale doc — lives in its own
repo, [`jvsl.env.agents.code-server`](https://github.com/TheHefty/jvsl.env.agents.code-server),
vendored here as a git submodule at `.code-server/` (the officially documented way to consume it —
not a copy-paste drop-in). Splitting it out means any monorepo consuming the template pulls in
template updates with a plain `git submodule update` (bump the pinned commit) instead of needing a
rebase against upstream template history.

This repo is not itself an application — there's no product code here, only the root-level
scaffolding a consuming monorepo keeps outside the submodule: this `CLAUDE.md`, `README.md`,
`docs/OVERVIEW.md`, and `.code-server.stack.json` (the per-project stack selection — see "Manifest"
in `.code-server/docs/OVERVIEW.md` for why it can't live inside the submodule itself).

Full design rationale for the template — every decision made, the exact structure of
`core/`/`stacks/`, the manifest format, and every build error hit and fixed along the way — is
recorded in `.code-server/docs/OVERVIEW.md`, inside the submodule (so it versions together with the
template, not with this consuming repo). Treat that file as the authoritative, up-to-date spec for
anything under `.code-server/`. `docs/OVERVIEW.md` at this repo's root is the short user-facing "how
to use this template" version, and is what should be updated for anything specific to being a
*consumer* of the template (as opposed to the template's own internals).

## Pair Programming Mode

Work here is pair programming: you drive, the user navigates. That is about *direction* — what
gets built, what risk is worth taking, what ships — and not about permission for each keystroke.

**Don't stop to question the obvious.** When a choice has a clear recommendation, make it,
implement it, and say what you chose and why. Options are worth putting in front of the user only
when two readings lead to materially different systems; a menu offered for a decision you could
have made yourself is a round trip that buys nothing, and it spends the user's attention where
nothing was at stake.

The real work is anticipating failure. **Before writing code, state the three worst failure
scenarios or infrastructure bottlenecks this implementation can cause** — a broken contract, memory
exhaustion, concurrency, an external dependency changing under the build, state that outlives the
rebuild meant to replace it. Name them concretely for the change at hand; a generic risk checklist
is not the exercise.

Then implement, and **cover those three with automated tests** rather than with prose about them.
Tests live beside what they exercise, in the repository whose CI runs them: a `*.test.sh` next to
the script under test, driving the real script rather than a copy of its logic, plus a job in
`.code-server/.github/workflows/ci.yml` (see `packages.test.sh` and
`core/cont-init/30-editor-defaults.test.sh` for the shape). A consuming repo has no CI of its own,
so a test written there runs nowhere — a reason to make the change in the template, not a reason to
skip the test.

Stop and consult in three cases:

- **A real technical blocker** — no toolchain to build or run something, a credential the agent
  cannot reach, a host capability that is absent. Say so plainly and early, and never present
  untested code as verified.
- **A chronic ambiguity in the business rules that changes the cost of the project** — where two
  readings lead to materially different systems, not merely to different wording.
- **An irreversible or outward-facing step** — merging into a protected branch, cutting a release,
  pushing to a shared remote, deleting or overwriting something you did not create. This is the
  half of pairing that the rule above does not dissolve: those stay with the user, because the
  cost of being wrong there is not paid by asking. Handing over a whole sequence at once is
  pairing; asking again at each step of a sequence already handed over is not.

Everything else is yours to decide, do, and report.

## Navigator Mode

The same pairing with the seats swapped: the user writes the code, and the agent navigates. Do not
edit files unless asked — a patch offered instead of an answer takes the wheel back.

The duty from the mode above does not change hands, it only changes target. **Read what the user
actually wrote, and name the three worst failure scenarios it can cause** — concretely, in their
code, not as a lecture on the category. That is the whole value on offer here; a review that only
compliments the shape of the code is the review that let the outage through.

Same bar for speaking up as for asking: raise what changes the outcome. Style preferences, renamings
and alternative spellings of a working idea are noise. What the change touches and the user may not
be looking at — the submodule pointer, the manifest, the generated Dockerfile, the sandbox map, a
pinned digest — is exactly what a navigator is for.

**Verification stays with the agent in both modes.** Run what can be run — `bash -n`, the test
scripts, a grep that settles the question — and report the result, not an impression of it. "This
looks right" is not a finding; a command and its output is.

Say plainly when something is wrong, including when it is the user who is wrong, and say it while it
is still cheap to change. Softening a real defect into a suggestion is how it survives review.

## Commands

Build the dev image (interactive; also how you add/remove stacks later):
```bash
.code-server/setup
```
Requires `jq`, `whiptail`, and `docker` on the host. This runs on the host, before any image
exists, so it cannot depend on anything from inside the image it builds.

Build the native launcher (Rust/Tauri, only needed once, or after editing `.code-server/start/src/main.rs`):
```bash
cd .code-server/start && cargo build --release
```
Requires Rust and the Tauri Linux prerequisites (webkit2gtk, etc. — exact packages per distro are
in `.code-server/docs/OVERVIEW.md`). There is no test suite and no lint config in this repo. The
template itself does have CI, inside the submodule (`.code-server/.github/workflows/ci.yml`):
`bash -n` over the shell scripts, `cargo check --release --locked` on `start/` (the `--locked` is
what keeps a stale `Cargo.lock` from reaching you here as a dirty submodule), and a `docker build`
per stack (each composed through `core/compose-dockerfile.sh`, so a stack's `requires.json`
dependencies are built with it) — plus `ci-green`, a job that needs all of the others and is the
single check the template's branch protection requires, since the per-stack jobs are a matrix built
from `ls stacks` and their names change whenever a stack is added or removed. Changes under
`.code-server/` are therefore verifiable there, but nothing in this consuming repo runs it.

Launch the environment:
```bash
.code-server/start/target/release/start
```

## Architecture

- **`.code-server/core/Dockerfile.frag`** — the mandatory base layer (code-server, Node.js,
  Claude Code CLI, `ai-jail`, the GitHub CLI, Rust/`rustup` + the Tauri Linux libs). Never optional.
  Two parts of it are worth knowing before touching anything else: **Docker inside the container is
  a nested *rootless* daemon**, run as the s6 service in `core/services/svc-dockerd-rootless/` —
  the host's socket is deliberately not mounted, because mounting it made everything in the
  container root-equivalent on the host and silently voided `ai-jail`'s sandbox (an agent shown a
  read-only path can `docker exec -u 0` into its own container); and `CLAUDE_CONFIG_DIR=/config/.claude`
  keeps the whole Claude Code CLI state in the bind-mounted directory rather than only its
  credentials. `core/cont-init/` now holds a single boot hook, `20-kvm-gid.sh`, which aligns the
  in-container `kvm` group with the host device's gid when `start` passed one.
- **`.code-server/stacks/<name>/`** — one directory per selectable tech stack, each with a
  `Dockerfile.frag` (using a `{{VERSION}}` placeholder, substituted at compose time — version
  divergence within a stack is handled with a shell `if` inside the same fragment, not a separate
  directory per version), a `versions.json` listing valid versions, and optionally a
  `requires.json` listing other stacks it can't build without and a `cont-init/` directory of
  boot-time scripts the fragment `COPY`s into `/custom-cont-init.d/` (the same LinuxServer hook
  `core/` uses — for anything that must hold on *every* boot rather than once at build time, which
  for a stack usually means state under `/config`, a named volume Docker seeds from the image only
  on first mount). Current stacks: `java`, `cpp`, `dotnet`, `python`, `golang`, `ruby`, `php`,
  `node`, `rust`, `android` (the only one with a `requires.json`: `["java"]`, and so far the only
  one with a `cont-init/`) — `java` was the original, meant as the pattern to copy for new ones.
- **`.code-server/setup`** — bash script: reads `.code-server.stack.json` at the consuming repo's
  root (one level above `.code-server/` — the versioned manifest, the source of truth for stack
  selection; lives outside the submodule so it survives `git submodule` updates instead of being
  local, uncommittable state inside vendored code), shows a `whiptail` multi-select checklist
  pre-populated from it, refuses a selection that leaves a `requires.json` dependency unchecked,
  asks a version per selected stack, rewrites the manifest, then exports it as `STACK_MANIFEST` and
  calls `core/compose-dockerfile.sh` to generate `.code-server/Dockerfile` (gitignored — always
  regenerated, never hand-edited), and runs `docker build`. Removing a stack is just excluding it
  from the manifest; there's no uninstall logic, the image is always rebuilt from scratch.
- **`.code-server/core/compose-dockerfile.sh`** — takes stack names and writes the Dockerfile to
  stdout: `core/Dockerfile.frag` followed by each stack's fragment, `requires.json` dependencies
  first, `{{VERSION}}` substituted. Versions come from the JSON file `$STACK_MANIFEST` points at
  when it has an entry for the stack, and otherwise from the lowest version in that stack's
  `versions.json` — which is exactly what lets `setup` (exports the manifest it just wrote) and CI
  (exports nothing, gets the lowest listed version it already tests) share one composition path
  instead of each concatenating fragments on its own.
- **`.code-server/start/`** — a Tauri v2 Rust app with no JS frontend (`dist/index.html` is an
  unused placeholder; the window navigates straight to code-server's external URL). `src/main.rs`
  ensures the container is running (`docker start` if it already exists, otherwise a `docker run`
  replicating the flags a plain `docker run` setup would need — workspace and `~/.claude` mounts
  plus the named `/config` volume, `PUID/PGID=1000`, `--cap-add=SYS_ADMIN`, `--memory=8g` with
  `--memory-swap=10g` (i.e. 2g of swap), and `--cpuset-cpus` over half the host's cores so `nproc`
  inside reflects the limit), reads back the host port Docker published for it, polls the
  code-server URL until it responds, then opens a native window there instead of a browser tab
  (deliberately, to avoid the browser intercepting editor keyboard shortcuts like Ctrl+W/Ctrl+N).
  It deliberately does *not* use `--network host`: code-server is published as `-p
  127.0.0.1:0:8443` (a free host port, loopback only) so several projects' containers can run at
  once — see "Networking and port discovery" in `.code-server/docs/OVERVIEW.md`. Image/container
  name, data volume name and `START_WORKSPACE_DIR` default-derive automatically (from the binary's
  own location, and from the same basename convention `setup` uses for the image name), so it runs
  with no configuration as long as it stays inside the repo structure it was built in. Three device
  nodes are passed through *conditionally*, only when the host has them (`docker run --device` on a
  missing path is a hard failure, not a no-op): `/dev/fuse` and `/dev/net/tun`, which the nested
  rootless daemon needs for fuse-overlayfs and slirp4netns — without `/dev/fuse` the daemon stays
  down instead of crash-looping, so `docker` inside simply isn't available — and `/dev/kvm`, which
  the `android` stack's headless emulator needs, passed together with a `KVM_GID` the boot hook
  reads.
- **Versioning** — the template is released with release-please from its own conventional commits;
  `v1.0.0` is the first tag. Prefer bumping `.code-server/` to a tag rather than a bare commit, and
  read the submodule's `CHANGELOG.md` when bumping across one. A bare commit is not just less
  tidy: if it came from a branch that is later squash-merged, the commit becomes unreachable and
  every fresh clone fails its `git submodule update`. The template's own `main` is protected and
  requires `ci-green`, and its release-please runs under a PAT (`RELEASE_PLEASE_TOKEN`) so that its
  release PRs get a CI run at all — a token that expires, and whose expiry shows up as releases
  quietly no longer being proposed. See "Versioning and releases" in
  `.code-server/docs/OVERVIEW.md`.

## Releases

This repo is released the same way the template is: release-please
(`.github/workflows/release-please.yml`) keeps a release PR open on `master` and cuts the tag when
it is merged, with `version.txt` + `CHANGELOG.md` as the only versioned artifacts (`release-type:
simple` — there is nothing here to publish). Commit messages are therefore load-bearing, not
decoration: only `feat`/`fix` reach the changelog, and a release is proposed only when one of them
lands.

`master` is protected, so **there is no direct push to it** — every change, including a submodule
bump or a one-line doc fix, goes through a pull request. No approvals are required (single
maintainer), but the rule applies to administrators too, and force-pushes and branch deletion are
blocked. There are no required status checks, because this repo has no CI of its own: a PR here is
mergeable as soon as it is open. Head branches are deleted automatically on merge.

`bootstrap-sha` pins the changelog's starting point at `54628be`, the commit that vendored the
template as a submodule. Everything before it describes `core/`/`stacks/` work that has since moved
into the template's own repo, and letting release-please walk into it would produce a changelog
about code this repo no longer contains.
