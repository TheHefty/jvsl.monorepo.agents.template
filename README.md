# jvsl.monorepo.agents.template

Reusable template for a [code-server](https://github.com/coder/code-server)-based dev container,
meant to be dropped into other monorepos. It ships code-server itself, the Claude Code CLI,
`ai-jail`, and Docker-out-of-Docker already set up, plus a selectable set of tech stacks.

It is **not** an application — there's no product code here, only the tooling that builds and
launches the dev environment. Everything lives under `.code-server/` (mirroring how a
`.devcontainer/` would work), so a monorepo that adopts this template keeps its own repo root
free.

## Quick start

Prerequisites on the host: `jq`, `whiptail`, `docker` (for `setup`); Rust/`cargo` + the Tauri Linux
libs (for `start` — see [`.code-server/docs/OVERVIEW.md`](.code-server/docs/OVERVIEW.md) for the
exact packages per distro).

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
- [`.code-server/docs/OVERVIEW.md`](.code-server/docs/OVERVIEW.md) — full design rationale: every
  decision made, the `core/`/`stacks/` structure, the manifest format, and build issues already
  hit and fixed. Treated as the authoritative, up-to-date spec.

## License

[MIT](LICENSE)
