# Configuration Pipeline

The **configuration pipeline** is a declarative, 6-phase model for configuring the multi-agent system. It defines how agents are provisioned, modeled, filtered, connected, and extended.

The pipeline is **optional and zero-config** — the system works identically without a config file. All phases have sensible defaults. When present, the JSONC file at `.agents/agents.config.jsonc` formalizes and overrides these defaults.

## Pipeline Flow

```
┌──────────────────────────────────────┐
│  Phase 1: Provider Detect            │  Which model backend?
│         ↓                            │
│  Phase 2: Agent Override / Merge     │  Who are the agents?
│         ↓                            │
│  Phase 3: Tool Filter                │  What can they use?
│         ↓                            │
│  Phase 4: MCP Load                   │  Which servers?
│         ↓                            │
│  Phase 5: Command Inject             │  Which slash commands?
│         ↓                            │
│  Phase 6: Skill Compose              │  Which skills?
└──────────────────────────────────────┘
```

Each phase is independent but ordered — earlier phases feed later ones. All phases are optional; when absent, the system assumes defaults.

---

## Phase 1: Provider Detect

**Purpose**: Declare which model backend(s) the system uses.

**Semantics**: A provider is a backend identity (e.g., `"anthropic"`, `"openai"`, `"custom"`). This phase maps a default provider and per-agent overrides.

**Zero-Config Default**: `provider = "anthropic"` for all agents.

**Ordering Rationale**: Providers must be declared first because later phases (especially Phase 2) may reference them.

**Example JSONC Snippet**:

```jsonc
{
  "providers": {
    // Global default when no agent override is specified
    "default": "anthropic",
    // Per-agent overrides (optional)
    "overrides": {
      "scout": "anthropic",
      "ward": "anthropic"
    }
  }
}
```

**Notes**:
- If an agent is not listed in `overrides`, it inherits the `default` provider.
- Provider names are arbitrary strings; the system treats them as opaque identifiers.

---

## Phase 2: Agent Override / Merge / Remap

**Purpose**: Configure each agent's identity — display name, mode, model, and description.

**Semantics**: For each of the 6 agents (Herald, Scout, Sage, Forge, Ward, Arbiter), declare:
- `displayName`: Human-readable name (e.g., "Scout").
- `mode`: `"primary"` (respects UI model choice) or `"subagent"` (uses pinned model).
- `model`: Model identifier for `subagent` mode (e.g., `"claude-haiku-4"`); `null` for primary.
- `description`: One-line summary of the agent's role.

**Zero-Config Default**: All agents are `subagent` mode with pinned models as follows:
- Herald: `primary` mode (defers to user)
- Scout: `subagent`, `claude-haiku-4`
- Sage: `subagent`, `claude-opus-4`
- Forge: `subagent`, `claude-sonnet-4`
- Ward: `subagent`, `claude-haiku-4`
- Arbiter: `subagent`, `claude-sonnet-4`

**Ordering Rationale**: Agent identity must be defined early because later phases reference agent keys.

**Example JSONC Snippet**:

```jsonc
{
  "agents": {
    "herald": {
      "displayName": "Herald",
      "mode": "primary",
      "model": null,
      "description": "Coordinator and router"
    },
    "scout": {
      "displayName": "Scout",
      "mode": "subagent",
      "model": "claude-haiku-4",
      "description": "Codebase explorer and analyzer"
    },
    "sage": {
      "displayName": "Sage",
      "mode": "subagent",
      "model": "claude-opus-4",
      "description": "Strategic planner and analyst"
    },
    "forge": {
      "displayName": "Forge",
      "mode": "subagent",
      "model": "claude-sonnet-4",
      "description": "Code executor and implementer"
    },
    "ward": {
      "displayName": "Ward",
      "mode": "subagent",
      "model": "claude-haiku-4",
      "description": "Security and compliance auditor"
    },
    "arbiter": {
      "displayName": "Arbiter",
      "mode": "subagent",
      "model": "claude-sonnet-4",
      "description": "Quality gate and reviewer"
    }
  }
}
```

**Mode Semantics**:

| Mode | Behavior | Example |
|------|----------|---------|
| `primary` | Agent uses the model selected in the user's UI. Herald is the only primary agent. | User selects "Claude 3.5 Sonnet" in UI → Herald uses Sonnet |
| `subagent` | Agent uses its pinned `model` value, ignoring UI selection. | Scout always uses Haiku, regardless of UI |

---

## Phase 3: Tool Filter

