#!/usr/bin/env python3
from __future__ import annotations

import argparse
import hashlib
import json
import shutil
import sqlite3
import subprocess
import time
from datetime import datetime, timezone
from pathlib import Path
from typing import Any
from urllib.parse import parse_qsl, unquote, urlencode, urlsplit, urlunsplit

DEFAULT_STAGING_DIR = Path("/Users/tfinklea/codex/.tmp/transcript-imports")
DEFAULT_DOWNLOADS_DIR = Path("/Users/tfinklea/Downloads")
DEFAULT_WORKSPACE = Path("/Users/tfinklea/codex")
DEFAULT_SOURCE = "teams"
TEMP_DOWNLOAD_SUFFIXES = {".crdownload", ".download", ".tmp", ".part"}
TRACKING_QUERY_PARAMS = {
    "ref",
    "referrer",
    "referrerscenario",
    "trk",
    "trackingid",
    "tracking",
    "wt.mc_id",
}
SUCCESS_STATUSES = {"pending_index", "indexed"}


def utc_now() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat()


def compact_json(payload: Any) -> None:
    print(json.dumps(payload, indent=2, sort_keys=True))


def parse_csv(value: str | None) -> list[str]:
    if not value:
        return []
    return [item.strip() for item in value.split(",") if item.strip()]


def normalize_title(value: str | None) -> str:
    return " ".join((value or "").split()).strip()


def normalize_occurred_at(value: str | None) -> str:
    if not value:
        return ""
    return value.strip()


def cutoff_applies(occurred_at: str | None, cutoff: str | None) -> bool:
    normalized_occurred_at = normalize_occurred_at(occurred_at)
    normalized_cutoff = normalize_occurred_at(cutoff)
    if not normalized_occurred_at or not normalized_cutoff:
        return False
    return normalized_occurred_at <= normalized_cutoff


def normalize_participants(value: str | None) -> list[str]:
    deduped: list[str] = []
    seen: set[str] = set()
    for name in parse_csv(value):
        key = name.casefold()
        if key in seen:
            continue
        seen.add(key)
        deduped.append(name)
    return deduped


def is_tracking_param(key: str) -> bool:
    lowered = key.casefold()
    if lowered in TRACKING_QUERY_PARAMS:
        return True
    return lowered.startswith("utm_")


def canonicalize_url(value: str | None) -> str:
    raw = (value or "").strip()
    if not raw:
        return ""
    parts = urlsplit(raw)
    if not parts.scheme or not parts.netloc:
        return raw
    query_pairs = sorted(
        (key, item)
        for key, item in parse_qsl(parts.query, keep_blank_values=True)
        if not is_tracking_param(key)
    )
    path = parts.path or "/"
    if path != "/" and path.endswith("/"):
        path = path[:-1]
    return urlunsplit(
        (
            parts.scheme.lower(),
            parts.netloc.lower(),
            path,
            urlencode(query_pairs, doseq=True),
            "",
        )
    )


def format_person_slug(value: str) -> str:
    slug = value.strip()
    if slug.endswith("_therapynotes_com"):
        slug = slug[: -len("_therapynotes_com")]
    slug = slug.replace("_", " ").replace("-", " ")
    parts = [part for part in slug.split() if part]
    return " ".join(part.capitalize() for part in parts)


def infer_organizer_contact(meeting_url: str | None) -> str | None:
    canonical_url = canonicalize_url(meeting_url)
    if not canonical_url:
        return None
    decoded_url = unquote(canonical_url)
    lowered_url = decoded_url.casefold()
    marker = "/personal/"
    if marker not in lowered_url:
        return None
    start = lowered_url.index(marker) + len(marker)
    slug = decoded_url[start:].split("/", 1)[0].strip()
    if not slug:
        return None
    organizer = format_person_slug(slug)
    return organizer or None


def build_meeting_identity(meeting_url: str | None, title: str | None, occurred_at: str | None) -> tuple[str, str]:
    canonical_url = canonicalize_url(meeting_url)
    if canonical_url:
        source_value = canonical_url
    else:
        fallback = f"{normalize_title(title)}|{normalize_occurred_at(occurred_at)}"
        source_value = fallback
        canonical_url = fallback
    meeting_key = hashlib.sha256(source_value.encode("utf-8")).hexdigest()
    return canonical_url, meeting_key


def ensure_dir(path: Path) -> Path:
    path.mkdir(parents=True, exist_ok=True)
    return path


def state_db_path(staging_dir: Path) -> Path:
    return staging_dir / "state.sqlite3"


def run_manifest_path(staging_dir: Path, run_id: str) -> Path:
    return staging_dir / "runs" / f"{run_id}.json"


def summary_path(staging_dir: Path, run_id: str) -> Path:
    return staging_dir / "runs" / f"{run_id}-summary.txt"


