# Agent Guidelines

Multi-agent system: Herald (coordinator), Scout (explorer), Sage (planner), Forge (executor), Ward (security), Arbiter (quality).

**Core tradeoff:** Correctness and clarity over speed. Use judgment for trivial tasks.

> ⚠️ **All agents MUST emit a JSON envelope as their final output.** Format defined in `.agents/protocol.md`. No exceptions — free-text responses are invalid.

---

## Principles

| Principle | Rule |
|-----------|------|
| Think Before | Don't assume; make reasoning explicit |
| Simplicity | If 200 lines can be 50 → rewrite |
| Surgical | Every changed line must trace to request |
| Goal-Driven | "Fix bug" → test failure → make pass |
| Workflow | Research → Plan → Implement |
| Context | Prefer `file:line` over full files |
| Delegation | Delegate exploration, analysis, grep |
| Execution | Execute before describing |
| Output | Avoid unnecessary verbosity |
| Knowledge | Significant work → log to projets-wiki vault |
| Context Awareness | Monitor context window usage; warn at 80%, pause at 95% |

---

## Context Management

Agents must actively monitor their context window usage to prevent silent degradation or token exhaustion.

**See also:** [Context Window Monitor](.agents/agents.md#context-window-monitor) — detailed hook interface and behavior specs

Key thresholds:

- **80% usage (warn)**: Agent emits warning but continues execution
- **95% usage (pause)**: Agent stops and waits for user decision (continue, compact, or save-and-stop)

The context monitor hook is nullable — if disabled, monitoring has no effect. Detailed behavior specs are in the agent definitions file.

---

## Delegation

**Always delegate:** codebase search, module analysis, 3+ files, "Where is X?", large diffs, exploratory commands.

**Never delegate:** single-file edits, targeted known commands.

**Agent availability:** Agent availability depends on `.agents/agent-variants.json`. Check this file to determine which agents are enabled in the current workspace.

---

## Integrations

**graphify** — knowledge graph at `graphify-out/`
- Before architecture questions: read `graphify-out/GRAPH_REPORT.md`
- If `graphify-out/wiki/index.md` exists, navigate it instead of raw files
- After modifying code: run `python3 -c "from graphify.watch import _rebuild_code; from pathlib import Path; _rebuild_code(Path('.'))"`

**projets-wiki** — persistent memory vault at `~/Documents/dev/projets-wiki/`
- After significant work: log to `<project>/logs/YYYY-MM-DD-<slug>.md`
- Long-term decisions: `<project>/architecture/decisions.md`
- Agent/tooling lessons: `opencode/logs/`
- Skip logs for trivial tasks

**SESSION_LOG.md** — append-only execution audit trail
- Location: working directory root
- Herald appends `started` before delegation, `completed`/`failed`/`skipped` after
- Enables recovery from interruptions; see [Herald recovery protocol](.agents/herald.md#recovery-after-interruption)

---

## Detailed Instructions

- [JSON Inter-Agent Protocol](.agents/protocol.md) — schemas, progressive disclosure
- [Approval Gate System](.agents/gates.md) — G1-G6, Question tool enforcement
- [Herald](.agents/herald.md) — routing, quick flow, commit flow
- [Agent Definitions](.agents/agents.md) — Scout, Sage, Forge, Ward, Arbiter


