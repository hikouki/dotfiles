(defgroup poti nil
  "Customization group for `poti-mode'."
  :group 'frames)

(defvar poti-task-count 0)

(defun poti-refresh-task-count ()
  (interactive)
  "Fetch task count"
  (setq poti-task-count (length (todoist--get-tasks))))

(defun poti-create ()
  "Displays the number of unfinished tasks"
  (with-eval-after-load 'todoist
    (propertize (concat (all-the-icons-material "notifications" :height 0.7 :v-adjust -0.15) (number-to-string poti-task-count)))))

;;;###autoload
(define-minor-mode poti-mode
  "poti-mode"
  :global t
  :group 'poti
  (cond (poti-mode
         (poti-refresh-task-count))))

(provide 'poti-mode)
