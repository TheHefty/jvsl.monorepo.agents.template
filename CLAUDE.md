# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Initialization

Six questions are settled before anything is built, and none of them can be answered from an
empty repository. The first file written is the record of the answers.

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

Do not improvise that interview, and do not invent a procedure for it: every RFC in this project
is produced by the same interview, and [`docs/RFC/README.md`](docs/RFC/README.md) describes it.
This one is simply the first. Touch no project file until it ends.

**The result is the project's first RFC**, `docs/RFC/0001-*.md`, merged `Accepted`. Everything
after is built on it, and it is the only place a later reader finds out why the project is shaped
this way.

**Whether the project keeps long-term memory.** `ai-memory` is off unless the project carries an
`.ai-memory.toml` marker, so this is a decision, not a default — ask it, and put enough in front of
the user to answer it. What it buys: a handoff across sessions and across agent CLIs, and search
over what was already decided, instead of re-explaining the architecture every time. What it costs:
prompts and tool excerpts are captured to disk for this project. Memory is per project and never
crosses into another, and no LLM provider is configured, so nothing captured leaves the machine
unless someone later adds one. The mechanics are in
[`docs/OVERVIEW.md`](docs/OVERVIEW.md) — don't restate them here, they drift.

If yes, create the marker and say that the container has to be restarted before anything comes up:
the marker is read at boot, by the service and by the hook that registers with the CLI. If no,
create nothing — absence is the switch, and it can be turned on later without redoing anything.
Either way the answer belongs in RFC `0001`, since it decides whether this project accumulates a
record of how it was built.

**Which language the documentation is written in.** Ask, and apply the answer to all of it —
`README.md`, `CLAUDE.md`, `docs/`, the RFCs, and commit messages if the user wants it there too.
The failure mode is not the wrong choice, it is the mixture: half the docs in English and half in
Portuguese, with no rule saying which is which, so every new file re-opens the question and nobody
can grep. The files inherited from the template arrive in English; translating them is part of the
answer, not a separate errand. Conversation language is a different thing and does not need
settling here — the user sets it by speaking.

**Who the project is for.** Not public versus private: what decides the legal baseline is whose
data is processed and to what end. Three shapes, and they are not points on a scale.

