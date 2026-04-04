#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import shutil
import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
if str(SCRIPT_DIR) not in sys.path:
    sys.path.insert(0, str(SCRIPT_DIR))

from create_template import create_template
from workbook_schema import DEFAULT_TEMPLATE_PATH, DEFAULT_WORKBOOK_DIR, DEFAULT_WORKBOOK_PATH


def copy_artifact(source: Path, destination: Path) -> None:
    if destination.exists():
        if destination.is_dir():
            shutil.rmtree(destination)
        else:
            destination.unlink()
    if source.is_dir():
        shutil.copytree(source, destination)
    else:
        shutil.copy2(source, destination)


def bootstrap_workbook(
    workbook_path: Path = DEFAULT_WORKBOOK_PATH,
    template_path: Path = DEFAULT_TEMPLATE_PATH,
    force: bool = False,
) -> dict[str, object]:
    workbook_path.parent.mkdir(parents=True, exist_ok=True)

    if not template_path.exists():
        create_template(template_path, force=True)

    if workbook_path.exists() and not force:
        return {
            "status": "exists",
            "workbook_path": str(workbook_path),
            "template_path": str(template_path),
        }

    copy_artifact(template_path, workbook_path)
    return {
        "status": "created",
        "workbook_path": str(workbook_path),
        "template_path": str(template_path),
    }


def main() -> None:
    parser = argparse.ArgumentParser(description="Ensure the weekly meal planner workbook exists.")
    parser.add_argument("--workbook", type=Path, default=DEFAULT_WORKBOOK_PATH)
    parser.add_argument("--template", type=Path, default=DEFAULT_TEMPLATE_PATH)
    parser.add_argument("--force", action="store_true")
    args = parser.parse_args()

    result = bootstrap_workbook(args.workbook, args.template, args.force)
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
