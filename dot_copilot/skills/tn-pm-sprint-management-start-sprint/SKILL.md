---
name: tn-pm-sprint-management-start-sprint
description: Guide the TherapyNotes Jira workflow for safely starting the next IT sprint. Use when a user asks to start or stage the next IT sprint, identify the earliest future IT sprint with Atlassian Rovo MCP, navigate to the Information Technology backlog, verify sprint readiness, or open the Start Sprint dialog. This skill may open the Start Sprint dialog, but it must stop before the final start click unless the user explicitly approves that action in the current turn.
---

# TN PM Sprint Management Start Sprint

Use this skill for the TherapyNotes IT sprint-start workflow in Jira. Follow the documented Confluence procedure, use Atlassian Rovo MCP to identify the next sprint to start, and treat the final start action as a guarded action.

## Current Iteration

Implement the sprint-start preparation and dialog-staging steps, but do not click the final `Start Sprint` button without explicit approval in the current turn.

1. Read `references/starting-completing-a-sprint-in-jira.md` if you need the source procedure or supporting notes.
2. Confirm the user wants the start-sprint workflow, not the close-sprint workflow.
3. Determine the sprint that should be started with Atlassian Rovo MCP:
   - Use Jira JQL through Rovo:

   ```jql
   project = IT AND Sprint in futureSprints()
   ```

   - Request `customfield_10020`, which is the Sprint field in this Jira instance.
   - Collect only sprint entries where `state = "future"`.
   - Choose the future sprint with the earliest `startDate`.
   - Record that sprint name as the expected sprint to start.
   - If Rovo does not return a single clear next sprint, stop and ask the user before touching Jira UI controls.
4. Verify the target sprint looks ready to start:
   - Inspect issues in the target sprint with Atlassian Rovo MCP:

   ```jql
   project = IT AND Sprint = "<next-sprint-name>"
   ```

   - Request at least `key`, `summary`, and `status`.
   - Make sure the sprint is not empty.
   - Make sure sprint work items are in `Input Queue` or another in-progress status, consistent with the Confluence procedure.
   - If Jira data suggests the sprint contents are not ready, stop and ask the user before opening the dialog.
5. Navigate in Jira:
   - Log into Jira.
   - Open `Spaces > Information Technology`.
   - Use the current Information Technology board that exposes the backlog start control, even if the board title differs from the Confluence page wording.
   - Open the `Backlog` tab.
6. Locate the backlog sprint whose name matches the Rovo-derived sprint name exactly.
   - If the expected sprint is not visible, stop and ask the user instead of guessing.
7. Stage the start dialog:
   - Click `Start Sprint` for the exact matching sprint.
   - Verify the dialog's sprint name matches the Rovo-derived sprint.
   - If Jira shows editable dates, verify they are consistent with the sprint metadata or expected cadence before proceeding.
8. Ask for confirmation before the final start:
   - Report the sprint name being started.
   - Report any start and end dates shown in the dialog.
   - Ask the user to confirm before clicking the final dialog button.
9. After the user explicitly confirms in the current turn:
   - Click the final `Start Sprint` button in the dialog.
   - Verify Jira moves the sprint into the active state.
10. Do not close the sprint, release versions, update automation, or refresh easyBI from this skill.

## Guardrails

- Never start a sprint without explicit user approval in the current turn.
- Never assume the correct sprint from the UI alone; verify it with Atlassian Rovo MCP first.
- Never proceed if the dialog sprint name differs from the Rovo-derived sprint.
- Never guess when multiple future sprints are present; use the earliest future sprint by `startDate`.
- Never proceed if the sprint appears empty or obviously not ready based on Jira issue data.
- Stop and ask if the Jira UI differs materially from the documented board or menu names.
- Treat the final start click as out of scope unless the user asks to execute it now.

## Later Iterations

Add these only after the user asks to extend the skill:

1. Add a richer readiness summary for sprint contents before opening the dialog.
2. Add post-start verification steps such as active-sprint screenshots or follow-up checks.
