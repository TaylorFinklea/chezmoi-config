# UI Notes

Use this file only when the Slack UI does not match the main workflow.

## Entry Behavior

- The channel entrypoint is `https://therapynotes.slack.com/archives/CFHP0HT8F`.
- Slack may first show SSO, workspace picker, or a stale session recovery flow.
- Do not assume silent auth. Pause for manual completion if Slack does not land in the workspace cleanly.

## Channel Confirmation

Look for evidence that the `#firefighters` channel is active before proceeding:

- the channel name `#firefighters`
- a top navigation area with views like `Messages`, `Files`, or `Canvases`
- recent channel content in the main pane

If those signals are absent, snapshot the page again before concluding the UI drifted.

## Canvases View Strategy

- Prefer clicking a visible `Canvases` tab or view chip by accessible name.
- If Slack groups views under a more-menu, open the menu and choose `Canvases`.
- After the canvases list loads, re-snapshot the page before collecting refs or links.

## Discovery Strategy

- Extract canvas URLs and visible titles into a local list.
- Only keep titles that match the pattern `Huddle notes: <date> in #firefighters`.
- Parse the visible date from the title before opening the canvas.
- This workspace uses a one-year inclusive import window ending today, March 11, 2026.
- Skip canvases on or before `2025-03-10`.
- Keep the canvases list open in a dedicated tab and open each canvas in a separate detail tab.
- Close only the detail tab after each huddle. Do not close the canvases tab during the run.

## Exact Thread Link

- The exact Slack huddle thread permalink is required metadata.
- Prefer a visible `View huddle in channel` link inside the canvas.
- Capture the actual `href`, not just the visible label text.
- If the link opens a preview popover or menu first, use that flow, but do not settle for the canvas URL as the source link when the real thread permalink is available.
- If the exact thread permalink is unavailable, stop processing that canvas and record it as blocked.

## PDF Generation

- The canonical ingest format is a PDF generated from a combined view, not the raw canvas alone.
- A direct PDF of the canvas only captures the Slack AI notes. It misses the full verbatim huddle transcript.
- Prefer Playwright `page.pdf()` from a temporary print page that combines the canvas notes and the transcript dialog text.
- Write the PDF to `/Users/tfinklea/Downloads`, then let the helper claim and move it into staging.
- Use a stable filename derived from the visible canvas title so repeated runs are predictable.
- Record the time immediately before PDF generation and pass that timestamp to `claim-downloads`.

## Transcript Expansion

- The transcript lives in an embedded file-preview section near the bottom of the canvas, not in the visible notes body by default.
- The hidden preview activator is a `role="button"` element whose text contains a Slack file URL ending in `/huddle_transcript`.
- Reliable sequence:
  - capture the AI notes text from `article.document-content` before opening the transcript
  - focus the hidden `/huddle_transcript` button and press `Enter`
  - wait for the `File preview` dialog
  - focus the file card inside that dialog and press `Enter`
  - wait for the `Huddle transcript` dialog
  - confirm it contains `Transcript of huddle in #firefighters`
- Do not continue if the dialog only shows the file card header. The transcript body must be visible.
- The transcript dialog text is the source of truth for the full transcript. Export that text into the combined PDF under a `Full Huddle Transcript` heading.
- The canvas title is most reliably exposed as a heading-like element with `role="heading"` and `aria-level="1"`, not always a literal `h1`.
- If that heading is blank, use the first non-empty line of the captured AI notes text. In practice that line is the visible huddle title.

## Metadata Reliability

Only pass metadata to the helper when the UI is explicit:

- title visible as the canvas heading
- occurred date visible in the heading text
- participants visible in the AI notes attendee section or another explicit attendee block

If metadata is weak, omit it and let the ingest pipeline infer it from the PDF.

## Drift Response

- Save a screenshot under `output/playwright/slack-firefighters-huddle-import/`.
- Include the current page URL, the missing expected element, and the last successful action in the error.
- Stop instead of guessing through changed Slack navigation or canvas controls.
