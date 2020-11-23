(defpackage :make-project/src/all
  (:use :common-lisp)
  (:nicknames :make-project :prj)
  (:import-from :make-project/src/main #:new)
  (:export #:new))
