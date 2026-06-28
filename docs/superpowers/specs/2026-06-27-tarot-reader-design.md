# Tarot Reader for Emacs — Design Spec

**Date:** 2026-06-27
**Status:** Approved

## Overview

A tarot card reading plugin for Emacs, built as a structured learning exercise in
Emacs Lisp and Emacs package development. Development is test-driven: each iteration
begins with a failing test, then implements the minimum to pass it, then refactors.

Starting fresh from the existing repository (prior iterations preserved in git
history) to fix identified issues in the previous codebase:

- Tests were co-located with production code in `tarot.el`
- `tarot-reading` never shuffled the deck (bug: always dealt the same order)
- `tarot-shuffle` was a redundant thin wrapper around `tarot--shuffle`
- No `defgroup` / `defcustom` for the customization system

---

## File Structure

```
tarot.el               — core logic, UI, mode, commands, customization
tarot-meanings.el      — single defconst with all 78 card meanings (upright + reversed)
tarot-test.el          — all ERT tests (never loaded by end users)
```

`tarot-meanings.el` uses `(provide 'tarot-meanings)` and is loaded from `tarot.el`
via `(require 'tarot-meanings)`. This teaches the `provide`/`require` module system
while keeping meaning data (≈450 lines) out of the logic file.

`tarot.el` is organised into sections with `;;; Section ──` comments:

```
;;; Card data       — defconst: major arcana names, minor suits, ranks
;;; Deck ops        — make-deck, shuffle, draw
;;; Meanings        — card-meaning
;;; Reading ops     — spread defconsts, draw-reading (with reversals)
;;; Faces           — defgroup, defface
;;; Customization   — defcustom
;;; UI / Mode       — define-derived-mode, render, keymap
;;; Commands        — tarot-reading (interactive entry point)
```

---

## Data Model

The data model is intentionally **not prescribed upfront**. It emerges through TDD:
tests for behaviour surface the right shapes. Key decision points are flagged as
Learn by Doing moments in the iteration plan below.

One known Elisp subtlety surfaces in Iteration 7 (reading assembly): pairing a
position string with a card plist using `cons` produces a flat list that looks like
a splice (`("Past" :rank 3 :suit "Cups")`), not a nested pair. Both the dotted pair
approach (access card via `cdr`) and the two-element list approach
`(list position card)` (access card via `cadr`) are valid. This is a *Learn by
Doing* decision point — the right choice becomes clear when writing the display code.

---

## Rendering Approach

**Approach: erase-and-redraw** (used by Magit, Elfeed, Dired).

Two buffer-local variables hold all state:

- `tarot--reading` — the full reading alist (positions + drawn cards)
- `tarot--position-index` — integer, which position is currently selected

`tarot--render` erases the buffer and redraws from these variables on every state
change. The buffer is always a pure projection of state — never the source of truth.

Navigation commands (`n`/`p`) mutate `tarot--position-index` then call
`tarot--render`. Cursor position is restored after redraw via `save-excursion`.

**Display per position:**

```
Past                          ← position label (tarot-position-face)
  Three of Cups               ← card name (tarot-major-arcana-face or tarot-minor-arcana-face)
  Upright                     ← orientation indicator
```

Selected position additionally shows:

```
  Celebration, friendship,    ← meaning text (only for selected position)
  joy shared with others...
```

---

## Mode

`tarot-mode` derives from `special-mode`:

```elisp
(define-derived-mode tarot-mode special-mode "Tarot"
  "Major mode for tarot card readings.")
```

`special-mode` provides read-only buffers, `q` to quit, and `g` to revert.
`tarot-mode-map` inherits from it and adds:

- `n` — `tarot-next-card`
- `p` — `tarot-prev-card`

---

## Reversals

Cards are drawn with a randomly assigned orientation (50% upright, 50% reversed).
`:reversed` is added to the card plist at draw time, not stored in the deck.
The deck remains a pure list of unoriented cards; orientation is a property of
how a card was drawn.

`tarot-card-meaning` uses `:reversed` on the drawn card to select the correct
meaning string.

---

## Meaning Data

Stored in `tarot-meanings.el` as a single `defconst` alist keyed by the string
returned by `tarot-card-name`:

```elisp
(defconst tarot-meanings
  '(("The Fool"
     :upright "..."
     :reversed "...")
    ("Three of Cups"
     :upright "..."
     :reversed "...")
    ...))
```

Meanings are original text (not lifted from any source) to avoid licensing
ambiguity. Short: 2–3 sentences per orientation.

---

## TDD Iteration Plan

### Phase 1 — Pure core

**Iteration 1: Test infrastructure**
Set up `tarot-test.el` as a separate file with a sanity-check test.
Concepts: `provide`/`require`, ERT basics, `M-x ert`

**Iteration 2: Deck construction**
`tarot-make-deck` returns a list of cards.
*Learn by Doing:* how to represent a card; major vs minor distinction emerges
from tests.
Concepts: `defconst`, `mapcar`, `append`, `cl-loop`

**Iteration 3: Card naming**
`tarot-card-name` returns a friendly string for any card.
Concepts: `plist-get`, `alist-get`, `format`, `if`

