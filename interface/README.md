# interface

## Building

To build the interface:

```
elm make src/Main.elm --output=server/static/output.js
```

## Running

To serve the interface (assumes quicklisp is installed):
```
$ cd server && sbcl
* (load "main.lisp")
```
