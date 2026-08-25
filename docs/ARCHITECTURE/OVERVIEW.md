# Architecture overview

What the system is, right now: its parts, what each one owns, how they reach each other, and where
it breaks. Written so that someone arriving on their first day can find the seam they need without
reading the code first.

## What this is not

- **Not the dev environment's architecture.** The container, the sandbox, the nested Docker daemon
  and the launcher belong to the template, and they are documented in
  [`../../.code-server/docs/OVERVIEW.md`](../../.code-server/docs/OVERVIEW.md), which versions with
  the template rather than with this project. Do not restate it here; link it.
- **Not a decision log.** Why a shape was chosen, what was rejected, and what it cost live in
  [`../RFC/`](../RFC/), and stay true after the code moves on. This file describes the present and
  is rewritten whenever the present changes.
- **Not [`../OVERVIEW.md`](../OVERVIEW.md)**, which is how to use the template as a consumer.
  Three files in this repository are called `OVERVIEW.md`; check which one you are editing.

## Keeping it true

An architecture document that lags the system is worse than none, because it is believed. The rule
that keeps it honest: **an RFC that changes the shape updates this file in the same pull request.**
The RFC says why it changed; this says what it is now. If they disagree, this one is wrong.

## Sections to fill

A project fills these in as it grows. Empty is a fine answer while something does not exist yet;
a section that quietly describes an intention rather than the code is not.

### Context and boundaries

What the system is responsible for and what it deliberately is not. Who and what it talks to across
its edges — users, other services, third parties — and which of those it trusts.

### Components

One entry per part that can fail independently. What it owns, what it depends on, and what it would
take down with it. Name the thing that is not obvious from the directory layout.

### Data

What is stored, where, and for how long. If the project processes personal data, this is the same
map recorded in RFC `0001` — keep one of them and link the other, never two that can disagree. See
Security in [`../RULES.md`](../RULES.md).

### Runtime and deployment

How it runs in production and how that differs from how it runs here. Where configuration comes
from, what is required to be present, and what it does when something is missing.

### Failure modes and observability

How the system fails, how anyone finds out, and what they look at first. The three worst failure
scenarios named in each RFC accumulate here once they are real, along with the signals that catch
them — see Observability in [`../RULES.md`](../RULES.md).

### Seams

Where the system was deliberately left able to change: the i18n catalogue, the theming and
accessibility tokens, an interface with a second implementation in mind. A seam nobody documents
is a seam the next change routes around.

### Open edges

What is known to be unfinished or wrong, and what it would take to close. This is the section that
makes the rest trustworthy: a document with no open edges is either finished or unmaintained, and
it is rarely finished.

---

**In this repository this file is a scaffold.** It is the template, not a project built on it, so
there is no product architecture to describe — the same reason [`../RFC/`](../RFC/) carries no
numbered files. The sections start being filled in the repositories that adopt the template.
