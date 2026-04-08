# TherapyNotes GitHub Copilot Model Ticket Patterns

Observed and updated through 2026-03-09 while drafting `therapynotes-grc-ai-model-workflow`.

## Sections

- Source request pattern
- Target epic
- GitHub Copilot ticket pattern
- Copilot model policy interpretation
- Copilot wording template
- Screenshot handling
- Planning and change tickets
- Out-of-scope work
- Default behaviors worth rechecking

## Source Request Pattern

- Example source request: `ISD-92375`
- Title style: `Add AI Model Request | <model name>`
- Description commonly includes:
  - `Action Type`
  - `AI Model Name`
  - `Deployment Context`
  - model card URL
  - business justification URL and free text
  - `Data Type`
- Treat the description as the source of truth. If the target systems are still unclear after reading it, ask.

## Target Epic

- Create IT tasks under epic `IT-14359` (`AI Adoption Enhancements`).
- Search the epic before creating anything:
  - `parent = IT-14359 AND summary ~ "<model name>"`
  - `parent = IT-14359 AND summary ~ "GitHub Copilot"`
- If a close match already exists, ask whether to reuse or update it instead of creating a duplicate.

## GitHub Copilot Ticket Pattern

Primary examples:

- `IT-17034` `Enable Claude Haiku 4.5 in GitHub Copilot`
- `IT-17013` `Enable Claude Opus 4.6 in GitHub Copilot`
- `IT-16950` `Enable GPT 5.2 Codex GitHub Copilot Model`
- `IT-16699` `Enable GPT 5.1 Codex and Codex Max - GitHub Copilot Model`
- `IT-17358` `Enable Anthropic Claude Sonnet 4.6 in GitHub Copilot`

Observed Copilot structure:

- Summary section explains enabling the LLM in GitHub Copilot for developers and engineers.
- Acceptance criteria are short and concrete:
  - enable the model in GitHub Copilot
  - announce or communicate availability
- Implementation details are usually terse:
  - GitHub does not support configuring these options as code
  - enable the model
  - include one inline screenshot of the Copilot admin setting
- Prefer the full vendor-qualified model name in the summary when that is how the source request identifies the model. Example: `Anthropic Claude Sonnet 4.6`.

Observed linking pattern:

- The source GRC request commonly appears as a `Blocks` link on the new IT ticket.
- The companion change ticket uses `1 Relates`.

## Copilot Model Policy Interpretation

The GitHub Copilot admin UI exposes three policy states for many models:

- `Let organizations decide`
- `Enabled everywhere`
- `Disabled everywhere`

Use the screenshot to decide how to word the ticket:

- `Let organizations decide`: describe the outcome as organizational availability or organizational use. Do not overstate this as forced enablement for all users.
- `Enabled everywhere`: describe the outcome as broad availability that cannot be disabled at the organization level.
- `Disabled everywhere`: this conflicts with an enablement request. Ask before drafting or moving the ticket forward.

For Copilot screenshots, the strongest implementation detail is usually not the whole settings page but the model row and policy selector showing the selected state.

## Copilot Wording Template

This wording reviewed cleanly for `IT-17358` and is a good default for model-enable requests when the screenshot shows an enablement-oriented state.

Suggested IT summary:

- `Enable <full model name> in GitHub Copilot`

Suggested IT body:

```md
## Summary

As a system owner, I want to enable <full model name> in GitHub Copilot to provide more options to our developers and engineers for coding assistance.

## Acceptance Criteria

* Enable <full model name> in GitHub Copilot.
* Announce the new model to IT and Development.

## Implementation Details

GitHub does not support configuring these options as code.

* Enable <full model name> in GitHub Copilot.
* Validate the policy is set for organizational use in the GitHub Copilot admin settings.
* Use the attached admin screenshot as the implementation reference.
```

Adjust the validation bullet to match the screenshot's actual policy:

- For `Let organizations decide`: `Validate the policy is set for organizational use in the GitHub Copilot admin settings.`
- For `Enabled everywhere`: `Validate the policy is enabled everywhere in the GitHub Copilot admin settings.`

If the source request description is blank or unavailable through Jira, it is acceptable to draft from the source title, screenshot, and closest precedent. Surface that fallback in the final user report.

## Screenshot Handling

- Treat the Copilot screenshot as required before the ticket is ready for planning.
- Ask for the Copilot screenshot before finalizing the Copilot ticket.
- Prefer inline image placement over bare attachment links.
- Use stable Jira attachment URLs when you need a durable inline image source.
- Use Playwright only when Jira MCP cannot upload or place the screenshot inline.
- For Copilot model enables, reuse the same screenshot inline on the IT ticket and the companion change ticket unless the user provides a better change-specific image.

## Planning And Change Tickets

- After each IT ticket has its screenshot, sprint, and story points, follow:
  - `/Users/tfinklea/.codex/skills/therapynotes-it-change-workflow/SKILL.md`
  - `/Users/tfinklea/.codex/skills/therapynotes-it-change-workflow/references/jira-field-map.md`
- Reuse that workflow for:
  - sprint assignment
  - story points
  - priority normalization
  - assignee and planner handling
  - change ticket creation
  - architect-review transitions

For Copilot model-enable changes, this default pattern worked cleanly:

- Change summary: `<IT-key> - <IT summary>`
- Link to the IT ticket with `1 Relates`
- Reuse the IT implementation details almost verbatim in `Implementation Plan`
- Start the implementation plan with `Implementation Details From <IT-key>`
- Inline the same admin screenshot used on the IT ticket
- Rollback/Contingency Plan:
  - `Disable <full model name> in GitHub Copilot if validation or stakeholder feedback identifies an issue after enablement.`
- Test and Monitoring Plan:
  - `Verify <full model name> is enabled in the GitHub Copilot admin settings and confirm the availability announcement is sent to IT and Development.`
- Change Risk Detail:
  - `Low-risk administrative configuration change in GitHub Copilot. No code deployment is involved, and the model policy can be reverted by restoring the previous setting.`

Observed field pattern on `ISD-92474`:

- Priority: `Medium`
- Change Type: `Normal`
- Implementation Path: `Ad Hoc`
- Change Risk Level: `Low`
- Cloud Cost Action: `No cost implication`
- Lead Reviewer: `Joshua Klingerman`
- Team: `IT Management`
- Tech Team: `IT Management`

## Out-Of-Scope Work

- This skill does not handle ChatGPT Enterprise model-enablement requests.
- If the source request also mentions ChatGPT Enterprise or another non-Copilot target system, stop and ask whether to proceed with the Copilot portion only or to treat the other system as a separate workflow.

## Default Behaviors Worth Rechecking

- Keep the current authenticated user as assignee and planner unless the user says otherwise.
- Use the same sprint and story points for the Copilot IT ticket and its change ticket unless the user says otherwise.
- Do not create the change ticket until the Copilot IT ticket is fully drafted and has its screenshot.
- If a companion change ticket already exists, update it instead of creating another one.