def connect_db(staging_dir: Path) -> sqlite3.Connection:
    ensure_dir(staging_dir)
    ensure_dir(staging_dir / "runs")
    connection = sqlite3.connect(state_db_path(staging_dir))
    connection.row_factory = sqlite3.Row
    connection.executescript(
        """
        PRAGMA foreign_keys = ON;

        CREATE TABLE IF NOT EXISTS meetings (
            meeting_key TEXT PRIMARY KEY,
            canonical_url TEXT NOT NULL,
            title TEXT,
            occurred_at TEXT,
            participants_json TEXT NOT NULL DEFAULT '[]',
            first_seen_at TEXT NOT NULL,
            last_attempt_at TEXT,
            processed_at TEXT,
            state TEXT NOT NULL,
            transcript_id TEXT,
            duplicate_of TEXT,
            bundle_path TEXT,
            error_message TEXT
        );

        CREATE TABLE IF NOT EXISTS files (
            meeting_key TEXT NOT NULL,
            file_type TEXT NOT NULL,
            original_filename TEXT NOT NULL,
            staged_path TEXT NOT NULL,
            downloaded_at TEXT NOT NULL,
            selected_for_ingest INTEGER NOT NULL DEFAULT 0,
            skip_reason TEXT,
            ingest_json_path TEXT,
            PRIMARY KEY (meeting_key, staged_path),
            FOREIGN KEY (meeting_key) REFERENCES meetings(meeting_key) ON DELETE CASCADE
        );

        CREATE TABLE IF NOT EXISTS runs (
            run_id TEXT PRIMARY KEY,
            started_at TEXT NOT NULL,
            finished_at TEXT,
            summary_path TEXT
        );
        """
    )
    return connection


def row_to_dict(row: sqlite3.Row | None) -> dict[str, Any] | None:
    if row is None:
        return None
    payload = dict(row)
    if "participants_json" in payload:
        payload["participants"] = json.loads(payload.pop("participants_json") or "[]")
    if "selected_for_ingest" in payload:
        payload["selected_for_ingest"] = bool(payload["selected_for_ingest"])
    return payload


def load_run_manifest(staging_dir: Path, run_id: str) -> dict[str, Any]:
    path = run_manifest_path(staging_dir, run_id)
    if not path.exists():
        raise SystemExit(f"Run manifest not found: {path}")
    return json.loads(path.read_text(encoding="utf-8"))


def save_run_manifest(staging_dir: Path, run_id: str, payload: dict[str, Any]) -> None:
    path = run_manifest_path(staging_dir, run_id)
    path.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def update_run_manifest(staging_dir: Path, run_id: str, meeting_key: str | None = None, **changes: Any) -> dict[str, Any]:
    payload = load_run_manifest(staging_dir, run_id)
    if meeting_key is not None:
        meetings = payload.setdefault("meetings", {})
        meeting_entry = meetings.setdefault(meeting_key, {})
        for key, value in changes.items():
            if isinstance(value, dict) and isinstance(meeting_entry.get(key), dict):
                meeting_entry[key].update(value)
            else:
                meeting_entry[key] = value
        meeting_order = payload.setdefault("meeting_order", [])
        if meeting_key not in meeting_order:
            meeting_order.append(meeting_key)
    else:
        payload.update(changes)
    save_run_manifest(staging_dir, run_id, payload)
    return payload


def require_run(connection: sqlite3.Connection, run_id: str) -> None:
    row = connection.execute("SELECT run_id FROM runs WHERE run_id = ?", (run_id,)).fetchone()
    if row is None:
        raise SystemExit(f"Unknown run_id: {run_id}")


