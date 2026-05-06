---
name: tn-ticket-intake
description: Turn short TherapyNotes ticket ideas into created Jira requests or IT tasks. Use when a user asks to "put in a ticket for this model", "request this ChatGPT feature", "request this Copilot feature", "approve this open source app", "install this open source app", "request this MCP server", "submit this vendor/system request", or wants a vague idea turned into the right TherapyNotes Jira ticket.
---

# TN Ticket Intake

Use this skill to classify, research, dedupe, draft, and create the initial TherapyNotes Jira ticket for AI model requests, native ChatGPT or GitHub Copilot feature requests, FOSS approvals, and vendor or MCP system changes.

Read `references/request-routing.md` before creating anything when the route is not obvious. Read `references/ticket-patterns.md` before filling portal fields or drafting the `IT` task body.

## Goal

Turn a short idea into the correct initial ticket with as little user effort as possible:

1. classify the request
2. gather only missing inputs
3. research official sources
4. check for duplicates
5. create the initial request or task
6. report what was created and why

Stop after the initial request or task is created. Do not move tickets through planning, architect review, change-ticket creation, or release workflows from this skill.

If the user explicitly wants the downstream GitHub Copilot rollout after an `ISD` AI model request already exists, hand off to `../tn-grc-ai-model-workflow/SKILL.md`.

## Tooling

- Use official vendor pages, model cards, changelogs, blogs, docs, and GitHub repositories for research.
- Use Atlassian Rovo MCP for Jira reads, JQL duplicate checks, and `IT` task creation.
- Use Playwright for `ISD` Service Desk portal `2` submissions because the service-desk request type selector is not exposed cleanly through standard Jira create metadata.

## Route The Request

Classify every request into one of four routes before drafting or creating anything.

### 1. AI model request

Use this route when the user wants a new model reviewed, approved, or added as a model.

Examples:
- `put in a ticket for GPT 5.4 Thinking`
- `request this new OpenAI model`
- `submit the model request for Claude Sonnet`

Create an `ISD` Service Desk request using request type `AI Models - Vendor System Management` (`337`).

### 2. Native ChatGPT or GitHub Copilot feature request

Use this route when the feature is native to ChatGPT or GitHub Copilot themselves, not a feature inside another vendor product.

Examples:
- `request this ChatGPT feature`
- `put in a ticket for Copilot coding agent`
- `request ChatGPT Skills`

Create an `IT` task under epic `IT-14359` (`AI Adoption Enhancements`).

### 3. FOSS software approval

Use this route when the user wants a new open source application, framework, or tool approved, installed, or evaluated.

Examples:
- `install this open source app on my work computer`
- `request Microsoft Agent Framework`

Create an `ISD` Service Desk request using request type `Free & Open Source Software - Vendor System Management` (`303`).

### 4. Vendor or MCP system request

Use this route when the user wants a feature or change inside an existing vendor system, or wants an MCP server that should be treated as part of a vendor or system request rather than a model request.

Examples:
- `Spacelift added Intelligence`
- `request this MCP server for Check Point`
- `turn on this AI feature in an existing vendor product`

Create an `ISD` Service Desk request using request type `General Vendor/System - Vendor System Management` (`270`).

### Route disambiguation

Ask one compact clarifying question only when classification is materially ambiguous. If the user names a new model, treat it as an AI model request. If the user names a native ChatGPT or GitHub Copilot capability, treat it as a native feature request. If the user names an open source product or GitHub repository, treat it as FOSS unless it is clearly an MCP or vendor change on an already-approved system.

## Gather Inputs

Ask only for missing high-value inputs, and ask in one compact batch.

Always try to capture:
- the product, model, or feature name
- why the user wants it
- the target platform only when the route is ambiguous
- deployment context or data type only when the default would be risky or clearly wrong

### Defaults

Use these defaults unless the user gives a better answer or the official source clearly indicates a different fit:
- `Reporter`: current authenticated user
- `AI model Action Type`: `Add`
- `FOSS Action Type`: `Add`
- `Data Type`: `Confidential`
- desktop-installed FOSS app: `Employee Internal Facing`
- AI model intake: initial `ISD` request, not the downstream Copilot enablement workflow

## Research

Use official sources and keep the research concise and reviewer-friendly.

### AI models

Find:
- official model card URL
- official release or announcement page
- one concise business justification in plain language

When the user provides only a vague reason, prefer a short justification such as `newer version of a model family we already use` plus one concrete capability improvement supported by the official source.

Do not invent a model card. If a trustworthy official model card cannot be found and the request appears to require one, stop and ask the user.

### FOSS software

Find:
- product or repository URL
- license
- vendor or organization name when obvious
- concise business justification based on the user's use case

Prefer the official repository or project site. Use the repository license rather than guessing.

### Native ChatGPT or Copilot features

Find:
- official changelog, doc page, or announcement post
- one short summary of what the feature does
- one short explanation of why it matters for TherapyNotes users

### Vendor or MCP requests

Find:
- official vendor product page, docs, or changelog
- whether the request is `Add` or `Change`
- concise change description for existing vendor features

