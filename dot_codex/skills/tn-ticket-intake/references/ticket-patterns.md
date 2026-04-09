# TherapyNotes Ticket Patterns

Use these patterns to keep new tickets aligned with the current TherapyNotes examples.

## AI Model Request Pattern

Reference: `ISD-92375`

Summary:
- `Add AI Model Request | <model name>`

Core fields:
- `Action Type:` `Add`
- `AI Model Name:` full model name
- `Deployment Context:` user-provided or source-supported value
- `Link to AI Model Card:` official model card URL
- `Business Justification:`
  - official launch or announcement URL
  - one short plain-language reason tied to the user's goal
- `Data Type:` default `Confidential`

Recommended justification style:
- first line: official release link
- second line: why the model is worth evaluating or enabling
- keep it short and concrete

Example phrasing:
- `Newer model from <vendor> with stronger coding and general reasoning capabilities than the version we already use.`
- `Updated version of a model family already familiar to the team, with improved quality and efficiency.`

## Native ChatGPT or Copilot Feature Pattern

References:
- `IT-17326`
- `IT-17369`

Summary:
- `Enable <feature name>` when enablement is the right framing
- `Request <feature name>` when the work is exploratory or broader than a toggle

Description template:

```markdown
## Summary

As a system owner, I want to enable <feature name> so <business reason>.

## Acceptance Criteria

* Enable or configure <feature name> in the target platform.
* Validate the feature works as expected for the intended users.
* Communicate availability or next steps to the relevant teams when appropriate.

## Implementation Details

* Official source: <link>
* Reviewer notes: <platform-specific notes>
* Validation notes: <what should be checked>
```

Guidance:
- keep acceptance criteria testable
- cite the official feature announcement or documentation
- avoid placeholders or half-finished templates
- do not set sprint, story points, or later workflow fields from this skill

## FOSS Request Pattern

References:
- `ISD-92377`
- `ISD-92378`

Summary:
- `Add FOSS Vendor Request | <product name>`

Core fields:
- `Action Type:` `Add`
- `FOSS Vendor:` usually `New/Other`
- `New FOSS System/Vendor Name:` product or project name
- `License Type:` official license
- `Product Link:` official repo or site
- `Deployment Context:`
  - default desktop/internal tools to `Employee Internal Facing`
- `Data Type:` default `Confidential`
- `Business Justification:` specific usage at TherapyNotes

Recommended justification style:
- one sentence on what the tool is
- one sentence on how the requester plans to use it
- one sentence on why that matters for the team or workflow

Example phrasing:
- `Low-code framework for building agents that would help Engineering prototype more purpose-built internal agents.`
- `Open source framework to use in a proof of concept for granular internal automation and agent workflows.`

## Vendor or MCP Request Pattern

References:
- `ISD-92800`
- `ISD-92994`
- `ISD-92276`

Summary:
- `Add General Vendor/System Request | <product or service>`
- `Change General Vendor/System Request | <vendor or product>`

Choose `Add` when requesting a new system or service.
Choose `Change` when requesting a new capability inside an existing vendor or product.

Core fields for `Add`:
- `Vendor Name:` existing vendor when known, otherwise `New/Other`
- `New Vendor Name:` only when needed
- `System Type:` use source-supported value such as `AI System` or `Cloud System`
- `Deployment Context:` use the best available match
- `Product/Service Name:` requested capability or service name
- `Licensing:` only when relevant
- `Business Justification:` short, concrete, reviewer-friendly
- `Product Link:` official source

Core fields for `Change`:
- `Existing System/Vendor to Change/Remove:` current vendor or system
- `Vendor Change Description:` concise summary of the new feature or capability
- include the same supporting source link and business justification

MCP guidance:
- existing vendor MCP -> usually `General Vendor/System`
- net-new open source MCP project -> usually `FOSS`
- AI model-related request with model card requirement -> `AI Models`

## Duplicate Check Pattern

Before creating any ticket:
- search for the exact model, feature, vendor, or product name
- search the likely destination project and route-specific request type
- inspect recent issues with similar summaries
- ask before creating a near-duplicate

## Reporting Pattern

After creation, report:
- route used
- destination project and request type
- key fields filled
- created issue key and link
- assumptions used
- duplicate handling decision, if any
