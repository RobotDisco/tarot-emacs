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
    (seq-let (reading remaining) (tarot-draw-reading tarot-deck
						     spread
						     #'identity)
      (should (= (length remaining) 0))
      (let ((rcards (mapcar #'cdr reading)))
	(should (equal rcards (cl-remove-duplicates rcards :test #'equal)))))))

(ert-deftest tarot-test-draw-reading-too-many-cards ()
  "Drawing too many cards returns nil reading."
  (let ((spread '("pos1" "pos2" "pos3" "pos4" "pos5" "pos6" "pos7" "pos8"))
	(cards '(one two three four five)))
    (seq-let (reading _) (tarot-draw-reading cards spread #'identity)
      (should-not reading))))

(ert-deftest tarot-test-spread-get-by-name ()
  "`tarot-spreads-get' performs a name lookup from `tarot-spreads'."
  (let ((tarot-spreads '(("Three Card" . ("Past" "Present" "Future"))
			 ("One Card" . ("Card")))))
    (should
     (equal (tarot-spreads-get "Three Card") '("Past" "Present" "Future")))))

(ert-deftest tarot-test-spread-nonexistent-name ()
  "`tarot-spreads-get' returns nil when name isn't found in `tarot-spreads'."
  (let ((tarot-spreads '(("Three Card" . ("Past" "Present" "Future")))))
    (should-not (tarot-spreads-get "Non-existent spread"))))

;;; Iteration 8 - Card Meanings ------------------------------------------------

(ert-deftest tarot-test-meaning ()
  "Test fetching card meanings by card name."
  (let ((tarot-meanings
	 '(("The Fool" . (:upright "something" :reversed "rsomething"))
	   ("Five of Wands" . (:upright "something" :reversed "rsomething")))))
    (should (string-equal
	     (tarot-card-meaning '(:name "The Fool" :orientation :upright))
	     "something"))
    (should (string-equal
	     (tarot-card-meaning '(:name "The Fool" :orientation :reversed))
	     "rsomething"))
    (should (string-equal
	     (tarot-card-meaning '(:name "Five of Wands" :orientation :upright))
	     "something"))
    (should (string-equal
	     (tarot-card-meaning '(:name "Five of Wands" :orientation :reversed))
	     "rsomething"))
    (should-not (tarot-card-meaning
		 '(:name "Fifty-eight of Guitars" :orientation :upright)))))

(ert-deftest tarot-test-meaning-suppressed-reversed-orientation ()
  "Test fetching card meanings when reversed orientations are suppressed."
  (let ((tarot-show-reversed-orientation nil)
	(tarot-meanings
	 '(("The Fool" . (:upright "something" :reversed "rsomething")))))
    (should (string-equal (tarot-card-meaning
			   '(:name "The Fool" :orientation :upright))
			  "something"))
    (should (string-equal (tarot-card-meaning
			   '(:name "The Fool" :orientation :reversed))
			  "something"))))

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
  (cl-letf (((symbol-function 'completing-read) (lambda (&rest _)
						  "Celtic Cross")))
    (unwind-protect
	(progn
	  (tarot-reading)
	  (let ((buffer (get-buffer "*tarot*")))
	    ;; We should have a buffer named "*tarot*"
	    (should buffer)
	    (with-current-buffer buffer
	      ;; "*tarot* buffer should be using our tarot major mode.
	      (should (derived-mode-p 'tarot-mode)))))
      (when (get-buffer "*tarot*")
	(kill-buffer "*tarot*")))))

;;; Iteration 11 - Tarot UI rendering ------------------------------------------

(defun tarot-test--render-helper (assertions-fn &optional start-idx)
  "Set up fixtures for `tarot--render'.

Supply closure ASSERTIONS-FN that executes test assertions.
START-IDX sets focused card position, zero-indexed."
  (let ((tarot-meanings
	 '(("The Fool" :upright "New beginnings, spontaneity")
	   ("Five of Swords"
	    :upright "Hollow victory, costly conflict"
	    :reversed "Reckoning with the cost")
	   ("Wheel of Fortune" :upright "Positive change, accepting change"))))
    (with-temp-buffer
      (setq-local tarot--reading
		  '(("First" . (:name "The Fool" :orientation :upright))
		    ("Second" . (:name "Five of Swords" :orientation :reversed))
		    ("Third" . (:name "Wheel of Fortune" :orientation :upright)))
		  tarot--position-index (or start-idx 1))
      (tarot--render)
      (funcall assertions-fn))))

(ert-deftest tarot-test--render-spread-positions ()
  "Tarot--render displays spread position names."
  (tarot-test--render-helper
   (lambda ()
     (should (string-match-p "First" (buffer-string)))
     (should (string-match-p "Second" (buffer-string)))
     (should (string-match-p "Third" (buffer-string))))))

(ert-deftest tarot-test--render-card-names ()
  "Tarot--render displays card names."
  (tarot-test--render-helper
   (lambda ()
     (should (string-match-p "The Fool" (buffer-string)))
     (should (string-match-p "Five of Swords" (buffer-string)))
     (should (string-match-p "Wheel of Fortune" (buffer-string))))))

(ert-deftest tarot-test--render-spread-position-face ()
  "Correct faces should be rendered by tarot--render."
  (tarot-test--render-helper
   (lambda ()
     (dolist (posstr '("First" "Second" "Third"))
       (goto-char (point-min))
       (search-forward posstr)
       (should (eq (get-text-property (match-beginning 0) 'face)
		   'tarot-spread-position-face))))))

(ert-deftest tarot-test--render-card-name-faces ()
  "Correct faces should be rendered by tarot--render."
  (tarot-test--render-helper
   (lambda ()
     (dolist (cardname '("The Fool" "Wheel of Fortune"))
       (goto-char (point-min))
       (search-forward cardname)
       (should (eq (get-text-property (match-beginning 0) 'face)
		   'tarot-major-arcana-face)))
     (dolist (cardname '("Five of Swords"))
       (goto-char (point-min))
       (search-forward cardname)
       (should (eq (get-text-property (match-beginning 0) 'face)
		   'tarot-minor-arcana-face))))))

(ert-deftest tarot-test--render-card-upright-orientation-face ()
  "Correct faces should be rendered by tarot--render."
  (tarot-test--render-helper
   (lambda ()
     (goto-char (point-min))
     (while (search-forward "Upright" nil t)
       (should (eq (get-text-property (match-beginning 0) 'face)
		   'tarot-upright-orientation-face))))))

(ert-deftest tarot-test--render-card-reversed-orientation-face ()
  "Correct faces should be rendered by tarot--render."
  (tarot-test--render-helper
   (lambda ()
     (goto-char (point-min))
     (while (search-forward "Reversed" nil t)
       (should (eq (get-text-property (match-beginning 0) 'face)
		   'tarot-reversed-orientation-face))))))


;;; Iteration 11.5 - Tarot card functions needed for UI ------------------------

(ert-deftest tarot-test-card-orientation-string ()
  "Return friendly string for a card's orientation keyword."
  (should (string-equal (tarot-card-orientation-string
			 '(:name "The Fool" :orientation :upright))
			"Upright"))
  (should (string-equal (tarot-card-orientation-string
			 '(:name "The Fool" :orientation :reversed))
			"Reversed")))

(ert-deftest tarot-test-card-orientation-string-reversed-suppressed ()
  "Return friendly string for a card's orientation with reversed suppressed."
  (let ((tarot-show-reversed-orientation nil))
    (should (string-equal (tarot-card-orientation-string
			   '(:name "The Fool" :orientation :upright))
			  "Upright"))
    (should (string-equal (tarot-card-orientation-string
			   '(:name "The Fool" :orientation :reversed))
			  "Upright"))))

(ert-deftest tarot-test-card-orientation-face ()
  "Return the face for a card's orientation keyword."
  (should (eq (tarot-card-orientation-face
	       '(:name "The Fool" :orientation :upright))
	      'tarot-upright-orientation-face))
  (should (eq (tarot-card-orientation-face
	       '(:name "The Fool" :orientation :reversed))
	      'tarot-reversed-orientation-face)))

(ert-deftest tarot-test-card-orientation-face-reversed-suppressed ()
  "Return the face for a card's orientation with reversed suppressed."
  (let ((tarot-show-reversed-orientation nil))
    (should (eq (tarot-card-orientation-face
		 '(:name "The Fool" :orientation :upright))
		'tarot-upright-orientation-face))
    (should (eq (tarot-card-orientation-face
		 '(:name "The Fool" :orientation :reversed))
		'tarot-upright-orientation-face))))

(ert-deftest tarot-test-major-arcana-p ()
  "Determine whether a card is a major arcana card."
  (should (tarot-major-arcana-p '(:name "The Fool")))
  (should (tarot-major-arcana-p '(:name "Judgement" :orientation :upright)))
  (should-not (tarot-major-arcana-p '(:name "Five of Pentacles")))
  (should-not (tarot-major-arcana-p
	       '(:name "King of Cups" :orientation :reversed))))

(ert-deftest tarot-test-minor-arcana-p ()
  "Determine whether a card is a minor arcana card."
  (should (tarot-minor-arcana-p '(:name "Five of Pentacles")))
  (should (tarot-minor-arcana-p
	   '(:name "King of Cups" :orientation :reversed)))
  (should-not (tarot-minor-arcana-p '(:name "The Fool")))
  (should-not (tarot-minor-arcana-p
	       '(:name "Judgement" :orientation :upright))))


;;; Iteration 12 - Cycling between focused cards -------------------------------

(ert-deftest tarot-test-next-card-advances-focused-card ()
  "Test advancing card focus."
  (tarot-test--render-helper
   (lambda ()
     (should (= tarot--position-index 0))
     (should (string-match-p (regexp-quote "New beginnings, spontaneity")
			     (buffer-string)))
     (should-not (string-match-p (regexp-quote "Reckoning with the cost")
				 (buffer-string)))
     (should-not (string-match-p (regexp-quote
				  "Positive change, accepting change")
				 (buffer-string)))

     (tarot-next-card)

     (should (= tarot--position-index 1))
     (should-not (string-match-p (regexp-quote "New beginnings, spontaneity")
				 (buffer-string)))
     (should (string-match-p (regexp-quote "Reckoning with the cost")
			     (buffer-string)))
     (should-not (string-match-p (regexp-quote
				  "Positive change, accepting change")
				 (buffer-string))))
   0))

(ert-deftest tarot-test-previous-card-rewinds-focused-card ()
  "Test rewinding card focus."
  (tarot-test--render-helper
   (lambda ()
     (should (= tarot--position-index 2))
     (should-not (string-match-p (regexp-quote "New beginnings, spontaneity")
				 (buffer-string)))
     (should-not (string-match-p (regexp-quote "Reckoning with the cost")
				 (buffer-string)))
     (should (string-match-p (regexp-quote "Positive change, accepting change")
			     (buffer-string)))

     (tarot-prev-card)

     (should (= tarot--position-index 1))
     (should-not (string-match-p (regexp-quote "New beginnings, spontaneity")
				 (buffer-string)))
     (should (string-match-p (regexp-quote "Reckoning with the cost")
			     (buffer-string)))
     (should-not (string-match-p (regexp-quote "Positive change, accepting change")
				 (buffer-string))))
   2))

(ert-deftest tarot-test-next-previous-card-wraps-around-spread-sequence ()
  "Test wrapping focused card across end and beginning of spread positions."
  (tarot-test--render-helper
   (lambda ()
     (should (= tarot--position-index 2))
     (tarot-next-card)
     (should (= tarot--position-index 0))
     (tarot-prev-card)
     (should (= tarot--position-index 2)))
   2))

(ert-deftest tarot-test-keybinding-for-card-focus-cycling ()
  "Test keybindings for UI card focus cycling."
  (should (eq (lookup-key tarot-mode-map (kbd "n")) #'tarot-next-card))
  (should (eq (lookup-key tarot-mode-map (kbd "p")) #'tarot-prev-card)))


;;; Iteration 13 - Tarot card meanings displayed in UI -------------------------

(ert-deftest tarot-test--render-card-meaning-for-selected-position ()
  "Only display tarot card meaning for the selected position in tarot--render."
  (tarot-test--render-helper
   (lambda ()
     (should-not (string-match-p (regexp-quote "New beginnings, spontaneity")
				 (buffer-string)))
     (should (string-match-p (regexp-quote "Reckoning with the cost")
			     (buffer-string)))
     (should-not (string-match-p (regexp-quote
				  "Positive change, accepting change")
				 (buffer-string))))))


;;; Iteration 14 - Optionally suppress reversed card orientation ---------------

(ert-deftest tarot-test--render-card-meaning-face ()
  "Correct faces should be rendered by tarot--render."
  (tarot-test--render-helper
   (lambda ()
     ;; Should find reversed meaning for focused card.
     (goto-char (point-min))
     (search-forward "Reckoning with the cost")
     (should (eq (get-text-property (match-beginning 0) 'face)
		 'tarot-meaning-face))
     ;; Should not find upright meaning for focused card.
     (goto-char (point-min))
     (should-error (search-forward "Hollow victory, costly conflict")))))

(ert-deftest tarot-test-we-can-suppress-reversed-orientation ()
  "We can suppress reversed orientations using tarot-show-reversed-orientation."
  (let ((tarot-show-reversed-orientation nil))
    (tarot-test--render-helper
     (lambda ()
       ;; Should find upright meaning for focused card.
       (goto-char (point-min))
       (search-forward "Hollow victory, costly conflict")
       (should (eq (get-text-property (match-beginning 0) 'face)
		   'tarot-meaning-face))
       ;; Should not find reversed meaning for focused card.
       (goto-char (point-min))
       (should-error (search-forward "Reckoning with the cost"))
       (goto-char (point-min))
       (should-error (search-forward "Reversed"))))))

(ert-deftest tarot-test-show-reversed-orientation-if-set ()
  "Show reversed orientations if customisation value enabled."
  (let ((tarot-show-reversed-orientation t))
    (should (eq (tarot--card-display-orientation
		 '(:name "The Fool" :orientation :upright))
		:upright))
    (should (eq (tarot--card-display-orientation
		 '(:name "The Fool" :orientation :reversed))
		:reversed))
    (should-not (tarot--card-display-orientation '(:name "The Fool")))))

(ert-deftest tarot-test-dont-show-reversed-orientation-if-unset ()
  "Don't show reversed orientation if customisation value disabled."
  (let ((tarot-show-reversed-orientation nil))
    (should (eq (tarot--card-display-orientation
		 '(:name "The Fool" :orientation :upright))
		:upright))
    (should (eq (tarot--card-display-orientation
		 '(:name "The Fool" :orientation :reversed))
		:upright))
    (should-not (tarot--card-display-orientation '(:name "The Fool")))))

;;; Iteration 15 - Wire tarot--render to tarot-reading -------------------------

(ert-deftest tarot-test-reading-lists-drawn-cards-in-order ()
  "Calling tarot-reading lays down cards in order of drawing."

  ;; Disable the use of reversed cards, because it makes testing deterministic.
  (let ((tarot-show-reversed-orientation nil))
    (cl-letf (((symbol-function 'tarot-shuffle) #'identity)
	      ((symbol-function 'completing-read) (lambda (&rest _)
						    "Celtic Cross")))
      (unwind-protect
	  (progn
	    (tarot-reading)
	    (let ((buffer (get-buffer "*tarot*")))
	      (with-current-buffer buffer
		(goto-char (point-min))
		(should (search-forward "The Fool"))
		(should (search-forward "The Magician"))
		(should (search-forward "The High Priestess")))))
	(when (get-buffer "*tarot*")
	  (kill-buffer "*tarot*"))))))

(ert-deftest tarot-test-reading-calls-tarot-shuffle ()
  "Calling tarot-reading shuffles the deck."

  ;; Disable the use of reversed cards, because it makes testing deterministic.
  (let ((tarot-show-reversed-orientation nil)
	(tarot-shuffle-called nil))
    (cl-letf (((symbol-function 'tarot-shuffle)
	       (lambda (x)
		 (setq tarot-shuffle-called t)
		 x))
	      ((symbol-function 'completing-read) (lambda (&rest _)
						    "Celtic Cross")))
      (unwind-protect
	  (progn
	    (tarot-reading)
	    (should tarot-shuffle-called))
	(when (get-buffer "*tarot*")
	  (kill-buffer "*tarot*"))))))

(ert-deftest tarot-test-reading-can-be-passed-a-different-spread ()
  "Calling tarot-reading can be supplied a different prompt via prompt."

  (cl-letf (((symbol-function 'completing-read) (lambda (&rest _)
						  "Celtic Cross")))
    (unwind-protect
	(progn
	  (tarot-reading)
	  (with-current-buffer "*tarot*"
	    (should (= (length tarot--reading)
		       (length (tarot-spreads-get "Celtic Cross"))))))
      (when (get-buffer "*tarot*")
	(kill-buffer "*tarot*")))))

(provide 'tarot-test)
;;; tarot-test.el ends here
