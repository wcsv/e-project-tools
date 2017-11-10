;; EProjectTools.el is part of e-project-tools
;; Copyright (C) 2017 wcsv.

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.


;; To use this file place it in a known location on your computer and
;; run M-x load-file <path-to-this-file> from within Emacs, or load
;; it from your .emacs file.

;;This file is NOT part of Emacs


;;;;;;;;;;;;;;;;;;;;
;; VARIABLES
;;;;;;;;;;;;;;;;;;;;

;; string representing the root directory path for the active project
;; defaults to the directory where this file is located
(defvar ept-root-dir (file-name-directory load-file-name))

;; string representation of the file filter regex used when loading project files
;; defaults to .c and .h files
(defvar ept-file-filter-regex "^.*\\.[ch]$")

;; string representation of the glob used to filter project files where
;; a glob is required rather than a regex
;; defaults to c and h files
(defvar ept-file-filter-glob "*.[ch]")

;; list of filename strings representing the files that are part of this project
(defvar ept-file-names-list '())


;;;;;;;;;;;;;;;;;;;;
;; FUNCTIONS
;;;;;;;;;;;;;;;;;;;;

;; NAME:     ept-set-project-root (rootDir)
;; INPUTS:   rootDir - string representing the new root directory for the project
;; OUTPUTS:  None
;; INFO:     function that sets the working directory to the supplied value
;;           via user interaction.
(defun ept-set-project-root (rootDir)
  (interactive "DRoot Directory: ")
  ;;remove the trailing slash as this seems to cause grep -r to choke
  (setq ept-root-dir (replace-regexp-in-string "[/\\]$" "" rootDir))
  (print (concat "Set project root at " ept-root-dir))
  (ept-load-project-files))

;; NAME:     ept-load-project-files ()
;; INPUTS:   None
;; OUTPUTS:  None
;; INFO:     function that loads the files list from the project root directory
;;           and all subdirectories. Files that match ept-file-filter-regex are
;;           added to the list
(defun ept-load-project-files ()
  (interactive)
  (setq ept-file-names-list (directory-files-recursively ept-root-dir ept-file-filter-regex)))

;; NAME:     ept-tag-project ()
;; INPUTS:   None
;; OUTPUTS:  None
;; INFO:     function that tags the project based at the current root directory
(defun ept-tag-project ()
  (interactive)
  (let (tagCmdStr) 
    (dolist (item ept-file-names-list tagCmdStr) (setq tagCmdStr (concat tagCmdStr " " item)))
    (setq tagCmdStr (concat "etags -l auto -o " (concat ept-root-dir "/TAGS") tagCmdStr))
    (shell-command tagCmdStr)
    (get-buffer-create "*Project Tagging Ouput*") t
    (visit-tags-table ept-root-dir)))

;; NAME:     ept-list-project-files ()
;; INPUTS:   None
;; OUTPUTS:  None
;; INFO:     function that lists the current project's files in a buffer
;(defun ept-list-project-files ()
;  (interactive)
;  (save-excursion
;    (pop-to-buffer (get-buffer-create "*test file list*") t)
;    (compilation-mode)
;    (dolist (item ept-file-names-list) (insert item))))
  
;; NAME:     ept-search-in-project (str)
;; INPUTS:   str - the string (or regex) to find within the project files
;; OUTPUTS:  None
;; INFO:     search with grep within the project files
(defun ept-search-in-project (str)
  (interactive "sFind Regex: ")
  (let (grepCmdStr)
    (grep-compute-defaults)
    (setq grepCmdStr (replace-regexp-in-string "^grep " (concat "grep -r --include=" ept-file-filter-glob " ") grep-command))
    (setq grepCmdStr (concat grepCmdStr " \"" str "\" " ept-root-dir ""))
    (grep grepCmdStr)))
    
