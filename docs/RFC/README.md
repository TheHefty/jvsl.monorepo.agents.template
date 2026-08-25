# RFCs

A record of decisions that were expensive to make, kept so the next person does not pay for them
twice. An RFC captures *why* — the problem, what was rejected, what it costs — and stays true
after the code moves on. It is not a description of the current system: that is
[`docs/OVERVIEW.md`](../OVERVIEW.md), and the template's own
[`.code-server/docs/OVERVIEW.md`](../../.code-server/docs/OVERVIEW.md).

## When you need one

Write an RFC before a change that:

- **alters a contract other things depend on** — the stack manifest's shape, the launcher's
  interface, anything a consuming repo builds on;
- **widens the agent's sandbox**, or moves a decision from the image into a project's config (or
  back);
- **adds something always-on** — a service, a daemon, a boot hook — that every project inherits;
- **adds a dependency fetched at build time**, or changes how one is pinned;
- **changes the release or versioning discipline** — what triggers a release, how the submodule is
  bumped, what a tag promises.

## When you don't

Most work. A bug fix, a doc correction, a stack version bump, a new stack that follows the
existing pattern, anything reversible by a revert. Writing an RFC for these is not caution, it is
ceremony —
and a process applied to everything is a process that gets applied to nothing.

The test is not size. It is whether a future reader, finding the result and disagreeing with it,
would be able to reconstruct why it was done that way. If the commit message can carry that, the
commit message is enough.

## How

1. Copy [`0000-template.md`](0000-template.md) to `NNNN-short-kebab-title.md`, where `NNNN` is the
   next free number. Numbers are never reused, including by a rejected RFC.
2. Open it as a pull request, like everything else here — see [`../RULES.md`](../RULES.md). The
   discussion belongs in the PR, where it is attached to the diff.
3. Merge with the status set to what was actually decided. **A rejected RFC is merged too**: the
   argument against is the part that stops the idea coming back every six months.

## Status

| Status | Meaning |
|---|---|
| `Draft` | Open for discussion; nothing has been decided. |
| `Accepted` | Decided. Implementation may or may not have happened yet. |
| `Rejected` | Decided against, with the reasoning kept. |
| `Superseded by NNNN` | A later RFC replaced this decision. The old one is not edited to match. |

An accepted RFC is never rewritten to track what the code became. If the decision changes, that
is a new RFC that supersedes it — the trail of what was believed, and when, is worth more than a
tidy file.
