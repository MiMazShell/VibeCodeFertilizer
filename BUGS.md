# BUGS

Open defects in the project. Bugs are specific issues to fix — different from hazards (ongoing traps) and ideas (speculative additions).

Each entry has:
- **Symptom** — what's observably wrong
- **Suspected area** — where it likely lives in the code

Capture bugs from the ClaudeForge menu-bar HUD when you hit one.

---

## Folder picker opens behind other apps when invoked from the HUD

**Symptom:** After clicking Settings → Choose Folder… in the HUD, the NSOpenPanel appears behind the currently-focused app (Terminal, Xcode, etc.) instead of as a top-most modal over the HUD. The user has to hunt for it in window stacking.

**Suspected area:** ClaudeForgeDesignerApp.swift MenuBarExtra + RepoSyncService.promptForTargetRepo — likely needs NSApp.activate(ignoringOtherApps: true) before panel.runModal(), and/or setting panel.level = .modalPanel.

---

## HUD does not return to focus after folder picker dismisses

**Symptom:** After choosing a folder (or cancelling) in Settings → Choose Folder…, the HUD popover closes and control jumps back to whichever app was previously focused. The user has to click the menu-bar hammer icon again to re-open the HUD and finish their flow (e.g., click Done on the Settings sheet).

**Suspected area:** MenuBarExtra with .window style dismisses on focus loss. After the NSOpenPanel closes, focus doesn't return to the popover. Likely needs an explicit "reopen HUD" call or a different window strategy for the Settings sheet (e.g., present as a standalone NSWindow rather than a sheet inside a popover).
