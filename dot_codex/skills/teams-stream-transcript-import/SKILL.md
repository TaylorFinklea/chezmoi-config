---
name: teams-stream-transcript-import
description: Import unseen Teams meeting transcripts from SharePoint Stream or Clipchamp into the local Codex transcript workspace. Use when Codex needs to open the Stream video hub, filter to Meetings, inspect individual meeting detail pages, download transcript exports as `.vtt` and `.docx`, stage them under `/Users/tfinklea/codex/.tmp/transcript-imports`, ingest the canonical Teams transcript into `codex transcripts`, and record permission or export blockers for meetings that cannot be imported.
---

# Teams Stream Transcript Import

Use Playwright MCP for every browser action and the bundled helper script for all local state, download claiming, ingestion, and final reporting.

## Prerequisites

1. Start from `/Users/tfinklea/codex`.
2. Use the Playwright MCP browser tools directly, not the Playwright shell wrapper skill.
3. Treat `/Users/tfinklea/codex/.tmp/transcript-imports` as the only staging area for raw downloads.
4. Never write raw files directly into `/Users/tfinklea/codex/transcripts`.

Set the helper path once:

```bash
export STREAM_IMPORTER="$HOME/.codex/skills/teams-stream-transcript-import/scripts/stream_meeting_import.py"
```

Only set a cutoff when the user explicitly wants a time-bounded pass. Do not assume that older meetings are already processed just because they are older or because a prior helper run marked them as cleared by cutoff.

## Run The Workflow

1. Start the local run state:

```bash
python3 "$STREAM_IMPORTER" start-run
```

2. If and only if the user explicitly wants a cutoff-bounded pass, apply the cutoff:

```bash
python3 "$STREAM_IMPORTER" apply-cutoff \
  --run-id "<run-id>" \
  --on-or-before YYYY-MM-DD
```

3. Open this URL in Playwright MCP:

```text
https://psolutions.sharepoint.com/_layouts/15/videohub.aspx?referrer=StreamWebApp&referrerScenario=StreamIcon%5C
```

4. If Microsoft sign-in or MFA appears:
   - pause
   - tell the user to finish the sign-in in the current browser session
   - resume from the page that loads after sign-in
5. Confirm the Stream or Clipchamp hub is loaded, then click the `Meetings` filter.
6. Collect meeting URLs plus any reliable visible metadata. Keep scrolling until two consecutive passes produce no new meeting URLs.
   - Treat the hub as a discovery surface only.
   - Do not treat the `Opened` column as the meeting date or as proof that a meeting is old, new, or already imported.
   - Do not treat the right-side `Activity` text such as `Mon`, `Thu`, `Yesterday`, or `Mar 11` as the meeting occurrence date. That text reflects sharing or chat activity, not when the meeting happened.
   - Rows with blank `Opened` values can still point to fresh, unseen meetings.
   - Repeated titles can represent different occurrences. Keep the URL list keyed by meeting URL, not by title alone.
7. Keep the hub open in its own tab for the entire run.
8. Process meetings from the collected URL list instead of relying on stale card refs after back-navigation.

## Process One Meeting

For each collected meeting URL:

1. Open the meeting page in a separate detail tab. Do not replace or navigate away from the hub tab.
2. Immediately silence the meeting tab before doing anything else. This is mandatory.
   - First run a Playwright code step that pauses every `video` and `audio` element and forces mute plus zero volume:

```javascript
async (page) => {
  const result = await page.evaluate(() => {
    const media = Array.from(document.querySelectorAll("video, audio"));
    return media.map((element, index) => {
      try {
        element.muted = true;
        element.volume = 0;
        element.pause();
      } catch (error) {
        return {
          index,
          tag: element.tagName,
          error: String(error),
        };
      }
      return {
        index,
        tag: element.tagName,
        muted: element.muted,
        volume: element.volume,
        paused: element.paused,
        currentTime: element.currentTime,
      };
    });
  });
  return { media: result };
}
```

   - Then, if player controls are visible, click the accessible `Mute` control when present and click the accessible `Pause` control when present.
   - If the control already reads `Unmute`, leave it alone because the player is already muted.
   - If the control reads `This video has no sound`, leave it alone and still pause playback if possible.
   - Do not continue until one of these is true:
     - the JS result shows every discovered media element is `paused: true` and either `muted: true` or `volume: 0`
     - the accessible player controls no longer expose a `Pause` action
   - If silence cannot be confirmed, stop and treat it as UI drift instead of continuing with transcript actions.