- **Personal use** — one person building for themselves, on their own data, with no economic
  purpose. LGPD puts this outside its scope (Lei 13.709/2018, art. 4º, I, *"realizado por pessoa
  natural para fins exclusivamente particulares e não econômicos"*), and there is no application
  provider serving third parties for the Marco Civil to reach. Record it as the answer, and record
  **what would end it**: opening it to other people, charging for it, or storing data belonging to
  anyone else. That transition is the one nobody notices happening, and it is where a project
  acquires obligations it was never designed for. Ask whether the user wants privacy rules anyway
  — plenty of personal projects want them, for reasons that have nothing to do with the law — and
  if not, record the decision **and its reason**, so the next reader can tell it was decided
  rather than overlooked.
- **Private but not personal** — internal to a team or a company, or holding data about employees,
  clients or users. In scope. The exclusion above is about a natural person acting for themselves;
  it is not about a system being unpublished.
- **Public** — reachable by people outside the team: a site, an API, an app, a repository open to
  outside contributions. In scope, plus the obligations that come with serving an application over
  the internet.

For the second and third, settle at initialization: whether any personal data is touched at all,
which of it is sensitive, the purpose and legal basis for each use, how long it is kept, how
subject requests are answered, and who the controller is. **If nothing personal is processed,
record that** — it is the answer that saves the most work later, and the one nobody writes down.
For the third, the **Marco Civil da Internet (Lei 12.965/2014)** adds terms of use and a privacy
policy that are actually reachable, obligations around keeping access records, and disclosure only
under judicial order. Confirm current retention periods against the law rather than trusting a
number quoted in a document like this one; that is the part that changes.

Whatever the answer, it goes in RFC `0001` as a data map — what personal data exists, why, where
it lives, how long it stays — and the standing rules go in `docs/RULES.md`. Policy and terms are
project files, written in the documentation language chosen above.

**Which licence the project is under.** Ask, and apply the answer immediately rather than leaving
it for later — `LICENSE` at the root, the licence field of whatever manifest the project has
(`package.json`, `Cargo.toml`, `pyproject.toml`), and the line in `README.md` that names it. All
three, or the machine-readable one contradicts the file and downstream tooling reports whatever it
finds first.

Three things make this cheap now and expensive afterwards.

- **A repository with no `LICENSE` is not permissive by default, it is closed.** Absent a licence,
  default copyright applies: nobody may use, copy or modify it. Publishing code that way is
  publishing something nobody is allowed to use, which is rarely what was intended. "All rights
  reserved" is a legitimate answer — record it as one, so it reads as a decision.
- **A licence arrives inherited, and inheriting is a choice.** The template ships `LICENSE` (MIT)
  and a project adopting it starts with that file in place. Confirm it or replace it; a licence
  nobody chose is a licence someone else chose.
- **Relicensing later needs the agreement of everyone who contributed** under the old terms. While
  the project is one person and one commit, changing it costs nothing.

Check what the dependencies permit before promising a licence — a copyleft dependency constrains
what the project can be distributed under, and finding that out after release is finding it out
from someone else.

**This is scaffolding, not legal advice.** The job is to make the decisions explicit and recorded
so that someone qualified has something to review. Never present generated policy text as
compliant, and say plainly that it has not been reviewed.

Beyond the five questions, one recommendation to make out loud: **build for accessibility and
internationalisation from the first screen, not as a later pass.** Put it in terms of cost rather
than virtue, because that is what is actually true — both are nearly free while the structure is
being laid and expensive afterwards. i18n retrofitted means hunting every literal string in the
codebase and finding the ones built by concatenation. Accessibility retrofitted means redoing
markup, focus order and colour decisions that everything else was already built on top of.

What that means on day one, concretely:

- **Strings leave the code from the first commit** — a catalogue keyed by identifier, not literals
  to be extracted later. A single locale is fine; the point is the seam, not the translation.
- **Dates, numbers and currency are formatted by locale**, and translated fragments are never
  concatenated into sentences — word order is not a constant across languages.
- **Semantic markup and real controls before ARIA**, everything reachable by keyboard, focus
  visible. ARIA patches what HTML cannot express; it is not a substitute for expressing it.
- **Contrast and text sizing live in the design tokens**, decided once, rather than per component
  where they drift.
- **A check in CI as soon as there is something to check.** The rule from below applies here too:
  a stated intention with no test is a stated intention.

Scope it honestly. A CLI, a library or a service with no interface still has user-facing messages,
so the i18n seam applies; most of the accessibility list does not. Recommending the whole thing to
a project that has no UI is ritual, and ritual is what teaches people to skip the parts that
mattered.

It is a recommendation, not a gate. If the user declines, record it in RFC `0001` with the reason,
like everything else here — an omission with a reason attached can be revisited; one without looks
like an oversight forever.

Once it is settled, proceed under the chosen mode: update the base files (`README.md`, `CLAUDE.md`,
`docs/OVERVIEW.md`, `docs/RULES.md`, and the stack selection in `.code-server.stack.json` at the
consuming repo's root) to reflect the answers, and assemble an initial structure from them.

**Delete this section once the project is initialized.** It is scaffolding for a moment that
happens once, and a checklist that stays after it is done gets re-run, argued with, or quietly
ignored — and the third is the one that spreads to the sections around it.

Two things have to be somewhere else first, because they are standing answers rather than one-time
decisions and the rest of the file assumes them:

- **The mode**, written as a fact — "work here is Navigator Mode" — where the mode sections can be
  read against it. It governs every session, not just this one.
- **The documentation language**, for the same reason: every file written from here on inherits it,
  and a question that was deleted cannot be re-read.

Everything else is already recorded in RFC `0001`, which is what makes deleting this safe: the
answers outlive the questions. In the template repository itself this section stays — it is the
copy that projects inherit, the same reason [`docs/RFC/`](docs/RFC/) and
[`docs/SCENARIOS/`](docs/SCENARIOS/) carry no numbered files.

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

Stop and consult in four cases:

- **A real technical blocker** — no toolchain to build or run something, a credential the agent
  cannot reach, a host capability that is absent. Say so plainly and early, and never present
  untested code as verified.
- **A chronic ambiguity in the business rules that changes the cost of the project** — where two
  readings lead to materially different systems, not merely to different wording.
- **A gate in a defined pipeline** — the RFC agreed with the user before any scenario is written,
  the Gherkin scenarios agreed before any code is. See "Releases have a theme" in
  [`docs/RULES.md`](docs/RULES.md). Waiting at a handoff someone designed on purpose is not the
  same as stopping to ask about the obvious: one is the process working, the other is the round
  trip this mode exists to remove. An agent that skips these citing the rule above has read it
  backwards.
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
