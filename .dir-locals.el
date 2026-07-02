((emacs-lisp-mode . ((eval . (progn
			       (defun tarot-emacs/test ()
				 (require 'ert)
				 (load-file "tarot.el")
				 (load-file "tarot-test.el")
				 (save-selected-window
				   (ert-run-tests-interactively t)))
			       (add-hook 'after-save-hook #'tarot-emacs/test nil t))))))