**Purpose**: Declare which tools each agent is permitted to use.

**Semantics**: Each agent has an `allow` list (tools it *can* use) and a `deny` list (tools it *cannot* use). Deny takes precedence. Supports wildcards (e.g., `"mcp_*"` matches all MCP-prefixed tools).

**Zero-Config Default**: All agents can use all tools (no filtering).

**Ordering Rationale**: Tool access must be defined after agents exist (Phase 2) but before tools are invoked.

**Precedence Rule**: `deny` overrides `allow`. If a tool matches both an `allow` pattern and a `deny` pattern, it is denied.

**Wildcard Syntax**: 
- `*` matches any substring
- `mcp_*` matches any tool starting with `mcp_`
- `*_session` matches any tool ending with `_session`

**Example JSONC Snippet**:

```jsonc
{
  "toolFilters": {
    // Sage: planning agent — no code execution, no mutations
    "sage": {
      "allow": [
        "mcp_Context7_*",
        "mcp_Webfetch",
        "mcp_Skill",
        "mcp_Read_session",
        "mcp_Handoff_session"
      ],
      "deny": [
        "Bash",
        "Write",
        "Edit",
        "MultiEdit",
        "Glob",
        "Grep"
      ]
    },
    // Scout: exploration — can read and search, cannot write
    "scout": {
      "allow": ["Bash", "Glob", "Grep", "Read", "mcp_*"],
      "deny": ["Write", "Edit", "MultiEdit"]
    },
    // Ward: audit only — minimal tools
    "ward": {
      "allow": ["Read", "Glob", "Grep", "Bash"],
      "deny": ["Write", "Edit", "MultiEdit"]
    }
  }
}
```

---

## Phase 4: MCP Load

**Purpose**: Declare which MCP (Model Context Protocol) servers each agent connects to.

**Semantics**: MCP servers provide additional tools, data sources, or integrations. This phase declares a default set and per-agent overrides.

**Zero-Config Default**: All agents connect to: `["context7", "webfetch", "skill", "tokenscope"]`.

**Ordering Rationale**: MCP servers are declared after tool filters (Phase 3) so that tools from MCP servers can be filtered in Phase 3 in future enhancements.

**Example JSONC Snippet**:

```jsonc
{
  "mcpServers": {
    // Default MCP servers for all agents
    "default": [
      "context7",
      "webfetch",
      "skill",
      "tokenscope"
    ],
    // Per-agent overrides
    "overrides": {
      "scout": [
        "context7",
        "webfetch",
        "skill",
        "tokenscope"
      ],
      "sage": [
        "context7",
        "webfetch",
        "skill",
        "tokenscope",
        "handoff",
        "read-session"
      ],
      "forge": [
        "context7",
        "webfetch",
        "skill",
        "tokenscope"
      ]
    }
  }
}
```

---

## Phase 5: Command Inject

**Purpose**: Declare which slash commands (user shortcuts) are available per agent.

**Semantics**: A command is a shorthand string like `/plan`, `/implement`, `/audit` that the user can invoke. This phase declares which commands each agent recognizes.

**Zero-Config Default**: All agents recognize all commands (no filtering).

**Ordering Rationale**: Commands are declared after agents exist but before the system routes user input.

**Example JSONC Snippet**:

```jsonc
{
  "commands": {
    "herald": [
      "/plan",
      "/fix",
      "/commit",
      "/review",
      "/scout",
      "/sage",
      "/forge",
      "/ward",
      "/arbiter"
    ],
    "sage": [
      "/spec",
      "/design",
      "/tasks"
    ],
    "forge": [
      "/implement",
      "/test",
      "/refactor"
    ],
    "ward": [
      "/audit",
      "/scan"
    ],
    "arbiter": [
      "/review",
      "/approve",
      "/reject"
    ]
  }
}
```

---

## Phase 6: Skill Compose

**Purpose**: Declare which skills (specialized capabilities or workflows) each agent loads at initialization.

**Semantics**: A skill is a module or behavior that augments an agent's capabilities. Examples: `"spec-driven"` (planning methodology), `"code-review"` (code analysis), `"security-audit"` (vulnerability scanning).

**Zero-Config Default**: No skills are loaded. Agents use their baseline capabilities.

**Ordering Rationale**: Skills are loaded last because they may depend on all earlier phases (provider, agent config, tool filters, MCP servers, commands).

**Example JSONC Snippet**:

