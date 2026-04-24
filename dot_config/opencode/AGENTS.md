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
