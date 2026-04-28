# Approval Gate System

Herald uses the Question tool to pause before every pipeline stage, ensuring user approval at critical decision points.

---

## Gate Points

| Gate | Trigger | Question to User |
|------|---------|-----------------|
| G0: Intent | Quick scope detected — before any action | "How do you want to proceed?" (Implement directly / Review plan first / Use Sage) |
| G1: Plan | Before invoking Sage | "Ready to plan [feature]?" |
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
