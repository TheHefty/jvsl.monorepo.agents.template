# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

A reusable template for a code-server-based dev container, meant to be dropped into other
monorepos. It is not itself an application — there's no product code here, only the tooling that
builds and launches the dev environment. Everything lives under `.code-server/`, mirroring how a
`.devcontainer/` would work, so a monorepo that adopts this template keeps its own repo root free.

Full design rationale — every decision made, the exact structure of `core/`/`stacks/`, the manifest
format, and every build error hit and fixed along the way — is recorded in
`.code-server/docs/OVERVIEW.md`. Treat that file as the authoritative, up-to-date spec; update it
(not this summary) as new decisions are made. `docs/OVERVIEW.md` at the repo root is the short
user-facing "how to use this template" version.

## Pair Programming Mode

By default, treat work in this repo as guided pair programming, not delegated implementation:
work through open design questions one at a time — present 2-3 options with a short tradeoff and
a recommendation, let the user pick, then move to the next item. Don't front-load a full design
doc or make several decisions on the user's behalf in one pass. Only write or edit code once the
user gives an explicit go-ahead for that scoped piece of work (e.g. "pode escrever", "faça tudo")
— don't implement unilaterally before that. If there's a genuine verification gap (e.g. no
toolchain available locally to build/run something), say so plainly before writing and let the
user decide how to handle it, rather than claiming untested code works.

When this template is dropped into a new project (bootstrapping), the agent must start by asking
about the project's purpose — domain, goals, and any constraints already known — before touching
files. Update the base files (`README.md`, `CLAUDE.md`, `docs/OVERVIEW.md`, and any stack
selection in `.code-server/.stack.json`) to reflect the answers, and propose/assemble an initial
structure for the new project based on them, following the one-decision-at-a-time approach above
rather than generating the whole thing unprompted.

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
in `.code-server/docs/OVERVIEW.md`). There is no test suite and no lint config in this repo.

Launch the environment:
```bash
.code-server/start/target/release/start
```

## Architecture

- **`.code-server/core/Dockerfile.frag`** — the mandatory base layer (code-server, Node.js,
  Claude Code CLI, `ai-jail`, the docker-socket gid fix in `core/cont-init/`). Never optional.
- **`.code-server/stacks/<name>/`** — one directory per selectable tech stack, each with a
  `Dockerfile.frag` (using a `{{VERSION}}` placeholder, substituted at compose time — version
  divergence within a stack is handled with a shell `if` inside the same fragment, not a separate
  directory per version) and a `versions.json` listing valid versions. `java` is currently the only
  stack, meant as the pattern to copy for new ones.
- **`.code-server/setup`** — bash script: reads `.code-server/.stack.json` (the versioned manifest,
  the source of truth for stack selection), shows a `whiptail` multi-select checklist pre-populated
  from it, asks a version per selected stack, rewrites the manifest, concatenates
  `core/Dockerfile.frag` + each selected stack's fragment into `.code-server/Dockerfile`
  (gitignored — always regenerated, never hand-edited), and runs `docker build`. Removing a stack
  is just excluding it from the manifest; there's no uninstall logic, the image is always rebuilt
  from scratch.
- **`.code-server/start/`** — a Tauri v2 Rust app with no JS frontend (`dist/index.html` is an
  unused placeholder; the window navigates straight to code-server's external URL). `src/main.rs`
  ensures the container is running (`docker start` if it already exists, otherwise a `docker run`
  replicating the flags a plain `docker run` setup would need — workspace/`~/.claude`/docker-socket
  mounts, `--network host`, `--cap-add=SYS_ADMIN`, etc.), polls the code-server URL until it
  responds, then opens a native window there instead of a browser tab (deliberately, to avoid the
  browser intercepting editor keyboard shortcuts like Ctrl+W/Ctrl+N). Image/container name and
  `START_WORKSPACE_DIR` default-derive automatically (from the binary's own location, and from the
  same basename convention `setup` uses for the image name), so it runs with no configuration as
  long as it stays inside the repo structure it was built in.
