;;; tarot.el --- Tarot card readings in Emacs -*- lexical-binding: t; -*-

;; Copyright (C) 2026 Gaelan D'costa
;; Author: Gaelan D'costa <gaelan@fastmail.ca>
;; Version: 0.0.1
;; Package-Requires: ((emacs "26.1"))
;; Keywords: games
;; SPDX-License-Identifier: GPL-3.0-or-later

;; This file is NOT part of GNU Emacs.

;;; Commentary:
;; A tarot card reader for Emacs.

;;; Code:
(require 'cl-lib)
(require 'seq)
(require 'subr-x)

(require 'tarot-meanings)


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
				   collect (list :name (format "%s of %s"
							       rank
							       suit)))))
  "Non-shuffled tarot deck.")


;;; Tarot customizations -------------------------------------------------------

(defgroup tarot nil
  "Customisation variables for tarot reading." :group 'games)

(defcustom tarot-spreads
  '(("Three Card" . ("Past" "Present" "Future"))
    ("Celtic Cross" . ("Present"
		       "Challenge"
		       "Past"
		       "Future"
		       "Conscious"
		       "Unconscious"
		       "Self-perception"
		       "External Influences"
		       "Hopes & Fears"
		       "Outcome")))
  "Alist where the car is the spread name, the cdr a list of position strings."
  :group 'tarot
  :type '(alist :key-type string :value-type (repeat string)))

(defcustom tarot-show-reversed-orientation
  t
  "Non-nil means show a card's true reversed orientation and meaning.

When nil, reversed cards are suppressed and always displayed as upright."
  :group 'tarot
  :type 'boolean)

(defface tarot-spread-position-face
  '((t . (:inherit font-lock-function-name-face)))
  "Face for tarot spread positions." :group 'tarot)

(defface tarot-major-arcana-face
  '((t . (:inherit font-lock-variable-name-face :weight bold)))
  "Face for tarot major arcana." :group 'tarot)

(defface tarot-minor-arcana-face
  '((t . (:inherit font-lock-variable-name-face)))
  "Face for tarot minor arcana." :group 'tarot)

(defface tarot-meaning-face
  '((t . (:inherit font-lock-string-face :box t)))
  "Face for tarot card meanings." :group 'tarot)

(defface tarot-upright-orientation-face
  '((t . ()))
  "Face to indicate this card was placed in upright orientation." :group 'tarot)

(defface tarot-reversed-orientation-face
  '((t . (:slant italic)))
  "Face to indicate this card was placed in reverse orientation." :group 'tarot)


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

If the deck has enough cards, returns a two-element list:
1. A list of cards drawn from the deck.
2. A list of cards remaining in the deck.

If the deck has less cards than the draw requests, return:
1. An empty list.
2. The list of remaining cards, unmodified.

Apply DRAW-FN to each drawn card if supplied.  Otherwise, apply
`tarot--card-orient'."
  (if (< (length deck) count)
      (cons nil (list deck))
    (let ((f (or draw-fn #'tarot--card-orient)))
      (cons (mapcar f (seq-take deck count))
	    (list (seq-drop deck count))))))

(defun tarot-card-orientation (card)
  "Return card orientation for CARD.

Values are either :upright or :reversed"
  (plist-get card :orientation))

(defun tarot-card-orientation-string (card)
  "Return friendly string for drawn CARD orientation."
  (let ((symbol (tarot--card-display-orientation card)))
    (pcase symbol
      (:upright "Upright")
      (:reversed "Reversed"))))

(defun tarot-card-orientation-face (card)
  "Return the face for drawn CARD orientation."
  (pcase (tarot--card-display-orientation card)
    (:upright 'tarot-upright-orientation-face)
    (:reversed 'tarot-reversed-orientation-face)))

(defun tarot--card-orient (card)
  "Assign random orientation to CARD and return a modified copy.

This is the default function applied by `tarot-draw'."
  (plist-put (copy-sequence card) :orientation (if (zerop (cl-random 2))
						   :upright
						 :reversed)))

(defun tarot-draw-reading (deck spread &optional draw-fn)
  "Given a DECK of cards and a SPREAD of positions, return a reading.

A reading is an alist where the car is the position key and the cdr is the card
drawn in that position.

If DRAW-FN is supplied, it is applied to every card that is drawn before
inserting into the spread mapping instead of the default drawing function."
  (seq-let (drawn remaining) (tarot-draw deck (length spread) draw-fn)
    (cons (cl-mapcar #'cons spread drawn)
	  (list remaining))))

(defun tarot-spreads-get (name)
  "Fetch spread from `tarot-spreads' by NAME.  Return nil if non-existent."
  (alist-get name tarot-spreads nil nil #'string-equal))

(defun tarot-card-meaning (card)
  "Retrieve the meaning for a drawn CARD.

A prerequisite of this function is that the card has an assigned orientation."
  (let ((cname (tarot-card-name card))
	(corient (tarot--card-display-orientation card)))
    (unless corient
      (error ":orientation property required, %S provided" card))
    (plist-get (alist-get cname tarot-meanings nil nil #'string-equal)
	       corient)))

(defun tarot-major-arcana-p (card)
  "Determine whether CARD is a major arcana card."
  (cl-member card tarot-major-arcana
	     :test (lambda (x y)
		     (string-equal (tarot-card-name x)
				   (tarot-card-name y)))))

(defun tarot-minor-arcana-p (card)
  "Determine whether CARD is a minor arcana card."
  (not (tarot-major-arcana-p card)))


;;; Tarot UI mode --------------------------------------------------------------

(defconst tarot-buffer-name "*tarot*"
  "Standard buffer name where tarot card readings are placed.")

(defvar-local tarot--reading nil
  "Tarot reading for local buffer.")

(defvar-local tarot--position-index nil
  "Currently selected tarot card in local buffer.

Used to display card meaning.")

(define-derived-mode tarot-mode special-mode "Tarot"
  "Major mode for tarot card readings.")

(define-key tarot-mode-map (kbd "p") #'tarot-prev-card)
(define-key tarot-mode-map (kbd "n") #'tarot-next-card)

(defun tarot-reading ()
  "Perform a tarot reading."
  (interactive)
  (let ((spread (completing-read "Choose tarot spread: "
				 tarot-spreads
				 nil
				 t)))
    (with-current-buffer (get-buffer-create tarot-buffer-name)
      (tarot-mode)
      (setq-local tarot--reading (car (tarot-draw-reading
				       (tarot-shuffle tarot-deck)
				       (tarot-spreads-get spread))))
      (setq-local tarot--position-index 0)
      (tarot--render)
      (pop-to-buffer tarot-buffer-name))))

(defun tarot--render ()
  "Render a tarot reading into buffer.

Rendering is dependant on two variables that are buffer-local:
1. `tarot--reading' is the tarot reading generated for this specific buffer.
2. `tarot--position-index' is the currently selected card in the buffer.

The currently selected position renders the meaning of the associated card,
which is omitted from the other cards."
  (save-excursion
    (let ((inhibit-read-only t))
      (erase-buffer)
      (dolist (cur tarot--reading)
	(let ((spreadpos (car cur))
	      (spreadcard (cdr cur)))
	  (insert (propertize spreadpos 'face 'tarot-spread-position-face) "\n")
	  (insert "  " (propertize (tarot-card-name spreadcard) 'face
				   (if (tarot-major-arcana-p spreadcard)
				       'tarot-major-arcana-face
				     'tarot-minor-arcana-face)) "\n")
	  (insert "  "
		  (propertize (tarot-card-orientation-string spreadcard)
			      'face
			      (tarot-card-orientation-face spreadcard))
		  "\n")
	  (when (equal (cdr (nth tarot--position-index tarot--reading))
		       spreadcard)
	    (insert "\n" (propertize (tarot-card-meaning spreadcard)
				     'face 'tarot-meaning-face)
		    "\n"))
	  (insert "\n"))))))

(defun tarot--move-card-focus (move-fn)
  "Change focused card in the tarot reading UI buffer.

`tarot--position-index' is mutated by applying MOVE-FN to its current value then
accounting for wraparound in the available card positions in `tarot--reading'.

`tarot--render' is invoked afterwards to redraw the buffer."
  (setq-local tarot--position-index (mod (funcall move-fn tarot--position-index)
					 (length tarot--reading)))
  (tarot--render))

(defun tarot-next-card ()
  "Advance card focus in UI, with wraparound."
  (interactive)
  (tarot--move-card-focus #'1+))

(defun tarot-prev-card ()
  "Rewind card focus in UI, with wraparound."
  (interactive)
  (tarot--move-card-focus #'1-))

(defun tarot--card-display-orientation (card)
  "Orientation accessor for CARD, factoring in display suppression options.

If `tarot-show-reversed-orientation' is unset, return :upright in place of
:reversed orientation values."
  (if-let* ((orientation (tarot-card-orientation card)))
      (if tarot-show-reversed-orientation
	  orientation
	:upright)))


(provide 'tarot)
;;; tarot.el ends here
