;;; org-config.el -*- lexical-binding: t; -*-

(after! org
  (setq org-hide-emphasis-markers t
        org-pretty-entities t
        org-ellipsis " ▾"
        org-log-done 'time
        org-tags-column 0
        org-src-fontify-natively t
        org-src-tab-acts-natively t
        org-todo-keywords
        '((sequence "TODO(t)" "NEXT(n)" "DOING(g)" "WAIT(w)" "|" "DONE(d)" "CANCELLED(c)")))

  (use-package! org-modern
    :hook ((org-mode . org-modern-mode)
           (org-agenda-finalize . org-modern-agenda))
    :config
    (setq org-modern-hide-stars 'leading
          org-modern-star 'replace
          org-modern-list '(?• ?◦ ?▸ ?▹)
          org-modern-tag nil
          org-modern-timestamp nil
          org-modern-priority t))

  (use-package! org-appear
    :hook (org-mode . org-appear-mode)
    :config
    (setq org-appear-autoemphasis t
          org-appear-autolinks t
          org-appear-autosubmarkers t
          org-appear-autoentities t))

  (custom-set-faces!
    '(org-document-title :inherit variable-pitch :weight bold :height 1.55)
    '(org-level-1 :inherit variable-pitch :weight bold :height 1.42)
    '(org-level-2 :inherit variable-pitch :weight bold :height 1.24)
    '(org-level-3 :inherit variable-pitch :weight semi-bold :height 1.14)
    '(org-level-4 :inherit variable-pitch :weight semi-bold :height 1.08)
    '(org-level-5 :inherit variable-pitch :weight normal :height 1.03)
    '(org-level-6 :inherit variable-pitch :weight normal :height 1.0)
    '(org-level-7 :inherit variable-pitch :weight normal :height 1.0)
    '(org-level-8 :inherit variable-pitch :weight normal :height 1.0)
    '(org-block :background "#1f2335" :foreground "#c0caf5" :extend t)
    '(org-block-begin-line :background "#1f2335" :foreground "#565f89" :extend t)
    '(org-block-end-line :background "#1f2335" :foreground "#565f89" :extend t)
    '(org-code :foreground "#7dcfff")
    '(org-verbatim :foreground "#73daca")
    '(org-tag :foreground "#565f89" :weight normal)
    '(org-checkbox :foreground "#7aa2f7" :weight bold)))

(after! org-agenda
  (require 'org-super-agenda)
  (org-super-agenda-mode)

  (setq org-agenda-start-day nil
        org-agenda-span 7
        org-agenda-start-on-weekday nil
        org-agenda-skip-scheduled-if-done t
        org-agenda-skip-deadline-if-done t
        org-agenda-block-separator ?─
        org-agenda-time-grid
        '((daily today require-timed)
          (800 1000 1200 1400 1600 1800 2000)
          " ┄┄┄ "
          "────────────────")
        org-agenda-current-time-string
        "⭠ now ─────────────────────────────────────────────────"
        org-super-agenda-groups
        '((:name "Today" :time-grid t :date today :order 1)
          (:name "Overdue" :deadline past :order 2)
          (:name "Due Soon" :deadline future :order 3)
          (:name "Important" :priority "A" :order 4)
          (:name "Next Actions" :todo ("NEXT") :order 5)
          (:name "In Progress" :todo ("DOING") :order 6)
          (:name "Projects" :tag "project" :order 7)
          (:name "Waiting" :todo ("WAIT") :order 8)
          (:discard (:todo ("DONE" "CANCELLED"))))
        org-agenda-custom-commands
        '(("d" "Dashboard"
           ((agenda "")
            (alltodo "")))
          ("n" "Next Tasks"
           ((todo "NEXT"
                  ((org-agenda-overriding-header "Next Tasks"))))))
        org-agenda-prefix-format
        '((agenda . " %?-12t %s")
          (todo . " %i %-12:c")
          (tags . " %i %-12:c")
          (search . " %i %-12:c")))

  (custom-set-faces!
    '(org-agenda-structure :foreground "#7aa2f7" :weight bold)
    '(org-super-agenda-header :foreground "#bb9af7" :weight bold)
    '(org-agenda-date :foreground "#7dcfff" :weight bold)
    '(org-agenda-date-today :foreground "#7aa2f7" :weight bold)
    '(org-agenda-date-weekend :foreground "#565f89")
    '(org-scheduled :foreground "#9ece6a")
    '(org-scheduled-today :foreground "#73daca" :weight bold)
    '(org-upcoming-deadline :foreground "#e0af68")
    '(org-warning :foreground "#f7768e" :weight bold)
    '(org-headline-done :foreground "#565f89" :strike-through t)
    '(org-todo :foreground "#f7768e" :weight bold)
    '(org-done :foreground "#9ece6a" :weight bold)))

(use-package! org-timeblock
  :after org
  :commands (org-timeblock org-timeblock-weekly))
