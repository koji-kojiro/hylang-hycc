(import sys argparse
        [hycc [--version--]]
        [hycc.core.build [build]])

(defn hycc-main []
  (setv parser (argparse.ArgumentParser
                :usage "%(prog)s [options] module..."
                :add_help False))
  (setv parser._optionals.title "options")

  (.add_argument parser
                 "module"
                 :nargs "+"
                 :help argparse.SUPPRESS)
  (.add_argument parser
                 "-o"
                 :nargs "+"
                 :metavar "file"
                 :help "place the output into [file]")
  (.add_argument parser
                 "--with-c"
                 :action "store_true"
                 :help "generate c code")
  (.add_argument parser
                 "--with-python"
                 :action "store_true"
                 :help "generate python code")
  (.add_argument parser
                 "--shared"
                 :action "store_true"
                 :help "create shared library")
  (.add_argument parser
                 "--version"
                 :action "version"
                 :version --version--)
  (.add_argument parser
                 "--help"
                 :action "help"
                 :help "show this help and exit")

  (setv options (.parse-args parser))
  (for [module options.module]
    (build module (if options.o (.pop options.o 0))
           options.shared options.with-c options.with-python)))
