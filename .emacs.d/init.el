(setq custom-file (locate-user-emacs-file "custom.el"))
(setq user-emacs-directory "~/.emacs.d/elisp")

;; alt key is meta key.
(when (and (eq system-type 'darwin) (eq window-system 'ns))
  (setq ns-command-modifier (quote super))
  (setq ns-alternate-modifier (quote meta)))

(eval-and-compile
  (setq load-prefer-newer t
        package-user-dir "~/.emacs.d/elpa"
        package--init-file-ensured t
        package-enable-at-startup nil)
  (unless (file-directory-p package-user-dir)
    (make-directory package-user-dir t)))

(eval-when-compile
  (require 'package)
  (package-initialize)
  (add-to-list 'package-archives '("gnu" . "https://elpa.gnu.org/packages/") t)
  (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
  (add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/") t)
  (unless (package-installed-p 'use-package)
    (package-refresh-contents)
    (package-install 'use-package)
    (package-install 'bind-key)
    (package-install 'diminish))
  (setq use-package-always-ensure t)
  (setq use-package-expand-minimally t)
  (require 'use-package))

(require 'bind-key)

(if window-system
    (progn
      ;; UI parts
      (toggle-scroll-bar 0)
      (tool-bar-mode 0)
      (menu-bar-mode 0)

      ;; Japanese font settings
      (defun set-japanese-font (family)
        (set-fontset-font (frame-parameter nil 'font) 'japanese-jisx0208        (font-spec :family family))
        (set-fontset-font (frame-parameter nil 'font) 'japanese-jisx0212        (font-spec :family family))
        (set-fontset-font (frame-parameter nil 'font) 'katakana-jisx0201        (font-spec :family family)))

      ;; Overwrite latin and greek char's font
      (defun set-latin-and-greek-font (family)
        (set-fontset-font (frame-parameter nil 'font) '(#x0250 . #x02AF) (font-spec :family family)) ; IPA extensions
        (set-fontset-font (frame-parameter nil 'font) '(#x00A0 . #x00FF) (font-spec :family family)) ; latin-1
        (set-fontset-font (frame-parameter nil 'font) '(#x0100 . #x017F) (font-spec :family family)) ; latin extended-A
        (set-fontset-font (frame-parameter nil 'font) '(#x0180 . #x024F) (font-spec :family family)) ; latin extended-B
        (set-fontset-font (frame-parameter nil 'font) '(#x2018 . #x2019) (font-spec :family family)) ; end quote
        (set-fontset-font (frame-parameter nil 'font) '(#x2588 . #x2588) (font-spec :family family)) ; █
        (set-fontset-font (frame-parameter nil 'font) '(#x2500 . #x2500) (font-spec :family family)) ; ─
        (set-fontset-font (frame-parameter nil 'font) '(#x2504 . #x257F) (font-spec :family family)) ; box character
        (set-fontset-font (frame-parameter nil 'font) '(#x0370 . #x03FF) (font-spec :family family)))

      (setq use-default-font-for-symbols nil)
      (setq inhibit-compacting-font-caches t)
      (setq jp-font-family "SF Mono Square")
      (setq default-font-family "FiraCode Nerd Font")

      ;; (set-face-attribute 'default nil :family default-font-family)
      (when (eq system-type 'darwin)
        (set-face-attribute 'default nil :family jp-font-family :height 140))
      (when (eq system-type 'gnu/linux)
        (set-face-attribute 'default nil :family jp-font-family :height 150))
      (set-japanese-font jp-font-family)
      (set-latin-and-greek-font default-font-family)
      (add-to-list 'face-font-rescale-alist (cons default-font-family 0.86))
      (add-to-list 'face-font-rescale-alist (cons jp-font-family 1.0))))

(set-face-attribute 'region nil :background "#555")

;;
;; OS
;;

(use-package exec-path-from-shell
  :custom
  (exec-path-from-shell-check-startup-files nil)
  (exec-path-from-shell-variables '("PATH" "GOPATH"))
  :config
  (when (memq window-system '(mac ns x))
    (exec-path-from-shell-initialize)))

;; Mac OS

(when (equal system-type 'darwin)
  (setq mac-option-modifier 'super)
  (setq mac-command-modifier 'meta)
  (setq ns-auto-hide-menu-bar t)
  (setq ns-use-proxy-icon nil)
  (setq initial-frame-alist
        (append
         '((ns-transparent-titlebar . t)
           (ns-appearance . dark)
           (vertical-scroll-bars . nil)
           (internal-border-width . 0)))))
;; pbcopy
(use-package pbcopy
  :if (eq system-type 'darwin)
  :hook (dashboard-mode . (turn-on-pbcopy)))


;; Ignore split window horizontally
(setq split-width-threshold nil)
(setq split-width-threshold 160)

;; Default Encoding
(prefer-coding-system 'utf-8-unix)
(set-locale-environment "en_US.UTF-8")
(set-default-coding-systems 'utf-8-unix)
(set-selection-coding-system 'utf-8-unix)
(set-buffer-file-coding-system 'utf-8-unix)
(set-clipboard-coding-system 'utf-8) ; included by set-selection-coding-system
(set-keyboard-coding-system 'utf-8) ; configured by prefer-coding-system
(set-terminal-coding-system 'utf-8) ; configured by prefer-coding-system
(setq buffer-file-coding-system 'utf-8) ; utf-8-unix
(setq save-buffer-coding-system 'utf-8-unix) ; nil
(setq process-coding-system-alist
      (cons '("grep" utf-8 . utf-8) process-coding-system-alist))

;; Quiet Startup
(setq inhibit-startup-screen t)
(setq inhibit-startup-message t)
(setq inhibit-startup-echo-area-message t)
(setq initial-scratch-message nil)

(defun display-startup-echo-area-message ()
  (message ""))

(setq frame-title-format nil)
(setq ring-bell-function 'ignore)
(setq uniquify-buffer-name-style 'post-forward-angle-brackets) ; Show path if names are same
(setq adaptive-fill-regexp "[ t]+|[ t]*([0-9]+.|*+)[ t]*")
(setq adaptive-fill-first-line-regexp "^* *$")
(setq sentence-end "\\([。、！？]\\|……\\|[,.?!][]\"')}]*\\($\\|[ \t]\\)\\)[ \t\n]*")
(setq sentence-end-double-space nil)
(setq delete-by-moving-to-trash t)    ; Deleting files go to OS's trash folder

;; backup settings.
(setq backup-directory-alist '(("." . "~/.emacs.d/backup")))
(setq version-control t)
(setq kept-new-versions 5)
(setq kept-old-versions 1)
(setq delete-old-versions t)

(setq auto-save-default nil)          ; Disable auto save
(setq set-mark-command-repeat-pop t)  ; Repeating C-SPC after popping mark pops it again
(setq track-eol t)			; Keep cursor at end of lines.
(setq line-move-visual nil)		; To be required by track-eol
(setq-default kill-whole-line t)	; Kill line including '\n'
(setq-default indent-tabs-mode nil)   ; use space
(defalias 'yes-or-no-p #'y-or-n-p)

(setq create-lockfiles nil) ; not lockfiles

(when (functionp 'mac-auto-ascii-mode)
  (mac-auto-ascii-mode 1))

(setq-default c-basic-offset 2 indent-tabs-mode nil)
(setq-default js-indent-level 2)

;; camel case words.
(global-subword-mode 1)

(use-package wdired
  :config
  (define-key dired-mode-map "e" 'wdired-change-to-wdired-mode))

(use-package editorconfig
  :diminish
  :ensure t
  :config
  (editorconfig-mode 1))

;; Delete selection if insert someting
(use-package delsel
  :ensure nil
  :hook (after-init . delete-selection-mode))

(use-package prettier-js
  :ensure t)

(use-package add-node-modules-path
  :load-path "~/.emacs.d/elisp/src/add-node-modules-path")

;;
;; Theme
;;

(use-package doom-themes
  :custom
  (doom-themes-enable-italic t)
  (doom-themes-enable-bold t)
  ;; (vertical-bar   (doom-darken base5 0.4))
  ;; (doom-darken bg 0.4)
  :config
  (load-theme 'doom-solarized-dark t)
  (doom-themes-neotree-config)
  (doom-themes-org-config)
  (with-eval-after-load 'doom-themes
    (set-face-attribute 'region nil :background "#294B5A"))
  ;; Modeline
  (use-package doom-modeline
    :custom
    (doom-modeline-buffer-file-name-style 'truncate-with-project)
    (doom-modeline-icon t)
    (doom-modeline-major-mode-icon nil)
    (doom-modeline-minor-modes nil)
    :hook
    (after-init . doom-modeline-mode)
    :config
    (set-cursor-color "cyan")
    (line-number-mode 1)
    (column-number-mode 0)
    (doom-modeline-def-modeline 'main
      '(bar workspace-name window-number matches buffer-info remote-host buffer-position parrot selection-info)
      '(misc-info persp-name lsp github debug minor-modes input-method major-mode process vcs checker))))

(use-package nyan-mode
  :custom
  (nyan-cat-face-number 4)
  (nyan-animate-nyancat t)
  :hook
  (doom-modeline-mode . nyan-mode))

(use-package smartparens
  :diminish
  :hook
  (after-init . smartparens-global-mode)
  :config
  (require 'smartparens-config)
  (sp-pair "=" "=" :actions '(wrap))
  (sp-pair "+" "+" :actions '(wrap))
  (sp-pair "<" ">" :actions '(wrap))
  (sp-pair "$" "$" :actions '(wrap)))

(use-package paren
  :ensure nil
  :hook
  (after-init . show-paren-mode)
  :custom-face
  (show-paren-match ((nil (:background "#44475a" :foreground "#f1fa8c")))) ;; :box t
  :custom
  (show-paren-style 'mixed)
  (show-paren-when-point-inside-paren t)
  (show-paren-when-point-in-periphery t))

(use-package undo-tree
  :bind
  ("C-]" . undo-tree-redo)
  :config
  (global-undo-tree-mode))

(use-package projectile
  :diminish
  :bind
  ("M-o p" . counsel-projectile-switch-project)
  :config
  (projectile-mode +1))

(use-package ag
  :custom
  (ag-highligh-search t)
  (ag-reuse-buffers t)
  (ag-reuse-window t)
  :bind
  ("M-s a" . ag-project)
  :config
  (use-package wgrep-ag))

;;
;; Need M-x all-the-icons-install-fonts
;;
(use-package all-the-icons
  :defer t
  :load-path "~/.emacs.d/elisp/src/all-the-icons.el/")

(use-package posframe)

;; History
(use-package saveplace
  :ensure nil
  :hook (after-init . save-place-mode))

;; Recent files
(use-package recentf
  :ensure nil
  :hook (after-init . recentf-mode)
  :custom
  (recentf-max-saved-items 20000000)
  (recentf-auto-cleanup 'never)
  (recentf-exclude '((expand-file-name package-user-dir)
                     ".cache"
                     "cache"
                     "recentf"
                     "COMMIT_EDITMSG\\'"))
  :preface
  (defun ladicle/recentf-save-list-silence ()
    (interactive)
    (let ((message-log-max nil))
      (if (fboundp 'shut-up)
          (shut-up (recentf-save-list))
        (recentf-save-list)))
    (message ""))
  (defun ladicle/recentf-cleanup-silence ()
    (interactive)
    (let ((message-log-max nil))
      (if shutup-p
          (shut-up (recentf-cleanup))
        (recentf-cleanup)))
    (message ""))
  :hook
  (focus-out-hook . (ladicle/recentf-save-list-silence ladicle/recentf-cleanup-silence)))

(use-package company
  :diminish company-mode
  :defines
  (company-dabbrev-ignore-case company-dabbrev-downcase)
  :bind
  (:map company-active-map
        ("C-n" . company-select-next)
        ("C-p" . company-select-previous)
        ("<tab>" . company-complete-common-or-cycle)
        :map company-search-map
        ("C-p" . company-select-previous)
        ("C-n" . company-select-next))
  :custom
  (company-idle-delay 0)
  (company-echo-delay 0)
  (company-minimum-prefix-length 1)
  :hook
  (after-init . global-company-mode)
  (plantuml-mode . (lambda () (set (make-local-variable 'company-backends)
                                   '((company-yasnippet
                                      ;; company-dabbrev
                                      )))))
  ((js-mode
    go-mode
    c++-mode
    c-mode
    objc-mode) . (lambda () (set (make-local-variable 'company-backends)
                                 '((company-yasnippet
                                    company-files
                                    ;; company-dabbrev-code
                                    )))))
  :config
  ;; using child frame
  (use-package company-posframe
    :diminish
    :hook (company-mode . company-posframe-mode))
  ;; Show pretty icons
  (use-package company-box
    :diminish
    :hook (company-mode . company-box-mode)
    :init (setq company-box-icons-alist 'company-box-icons-all-the-icons)
    :config
    (setq company-box-backends-colors nil)
    (setq company-box-show-single-candidate t)
    (setq company-box-max-candidates 50)

    (defun company-box-icons--elisp (candidate)
      (when (derived-mode-p 'emacs-lisp-mode)
        (let ((sym (intern candidate)))
          (cond ((fboundp sym) 'Function)
                ((featurep sym) 'Module)
                ((facep sym) 'Color)
                ((boundp sym) 'Variable)
                ((symbolp sym) 'Text)
                (t . nil)))))

    (with-eval-after-load 'all-the-icons
      (declare-function all-the-icons-faicon 'all-the-icons)
      (declare-function all-the-icons-fileicon 'all-the-icons)
      (declare-function all-the-icons-material 'all-the-icons)
      (declare-function all-the-icons-octicon 'all-the-icons)
      (setq company-box-icons-all-the-icons
            `((Unknown . ,(all-the-icons-material "find_in_page" :height 0.7 :v-adjust -0.15))
              (Text . ,(all-the-icons-faicon "book" :height 0.68 :v-adjust -0.15))
              (Method . ,(all-the-icons-faicon "cube" :height 0.7 :v-adjust -0.05 :face 'font-lock-constant-face))
              (Function . ,(all-the-icons-faicon "cube" :height 0.7 :v-adjust -0.05 :face 'font-lock-constant-face))
              (Constructor . ,(all-the-icons-faicon "cube" :height 0.7 :v-adjust -0.05 :face 'font-lock-constant-face))
              (Field . ,(all-the-icons-faicon "tags" :height 0.65 :v-adjust -0.15 :face 'font-lock-warning-face))
              (Variable . ,(all-the-icons-faicon "tag" :height 0.7 :v-adjust -0.05 :face 'font-lock-warning-face))
              (Class . ,(all-the-icons-faicon "clone" :height 0.65 :v-adjust 0.01 :face 'font-lock-constant-face))
              (Interface . ,(all-the-icons-faicon "clone" :height 0.65 :v-adjust 0.01))
              (Module . ,(all-the-icons-octicon "package" :height 0.7 :v-adjust -0.15))
              (Property . ,(all-the-icons-octicon "package" :height 0.7 :v-adjust -0.05 :face 'font-lock-warning-face)) ;; Golang module
              (Unit . ,(all-the-icons-material "settings_system_daydream" :height 0.7 :v-adjust -0.15))
              (Value . ,(all-the-icons-material "format_align_right" :height 0.7 :v-adjust -0.15 :face 'font-lock-constant-face))
              (Enum . ,(all-the-icons-material "storage" :height 0.7 :v-adjust -0.15 :face 'all-the-icons-orange))
              (Keyword . ,(all-the-icons-material "filter_center_focus" :height 0.7 :v-adjust -0.15))
              (Snippet . ,(all-the-icons-faicon "code" :height 0.7 :v-adjust 0.02 :face 'font-lock-variable-name-face))
              (Color . ,(all-the-icons-material "palette" :height 0.7 :v-adjust -0.15))
              (File . ,(all-the-icons-faicon "file-o" :height 0.7 :v-adjust -0.05))
              (Reference . ,(all-the-icons-material "collections_bookmark" :height 0.7 :v-adjust -0.15))
              (Folder . ,(all-the-icons-octicon "file-directory" :height 0.7 :v-adjust -0.05))
              (EnumMember . ,(all-the-icons-material "format_align_right" :height 0.7 :v-adjust -0.15 :face 'all-the-icons-blueb))
              (Constant . ,(all-the-icons-faicon "tag" :height 0.7 :v-adjust -0.05))
              (Struct . ,(all-the-icons-faicon "clone" :height 0.65 :v-adjust 0.01 :face 'font-lock-constant-face))
              (Event . ,(all-the-icons-faicon "bolt" :height 0.7 :v-adjust -0.05 :face 'all-the-icons-orange))
              (Operator . ,(all-the-icons-fileicon "typedoc" :height 0.65 :v-adjust 0.05))
              (TypeParameter . ,(all-the-icons-faicon "hashtag" :height 0.65 :v-adjust 0.07 :face 'font-lock-const-face))
              (Template . ,(all-the-icons-faicon "code" :height 0.7 :v-adjust 0.02 :face 'font-lock-variable-name-face))))))
  ;; Show quick tooltip
  (use-package company-quickhelp
    :defines company-quickhelp-delay
    :bind (:map company-active-map
                ("M-h" . company-quickhelp-manual-begin))
    :hook (global-company-mode . company-quickhelp-mode)
    :custom (company-quickhelp-delay 0.8)))

(use-package hydra
  :load-path "~/.emacs.d/elisp/src/hydra")

(use-package lsp-mode
  :load-path "~/.emacs.d/elisp/src/lsp-mode"
  :custom
  ;; debug
  (lsp-log-io t)
  (lsp-print-io t)
  (lsp-trace t)
  (lsp-print-performance t)
  ;; general
  (lsp-auto-guess-root t)
  (lsp-document-sync-method 'incremental) ;; none, full, incremental, or nil
  (lsp-response-timeout 10)
  (lsp-prefer-flymake t) ;; t(flymake), nil(lsp-ui), or :none
  ;; go-client
  (lsp-clients-go-server-args '("--cache-style=always" "--diagnostics-style=onsave" "--format-style=goimports"))
  :hook
  ((go-mode c-mode c++-mode js-mode) . lsp)
  :bind
  (:map lsp-mode-map
        ("C-c r"   . lsp-rename))
  :config
  (require 'lsp-clients)
  ;; LSP UI tools
  (use-package lsp-ui
    :load-path "~/.emacs.d/elisp/src/lsp-ui"
    :custom
    ;; lsp-ui-doc
    (lsp-ui-doc-enable nil)
    (lsp-ui-doc-header t)
    (lsp-ui-doc-include-signature nil)
    (lsp-ui-doc-position 'at-point) ;; top, bottom, or at-point
    (lsp-ui-doc-max-width 120)
    (lsp-ui-doc-max-height 30)
    (lsp-ui-doc-use-childframe t)
    (lsp-ui-doc-use-webkit t)
    ;; lsp-ui-flycheck
    (lsp-ui-flycheck-enable nil)
    ;; lsp-ui-sideline
    (lsp-ui-sideline-enable nil)
    (lsp-ui-sideline-ignore-duplicate t)
    (lsp-ui-sideline-show-symbol t)
    (lsp-ui-sideline-show-hover t)
    (lsp-ui-sideline-show-diagnostics nil)
    (lsp-ui-sideline-show-code-actions t)
    (lsp-ui-sideline-code-actions-prefix ">")
    ;; lsp-ui-imenu
    (lsp-ui-imenu-enable t)
    (lsp-ui-imenu-kind-position 'top)
    ;; lsp-ui-peek
    (lsp-ui-peek-enable t)
    (lsp-ui-peek-peek-height 20)
    (lsp-ui-peek-list-width 50)
    (lsp-ui-peek-fontify 'on-demand) ;; never, on-demand, or always
    :preface
    (defun ladicle/toggle-lsp-ui-doc ()
      (interactive)
      (if lsp-ui-doc-mode
          (progn
            (lsp-ui-doc-mode -1)
            (lsp-ui-doc--hide-frame))
        (lsp-ui-doc-mode 1)))
    :bind
    (:map lsp-mode-map
          ("C-c C-r" . lsp-ui-peek-find-references)
          ("C-c C-j" . lsp-ui-peek-find-definitions)
          ("C-c i"   . lsp-ui-peek-find-implementation)
          ("C-c m"   . lsp-ui-imenu)
          ("C-c s"   . lsp-ui-sideline-mode)
          ("C-c d"   . ladicle/toggle-lsp-ui-doc))
    :hook
    (lsp-mode . lsp-ui-mode))

  (lsp-register-client
   (make-lsp-client :new-connection (lsp-stdio-connection
                                     (lambda () (cons "bingo"
                                                      lsp-clients-go-server-args)))
                    :major-modes '(go-mode)
                    :priority 2
                    :initialization-options 'lsp-clients-go--make-init-options
                    :server-id 'go-bingo
                    :library-folders-fn (lambda (_workspace)
                                          lsp-clients-go-library-directories))))

(use-package volatile-highlights
  :diminish
  :hook
  (after-init . volatile-highlights-mode)
  :custom-face
  (vhl/default-face ((nil (:foreground "#FF3333" :background "#FFCDCD")))))

(use-package counsel
  :diminish ivy-mode counsel-mode
  :load-path "~/.emacs.d/elisp/src/swiper"
  :defines
  (projectile-completion-system magit-completing-read-function)
  :bind
  (("C-s" . swiper)
   ("M-s r" . ivy-resume)
   ("C-c v p" . ivy-push-view)
   ("C-c v o" . ivy-pop-view)
   ("C-c v ." . ivy-switch-view)
   ("M-s c" . counsel-ag)
   ("M-o f" . counsel-fzf)
   ("M-o r" . counsel-recentf)
   ("M-y" . counsel-yank-pop)
   :map ivy-minibuffer-map
   ("C-w" . ivy-backward-kill-word)
   ("C-k" . ivy-kill-line)
   ("C-j" . ivy-immediate-done)
   ("RET" . ivy-alt-done)
   ("C-h" . ivy-backward-delete-char))
  :preface
  (custom-set-faces
   '(ivy-current-match ((t (:foreground "#fff" :background "#294B5A")))))
  (defun ivy-format-function-pretty (cands)
    "Transform CANDS into a string for minibuffer."
    (ivy--format-function-generic
     (lambda (str)
       (concat
        (all-the-icons-faicon "hand-o-right" :height .85 :v-adjust .05 :face 'font-lock-constant-face)
        (ivy--add-face str 'ivy-current-match)))
     (lambda (str)
       (concat "  " str))
     cands
     "\n"))
  :hook
  (after-init . ivy-mode)
  (ivy-mode . counsel-mode)
  :custom
  (counsel-yank-pop-height 15)
  (enable-recursive-minibuffers t)
  (ivy-use-selectable-prompt t)
  (ivy-use-virtual-buffers t)
  (ivy-on-del-error-function nil)
  (swiper-action-recenter t)
  (counsel-grep-base-command "ag -S --noheading --nocolor --nofilename --numbers '%s' %s")
  :config
  ;; using ivy-format-fuction-arrow with counsel-yank-pop
  (advice-add
   'counsel--yank-pop-format-function
   :override
   (lambda (cand-pairs)
     (ivy--format-function-generic
      (lambda (str)
        (mapconcat
         (lambda (s)
           (ivy--add-face (concat (propertize "┃ " 'face `(:foreground "#61bfff")) s) 'ivy-current-match))
         (split-string
          (counsel--yank-pop-truncate str) "\n" t)
         "\n"))
      (lambda (str)
        (counsel--yank-pop-truncate str))
      cand-pairs
      counsel-yank-pop-separator)))

  ;; NOTE: this variable do not work if defined in :custom
  (setq ivy-format-function 'ivy-format-function-pretty)
  (setq counsel-yank-pop-separator
        (propertize "\n────────────────────────────────────────────────────────\n"
                    'face `(:foreground "#6272a4")))

  ;; Integration with `projectile'
  (with-eval-after-load 'projectile
    (setq projectile-completion-system 'ivy))
  ;; Integration with `magit'
  (with-eval-after-load 'magit
    (setq magit-completing-read-function 'ivy-completing-read))

  ;; Enhance fuzzy matching
  (use-package flx)
  ;; Enhance M-x
  (use-package amx)
  ;; Ivy integration for Projectile
  (use-package counsel-projectile
    :config (counsel-projectile-mode 1))

  ;; Show ivy frame using posframe
  (use-package ivy-posframe
    :custom
    (ivy-display-function #'ivy-posframe-display-at-frame-center)
    ;; (ivy-posframe-width 130)
    ;; (ivy-posframe-height 11)
    (ivy-posframe-parameters
     '((left-fringe . 5)
       (right-fringe . 5)))
    :custom-face
    (ivy-posframe ((t (:background "#282a36"))))
    (ivy-posframe-border ((t (:background "#6272a4"))))
    (ivy-posframe-cursor ((t (:background "#61bfff"))))
    :hook
    (ivy-mode . ivy-posframe-enable))

  ;; ghq
  (use-package ivy-ghq
    :load-path "~/.emacs.d/elisp/src/ivy-ghq"
    :commands (ivy-ghq-open)
    :bind
    ("M-o p" . ivy-ghq-open-and-fzf)
    :custom
    (ivy-ghq-short-list t)
    :preface
    (defun ivy-ghq-open-and-fzf ()
      (interactive)
      (ivy-ghq-open)
      (counsel-fzf)))

  ;; More friendly display transformer for Ivy
  (use-package ivy-rich
    :defines (all-the-icons-dir-icon-alist bookmark-alist)
    :functions (all-the-icons-icon-family
                all-the-icons-match-to-alist
                all-the-icons-auto-mode-match?
                all-the-icons-octicon
                all-the-icons-dir-is-submodule)
    :preface
    (defun ivy-rich-bookmark-name (candidate)
      (car (assoc candidate bookmark-alist)))

    (defun ivy-rich-repo-icon (candidate)
      "Display repo icons in `ivy-rich`."
      (all-the-icons-octicon "repo" :height .9))

    (defun ivy-rich-org-capture-icon (candidate)
      "Display repo icons in `ivy-rich`."
      (pcase (car (last (split-string (car (split-string candidate)) "-")))
        ("emacs" (all-the-icons-fileicon "emacs" :height .68 :v-adjust .001))
        ("schedule" (all-the-icons-faicon "calendar" :height .68 :v-adjust .005))
        ("tweet" (all-the-icons-faicon "commenting" :height .7 :v-adjust .01))
        ("link" (all-the-icons-faicon "link" :height .68 :v-adjust .01))
        ("memo" (all-the-icons-faicon "pencil" :height .7 :v-adjust .01))
        (_       (all-the-icons-octicon "inbox" :height .68 :v-adjust .01))
        ))

    (defun ivy-rich-org-capture-title (candidate)
      (let* ((octl (split-string candidate))
             (title (pop octl))
             (desc (mapconcat 'identity octl " ")))
        (format "%-25s %s"
                title
                (propertize desc 'face `(:inherit font-lock-doc-face)))))

    (defun ivy-rich-buffer-icon (candidate)
      "Display buffer icons in `ivy-rich'."
      (when (display-graphic-p)
        (when-let* ((buffer (get-buffer candidate))
                    (major-mode (buffer-local-value 'major-mode buffer))
                    (icon (if (and (buffer-file-name buffer)
                                   (all-the-icons-auto-mode-match? candidate))
                              (all-the-icons-icon-for-file candidate)
                            (all-the-icons-icon-for-mode major-mode))))
          (if (symbolp icon)
              (setq icon (all-the-icons-icon-for-mode 'fundamental-mode)))
          (unless (symbolp icon)
            (propertize icon
                        'face `(
                                :height 1.1
                                :family ,(all-the-icons-icon-family icon)
                                ))))))

    (defun ivy-rich-file-icon (candidate)
      "Display file icons in `ivy-rich'."
      (when (display-graphic-p)
        (let ((icon (if (file-directory-p candidate)
                        (cond
                         ((and (fboundp 'tramp-tramp-file-p)
                               (tramp-tramp-file-p default-directory))
                          (all-the-icons-octicon "file-directory"))
                         ((file-symlink-p candidate)
                          (all-the-icons-octicon "file-symlink-directory"))
                         ((all-the-icons-dir-is-submodule candidate)
                          (all-the-icons-octicon "file-submodule"))
                         ((file-exists-p (format "%s/.git" candidate))
                          (all-the-icons-octicon "repo"))
                         (t (let ((matcher (all-the-icons-match-to-alist candidate all-the-icons-dir-icon-alist)))
                              (apply (car matcher) (list (cadr matcher))))))
                      (all-the-icons-icon-for-file candidate))))
          (unless (symbolp icon)
            (propertize icon
                        'face `(
                                :height 1.1
                                :family ,(all-the-icons-icon-family icon)
                                ))))))
    :hook (ivy-rich-mode . (lambda ()
                             (setq ivy-virtual-abbreviate
                                   (or (and ivy-rich-mode 'abbreviate) 'name))))
    :init
    (setq ivy-rich-display-transformers-list
          '(ivy-switch-buffer
            (:columns
             ((ivy-rich-buffer-icon)
              (ivy-rich-candidate (:width 30))
              (ivy-rich-switch-buffer-size (:width 7))
              (ivy-rich-switch-buffer-indicators (:width 4 :face error :align right))
              (ivy-rich-switch-buffer-major-mode (:width 12 :face warning))
              (ivy-rich-switch-buffer-project (:width 15 :face success))
              (ivy-rich-switch-buffer-path (:width (lambda (x) (ivy-rich-switch-buffer-shorten-path x (ivy-rich-minibuffer-width 0.3))))))
             :predicate
             (lambda (cand) (get-buffer cand)))
            ivy-switch-buffer-other-window
            (:columns
             ((ivy-rich-buffer-icon)
              (ivy-rich-candidate (:width 30))
              (ivy-rich-switch-buffer-size (:width 7))
              (ivy-rich-switch-buffer-indicators (:width 4 :face error :align right))
              (ivy-rich-switch-buffer-major-mode (:width 12 :face warning))
              (ivy-rich-switch-buffer-project (:width 15 :face success))
              (ivy-rich-switch-buffer-path (:width (lambda (x) (ivy-rich-switch-buffer-shorten-path x (ivy-rich-minibuffer-width 0.3))))))
             :predicate
             (lambda (cand) (get-buffer cand)))
            counsel-M-x
            (:columns
             ((counsel-M-x-transformer (:width 40))
              (ivy-rich-counsel-function-docstring (:face font-lock-doc-face))))
            counsel-describe-function
            (:columns
             ((counsel-describe-function-transformer (:width 45))
              (ivy-rich-counsel-function-docstring (:face font-lock-doc-face))))
            counsel-describe-variable
            (:columns
             ((counsel-describe-variable-transformer (:width 45))
              (ivy-rich-counsel-variable-docstring (:face font-lock-doc-face))))
            counsel-find-file
            (:columns
             ((ivy-rich-file-icon)
              (ivy-rich-candidate)))
            counsel-file-jump
            (:columns
             ((ivy-rich-file-icon)
              (ivy-rich-candidate)))
            counsel-dired-jump
            (:columns
             ((ivy-rich-file-icon)
              (ivy-rich-candidate)))
            counsel-git
            (:columns
             ((ivy-rich-file-icon)
              (ivy-rich-candidate)))
            counsel-recentf
            (:columns
             ((ivy-rich-file-icon)
              (ivy-rich-candidate (:width 110))))
            counsel-bookmark
            (:columns
             ((ivy-rich-bookmark-type)
              (ivy-rich-bookmark-name (:width 30))
              (ivy-rich-bookmark-info (:width 80))))
            counsel-projectile-switch-project
            (:columns
             ((ivy-rich-file-icon)
              (ivy-rich-candidate)))
            counsel-fzf
            (:columns
             ((ivy-rich-file-icon)
              (ivy-rich-candidate)))
            ivy-ghq-open
            (:columns
             ((ivy-rich-repo-icon)
              (ivy-rich-candidate)))
            ivy-ghq-open-and-fzf
            (:columns
             ((ivy-rich-repo-icon)
              (ivy-rich-candidate)))
            counsel-projectile-find-file
            (:columns
             ((ivy-rich-file-icon)
              (ivy-rich-candidate)))
            counsel-org-capture
            (:columns
             ((ivy-rich-org-capture-icon)
              (ivy-rich-org-capture-title)
              ))
            counsel-projectile-find-dir
            (:columns
             ((ivy-rich-file-icon)
              (counsel-projectile-find-dir-transformer)))))

    (setq ivy-rich-parse-remote-buffer nil)
    :config
    (ivy-rich-mode 1))
  )

;; flymake

(use-package flymake-posframe
  :load-path "~/.emacs.d/elisp/src/flymake-posframe"
  :custom
  (flymake-posframe-error-prefix "x")
  :custom-face
  (flymake-posframe-foreground-face ((t (:foreground "white"))))
  :hook (flymake-mode . flymake-posframe-mode))

(use-package flymake-diagnostic-at-point
  :disabled
  :after flymake
  :custom
  (flymake-diagnostic-at-point-timer-delay 0.1)
  (flymake-diagnostic-at-point-error-prefix "x")
  (flymake-diagnostic-at-point-display-diagnostic-function 'flymake-diagnostic-at-point-display-popup) ;; or flymake-diagnostic-at-point-display-minibuffer
  :hook
  (flymake-mode . flymake-diagnostic-at-point-mode))


(use-package rainbow-delimiters
  :hook
  (prog-mode . rainbow-delimiters-mode))

(use-package rainbow-mode
  :diminish
  :hook (emacs-lisp-mode . rainbow-mode))

(use-package which-key
  :diminish which-key-mode
  :hook (after-init . which-key-mode))

(use-package wgrep
  :defer t
  :custom
  (wgrep-enable-key "e")
  (wgrep-auto-save-buffer t)
  (wgrep-change-readonly-file t))

(add-hook 'js-mode-hook '(lambda() (add-node-modules-path)))
(add-to-list 'auto-mode-alist '("\\.tsx?$" . js-mode))

;; multiple cursor

(use-package multiple-cursors)

;; git

(use-package git-gutter
  :custom
  (git-gutter:modified-sign "~")
  (git-gutter:added-sign    "+")
  (git-gutter:deleted-sign  "-")
  :custom-face
  (git-gutter:modified ((t (:foreground "#f1fa8c" :background "#f1fa8c"))))
  (git-gutter:added    ((t (:foreground "#50fa7b" :background "#50fa7b"))))
  (git-gutter:deleted  ((t (:foreground "#ff79c6" :background "#ff79c6"))))
  :config
  (global-git-gutter-mode +1))

(use-package browse-at-remote
  :load-path "~/.emacs.d/elisp/src/browse-at-remote"
  :bind ("M-g r" . browse-at-remote))

;; rotate

(use-package rotate
  :load-path "~/.emacs.d/elisp/src/emacs-rotate"
  :bind
  ("C-M-o" . hydra-window/body)
  :preface
  ;; fixed cursor scroll-up
  (defun scroll-up-in-place (n)
    (interactive "p")
    (forward-line (- n))
    (scroll-down n))
  ;; fixed cursor scroll-down
  (defun scroll-down-in-place (n)
    (interactive "p")
    (forward-line n)
    (scroll-up n))
  :config
  (with-eval-after-load 'hydra
    (defhydra hydra-window (:color pink :hint nil)
      "
^Rotate^         ^Move^
^^^^^^^^-----------------------------------------------------------------
_r_: rotate      _n_: scroll down
_s_: split       _p_: scroll up
"
      ("r" rotate-window)
      ("s" rotate-layout)
      ("n" scroll-down-in-place)
      ("p" scroll-up-in-place)
      ("q" nil))))

;; avy

(use-package avy
  :bind
  ("C-'" . avy-resume)
  ("C-;" . avy-goto-char-2)
  :preface
  ;; yank inner sexp
  (defun yank-inner-sexp ()
    (interactive)
    (backward-list)
    (mark-sexp)
    (copy-region-as-kill (region-beginning) (region-end)))
  :config
   (use-package avy-zap
      :config
      (bind-key* "M-z" 'avy-zap-up-to-char-dwim)))

;;
;; Hydra
;;

(with-eval-after-load 'hydra
  (defhydra hydra-primary (:color pink
                           :hint nil)
  "
^Project^         ^Git^              ^Edit^          
^^^^^^^^-----------------------------------------------------------------
_p_: ghq          _m_: magit-status  _r_: replace
_f_: find-file    _o_: open-repos    _c_: mc/line
_e_: run command                   _t_: mc/match
_a_: ag                            _j_: avy jump
"
  ("p" ivy-ghq-open)
  ("a" ag :exit t)
  ("f" projectile--find-file :exit t)
  ("e" projectile-run-project :exit t)
  ("m" magit-status :exit t)
  ("r" query-replace-regexp :exit t)
  ("c" mc/edit-lines)
  ("t" mc/mark-all-like-this)
  ("j" avy-goto-char-2 :exit t)
  ("o" browse-at-remote :exit t)
  ("q" nil))
  (bind-key* "C-z" 'hydra-primary/body))

;; Global

(global-unset-key "\C-z")
(global-set-key (kbd "C-h")   'backward-delete-char)
(global-set-key (kbd "M-h")   'backward-kill-word)
(global-set-key (kbd "C--")   'undo)

;; lsp code jump.
(bind-key* "M-." 'lsp-ui-peek-find-implementation)
(bind-key* "M-," 'xref-pop-marker-stack)
(bind-key* "M-/" 'lsp-ui-peek-find-references)
