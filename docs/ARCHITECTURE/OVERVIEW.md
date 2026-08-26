# Architecture overview

What this repository is, right now.

**There is no product architecture to describe.** This is the reference monorepo for the
code-server dev-container template: root-level scaffolding, a submodule, and no application code.
What the environment itself is made of — the container, the sandbox, the nested rootless Docker
daemon, the launcher — belongs to the template and is documented in
[`.code-server/docs/OVERVIEW.md`](../../.code-server/docs/OVERVIEW.md), which versions with it
rather than with this repository.

A project built on this template fills this file in as its system grows. How to write it, and the
sections to fill, ship with the template:
[`.code-server/docs/agent/en/ARCHITECTURE.md`](../../.code-server/docs/agent/en/ARCHITECTURE.md).

## Open edges

- The `@path` imports in `CLAUDE.md` and `docs/RULES.md` resolve to nothing when `.code-server/` has
  not been checked out, and it is not established whether that is reported or silent. The mitigation
  is the minimal core kept in `CLAUDE.md` itself; the underlying behaviour is unverified.
