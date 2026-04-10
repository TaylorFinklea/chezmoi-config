---
name: tn-grc-ai-model-workflow
description: Convert TherapyNotes GRC AI model request tickets into planned AI Adoption Enhancements tasks and companion change tickets for GitHub Copilot model enablement. Use when a user provides a source GRC or ISD AI model request, wants a GitHub Copilot enablement ticket created under IT-14359, needs the Copilot screenshot attached inline, or wants the follow-on ISD change ticket generated. Ask clarifying questions whenever GitHub Copilot targeting, screenshot readiness, sprint, story points, duplicates, or precedent are uncertain.
---

# TN GRC AI Model Workflow

## Overview

Turn a GRC AI model request into one GitHub Copilot IT task under `IT-14359`, collect the required Copilot admin screenshot, and then plan that IT ticket through the existing TherapyNotes change workflow so it gets its companion `ISD` change ticket.

Read [references/ticket-patterns.md](references/ticket-patterns.md) before drafting anything. Read `../tn-it-change-workflow/SKILL.md` and `../tn-it-change-workflow/references/jira-field-map.md` before planning or creating change tickets.

## Guardrails

- Ask instead of guessing when the request does not clearly target GitHub Copilot.
- Stop and clarify if the request appears to require ChatGPT Enterprise or another non-Copilot rollout. This skill only covers the GitHub Copilot path.
- Ask if the source GRC ticket, epic search, or linked issues show a near-duplicate.
- Ask if the user has not provided sprint or story points.
- Ask for the GitHub Copilot screenshot before treating the ticket as ready for planning or change-ticket creation.
- Do not invent admin steps that are not visible in the source request, screenshots, or close precedents.
- Keep the current authenticated Jira user as assignee and planner unless the user says otherwise.
- Use Atlassian Rovo MCP first. Use Playwright only for attachment upload and inline image placement.

## Workflow

### 1. Inspect the source request

- Read the source GRC or ISD ticket and extract the model name, action type, deployment context, model card URL, business justification, data type, and any notes about rollout scope.
- Treat the description as the source of truth, not the title alone.
- If the Jira API returns a blank or unavailable description, fall back to the source title, the provided screenshot, and the closest precedent. Call out that fallback as an assumption in the final report.
- If the ticket does not clearly say the model should be enabled in GitHub Copilot, ask before drafting or creating anything.

### 2. Decide the target tickets

- Create a GitHub Copilot IT ticket for every model request this workflow handles unless the user explicitly says otherwise.
- Search `IT-14359` for the model name and `GitHub Copilot` before creating anything. If a matching or near-matching ticket already exists, ask whether to update it or skip it.
- If the request also mentions ChatGPT Enterprise or another target system, call out that this skill only handles the Copilot rollout and ask whether to proceed with the Copilot ticket only.

### 3. Pick the precedent

- Use the nearest Copilot precedent from [references/ticket-patterns.md](references/ticket-patterns.md) for Copilot wording and screenshot placement.
- If no close precedent exists, say which ticket is only a partial match and ask before going further.

### 4. Draft the Copilot ticket

- Create an IT task under epic `IT-14359`.
- Use a clear summary such as `Enable <model> in GitHub Copilot`.
- Prefer the full vendor-qualified model name when the source request uses it, such as `Anthropic Claude Sonnet 4.6` instead of shortening it to `Claude Sonnet 4.6`.
- Mirror the established Copilot structure:
  - `Summary`
  - `Acceptance Criteria`
  - `Implementation Details`
- Keep the body short and concrete. Include:
  - why the model is being enabled
  - GitHub Copilot as the target system
  - validation and announcement expectations
  - the note that GitHub does not support this as code when that precedent still applies
  - model card or justification links when they help reviewers
- Use the screenshot to infer the intended GitHub Copilot policy state:
  - `Let organizations decide` means the ticket should describe organizational availability, not forced global enablement
  - `Enabled everywhere` means the ticket can describe broad availability that cannot be disabled at the organization level
  - `Disabled everywhere` conflicts with an enablement request and should trigger a clarification
- Link the source GRC request as a blocker if that matches the precedent and no conflicting pattern exists.
- Stop and ask for the Copilot screenshot if it has not been provided yet.
- After receiving it, upload it and place it inline in `Implementation Details`.

### 5. Plan the Copilot ticket

- Once the Copilot ticket has its screenshot and the user has provided sprint and story points, follow `../tn-it-change-workflow/SKILL.md`.
- Reuse that workflow to:
  - set sprint and story points
  - normalize priority
  - set assignee, planner, and team fields
  - create or update the companion `ISD` change ticket
  - move both tickets to the appropriate review state
- For model-enable change tickets, reuse the proven low-risk administrative-change wording from [references/ticket-patterns.md](references/ticket-patterns.md), including copying the implementation details into the change plan and reusing the same screenshot inline.

### 6. Report the result

- Summarize what was created or updated.
- Provide links or keys for:
  - the source GRC ticket
  - the Copilot IT ticket and its change ticket
- Call out any open questions, skipped work, or assumptions that still need confirmation.

## Ticket Content Rules

- Keep summaries specific to GitHub Copilot.
- Use one Copilot screenshot at minimum.
- Prefer inline images over bare attachment links.
- Preserve useful wording from the source GRC ticket, but rewrite placeholders or vague text into direct reviewer-friendly language.
- Keep Copilot implementation wording aligned to the actual policy shown in the screenshot rather than assuming every model is simply `enabled`.
- Do not move a ticket into planning or change workflow if its required screenshot is still missing.
- Do not silently normalize model names if the source request uses a new or unusual naming format. Ask if the naming is unclear.

## When To Ask

Ask the user before editing or creating tickets when any of the following are unclear:

- whether GitHub Copilot is the intended rollout target when the request mentions multiple systems
- which prior ticket should be treated as the closest precedent
- whether an existing epic ticket should be reused instead of creating a new one
- whether a screenshot is current enough to attach
- whether the GRC request should be linked as the blocking ticket for the new IT work
