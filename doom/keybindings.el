;;; keybindings.el -*- lexical-binding: t; -*-

(after! evil
  (defun crab/org-insert-codeblock ()
    (interactive)
    (insert "#+begin_src \n#+end_src")
    (forward-line -1)
    (end-of-line)
    (evil-insert-state))

  (defun crab/org-insert-codeline ()
    (interactive)
    (insert "~~")
    (backward-char 1)
    (evil-insert-state))

  (defun crab/org--strip-inline-format (text)
    (cond
     ((and (string-prefix-p "*/" text) (string-suffix-p "/*" text))
      (substring text 2 -2))
     ((and (string-prefix-p "*" text) (string-suffix-p "*" text)
           (>= (length text) 2))
      (substring text 1 -1))
     ((and (string-prefix-p "/" text) (string-suffix-p "/" text)
           (>= (length text) 2))
      (substring text 1 -1))
     (t text)))

  (defun crab/org-replace-region-with-format (left right)
    (unless (use-region-p)
      (user-error "Select text first"))
    (let* ((beg (region-beginning))
           (end (region-end))
           (text (buffer-substring-no-properties beg end))
           (clean (crab/org--strip-inline-format text)))
      (delete-region beg end)
      (goto-char beg)
      (insert left clean right)
      (set-mark beg)
      (goto-char (+ beg (length left) (length clean) (length right)))))

  (defun crab/org-bold-region ()
    (interactive)
    (crab/org-replace-region-with-format "*" "*"))

  (defun crab/org-italic-region ()
    (interactive)
    (crab/org-replace-region-with-format "/" "/"))

  (defun crab/org-bold-italic-region ()
    (interactive)
    (crab/org-replace-region-with-format "*/" "/*"))

  (defun crab/copy-to-system-clipboard (text)
    (with-temp-buffer
      (insert text)
      (call-process-region (point-min) (point-max) "pbcopy" nil 0 nil)))

  (defun crab/copy-region-to-system-clipboard (beg end)
    (interactive "r")
    (let ((text (buffer-substring-no-properties beg end)))
      (kill-new text)
      (crab/copy-to-system-clipboard text)
      (message "Copied selection")))


  (defun crab/insert-current-time ()
    (interactive)
    (insert (format-time-string "%Y-%m-%d %H:%M")))

  ;; Ex commands
  (evil-ex-define-cmd "todo" #'org-todo-list)
  (evil-ex-define-cmd "agenda" (cmd! (org-agenda nil "a")))
  (evil-ex-define-cmd "inbox" (cmd! (find-file crab/org-inbox-file)))
  (evil-ex-define-cmd "tasks" (cmd! (find-file crab/org-tasks-file)))
  (evil-ex-define-cmd "notes" (cmd! (find-file crab/org-notes-file)))
  (evil-ex-define-cmd "ddl" #'org-deadline)
  (evil-ex-define-cmd "scd" #'org-schedule)
  (evil-ex-define-cmd "done" (cmd! (org-todo "DONE")))
  (evil-ex-define-cmd "codeblock" #'crab/org-insert-codeblock)
  (evil-ex-define-cmd "codeline" #'crab/org-insert-codeline)
  (evil-ex-define-cmd "bold" #'crab/org-bold-region)
  (evil-ex-define-cmd "italic" #'crab/org-italic-region)
  (evil-ex-define-cmd "bai" #'crab/org-bold-italic-region)
  (evil-ex-define-cmd "time" #'crab/insert-current-time)

  (setq evil-ex-complete-emacs-commands nil)

  ;; Unbind conflicting defaults
  (define-key evil-motion-state-map (kbd "J") nil)
  (define-key evil-normal-state-map (kbd "J") nil)
  (define-key evil-visual-state-map (kbd "J") nil)
  (define-key evil-motion-state-map (kbd "K") nil)
  (define-key evil-normal-state-map (kbd "K") nil)
  (define-key evil-visual-state-map (kbd "K") nil)

  ;; Keymaps
  (map! :n ";" #'evil-ex
        :n "Q" #'save-buffers-kill-emacs
        :v "Y" #'crab/copy-region-to-system-clipboard
        :n "J" (cmd! (evil-next-line 5))
        :n "K" (cmd! (evil-previous-line 5))
        :v "J" (cmd! (evil-next-line 5))
        :v "K" (cmd! (evil-previous-line 5))
        :n "C-g" #'what-cursor-position
        :leader
        :desc "Find file" "SPC" #'find-file
        :desc "Clear search highlight" "RET" #'evil-ex-nohighlight
        :desc "Window left"  "h" #'evil-window-left
        :desc "Window down"  "j" #'evil-window-down
        :desc "Window up"    "k" #'evil-window-up
        :desc "Window right" "l" #'evil-window-right))
