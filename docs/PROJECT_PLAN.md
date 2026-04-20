# ClaudeForge — Project Plan

_Living document. Update at the end of every session as direction changes or work ships._

**Version:** 0.3 · **Last updated:** 2026-04-20 (Session 03)

---

## Product identity

**ClaudeForge** is a macOS app that helps users produce and maintain the context AI coding agents need to build Apple-platform software well.

**Positioning:** _"The best Mac app for preparing AI to build Apple software."_

**Target audience:** Intelligent, data-literate users whose coding background is mostly historical (C, Fortran, BASIC, Pascal — 80s/90s). They understand systems and app concepts, but rely on AI to do the actual coding today. They want to feel engaged and empowered, not handed a text-only tool that feels like homework.

## Vision: rhythm and dance moves

ClaudeForge sets the **rhythm of human + AI coding collaboration**. Every artifact it produces is either:

- a **cadence moment** — _when_ something happens (session handoffs, hazard-capture prompts, doc-freshness nudges, end-of-session rituals), or
- a **dance move** — _how_ a specific thing is done (trigger phrases, task templates, conventions, commands, design tokens).

The visual Design Studio is the invitation to the dance. The structured exports are the choreography notes the AI actually reads.

## Product shape (confirmed Session 02)

ClaudeForge has two phases:

1. **Forge** — first-run, small, focused. A simple wizard that scaffolds seed documents for a new project. Runs once, maybe revisited for bigger scope changes.
2. **HUD** — ongoing. An always-available menu-bar companion that captures (hazards, bugs, ideas, screenshots) and surfaces references (plan, triggers, conventions) without interrupting the AI conversation. **This is the main product.**

The conflict between the original wizard-centric plan and the anti-wizard brief resolves here: they're different phases, not competing visions. The wizard is entry scaffolding; the HUD is where the product actually lives.

## Core principle: both-sides value

Every feature should produce BOTH:
- a **visual/interactive affordance** for the human (engagement, confidence, fun), AND
- a **structured file** the AI can execute against (JSON/YAML/markdown with concrete rules).

Never optimize purely for senior-dev efficiency at the cost of engagement. Never optimize purely for visual delight at the cost of machine-readable output.

## Seed vs. finished docs

First-run generates **seed documents** — intentionally incomplete, with clear TODO markers that pull the user back to maintain them. The app lives with the user through the project, not as a one-time wizard.

## Current artifact set

| Artifact | Defines | Status |
|---|---|---|
| `CLAUDE.md` | Overall rhythm (project identity, rules, workflow) | Generated |
| `planning/project-brief.txt` | Goals, audience, scope | Generated |
| `planning/architecture-guidelines.txt` | Architecture invariants | Generated |
| `planning/acceptance-criteria.txt` | Done-ness checklist | Generated |
| `prompts/trigger-phrases.txt` | Named "dance moves" the user can invoke | Generated |
| `prompts/task-templates.txt` | Reusable prompt skeletons | Generated |
| `design-examples/theme-definition.txt` | Design direction, prose | Generated |
| `design-examples/ui-rules.txt` | UI rules, prose | Generated |
| `design-examples/design-tokens.json` | Machine-readable design tokens | Shipped Session 01 |
| `design-examples/*.svg` | Visual reference mocks | Generated |
| `repo/github-setup.txt` | Clone/setup commands | Generated |
| `repo/terminal-cheatsheet.txt` | Commands cheatsheet | Generated |
| **`HAZARDS.md`** | **Non-obvious traps in this repo — read first** | **Shipped Session 02** |
| **`BUGS.md`** | **Open defects** | **Shipped Session 02** |
| **HUD — capture (hazard/bug/idea/screenshot)** | **Menu-bar popover for in-flow capture** | **Hazard/Bug/Screenshot: Session 02; Idea: Session 03** |
| **HUD — Plan tab** | **Wizard-progress reference view** | **Shipped Session 02** |
| **`IDEAS.md`** | **Bright-ideas backlog, sibling to HAZARDS.md/BUGS.md** | **Shipped Session 03** |
| **Target repo folder setting** | **UserDefaults-backed path; wizard export + HUD settings both set it** | **Shipped Session 03** |
| **Auto-write on capture** | **Read-merge-write into HAZARDS/BUGS/IDEAS.md in target repo on every capture** | **Shipped Session 03** |
| **Pending indicator** | **Amber badge + per-row dot for unsynced captures** | **Shipped Session 03** |
| **Sync-to-repo action** | **HUD button: git add/commit/push with rotating-icon animation** | **Shipped Session 03** |
| **Archive / History tab** | **Parses git log → lists removed blocks with Restore action** | **Shipped Session 03** |
| **HUD Settings sheet** | **Target-repo picker, last-sync status, clear** | **Shipped Session 03** |
| `COMMANDS.md` (standalone) | Copy-paste invocations | Not yet built |
| `CONVENTIONS.md` | "How we do things here" | Not yet built |
| Session handoff notes | End-of-session recap | Not yet built |
| Menu-bar badge count | Show pending count on the menu-bar hammer icon itself | Not yet built (HUD header shows it) |

