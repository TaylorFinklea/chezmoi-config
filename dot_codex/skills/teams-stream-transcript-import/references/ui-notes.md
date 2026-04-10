# UI Notes

Use this file only when the Stream or Clipchamp UI does not match the main workflow.

## Entry Behavior

- The SharePoint `videohub.aspx` URL can redirect to Microsoft sign-in before the Stream hub appears.
- A cached account picker may appear first, but password entry or MFA can still follow.
- Do not assume silent SSO. Pause for manual completion if auth is required.

## Hub Confirmation

Look for evidence that the video hub loaded before proceeding:

- Stream or Clipchamp branding
- a filter bar or tabs that include `Meetings`
- a grid or list of meeting recordings

If those elements are absent, snapshot the page again before concluding the UI drifted.

## Meetings Filter Strategy

- Prefer clicking a visible `Meetings` button, tab, or chip by accessible name.
- If multiple `Meetings` labels exist, choose the one associated with content filtering rather than page navigation.
- After the filter applies, re-snapshot the page before collecting refs or links.

## Discovery Strategy

- Extract meeting URLs and visible labels into a local list.
- Scroll the recordings container or page body until no new URLs appear in two consecutive passes.
- Keep the hub open in a dedicated tab and open each meeting in a separate detail tab.
- Close only the detail tab after each meeting. Do not close the hub tab during the run.
- Do not depend on previously captured element refs after navigation back from a meeting detail page.
- Do not trust the hub `Opened` column as the meeting occurrence date.
- Do not trust the right-side `Activity` text as the meeting occurrence date. Labels like `Mon`, `Thu`, `Yesterday`, and `Mar 11` reflect share or chat activity.
- Rows with blank `Opened` values can still point to fresh, unseen meetings.
- Repeated titles often represent separate meeting occurrences. Deduplicate by URL, not by title alone.
- The detail page date is the source of truth for `occurred_at`.
- Use a cutoff only when the user explicitly wants a time-bounded pass. A historical cutoff mark in an older run is backlog bookkeeping, not proof that the meeting was imported.

## Playback Control

- Many meeting pages start playing immediately after the detail tab loads.
- As soon as the meeting tab opens, run a JS-level mute and pause pass before collecting metadata or opening transcript menus.
- Do not rely on the visible player controls alone. Use both layers:
  - first force `muted = true`, `volume = 0`, and `pause()` on every `video` and `audio` element
  - then use visible controls to confirm the player state when those controls are available
- Prefer this exact Playwright code step:

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

- After the JS pass:
  - click `Mute` if that control is visible
  - click `Pause` if that control is visible
  - if the control already reads `Unmute`, treat the player as muted
  - if the control reads `This video has no sound`, do not treat that as a failure
- Do not proceed unless:
  - every discovered media element reports paused and muted or zero-volume, or
  - the visible player controls no longer show `Pause`
- If playback silence cannot be confirmed, stop and report UI drift instead of guessing.

## Transcript Download Variants

Expect the download action to appear under one of these patterns:

- a primary `Download` button
- an overflow menu such as `More`, `More actions`, or `...`
- a transcript panel with export actions

Common label variations:

- `Download transcript`
- `Download as .vtt`
- `Download as .docx`
- `Download file`

Always capture the time immediately before triggering downloads and pass that timestamp to `claim-downloads`.

If `Download as .vtt` is offered but `claim-downloads` reports that the `.vtt` file never appeared, retry `Download as .docx` before treating the meeting as blocked. Some pages expose the menu item but fail to deliver the `.vtt` export.

## Metadata Reliability

Only pass metadata to the helper when the UI is explicit:

- title visible as the page heading or clearly associated card title
- occurred date visible on the detail page as a concrete date, not hub-relative time
- participants visible as attendee names, not partial avatars or collapsed counts

If metadata is weak, omit it and let the ingest pipeline infer it.

## Organizer Contact

- When transcript export is blocked, capture the organizer or owner contact so the final summary tells the user who to reach out to.
- Prefer the visible location label on the hub row, such as `Location: Cassidy Palmer's Files`.
- If that label is not available, derive the contact from the meeting URL when it uses a SharePoint personal site path like `/personal/cassidy_palmer_therapynotes_com/`.
- The helper can derive this automatically from the meeting URL, but the browser workflow should still preserve the visible owner label when it is obvious.

## Drift Response

- Save a screenshot under `output/playwright/teams-stream-transcript-import/`.
- Include the current page URL, the missing expected element, and the last successful action in the error.
- Stop instead of guessing through a changed download flow.
