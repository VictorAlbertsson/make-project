(defpackage :make-project/src/main
  (:use :common-lisp)
  (:import-from :trivial-types #:proper-list)
  (:export #:new #:make-asdf-system #:make-packages))

(in-package :make-project/src/main)

(declaim (optimize (speed 2) (safety 1)))

(declaim (ftype (function (string &optional (proper-list string))) new))
(defun new (name &rest deps)
  (make-asdf-system name)
  (make-packages name deps))

(declaim (ftype (function (string &optional string)) make-asdf-system))
(defun make-asdf-system (name &optional (subdir "src"))
  (let ((path (format nil "~a/~a"
                      (first ql:*local-project-directories*)
                      (concatenate 'string name "/" name ".asd"))))

    (declare (type (string) path))
    (with-open-file (file (ensure-directories-exist path)
                          :direction :output
                          :if-does-not-exist :create
                          :if-exists :supersede)
      (when (not (null file))
            (format file "(defsystem :~a~%  :class :package-inferred-system~%  :depends-on (\"~:*~a/~a/all\")~%"
                  name
                  subdir)))))

(declaim (ftype (function (string (proper-list string) &optional string)) make-packages))
(defun make-packages (name deps &optional (subdir "src"))
  (let ((all-file (format nil "~a/~a"
                          (first ql:*local-project-directories*)
                          (concatenate 'string name "/" subdir "/all.lisp")))
        (main-file (format nil "~a/~a"
                           (first ql:*local-project-directories*)
                           (concatenate 'string name "/" subdir "/main.lisp"))))
    (declare (type (string) all-file))
    (declare (type (string) main-file))
    (with-open-file (file (ensure-directories-exist all-file)
                          :direction :output
                          :if-does-not-exist :create
                          :if-exists :supersede)
      (format file "(defpackage :~a~%  (:use :common-lisp :serapeum :alexandria)~%  (:nicknames :~a)~%  (:import-from :~a))~%"
              (concatenate 'string name "/" subdir "/all")
              name
              (concatenate 'string name "/" subdir "/main")))
    (with-open-file (file (ensure-directories-exist main-file)
                          :direction :output
                          :if-does-not-exist :create
                          :if-exists :supersede)
      ;; TODO If `deps` is empty don't include the `:import-from` line
      (if (null deps)
          (format file "(defpackage :~a~%  (:use :common-lisp :serapeum :alexandria))~%~%(in-package :~a)~%"
                  (concatenate 'string name "/" subdir "/main")
                  (concatenate 'string name "/" subdir "/main"))
          (format file "(defpackage :~a~%  (:use :common-lisp :serapeum :alexandria)~{~&  (:import-from :~a)~})~%~%(in-package :~a)~%"
                  (concatenate 'string name "/" subdir "/main")
                  deps
                  (concatenate 'string name "/" subdir "/main"))))))
