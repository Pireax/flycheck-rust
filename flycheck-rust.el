;;; flycheck-rust.el --- Flycheck: Rust additions and Cargo support  -*- lexical-binding: t; -*-

;; Copyright (C) 2014, 2015  Sebastian Wiesner <swiesner@lunaryorn.com>

;; Author: Sebastian Wiesner <swiesner@lunaryorn.com>
;; URL: https://github.com/flycheck/flycheck-rust
;; Keywords: tools, convenience
;; Version: 0.1-cvs
;; Package-Requires: ((emacs "24.1") (flycheck "0.20") (dash "2.13.0") (seq "2.15"))

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This Flycheck extension configures Flycheck automatically for the current
;; Cargo project.
;;
;; # Setup
;;
;;     (add-hook 'flycheck-mode-hook #'flycheck-rust-setup)
;;
;; # Usage
;;
;; Just use Flycheck as usual in your Rust/Cargo projects.

;;; Code:

(require 'dash)
(require 'flycheck)
(require 'seq)
(require 'json)

(defun flycheck-rust-find-target (file-name)
  "Find and return the cargo target associated with the given file.

FILE-NAME is the name of the file that is matched against the
`src_path' value in the list `targets' returned by `cargo
read-manifest'.  If there is no match, the first target is
returned by default.

Return a cons cell (TYPE . NAME), where TYPE is the target
type (lib or bin), and NAME the target name (usually, the crate
name)."
  (let ((json-array-type 'list))
    (-let [(&alist 'targets targets)
           (with-temp-buffer
             (call-process (funcall flycheck-executable-find "cargo") nil t nil "read-manifest")
             (goto-char (point-min))
             (json-read))]
      ;; If there is a target that matches the file-name exactly, pick that
      ;; one.  Otherwise, just pick the first target.
      (-let [(&alist 'kind (kind) 'name name)
             (seq-find (lambda (target)
                         (-let [(&alist 'src_path src_path) target]
                           (string= file-name src_path)))
                       targets (car targets))]
          (cons kind name)))))

;;;###autoload
(defun flycheck-rust-setup ()
  "Setup Rust in Flycheck.

If the current file is part of a Cargo project, configure
Flycheck according to the Cargo project layout."
  (interactive)
  (-when-let (filename (buffer-file-name))
    ;; We should avoid raising any error in this function, as in combination
    ;; with `global-flycheck-mode' it will render Emacs unusable (see
    ;; https://github.com/flycheck/flycheck-rust/issues/40#issuecomment-253760883).
    (if (not (funcall flycheck-executable-find "cargo"))
        ;; We can still inform the user though
        (message "flycheck-rust cannot find `cargo'.  Please \
make sure that cargo is installed and on your PATH.  See \
http://www.flycheck.org/en/latest/user/troubleshooting.html for \
more information on setting your PATH with Emacs.")

      (pcase-let ((`(,target-type . ,target-name)
                   (flycheck-rust-find-target filename)))
        (setq-local flycheck-rust-target-kind target-type)
        (setq-local flycheck-rust-target-name target-name)))))

(provide 'flycheck-rust)

;;; flycheck-rust.el ends here
