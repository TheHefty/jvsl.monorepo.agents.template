# Overview

Dev environment template based on [code-server](https://github.com/coder/code-server), with the
Claude Code CLI, `ai-jail`, and Docker-out-of-Docker already set up. Everything lives inside
`.code-server/` (doesn't clutter the root of the monorepo that adopts this template) and is
controlled by two executables: `setup` (chooses the tech stacks that go into the image) and
`start` (brings up the environment in a native window).

The full design — decisions made, the structure of `core/`/`stacks/`, the manifest format, bugs
already hit and fixed — is in
[`.code-server/docs/OVERVIEW.md`](../.code-server/docs/OVERVIEW.md). This document is just the
"how to use it" summary.

## Starting the environment

Prerequisites on the host: `jq`, `whiptail`, `docker` (for `setup`); Rust/`cargo` + the Tauri libs
for Linux (for `start` — see `.code-server/docs/OVERVIEW.md` for the exact packages per distro).

1. **Build the image** (choose the monorepo's stacks, generate the Dockerfile, and build it):
   ```bash
   .code-server/setup
   ```
   Rerun `setup` any time you want to add or remove a stack.

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
