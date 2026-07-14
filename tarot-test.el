;;; tarot-test.el --- Tarot.el tests -*- lexical-binding: t; -*-

;; Copyright (C) 2026 Gaelan D'costa
;; Author: Gaelan D'costa <gaelan@fastmail.ca>
;; SPDX-License-Identifier: GPL-3.0-or-later

;; This file is NOT part of GNU Emacs.

;;; Commentary:
;; Tarot.el tests

;;; Code:
(require 'ert)
(require 'tarot)
(require 'tarot-meanings)

;;; Iteration 1 - Test scaffolding ---------------------------------------------

(ert-deftest tarot-test-sanity ()
  "Sanity check."
  (should (= 1 1)))

;;; Iteration 2 - Card data ----------------------------------------------------

(ert-deftest tarot-test-deck-has-78-cards ()
  "Tarot deck needs right number of cards."
  (should (= (length tarot-deck) 78)))

(ert-deftest tarot-test-deck-has-major-arcana-cards ()
  "Tarot deck has all major arcana cards."
  (dolist (card tarot-major-arcana)
    (should (cl-member card tarot-deck :test #'equal))))

(ert-deftest tarot-test-deck-has-all-minor-rank-suit-combinations ()
  "Tarot deck has 14 cards for all four suits."
  (dolist (suit tarot-minor-suits)
    (dolist (rank tarot-minor-ranks)
      (let ((card (list :name (format "%s of %s" rank suit))))
	(should (cl-member card tarot-deck :test #'equal))))))

;;; Iteration 3 - Card accessors -----------------------------------------------

(ert-deftest tarot-test-card-name ()
  "Function to get name of tarot card."
  (should (equal (tarot-card-name '(:name "The Magician")) "The Magician"))
  (should (equal (tarot-card-name '(:name "Ace of Cups")) "Ace of Cups")))

;;; Iteration 4 - Card shuffling -----------------------------------------------

(ert-deftest tarot-test-shuffling-does-not-change-count ()
  "Shuffling tarot deck does not change number of cards in deck."
  (should (= (length tarot-deck) (length (tarot-shuffle tarot-deck)))))

(ert-deftest tarot-test-shuffled-deck-has-same-cards-as-unshuffled ()
  "Shuffling tarot deck does not change the cards, only their positions."
  (let ((shuffled (tarot-shuffle tarot-deck)))
    (dolist (card tarot-deck)
      (should (cl-member card shuffled :test #'equal)))))

(ert-deftest tarot-test-shuffling-does-not-mutate-original-deck ()
  "Shuffling does not mutate the original deck, but creates a copy."
  (let ((shuffled (tarot-shuffle tarot-deck)))
    (should-not (equal tarot-deck shuffled))))

(ert-deftest tarot-test-handles-empty-list ()
  "Shuffling handles an empty list."
  (should (equal (tarot-shuffle '()) '())))

;;; Iteration 5 - Drawing cards ------------------------------------------------

(ert-deftest tarot-test-draw-cards ()
  "Drawing N cards returns the first N cards from the deck."
  (should (equal (car (tarot-draw tarot-deck 3 #'identity))
		 (take 3 tarot-deck)))
  (should (equal (car (tarot-draw '() 5))
		 '())))

(ert-deftest tarot-test-draw-count ()
  "The number of cards drawn and left is the same as the total deck number."
  (seq-let (drawn remaining) (tarot-draw tarot-deck 5 #'identity)
    (should (= (length drawn) 5))
    (should (= (length remaining) (- (length tarot-deck) 5)))))

(ert-deftest tarot-test-draw-splits-deck ()
  "The cards in the drawn and remaining piles make up the entire deck."
  (seq-let (drawn remaining) (tarot-draw tarot-deck 5 #'identity)
    (should (equal (append drawn remaining)
		   tarot-deck))))

(ert-deftest tarot-test-draw-too-many-cards ()
  "Drawing too many cards returns empty list, leaving all cards as remaining."
  (let ((request-num 10)
	(cards '(one two three four five)))
    (seq-let (drawn remaining) (tarot-draw cards request-num #'identity)
      (should-not drawn)
      (should (equal cards remaining)))))

;;; Iteration 6 - Card orientation ---------------------------------------------

(ert-deftest tarot-test-draw-gives-cards-orientations ()
  "When drawing from a deck, cards have upright or reversed orientations."
  (seq-let (drawn _) (tarot-draw tarot-deck 78)
    (dolist (card drawn)
      (should (memq (tarot-card-orientation card) '(:upright :reversed))))))

(ert-deftest tarot-test-draw-eventually-provides-upright-and-reversed-cards ()
  "Drawing enough cards guarantees us some in upright and reversed positions."
  (seq-let (drawn _) (tarot-draw tarot-deck 78)
    (let ((orientations (mapcar #'tarot-card-orientation drawn)))
      (should (cl-member :upright orientations))
      (should (cl-member :reversed orientations)))))

(ert-deftest tarot-test-draw-does-not-modify-original-value ()
  "The default tarot draw function does not mutate the original card."
  (let* ((card '(:name "test card"))
	 (deck (list card)))
    (seq-let (drawn _) (tarot-draw deck 1)
      (should (equal card '(:name "test card")))
      (should-not (equal card (car drawn))))))

;;; Iteration 7 - Spreads and readings -----------------------------------------

(ert-deftest tarot-test-draw-reading-fills-all-spread-positions ()
  "Drawing cards for a spread uses populates all spread positions."
  (let* ((spread '("pos1" "pos2" "pos3"))
	 (reading (car (tarot-draw-reading tarot-deck spread)))
	 (rkeys (mapcar #'car reading)))
    (should (= (length reading) (length spread)))
    (dolist (key spread)
      (should (member key rkeys)))))

(ert-deftest tarot-test-draw-reading-draws-without-replacement ()
  "Drawing into a spread never replaces cards in the deck."
  (let ((spread (number-sequence 1 78)))
    (seq-let (reading remaining) (tarot-draw-reading tarot-deck spread #'identity)
      (should (= (length remaining) 0))
      (let ((rcards (mapcar #'cdr reading)))
	(should (equal rcards (cl-remove-duplicates rcards :test #'equal)))))))

(ert-deftest tarot-test-draw-reading-too-many-cards ()
  "Drawing too many cards returns nil reading."
  (let ((spread '("pos1" "pos2" "pos3" "pos4" "pos5" "pos6" "pos7" "pos8"))
	(cards '(one two three four five)))
    (seq-let (reading remaining) (tarot-draw-reading cards spread #'identity)
      (should-not reading))))

(ert-deftest tarot-test-spread-get-by-name ()
  "`tarot-spreads-get' performs a name lookup from `tarot-spreads'."
  (should (equal (tarot-spreads-get "Three Card") '("Past" "Present" "Future"))))

(ert-deftest tarot-test-spread-nonexistent-name ()
  "`tarot-spreads-get' returns nil when name isn't found in `tarot-spreads'."
  (should-not (tarot-spreads-get "Non-existent spread")))

;;; Iteration 8 - Card Meanings ------------------------------------------------

(ert-deftest tarot-test-meaning ()
  "Test fetching card meanings by card name."
  (let ((tarot-meanings
	 '(("The Fool" . (:upright "something" :reversed "rsomething"))
	   ("Five of Wands" . (:upright "something" :reversed "rsomething")))))
    (should (string-equal (tarot-card-meaning '(:name "The Fool" :orientation :upright)) "something"))
    (should (string-equal (tarot-card-meaning '(:name "The Fool" :orientation :reversed)) "rsomething"))
    (should (string-equal (tarot-card-meaning '(:name "Five of Wands" :orientation :upright)) "something"))
    (should (string-equal (tarot-card-meaning '(:name "Five of Wands" :orientation :reversed)) "rsomething"))
    (should-not (tarot-card-meaning '(:name "Fifty-eight of Guitars" :orientation :upright)))))

(ert-deftest tarot-test-meaning-undrawn-card ()
  "Error when tarot-card-meaning is given a card lacking drawn orientation."
  (let ((tarot-meanings
	 '(("The Fool" . (:upright "something" :reversed "rsomething")))))
    (should-error (tarot-card-meaning '(:name "The Fool")))))

(ert-deftest tarot-test-meanings-for-every-standard-card ()
  "There is a tarot-card-meaning for every standard card."
  (dolist (card tarot-deck)
    (dolist (orient '(:upright :reversed))
      (should (tarot-card-meaning (plist-put (copy-sequence card)
					     :orientation orient))))))

;;; Iteration 9 - Tarot buffer mode --------------------------------------------

(ert-deftest tarot-test-tarot-mode-exists ()
  "We have a tarot buffer mode."
  (with-temp-buffer
    (tarot-mode)
    (should (derived-mode-p 'special-mode))))

(ert-deftest tarot-test-reading-opens-tarot-buffer ()
  "Calling tarot-reading brings up a new dedicated tarot reading buffer."
  (unwind-protect
      (progn
	(tarot-reading)
	(let ((buffer (get-buffer "*tarot*")))
	  (should buffer)
	  (with-current-buffer buffer
	    (should (derived-mode-p 'tarot-mode))
	    (should (string-match-p "The Fool" (buffer-string))))))
    (when (get-buffer "*tarot*")
      (kill-buffer "*tarot*"))))

(provide 'tarot-test)
;;; tarot-test.el ends here
