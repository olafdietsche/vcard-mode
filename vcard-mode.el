;;; vcard-mode.el --- Major mode for vCard files.

;; Copyright (C) 2012 Desmond O. Chang

;; Author: Desmond O. Chang <dochang@gmail.com>
;; Version: 0.1.0
;; Keywords: files

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

;; This package provides a major mode to edit vCard files.

;; To install it, put this file under your load path.  Then add the
;; following to your .emacs file:

;;  (require 'vcard-mode)

;; Or if you don't want to load it until editing a vCard file:

;;  (autoload 'vcard-mode "vcard-mode" "Major mode for vCard files" t)
;;  (add-to-list 'auto-mode-alist '("\\.vc\\(f\\|ard\\)\\'" . vcard-mode))

;;; Code:

(require 'generic)

(defun vcard-mode-init ()
  (set (make-local-variable 'paragraph-start) "BEGIN:VCARD"))

(defun vcard-lookup-coding-system ()
  "Look for a 'CHARSET=' attribute, and return the corresponding `coding-system'.
Return nil if none is found."
  (save-excursion
    (let ((end (line-end-position)))
      (beginning-of-line)
      (if (re-search-forward ";CHARSET=\\(.*?\\)[;:]" end t)
          (coding-system-from-name (match-string 1))))))

(defun vcard-decode-buffer ()
  "Decode property values, if attribute 'ENCODING=QUOTED-PRINTABLE' is defined.
Maybe used in `vcard-mode-hook'"
  (save-excursion
    (goto-char (point-min))
    (while (search-forward ";ENCODING=QUOTED-PRINTABLE" nil t)
      (let* ((end (line-end-position))
             (start (search-forward ":" end t))
             (charset (vcard-lookup-coding-system)))
        (quoted-printable-decode-region start end)
        (if charset
            (decode-coding-region start end charset))))))

(defun vcard-encode-buffer ()
  (interactive)
  "Encode property values, if attribute 'ENCODING=QUOTED-PRINTABLE' is defined."
  (save-excursion
    (goto-char (point-min))
    (while (search-forward ";ENCODING=QUOTED-PRINTABLE" nil t)
      (let* ((end (line-end-position))
             (start (search-forward ":" end t))
             (charset (vcard-lookup-coding-system)))
        (if charset
            (encode-coding-region start end charset))
        (quoted-printable-encode-region start end))))
  nil)

;;;###autoload
(define-generic-mode vcard-mode
  '()
  nil
  '(("^BEGIN:VCARD" . font-lock-function-name-face)
    (";[^:\n]+:" . font-lock-type-face)
    ("^\\([^;:\n]+\\):?" . font-lock-keyword-face))
  '("\\.\\(vcf\\|vcard\\)\\'")
  '(vcard-mode-init)
  "Generic mode for vCard files.")

(defcustom vcard-mode-hook nil
  "*Hook called by `vcard-mode'."
  :type 'hook
  :group 'vcard)

(provide 'vcard-mode)

;;; vcard-mode.el ends here
