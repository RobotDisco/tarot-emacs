((emacs-lisp-mode . ((eval . (progn
			       (defun tarot-emacs/test ()
				 (require 'ert)
				 (add-to-list 'load-path default-directory)
				 (load-file "./tarot-meanings.el")
				 (load-file "./tarot.el")
				 (load-file "./tarot-test.el")
				 (save-selected-window
				   (ert-run-tests-interactively t)))
			       (add-hook 'after-save-hook #'tarot-emacs/test nil t))))))