## Roadmap (ordered)

1. ✅ **Design-tokens.json export** — structured design output agents can execute against
2. ✅ **HUD v0.1** — menu-bar popover with hazard/bug/screenshot capture + Plan reference tab; HAZARDS.md + BUGS.md exports; CLAUDE.md "read first" pointer
3. ✅ **HUD v0.2 — sync & persistence** (Session 03):
   - ✅ Target-repo-folder setting (UserDefaults, sticky + explicit HUD picker)
   - ✅ Auto-write on capture (read-merge-write to HAZARDS/BUGS/IDEAS.md)
   - ✅ "Sync to Repo" button: git add + commit + push (terse summary commit format)
   - ✅ Sync animation (rotating-gear icon → green check flash)
   - ✅ Ideas capture (4th type) + `IDEAS.md` export
   - ✅ CLAUDE.md "Read first" updated to include IDEAS.md + "re-read each session, and before any non-trivial task"
   - ✅ Archive/History tab: parses `git log` → lists removed blocks with Restore action
4. ⬜ **Commands module** — `COMMANDS.md` with detected-project-type defaults
5. ⬜ **Conventions module** — `CONVENTIONS.md` seed with Apple-platform pitfalls
6. ⬜ **Trigger phrase management in HUD** — view/create aliases without leaving flow
7. ⬜ **Session handoff ritual** — end-of-session summary doc generator
8. ⬜ **Living-doc sidebar mode** — "open existing repo" → drop into maintenance view
9. ⬜ **Floating repo helper panel** — always-on-top window with copy-buttons
10. ⬜ **Token-based GitHub repo creation** — API flow from within the app
11. ⬜ **Repo-access helper** — detect SSH/keychain state, walk through setup (see `SSH access pain point` memory)
12. ⬜ **Better Review & Edit UX** — friendly doc titles, easier file switching
13. ⬜ **Animation presets + richer Design Studio component examples**
14. ⬜ **Writing-assist integration** — refine narrative fields for clarity/conciseness

## Delivery rules (always apply)

1. Double-check all code for compile risks before reporting done.
2. Verify every referenced file, function, and variable exists.
3. Ensure Xcode project file references are correct (files in the target, not just on disk).
4. Prefer minimal-file fixes.
5. If >3 files impacted, deliver a full ZIP of the affected tree.
6. State honestly whether code was only structurally reviewed or actually compiled.
7. Preserve prior working state when iterating.

## Key context documents

- `docs/PROJECT_PLAN.md` — this doc
- `docs/SESSION_XX_SUMMARY.md` — per-session handoff notes
- `ClaudeForgeDesigner_V6/AIContextTool_Brief.txt` — original brief from CarePort lived experience
- `ClaudeForgeDesigner_V6/ProjectOverview 1.txt` — earlier v6 directional overview
- `../ClaudeForgeDesigner_ProjectPlan.txt` (outside repo, parent folder) — original detailed plan; retained for history