**Iteration 4: Shuffling**
`tarot-shuffle` using Fisher-Yates directly — no redundant wrapper.
Concepts: `vconcat`, `aref`, `aset`, `random`, vectors vs lists

**Iteration 5: Drawing**
`tarot-draw` pulls N cards and returns drawn + remaining.
Concepts: `take`, `nthcdr`, `cons`, return value conventions

### Phase 2 — Readings & data

**Iteration 6: Reversals**
Drawing assigns a random orientation to each card.
*Learn by Doing:* where does `:reversed` belong — on the card, at draw time,
or somewhere else? Tests surface the right answer.
Concepts: `random`, extending plists

**Iteration 7: Spreads & readings**
Spread `defconst`s (single, three-card, Celtic Cross). `tarot-draw-reading`
pairs positions with drawn cards.
*Learn by Doing:* what shape makes display code natural? Alist, plist, list
of pairs?
Concepts: `cl-mapcar`, alist construction

**Iteration 8: Meanings & multi-file packages**
Create `tarot-meanings.el` with stub meanings and `(provide 'tarot-meanings)`.
Implement `tarot-card-meaning`.
Concepts: `provide`/`require` as Elisp's module system, alist lookup

### Phase 3 — Emacs UI

**Iteration 9: Major mode & buffer basics**
`tarot-mode` derived from `special-mode`. Stub `tarot-reading` opens `*tarot*`
and inserts a card name.
Concepts: `define-derived-mode`, `with-current-buffer`, `erase-buffer`, `insert`

**Iteration 10: Faces**
`defgroup` and `defface` for position labels, major arcana, minor arcana,
reversed cards. Apply with `propertize`.
Concepts: `defgroup`, `defface`, `propertize`, face composition

**Iteration 11: Buffer-local state**
Store reading in buffer-local variables. `tarot--render` erases and redraws
from state.
Concepts: `setq-local`, state-driven rendering, `save-excursion`

**Iteration 12: Navigation**
`tarot-next-card` / `tarot-prev-card` bound to `n`/`p` in `tarot-mode-map`.
Concepts: `make-sparse-keymap`, `define-key`, `kbd`

**Iteration 13: Meanings display**
Render the selected card's meaning (upright or reversed) in the buffer.
Concepts: state-dependent rendering, conditional `insert`

### Phase 4 — Polish

**Iteration 14: Customization**
`defcustom` for the spreads list and meaning display options.
Concepts: `defcustom`, `:type`, `:group`, `M-x customize`

**Iteration 15: Full interactive command**
`M-x tarot-reading` with `completing-read` for spread selection. Shuffle wired
in correctly (fixing the prior codebase bug).
Concepts: `interactive`, `completing-read`, tying all layers together

### Optional

**Iteration 16: Spatial Celtic Cross layout**
A 2D ASCII layout for the Celtic Cross spread using column-position-based
insertion, or SVG rendering via `svg.el`.
Concepts: `move-to-column`, `forward-line`, optionally `svg-create`/`svg-text`

---

## Testing Strategy

### Structure

`tarot-test.el` begins:

```elisp
(require 'ert)
(require 'tarot)
(require 'tarot-meanings)
```

Tests are grouped by iteration with `;;; Iteration N ──` section comments.

### What to test at each layer

**Pure functions** (deck, shuffle, draw, meanings lookup): test inputs and
outputs directly. No setup, no teardown.

**Reading assembly** (spreads, reversals): test structural invariants —
correct number of positions, orientation assigned, no card appears twice.
Do not assert specific cards from random draws; assert properties that must
hold regardless of random outcome.

**Buffer/UI layer**: test `(buffer-string)` after rendering a known,
fixed reading. Use non-random test fixtures so assertions are deterministic.

**Navigation**: test that `tarot--position-index` advances and wraps
correctly, and that the buffer reflects the new state.

### What not to test

- Content of meaning strings (data, not behaviour)
- Exact character positions in the buffer (too brittle)
- That `completing-read` prompts interactively

### ERT patterns introduced per iteration

| Pattern | Iteration |
|---|---|
| `(should ...)` / `(should-not ...)` | 1 |
| Testing list properties with `dolist` | 2–3 |
| Probabilistic invariant testing | 5–6 |
| `(with-temp-buffer ...)` for UI tests | 9 |
| `(ert-simulate-command ...)` for commands | 12 |

---

## Development Tooling

Install before writing code:

- **paredit** or **smartparens** — balanced parenthesis editing
- **helpful** — richer `describe-function` / `describe-variable`
- **rainbow-delimiters** — colour-coded nesting depth

Essential built-ins to learn early:

- `C-M-x` (`eval-defun`) — reload one function without restarting
- `M-x ielm` — Elisp REPL for interactive experimentation
- `C-h f` / `C-h v` — describe function/variable (replace with helpful)
- `M-x toggle-debug-on-error` — full backtraces on error (leave on)
- `M-x edebug-defun` — step debugger for failing functions
- `M-x byte-compile-file` — catches argument/variable errors the interpreter misses
- `M-x checkdoc` — validates docstring conventions
- `M-x ert` — runs the test suite interactively
- `*Messages*` buffer — output from `(message ...)` calls
