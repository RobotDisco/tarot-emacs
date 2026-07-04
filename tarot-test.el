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

(provide 'tarot-test)
;;; tarot-test.el ends here
