# make-project
***Easy, modern and lightweight Common LISP project setup***
## Getting started
- Make sure that you have `quicklisp` installed
- Clone this repository into some `ql:*local-project-directories*`
- Load the library with `(ql:quickload :make-project)`
- Create your new project with `(prj:new "insert-awesome-project-name-here")`
- If you want to initialize with dependencies: `(prj:new "project-name" "dep-1" "dep-2")`
## Dependencies
- ASDF (included in most implementations)
- quicklisp
- trivial-types
## Notes
- `make-project` adds `serapeum` and `alexandria` to all `:use` forms
- `make-project` currently is not on `quicklisp`, however this might change
## API
- `new`
