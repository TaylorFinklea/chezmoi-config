# TherapyNotes Ticket Routing

Use this file to choose the correct first-step Jira destination for TherapyNotes ticket intake.

## Routes

### AI model request

Use when the request is for a model itself.

Signals:
- user names a model family or version
- user asks for a model card-based request
- user wants a new model reviewed, approved, or added

Destination:
- project: `ISD`
- issue type: `Vendor System Management`
- portal: `2`
- request type: `337`
- request type name: `AI Models - Vendor System Management`

Reference ticket:
- `ISD-92375`

Summary format:
- `Add AI Model Request | <model name>`

## Native ChatGPT or GitHub Copilot feature

Use when the feature is native to ChatGPT or GitHub Copilot.

Signals:
- user says `ChatGPT feature`
- user says `Copilot feature`
- official source is an OpenAI or GitHub Copilot feature announcement
- request is not about an external vendor product

Destination:
- project: `IT`
- issue type: `Task`
- parent epic: `IT-14359`
- epic name: `AI Adoption Enhancements`

Reference tickets:
- `IT-17326`
- `IT-17369`

Description format:
- `## Summary`
- `## Acceptance Criteria`
- `## Implementation Details`

## FOSS software approval

Use when the user wants approval or installation for open source software.

Signals:
- GitHub repository or open source project
- user mentions install or approve on work computer
- request is for a framework, tool, desktop app, or internal-use OSS product

Destination:
- project: `ISD`
- issue type: `Vendor System Management`
- portal: `2`
- request type: `303`
- request type name: `Free & Open Source Software - Vendor System Management`

Reference tickets:
- `ISD-92377`
- `ISD-92378`

Summary format:
- `Add FOSS Vendor Request | <product name>`

Default deployment context:
- desktop-installed or employee-use app -> `Employee Internal Facing`

## Vendor or MCP system request

Use when the request is for:
- a new feature in an existing vendor product
- an MCP server tied to an existing vendor or platform
- a vendor or system change that is not a model request and not a pure FOSS approval

Destination:
- project: `ISD`
- issue type: `Vendor System Management`
- portal: `2`
- request type: `270`
- request type name: `General Vendor/System - Vendor System Management`

Reference tickets:
- `ISD-92800`
- `ISD-92994`
- `ISD-92276`

Summary format:
- `Add General Vendor/System Request | <product or service>`
- `Change General Vendor/System Request | <vendor or product>`

## Ambiguity rules

If the request could fit multiple routes, resolve it in this order:

1. model name present -> AI model request
2. native ChatGPT or GitHub Copilot capability -> native feature
3. open source product or GitHub repository -> FOSS approval
4. existing vendor platform, vendor AI feature, or MCP tied to a vendor -> vendor or MCP system request

Ask one compact clarifying question only when the destination still cannot be determined safely.
