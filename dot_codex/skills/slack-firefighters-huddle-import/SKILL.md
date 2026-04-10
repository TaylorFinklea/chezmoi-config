---
name: slack-firefighters-huddle-import
description: Import unseen Slack #firefighters huddle note canvases into the local Codex transcript workspace. Use when Codex needs to open Slack, switch to the #firefighters channel canvases, find canvas titles like `Huddle notes: 3/9/26 in #firefighters`, extract both the AI-generated huddle notes and the full huddle transcript, generate a combined PDF, stage the raw PDF under `/Users/tfinklea/codex/.tmp/transcript-imports`, ingest it with `--source slack-huddle`, and preserve the exact Slack huddle thread permalink as transcript metadata.
---

# Slack Firefighters Huddle Import

Use Playwright MCP for every browser action and the bundled helper script for all local state, cutoff handling, download claiming, ingestion, and final reporting.

## Prerequisites

1. Start from `/Users/tfinklea/codex`.
2. Use the Playwright MCP browser tools directly, not the shell wrapper.
3. Treat `/Users/tfinklea/codex/.tmp/transcript-imports` as the only staging area for raw downloads.
4. Never write raw files directly into `/Users/tfinklea/codex/transcripts`.

Set the helper path once:

```bash
export SLACK_HUDDLE_IMPORTER="$HOME/.codex/skills/slack-firefighters-huddle-import/scripts/slack_huddle_import.py"
export SLACK_HUDDLE_IMPORT_CUTOFF="2025-03-10"
```

This importer should only process huddles from the past year inclusive.
Because today is Thursday, March 11, 2026, skip canvases on or before `2025-03-10` and import canvases on or after `2025-03-11`.

## Run The Workflow

1. Start the local run state:

```bash
python3 "$SLACK_HUDDLE_IMPORTER" start-run
```

2. Immediately mark already-discovered huddles on or before the cutoff as already run:

```bash
python3 "$SLACK_HUDDLE_IMPORTER" apply-cutoff \
  --run-id "<run-id>" \
  --on-or-before "$SLACK_HUDDLE_IMPORT_CUTOFF"
```

3. Open this channel in Playwright MCP:

```text
https://therapynotes.slack.com/archives/CFHP0HT8F
```

4. If Slack sign-in, SSO, or workspace selection appears:
   - pause
   - tell the user to finish auth in the current browser session
   - resume from the loaded workspace
5. Confirm the `#firefighters` channel is loaded.
6. Switch to the channel `Canvases` view.
7. Collect canvas URLs and visible titles. Keep scrolling until two consecutive passes produce no new matching canvas URLs.
8. Only keep canvases whose visible title starts with `Huddle notes:` and ends with `in #firefighters`.
9. Parse the occurred date from the canvas title before opening the detail tab. If the date is on or before the cutoff, do not open that canvas.

## Process One Canvas

For each collected canvas URL:

1. Ask the helper whether the huddle still needs work:

```bash
python3 "$SLACK_HUDDLE_IMPORTER" should-process \
  --run-id "<run-id>" \
  --canvas-url "<canvas-url>" \
  --title "Huddle notes: 3/9/26 in #firefighters" \
  --occurred-at YYYY-MM-DD \
  --skip-on-or-before "$SLACK_HUDDLE_IMPORT_CUTOFF"
```

2. If `should_process` is `false`, skip the canvas.
   - When `marked_as_run` is `true`, treat it as intentional backlog clearing because it happened on or before the cutoff.
3. Open the canvas in a separate detail tab. Keep the channel canvases tab open for the entire run.
4. Extract the exact Slack huddle thread permalink from the visible `View huddle in channel` link.
   - Do not continue if the exact thread permalink is missing.
5. Call `should-process` again with the exact thread permalink so the helper uses that as the canonical identity:

```bash
python3 "$SLACK_HUDDLE_IMPORTER" should-process \
  --run-id "<run-id>" \
  --canvas-url "<canvas-url>" \
  --thread-url "<exact-thread-url>" \
  --title "Huddle notes: 3/9/26 in #firefighters" \
  --occurred-at YYYY-MM-DD \
  --skip-on-or-before "$SLACK_HUDDLE_IMPORT_CUTOFF"
```

6. Generate the canonical PDF programmatically with Playwright from the open canvas tab. Do not export the raw canvas directly, because that only captures Slack AI notes. The canonical PDF must contain both:
   - the AI-generated huddle notes already visible in the canvas
   - the full huddle transcript from the `Huddle transcript` flow at the bottom of the canvas
   Use a filename derived from the visible title and write it into `/Users/tfinklea/Downloads`.
   - Prefer a safe filename like `Huddle notes 3-9-26 in firefighters.pdf`.
   - Extract the AI notes text before opening the transcript preview.
   - Open the transcript in two steps:
     - focus the hidden file preview activator whose text contains `/huddle_transcript` and press `Enter`
     - wait for the `File preview` dialog, focus its inner file-card button, and press `Enter`
   - Wait for the `Huddle transcript` dialog to appear and for its text to include `Transcript of huddle in #firefighters`.
   - Build a clean HTML document that contains two sections, `AI Summary and Notes` and `Full Huddle Transcript`, then print that HTML to PDF.
   - Use Playwright code like:

