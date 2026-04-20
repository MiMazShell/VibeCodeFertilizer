# HAZARDS

_Read this file FIRST, and re-read it before any non-trivial task._

Hazards are non-obvious traps in this repo — things that look fine but are secretly wrong, surprising constraints, and dangerous patterns. An AI agent working on this project should read this file at the start of every session and skim it again before touching a new area, to avoid re-discovering the same traps.

Each entry has three parts:
- **What** — the surprising fact (the title below)
- **Why it bites** — the consequence, with context
- **How to handle** — the safe path

Capture new hazards from the ClaudeForge menu-bar HUD the moment you find them. The file compounds in value as real issues get recorded.

---

## Xcode project uses hand-assigned pbxproj UUIDs

**Why it bites:** New Swift files won't compile if only dropped on disk — the file system has no auto-registration. Agents can silently leave the project in a broken state.

**How to handle:** When adding any new .swift file, update project.pbxproj in four places: PBXBuildFile, PBXFileReference, the relevant PBXGroup children, and PBXSourcesBuildPhase. Use unique hex-24 UUIDs in the existing pattern.

---

## regenerateFiles() preserves previously generated content

**Why it bites:** Changes to theme or wizard selections may not propagate to already-viewed generated files. A user who edits a palette still sees the old JSON until content is reset.

**How to handle:** For machine-generated files (.json, .yaml), prefer always-regenerate. Consider a 'Reset to generated' button in the Review step for prose files.

---

## Legacy project names (VibeCodeFertilizer, ClaudeForgeDesigner) persist in paths

**Why it bites:** The product is officially ClaudeForge, but folder paths, Xcode targets, and prior docs reference older names. Drifting names can confuse users and agents.

**How to handle:** Use 'ClaudeForge' in user-facing strings and new docs. Tolerate older names in paths without renaming folders mid-flight — rename surgery is a separate deliberate task.
