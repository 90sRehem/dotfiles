# Progress Reporting

## Format for Subagent Reports

When a subagent completes work, return a structured summary:

```
## Result: {task title}
- **Status:** completed | partial | blocked
- **Files changed:** {list with line references}
- **Key decisions:** {any non-obvious choices made}
- **Tests:** {pass/fail status}
- **Blockers:** {if any}
```

## During Implementation

- Mark TodoWrite items as `in_progress` when starting, `completed` when done.
- One task in progress at a time.
- Report blockers immediately rather than guessing solutions.
