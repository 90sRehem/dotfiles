# Approval Gate System

Herald uses the Question tool to pause before every pipeline stage, ensuring user approval at critical decision points.

**Note:** All inter-agent communication uses JSON envelopes (see [protocol.md](protocol.md) for complete schema). Herald parses `envelope.agent` + `envelope.status` to determine next action; gate presentation and decisions are as documented below.

---

## Gate Points

| Gate | Trigger | Question to User |
|------|---------|-----------------|
| G0: Intent | Quick scope detected — before any action | "How do you want to proceed?" (Implement directly / Review plan first / Use Sage) |
| G1: Plan | Before invoking Sage | "Ready to plan [feature]? (or type 'adjust <plan>' to modify an existing plan)" |
| G2: Write Specs | Before Forge writes spec artifacts | "Plan ready. Write spec files?" |
| G3: Execute | Before Forge implements code | "Tasks defined. Start implementation?" |
| G4/G5: Review | After Forge completes — before Ward/Arbiter | "Which reviews to run?" (Security+Quality parallel / Security only / Quality only / Skip / Cancel) |
| G6: Commit | Before Forge commits | "Proposed commit: [message]. Approve?" |

---

## Gate Rules

- **Mandatory enforcement**: Herald MUST NOT skip gates. No bypass paths exist.
- **Affirmative** ("yes", "y", "go", "sim", "s") → proceed
- **Negative** ("no", "n", "não") → Herald stops and asks what to change
- **Opt-out**: User may say "skip gates" to disable for current session (not recommended)

## Recovery Checkpoints at Gates

When Forge is executing complex tasks (resumable workflows), gate passage triggers a recovery checkpoint distinct from task-level checkpoints.

**See also:** [Forge Recovery Startup & Cleanup](agents.md#recovery-startup) — detailed checkpoint behavior

| Gate | Checkpoint Trigger |
|------|-------------------|
| G3 (Execute) | User approves execution. Forge writes initial checkpoint before starting task 1. |
| G4/G5 (Review) | User chooses review option. Forge writes checkpoint with all completed tasks before delegating Ward/Arbiter. |
| G6 (Commit) | User approves commit. Forge writes final checkpoint before executing git commit. |

These gate-triggered checkpoints ensure that recovery can restart cleanly at gate boundaries, not mid-task.

---

## Command-Triggered Workflows

Command-triggered workflows are skills that fire on explicit user commands, not at fixed gate checkpoints. They are **not gates** — they do not block progress or appear in the gate numbering (G1–G6).

### grill-me (Adjust Plan)

**Trigger commands**: `adjust plan`, `adjust <plan>`, `/adjust`, `modify plan`, `change plan`, `that's not what I meant`, `this isn't right`

**Workflow type**: `command_triggered` (not a gate)

**Target agent**: `herald`

**Interview protocol**:
1. Herald detects a trigger command in user input (case-insensitive substring match)
2. Herald loads the grill-me skill from registry → `.agents/skills/grill-me.md`
3. Herald conducts a structured interview: one question at a time, with recommendations
4. Interview walks the change tree depth-first (root complaint → scope → approach → constraints → details → priority → success criteria)
5. Interview stops when shared understanding is reached

**Output**: grill-me produces a JSON envelope with:
- `payload.root_complaint`: The user's initial dissatisfaction
- `payload.clarifications[]`: Array of resolved branches (branch, current_plan_says, question, answer, why, decision)
- `payload.summary`: Concise description of what the revised plan should look like
- `payload.unresolved[]`: Any branches that couldn't be resolved

**Re-planning flow**:
1. Herald constructs re-planning context: existing plan reference + grill-me clarifications + summary
2. Herald dispatches Sage with instruction: "Revise the existing plan to incorporate these adjustments"
3. Sage produces a revised plan
4. User reviews → satisfied (proceed to Forge) or adjusts again

**Iteration limit**: Maximum 3 re-plan iterations per plan. After 3 iterations, Herald blocks further adjustments and suggests: human pair review or feature breakdown.

**When it does NOT fire**: grill-me never fires on the happy path. A well-specified request goes straight through G1 → Scout → Sage → Forge with no interview.

---

## Question Tool Enforcement

Question tool is mandatory for **all** gates G1-G6 AND for any user-facing interaction requiring a choice:

- Presenting Ward/Arbiter findings
- Presenting Sage artifacts for approval
- Asking about scope classification
- Presenting options for next steps

**PROHIBITED**: Listing options in free text. MUST use Question tool invocation.

### Minimum Format

```json
{
  "header": "string — context label (≤30 chars)",
  "question": "string — what is being asked",
  "options": [
    {"label": "string — short label", "description": "string — what this choice means"}
  ]
}
```

**Applies to**: Herald (all interactions) and Sage (direct access — post-SPECIFY, post-DESIGN, post-TASKS approvals).

---

## Compaction Recovery Flow (Informational)

When context window reaches critical capacity and compaction is triggered, Forge uses the recovery checkpoint system to resume execution.

**See also:** [Recovery File Schema](protocol.md#recovery-file-schema) — checkpoint structure and protocol

1. **Context reaches 95%**: Agent emits `status: "context_pause"` (see `.agents/agents.md` § Context Window Monitor)
2. **User chooses "compact_now"**: Herald initiates compaction (externally managed)
3. **Compaction complete**: Herald invokes Forge recovery startup
4. **Forge checks recovery file**: Loads `.specs/features/<name>/.recovery.json`
5. **Forge emits recovery prompt**: System-origin prompt contains feature name, completed tasks, next task ID
6. **Forge resumes execution**: Continues from checkpoint without user re-initiation
7. **On completion**: Forge deletes recovery file and logs to vault

This flow ensures resumption is transparent to the user and maintains execution continuity across compaction events.