def upsert_meeting(
    connection: sqlite3.Connection,
    *,
    canonical_url: str,
    meeting_key: str,
    title: str | None,
    occurred_at: str | None,
    participants: list[str],
    state: str | None = None,
    error_message: str | None = None,
) -> dict[str, Any]:
    now = utc_now()
    title_value = normalize_title(title) or None
    occurred_at_value = normalize_occurred_at(occurred_at) or None
    participants_json = json.dumps(participants)
    existing = connection.execute(
        "SELECT * FROM meetings WHERE meeting_key = ?",
        (meeting_key,),
    ).fetchone()
    if existing is None:
        connection.execute(
            """
            INSERT INTO meetings (
                meeting_key, canonical_url, title, occurred_at, participants_json,
                first_seen_at, last_attempt_at, state, error_message
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            (
                meeting_key,
                canonical_url,
                title_value,
                occurred_at_value,
                participants_json,
                now,
                now,
                state or "discovered",
                error_message,
            ),
        )
    else:
        merged_title = title_value or existing["title"]
        merged_occurred_at = occurred_at_value or existing["occurred_at"]
        existing_participants = json.loads(existing["participants_json"] or "[]")
        merged_participants = participants or existing_participants
        merged_state = state or existing["state"]
        merged_error = error_message if error_message is not None else existing["error_message"]
        connection.execute(
            """
            UPDATE meetings
               SET canonical_url = ?,
                   title = ?,
                   occurred_at = ?,
                   participants_json = ?,
                   last_attempt_at = ?,
                   state = ?,
                   error_message = ?
             WHERE meeting_key = ?
            """,
            (
                canonical_url,
                merged_title,
                merged_occurred_at,
                json.dumps(merged_participants),
                now,
                merged_state,
                merged_error,
                meeting_key,
            ),
        )
    connection.commit()
    row = connection.execute(
        "SELECT * FROM meetings WHERE meeting_key = ?",
        (meeting_key,),
    ).fetchone()
    return row_to_dict(row) or {}


def mark_meeting_processed(
    connection: sqlite3.Connection,
    meeting_key: str,
    *,
    state: str,
    transcript_id: str | None,
    duplicate_of: str | None,
    bundle_path_value: str | None,
    error_message: str | None,
) -> dict[str, Any]:
    processed_at = utc_now() if state == "processed" else None
    connection.execute(
        """
        UPDATE meetings
           SET state = ?,
               processed_at = COALESCE(?, processed_at),
               transcript_id = ?,
               duplicate_of = ?,
               bundle_path = ?,
               error_message = ?
         WHERE meeting_key = ?
        """,
        (
            state,
            processed_at,
            transcript_id,
            duplicate_of,
            bundle_path_value,
            error_message,
            meeting_key,
        ),
    )
    connection.commit()
    row = connection.execute("SELECT * FROM meetings WHERE meeting_key = ?", (meeting_key,)).fetchone()
    return row_to_dict(row) or {}


def mark_meeting_as_run(
    connection: sqlite3.Connection,
    *,
    meeting_key: str,
    reason: str,
) -> dict[str, Any]:
    return mark_meeting_processed(
        connection,
        meeting_key,
        state="processed",
        transcript_id=None,
        duplicate_of=None,
        bundle_path_value=None,
        error_message=reason,
    )


def upsert_file(
    connection: sqlite3.Connection,
    *,
    meeting_key: str,
    file_type: str,
    original_filename: str,
    staged_path_value: str,
    downloaded_at: str,
) -> None:
    connection.execute(
        """
        INSERT INTO files (
            meeting_key, file_type, original_filename, staged_path, downloaded_at
        ) VALUES (?, ?, ?, ?, ?)
        ON CONFLICT(meeting_key, staged_path) DO UPDATE SET
            original_filename = excluded.original_filename,
            downloaded_at = excluded.downloaded_at
        """,
        (meeting_key, file_type, original_filename, staged_path_value, downloaded_at),
    )
    connection.commit()


def update_file_decision(
    connection: sqlite3.Connection,
    meeting_key: str,
    staged_path_value: str,
    *,
    selected_for_ingest: bool,
    skip_reason: str | None,
    ingest_json_path: str | None = None,
) -> None:
    connection.execute(
        """
        UPDATE files
           SET selected_for_ingest = ?,
               skip_reason = ?,
               ingest_json_path = COALESCE(?, ingest_json_path)
         WHERE meeting_key = ? AND staged_path = ?
        """,
        (1 if selected_for_ingest else 0, skip_reason, ingest_json_path, meeting_key, staged_path_value),
    )
    connection.commit()


def latest_file_by_extension(paths: list[Path]) -> Path:
    return sorted(paths, key=lambda item: (item.stat().st_mtime, item.name))[-1]


def move_destination(meeting_dir: Path, filename: str) -> Path:
    destination = meeting_dir / filename
    if not destination.exists():
        return destination
    collision_root = meeting_dir / "collisions"
    ensure_dir(collision_root)
    counter = 1
    while True:
        candidate = collision_root / str(counter) / filename
        if not candidate.exists():
            ensure_dir(candidate.parent)
            return candidate
        counter += 1


def wait_for_stable_file(path: Path, timeout_seconds: int = 30, poll_seconds: float = 1.0) -> bool:
    deadline = time.time() + timeout_seconds
    stable_checks = 0
    previous_size: int | None = None
    while time.time() < deadline:
        if not path.exists():
            time.sleep(poll_seconds)
            continue
        if path.suffix.casefold() in TEMP_DOWNLOAD_SUFFIXES:
            time.sleep(poll_seconds)
            continue
        current_size = path.stat().st_size
        if previous_size is not None and current_size == previous_size:
            stable_checks += 1
            if stable_checks >= 2:
                return True
        else:
            stable_checks = 0
        previous_size = current_size
        time.sleep(poll_seconds)
    return path.exists() and path.suffix.casefold() not in TEMP_DOWNLOAD_SUFFIXES


def build_blocked_reason(entry: dict[str, Any]) -> str:
    missing_formats = entry.get("missing_formats") or []
    if missing_formats:
        return f"transcript export unavailable or blocked ({', '.join(missing_formats)} missing)"
    return "transcript export unavailable or blocked"


def build_summary_text(
    summary_rows: list[dict[str, Any]],
    skipped_rows: list[dict[str, Any]],
    blocked_rows: list[dict[str, Any]],
    reindex: dict[str, Any],
) -> str:
    lines = ["Imported files:"]
    if summary_rows:
        for item in summary_rows:
            lines.append(
                " | ".join(
                    [
                        item.get("filename", "-"),
                        item.get("source", DEFAULT_SOURCE),
                        item.get("transcript_id", "-"),
                        item.get("status", "-"),
                        item.get("duplicate_of") or "-",
                        item.get("bundle_path") or "-",
                    ]
                )
            )
    else:
        lines.append("(none)")
    lines.append("")
    lines.append("Blocked meetings:")
    if blocked_rows:
        for item in blocked_rows:
            lines.append(
                " | ".join(
                    [
                        item.get("occurred_at") or "-",
                        item.get("title") or "-",
                        item.get("organizer") or "-",
                        item.get("reason") or "transcript export unavailable or blocked",
                    ]
                )
            )
    else:
        lines.append("(none)")
    lines.append("")
    lines.append("Skipped files:")
    if skipped_rows:
        for item in skipped_rows:
            lines.append(f"{item.get('filename', '-')} skipped because {item.get('reason', 'no reason recorded')}")
    else:
        lines.append("(none)")
    lines.append("")
    lines.append("Reindex:")
    if reindex.get("ok", True):
        lines.extend(reindex.get("lines") or ["(no output)"])
    else:
        lines.append(reindex.get("error", "reindex failed"))
    return "\n".join(lines) + "\n"


def find_staged_files(meeting_dir: Path) -> dict[str, list[Path]]:
    files: dict[str, list[Path]] = {"vtt": [], "docx": []}
    if not meeting_dir.exists():
        return files
    for path in meeting_dir.rglob("*"):
        if not path.is_file():
            continue
        suffix = path.suffix.casefold().lstrip(".")
        if suffix in files:
            files[suffix].append(path)
    return files


def select_canonical_file(files: dict[str, list[Path]]) -> tuple[Path | None, list[tuple[Path, str]]]:
    skipped: list[tuple[Path, str]] = []
    vtts = files["vtt"]
    docxs = files["docx"]
    selected: Path | None = None
    if vtts:
        selected = latest_file_by_extension(vtts)
        for path in vtts:
            if path != selected:
                skipped.append((path, f"newer {selected.name} was chosen for ingest"))
        for path in docxs:
            skipped.append((path, f"matching {selected.name} was ingested"))
        return selected, skipped
    if docxs:
        selected = latest_file_by_extension(docxs)
        for path in docxs:
            if path != selected:
                skipped.append((path, f"newer {selected.name} was chosen for ingest"))
        return selected, skipped
    return None, skipped


def build_ingest_command(
    *,
    workspace: Path,
    transcript_path: Path,
    title: str | None,
    occurred_at: str | None,
    participants: list[str],
    tags: list[str],
) -> list[str]:
    command = [
        "uv",
        "run",
        "codex",
        "--workspace",
        str(workspace),
        "transcripts",
        "ingest",
        str(transcript_path),
        "--source",
        DEFAULT_SOURCE,
    ]
    normalized_title = normalize_title(title)
    normalized_occurred_at = normalize_occurred_at(occurred_at)
    if normalized_title:
        command.extend(["--title", normalized_title])
    if normalized_occurred_at:
        command.extend(["--occurred-at", normalized_occurred_at])
    if participants:
        command.extend(["--participants", ", ".join(participants)])
    if tags:
        command.extend(["--tags", ", ".join(tags)])
    return command


def build_module_ingest_command(
    *,
    workspace: Path,
    transcript_path: Path,
    title: str | None,
    occurred_at: str | None,
    participants: list[str],
    tags: list[str],
) -> list[str]:
    command = [
        "uv",
        "run",
        "python",
        "-m",
        "codex.cli",
        "--workspace",
        str(workspace),
        "transcripts",
        "ingest",
        str(transcript_path),
        "--source",
        DEFAULT_SOURCE,
    ]
    normalized_title = normalize_title(title)
    normalized_occurred_at = normalize_occurred_at(occurred_at)
    if normalized_title:
        command.extend(["--title", normalized_title])
    if normalized_occurred_at:
        command.extend(["--occurred-at", normalized_occurred_at])
    if participants:
        command.extend(["--participants", ", ".join(participants)])
    if tags:
        command.extend(["--tags", ", ".join(tags)])
    return command


def build_reindex_command(*, workspace: Path) -> list[str]:
    return [
        "uv",
        "run",
        "codex",
        "--workspace",
        str(workspace),
        "transcripts",
        "reindex",
        "--pending",
    ]


def build_module_reindex_command(*, workspace: Path) -> list[str]:
    return [
        "uv",
        "run",
        "python",
        "-m",
        "codex.cli",
        "--workspace",
        str(workspace),
        "transcripts",
        "reindex",
        "--pending",
    ]


def should_retry_with_module_entrypoint(stdout: str, stderr: str) -> bool:
    combined = "\n".join(part for part in [stdout, stderr] if part)
    return "ModuleNotFoundError: No module named 'codex.app'" in combined


def run_codex_command(command: list[str], fallback_command: list[str]) -> tuple[subprocess.CompletedProcess[str], list[str]]:
    completed = subprocess.run(command, capture_output=True, text=True)
    if completed.returncode == 0 or not should_retry_with_module_entrypoint(completed.stdout.strip(), completed.stderr.strip()):
        return completed, command
    fallback_completed = subprocess.run(fallback_command, capture_output=True, text=True)
    return fallback_completed, fallback_command


def command_start_run(args: argparse.Namespace) -> int:
    staging_dir = Path(args.staging_dir).resolve()
    connection = connect_db(staging_dir)
    run_id = f"run-{int(time.time() * 1000)}"
    started_at = utc_now()
    connection.execute(
        "INSERT INTO runs(run_id, started_at, finished_at, summary_path) VALUES (?, ?, NULL, NULL)",
        (run_id, started_at),
    )
    connection.commit()
    manifest = {
        "run_id": run_id,
        "source": DEFAULT_SOURCE,
        "started_at": started_at,
        "finished_at": None,
        "meeting_order": [],
        "meetings": {},
        "reindex": None,
        "summary_path": None,
    }
    save_run_manifest(staging_dir, run_id, manifest)
    compact_json({"run_id": run_id})
    return 0


def command_should_process(args: argparse.Namespace) -> int:
    staging_dir = Path(args.staging_dir).resolve()
    connection = connect_db(staging_dir)
    require_run(connection, args.run_id)
    participants = normalize_participants(args.participants)
    canonical_url, meeting_key = build_meeting_identity(args.meeting_url, args.title, args.occurred_at)
    organizer = infer_organizer_contact(canonical_url)
    meeting = upsert_meeting(
        connection,
        canonical_url=canonical_url,
        meeting_key=meeting_key,
        title=args.title,
        occurred_at=args.occurred_at,
        participants=participants,
    )
    mark_reason = None
    if cutoff_applies(meeting.get("occurred_at"), args.skip_on_or_before):
        mark_reason = (
            f"Marked as already run because occurred_at {meeting.get('occurred_at')} "
            f"is on or before cutoff {normalize_occurred_at(args.skip_on_or_before)}."
        )
        meeting = mark_meeting_as_run(connection, meeting_key=meeting_key, reason=mark_reason)
    should_process = meeting["state"] != "processed"
    update_run_manifest(
        staging_dir,
        args.run_id,
        meeting_key,
        source=DEFAULT_SOURCE,
        canonical_url=canonical_url,
        title=meeting.get("title"),
        occurred_at=meeting.get("occurred_at"),
        participants=meeting.get("participants", []),
        organizer=organizer,
        state=meeting.get("state"),
        should_process=should_process,
        marked_as_run=bool(mark_reason),
        mark_reason=mark_reason,
    )
    compact_json(
        {
            "meeting_key": meeting_key,
            "canonical_url": canonical_url,
            "organizer": organizer,
            "should_process": should_process,
            "marked_as_run": bool(mark_reason),
            "mark_reason": mark_reason,
            "meeting": meeting,
        }
    )
    return 0


def command_apply_cutoff(args: argparse.Namespace) -> int:
    staging_dir = Path(args.staging_dir).resolve()
    connection = connect_db(staging_dir)
    require_run(connection, args.run_id)
    cutoff = normalize_occurred_at(args.on_or_before)
    if not cutoff:
        raise SystemExit("--on-or-before must not be empty")

    rows = connection.execute(
        """
        SELECT * FROM meetings
         WHERE state != 'processed'
           AND occurred_at IS NOT NULL
           AND occurred_at <= ?
         ORDER BY occurred_at DESC, title
        """,
        (cutoff,),
    ).fetchall()

    marked_rows: list[dict[str, Any]] = []
    for row in rows:
        meeting = row_to_dict(row) or {}
        meeting_key = str(meeting.get("meeting_key") or "")
        if not meeting_key:
            continue
        reason = f"Marked as already run because occurred_at {meeting.get('occurred_at')} is on or before cutoff {cutoff}."
        updated = mark_meeting_as_run(connection, meeting_key=meeting_key, reason=reason)
        organizer = infer_organizer_contact(updated.get("canonical_url"))
        update_run_manifest(
            staging_dir,
            args.run_id,
            meeting_key,
            source=DEFAULT_SOURCE,
            canonical_url=updated.get("canonical_url"),
            title=updated.get("title"),
            occurred_at=updated.get("occurred_at"),
            participants=updated.get("participants", []),
            organizer=organizer,
            state=updated.get("state"),
            should_process=False,
            marked_as_run=True,
            mark_reason=reason,
        )
        marked_rows.append(
            {
                "meeting_key": meeting_key,
                "title": updated.get("title"),
                "occurred_at": updated.get("occurred_at"),
                "organizer": organizer,
                "reason": reason,
            }
        )

    compact_json(
        {
            "cutoff": cutoff,
            "marked_count": len(marked_rows),
            "marked_meetings": marked_rows,
        }
    )
    return 0


def command_record_blocked(args: argparse.Namespace) -> int:
    staging_dir = Path(args.staging_dir).resolve()
    connection = connect_db(staging_dir)
    require_run(connection, args.run_id)
    participants = normalize_participants(args.participants)
    canonical_url, meeting_key = build_meeting_identity(args.meeting_url, args.title, args.occurred_at)
    organizer = normalize_title(args.organizer) or infer_organizer_contact(canonical_url)
    blocked_reason = normalize_title(args.reason) or "transcript export unavailable or blocked"
    blocked_kind = normalize_title(args.blocked_kind) or "permissions"
    blocked_at = utc_now()
    meeting = upsert_meeting(
        connection,
        canonical_url=canonical_url,
        meeting_key=meeting_key,
        title=args.title,
        occurred_at=args.occurred_at,
        participants=participants,
        state="blocked",
        error_message=blocked_reason,
    )
    update_run_manifest(
        staging_dir,
        args.run_id,
        meeting_key,
        source=DEFAULT_SOURCE,
        canonical_url=canonical_url,
        title=meeting.get("title"),
        occurred_at=meeting.get("occurred_at"),
        participants=meeting.get("participants", []),
        organizer=organizer,
        state="blocked",
        blocked_kind=blocked_kind,
        blocked_reason=blocked_reason,
        blocked_at=blocked_at,
    )
    compact_json(
        {
            "meeting_key": meeting_key,
            "canonical_url": canonical_url,
            "organizer": organizer,
            "blocked_kind": blocked_kind,
            "blocked_reason": blocked_reason,
            "blocked_at": blocked_at,
            "state": "blocked",
        }
    )
    return 0


def command_claim_downloads(args: argparse.Namespace) -> int:
    staging_dir = Path(args.staging_dir).resolve()
    downloads_dir = Path(args.downloads_dir).resolve()
    connection = connect_db(staging_dir)
    require_run(connection, args.run_id)
    canonical_url, meeting_key = build_meeting_identity(args.meeting_url, None, None)
    organizer = infer_organizer_contact(canonical_url)
    meeting = upsert_meeting(
        connection,
        canonical_url=canonical_url,
        meeting_key=meeting_key,
        title=None,
        occurred_at=None,
        participants=[],
    )
    meeting_dir = ensure_dir(staging_dir / meeting_key)
    expected = {item.lower().lstrip(".") for item in (args.expect or [])}
    candidates: list[Path] = []
    for path in downloads_dir.iterdir():
        if not path.is_file():
            continue
        suffix = path.suffix.casefold().lstrip(".")
        if suffix not in expected:
            continue
        if path.suffix.casefold() in TEMP_DOWNLOAD_SUFFIXES:
            continue
        if path.stat().st_mtime < args.since_epoch:
            continue
        candidates.append(path)
    candidates.sort(key=lambda item: (item.stat().st_mtime, item.name))
    moved: list[dict[str, Any]] = []
    ignored: list[str] = []
    found_extensions: set[str] = set()
    for candidate in candidates:
        suffix = candidate.suffix.casefold().lstrip(".")
        if not wait_for_stable_file(candidate):
            ignored.append(f"{candidate.name} was not stable before timeout")
            continue
        destination = move_destination(meeting_dir, candidate.name)
        shutil.move(str(candidate), str(destination))
        downloaded_at = utc_now()
        upsert_file(
            connection,
            meeting_key=meeting_key,
            file_type=suffix,
            original_filename=candidate.name,
            staged_path_value=str(destination),
            downloaded_at=downloaded_at,
        )
        found_extensions.add(suffix)
        moved.append(
            {
                "filename": candidate.name,
                "file_type": suffix,
                "staged_path": str(destination),
            }
        )
    missing = sorted(expected - found_extensions)
    meeting_state = "downloaded" if not missing and moved else "downloads_missing"
    blocked_reason = None if meeting_state != "downloads_missing" else build_blocked_reason({"missing_formats": missing})
    blocked_kind = None if meeting_state != "downloads_missing" else "missing_downloads"
    blocked_at = utc_now() if meeting_state == "downloads_missing" else None
    meeting = upsert_meeting(
        connection,
        canonical_url=canonical_url,
        meeting_key=meeting_key,
        title=meeting.get("title"),
        occurred_at=meeting.get("occurred_at"),
        participants=meeting.get("participants", []),
        state=meeting_state,
        error_message=blocked_reason,
    )
    update_run_manifest(
        staging_dir,
        args.run_id,
        meeting_key,
        source=DEFAULT_SOURCE,
        canonical_url=canonical_url,
        organizer=organizer,
        state=meeting_state,
        downloaded_files=moved,
        missing_formats=missing,
        claim_ignored=ignored,
        blocked_kind=blocked_kind,
        blocked_reason=blocked_reason,
        blocked_at=blocked_at,
        title=meeting.get("title"),
        occurred_at=meeting.get("occurred_at"),
    )
    compact_json(
        {
            "meeting_key": meeting_key,
            "organizer": organizer,
            "moved": moved,
            "missing_formats": missing,
            "ignored": ignored,
            "blocked_kind": blocked_kind,
            "blocked_reason": blocked_reason,
            "blocked_at": blocked_at,
            "state": meeting_state,
        }
    )
    return 0


def command_ingest_meeting(args: argparse.Namespace) -> int:
    staging_dir = Path(args.staging_dir).resolve()
    workspace = Path(args.workspace).resolve()
    connection = connect_db(staging_dir)
    require_run(connection, args.run_id)
    canonical_url, meeting_key = build_meeting_identity(args.meeting_url, args.title, args.occurred_at)
    participants = normalize_participants(args.participants)
    tags = parse_csv(args.tags)
    meeting = upsert_meeting(
        connection,
        canonical_url=canonical_url,
        meeting_key=meeting_key,
        title=args.title,
        occurred_at=args.occurred_at,
        participants=participants,
    )
    meeting_dir = staging_dir / meeting_key
    staged_files = find_staged_files(meeting_dir)
    selected_file, skipped = select_canonical_file(staged_files)
    if selected_file is None:
        meeting = mark_meeting_processed(
            connection,
            meeting_key,
            state="ingest_failed",
            transcript_id=None,
            duplicate_of=None,
            bundle_path_value=None,
            error_message="No staged .vtt or .docx files found for meeting.",
        )
        update_run_manifest(
            staging_dir,
            args.run_id,
            meeting_key,
            state="ingest_failed",
            error="No staged .vtt or .docx files found for meeting.",
        )
        compact_json(
            {
                "meeting_key": meeting_key,
                "error": "No staged .vtt or .docx files found for meeting.",
            }
        )
        return 1

    for skipped_path, reason in skipped:
        update_file_decision(
            connection,
            meeting_key,
            str(skipped_path),
            selected_for_ingest=False,
            skip_reason=reason,
        )

    ingest_command = build_ingest_command(
        workspace=workspace,
        transcript_path=selected_file,
        title=meeting.get("title"),
        occurred_at=meeting.get("occurred_at"),
        participants=meeting.get("participants", []),
        tags=tags,
    )
    fallback_ingest_command = build_module_ingest_command(
        workspace=workspace,
        transcript_path=selected_file,
        title=meeting.get("title"),
        occurred_at=meeting.get("occurred_at"),
        participants=meeting.get("participants", []),
        tags=tags,
    )
    completed, executed_ingest_command = run_codex_command(ingest_command, fallback_ingest_command)
    stdout = completed.stdout.strip()
    stderr = completed.stderr.strip()
    if completed.returncode != 0:
        error_message = stderr or stdout or f"ingest command failed with exit code {completed.returncode}"
        meeting = mark_meeting_processed(
            connection,
            meeting_key,
            state="ingest_failed",
            transcript_id=None,
            duplicate_of=None,
            bundle_path_value=None,
            error_message=error_message,
        )
        update_file_decision(
            connection,
            meeting_key,
            str(selected_file),
            selected_for_ingest=True,
            skip_reason=None,
        )
        update_run_manifest(
            staging_dir,
            args.run_id,
            meeting_key,
            state="ingest_failed",
            selected_file=str(selected_file),
            ingest_error={
                "file_path": str(selected_file),
                "command": executed_ingest_command,
                "stdout": stdout,
                "stderr": stderr,
                "error": error_message,
            },
            skipped_files=[{"filename": path.name, "reason": reason} for path, reason in skipped],
        )
        compact_json(
            {
                "meeting_key": meeting_key,
                "file_path": str(selected_file),
                "error": error_message,
                "stdout": stdout,
                "stderr": stderr,
            }
        )
        return 1

    try:
        ingest_payload = json.loads(stdout)
    except json.JSONDecodeError as exc:
        error_message = f"Failed to parse ingest JSON output: {exc}"
        meeting = mark_meeting_processed(
            connection,
            meeting_key,
            state="ingest_failed",
            transcript_id=None,
            duplicate_of=None,
            bundle_path_value=None,
            error_message=error_message,
        )
        update_run_manifest(
            staging_dir,
            args.run_id,
            meeting_key,
            state="ingest_failed",
            selected_file=str(selected_file),
            ingest_error={
                "file_path": str(selected_file),
                "command": executed_ingest_command,
                "stdout": stdout,
                "stderr": stderr,
                "error": error_message,
            },
        )
        compact_json(
            {
                "meeting_key": meeting_key,
                "file_path": str(selected_file),
                "error": error_message,
                "stdout": stdout,
            }
        )
        return 1

    ingest_json_path = meeting_dir / "ingest-result.json"
    ingest_json_path.write_text(json.dumps(ingest_payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    update_file_decision(
        connection,
        meeting_key,
        str(selected_file),
        selected_for_ingest=True,
        skip_reason=None,
        ingest_json_path=str(ingest_json_path),
    )

    status = ingest_payload.get("status")
    duplicate_of = ingest_payload.get("duplicate_of")
    is_success = bool(duplicate_of) or status in SUCCESS_STATUSES
    meeting_state = "processed" if is_success else "ingest_failed"
    error_message = None if is_success else f"Ingest returned non-success status: {status}"
    meeting = mark_meeting_processed(
        connection,
        meeting_key,
        state=meeting_state,
        transcript_id=ingest_payload.get("id"),
        duplicate_of=duplicate_of,
        bundle_path_value=ingest_payload.get("bundle_path"),
        error_message=error_message,
    )
    skipped_rows = [{"filename": path.name, "reason": reason} for path, reason in skipped]
    update_run_manifest(
        staging_dir,
        args.run_id,
        meeting_key,
        state=meeting_state,
        selected_file=str(selected_file),
        ingest_result=ingest_payload,
        skipped_files=skipped_rows,
    )
    compact_json(
        {
            "meeting_key": meeting_key,
            "selected_file": str(selected_file),
            "ingest_result": ingest_payload,
            "skipped_files": skipped_rows,
        }
    )
    return 0 if is_success else 1


def command_finalize_run(args: argparse.Namespace) -> int:
    staging_dir = Path(args.staging_dir).resolve()
    workspace = Path(args.workspace).resolve()
    connection = connect_db(staging_dir)
    require_run(connection, args.run_id)
    manifest = load_run_manifest(staging_dir, args.run_id)
    reindex_command = build_reindex_command(workspace=workspace)
    fallback_reindex_command = build_module_reindex_command(workspace=workspace)
    completed, executed_reindex_command = run_codex_command(reindex_command, fallback_reindex_command)
    reindex_payload: dict[str, Any]
    if completed.returncode == 0:
        reindex_payload = {
            "ok": True,
            "command": executed_reindex_command,
            "lines": [line for line in completed.stdout.splitlines() if line.strip()],
        }
    else:
        reindex_payload = {
            "ok": False,
            "command": executed_reindex_command,
            "lines": [line for line in completed.stdout.splitlines() if line.strip()],
            "error": completed.stderr.strip() or completed.stdout.strip() or "reindex failed",
        }

    summary_rows: list[dict[str, Any]] = []
    blocked_rows: list[dict[str, Any]] = []
    skipped_rows: list[dict[str, Any]] = []
    for meeting_key in manifest.get("meeting_order", []):
        entry = manifest.get("meetings", {}).get(meeting_key, {})
        result = entry.get("ingest_result")
        selected_file = entry.get("selected_file")
        if result and selected_file:
            summary_rows.append(
                {
                    "filename": Path(selected_file).name,
                    "source": DEFAULT_SOURCE,
                    "transcript_id": result.get("id", "-"),
                    "status": result.get("status", "-"),
                    "duplicate_of": result.get("duplicate_of"),
                    "bundle_path": result.get("bundle_path"),
                }
            )
        if (entry.get("state") in {"blocked", "downloads_missing"} or entry.get("blocked_reason") or entry.get("blocked_kind")) and not result:
            blocked_rows.append(
                {
                    "occurred_at": entry.get("occurred_at"),
                    "title": entry.get("title"),
                    "organizer": entry.get("organizer") or infer_organizer_contact(entry.get("canonical_url")),
                    "reason": entry.get("blocked_reason") or build_blocked_reason(entry),
                }
            )
        for item in entry.get("skipped_files", []):
            skipped_rows.append(item)

    summary_text = build_summary_text(summary_rows, skipped_rows, blocked_rows, reindex_payload)
    final_summary_path = summary_path(staging_dir, args.run_id)
    final_summary_path.write_text(summary_text, encoding="utf-8")
    finished_at = utc_now()
    connection.execute(
        "UPDATE runs SET finished_at = ?, summary_path = ? WHERE run_id = ?",
        (finished_at, str(final_summary_path), args.run_id),
    )
    connection.commit()
    manifest["finished_at"] = finished_at
    manifest["reindex"] = reindex_payload
    manifest["summary_path"] = str(final_summary_path)
    save_run_manifest(staging_dir, args.run_id, manifest)
    print(summary_text, end="")
    return 0 if reindex_payload.get("ok", True) else 1


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Track and ingest Teams meeting transcript exports.")
    subparsers = parser.add_subparsers(dest="command", required=True)

    start_parser = subparsers.add_parser("start-run")
    start_parser.add_argument("--staging-dir", default=str(DEFAULT_STAGING_DIR))
    start_parser.set_defaults(func=command_start_run)

    should_process_parser = subparsers.add_parser("should-process")
    should_process_parser.add_argument("--run-id", required=True)
    should_process_parser.add_argument("--meeting-url", required=True)
    should_process_parser.add_argument("--title")
    should_process_parser.add_argument("--occurred-at")
    should_process_parser.add_argument("--participants")
    should_process_parser.add_argument("--skip-on-or-before")
    should_process_parser.add_argument("--staging-dir", default=str(DEFAULT_STAGING_DIR))
    should_process_parser.set_defaults(func=command_should_process)

    apply_cutoff_parser = subparsers.add_parser("apply-cutoff")
    apply_cutoff_parser.add_argument("--run-id", required=True)
    apply_cutoff_parser.add_argument("--on-or-before", required=True)
    apply_cutoff_parser.add_argument("--staging-dir", default=str(DEFAULT_STAGING_DIR))
    apply_cutoff_parser.set_defaults(func=command_apply_cutoff)

    record_blocked_parser = subparsers.add_parser("record-blocked")
    record_blocked_parser.add_argument("--run-id", required=True)
    record_blocked_parser.add_argument("--meeting-url", required=True)
    record_blocked_parser.add_argument("--title")
    record_blocked_parser.add_argument("--occurred-at")
    record_blocked_parser.add_argument("--participants")
    record_blocked_parser.add_argument("--organizer")
    record_blocked_parser.add_argument("--reason", required=True)
    record_blocked_parser.add_argument("--blocked-kind", default="permissions")
    record_blocked_parser.add_argument("--staging-dir", default=str(DEFAULT_STAGING_DIR))
    record_blocked_parser.set_defaults(func=command_record_blocked)

    claim_parser = subparsers.add_parser("claim-downloads")
    claim_parser.add_argument("--run-id", required=True)
    claim_parser.add_argument("--meeting-url", required=True)
    claim_parser.add_argument("--since-epoch", required=True, type=float)
    claim_parser.add_argument("--downloads-dir", default=str(DEFAULT_DOWNLOADS_DIR))
    claim_parser.add_argument("--staging-dir", default=str(DEFAULT_STAGING_DIR))
    claim_parser.add_argument("--expect", action="append", default=[])
    claim_parser.set_defaults(func=command_claim_downloads)

    ingest_parser = subparsers.add_parser("ingest-meeting")
    ingest_parser.add_argument("--run-id", required=True)
    ingest_parser.add_argument("--meeting-url", required=True)
    ingest_parser.add_argument("--workspace", default=str(DEFAULT_WORKSPACE))
    ingest_parser.add_argument("--title")
    ingest_parser.add_argument("--occurred-at")
    ingest_parser.add_argument("--participants")
    ingest_parser.add_argument("--tags")
    ingest_parser.add_argument("--staging-dir", default=str(DEFAULT_STAGING_DIR))
    ingest_parser.set_defaults(func=command_ingest_meeting)

    finalize_parser = subparsers.add_parser("finalize-run")
    finalize_parser.add_argument("--run-id", required=True)
    finalize_parser.add_argument("--workspace", default=str(DEFAULT_WORKSPACE))
    finalize_parser.add_argument("--staging-dir", default=str(DEFAULT_STAGING_DIR))
    finalize_parser.set_defaults(func=command_finalize_run)

    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    return args.func(args)


if __name__ == "__main__":
    raise SystemExit(main())
