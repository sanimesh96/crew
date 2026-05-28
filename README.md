# Crew

```
> run crew content-factory on the topic: Why subagents beat single agents

Running crew "content-factory" on: Why subagents beat single agents
Roles: researcher → writer → editor
Budget: 100k tokens, 20 hops

✓ researcher done (~8k tokens) — 7 sources, structured brief
✓ writer done (~6k tokens) — 720-word draft with inline citations
✓ editor done (~4k tokens) — final polished post

---
TL;DR: Single-agent loops collapse under their own context. Subagents stay sharp because each one starts fresh.

# Why subagents beat single agents
...
```

**That's a 3-role org producing a finished artifact in under 60 seconds.**

Crew is a Claude Code subagent that runs *organizations* of agents — each with a role and responsibility you define — against a task. You describe the roles in plain English. Crew spawns them in order, passes outputs between them, and hands you the final deliverable.

It ships with one demo crew (`content-factory`) pre-installed. You build the rest.

## How it works

A "crew" is just a YAML file. Each role is one block. Here's `content-factory.yaml`:

```yaml
name: content-factory
description: Turns a topic into a polished, evidence-backed blog post
topology: supervisor-workers
budget: { max_tokens: 100000, max_hops: 20 }

roles:
  - name: researcher
    responsibility: |
      Find 5–10 credible recent sources. For each, capture key facts and
      counterarguments. Output a structured research brief with URLs.
    subagent_type: researcher
    tools: [WebSearch, WebFetch]

  - name: writer
    responsibility: |
      Take the brief, write a 600–900 word post. Technical readers, opinionated
      tone, inline citations. Flag missing citations as [CITATION NEEDED].
    subagent_type: general-purpose

  - name: editor
    responsibility: |
      Fact-check claims against the brief, tighten prose, add TL;DR. Ship final.
    subagent_type: reviewer
```

Crew reads it, spawns each role as a Claude Code subagent in sequence, and passes the previous role's artifact as input to the next. Sequential pipeline, supervisor-and-workers topology, hard token + hop budget.

## Three modes

```
list crews
crew create <name>
run crew <name> on <task>
```

**List** scans `~/.claude/orgs/*.yaml` and shows what you have.

**Create** walks you through defining a new crew — name, description, roles, responsibilities, tools. Saves a YAML you can edit later.

**Run** loads a crew, dispatches its roles on your task, streams progress, returns the final artifact.

## Install

One line, from anywhere — works in a fresh terminal or pasted into an LLM agent:

```bash
curl -fsSL https://raw.githubusercontent.com/sanimesh96/crew/main/install.sh | bash
```

Or clone it if you want to fork or customize:

```bash
git clone https://github.com/sanimesh96/crew.git && cd crew && ./install.sh
```

The installer writes:
- `~/.claude/agents/crew.md` — the Crew Conductor agent
- `~/.claude/orgs/content-factory.yaml` — a working demo crew

Restart Claude Code. Then try:

```
run crew content-factory on the topic: Why your inbox needs a triage agent
```

**You need:** [Claude Code](https://claude.com/claude-code). For research-style crews, the built-in `WebSearch` and `WebFetch` tools are enough.

## Why bother

Single-agent prompting hits a ceiling. The model has to research, write, *and* self-edit in one context — quality drops as the conversation grows.

Crew splits work the way humans do: one agent per job, each with a fresh context window, passing finished artifacts down the line. The researcher doesn't try to write. The writer doesn't try to fact-check. The editor doesn't try to source new material. Each does one thing well.

You get higher quality output for the same token budget, with a clear audit trail of who did what.

## Customizing

Crews are just YAML. Edit `~/.claude/orgs/<name>.yaml` directly — change responsibilities, swap tools, reorder roles, raise the budget. Re-run.

Each role's `subagent_type` should match one of Claude Code's built-in agent types (`researcher`, `coder`, `reviewer`, `tester`, `system-architect`, `planner`, `general-purpose`, etc.). If unsure, use `general-purpose`.

## License

MIT.