Treat MCP servers tied to an existing vendor or platform as vendor or system requests unless the user explicitly wants a different route.

## Duplicate Checks

Run duplicate checks before creating anything.

### IT duplicate checks

For native ChatGPT or Copilot features, search `IT-14359` and nearby `IT` tasks using the feature name and platform name. Prefer Jira text or summary searches that can find obvious duplicates or near-duplicates.

### ISD duplicate checks

For `ISD` vendor-system flows, search recent `Vendor System Management` issues by product or model name and inspect the request type.

Match against:
- `AI Models - Vendor System Management` for route `337`
- `Free & Open Source Software - Vendor System Management` for route `303`
- `General Vendor/System - Vendor System Management` for route `270`

If a near-duplicate exists, stop and ask whether to:
- update the existing ticket
- skip because it already exists
- create a new ticket anyway

Do not silently create a duplicate.

## Create The Ticket

Follow the route-specific instructions below.

### AI model request -> ISD request type `337`

Create through Service Desk portal `2` using request type `AI Models - Vendor System Management`.

Use the summary format:
- `Add AI Model Request | <model name>`

Follow the field pattern from `ISD-92375`:
- `Action Type`: `Add`
- `AI Model Name`: full model name
- `Deployment Context`: use the best supported value from the user or source
- `Link to AI Model Card`: official model card URL
- `Business Justification`: include the official release link plus a concise plain-language justification
- `Data Type`: default `Confidential` unless the user gives a better answer
- leave change-only and removal-only fields blank for an add request

This route is for initial model intake. Do not convert it into the downstream Copilot rollout task unless the user explicitly asks for that workflow.

### Native ChatGPT or GitHub Copilot feature -> IT task under `IT-14359`

Create an `IT` `Task` under epic `IT-14359`.

Use a clear summary such as:
- `Enable ChatGPT Skills`
- `Enable GitHub Copilot Coding Agent for Jira`
- `Request <feature name>` when `Enable` would be misleading

Write the description with exactly these sections:
- `## Summary`
- `## Acceptance Criteria`
- `## Implementation Details`

Base the structure on `IT-17326` and the more polished language style in `IT-17369`.

Keep the body concise and specific:
- Summary: what the feature is and why TherapyNotes wants it
- Acceptance Criteria: 2-4 testable bullets
- Implementation Details: official source link, any enablement notes, and any reviewer-relevant constraints

Create only the initial `IT` task. Do not set sprint, story points, or create the companion `ISD` change ticket from this skill.

### FOSS software approval -> ISD request type `303`

Create through Service Desk portal `2` using request type `Free & Open Source Software - Vendor System Management`.

Use the summary format:
- `Add FOSS Vendor Request | <product name>`

Follow the field pattern from `ISD-92377` and `ISD-92378`:
- `Action Type`: `Add`
- `FOSS System`: leave blank unless the user gives a specific system classification
- `FOSS Vendor`: `New/Other` unless an existing vendor value is clearly appropriate
- `New FOSS System/Vendor Name`: product or project name
- `License Type`: official license value
- `Product Link`: official repository or product site
- `Deployment Context`: default desktop-installed apps to `Employee Internal Facing`
- `Data Type`: default `Confidential`
- `Business Justification`: polished, specific explanation of how the user plans to use the tool
- leave removal fields blank for add requests

### Vendor or MCP system request -> ISD request type `270`

Create through Service Desk portal `2` using request type `General Vendor/System - Vendor System Management`.

Use the summary format that matches the action:
- `Add General Vendor/System Request | <product or service name>`
- `Change General Vendor/System Request | <vendor or product name>`

Follow patterns like `ISD-92800` and `ISD-92994`:
- for net-new systems, prefer `Add`
- for new features inside an existing vendor product, prefer `Change`
- include vendor name, system type, deployment context, product or service name, licensing if relevant, product link, and a concise business justification
- for change requests, fill `Existing System/Vendor to Change/Remove` and `Vendor Change Description`

Treat MCP servers for existing vendors or platforms as this route by default.

## Portal Authentication Guardrail

Before submitting any `ISD` request, check whether Playwright is authenticated to Jira Service Desk portal `2`.

If the service desk shows a login screen or redirects to customer login:
- stop cleanly
- tell the user to log into the TherapyNotes service desk
- resume only after login is complete

Do not attempt to fake or bypass the login flow.

## Final Report

After creation, report:
- the chosen route
- the key ticket fields that were used
- the created issue key and link if creation succeeded
- any defaults or assumptions used
- any duplicate that was detected and how it was resolved

If creation was blocked, report the blocker clearly and stop.

## Guardrails

- Do not guess the route when classification is materially ambiguous.
- Do not invent official links, model cards, or licenses.
- Do not create duplicates without user approval.
- Do not move tickets through later workflow stages from this skill.
- Do not silently reroute native ChatGPT or Copilot features into the vendor-system flow unless the request is clearly about an existing vendor product or MCP system.
- Keep user questions short and bundled.
