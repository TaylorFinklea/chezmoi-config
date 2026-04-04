---
name: audit-backlog
description: Scan codebase for tech debt and populate the roadmap's Backlog section with Haiku and Sonnet tier items. Run in background with model override for thorough analysis.
model: opus
---

# Backlog Auditor

Scan the current repo for tech debt and quality issues. Append actionable, independent items to the `## Backlog` section of the roadmap, tiered by required model capability (Haiku = mechanical, Sonnet = needs judgment).

## Step 1: Find the roadmap

Check in order: `.docs/ai/roadmap.md`, `docs/ai/roadmap.md`. If neither exists, create `.docs/ai/roadmap.md` using the backlog template structure below. Read the existing `## Backlog` section to avoid duplicates.

## Step 2: Detect project type

```bash
ls package.json pyproject.toml Cargo.toml go.mod *.xcodeproj project.yml Gemfile 2>/dev/null
```

## Step 3: Scan for issues

Search the codebase for the patterns below. Use Grep and Glob — do not guess.

### Haiku-tier patterns (mechanical, 1-2 files, no judgment)

| Pattern | Grep/search | What to log |
|---------|-------------|-------------|
| TODO/FIXME/HACK | `TODO\|FIXME\|HACK\|XXX` in source files | Count + file list |
| Empty catch blocks | `catch\s*\{\s*\}` (Swift), `catch\s*\(\w*\)\s*\{\s*\}` (TS), `except:\s*$\|except Exception` (Python) | Each occurrence with file:line |
| Force unwraps (Swift) | `\w!` excluding string literals and IBOutlet | File:line for non-constant unwraps |
| `any` types (TypeScript) | `: any\|as any\|<any>` | File:line |
| Hardcoded magic numbers | Numeric literals in logic (not array indices or 0/1) | Group by file |
| Missing a11y labels | Icon-only buttons without `accessibilityLabel` (Swift) or `aria-label` (TSX) | Count per file |
| Console.log/print in prod | `console\.log\|print(` in non-test source | File:line |
| Commented-out code | Blocks of `//` exceeding 5 consecutive lines | File:line range |
| Missing doc comments | Exported functions without JSDoc (TS) or `///` (Swift) | Count per file |

### Sonnet-tier patterns (needs architectural judgment)

| Pattern | How to detect | What to log |
|---------|---------------|-------------|
| Large files | `wc -l` on source files, flag >300 lines | File + line count + what to extract |
| Long functions | Functions >50 lines | File:line + function name |
| Repeated patterns | 3+ structurally similar blocks | File locations + extraction suggestion |
| Type safety gaps | Untyped dictionaries, `Record<string, any>`, force casts | File:line |
| Missing error handling | Async calls at boundaries without try/catch | File:line |

### Language-specific additions

**Swift/SwiftUI:** Force unwraps, `@State` that could be `let`, views >300 lines, inline DateFormatter, repeated ViewModifier patterns.

**TypeScript:** `@ts-ignore` without reason, `== null`, redundant `?? undefined`, files mixing concerns.

**Python:** Bare `except:`, `# type: ignore`, missing type hints on public API, `print()` in library code.

## Step 4: Check recent history

```bash
git log --oneline -15
```

Skip issues in files that were committed in the last 5 commits (they were likely just worked on).

## Step 5: Format and append

Group related items (e.g., "Fix 5 empty catch blocks in admin views" not 5 separate entries). Each item must include:
- File path(s) relative to repo root
- Line number(s) or ranges
- One-sentence description of what to fix

Cap at **10 Haiku items** and **6 Sonnet items** per audit.

If the roadmap has no `## Backlog` section, create one:
```markdown
## Backlog (parallel, tiered by model capability)

### Haiku (mechanical, no judgment)
- [ ] Item (file:line)

### Sonnet (some architectural judgment)
- [ ] Item (file:line)
```

Append under the correct tier heading. Do NOT duplicate existing items.

## Step 6: Commit

```bash
git add .docs/ai/roadmap.md
git commit -m "docs: audit-backlog — added N Haiku + M Sonnet tier items"
```

If the roadmap path is `docs/ai/roadmap.md`, use that instead.

## Step 7: Report

Output a summary:

```
## Backlog Audit Complete

| Tier | Added | Total Open |
|------|-------|------------|
| Haiku | N | M |
| Sonnet | N | M |

### New Haiku items:
- ...

### New Sonnet items:
- ...

### Skipped (recently committed):
- ...
```
