# TherapyNotes Jira Field Map

Observed on 2026-03-06 while processing `IT-17326`, `ISD-92400`, `IT-17302`, and `ISD-92403`. Reconfirm with live Jira metadata if a field, option, or transition differs.

## Working rules

- Shape the IT ticket from a stub if planning is incomplete.
- Ask only for the missing planning inputs needed to make the ticket reviewable.
- Ask the user before setting sprint.
- Ask the user before setting story points.
- If the user gives a relative sprint such as `next sprint`, resolve it to the exact Jira sprint before setting it.
- Keep the source IT ticket assignee and planner as the user unless told otherwise.
- Set the source IT ticket priority to `Medium`.
- Set the source IT `Team` and `Tech Team` to `IT Management` when Jira requires them for workflow progression.
- Set `Joshua Klingerman` as `Lead Reviewer` on the change ticket only, unless the user names someone else.
- Append the source `Implementation Details` to the change ticket `Implementation Plan`.
- Carry reviewer-facing screenshots from the IT ticket into the change ticket and prefer inline image placement over plain links.
- Check for an existing linked `ISD-` ticket before creating a new one.

## Source IT ticket fields

- `Team`: `customfield_10001`
- `Sprint`: `customfield_10020`
- `Story Points`: `customfield_10057`
- `Planner`: `customfield_10142`
- `Tech Team`: `customfield_10058`
- `Priority`: `Medium` used Jira priority id `3` during this run

Known `IT Management` values used successfully:

- `Team`: raw team id string `3d2e4b43-2493-4df6-85fc-fd58adabdd45`
- `Tech Team`: option id `10886`

## Change ticket defaults and fields

- Companion issue type: `ISD Change`
- Companion project: `ISD`
- `Lead Reviewer`: `customfield_10124`
- `Implementation Plan`: `customfield_10041`
- `Change Type`: `customfield_10228`
- `Implementation Path`: `customfield_10202`
- `Change Risk Level`: `customfield_10006`
- `Tech Team`: `customfield_10058`
- `Cloud Cost Action`: `customfield_10530`
- `Change Risk Detail`: `customfield_10078`
- `Rollback/Contingency Plan`: `customfield_10042`
- `Test and Monitoring Plan`: `customfield_10043`
- `Team`: `customfield_10001`

Use these option ids when Jira does not resolve names automatically:

- `Change Type` -> `Normal`: `10787`
- `Implementation Path` -> `Ad Hoc`: `10749`
- `Change Risk Level` -> `Low`: `10010`
- `Tech Team` -> `IT Management`: `10886`
- `Cloud Cost Action` -> `No cost implication`: `11324`
- `Team` -> `IT Management`: raw team id string `3d2e4b43-2493-4df6-85fc-fd58adabdd45`

Treat those values as the working defaults for this TherapyNotes IT-to-ISD path unless the ticket content or Jira validators require something else.

## Transition ids observed on 2026-03-06

- `Backlog` -> `In Discovery`: `1581`
- `In Discovery` -> `Team Review`: `1771`
- `In Discovery` -> `Lead Review`: `1591`
- `Team Review` -> `Lead Review`: `1781`
- `Lead Review` -> `Architect Review`: `1611`
- `In Preparation` -> `Architect Review` on `ISD`: `9522`

Known validator behavior from this run:

- `Team Review` -> `Lead Review` accepted `timetracking.originalEstimate` and `timetracking.remainingEstimate` set to `1h`.
- `Lead Review` -> `Architect Review` on the IT ticket required sprint assignment first.
- `Backlog` -> `In Discovery` on `IT-17302` required `Team`, so set both IT `Team` and `Tech Team` before moving the ticket forward.
- `In Preparation` -> `Architect Review` on `ISD-92403` required `Change Risk Level`, `Rollback/Contingency Plan`, `Tech Team`, and `Test and Monitoring Plan`.
- Required fields on the change transition can differ between tickets. Do not assume the previous change ticket's field list is still sufficient.

Always prefer live transition metadata over these cached ids if Jira disagrees.

## Reviewer and account lookup

- Prefer `lookupJiraAccountId` or `atlassianUserInfo` over hardcoding account ids.
- `Joshua Klingerman` resolved to account id `62437ce61da0e1007138c1d4` during this run.

## Implementation details copy rule

- Extract the source ticket's `Implementation Details` section as directly as possible.
- Append it under a heading like `Implementation Details From <IT-key>` inside the change ticket `Implementation Plan`.
- Preserve the existing implementation steps above the appended section.
- If the ticket includes screenshots, attach or reuse them and paste them inline in the change ticket when Jira allows it.
- Replace page-scoped blob image URLs with stable Jira attachment URLs only when inline placement is not possible.

## Planning from a stub

Minimum planning targets before moving toward architect review:

- clear summary of the requested change
- direct implementation details that describe what will be changed
- testable acceptance criteria
- screenshots or visual references when they make the request easier to review

If any of those are missing, gather only the missing details from the user and update the IT ticket before doing workflow transitions.

## Browser fallback

- Start with Atlassian Rovo MCP.
- If MCP does not expose edit metadata or allowed values, use Playwright in the logged-in Jira session.
- Use Playwright for attachment uploads and inline image insertion in Jira editors.
- Query `/rest/api/3/issue/<key>/editmeta` from the browser session to recover field ids and allowed values.
- Query `/rest/api/3/issue/<key>/transitions?expand=transitions.fields` from the browser session when the blocked operation is a transition with a screen. This surfaces required transition-only fields that do not always appear in `editmeta`.
- Use Jira UI inspection only to bridge MCP gaps; keep the actual workflow driven by the authoritative Jira data.
