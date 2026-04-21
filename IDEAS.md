# IDEAS

Bright ideas and speculative additions for the project. Distinct from bugs (things to fix) and hazards (traps to avoid) — ideas are "this might be worth building."

Each entry has:
- **Why it matters** — the value or user problem behind the idea
- **Sketch** — a one-line shape of what it might look like

Capture ideas from the ClaudeForge HUD as they come up. Agents should read this when scoping new work to flag relevant adjacencies, but nothing here is committed scope until the user says so.

---

## Another brilliant idea from me

**Why it matters:** Hi

**Sketch:** Hello world

---

## Repo reconciliation

**Why it matters:** TO ensure we don't have descrepencies between the local and gitHub repos we should mayby sync/reconcile when the app opens?

**Sketch:** App opens,syc validation screen appears if there are conflicts otherwise happens automaticlly

---

## An Idea uncommited is no idea at all

**Why it matters:** Ideas matter, you matter

**Sketch:** Matter has weight and takes up space

---

## Ideas are the poops of the brain

**Why it matters:** Pooping is key to life. Desruction clears way for growth

**Sketch:** Ideas falling out of my head

---

## I'm so smart

**Why it matters:** AN idea is born

**Sketch:** Things happend and you are impressed

---

## A trashy idea

**Why it matters:** an idea for me to trash

**Sketch:** a trash for me to idea

---

## another trashy idea 2

**Why it matters:** _(no rationale captured)_

**Sketch:** _(no sketch captured)_

---

## a third tashy idea

**Why it matters:** _(no rationale captured)_

**Sketch:** _(no sketch captured)_

---

## Idea Idea

**Why it matters:** _(no rationale captured)_

**Sketch:** _(no sketch captured)_

---

## Edit capture in-place (tap row to load into form)

**Why it matters:** Once a capture is logged, the user has no way to edit it — they can only delete and re-create. Natural expectation in lists like this is "click to edit." Also helps when a capture's wording needs polish before syncing.

**Sketch:** Tap a row in Current hazards/bugs/ideas → the capture's fields populate the form above (title/body1/body2). The Log button becomes "Save changes." Esc or a Cancel button restores the blank form.

---

## Green "AI-reviewed" row state via agent convention

**Why it matters:** Today rows show orange (pending) and blue (synced). There's no signal that an AI agent has actually read and considered a capture. A green state would reassure the human that the signal landed, and creates a nice feedback loop between human-captured context and agent-processed context.

**Sketch:** Define an agent convention: when an agent reads HAZARDS.md/BUGS.md/IDEAS.md as part of a task, it appends `**Reviewed:** <ISO-date>` to each block it considered. Parser picks up that field; row renders with green tint and a tiny eye icon. This becomes a real "dance move" ClaudeForge teaches agents.

---

## Menu-bar icon badge count (not just HUD header)

**Why it matters:** The pending badge lives inside the HUD header today — you have to click the hammer to see it. A count or colored dot on the menu-bar icon itself would surface "you have 3 unsynced captures" without opening anything.

**Sketch:** Use MenuBarExtra's custom label closure to render Image(hammer) + Text("\(count)") when count > 0. When 0, icon-only. Experiment with whether macOS renders text in menu bar cleanly at both light/dark appearances.

---

## This is a new Idea

**Why it matters:** Did it work

**Sketch:** I can't see the cursor.
