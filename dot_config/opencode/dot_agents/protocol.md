# JSON Inter-Agent Protocol

**Source of truth for inter-agent communication.** `agents.md` instructs agents to emit these envelopes; `herald.md` defines parsing logic.

## Universal Envelope

All agents emit exactly this root structure:

```json
{
  "agent": "<scout|sage|forge|ward|arbiter>",
  "schema_version": "1.0",
  "status": "<agent-specific-status>",
  "payload": { }
}
```

**Herald routing:** `envelope.agent` + `envelope.status` → immediate action. `payload` only parsed if needed.

---

## Scout Schema

**Status values:** `ready`

**Full schema:**
```json
{
  "agent": "scout",
  "schema_version": "1.0",
  "status": "ready",
  "payload": {
    "topic": "string — exploration topic",
    "findings": [
      {
        "file": "path/to/file.ts",
        "line": 42,
        "note": "observação relevante"
      }
    ],
    "summary": "string — human-readable synthesis of findings",
    "recommendations": ["string — recommended action"]
  }
}
```

**Minified example:**
```json
{"agent":"scout","schema_version":"1.0","status":"ready","payload":{"topic":"auth-flow","findings":[{"file":"src/auth.ts","line":67,"note":"JWT decode missing expiration check"}],"summary":"Auth flow exposes unvalidated tokens","recommendations":["Add exp verification in src/auth.ts:67"]}}
```

---

## Sage Schema

**Status values:** `ready` | `needs_scout`

**Status: ready**
```json
{
  "agent": "sage",
  "schema_version": "1.0",
  "status": "ready",
  "payload": {
    "change_name": "string — feature slug",
    "artifacts": ["string — spec artifact paths"],
    "scope": "quick|medium|large",
    "key_decisions": ["string — architectural decision"],
    "task_count": 0,
    "next_action": "proceed_to_g2"
  }
}
```

**Status: needs_scout**
```json
{
  "agent": "sage",
  "schema_version": "1.0",
  "status": "needs_scout",
  "payload": {
    "topic": "string — exploration topic for Scout",
    "reason": "string — why more context is needed"
  }
}
```

**Examples:**
```json
{"agent":"sage","schema_version":"1.0","status":"ready","payload":{"change_name":"add-jwt-auth","artifacts":[".specs/features/add-jwt-auth/spec.md",".specs/features/add-jwt-auth/design.md",".specs/features/add-jwt-auth/tasks.md"],"scope":"medium","key_decisions":["JWT with RS256","Refresh token in httpOnly cookie"],"task_count":12,"next_action":"proceed_to_g2"}}

{"agent":"sage","schema_version":"1.0","status":"needs_scout","payload":{"topic":"database-schema","reason":"No schema found in initial exploration"}}
```

---

## Forge Schema

**Status values:** `complete` | `artifacts_written` | `committed`

**Status: complete** (after task execution)
```json
{
  "agent": "forge",
  "schema_version": "1.0",
  "status": "complete",
  "payload": {
    "tasks_done": 0,
    "files_changed": ["string — modified paths"],
    "proposed_commit": {
      "type": "feat|fix|refactor|docs|chore",
      "scope": "string",
      "message": "string — full commit message",
      "files": ["string — paths to include in commit"]
    }
  }
}
```

**Status: artifacts_written** (after ARTIFACTS WRITE MODE)
```json
{
  "agent": "forge",
  "schema_version": "1.0",
  "status": "artifacts_written",
  "payload": {
    "feature": "string — feature name",
    "files_created": ["string — created paths"]
  }
}
```

**Status: committed**
```json
{
  "agent": "forge",
  "schema_version": "1.0",
  "status": "committed",
  "payload": {
    "commit_hash": "string",
    "message": "string"
  }
}
```

**Example:**
```json
{"agent":"forge","schema_version":"1.0","status":"complete","payload":{"tasks_done":12,"files_changed":["src/auth.ts","src/middleware/jwt.ts"],"proposed_commit":{"type":"feat","scope":"auth","message":"feat(auth): add JWT authentication with RS256","files":["src/auth.ts","src/middleware/jwt.ts"]}}}
```

---

## Ward Schema

**Status values:** `approve` | `reject`

**Status: approve**
```json
{
  "agent": "ward",
  "schema_version": "1.0",
  "status": "approve",
  "payload": {
    "notes": "string — optional observations"
  }
}
```

**Status: reject**
```json
{
  "agent": "ward",
  "schema_version": "1.0",
  "status": "reject",
  "payload": {
    "issues": [
      {
        "sev": "CRITICAL|HIGH|MEDIUM|LOW",
        "rule": "string — e.g., OWASP-A01",
        "file": "string",
        "line": 0,
        "desc": "string — problem description"
      }
    ]
  }
}
```

**Examples:**
```json
{"agent":"ward","schema_version":"1.0","status":"approve","payload":{"notes":"No vulnerabilities found"}}

{"agent":"ward","schema_version":"1.0","status":"reject","payload":{"issues":[{"sev":"HIGH","rule":"OWASP-A07","file":"src/auth.ts","line":67,"desc":"JWT decode missing expiration check — token always valid"},{"sev":"MEDIUM","rule":"OWASP-A05","file":"src/middleware/jwt.ts","line":23,"desc":"Rate limit missing on login endpoint"}]}}
```

---

## Arbiter Schema

**Status values:** `approve` | `reject`

**Status: approve**
```json
{
  "agent": "arbiter",
  "schema_version": "1.0",
  "status": "approve",
  "payload": {
    "notes": "string — optional observations"
  }
}
```

**Status: reject**
```json
{
  "agent": "arbiter",
  "schema_version": "1.0",
  "status": "reject",
  "payload": {
    "issues": [
      {
        "sev": "HIGH|MEDIUM|LOW",
        "file": "string",
        "line": 0,
        "desc": "string — quality problem description"
      }
    ]
  }
}
```

---

## Herald Parsing Algorithm

```
1. Parse output as JSON → envelope
2. Switch envelope.agent:
   - "scout"   → SCOUT_FINDINGS: inject payload.findings to next Sage
   - "sage"    → switch envelope.status:
                    "ready"       → present G2 with payload.change_name, payload.artifacts
                    "needs_scout" → delegate Scout with payload.topic
   - "forge"   → switch envelope.status:
                    "complete"        → start Post-Forge Protocol (G4→G5→G6)
                    "artifacts_written" → present G3
                    "committed"       → execute POST-EXECUTION
   - "ward"    → switch envelope.status:
                    "approve" → present G5
                    "reject"  → present findings to user (fix/dismiss/abort)
   - "arbiter" → switch envelope.status:
                    "approve" → present G6
                    "reject"  → present findings to user (fix/dismiss/abort)
3. If parse fails → log error, request agent to re-emit in correct format
```

---

## Progressive Disclosure Rules

Herald applies these rules when presenting agent findings:

| Severity | Display Rule |
|----------|-------------|
| CRITICAL | Always shown |
| HIGH | Always shown |
| MEDIUM | Shown if count > 0 |
| LOW | Only on explicit user request ("show all" or "show LOW items") |
| Raw JSON | Always available via "show raw output" |
