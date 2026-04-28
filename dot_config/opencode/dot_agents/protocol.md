# JSON Inter-Agent Protocol

All inter-agent communication uses compact JSON to reduce parsing overhead for Herald and enable structured logging.

## Purpose

Standardizes output from Scout, Ward, Arbiter, and Forge, allowing Herald to:
- Parse agent findings programmatically
- Apply progressive disclosure rules (filter by severity)
- Present human-readable summaries
- Log structured decisions

---

## Schemas

### Scout

```json
{
  "findings": [
    {
      "file": "string — relative file path",
      "line": "number or null",
      "action": "modify | create | delete | read",
      "note": "string — brief description of what action to take"
    }
  ],
  "summary": "string — human-readable summary of findings"
}
```

Action enum: `modify` (file exists, changes needed) | `create` (new file) | `delete` (remove) | `read` (context only)

### Ward (Security)

```json
{
  "verdict": "PASS | WARN | REJECT",
  "issues": [
    {
      "severity": "HIGH | MEDIUM | LOW",
      "rule": "string — e.g., 'OWASP-A01-BrokenAccessControl'",
      "file": "string",
      "line": "number",
      "desc": "string"
    }
  ]
}
```

### Arbiter (Quality)

```json
{
  "verdict": "PASS | WARN | REJECT",
  "issues": [
    {
      "type": "DDD | clean-code | sonar | coverage",
      "rule": "string — e.g., 'UntestedPublicMethod'",
      "file": "string",
      "line": "number",
      "desc": "string"
    }
  ]
}
```

### Forge (Commit Proposal)

```json
{
  "proposed_commit": {
    "type": "feat | fix | refactor | chore | docs | test",
    "scope": "string — feature area",
    "message": "string — full commit message",
    "files": ["string — relative file paths"],
    "breaking": false
  }
}
```

### Sage

Returns a `SAGE_STATUS` block (structured markdown, not JSON):

- `SAGE_STATUS: READY` — artifacts produced; includes path and artifact contents
- `SAGE_STATUS: NEEDS_SCOUT` — more context needed; includes topic for Scout to explore

Herald parses the status and routes accordingly.

---

## Progressive Disclosure Rules

Herald applies these rules when presenting agent findings:

| Severity | Display Rule |
|----------|-------------|
| HIGH | Always shown |
| MEDIUM | Shown if count > 0 |
| LOW | Only on explicit user request ("show all" or "show LOW items") |
| Raw JSON | Always available via "show raw output" |
