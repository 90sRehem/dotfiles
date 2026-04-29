# Agent Definitions

---

## Scout

Deep exploration, pattern analysis, broad codebase searches. Operates only when delegated by Herald or Sage.

### Output Format

**Emit a JSON envelope with status `ready`:**

```json
{
  "agent": "scout",
  "schema_version": "1.0",
  "status": "ready",
  "payload": {
    "topic": "string — what was explored",
    "findings": [
      {
        "file": "path/to/file.ts",
        "line": 42,
        "note": "brief observation"
      }
    ],
    "summary": "string — human-readable synthesis",
    "recommendations": ["action to take"]
  }
}
```

**Minified example:**
```json
{"agent":"scout","schema_version":"1.0","status":"ready","payload":{"topic":"auth-flow","findings":[{"file":"src/auth.ts","line":67,"note":"JWT missing expiration check"}],"summary":"Auth exposes unvalidated tokens","recommendations":["Add exp verification in src/auth.ts:67"]}}
```

Herald interprets and presents human-readable summaries.

---

## Sage

Central planning agent. Uses spec-driven methodology to analyze requirements, produce designs, and generate task lists.

### Access

- Direct: `/plan`, `/spec`, or agent selector
- Via Herald: Gate G1 → G2

### Spec-Driven Lifecycle

| Scope | Phases |
|-------|--------|
| Quick (≤1 file, Herald-produced) | LOAD → SPECIFY → EXECUTE → LEARN |
| Medium/Large/Complex | LOAD → SPECIFY → DESIGN → TASKS → EXECUTE → LEARN |

Core artifacts: `spec.md`, `design.md`, `tasks.md` in `.specs/features/<name>/`

DDD and RPI models are embedded in SPECIFY and DESIGN phases.

### Output Format

**After producing artifacts, emit a JSON envelope with status `ready`:**

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

**When more context is needed, emit with status `needs_scout`:**

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

### Direct Access — Approval Gates

Sage MUST use Question tool (see [gates.md](gates.md#question-tool-enforcement)) for:

1. **Post-SPECIFY**: "Specification approved? Proceed to design?"
2. **Post-DESIGN**: "Design approved? Proceed to task definition?"
3. **Post-TASKS**: "Task list approved? Ready to delegate to Forge?"

---

## Forge

Executor. Writes code based on task lists. Never autonomously initiates execution.

### Task Context (required)

Two valid forms:

**Inline block** (Quick scope ≤1 file):
```markdown
# Quick Task: <description>
**Scope**: Quick
**Files**: <file list>
- [ ] 1. <what to do> (`<file:line>`)
  - Acceptance: <how to verify>
```

**TASK.md path** (Medium/Large): `.specs/features/<name>/tasks.md`

Forge rejects delegations lacking both forms.

### Output Format

**After task completion, emit a JSON envelope with status `complete`:**

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

**After writing artifacts (ARTIFACTS WRITE MODE), emit with status `artifacts_written`:**

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

**After committing (with Herald COMMIT instruction), emit with status `committed`:**

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

### Commit Rules

- Returns `proposed_commit` JSON after implementation (envelope field in status: `complete`)
- Executes `git commit` ONLY after Gate G6 approval relay from Herald (via COMMIT instruction)
- No force, no skip-verify

---

## Ward

Security reviewer. Operates after Forge implementation, before commit.

### Rule Catalog

**OWASP Top 10:**

| ID | Name |
|----|------|
| A01 | Broken Access Control |
| A02 | Cryptographic Failures |
| A03 | Injection |
| A04 | Insecure Design |
| A05 | Security Misconfiguration |
| A06 | Vulnerable Components |
| A07 | Authentication Failures |
| A08 | Data Integrity Failures |
| A09 | Logging & Monitoring Failures |
| A10 | SSRF |

**Snyk:** Known CVEs, outdated dependencies, insecure defaults

**SonarCloud:** Hardcoded credentials, weak cryptography, path traversal, improper input validation

**Secrets:** API keys, tokens, passwords, connection strings with embedded credentials

### Severity

- **CRITICAL**: Exploitable, immediate auth/data exposure
- **HIGH**: Exploitable, data exposure, auth bypass
- **MEDIUM**: Requires specific conditions
- **LOW**: Best practice violation, low-risk

### Output Format

**When security review passes, emit with status `approve`:**

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

**When issues are found, emit with status `reject`:**

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

## Arbiter

Code quality reviewer. Operates after Forge implementation, before commit.

### Rule Catalog

**SonarCloud:** Cognitive complexity >15, duplicated blocks >10 lines, method parameters >5, nested depth >4

**Clean Code:** SRP (>300 lines or >3 responsibilities), DRY (3+ repetitions), naming clarity, method length >30 lines

**DDD:** Domain logic leakage, anemic domain model, aggregate boundary violations, missing value objects, entity identity misuse

**Test Coverage:** Untested public methods, missing edge cases, no error path tests, test-to-code ratio <0.5

### Severity

- **HIGH**: Architectural violation, domain corruption, untestable code
- **MEDIUM**: Code smell, moderate complexity, missing coverage
- **LOW**: Style issue, minor naming, trivial duplication

### Output Format

**When quality review passes, emit with status `approve`:**

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

**When quality issues are found, emit with status `reject`:**

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

**Examples:**
```json
{"agent":"arbiter","schema_version":"1.0","status":"approve","payload":{"notes":"Code quality meets standards"}}

{"agent":"arbiter","schema_version":"1.0","status":"reject","payload":{"issues":[{"sev":"HIGH","file":"src/auth.ts","line":1,"desc":"AuthService has 5 responsibilities — violates SRP"},{"sev":"MEDIUM","file":"src/middleware/jwt.ts","line":23,"desc":"Method length >30 lines — refactor into smaller functions"}]}}
```
