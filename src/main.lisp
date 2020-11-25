(defpackage :make-project/src/main
  (:use :common-lisp)
  (:import-from :trivial-types #:proper-list)
  (:export #:new #:make-asdf-system #:make-packages))

(in-package :make-project/src/main)

(declaim (optimize (speed 3)))

(declaim (ftype (function (keyword &optional (proper-list keyword))) new))
(defun new (name &rest deps)
  (make-asdf-system (string name))
  (make-packages (string name) deps))

(declaim (ftype (function (string &optional string)) make-asdf-system))
(defun make-asdf-system (name &optional (subdir "src"))
  (let* ((name* (string-downcase name))
         (path (make-pathname
                 :directory
                 (append (pathname-directory  (first ql:*local-project-directories*))
                         (list (pathname-name (first ql:*local-project-directories*)))
                         (list name*))
                 :name name*
                 :type "asd")))
    (declare (type pathname path))
    (with-open-file (file (ensure-directories-exist path)
                          :direction :output
                          :if-does-not-exist :create
                          :if-exists :supersede)
      (when (not (null file))
            (format file "(defsystem :~a~%  :class :package-inferred-system~%  :depends-on (\"~:*~a/~a/all\")~%"
                  name*
                  subdir)))))

(declaim (ftype (function (string (proper-list string) &optional string)) make-packages))
(defun make-packages (name deps &optional (subdir "src"))
  (let* ((name* (string-downcase name))
         (deps* (mapcar #'string-downcase deps))
         (all-file (make-pathname
                     :directory
                     (append (pathname-directory  (first ql:*local-project-directories*))
                             (list (pathname-name (first ql:*local-project-directories*)))
                             (list name* subdir))
                     :name "all"
                     :type "lisp"))
         (main-file (make-pathname
                      :directory
                      (append (pathname-directory  (first ql:*local-project-directories*))
                              (list (pathname-name (first ql:*local-project-directories*)))
                              (list name* subdir))
                      :name "main"
                      :type "lisp")))
    (declare (type pathname all-file))
    (declare (type pathname main-file))
    (with-open-file (file (ensure-directories-exist all-file)
                          :direction :output
                          :if-does-not-exist :create
                          :if-exists :supersede)
      (format file "(defpackage :~a~%  (:use :common-lisp :serapeum :alexandria)~%  (:nicknames :~a)~%  (:import-from :~a))~%"
              (concatenate 'string name* "/" subdir "/" "all")
              name*
              (concatenate 'string name* "/" subdir "/" "main")))
    (with-open-file (file (ensure-directories-exist main-file)
                          :direction :output
                          :if-does-not-exist :create
                          :if-exists :supersede)
      (if (null deps*)
          (format file "(defpackage :~a~%  (:use :common-lisp :serapeum :alexandria))~%~%(in-package :~a)~%"
                  (concatenate 'string name* "/" subdir "/" "main")
                  (concatenate 'string name* "/" subdir "/" "main"))
          (format file "(defpackage :~a~%  (:use :common-lisp :serapeum :alexandria)~{~&  (:import-from :~a)~})~%~%(in-package :~a)~%"
                  (concatenate 'string name* "/" subdir "/" "main")
                  deps*
                  (concatenate 'string name* "/" subdir "/" "main"))))))
