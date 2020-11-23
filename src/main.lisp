(defpackage :make-project/src/main
  (:use :common-lisp)
  (:import-from :trivial-types #:proper-list)
  (:export #:new #:make-asd #:make-packages))

(in-package :make-project/src/main)

(declaim (optimize (speed 2)
		   (safety 1)))

(declaim (ftype (function (string &optional (proper-list string))) new))
(defun new (name &optional deps)
  (make-asd name)
  (make-packages name deps))

(declaim (ftype (function (string &optional string)) make-asd))
(defun make-asd (name &optional (subdir "src"))
  (let ((path (format nil "~a/~a"
		      (first ql:*local-project-directories*)
		      (concatenate 'string name "/" name ".asd"))))
    (declare (type (string) path))
    (with-open-file (file (ensure-directories-exist path)
			  :direction :output
			  :if-exists :supersede)
      (if (not (null file))
	  (format file "(defsystem :~a~%  :class :package-inferred-system~%  :depends-on (\"~:*~a/~a/all\"))~%"
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
    (with-open-file (file (ensure-directories-exist all-file)
			  :direction :output
			  :if-exists :supersede)
      (format file "(defpackage :~a~%  (:use :common-lisp)~%  (:nicknames :~a)~%  (:import-from :~a))~%"
	      (concatenate 'string name "/" subdir "/all")
	      name
	      (concatenate 'string name "/" subdir "/main")))
    (with-open-file (file (ensure-directories-exist main-file)
			  :direction :output
			  :if-exists :supersede)
      (format file "(defpackage :~a~%  (:use :common-lisp)~{~&  (:import-from :~a)~})~%~%(in-package :~a)~%"
	      (concatenate 'string name "/" subdir "/main")
	      deps
	      (concatenate 'string name "/" subdir "/main")))))
