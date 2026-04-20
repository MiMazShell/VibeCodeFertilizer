# Session 03 — Summary

**Date:** 2026-04-20
**Focus:** HUD v0.2 — sync, persistence, and the git-as-source-of-truth loop

---

## What shipped

- ✅ **Target-repo-folder setting** — `UserDefaults`-backed path. Sticky: persists across app restarts. Set via HUD → ⚙ → Choose Folder…, with Change / Clear affordances in the Settings sheet.
- ✅ **Auto-write on capture** — every `addHazard` / `addBug` / `addIdea` / `remove*` immediately writes the affected file (`HAZARDS.md` / `BUGS.md` / `IDEAS.md`) into the target repo. Pure write: in-memory state is the source of truth; no merge-on-write, which is what prevents delete-resurrection.
- ✅ **Read-merge-write (separate path)** — on HUD appear / target-repo pick / explicit refresh, the app reads the repo's capture files, absorbs any blocks present there but absent from in-memory (AI edits, hand edits, prior-session captures), writes the unified state back. Distinct from add/remove writes by design.
- ✅ **Sync to Repo button** — `git add HAZARDS.md BUGS.md IDEAS.md && git commit && git push` via `Process`. Terse summary commit message (`"Capture: 2 hazards, 1 bug — 2026-04-20"`). Push failures surface in the HUD header without blocking the local commit.
- ✅ **Sync animation** — timer-driven icon rotation (hammer → rotating gear during sync → 1.2s green-checkmark flash → clean return to static orange hammer). Timer-based rather than `.repeatForever` SwiftUI animation because `repeatForever` does not stop cleanly when its driving state flips off — a real hazard to note.
- ✅ **Pending indicator** — amber `N unsynced` pill in the HUD header; soft-orange card banding on pending rows, soft-blue card banding on synced rows (replaced the earlier per-row dot based on user feedback).
- ✅ **Ideas capture (4th type)** — `Idea` model, HUD capture form, `IDEAS.md` template.
- ✅ **Archive tab (git history → restore)** — parses `git log --pretty=format:%H\t%ct` + `git show <hash>:FILE` across HAZARDS/BUGS/IDEAS. Blocks that existed in some past commit but aren't in HEAD become Restore candidates. One-tap restore re-adds the block to in-memory + the current file.
- ✅ **HUD Settings sheet** — target-repo picker + status row + last-sync message + error surface.
- ✅ **CLAUDE.md — re-read directive** — `## Read first (re-read each session, and before any non-trivial task)` now covers HAZARDS.md, BUGS.md, and IDEAS.md, including an agent instruction to ask the user to HUD-capture newly-discovered traps.
- ✅ **PROJECT_PLAN.md updated** to v0.3 reflecting shipped scope.

## Defining decision (Session 03)

**Git is the single source of truth for captures after sync. Pre-sync captures are ephemeral.**

This resolved two design questions we worked through at session start:

- The app never maintains a separate "local archive" of trashed captures. History of committed captures lives only in git; the Archive tab is a friendly UI over `git log`.
- Uncommitted-then-trashed captures don't appear anywhere — intentional. Sync acts as "commit to memory." Until then, the capture is draft-state.

This preserves the "no dual history" invariant the user chose over the more heavyweight trash-bin design.

## Six design questions answered this session

| Q | Resolved to |
|---|---|
| 1. Auto-sync vs. manual? | **Manual button.** Captures auto-*write* to files instantly; git commit waits for the user's click. |
| 2. Delete after commit? | **Yes.** Removal commits on next sync. Captures never immutable. |
| 3. Archive shape? | **Git as single source of truth.** Archive tab parses `git log`, no separate app-side store. |
| 4. Commit message format? | **Terse summary** — `"Capture: 2 hazards, 1 bug — YYYY-MM-DD"`. |
| 5. Manual edits to HAZARDS.md outside the app? | **Read-merge-write.** Parser tolerates AI-introduced variation (field order, heading levels). |
| 6. Target-repo setting location? | **Sticky from wizard + explicit HUD picker** (both paths resolve to the same UserDefaults key). |

## Files changed this session