```javascript
async (page) => {
  const targetPath = "/Users/tfinklea/Downloads/Huddle notes 3-9-26 in firefighters.pdf";
  const escapeHtml = (value) =>
    value
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;");

  const summaryPayload = await page.evaluate(() => {
    const article = document.querySelector("article.document-content");
    if (!article) {
      throw new Error("Canvas article not found");
    }
    const heading =
      article.querySelector('[role="heading"][aria-level="1"]') ||
      article.querySelector("h1");
    const rawText = (article.innerText || "").trim();
    const summaryText = rawText.split("\nHuddle transcript")[0].trim();
    const firstSummaryLine =
      summaryText
        .split("\n")
        .map((line) => line.trim())
        .find(Boolean) || null;
    const title =
      heading?.textContent?.trim() ||
      firstSummaryLine ||
      document.title ||
      "Slack huddle notes";
    return { title, summaryText };
  });

  const transcriptActivator = page
    .locator('[role="button"]')
    .filter({ hasText: "huddle_transcript" })
    .first();
  await transcriptActivator.focus();
  await transcriptActivator.press("Enter");

  const filePreviewButton = page
    .locator('[role="dialog"][aria-label="File preview"] span[role="button"]')
    .first();
  await filePreviewButton.waitFor({ state: "visible", timeout: 15000 });
  await filePreviewButton.focus();
  await filePreviewButton.press("Enter");

  const transcriptDialog = page.locator(
    '[role="dialog"][aria-label="Huddle transcript"]'
  );
  await transcriptDialog.waitFor({ state: "visible", timeout: 15000 });
  await page.waitForFunction(() => {
    const dialog = document.querySelector(
      '[role="dialog"][aria-label="Huddle transcript"]'
    );
    const text = dialog?.textContent || "";
    return (
      text.includes("Transcript of huddle in #firefighters") &&
      !text.includes("loading…")
    );
  });

  const transcriptText = await transcriptDialog.innerText();
  const pdfPage = await page.context().newPage();
  await pdfPage.setContent(
    `
      <html>
        <head>
          <style>
            body { font-family: Georgia, serif; margin: 0.6in; color: #111; }
            h1, h2 { margin: 0 0 0.18in 0; }
            h1 { font-size: 22px; }
            h2 { font-size: 16px; margin-top: 0.35in; }
            pre {
              white-space: pre-wrap;
              font-family: "SFMono-Regular", "Menlo", monospace;
              font-size: 10.5px;
              line-height: 1.45;
              margin: 0;
            }
          </style>
        </head>
        <body>
          <h1>${escapeHtml(summaryPayload.title)}</h1>
          <h2>AI Summary and Notes</h2>
          <pre>${escapeHtml(summaryPayload.summaryText)}</pre>
          <h2>Full Huddle Transcript</h2>
          <pre>${escapeHtml(transcriptText)}</pre>
        </body>
      </html>
    `,
    { waitUntil: "load" }
  );
  await pdfPage.pdf({
    path: targetPath,
    format: "Letter",
    printBackground: true,
    margin: { top: "0.5in", right: "0.5in", bottom: "0.5in", left: "0.5in" },
  });
  await pdfPage.close();
  return {
    path: targetPath,
    transcript_length: transcriptText.length,
  };
}
```

7. Immediately hand control to the helper:

```bash
python3 "$SLACK_HUDDLE_IMPORTER" claim-downloads \
  --run-id "<run-id>" \
  --canvas-url "<canvas-url>" \
  --thread-url "<exact-thread-url>" \
  --title "Huddle notes: 3/9/26 in #firefighters" \
  --occurred-at YYYY-MM-DD \
  --since-epoch "<unix-seconds-before-pdf-generation>" \
  --downloads-dir "/Users/tfinklea/Downloads" \
  --staging-dir "/Users/tfinklea/codex/.tmp/transcript-imports"
```

8. Ingest the staged PDF:

```bash
python3 "$SLACK_HUDDLE_IMPORTER" ingest-meeting \
  --run-id "<run-id>" \
  --canvas-url "<canvas-url>" \
  --thread-url "<exact-thread-url>" \
  --workspace "/Users/tfinklea/codex" \
  --title "Huddle notes: 3/9/26 in #firefighters" \
  --occurred-at YYYY-MM-DD
```

9. Close only the detail tab when that canvas is finished, then return to the canvases tab.

## Canonical Ingest Rules

- Slack canonical format is `.pdf`.
- The canonical Slack PDF must contain both the AI summary canvas content and the full `Huddle transcript` dialog text.
- Ingest with `--source slack-huddle`.
- Always pass the exact Slack huddle thread permalink as `--source-url`.
- Use the exact thread permalink as the canonical meeting identity when it is available.
- Meetings on or before `2025-03-10` are an explicit exception: mark them as already run and skip ingest.
- For canvases after the cutoff, treat a huddle as processed only after the helper records a successful ingest result or a `duplicate_of` result.

## Finish The Run

After all canvases are processed:

```bash
python3 "$SLACK_HUDDLE_IMPORTER" finalize-run \
  --run-id "<run-id>" \
  --workspace "/Users/tfinklea/codex"
```

Use that output as the final user-facing summary.
The imported file lines include the exact Slack thread permalink in the last column.

## Failure Handling

- If the `Canvases` UI drifts, save a screenshot under `output/playwright/slack-firefighters-huddle-import/` and stop with a precise error.
- If the exact `View huddle in channel` permalink is missing, record the canvas as blocked and leave it retryable.
- If the `Huddle transcript` preview chain does not load a full transcript dialog, record the canvas as blocked and leave it retryable.
- If PDF generation or claiming fails, record the canvas as blocked and leave it retryable.
- If ingest fails, report the exact staged file path and the CLI error from the helper output.
- Do not manually edit the helper state DB; rerun the helper subcommands instead.

## Reference

Read `references/ui-notes.md` when:

- the Slack channel UI or canvases UI labels differ from expectation
- the `View huddle in channel` link is hard to locate
- the canvas PDF output needs troubleshooting
- Slack auth or workspace switching behaves unexpectedly
