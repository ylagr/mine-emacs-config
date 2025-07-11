;;; init.el --- Initialization file for Emacs  -*- lexical-binding: t; -*-
;;; Commentary:
;;; Emacs Startup File --- initialization for Emacs

;;; code:
;; -----------------  Hacks for speeding up initialization.
(defconst +file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)
(setq gc-cons-threshold most-positive-fixnum) ; gc use big memory
;; Packages should have been made available.  Disable it to speed up
;; installing packages during initialization.
(setq package-quickstart nil)

;; ------------------ move default dir
;; replace emacs paths early -- before doing anything
(use-package no-littering
  :ensure t
  :demand t
  :config
  (setq auto-save-file-name-transforms
        `((".*" ,(no-littering-expand-var-file-name "auto-save/") t))
	)
  )
;; -------------------------------config start
;; =============================  config use-package
;; Set up use-package for user config
(setq use-package-always-ensure t)  ; All packages used have to be installed

;; ============================  benchmark
(use-package benchmark-init
  :demand t
  :config (benchmark-init/activate)
  :hook (after-init . benchmark-init/deactivate)
  )

;; def fun show os name
(defun print-os()
  "Show current os name."
  (interactive)
  (message "%s" system-type)
  )

;; def fun quick open config file
(defun open-init-file()
"Open Emacs config file."
  (interactive)
  (find-file (concat user-emacs-directory "init.el"))
  )

;; 自定义两个函数
;; Faster move cursor
(defun next-ten-lines()
  "Move cursor to next 10 lines."
  (interactive)
  (forward-line 10))

(defun previous-ten-lines()
  "Move cursor to previous 10 lines."
  (interactive)
  (forward-line -10))
;; 绑定到快捷键
(global-set-key (kbd "M-n") 'next-ten-lines)            ; 光标向下移动 10 行
(global-set-key (kbd "M-p") 'previous-ten-lines)        ; 光标向上移动 10 行

;; ======================       keybind
(global-set-key (kbd "M-<f3>") 'open-init-file)
(global-set-key (kbd "C-x ,") 'open-init-file)
(global-set-key (kbd "C-c C-_") 'comment-or-uncomment-region)
(global-set-key (kbd "C-c C-/") 'comment-or-uncomment-region)
(global-set-key (kbd "C-x C-k") 'kill-current-buffer)
;; leader key
(global-set-key (kbd "M-SPC") nil) ;修改默认keybind M-SPC -> nil, 作为leader使用，用于各种命令替代
(global-set-key (kbd "M-ESC") 'keyboard-quit)
(global-set-key (kbd "C-j") nil)	      ;修改默认的C-j功能，作为编辑的leader key使用
(global-set-key (kbd "C-j C-j") 'electric-newline-and-maybe-indent);原始的C-j功能修改
(global-set-key (kbd "ESC ]") 'cycle-spacing) ;原始M-SPC功能修改为
;;(global-set-key (kbd "ESC SPC") 'cycle-spacing) ;test ESC SPC leaderkey使用
(global-set-key (kbd "M-o") 'other-window)

(global-set-key (kbd "C-j C-k") 'kill-whole-line)

;; ======================      config ui
(setq cursor-type 'box)       ; 终端不生效  原因不明
;;(fido-vertical-mode +1)			;minibuffer垂直补全  和 orderless冲突
(icomplete-vertical-mode +1)	      ;minibuffer垂直补全
(global-hl-line-mode 1)		;高亮当前行
(global-tab-line-mode +1)		;显示tab line 不同的buffer编辑区
(tab-bar-mode +1)			;显示tab bar  相当于不同的工作区
(column-number-mode +1)			;显示行列在buffer区域
(global-display-line-numbers-mode +1)
(electric-pair-mode +1)			;自动补全括号
(electric-quote-mode +1)
(electric-indent-mode +1)
(electric-layout-mode +1)
(show-paren-mode +1)			;
(delete-selection-mode +1)              ;选中区域后插入删除选中文字
(global-auto-revert-mode +1)		;实时刷新文件
(add-hook 'prog-mode-hook 'hs-minor-mode)

;(setq icomplete-in-buffer t)
;(setq completion-auto-help 'always)
;(setq completions-detailed t)
;(global-completion-preview-mode +1)
;(setq completion-preview-ignore-case t)
(setq completion-ignore-case t)
;(setq completion-preview-completion-styles '(orderless basic partial-completion initials orderless))

(repeat-mode +1)

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode)
  )

(use-package paren
  :init
  :config (setq show-paren-when-point-in-periphery t
 		show-paren-when-point-inside-paren t
	       	show-paren-style 'mixed
 		)
  )

(use-package which-key
  :hook (after-init . which-key-mode)
  :custom
  (which-key-idle-delay 0.01)
  )



;; ------------------  补全
;; 帮助文档
(use-package helpful
  :ensure t
  :bind
  (("C-c h f" . helpful-callable)
   ("C-c h v" . helpful-variable)
   ("C-c h k" . helpful-key)
   ("C-c h s" . helpful-symbol)
   ))

;; Enable rich annotations using the Marginalia package
(use-package marginalia
  ;; Bind `marginalia-cycle' locally in the minibuffer.  To make the binding
  ;; available in the *Completions* buffer, add it to the
  ;; `completion-list-mode-map'.
  :bind (:map minibuffer-local-map
         ("C-c '" . 'marginalia-cycle))
  ;; The :init section is always executed.
  :init
  ;; Marginalia must be activated in the :init section of use-package such that
  ;; the mode gets enabled right away. Note that this forces loading the
  ;; package.
  (marginalia-mode)
  )
(use-package orderless
  :init
  (setq completion-styles '(orderless partial-completion basic initials)
	completion-category-defaults nil
	completion-category-overrides nil
	)
  )

(use-package consult
  :ensure t
  :bind
  (("C-s" . consult-line))
  )

(use-package corfu
;  :disabled
  :ensure t
  :hook (after-init . global-corfu-mode)
  :custom
  (corfu-auto t)
  (corfu-auto-deply 0)
  (corfu-min-width 1)
;  (keymap-unset corfu-map "RET");配置无效 原因不明
;  (corfu-quit-at-boundary nil)
  :init
  (corfu-history-mode)
  (corfu-popupinfo-mode)
  (corfu-echo-mode)
  (corfu-indexed-mode)
  :bind
  (:map corfu-map ("RET" . 'newline))
  )
(use-package flymake
  :ensure nil
  :init
  (add-hook 'prog-mode-hook 'flymake-mode)
  (setq flymake-show-diagnostics-at-end-of-line t)
  (setq flymake-no-changes-timeout 0.9)
  :bind
  (
   ("C-j C-n" . 'flymake-goto-next-error)
   ("C-j C-p" . 'flymake-goto-prev-error)
   )
  )

;; ====================     term
(use-package eat
  :bind (
	 ("ESC SPC v" . eat-other-window)
	 :map eat-semi-char-mode-map ("M-o" . other-window)
	  )
  :config
  (setq eat-kill-buffer-on-exit nil)
  (setq eat-enable-blinking-text t)
  (setq eat-enable-directory-tracking t)
  )

;; ========================   config project
(use-package projection
  :disabled
  )
(use-package magit
  ;:disabled
  :defer t
  )
(use-package eglot
  :ensure nil
;  :hook (prog-mode . eglot-ensure)
  :bind ("C-c e f" . eglot-format)
  )
(use-package eglot-java
  :after eglot
  ;:init
  )

;; =============== package straight
;; (defvar bootstrap-version)
;; (let ((bootstrap-file
;;        (expand-file-name
;;         "straight/repos/straight.el/bootstrap.el"
;;         (or (bound-and-true-p straight-base-dir)
;;             user-emacs-directory)))
;;       (bootstrap-version 7))
;;   (unless (file-exists-p bootstrap-file)
;;     (with-current-buffer
;;         (url-retrieve-synchronously
;;          "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
;;          'silent 'inhibit-cookies)
;;       (goto-char (point-max))
;;       (eval-print-last-sexp)))
;;  (load bootstrap-file nil 'nomessage))
;; ================ straight end
;; (use-package yasnippet
;;   :init
;;   (yas-global-mode +1)
;;   )

;; (use-package lsp-bridge
;;   :straight '(lsp-bridge :type git :host github :repo "manateelazycat/lsp-bridge"
;;             :files (:defaults "*.el" "*.py" "acm" "core" "langserver" "multiserver" "resources")
;;             :build (:not compile))
;;   :init
;;   (global-lsp-bridge-mode))

;; custom
(when (file-exists-p custom-file)
  (load custom-file))

;; End of hacks.
(setq file-name-handler-alist +file-name-handler-alist)
(setq gc-cons-threshold 16777216) ;; 16mb
;; Re-enable package-quickstart.
(setq package-quickstart t)



(provide 'init)
;;; init.el ends here