| File | Change |
|---|---|
| `Models/WizardModels.swift` | +`SyncState`, +`Idea`, `syncState` on Hazard/Bug/Idea |
| `ViewModels.swift` | +ideas list, +target-repo state, +sync orchestration, +`refreshFromRepoIfTargetSet`, +`restoreRemovedBlock`, +pending-count helpers |
| `Services/CaptureMarkdown.swift` **NEW** | Render (hazard/bug/idea blocks), parse (tolerant block extractor), merge helpers (title-keyed union with orphans-as-synced) |
| `Services/RepoSyncService.swift` **NEW** | UserDefaults path, pure-write + read-merge-write file ops, `syncCommit` via `/usr/bin/git` Process, `fetchRemovedBlocks` git-log parser |
| `Services/TemplateService.swift` | IDEAS.md template, hazards/bugs/ideas intros exposed as static funcs, CLAUDE.md "Read first" expanded to cover re-read directive + IDEAS.md |
| `Views/HUDView.swift` | +Archive tab, +Settings sheet, 4-type capture picker (Hazard/Bug/Idea/Shot), IdeaCaptureForm + IdeaRow, CaptureRowStyle (orange/blue banding + stroke), timer-driven sync animation, HUD.onAppear refresh, reversed ordering for newest-on-top |
| `ClaudeForgeDesigner.xcodeproj/project.pbxproj` | Registered CaptureMarkdown.swift + RepoSyncService.swift (4 surgery sites each; UUIDs `…121/…201` and `…122/…202`) |
| `docs/PROJECT_PLAN.md` | v0.3 update, Session 03 scope checked, menu-bar-badge-count deferred to follow-ups |
| `HAZARDS.md` / `BUGS.md` / `IDEAS.md` (target-repo root) | Seeded + session captures from dogfooding |

## Verified manually

- `xcodebuild -destination 'platform=macOS' build` succeeds clean.
- App launches; menu-bar hammer icon present.
- Sync end-to-end exercised against the VibeCodeFertilizer repo:
  - Capture orange-banded → Sync → turns blue → Archive shows nothing.
  - Trash a committed capture → Sync → Archive shows the removed block with commit hash + Restore button.
  - Restore from Archive → capture reappears as pending → Sync → banding flips back to blue.
- Read-merge-write absorbs captures the AI (this agent) writes directly into BUGS.md / IDEAS.md on next HUD open.

## Bugs surfaced during testing (captured in BUGS.md)

- **Folder picker opens behind other apps when invoked from the HUD** — NSOpenPanel appears behind currently-focused app. Suspected fix: `NSApp.activate(ignoringOtherApps: true)` before `panel.runModal()`.
- **HUD does not return to focus after folder picker dismisses** — MenuBarExtra `.window` style dismisses on focus loss and doesn't auto-reopen after the NSOpenPanel returns.

Two regressions discovered and fixed within the session (not filed, because fixed):
- Sync icon spin persisted after completion — `.repeatForever` SwiftUI animation doesn't stop via transaction-based value reset. Fixed by switching to `Timer`-driven rotation.
- Delete didn't propagate (items turned blue instead of disappearing) — `persistCaptures` ran read-merge-write on every user action, so just-deleted blocks were re-absorbed as "orphans" from the file that hadn't been written yet. Fixed by splitting: pure write on add/remove, merge-write only on refresh.

## Session 04 scope (suggested)

```
HUD polish + agent convention
  [ ] Fix the two window-focus bugs in BUGS.md
  [ ] Edit capture in-place (tap row → form pre-fills, Save vs. Cancel)
  [ ] Green "AI-reviewed" row state — define the convention (agent writes `**Reviewed:** <date>` to each block it considered), update parser to render green, update CLAUDE.md to teach the convention
  [ ] Menu-bar icon badge count (MenuBarExtra custom label closure)
  [ ] First-run smoothness: if target repo isn't a git repo, offer to run `git init` with a confirmation
```

Longer horizon:
```
Commands + Conventions modules
  [ ] COMMANDS.md generator with detected-project-type defaults
  [ ] CONVENTIONS.md seed with Apple-platform pitfalls
  [ ] Session handoff ritual — end-of-session summary doc generator from HUD
```

## Session vibe

Long but productive. First half was the 6-question design-resolution pass (manual sync, removal commits, git-as-single-source, terse commit format, read-merge-write, sticky-plus-explicit target). Second half built it. Third half bug-bashed it — the two regressions found (forever-animation cling, orphan-merge resurrection) were both real lessons worth writing into HAZARDS.md if they recur in similar contexts.

The moment of "mental model validation" was the user asking why uncommitted trashed ideas don't appear in Archive. The answer — "by design, because you chose git-as-single-source-of-truth in Q3" — confirmed the design choice held together. That's the shape of a good session: decisions early, implementation second, and the user's post-test question maps cleanly back to a decision they already made.

## Suggested next session opener

Pick up with the **two focus bugs in BUGS.md** as warmup (10–20 minutes of AppKit window-management surgery), then move to **edit capture in-place** as the first real feature of Session 04. The green-reviewed state is the conceptually richest item on the list and probably wants its own focused discussion before code.
