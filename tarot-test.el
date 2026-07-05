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
  (should (equal (car (tarot-draw tarot-deck 3))
		 (take 3 tarot-deck)))
  (should (equal (car (tarot-draw '() 5))
		 '())))

(ert-deftest tarot-test-draw-count ()
  "The number of cards drawn and left is the same as the total deck number."
  (seq-let (drawn remaining) (tarot-draw tarot-deck 5)
    (should (= (length drawn) 5))
    (should (= (length remaining) (- (length tarot-deck) 5)))))

(ert-deftest tarot-test-draw-splits-deck ()
  "The cards in the drawn and remaining piles make up the entire deck."
  (seq-let (drawn remaining) (tarot-draw tarot-deck 5)
    (should (equal (append drawn remaining)
		   tarot-deck))))


(provide 'tarot-test)
;;; tarot-test.el ends here
