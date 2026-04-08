---
name: pm-sprint-management-close-sprint
description: Guide the TherapyNotes Jira workflow for preparing and completing an IT sprint close safely. Use when a user asks to close or complete the current IT sprint, capture incomplete sprint tasks, determine the next sprint with Atlassian Rovo MCP, release the corresponding IT fix version, validate that carry-over tickets were moved to the upcoming sprint, navigate the Information Technology Jira board, or work through the post-close release and automation steps. This skill may open the Complete sprint dialog, but it must stop before the final completion click unless the user explicitly approves that action in the current turn.
---

# PM Sprint Management Close Sprint

Use this skill for the TherapyNotes IT sprint-close workflow in Jira. Follow the documented Confluence procedure, use Atlassian Rovo MCP to identify the expected next sprint and the IT fix version to release, and treat the final close action as a guarded action.

## Current Iteration

Implement the preparation steps, close the sprint with confirmation, then complete the post-close IT, ISD, automation, and easyBI follow-up steps from the Confluence article.

1. Read `references/starting-completing-a-sprint-in-jira.md` if you need the source procedure or later follow-up steps.
2. Confirm the user wants the close-sprint workflow, not the start-sprint workflow.
3. Capture incomplete work items before touching the sprint:
   - Use this JQL:

   ```jql
   project = IT AND issuetype = Task AND Sprint in OpenSprints() AND status in ("Input Queue", Implementing, "Implementation Review", Pending) Order BY cf[10021] ASC, assignee ASC, fixVersion ASC, priority DESC, updated DESC
   ```

   - Export the results to a CSV file and save it for retrospectives.
   - Record the issue keys from this result set as the carry-over candidate set for later validation.
   - Note that the same list is available in the Closed Sprint Report Dashboard.
4. Determine the expected next sprint with Atlassian Rovo MCP before opening the close dialog:
   - Use Jira JQL through Rovo:

   ```jql
   project = IT AND Sprint in futureSprints()
   ```

   - Request `customfield_10020`, which is the Sprint field in this Jira instance.
   - Collect only sprint entries where `state = "future"`.
   - Choose the future sprint with the earliest `startDate`.
   - Record that sprint name as the expected `Move open work items to` target.
   - If Rovo does not return a clear next sprint, stop and ask the user before opening the close dialog.
5. Navigate in Jira:
   - Log into Jira.
   - Open `Spaces > Information Technology`.
   - Use the current Information Technology board that exposes the active sprint close control, even if the board title differs from the Confluence page wording.
   - Open the `Active Sprints` tab.
6. Stage the close dialog:
   - Click the visible `Complete sprint` button to open the close dialog.
   - If Jira offers a checkbox to create a retrospective, uncheck it.
   - Do not generate release notes.
   - Verify the dialog's `Move open work items to` value matches the expected next sprint from Rovo.
   - If the value does not match, stop and ask the user instead of proceeding.
7. Ask for confirmation before the final close:
   - Report the current sprint being closed.
   - Report the `Move open work items to` sprint value.
   - Report that retrospective creation has been unchecked.
   - Ask the user to confirm before clicking the final dialog button.
8. After the user explicitly confirms in the current turn:
   - Click the final `Complete sprint` button in the dialog.
9. Release the IT fix version after the sprint is closed:
   - Use Atlassian Rovo MCP to inspect issues from the sprint that was just closed:

   ```jql
   project = IT AND Sprint = "<closed-sprint-name>"
   ```

   - Request `fixVersions` and identify the unreleased fix version associated with the closed sprint.
   - Prefer the unreleased version whose name matches the closed sprint name.
   - If multiple unreleased fix versions are present and none clearly match, stop and ask the user.
   - In Jira, open `More > Releases` from the Information Technology project navigation.
   - Use the Releases search field to filter to the exact version name.
   - Verify the row is still `UNRELEASED`.
   - Click the row-level `Release` button for that exact version.
   - In the release dialog, keep the default release date unless the user asks to change it.
   - If Jira offers `Create release notes`, uncheck it.
   - Click the final dialog `Release` button.
   - Verify the version row changes to `RELEASED`.
   - Verify via Atlassian Rovo MCP that the released version now reports `released = true` on at least one issue from the closed sprint.
