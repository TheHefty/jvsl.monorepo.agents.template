# Overview

Dev environment template based on [code-server](https://github.com/coder/code-server), with the
Claude Code CLI, `ai-jail`, `ai-memory`, the GitHub CLI, and a nested rootless Docker daemon
already set up. The
template itself lives in its own repo,
[`jvsl.env.agents.code-server`](https://github.com/TheHefty/jvsl.env.agents.code-server),
vendored here as a git submodule at `.code-server/` (doesn't clutter the root of the monorepo that
adopts it) and controlled by two executables: `setup` (chooses the tech stacks that go into the
image) and `start` (brings up the environment in a native window).

The full design — decisions made, the structure of `core/`/`stacks/`, the manifest format, bugs
already hit and fixed — is in
[`.code-server/docs/OVERVIEW.md`](../.code-server/docs/OVERVIEW.md), inside the submodule (so it
versions with the template, not with this consuming repo). This document is just the "how to use
it" summary, and covers what's specific to being a *consumer* of the template.

## Updating the template

The template is released with [release-please](https://github.com/googleapis/release-please), so it
carries tags and a `CHANGELOG.md`. Prefer pinning to a tag over a bare commit:
```bash
cd .code-server && git fetch --tags && git checkout v1.0.1 && cd ..
git add .code-server && git commit -m "chore: bump .code-server template to v1.0.1"
```
This is the whole point of the submodule split: pulling in template changes (new stacks, fixes)
never requires rebasing this repo's own history against the template's. Rerun `.code-server/setup`
after a bump — the image is what actually carries the change, and it is never updated in place.

## Starting the environment

Prerequisites on the host: `jq`, `whiptail`, `docker` (for `setup`); Rust/`cargo` + the Tauri libs
for Linux (for `start` — see `.code-server/docs/OVERVIEW.md` for the exact packages per distro).

1. **Build the image** (choose the monorepo's stacks, generate the Dockerfile, and build it):
   ```bash
   .code-server/setup
   ```
   Rerun `setup` any time you want to add or remove a stack. A stack can depend on another one
   (today only `android`, which needs `java`); `setup` refuses a selection that leaves the
   dependency unchecked rather than adding it silently, since its version is yours to choose.

2. **Build the app that opens the environment** (only needs to be done once, or again if
   `main.rs`/`Cargo.toml` changes):
   ```bash
   cd .code-server/start
   cargo build --release
   ```

3. **Bring up the environment**:
   ```bash
   .code-server/start/target/release/start
   ```
   The first time it creates the container (`docker run`, with the workspace mounted); on
   subsequent runs it just ensures the container is running (`docker start`) and opens the window.
   No env var needs to be passed to run it from within the repo's own structure — image/container
   name and `START_WORKSPACE_DIR` have an automatically derived default.

What the host provides decides part of what you get inside, and `start` adapts instead of failing:
`docker` in the container is a nested rootless daemon that needs `/dev/fuse` and `/dev/net/tun` —
without `/dev/fuse` the daemon stays down and `docker` simply isn't available — and the `android`
stack's headless emulator needs `/dev/kvm`, which exists on Linux hosts with VT-x/AMD-V but has no
equivalent under Docker Desktop's macOS/Windows VM. The container is also capped at 8g of memory
(plus 2g of swap) and pinned to half the host's cores.

## Long-term memory (`ai-memory`)

[`ai-memory`](https://github.com/akitaonrails/ai-memory) gives the agent memory that outlives a
session: quit mid-task, come back tomorrow (or in a different agent CLI), and the next session opens
with a handoff instead of a blank slate. The memory itself is plain markdown in a git repo —
`grep`-able and readable without any of this — kept on the container's persistent volume at
`/config/ai-memory`, not in your repository.

**It is off until you ask for it, per project.** The switch is a marker file at the repo root:

```bash
printf '[project]\nproject_strategy = "repo-root"\n' > .ai-memory.toml
```

Then restart the container — the marker is read at boot. `ai-memory status` shows the paths and
counts once it is up.

Without that file nothing runs and nothing is recorded: the server never starts listening, the
installed hooks are in allowlist mode and emit no event at all, and the agent's sandbox is not
widened to reach the store. Forgetting the marker costs you recall, never confidentiality.

Two things worth knowing before you turn it on. **Memory is per project**, because the server runs
inside this project's container — a second project gets its own, and they never see each other.
And **no LLM provider is configured**, so nothing captured leaves the machine: you get full-text,
entity and graph-neighbour search plus rule-based summaries. Adding a provider buys consolidated
pages and contradiction linting, and costs sending captured prompts and tool excerpts to it.
