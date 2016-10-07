;;; test-error-list.el --- Flycheck Specs: Error List  -*- lexical-binding: t; -*-

;; Copyright (C) 2016 fmdkdd

;; Author: fmdkdd <fmdkdd@gmail.com>

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

;; Integration tests for `flycheck-rust-setup'.

;;; Code:

(require 'flycheck-rust)

(defun crate-file (file-name)
  (expand-file-name file-name "tests/test-crate"))

(describe
 "`flycheck-rust-find-target' associates"

 (it "'src/lib.rs' to the library target"
     (expect
      (car (flycheck-rust-find-target (crate-file "src/lib.rs")))
      :to-equal "lib"))

 (it "'src/a.rs' to the library target"
     (expect
      (car (flycheck-rust-find-target (crate-file "src/a.rs")))
      :to-equal "lib"))

 (it "'src/main.rs' to the main binary target"
     (expect
      (flycheck-rust-find-target (crate-file "src/main.rs"))
      :to-equal '("bin" . "test-crate")))

 (it "'src/bin/a.rs' to the 'a' binary target"
     (expect
      (flycheck-rust-find-target (crate-file "src/bin/a.rs"))
      :to-equal '("bin" . "a")))

 (it "'src/bin/support/a.rs' to the 'a' binary target"
     (expect
      (flycheck-rust-find-target (crate-file "src/bin/support/a.rs"))
      :to-equal '("bin" . "a")))

 (it "'tests/a.rs' to the 'a' test target"
     (expect
      (flycheck-rust-find-target (crate-file "tests/a.rs"))
      :to-equal '("test" . "a")))

 (it "'tests/support/a.rs' to the 'a' test target"
     (expect
      (flycheck-rust-find-target (crate-file "tests/support/a.rs"))
      :to-equal '("test" . "a")))

 (it "'examples/a.rs' to the 'a' example target"
     (expect
      (flycheck-rust-find-target (crate-file "examples/a.rs"))
      :to-equal '("example" . "a")))

 (it "'examples/support/a.rs' to the 'a' example target"
     (expect
      (flycheck-rust-find-target (crate-file "examples/support/a.rs"))
      :to-equal '("example" . "a")))

 (it "'benches/a.rs' to the 'a' bench target"
     (expect
      (flycheck-rust-find-target (crate-file "benches/a.rs"))
      :to-equal '("bench" . "a")))

 (it "'benches/support/a.rs' to the 'a' bench target"
     (expect
      (flycheck-rust-find-target (crate-file "benches/support/a.rs"))
      :to-equal '("bench" . "a")))


 )