10. Validate that carry-over tickets were assigned to the upcoming sprint:
   - Use the carry-over candidate issue keys captured before the sprint close.
   - Run Jira JQL through Atlassian Rovo MCP for the carry-over candidate set:

   ```jql
   key in (<carry-over-keys>)
   ```

   - Run Jira JQL through Atlassian Rovo MCP for the subset assigned to the expected next sprint:

   ```jql
   key in (<carry-over-keys>) AND Sprint = "<expected-next-sprint-name>"
   ```

   - Compare the counts.
   - If every carry-over candidate is assigned to the expected next sprint, record success and continue.
   - If any carry-over candidates are missing from the expected next sprint, identify the mismatches with Jira JQL:

   ```jql
   key in (<carry-over-keys>) AND Sprint not in ("<expected-next-sprint-name>")
   ```

   - Report the mismatched issue keys to the user.
   - Ask the user whether you should update those issues to the expected next sprint before making any change.
11. Verify the matching ISD fix version:
   - Use Atlassian Rovo MCP with Jira JQL:

   ```jql
   project = ISD AND fixVersion = "<closed-sprint-name>"
   ```

   - Treat the closed sprint name as the expected ISD version name unless Jira data proves otherwise.
   - If Rovo shows that matching ISD fix version already has `released = true`, record that no manual release is needed and continue.
   - If the matching ISD version exists but is still unreleased, navigate to `Spaces > IT Service Desk > ... > Space settings > Versions`.
   - Find the exact matching version and use the row action to release it.
   - Verify via Atlassian Rovo MCP that the ISD fix version now reports `released = true` on at least one ISD issue.
   - If you cannot identify a single matching ISD version, stop and ask the user.
12. Update the ISD automation that assigns Fix Version:
   - Reuse the Rovo-derived next sprint from earlier, or query future sprints again if needed.
   - Navigate to `Spaces > IT Service Desk > ... > Space settings > Automation`.
   - Filter rules to `ISD - Set FixVersion on Close`.
   - Open the rule and inspect `Then: Edit work item fields`.
   - Verify the current `Fix versions` value before changing it.
   - Replace the old sprint value with the next sprint ID.
   - Click `Update`.
   - Reopen the same `Then: Edit work item fields` action and verify the saved `Fix versions` value matches the next sprint ID.
13. Refresh easyBI data:
   - Go to Jira home if needed.
   - Open `Apps > eazyBI`.
   - In the eazyBI account list, expand `IT`.
   - Open `Source data`.
   - On the Jira source row for `Projects: ISD, IT`, click `Import`.
   - Verify the row enters an active import state such as `Waiting in queue` or `Importing`.
14. Do not start the next sprint unless the user asks to continue beyond the documented close workflow.

## Guardrails

- Never close a sprint without explicit user approval in the current turn.
- Never assume the correct next sprint from the UI alone; verify it with Atlassian Rovo MCP first.
- Never proceed if the close dialog's `Move open work items to` value differs from the Rovo-derived next sprint.
- Never release an IT fix version without verifying from Jira data that it belongs to the sprint just closed and is still unreleased.
- Never treat carry-over assignment as successful without comparing the pre-close carry-over candidate set to the issues now assigned to the expected next sprint.
- Never update mismatched carry-over issues to a sprint without explicit user approval in the current turn.
- Never assume the ISD version name differs from the sprint name unless Jira data shows that it does.
- Never change the ISD automation rule without verifying the current value first and reopening it after save to confirm the new value persisted.
- Never treat an easyBI click as complete until the Jira source row shows a queued or active import state.
- Stop and ask if the Jira UI differs materially from the documented board or menu names.
- Treat next-sprint startup as out of scope unless the user asks to add it next.

## Later Iterations

Add these only after the user asks to extend the skill:

1. Start the next sprint.
2. Add any additional dashboard or reporting validation that should happen after easyBI import completes.
