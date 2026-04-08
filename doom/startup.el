;;; startup.el -*- lexical-binding: t; -*-

(defconst crab/org-root (expand-file-name "~/Desktop/EmacsTry/"))
(defconst crab/org-inbox-file (expand-file-name "inbox.org" crab/org-root))
(defconst crab/org-tasks-file (expand-file-name "tasks.org" crab/org-root))
(defconst crab/org-notes-file (expand-file-name "notes.org" crab/org-root))

(setq confirm-kill-emacs nil
      default-directory crab/org-root
      org-directory crab/org-root
      org-agenda-files (list crab/org-inbox-file
                             crab/org-tasks-file
                             crab/org-notes-file)
      +doom-dashboard-functions nil)

(defun crab/open-default-notes-file ()
  (when (file-exists-p crab/org-inbox-file)
    (find-file crab/org-inbox-file)))

(add-hook 'emacs-startup-hook #'crab/open-default-notes-file)
