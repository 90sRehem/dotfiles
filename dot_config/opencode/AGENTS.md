# Agent Guidelines

Principles for Forge, Herald, Scout, and Ward agents to reduce common LLM mistakes while maintaining simplicity, precision, and execution discipline.

**Core Tradeoff:** These rules favor correctness and clarity over speed. Use judgment for trivial tasks.

---

## 10 Essential Principles

1. **Think Before Coding** — State assumptions, present options, call out simpler approaches
2. **Simplicity First** — Solve with minimum code; no unnecessary abstractions or features
3. **Surgical Changes** — Change only what's required; don't "improve" adjacent code
4. **Goal-Driven Execution** — Work with verifiable success criteria; write tests before fixes
5. **Research → Plan → Implement** — Default workflow for non-trivial tasks
6. **Context Discipline** — Load on demand; use `file:line` references; avoid pollution
7. **Mandatory Subagent Delegation** — Delegate exploration, broad analysis, multi-file searching
8. **Execution Principles** — Execute before describing; verify results; fail transparently
9. **Clean Output Discipline** — Avoid verbosity; prefer clarity; stay focused
10. **Success Signals** — Fewer diffs, less overengineering, more clarification, simpler code
11. **Knowledge Capture** — After significant sessions (feature complete, architectural decision, lesson discovered), write a log to the projets-wiki vault. Structure: what, why, lessons, pending.

---

## Quick Reference

| Principle    | Key Rule                                 |
| ------------ | ---------------------------------------- |
| Think Before | Don't assume; make reasoning explicit    |
| Simplicity   | If 200 lines can be 50 → rewrite         |
| Surgical     | Every changed line must trace to request |
| Goal-Driven  | "Fix bug" → test failure → make pass     |
| Workflow     | Research → Plan → Implement              |
| Context      | Prefer `file:line` over full files       |
| Delegation   | Delegate exploration, analysis, grep     |
| Execution    | Execute before describing                |
| Output       | Avoid unnecessary verbosity              |
| Success      | Measure by fewer diffs, simpler code     |
| Knowledge    | Significant work → log to projets-wiki vault         |

---

## When to Delegate

**Always delegate:**

- Searching codebase (grep, glob, multiple files)
- Understanding modules or flows
- Analyzing 3+ files
- Answering: "Where is X?", "How does X work?", "What calls X?"
- Reviewing large diffs
- Running exploratory commands

**Never delegate:**

<!-- - Editing a single file -->
<!-- - Running known build/test/lint commands -->

- Simple, targeted operations

---

For detailed guidelines and examples, [→ see docs/coding-guidelines.md](docs/coding-guidelines.md)

## graphify

This project has a graphify knowledge graph at graphify-out/.

Rules:
- Before answering architecture or codebase questions, read graphify-out/GRAPH_REPORT.md for god nodes and community structure
- If graphify-out/wiki/index.md exists, navigate it instead of reading raw files
- After modifying code files in this session, run `python3 -c "from graphify.watch import _rebuild_code; from pathlib import Path; _rebuild_code(Path('.'))"` to keep the graph current

## projets-wiki

Vault de memória persistente em `~/Documents/dev/projets-wiki/`.

Rules:
- After completing significant work (feature, fix, architectural decision), write a session log to `~/Documents/dev/projets-wiki/<project>/logs/YYYY-MM-DD-<slug>.md`
- Log format: what was done, decisions made, lessons learned, pending items
- Decisions with long-term impact → also record in `~/Documents/dev/projets-wiki/<project>/architecture/decisions.md`
- Lessons about agent behavior, tooling, or workflow → record in `~/Documents/dev/projets-wiki/opencode/logs/`
- Do NOT write logs for trivial tasks (single-line fixes, config tweaks)
