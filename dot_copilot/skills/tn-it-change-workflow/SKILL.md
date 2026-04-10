---
name: tn-it-change-workflow
description: Drive the TherapyNotes Jira workflow from an `IT-` stub ticket through planning, `Architect Review`, and creation or advancement of its linked `ISD-` change ticket. Use when handling TherapyNotes Jira work that needs ticket shaping, implementation-details drafting, acceptance-criteria drafting, screenshot attachment or inline image handling, sprint and story point assignment, planner and assignee updates, priority normalization to Medium, change-ticket creation, lead-reviewer assignment, implementation-plan copying, or Jira field and transition handling through Atlassian Rovo MCP first, Atlassian CLI next, and Playwright only for Jira UI gaps.
---

# TN IT Change Workflow

Use Atlassian Rovo MCP first. Use Atlassian CLI (`acli`) next for Jira operations that MCP does not expose cleanly, especially issue linking. Use Playwright only when Jira exposes a field, option list, or validator that neither MCP nor `acli` can handle cleanly.

## Plan the stub

1. Read the source `IT-` ticket before editing. Confirm what already exists in the summary, implementation details, acceptance criteria, screenshots, linked issues, current status, assignee, planner, sprint, story points, and priority.
2. Treat a stub as incomplete if the ticket is missing a concrete summary, actionable implementation details, testable acceptance criteria, or supporting screenshots and links.
3. Ask the user only for the missing planning inputs. Prefer a short batch that covers: what is changing, why it is needed, how it should be implemented, how success should be validated, what screenshots or mockups should be attached, and any rollout or rollback concerns that matter for architect review.
4. Rewrite or expand the IT ticket so the summary is specific, the implementation details are direct and actionable, and the acceptance criteria are testable. Preserve any useful structure already present on the ticket.
5. If the user provides screenshots, attach them to the IT ticket and place them inline where they help reviewers most. Prefer inline images over bare attachment links.

## Run the workflow

1. Ask the user which sprint and how many story points to set before changing either field. Do not assume either value.
2. If the user gives a relative sprint like `next sprint`, resolve it to the exact Jira sprint before editing the ticket and report the exact sprint name back in the final state.
3. Check for an existing linked `ISD-` change ticket before creating one. Update the existing change ticket instead of creating a duplicate.
4. Set the source IT ticket priority to `Medium` if it still sits at Jira's default `Low`.
5. Keep the user as both assignee and planner on the IT ticket unless they explicitly say otherwise.
6. Set the source IT `Team` and `Tech Team` before leaving `Backlog` when Jira requires them for the first workflow transition.
7. Set sprint and story points, then move the IT ticket to `Architect Review`. If Jira requires intermediate transitions, move through them without changing the ownership intent.
8. Create the companion `ISD Change` ticket only after the IT ticket is ready for architect review.
9. Keep the user as assignee on the change ticket. Set `Joshua Klingerman` as `Lead Reviewer` unless the user names someone else.
10. Copy the source ticket's `Implementation Details` directly and append them to the change ticket `Implementation Plan`. Preserve any structured implementation plan already present. Append; do not replace.
11. If the source ticket includes screenshots or other reviewer-facing visuals, carry them into the change ticket and prefer inline image placement over plain links so the architect reviewer can see them in context.
12. When inline image placement is not possible, fall back to stable Jira attachment URLs rather than page-scoped blob URLs.
13. Fill every required change-management field before transitioning. Expect the required set to vary by ticket. Do not assume the previous change ticket's validator list is complete.
14. Move the change ticket to `Architect Review`.
15. Report the final IT key, change key, statuses, assignee, planner, sprint, story points, priority, lead reviewer, and any fallbacks or assumptions used.

## Use the available tools

- Start with Atlassian Rovo MCP for issue reads, issue edits, transitions, linked-issue discovery, and ticket creation.
- Use Atlassian CLI before Playwright when MCP cannot perform the Jira action directly. Prefer it for issue-link creation, issue-link listing, and other standard Jira work-item operations that `acli jira workitem` already supports.
- Use MCP for Jira issue edits whenever the fields are accessible there. Use Playwright for attachment uploads, inline image placement, or editor interactions that MCP and `acli` cannot express.
- Use `getTransitionsForJiraIssue`, `getJiraIssue`, `editJiraIssue`, `createJiraIssue`, `searchJiraIssuesUsingJql`, `lookupJiraAccountId`, and `jiraRead` before falling back to the browser.
- For issue links, prefer:
  - `acli jira workitem link list`
  - `acli jira workitem link create --out <KEY> --in <KEY> --type <outward description> --yes`
  - `acli jira workitem link type`
- Use Playwright only for Jira UI-only fields or when MCP metadata and `acli` both fail to expose the needed operation, field ids, allowed values, or validation requirements.
- When Playwright is required, inspect the page and, if needed, query Jira from the logged-in browser session with `/rest/api/3/issue/<key>/editmeta` and `/rest/api/3/issue/<key>/transitions?expand=transitions.fields` to recover field ids, transition-screen fields, and allowed values.

## Read the reference

Read [jira-field-map.md](references/jira-field-map.md) when you need:

- TherapyNotes-specific field ids and option ids
- known transition ids observed during `IT-17326`
- the current default values used on `ISD` change tickets
- the implementation-details copying rule and inline screenshot preference
