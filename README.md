# jvsl.monorepo.agents.template

A reference monorepo that has already adopted the
[code-server](https://github.com/coder/code-server)-based dev container template — code-server
itself, the Claude Code CLI, `ai-jail`, Docker-out-of-Docker, and a selectable set of tech stacks,
all set up.

The template itself lives in its own repo,
[`jvsl.env.agents.code-server`](https://github.com/TheHefty/jvsl.env.agents.code-server), vendored
here as a git submodule at `.code-server/` (mirroring how a `.devcontainer/` would work). Splitting
it out this way means updating the template is a `git submodule update` (bump the pinned commit),
not a rebase against this repo's own history. This repo itself is **not** an application — there's
no product code here, only the root-level scaffolding a consuming monorepo keeps outside the
submodule.

## Quick start

Prerequisites on the host: `jq`, `whiptail`, `docker` (for `setup`); Rust/`cargo` + the Tauri Linux
libs (for `start` — see [`.code-server/docs/OVERVIEW.md`](.code-server/docs/OVERVIEW.md) for the
exact packages per distro).

Clone with `git clone --recurse-submodules`, or `git submodule update --init` after a plain clone —
`.code-server/` is empty until the submodule is checked out.

1. **Build the image** — interactive stack selection, generates `.code-server/Dockerfile`, and
   builds it:
   ```bash
   .code-server/setup
   ```
   Rerun any time you want to add or remove a stack.

2. **Build the launcher app** (only needed once, or again after editing
   `.code-server/start/src/main.rs`):
   ```bash
   cd .code-server/start && cargo build --release
   ```

3. **Bring up the environment**:
   ```bash
   .code-server/start/target/release/start
   ```
   Opens a native window pointed at code-server, creating the container on first run and just
   starting it on subsequent ones. No configuration is needed as long as it stays inside the repo
   structure it was built in.

## Available stacks

- `java`
- `cpp`
- `dotnet`
- `python`
- `golang`
- `ruby`
- `php`
- `node`

Select/change them by rerunning `.code-server/setup`. None of them are mandatory — deselecting
everything builds an image with just the core layer (code-server, Claude Code CLI, `ai-jail`,
Docker-out-of-Docker).

## Docs

- [`docs/OVERVIEW.md`](docs/OVERVIEW.md) — short "how to use this template" guide.
- [`.code-server/docs/OVERVIEW.md`](.code-server/docs/OVERVIEW.md) — inside the submodule: full
  design rationale for the template itself — every decision made, the `core/`/`stacks/` structure,
  the manifest format, and build issues already hit and fixed. Treated as the authoritative,
  up-to-date spec for anything under `.code-server/`; versions together with
  [`jvsl.env.agents.code-server`](https://github.com/TheHefty/jvsl.env.agents.code-server), not
  with this repo.

## License

[MIT](LICENSE)
