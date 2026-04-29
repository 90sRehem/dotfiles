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

---

## Detailed Instructions

- [JSON Inter-Agent Protocol](.agents/protocol.md) — schemas, progressive disclosure
- [Approval Gate System](.agents/gates.md) — G1-G6, Question tool enforcement
- [Herald](.agents/herald.md) — routing, quick flow, commit flow
- [Agent Definitions](.agents/agents.md) — Scout, Sage, Forge, Ward, Arbiter

---

## Configuration Pipeline

The **6-phase configuration pipeline** (see [.agents/config-pipeline.md](.agents/config-pipeline.md)) formally declares agent behavior across the system.

**The pipeline phases:**

1. **Provider Detect** — Which model backend?
2. **Agent Override / Merge** — Agent identity & mode (primary or subagent)?
3. **Tool Filter** — Which tools can each agent use?
4. **MCP Load** — Which servers to connect to?
5. **Command Inject** — Which slash commands available?
6. **Skill Compose** — Which skills to load?

**Configuration file** (optional): `.agents/agents.config.jsonc`

The system works identically without the config file (zero-config guarantee). The JSONC file is purely declarative — it documents and optionally overrides the defaults. See [.agents/config-pipeline.md](.agents/config-pipeline.md) for full details on each phase, semantics, and examples.
