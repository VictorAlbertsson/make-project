# make-project
***Easy and modern Common LISP project setup***
## Getting started
- Make sure that you have `quicklisp` and `trivial-types` installed
- Clone this repository into some `ql:*local-project-directories*`
- Load the library with `(ql:quickload :make-project)`
- Create your new project with `(prj:new :insert-awesome-project-name-here)`
## Dependencies
- ASDF
- quicklisp
- trivial-types
## API
- `new`
- `make-asd`
- `make-packages`
