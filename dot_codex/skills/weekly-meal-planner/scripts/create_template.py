#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
if str(SCRIPT_DIR) not in sys.path:
    sys.path.insert(0, str(SCRIPT_DIR))

from workbook_schema import DEFAULT_TEMPLATE_PATH, TABLE_SPECS, column_format, default_rows


def applescript_literal(value: object) -> str:
    if value is None:
        return '""'
    if isinstance(value, bool):
        return "true" if value else "false"
    if isinstance(value, (int, float)):
        return str(value)
    text = str(value).replace("\\", "\\\\").replace('"', '\\"')
    return f'"{text}"'


def cell_literal(table_name: str, column_name: str, value: object) -> str:
    if column_format(table_name, column_name) == "number" and isinstance(value, (int, float)):
        return str(value)
    if isinstance(value, bool):
        return applescript_literal(str(value).lower())
    return applescript_literal(value)


def remove_existing(path: Path) -> None:
    if not path.exists():
        return
    if path.is_dir():
        shutil.rmtree(path)
    else:
        path.unlink()


def grouped_specs() -> dict[str, list[tuple[str, object]]]:
    grouped: dict[str, list[tuple[str, object]]] = {}
    for name, spec in TABLE_SPECS.items():
        grouped.setdefault(spec.sheet, []).append((name, spec))
    return grouped


def build_table_commands(table_name: str, table_var: str) -> list[str]:
    spec = TABLE_SPECS[table_name]
    rows = default_rows(table_name)
    materialized_rows: list[dict[str, object]] = [
        {column: row.get(column, "") for column in spec.columns} for row in rows
    ]
    row_count = max(2, len(materialized_rows) + 1)

    commands = [
        f"set name of {table_var} to {applescript_literal(spec.table)}",
        f"tell {table_var}",
        f"set row count to {row_count}",
        f"set column count to {len(spec.columns)}",
        f"set header row count to {spec.header_rows}",
        "end tell",
        f"set position of {table_var} to {{{spec.position[0]}, {spec.position[1]}}}",
    ]

    for column_index, column_name in enumerate(spec.columns, start=1):
        commands.append(
            f"tell {table_var} to tell column {column_index} to set format to {column_format(table_name, column_name)}"
        )
        commands.append(
            f"tell {table_var} to tell cell {column_index} of row 1 to set value to {applescript_literal(column_name)}"
        )

    if materialized_rows:
        for row_index, row in enumerate(materialized_rows, start=2):
            for column_index, column_name in enumerate(spec.columns, start=1):
                commands.append(
                    "tell "
                    + table_var
                    + f" to tell cell {column_index} of row {row_index} to set value to "
                    + cell_literal(table_name, column_name, row.get(column_name, ""))
                )
    else:
        for column_index in range(1, len(spec.columns) + 1):
            commands.append(
                f'tell {table_var} to tell cell {column_index} of row 2 to set value to ""'
            )

    return commands


def build_applescript(output_path: Path) -> str:
    grouped = grouped_specs()
    sheet_names = list(grouped)
    first_sheet_name = sheet_names[0]
    first_sheet_tables = grouped[first_sheet_name]

    lines = [
        'set outputPath to system attribute "OUTPUT_PATH"',
        'tell application "Numbers"',
        "activate",
        'set docRef to make new document with properties {document template:template "Blank"}',
        "tell docRef",
        f"set name of active sheet to {applescript_literal(first_sheet_name)}",
        "set tableRef to first table of active sheet",
    ]
    lines.extend(build_table_commands(first_sheet_tables[0][0], "tableRef"))

    for table_name, _spec in first_sheet_tables[1:]:
        lines.append("tell active sheet")
        lines.append("set tableRef to make new table")
        lines.extend(build_table_commands(table_name, "tableRef"))
        lines.append("end tell")

    for sheet_name in sheet_names[1:]:
        lines.append(f"set sheetRef to make new sheet with properties {{name:{applescript_literal(sheet_name)}}}")
        for table_name, _spec in grouped[sheet_name]:
            lines.append("tell sheetRef")
            lines.append("set tableRef to make new table")
            lines.extend(build_table_commands(table_name, "tableRef"))
            lines.append("end tell")

    lines.extend(
        [
            "save in POSIX file outputPath",
            "close saving yes",
            "end tell",
            "end tell",
        ]
    )
    return "\n".join(lines)


def create_template(output_path: Path, force: bool = False) -> Path:
    output_path.parent.mkdir(parents=True, exist_ok=True)
    if output_path.exists():
        if not force:
            return output_path
        remove_existing(output_path)

    script = build_applescript(output_path)
    env = dict(os.environ)
    env["OUTPUT_PATH"] = str(output_path)
    completed = subprocess.run(
        ["osascript"],
        input=script,
        text=True,
        capture_output=True,
        env=env,
        check=False,
    )
    if completed.returncode != 0:
        raise RuntimeError(completed.stderr.strip() or "Failed to create Numbers template")
    return output_path


def main() -> None:
    parser = argparse.ArgumentParser(description="Create the weekly meal planner Numbers template.")
    parser.add_argument("--output", type=Path, default=DEFAULT_TEMPLATE_PATH)
    parser.add_argument("--force", action="store_true")
    args = parser.parse_args()

    created_path = create_template(args.output, force=args.force)
    print(json.dumps({"template_path": str(created_path), "created": True}, indent=2))


if __name__ == "__main__":
    main()
