;; -*- mode: Emacs-Lisp -*-
;; written by YoheiKakiuchi 2023.11.30

;; melpa
(when (require 'package nil t)
  (add-to-list 'package-archives
               '("melpa-stable" . "https://stable.melpa.org/packages/"))
  (add-to-list 'package-archives
               '("melpa" . "https://melpa.org/packages/") t)
  (package-initialize))
;;;; <<< package

(global-set-key "\C-h" 'backward-delete-char)
(global-set-key "\M-g" 'goto-line)
(global-set-key "\C-xL" 'goto-line)
(global-set-key "\C-xR" 'revert-buffer)
(global-set-key "\er" 'query-replace)

(global-unset-key "\C-o" )

(setq visible-bell t)

;;; When in Text mode, want to be in Auto-Fill mode.
;;;
;(defun my-auto-fill-mode nil (auto-fill-mode 1))
;(setq text-mode-hook 'my-auto-fill-mode)
;(setq mail-mode-hook 'my-auto-fill-mode)

;;; time
;;;
(load "time" t t)
(display-time)

;; (lookup)
;;
(setq lookup-search-agents '((ndtp "nfs")))
(define-key global-map "\C-co" 'lookup-pattern)
(define-key global-map "\C-cr" 'lookup-region)
(autoload 'lookup "lookup" "Online dictionary." t nil )

;; Japanese
;; uncommented by ueda. beacuse in shell buffer, they invokes mozibake
(set-language-environment 'Japanese)
(prefer-coding-system 'utf-8)
(setq enable-double-n-syntax t)

(setq use-kuten-for-period nil)
(setq use-touten-for-comma nil)

;; sudo apt-get install yc-el migemo
(when (require 'yc nil t)
  (load-library "yc"))
;; (when (require 'migemo nil t)
;;   (load "migemo"))

;;; Timestamp
;;;
(defun timestamp-insert ()
  (interactive)
  (insert (current-time-string))
  (backward-char))
(global-set-key "\C-c\C-d" 'timestamp-insert)

(global-font-lock-mode t)

;; M-n and M-p
(global-unset-key "\M-p")
(global-unset-key "\M-n")

(defun scroll-up-in-place (n)
       (interactive "p")
       (previous-line n)
       (scroll-down n))
(defun scroll-down-in-place (n)
       (interactive "p")
       (next-line n)
       (scroll-up n))

(global-set-key "\M-n" 'scroll-down-in-place)
(global-set-key "\M-p" 'scroll-up-in-place)

;; dabbrev
(global-set-key "\C-o" 'dabbrev-expand)

;;
(require 'paren)
(show-paren-mode 1)
;; show selection
(setq-default transient-mark-mode t)

;; ;; C-qで移動
(defun match-paren (arg)
  "Go to the matching parenthesis if on parenthesis."
  (interactive "p")
  (cond ((looking-at "\\s\(") (forward-list 1) (backward-char 1))
        ((looking-at "\\s\)") (forward-char 1) (backward-list 1))
        )
  )
;;(global-set-key "\C-Q" 'match-paren)

(font-lock-add-keywords 'lisp-mode
                        (list
                         (list "\\(\\*\\w\+\\*\\)\\>"
                               '(1 font-lock-constant-face nil t))
                         (list "\\(\\+\\w\+\\+\\)\\>"
                               '(1 font-lock-constant-face nil t))))

;; does not allow use hard tab.
(setq-default indent-tabs-mode nil)
;(setq-default indent-tabs-mode t)

;; ignore start message
(setq inhibit-startup-message t)

;; shell mode
(set-terminal-coding-system 'utf-8)
(set-buffer-file-coding-system 'utf-8)
(setq explicit-shell-file-name shell-file-name)
(setq shell-command-option "-c")
(setq system-uses-terminfo nil)
(setq shell-file-name-chars "~/A-Za-z0-9_^$!#%&{}@`'.,:()-")
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; White spaceを削除する関数
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun trim-buffer ()
  "Delete excess white space."
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward "[ \t]+$" nil t)
      (replace-match "" nil nil))
    (goto-char (point-max))
    (delete-blank-lines)
    (mark-whole-buffer)
    ;; (untabify (region-beginning) (region-end))
    ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(add-hook 'term-mode-hook
          (function
           (lambda ()
             ;; shell, ipython, python
             (setq term-prompt-regexp "\\(^In \[[0-9]+\]: *\\)\\|\\( *\.\.\.*: \\)\\|\\(^[\>\.]+ \\)\\|\\(^[^#$%>\n]*[#$%>] *\\)")
             ;;(setq term-prompt-regexp "^[^#$%>\n]*[#$%>] *")
             ;;(setq-local mouse-yank-at-point t)
             ;;(setq-local transient-mark-mode nil)
             (auto-fill-mode -1)
             (setq term-buffer-maximum-size 0) ;; num of buffer lines, 0 means unlimited
             (define-key term-mode-map "\C-c\C-v" 'trim-buffer)
             ;;(setq tab-width 8 )
             )))
;; for term-mode
(defun execute-selected-region ()
  (interactive)
  (let ((buf (get-buffer-create "*terminal*"))
        (str (buffer-substring-no-properties (region-beginning) (region-end)))
        )
    (with-current-buffer buf
      (insert str)
      (term-send-input)
      )))
(global-set-key "\C-ce" 'execute-selected-region)

;;(defun lisp-other-window ()
;;  "Run Lisp on other window"
;;  (interactive)
;;  (switch-to-buffer-other-window
;;   (get-buffer-create "*inferior-lisp*"))
;;  (run-lisp inferior-lisp-program))
;;(set-variable 'inferior-lisp-program "jskrbeusgl")
;;(global-set-key "\C-cE" 'lisp-other-window)

;; add color space,tab,zenkaku-space
(defface my-face-b-1 '((t (:background "gray"))) nil)
(defface my-face-b-2 '((t (:background "blue"))) nil)
(defface my-face-u-1 '((t (:background "red"))) nil)
(defvar my-face-b-1 'my-face-b-1)
(defvar my-face-b-2 'my-face-b-2)
(defvar my-face-u-1 'my-face-u-1)

(defadvice font-lock-mode (before my-font-lock-mode ())
  (font-lock-add-keywords
   major-mode
   '(
     ("\t" 0 my-face-b-1 append)
     ("　" 0 my-face-b-2 append)
     ("[ \t]+$" 0 my-face-u-1 append)
     )))
(ad-enable-advice 'font-lock-mode 'before 'my-font-lock-mode)
(ad-activate 'font-lock-mode)

(when nil
(set-foreground-color "white")
(set-background-color "black")
(set-scroll-bar-mode 'right)
(set-cursor-color "white")
)
;;
(line-number-mode t)
(column-number-mode t)

(when nil
;; stop auto scroll according to cursol
(setq comint-scroll-show-maximum-output nil)
)

(setq ring-bell-function 'ignore)
(setq auto-mode-alist (cons (cons "\\.launch$" 'xml-mode) auto-mode-alist))

;; ros-mode
;; sudo apt-get install rosemacs-el
;;(require 'rosemacs)
;;(invoke-rosemacs)
(add-to-list 'load-path "/opt/ros/kinetic/share/emacs/site-lisp")
(when (require 'rosemacs-config nil t)
  (invoke-rosemacs)
  (global-set-key "\C-x\C-r" ros-keymap))

;; vrml mode
(add-to-list 'load-path (format "%s/.emacs.d/vrml" (getenv "HOME")))
(when (file-exists-p (format "%s/.emacs.d/vrml/vrml-mode.el" (getenv "HOME")))
  (load "vrml-mode.el")
  (autoload 'vrml-mode "vrml" "VRML mode." t)
  (setq auto-mode-alist (append '(("\\.wrl\\'" . vrml-mode))
                                auto-mode-alist)))

;; matlab mode
(when (file-exists-p (format "%s/.emacs.d/matlab/matlab.el.1.10.1" (getenv "HOME")))
  (load "matlab/matlab.el.1.10.1" (getenv "HOME"))
  (setq auto-mode-alist (append '(("\\.m\\'" . matlab-mode))
                                auto-mode-alist)))

;; for Arduino
(setq auto-mode-alist (append '(("\\.pde\\'" . c++-mode))
                              auto-mode-alist))
(put 'downcase-region 'disabled nil)

;; yaml mode
(when (require 'yaml-mode nil t)
  (setq auto-mode-alist (append '(("\\.cnoid\\'" . yaml-mode))
                                auto-mode-alist))
  (setq auto-mode-alist (append '(("\\.body\\'" . yaml-mode))
                                auto-mode-alist))
  )
(put 'upcase-region 'disabled nil)

;; java indent 2
(add-hook 'js-mode-hook
          (lambda ()
            (make-local-variable 'js-indent-level)
            (setq js-indent-level 2)))

;; C++ style
(add-hook 'c++-mode-hook
          '(lambda()
             (c-set-style "stroustrup") ;; "gnu"
             ;; (setq indent-tabs-mode nil)  ;; インデントは空白文字で行う（TABコードを空白に変換）
             ;;(c-set-offset 'innamespace '+)
             (c-set-offset 'innamespace 0)  ;; namespace {}の中はインデントしない
             ;;(c-set-offset 'statement-cont '+)
             ;;(c-set-offset 'inline-open '+)
             (c-set-offset 'statement-cont 0)
             (c-set-offset 'inline-open 0)
             ;;(c-set-offset 'defun-block-intro '+)
             ;;(c-set-offset 'arglist-close 0) ; 関数の引数リストの閉じ括弧はインデントしない
             ;;(setq c-basic-offset 4)
             ))
(add-hook 'c-mode-hook
          '(lambda()
             (c-set-style "stroustrup") ;; "gnu"
             ;; (setq indent-tabs-mode nil)  ;; インデントは空白文字で行う（TABコードを空白に変換）
             ;;(c-set-offset 'innamespace '+)
             ;;(c-set-offset 'statement-cont '+)
             ;;(c-set-offset 'inline-open '+)
             (c-set-offset 'statement-cont 0)
             (c-set-offset 'inline-open 0)
             ;;(c-set-offset 'defun-block-intro '+)
             (c-set-offset 'arglist-close 0) ; 関数の引数リストの閉じ括弧はインデントしない
             (setq c-basic-offset 4)
             ))

(require 'cmake-mode); Add cmake listfile names to the mode list.
(setq auto-mode-alist
      (append
       '(("CMakeLists\\.txt\\'" . cmake-mode))
       '(("\\.cmake\\'" . cmake-mode))
       auto-mode-alist))

;;; end
