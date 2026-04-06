---
name: audit-backlog
description: Scan the codebase for tech debt and populate the roadmap's Backlog section with Haiku and Sonnet tier items that cheaper models can execute independently.
user-invocable: true
disable-model-invocation: true
---

# Audit Backlog

Scan the current repo for tech debt and quality issues, then append actionable items to the `## Backlog` section of the roadmap. Each item includes exact file paths and is tagged by tier so cheaper/smaller models can execute them without project context.

## Usage

`/audit-backlog` — full scan, populate both Haiku and Sonnet tiers
`/audit-backlog haiku` — only find Haiku-tier items
`/audit-backlog sonnet` — only find Sonnet-tier items

## Process

### 1. Find the roadmap

Check for the roadmap in this order:
- `.docs/ai/roadmap.md` (standard)
- `docs/ai/roadmap.md` (legacy)
- Ask the user if neither exists

Read the existing `## Backlog` section to avoid duplicating items already listed.

### 2. Detect project type

```bash
ls package.json pyproject.toml Cargo.toml go.mod *.xcodeproj project.yml 2>/dev/null
```

This determines which scanners to run.

### 3. Run scanners

Launch an Explore agent with thoroughness "very thorough" to find issues. The agent should search for the patterns below based on project type.

#### Universal scanners (all projects)

**Haiku-tier patterns:**
- `TODO|FIXME|HACK|XXX` comments (grep across all source files)
- Empty catch/except blocks (`catch {}`, `catch { }`, `except:`, `except Exception:`)
- Force unwraps, force casts, unsafe assertions (`!`, `as!`, `assert`, `unwrap()`)
- Hardcoded magic numbers (numeric literals that should be constants)
- Missing accessibility labels (UI code without a11y attributes)
- Console.log/print left in production code (debug logging that should be removed or structured)
- Commented-out code blocks (dead code)
- Unused imports

**Sonnet-tier patterns:**
- Files over 300 lines (candidates for extraction)
- Functions over 50 lines (candidates for decomposition)
- Repeated code patterns (3+ similar blocks — candidate for utility/component extraction)
- Type safety issues (`any`, `as any`, untyped dictionaries, `Record<string, any>`)
- Missing error handling (async calls without try/catch at boundaries)
- Inconsistent naming conventions within a file

#### Swift/SwiftUI projects

**Haiku:**
- Force unwraps (`!` on optionals outside of compile-time constants)
- Empty `catch {}` blocks
- Missing `accessibilityLabel` on icon-only buttons/images
- Hardcoded padding/spacing values that should use Theme constants
- `@State` properties that could be `let` (never mutated)

**Sonnet:**
- Views over 300 lines → extract sub-views
- Services/managers over 250 lines → extract domain extensions
- Repeated ViewModifier patterns → extract shared modifier
- Inline DateFormatter creation → shared utility
- Repeated error display patterns → shared component

#### TypeScript/JavaScript projects

**Haiku:**
- `// @ts-ignore` or `// @ts-expect-error` without justification
- `any` types (replace with `unknown` or proper types)
- `console.log` in production code
- Missing JSDoc on exported functions
- `== null` instead of `=== null` or `== undefined`

**Sonnet:**
- Files over 300 lines → split by responsibility
- Repeated fetch/API call patterns → extract client utility
- Inline type definitions → extract to types file
- Duplicated validation logic → extract validator

#### Python projects

**Haiku:**
- Bare `except:` or `except Exception:` without logging
- `# type: ignore` without justification
- Missing docstrings on public functions
- Hardcoded string literals that should be constants
- `print()` calls in library code

**Sonnet:**
- Files over 300 lines → split into modules
- Functions over 50 lines → decompose
- Repeated try/except patterns → context manager
- Missing type hints on public API

### 4. Format findings

For each finding, record:
- **Tier** (Haiku or Sonnet)
- **File path** (relative to repo root)
- **Line number(s)**
- **What to fix** (one sentence)

### 5. Update the roadmap

Read the roadmap's `## Backlog` section. If it doesn't exist, create it using the template from `~/.claude/templates/handoff/roadmap.md`.

Append new items under the appropriate tier heading. Use this format:
```markdown
- [ ] [description] (file:line)
```

Rules:
- Do NOT add items that are already listed (check existing items first)
- Do NOT add items for files that were recently committed (check `git log --oneline -10`)
- Group related items (e.g., "Fix 5 empty catch blocks" not 5 separate items)
- Include enough detail that a fresh agent can execute without asking questions
- Cap at 10 Haiku items and 6 Sonnet items per audit (don't overwhelm)

### 6. Report

Output a summary table:

```
## Backlog Audit Results

| Tier | New Items | Total Open |
|------|-----------|------------|
| Haiku | N added | M remaining |
| Sonnet | N added | M remaining |

### Haiku items added:
- item 1
- item 2

### Sonnet items added:
- item 1
```

Commit the roadmap update:
```
git add .docs/ai/roadmap.md
git commit -m "docs: audit-backlog — added N Haiku + M Sonnet tier items"
```
