(import sys argparse
        [hycc [--version--]]
        [hycc.core.build [build]])

(defclass Formatter [argparse.RawTextHelpFormatter]
  (defn -format-args [self action default-metavar]
    (setv get-metavar (.-metavar-formatter self action default-metavar))
    (try
     (.format "<{0:s}>" (first (get-metavar 1)))
    (except [] ""))))

(defn hycc-main [&optional [argv (list (rest sys.argv))]]
  (setv parser (argparse.ArgumentParser
                :usage "%(prog)s [options] module..."
                :add_help False
                :formatter-class Formatter))

  (setv parser._optionals.title "options")
  (doto parser
        (.add-argument "module" :nargs "+" :help argparse.SUPPRESS)
        (.add-argument "-o" :nargs "*" :metavar "file"
                       :help "place the output into <file>")
        (.add-argument "--clang" :action "store_true"
                       :help "create c code; do not compile")
        (.add-argument "--python" :action "store_true"
                       :help "create python code; do not compile")
        (.add-argument "--shared" :action "store_true"
                       :help "create shared library")
        (.add-argument "--version" :action "version"
                       :version (+ "%(prog)s " --version--))
        (.add-argument "--help" :action "help"
                       :help "show this help and exit"))

  (setv options (.parse-args parser argv))
  (for [module options.module]
    (build module (if options.o (.pop options.o 0))
           options.shared options.clang options.python)))
