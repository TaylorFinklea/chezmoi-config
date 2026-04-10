# Starting/Completing A Sprint in Jira

Source: https://therapynotes.atlassian.net/wiki/spaces/InfoTech/pages/320831797/Starting+Completing+A+Sprint+in+Jira
Fetched: 2026-03-09
Last updated in Confluence: 2026-02-23

## Complete Sprint

Sprints typically close at 1pm ET on the last Monday of the sprint.

### Capture the items that are incomplete

1. Use this filter to find incomplete items in the current sprint:

   ```jql
   project = IT AND issuetype = Task AND Sprint in OpenSprints() AND status in ("Input Queue", Implementing, "Implementation Review", Pending) Order BY cf[10021] ASC, assignee ASC, fixVersion ASC, priority DESC, updated DESC
   ```

2. Export to `.csv` and save for retrospectives.
3. The list is also available in the Closed Sprint Report Dashboard.

### Complete the sprint in Jira

1. Log into Jira.
2. Click `Spaces > Information Technology`.
3. Choose the `IT Team - Project Management` board.
4. Click `Active Sprints`.
5. Click `Complete sprint`; confirm.
   - The documented default is to transition items to the next sprint.
   - Release notes are not typically created.

### Release the fix version for IT tasks

1. From the `IT Team - Project Management` board, click `Releases`.
2. Find the appropriate Fix Version.
3. Click `Release` next to the Fix Version.

### Release the fix version for ISD tasks

The Confluence note says automation should usually release the matching ISD Fix Version after the IT Fix Version is released, but it should still be verified.

1. Click `Spaces > IT Service Desk`.
2. Open the `...` menu next to `IT Service Desk` and choose `Space Settings`.
3. Click `Versions` in the left-side menu.
4. Find the corresponding Fix Version.
5. If it is still unreleased, open the `...` menu and choose `Release`.

### Update the ISD automation that assigns Fix Version

1. Click `Automation` in the left-side menu.
2. Filter by `Fix Version` to find `ISD - Set FixVersion on Close`.
3. Click the rule.
4. Select the `Then: Edit issue fields` bubble.
5. Change the Fix Version to the next Sprint ID.
6. Click `Update`.

### Refresh easyBI data

1. In Jira, go to `Apps`, then `easyBI`.
2. Under `My Accounts`, open the `IT` section.
3. Click `Source Data`.
4. Click `Import` on the Jira project data connection.

## Start New Sprint

This section is source context only. It is not part of this skill's current scope.

1. Log into Jira.
2. Make sure all tasks assigned to the current sprint are in `Input Queue` or another in-progress status.
3. Click `Spaces > Information Technology`.
4. Choose the `IT Team - Project Management` board.
5. Click `Backlog`.
6. Click `Start Sprint`; confirm.

## Observed Jira Notes

- In this Jira instance, the Sprint field is available through Rovo/Jira API as `customfield_10020`.
- That field returns sprint objects with `name`, `state`, `boardId`, `startDate`, and `endDate`.
- For the close workflow, choose the future sprint with the earliest `startDate` as the expected move target.
- The IT fix version for a sprint can be derived from issues in the closed sprint by inspecting the `fixVersions` field.
- In the current project UI, `Releases` is available under the `More` tabs menu in Information Technology.
- The Releases page supports filtering by version name and exposes a row-level `Release` button for unreleased versions.
- Releasing an IT version opens a confirmation modal that shows work item count, keeps the existing release date, and enables `Create release notes` by default.
- In observed use, `Create release notes` should be unchecked before the final `Release` click.
- For carry-over validation, reuse the issue keys captured from the pre-close incomplete-item filter and compare them against the expected next sprint after the close is complete.
- If any carry-over issue keys are not in the expected next sprint after close, ask the user before performing any manual sprint reassignment.
- The matching ISD fix version currently uses the same version name as the closed sprint, for example `IT-20260224`.
- In observed use, the matching ISD fix version may already auto-release immediately after the IT version release, so verify Jira data before performing any manual ISD release.
- The IT Service Desk automation rule to update after sprint close is `ISD - Set FixVersion on Close`.
- In that rule, the `Then: Edit work item fields` action stores the next sprint in the `Fix versions` field and should be reopened after save to confirm the persisted value.
- The eazyBI refresh path is `Apps > eazyBI > IT > Source data`, and the Jira source row is labeled `Projects: ISD, IT`.
- After clicking eazyBI `Import`, the observed immediate success condition is the row entering `Waiting in queue`.
