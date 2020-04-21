;;; epithet.el --- Rename buffers with descriptive names  -*- lexical-binding: t; -*-

;; Copyright (C) 2020  Omar Antolín Camarena

;; Author: Omar Antolín Camarena <omar@matem.unam.mx>
;; Keywords: convenience

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; This package provides a function `epithet-rename-buffer' to rename
;; the current buffer with a descriptive name.  The name suggestion is
;; governed by the `epithet-suggesters' hook variable: each hook
;; should return either a name suggestion or nil, they are called in
;; turn and the first non-nil suggestion is taken.
;;
;; There are currently suggestion functions for eww, info and help
;; buffers.  For eww there are two, in fact, one that suggests the
;; page title and one that suggests the URL (the title is the
;; default).
;;
;; The `epithet-rename-buffer' function can be called interactively or
;; added to appropriate hooks to rename automatically.  If called
;; interactively you can use the universal prefix argument to get a
;; prompt where you can choose a different name, and the suggested
;; name is available as the default value.

;;; Code:

(defun epithet-for-eww-title ()
  "Suggest a name for a `eww-mode' buffer."
  (when (derived-mode-p 'eww-mode)
    (format "*eww: %s*" (plist-get eww-data :title))))

(defun epithet-for-eww-url ()
  "Suggest a name for a `eww-mode' buffer."
  (when (derived-mode-p 'eww-mode)
    (format "*eww: %s*" (plist-get eww-data :url))))

(defun epithet-for-Info ()
  "Suggest a name for an `Info-mode' buffer."
  (when (derived-mode-p 'Info-mode)
    (format "*info (%s)%s*"
            (file-name-sans-extension
             (file-name-nondirectory Info-current-file))
            Info-current-node)))

(defun epithet-for-help ()
  "Suggest a name for a `help-mode' buffer."
  (when (derived-mode-p 'help-mode)
    (format "*Help: %s*" (car (last help-xref-stack-item 2))))) 

(defgroup eipthet nil "Rename buffers with descriptive names.")

(defcustom epithet-suggesters
  '(epithet-for-eww-title epithet-for-Info epithet-for-help)
  "List of functions to suggest a name for the current buffer.
Each function should either return a string suggestion or nil."
  :type 'hook
  :group epithet)

(defun epithet-suggestion ()
  "Suggest a descriptive name for current buffer.
Runs down the `epithet-suggesters' list and picks the first
non-nil suggestion."
  (run-hook-with-args-until-success 'epithet-suggesters))

;;;###autoload
(defun epithet-rename-buffer (&optional new-name)
  "Automatically give current buffer a descriptive name.
Called interactively with a universal prefix argument, prompt for
new name (using the suggestion as default value)."
  (interactive
   (list
    (let ((suggestion (epithet-suggestion)))
      (pcase current-prefix-arg
        ('(4) (read-string
               (if suggestion
                   (format "Rename buffer (default %s): " suggestion)
                 "Rename buffer: ")
               nil nil suggestion))
        (_ suggestion)))))
  (when new-name
    (rename-buffer new-name)))

(provide 'epithet)
;;; epithet.el ends here