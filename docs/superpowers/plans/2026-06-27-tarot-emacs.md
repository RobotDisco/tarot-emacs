# Tarot Emacs — Implementation Plan

**Goal:** Build a complete Emacs tarot card reading package from scratch using TDD,
progressing through phases that each introduce a cluster of Emacs Lisp concepts.

**Architecture:** Three files — `tarot.el` (core logic + UI), `tarot-meanings.el`
(meaning data via `provide`/`require`), `tarot-test.el` (ERT tests, never loaded by
users). Buffer-local state drives erase-and-redraw rendering in a `special-mode`-derived
major mode. Each task starts with a failing test.

**Tech Stack:** Emacs Lisp 26.1+, ERT (built-in), `cl-lib` (built-in), `seq` (built-in)

**Conventions:**
- `tarot-` prefix for public symbols, `tarot--` for internal/private
- Conventional commits: `type: description`
- Tests live in `tarot-test.el` only

---

## Phase 1 — Pure Core ✓

Data and logic with no Emacs UI involved. Pure functions, pure data.

### Task 1: Test infrastructure ✓
A working ERT test suite that loads and runs.

### Task 2: Deck construction ★ Learn by Doing ✓
A constant representing the full 78-card deck. Cards have a name. The deck covers
all 22 major arcana and all 56 minor arcana (4 suits × 14 ranks). Tests verify
count, major arcana coverage, and minor arcana coverage.

### Task 3: Card naming ✓
A function that returns a human-readable name string for any card in the deck.
Major arcana return their name directly. Minor arcana return "Rank of Suit" format.

### Task 4: Shuffling ✓
A function that returns a new shuffled copy of the deck without modifying the
original. Tests verify count is preserved, card set is preserved, and the original
is not mutated.

### Task 5: Drawing ✓
A function that draws N cards from a deck and returns both the drawn cards and the
remaining deck as a single return value.

---

## Phase 2 — Readings & Data ✓

Combining cards into readings, adding orientation, attaching meaning.

### Task 6: Reversals ★ Learn by Doing ✓
A function that takes a card and returns a new card with a randomly assigned
orientation (upright or reversed). The original card is not modified. Orientation
is stored as `:orientation :upright` or `:orientation :reversed` on the card plist.

### Task 7: Spreads and readings ★ Learn by Doing ✓
Spread definitions (single card, three card, Celtic Cross — each with a name and
a list of position labels). A function that takes a deck and a spread, draws the
right number of cards, assigns each an orientation, and pairs each card with its
position label. No card appears twice. The return shape should make display code
natural to write.

### Task 8: Meanings and multi-file packages ✓
A second file (`tarot-meanings.el`) containing original 2–3 sentence meanings for
all 78 cards in both orientations, loaded via Elisp's `provide`/`require` module
system. A function that looks up the correct meaning for a card given its
orientation.

---

## Phase 3 — Emacs UI ✓

Bringing the logic into an interactive Emacs buffer.

### Task 9: Major mode and buffer basics ✓
A major mode derived from `special-mode`. A stub interactive command that opens a
dedicated `*tarot*` buffer using that mode and writes something into it.

### Task 10: Faces ✓
A customization group and faces for: spread position labels, major arcana card
names, minor arcana card names, and reversed orientation indicators. No new tests —
faces are exercised in the render step.

### Task 11: Buffer-local state and rendering ✓
Buffer-local variables holding the active reading and the currently selected
position index. A render function that erases the buffer and redraws from those
variables — showing all positions, card names, and orientation for each, with a
visual indicator on the selected position.

### Task 12: Navigation ✓
Commands to move forward and backward through positions, wrapping at either end.
Bound to keys in the mode keymap. Each navigation call rerenders the buffer.

### Task 13: Meanings display ✓
Extend the render function to show the meaning text for the currently selected
position only. Unselected positions show name and orientation but not meaning.

---

## Phase 4 — Polish ✓

### Task 14: Customization ✓
User-configurable options via `defcustom`: `tarot-spreads` is directly editable,
letting users add, remove, or redefine spreads rather than choosing from a fixed
set. `tarot-show-reversed-orientation` controls whether reversed cards display
their true reversed orientation and meaning, or are suppressed and always shown
as upright — suppression happens at display time only; the card's actual drawn
orientation is unaffected.

### Task 15: Full interactive command ✓
Replace the stub command with the complete entry point: prompt the user to choose
a spread, shuffle a fresh deck, draw a reading, and render it. Everything wired
together end to end.

---

## Optional

### Task 16: Spatial Celtic Cross layout
An alternative renderer that places the 10 Celtic Cross cards in their traditional
2D spatial arrangement rather than a linear list.
