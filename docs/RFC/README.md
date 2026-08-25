# RFCs

A record of decisions that were expensive to make, kept so the next person does not pay for them
twice. An RFC captures *why* — the problem, what was rejected, what it costs — and stays true
after the code moves on. It is not a description of the current system: that is
[`docs/OVERVIEW.md`](../OVERVIEW.md), and the template's own
[`.code-server/docs/OVERVIEW.md`](../../.code-server/docs/OVERVIEW.md).

## When you need one

One is written unconditionally at project initialization: the purpose interview becomes RFC
`0001`, and everything after is built on it. See "Project Initialization" in
[`../../CLAUDE.md`](../../CLAUDE.md).

**This repository is the template, not a project built on it**, so this folder carries the
scaffold and nothing else. An empty `RFC/` here is the correct state — the numbered files start
in the repositories that adopt the template. Don't backfill this one with the decisions behind
the template itself; those live in
[`.code-server/docs/OVERVIEW.md`](../../.code-server/docs/OVERVIEW.md), which versions with the
template rather than with a consumer of it.

Otherwise, write an RFC before a change that:

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

1. **Start from a theme.** A release is about one thing, said in one sentence; if the sentence
   needs an "and", it is two themes and it gets two RFCs. See "Releases have a theme" in
   [`../RULES.md`](../RULES.md).
2. Copy [`0000-template.md`](0000-template.md) to `NNNN-short-kebab-title.md`, where `NNNN` is the
   next free number. Numbers are never reused, including by a rejected RFC.
3. Open it as a pull request, like everything else here. The discussion belongs in the PR, where
   it is attached to the diff.
4. **Agree the RFC with the user before writing a single scenario.** This is a gate, not a
   formality: an RFC settled after the scenarios exist is a justification for them.
5. **Write the acceptance scenarios in Gherkin, and agree those too before any code.** They live
   with the RFC in the same pull request. Scenarios written after an implementation describe what
   was built, not what was wanted, and nobody can tell the difference by reading them.
6. Merge with the status set to what was actually decided. **A rejected RFC is merged too**: the
   argument against is the part that stops the idea coming back every six months.

The two gates are the point of the sequence, and they survive the autonomy rule in
[`../../CLAUDE.md`](../../CLAUDE.md) — waiting at a defined handoff is not the same as stopping to
ask about the obvious.

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
