---
name: tn-grc-ai-adoption-workflow
description: Convert existing TherapyNotes GRC or ISD AI adoption requests, including MCP server requests, into planned AI Adoption Enhancements work under IT-14359, ask which sprint and story points to use, move the IT ticket to Architect Review, link the source and companion tickets, and create or update the companion ISD change ticket in In Preparation. Use when the upstream request already exists and the user wants the downstream AI Adoption implementation ticket and change-management workflow completed.
---

# TN GRC AI Adoption Workflow

## Overview

Use this skill when the source GRC or `ISD` request already exists and the next step is to create or update the downstream implementation ticket in `IT-14359` (`AI Adoption Enhancements`), assign it to the intended sprint, move it through planning until it reaches `Architect Review`, link the source and downstream tickets, and create or update its companion `ISD` change ticket while leaving that change ticket in `In Preparation`.

Read `../tn-it-change-workflow/SKILL.md` and `../tn-it-change-workflow/references/jira-field-map.md` before moving any IT ticket into planning or creating the change ticket.

If the request is specifically an AI model approval that should become a GitHub Copilot model-enable ticket, use `../tn-grc-ai-model-workflow/SKILL.md` instead.

## Guardrails

- Treat the source GRC or `ISD` request as the source of truth, not the title alone.
- Use Atlassian Rovo MCP first. Use Atlassian CLI (`acli`) before Playwright for Jira actions that MCP does not expose cleanly, especially issue linking. Use Playwright only for Jira UI gaps such as attachment upload or inline image placement.
- Mirror the precedent link pattern unless the user says otherwise:
  - source `ISD` or GRC request `Blocks` the downstream `IT` implementation ticket
  - downstream `IT` implementation ticket `1 Relates` to the companion `ISD` change ticket
- Search `IT-14359` before creating a new AI Adoption ticket. If a close match exists, ask whether to update it, reuse it, or create a new one anyway.
- Ask the user which sprint to use before changing sprint.
- Ask for story points too if they are missing, because the downstream IT change workflow expects both sprint and story points before transition.
- Keep the current authenticated Jira user as assignee and planner unless the user says otherwise.
- Reuse the existing TherapyNotes IT change workflow for the transition and change-ticket steps instead of reinventing field handling.
- When link creation is needed and Atlassian Rovo MCP cannot write it directly, prefer `acli jira workitem link create` and `acli jira workitem link list` over a browser workflow.
- Do not move the companion `ISD` change ticket past `In Preparation` in this workflow unless the user explicitly asks for that additional step.
- If the source request is actually a model-enablement request for GitHub Copilot, stop and hand off to the Copilot-specific GRC workflow.

## Workflow

### 1. Inspect the source request

- Read the source GRC or `ISD` ticket.
- Extract the request type, product or capability name, vendor, target platform, justification, relevant URLs, screenshots, and any notes about rollout or validation.
- Confirm the request belongs in `AI Adoption Enhancements` rather than a pure service-desk-only flow.
- If the target implementation system is unclear, ask before creating anything.

### 2. Decide the AI Adoption ticket

- Search `IT-14359` using the product name, vendor name, and `MCP` or other distinctive request terms.
- If a near-duplicate exists, ask whether to:
  - update the existing ticket
  - skip because the work already exists
  - create a new ticket anyway
- Create a new `IT` task under `IT-14359` only when no acceptable existing ticket should be reused.

### 3. Draft the IT ticket

- Use a concrete summary that names the implementation work plainly.
- For MCP server requests, prefer summary patterns such as:
  - `Enable <product> MCP Server`
  - `Implement <vendor> MCP Server Access`
  - `Add <product> MCP Integration for AI Adoption`
- For other AI adoption work, keep the same standard structure and write the summary in direct implementation language.
- Write the description with exactly these sections:
  - `## Summary`
  - `## Acceptance Criteria`
  - `## Implementation Details`
- Keep the body concise and reviewer-friendly:
  - `Summary`: what is being enabled or implemented and why TherapyNotes wants it
  - `Acceptance Criteria`: 2 to 4 testable outcomes
  - `Implementation Details`: source request context, official links, implementation notes, validation approach, and any reviewer-relevant constraints
- Preserve useful wording and links from the source request, but rewrite vague request text into direct implementation language.
- Link the source GRC or `ISD` request to the IT ticket using the normal precedent pattern unless the user says otherwise.

### 4. Ask for planning inputs

- Ask the user which sprint the IT ticket should go into.
- Ask for story points in the same compact question if they are not already known.
- If the user gives a relative sprint such as `next sprint`, resolve it to the exact Jira sprint before editing the ticket and report the resolved sprint name back.

### 5. Run the planning and change workflow

- After the IT ticket is drafted and the sprint and story points are known, follow `../tn-it-change-workflow/SKILL.md`.
- Reuse that workflow to:
  - set sprint and story points
  - normalize priority
  - set assignee, planner, team, and tech team fields as needed
  - move the IT ticket through the required statuses until it reaches `Architect Review`
  - create or update the companion `ISD` change ticket
  - populate the change ticket from the IT ticket implementation details
  - add the expected issue links between source request, IT implementation ticket, and companion change ticket
  - leave the companion `ISD` change ticket in `In Preparation`

### 6. Report the result

- Summarize what was created or updated.
- Provide the source ticket key, AI Adoption IT ticket key, and companion change-ticket key.
- Report the final sprint, story points, statuses, assignee, planner, and the issue-link relationships that were created or verified.
- Call out any assumptions or fallbacks used.

## When To Ask

Ask before proceeding when any of the following are unclear:

- whether the source request should become work under `IT-14359`
- whether an existing AI Adoption ticket should be reused
- which sprint should be used
- how many story points should be set
- whether the request should follow the Copilot model-enable workflow instead of this general AI Adoption workflow
