# Agent Definitions

---

## Scout

Deep exploration, pattern analysis, broad codebase searches. Operates only when delegated by Herald or Sage.

Returns findings as structured JSON (schema in [protocol.md](protocol.md#scout)). Herald interprets and presents human-readable summaries.

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

### Commit Rules

- Returns `proposed_commit` JSON after implementation (schema in [protocol.md](protocol.md#forge-commit-proposal))
- Executes `git commit` ONLY after Gate G6 approval relay from Herald
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

- **HIGH**: Exploitable, data exposure, auth bypass
- **MEDIUM**: Requires specific conditions
- **LOW**: Best practice violation, low-risk

Output schema in [protocol.md](protocol.md#ward-security).

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

Output schema in [protocol.md](protocol.md#arbiter-quality).