```jsonc
{
  "skills": {
    "sage": [
      "spec-driven"
    ],
    "forge": [
      "code-review",
      "test-driven"
    ],
    "ward": [
      "security-audit"
    ],
    "arbiter": [
      "quality-gate"
    ]
  }
}
```

---

## Zero-Config Guarantee

**When `agents.config.jsonc` is absent or empty, the system behaves as follows**:

1. **Phase 1**: All agents use provider `"anthropic"` by default.
2. **Phase 2**: All agents are configured as listed in Phase 2 defaults above.
3. **Phase 3**: No tool filtering is applied; all agents can use all tools.
4. **Phase 4**: All agents connect to `["context7", "webfetch", "skill", "tokenscope"]`.
5. **Phase 5**: All agents recognize all commands.
6. **Phase 6**: No skills are loaded.

This guarantees **backwards compatibility**: existing setups work without the config file, and runtime behavior is identical whether the file is present or absent.

---

## Configuration File Location

The configuration file is located at:

```
.agents/agents.config.jsonc
```

It is optional. The file is validated against the JSON Schema at `.agents/agents.config.schema.json`.

---

## Cross-References

- **Agent Definitions**: See `.agents/agents.md` for details on each agent's role, mode, and capabilities.
- **Agent Annotations**: Each agent in `.agents/agents.md` includes a `mode` field and `model` recommendation.
- **Schema**: See `.agents/agents.config.schema.json` for the formal validation schema.
- **System Overview**: See `AGENTS.md` for the system architecture and agent responsibilities.

---

## Conventions

See sections below for detailed conventions on tool filtering and skill composition.

### Tool Filter Conventions

The tool filter serves as a coarse access control mechanism. It prevents accidental or inappropriate tool invocations but is not a security boundary.

**Precedence Rule**: `deny` always takes precedence over `allow`. If a tool matches both an `allow` pattern and a `deny` pattern, it is **denied**.

**Wildcard Syntax**:
- `*` matches any substring
- `mcp_*` → matches `mcp_Read`, `mcp_Bash`, `mcp_Context7_query_docs`, etc.
- `*_session` → matches `mcp_Read_session`, `mcp_Handoff_session`, etc.
- `Bash` → matches exactly `Bash` (no wildcard)

**Wildcard Matching Algorithm**:
1. For each tool name and each pattern in `allow`, check if the tool matches the pattern
2. For each tool name and each pattern in `deny`, check if the tool matches the pattern
3. If the tool matches any `deny` pattern, it is **denied** (regardless of matches in `allow`)
4. If the tool matches any `allow` pattern and no `deny` patterns, it is **allowed**
5. If the tool matches no patterns (neither allow nor deny), it is **allowed** (default-allow policy)

#### Agent × Tool Filter Matrix

| Agent | Role | Allow Patterns | Deny Patterns | Rationale |
|-------|------|---|---|---|
| **Herald** | Coordinator | (all) | (none) | Primary agent; routes to others |
| **Scout** | Explorer | `Bash`, `Glob`, `Grep`, `mcp_*` | `Write`, `Edit`, `MultiEdit`, `mcp_Handoff_session` | Read-only; cannot mutate files |
| **Sage** | Planner | `mcp_*`, `mcp_Read_session`, `mcp_Handoff_session` | `Bash`, `Write`, `Edit`, `MultiEdit`, `Glob`, `Grep` | No code execution; read Scout context only |
| **Forge** | Executor | (all) | (none) | Must write code; needs full access |
| **Ward** | Security | `mcp_Read`, `Glob`, `Grep`, `Bash`, `mcp_Context7_*`, `mcp_Skill`, `mcp_Tokenscope` | `Write`, `Edit`, `MultiEdit`, `mcp_Webfetch`, `mcp_Read_session`, `mcp_Handoff_session` | Audit only; no mutations, no handoff |
| **Arbiter** | Quality | `mcp_Read`, `Glob`, `Grep`, `Bash`, `mcp_Context7_*`, `mcp_Skill`, `mcp_Tokenscope` | `Write`, `Edit`, `MultiEdit`, `mcp_Webfetch`, `mcp_Read_session`, `mcp_Handoff_session` | Review only; no mutations, no handoff |

**Common Role Patterns**:
- **Read-only agents** (Ward, Arbiter): allow `["Read", "Glob", "Grep", "Bash"]`, deny `["Write", "Edit", "MultiEdit"]`
- **Planning agents** (Sage): allow `["mcp_*"]`, deny `["Bash", "Write", "Edit"]`
- **Executor agents** (Forge, Scout): allow all tools (or specific whitelist), deny specific non-writing tools only

