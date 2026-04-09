# Starting/Completing A Sprint in Jira

Source: https://therapynotes.atlassian.net/wiki/spaces/InfoTech/pages/320831797/Starting+Completing+A+Sprint+in+Jira
Fetched: 2026-03-09
Last updated in Confluence: 2026-02-23

## Start New Sprint

1. Log into Jira.
2. Make sure all tasks assigned to the current sprint are in `Input Queue` or another in-progress status.
3. Click `Spaces > Information Technology`.
4. Choose the `IT Team - Project Management` board.
5. Click `Backlog`.
6. Click `Start Sprint`; confirm.

## Observed Jira Notes

- In this Jira instance, the Sprint field is available through Rovo/Jira API as `customfield_10020`.
- That field returns sprint objects with `name`, `state`, `boardId`, `startDate`, and `endDate`.
- For the start workflow, choose the future sprint with the earliest `startDate` as the expected sprint to start.
- In observed use, the board exposing the relevant sprint controls may not match the Confluence board title exactly, so use the current Information Technology board that contains the backlog sprint controls.
- Treat the final `Start Sprint` click as a guarded action and require explicit user approval in the current turn.
