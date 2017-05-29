(in-package #:df-cl-utils)

(defvar *dbp-count* 0)

(defun dbpe (&key (stream t) (increase-count? t) (place-for-count 4) (place-for-prefix 17) (trailing-newline? t) (delimiter " ") (add-prefixes? t) (use-first-as-prefix-part? t) (output-list (error "DBPE NEEDS OUTPUT-LIST ARGUMENT")))
  "extended"
  (let* ((prefix-count (format nil
                               (format nil "~~~AA " place-for-count)
                               (format nil "~A>" *dbp-count*)))
         (prefix (if use-first-as-prefix-part?
                     (format nil
                             (format nil "~~~AA " place-for-prefix)
                             (format nil "~A ~A" prefix-count (car output-list)))
                     prefix-count))
         (output-list (if use-first-as-prefix-part? (cdr output-list) output-list)))
    (labels ((%apply-autistic-formatting (list)
               (mapcar (lambda (el) (if (eq el :nl) (format nil "~%") (format nil "~A~A" el delimiter))) list))
             (%intercept-newlines-with-prefix (string)
               (coerce
                (loop for c across string
                      appending (if (eq c #\newline)
                                    (cons #\newline (coerce prefix 'list))
                                    (list c)))
                'string)))
      (let ((str (format nil "~@[~{~A~}~]" (%apply-autistic-formatting output-list))))
        (format stream "~A~:[~;~%~]" (format nil "~A~A" prefix (if add-prefixes? (%intercept-newlines-with-prefix str) str)) trailing-newline?)
        (when increase-count? (incf *dbp-count*))))))

(defun dbp (&rest output-list)
  "simple"
  (dbpe :stream t :increase-count? t :place-for-count 4 :place-for-prefix 20 :trailing-newline? t :delimiter " " :add-prefixes? t :use-first-as-prefix-part? t :output-list output-list))

(defmacro dbps (&rest output-list-list)
  "several with implicit :nl"
  `(progn 
     ,@(mapcar (lambda (output-list) `(dbpe :increase-count? nil :output-list ',output-list)) (butlast output-list-list))
     (dbpe :increase-count? t :output-list ',(car (last output-list-list)))))

(defun dbp-reset ()
  (setf *dbp-count* 0))