### Skill Composition Conventions

A skill is a named capability or workflow that an agent can load. Skills are declared in Phase 6 and discovered at runtime. Skills represent agent behaviors, methodologies, or specialized workflows.

#### Skill Discovery Process

The system discovers skills through a convention-based discovery process:

1. **Skill Registry Lookup**: The system checks for a canonical skill registry (location TBD, typically `skills/registry.json` or `.agents/skills/`)
2. **Load by Name**: When an agent is initialized with skills declared in Phase 6 (e.g., `"skills": {"sage": ["spec-driven"]}`), the system:
   - Looks up the skill name in the registry
   - Verifies the skill implementation exists
   - Loads and initializes the skill with the agent's context
3. **Initialization**: Skills are initialized after all earlier phases (Phases 1-5) are complete, giving skills access to agent configuration, tool filters, and MCP servers

#### Runtime vs. Declared

| Aspect | Declared | Runtime |
|--------|----------|---------|
| **Definition** | Skill names listed in Phase 6 of `.agents/agents.config.jsonc` | Actual skill implementation loaded and executed |
| **Binding** | `"skills": {"sage": ["spec-driven"]}` | `Skill("spec-driven").load(agent)` |
| **Resolution** | By name; must match a known skill identifier | By implementation; must implement the skill interface |
| **Timing** | Configuration time (static) | Runtime (dynamic) |

A declared skill that does not exist at runtime is a **configuration error** — the agent fails to initialize.

#### Error Handling

**Missing Skill Error**:

When a skill declared in Phase 6 is not found at runtime, the agent initialization MUST fail with a clear diagnostic message:

```
ERROR: Agent 'sage' failed to load skill 'spec-driven'
Reason: Skill not found in registry or implementation missing
Action: Check .agents/agents.config.jsonc; verify skill exists in skill registry
Context: Skills available: [<comma-separated list>]
```

The agent does NOT partially initialize with a subset of skills. The entire initialization is aborted.

**Prevention**: Validate skill declarations against the skill registry during config validation (pre-initialization).

#### Common Skills by Agent

| Agent | Skill | Purpose |
|-------|-------|---------|
| **Sage** | `spec-driven` | Use spec-driven methodology for planning: SPECIFY → DESIGN → TASKS phases |
| **Forge** | `code-review` | Apply code review practices: check for style, patterns, best practices |
| **Forge** | `test-driven` | Use test-driven development: write tests before implementation |
| **Ward** | `security-audit` | Perform security audits: check for OWASP, CVEs, hardcoded secrets |
| **Arbiter** | `quality-gate` | Enforce quality gates: check SRP, DRY, test coverage, complexity |

#### Skill Composition Example

**In `.agents/agents.config.jsonc` (Phase 6):**

```jsonc
{
  "skills": {
    "sage": ["spec-driven"],
    "forge": ["code-review", "test-driven"],
    "ward": ["security-audit"],
    "arbiter": ["quality-gate"]
  }
}
```

**At runtime (pseudo-code):**

```
For each agent in ["sage", "forge", "ward", "arbiter"]:
  For each skill in config.skills[agent]:
    skillImpl = registry.lookup(skill)
    if not skillImpl:
      raise ConfigError(f"Skill '{skill}' not found")
    skillImpl.load(agent)
  agent.initialize()
```

#### Skill Interfaces (Future)

Skills are expected to implement a standard interface (to be defined in a future skill architecture document):

```typescript
interface Skill {
  name: string;           // Unique skill identifier (e.g., "spec-driven")
  version: string;        // Semantic version (e.g., "1.0.0")
  load(agent: Agent): void;     // Initialize skill with agent context
  execute(task: Task): Result;  // Execute skill behavior
  unload(): void;         // Cleanup on agent shutdown
}
```

Details will be formalized when skills are runtime-implemented.

---

## Summary

| Phase | Key Decision | Zero-Config Default |
|-------|--------------|---------------------|
| 1 | Provider backend | `"anthropic"` |
| 2 | Agent identity & mode | Herald: primary; others: subagent with pinned models |
| 3 | Tool access | No filtering; all agents can use all tools |
| 4 | MCP servers | `["context7", "webfetch", "skill", "tokenscope"]` |
| 5 | Slash commands | All agents recognize all commands |
| 6 | Skills | No skills loaded |

The pipeline is **declarative** (configuration, not code), **composable** (phases stack), and **optional** (works without the config file).