3. Capture exact metadata only when the detail page makes it reliable.
   - The detail page heading is the source of truth for the meeting title.
   - The concrete date shown on the detail page is the source of truth for `occurred_at`.
   - Use hub owner labels like `Taylor Finklea's Files` only for organizer or owner context, not for occurred date.
4. Ask the helper whether the meeting still needs work, using detail-page metadata rather than hub guesses:

```bash
python3 "$STREAM_IMPORTER" should-process \
  --run-id "<run-id>" \
  --meeting-url "<meeting-url>" \
  --title "Exact detail-page meeting title if reliable" \
  --occurred-at YYYY-MM-DD \
  --participants "Name 1, Name 2"
```

5. If `should_process` is `false`, inspect why before skipping.
   - Skip when the helper indicates the meeting already has a successful ingest result, duplicate result, or a prior explicit blocked result that the user does not want revisited.
   - Do not blindly skip a meeting just because an older helper run marked it as already run due to a cutoff. If the user asked for all unseen meetings, treat old cutoff-based marks as backlog bookkeeping, not proof of successful import.
6. Trigger transcript downloads:
   - download both `.vtt` and `.docx` when both are offered
   - if only one exists, continue with that one and let the helper record the missing format
   - if the transcript `Download` control is disabled or no export action is available, record the organizer or file owner contact for the blocked meeting
     - prefer the visible `Location: Name's Files` label when present
     - otherwise derive it from the SharePoint personal URL in the meeting page
   - if `.vtt` is offered but `claim-downloads` reports it missing, retry with `.docx` before concluding the export is unavailable
7. Immediately after triggering downloads, hand control to the helper:

```bash
python3 "$STREAM_IMPORTER" claim-downloads \
  --run-id "<run-id>" \
  --meeting-url "<meeting-url>" \
  --since-epoch "<unix-seconds-before-download-clicks>" \
  --downloads-dir "/Users/tfinklea/Downloads" \
  --staging-dir "/Users/tfinklea/codex/.tmp/transcript-imports" \
  --expect vtt \
  --expect docx
```

8. Ingest the canonical Teams transcript:

```bash
python3 "$STREAM_IMPORTER" ingest-meeting \
  --run-id "<run-id>" \
  --meeting-url "<meeting-url>" \
  --workspace "/Users/tfinklea/codex" \
  --title "Exact meeting title if reliable" \
  --occurred-at YYYY-MM-DD \
  --participants "Name 1, Name 2"
```

9. Close only the detail tab when that meeting is finished, then return to the hub tab for the next meeting.

## Canonical Ingest Rules

- Prefer `.vtt`.
- Use `.docx` only when `.vtt` is unavailable.
- If both exist but the pairing is unclear, ingest the `.vtt` and skip the `.docx`.
- Pass `--title`, `--occurred-at`, `--participants`, and `--tags` only when the UI exposes them reliably.
- Do not use hub row dates, `Opened` values, or right-side activity labels as substitutes for the detail page date.
- Treat a meeting as processed only after the helper records a successful ingest result, an explicit `duplicate_of` result, or an explicit blocked result.
- A prior cutoff mark from an older run is not the same thing as a successful import.

## Finish The Run

After all meetings are processed:

```bash
python3 "$STREAM_IMPORTER" finalize-run \
  --run-id "<run-id>" \
  --workspace "/Users/tfinklea/codex"
```

Use that output as the final user-facing summary.
It now includes a `Blocked meetings:` section with occurred date, meeting title, organizer or owner contact, and the blocked reason so the user knows who to contact for access.

## Failure Handling

- If the page layout drifts, save a screenshot under `output/playwright/teams-stream-transcript-import/` and stop with a precise error.
- If a download succeeds but ingest fails, report the exact staged file path and the CLI error from the helper output.
- If transcript export is blocked, include the organizer or owner contact in the user-facing report.
- Do not manually edit `state.sqlite3`; rerun the helper subcommands instead.

## Reference

Read `references/ui-notes.md` when:

- the Stream or Clipchamp UI labels differ from expectation
- you need selector guidance for the `Meetings` filter or transcript menus
- auth or lazy-loading behavior changes
