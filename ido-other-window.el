;;; ido-other-window.el --- invoke ido completion in other window

;; Author: Tim C Harper <timcharper@gmail.com>
;; Maintainer: Georgi Valkov <georgi.t.valkov@gmail.com>
;; Version: 0.1
;; Created: 2012-07-15
;; Keywords: ido, convenience
;; EmacsWiki: InteractivelyDoThings
;; URL: https://github.com/gvalkov/ido-other-window


;;; Commentary:
;;
;; This plugin provides an alternative to the ido-*-other-window set of
;; commands. The following shortcuts will become available to everything that
;; relies on ido-completing-read:
;;
;;   C-o - invoke in other window
;;   C-2 - split vertically and invoke in other window
;;   C-3 - split horizontally and invoke in other window
;;   C-4 - invoke in other window
;;   C-5 - invoke in new frame
;;
;; It is the author and maintainer's strong conviction that this
;; functionality would make a nice addition to ido itself.


;;; Installation:
;;
;; Manual:
;;   1) Place ido-other-window.el on your emacs load-path.
;;   2) Add (require 'ido-other-window) to your .emacs or init.el.
;;
;; Package.el and MELPA:
;;   1) Enable MELPA: http://melpa.milkbox.net/#installing
;;   2) M-x package-install ido-other-window

;;; License:
;;
;; -- Original license not specified by author  --


;;; Code:
(require 'ido)

;;;###autoload
(eval-after-load "ido"
'(progn
   (defun split-window-vertically-and-switch ()
     (interactive)
     (split-window-vertically)
     (other-window 1))

   (defun split-window-horizontally-and-switch ()
     (interactive)
     (split-window-horizontally)
     (other-window 1))

   (defun ido-invoke-in-other-window ()
     "signals ido mode to switch to (or create) another window after exiting"
     (interactive)
     (setq ido-exit-minibuffer-target-window 'other)
     (ido-exit-minibuffer))

   (defun ido-invoke-in-horizontal-split ()
     "signals ido mode to split horizontally and switch after exiting"
     (interactive)
     (setq ido-exit-minibuffer-target-window 'horizontal)
     (ido-exit-minibuffer))

   (defun ido-invoke-in-vertical-split ()
     "signals ido mode to split vertically and switch after exiting"
     (interactive)
     (setq ido-exit-minibuffer-target-window 'vertical)
     (ido-exit-minibuffer))

   (defun ido-invoke-in-new-frame ()
     "signals ido mode to create a new frame after exiting"
     (interactive)
     (setq ido-exit-minibuffer-target-window 'frame)
     (ido-exit-minibuffer))

   (defadvice ido-read-internal (around ido-read-internal-with-minibuffer-other-window activate)
     (let* (ido-exit-minibuffer-target-window
            (this-buffer (current-buffer))
            (result ad-do-it))
       (cond
        ((equal ido-exit-minibuffer-target-window 'other)
         (if (= 1 (count-windows))
             (split-window-horizontally-and-switch)
           (other-window 1)))
        ((equal ido-exit-minibuffer-target-window 'horizontal)
         (split-window-horizontally-and-switch))

        ((equal ido-exit-minibuffer-target-window 'vertical)
         (split-window-vertically-and-switch))
        ((equal ido-exit-minibuffer-target-window 'frame)
         (make-frame)))

       ;; why? Some ido commands, such as textmate.el's
       ;; textmate-goto-symbol don't switch the current buffer
       (switch-to-buffer this-buffer)
       result))

   (defadvice ido-init-completion-maps (after ido-init-completion-maps-with-other-window-keys activate)
     (mapcar (lambda (map)
               (define-key map (kbd "C-o") 'ido-invoke-in-other-window)
               (define-key map (kbd "C-2") 'ido-invoke-in-vertical-split)
               (define-key map (kbd "C-3") 'ido-invoke-in-horizontal-split)
               (define-key map (kbd "C-4") 'ido-invoke-in-other-window)
               (define-key map (kbd "C-5") 'ido-invoke-in-new-frame))
             (list ido-buffer-completion-map
                   ido-common-completion-map
                   ido-file-completion-map
                   ido-file-dir-completion-map)))))

(provide 'ido-other-window)
;;; ido-other-window.el ends here
