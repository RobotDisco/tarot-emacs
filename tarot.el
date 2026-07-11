;;; tarot.el --- Tarot card readings in Emacs -*- lexical-binding: t; -*-

;; Copyright (C) 2026 Gaelan D'costa
;; Author: Gaelan D'costa <gaelan@fastmail.ca>
;; Version: 0.0.1
;; Package-Requires: ((emacs "29.1"))
;; Keywords: games
;; SPDX-License-Identifier: GPL-3.0-or-later

;; This file is NOT part of GNU Emacs.

;;; Commentary:
;; A tarot card reader for Emacs.

;;; Code:
(require 'cl-lib)


;;; Tarot card constants -------------------------------------------------------

(defconst tarot-major-arcana
  '((:name "The Fool")
    (:name "The Magician")
    (:name "The High Priestess")
    (:name "The Empress")
    (:name "The Emperor")
    (:name "The Hierophant")
    (:name "The Lovers")
    (:name "The Chariot")
    (:name "Strength")
    (:name "The Hermit")
    (:name "Wheel of Fortune")
    (:name "Justice")
    (:name "The Hanged Man")
    (:name "Death")
    (:name "Temperance")
    (:name "The Devil")
    (:name "The Tower")
    (:name "The Star")
    (:name "The Moon")
    (:name "The Sun")
    (:name "Judgement")
    (:name "The World"))
  "List of major arcana cards in a standard tarot deck.")

(defconst tarot-minor-ranks
  '("Ace"
    "Two"
    "Three"
    "Four"
    "Five"
    "Six"
    "Seven"
    "Eight"
    "Nine"
    "Ten"
    "Page"
    "Knight"
    "Queen"
    "King")
  "List of card ranks in the minor arcana of a standard tarot deck.")

(defconst tarot-minor-suits
  '("Cups"
    "Pentacles"
    "Swords"
    "Wands")
  "List of card suits in the minor arcana of a standard tarot deck.")

(defconst tarot-deck
  (append tarot-major-arcana
	  (cl-loop for suit in tarot-minor-suits
		   append (cl-loop for rank in tarot-minor-ranks
				   collect (list :name (format "%s of %s" rank suit)))))
  "Non-shuffled tarot deck.")


;;; Tarot card operations ------------------------------------------------------

(defun tarot-card-name (card)
  "Return the friendly name for CARD."
  (plist-get card :name))

(defun tarot-shuffle (deck)
  "Return shuffled copy of sequence DECK.

Uses Fisher-Yates algorithm for shuffling.

For more details, see https://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle#The_modern_algorithm"
  (let ((deck-vec (vconcat deck)))
    ;; "processed" random selections collect at end of vector.
    ;; No point randomly picking from 1 candidate, so we finish at pos 2.
    (dolist (ceiling (number-sequence (length deck) 2 -1))
      ;; Pick one entity from the unprocessed part of our sequence
      (let* ((rand-idx (random ceiling))
	     (rand-val (aref deck-vec rand-idx))
	     ;; Temp store the value just under the ceiling for when we swap it.
	     (ceil-val (aref deck-vec (1- ceiling))))
	;; Swap the picked value with the value just under the ceiling of
	;; unprocessed elements. The ceiling lowers to include this new pick
	;; next round.
	(setf (aref deck-vec rand-idx) ceil-val
	      (aref deck-vec (1- ceiling)) rand-val)))
    (cl-coerce deck-vec 'list)))

(defun tarot-draw (deck count &optional draw-fn)
  "Return the first COUNT cards from DECK, and remaining cards.

Returns a two-element list:
1. A list of cards drawn from the deck.
2. A list of cards remaining in the deck.

Apply DRAW-FN to each drawn card if supplied.  Otherwise, apply
`tarot--card-orient'."
  (let ((f (or draw-fn #'tarot--card-orient)))
    (list (mapcar f (take count deck))
	  (drop count deck))))

(defun tarot-card-orientation (card)
  "Return card orientation for CARD.

Values are either :upright or :reversed"
  (plist-get card :orientation))

(defun tarot--card-orient (card)
  "Assign random orientation to CARD and return a modified copy.

This is the default function applied by `tarot-draw'."
  (plist-put (copy-sequence card) :orientation (if (zerop (cl-random 2))
						   :upright
						 :reversed)))

(provide 'tarot)
;;; tarot.el ends here
