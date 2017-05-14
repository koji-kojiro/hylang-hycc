(import sys)
(import argparse)
(import [hy-compiler.core.build [build]])

(defn hy-compiler-main []
  (setv parser (argparse.ArgumentParser
                :usage "%(prog)s [options] module..."
                :add_help False))
  (setv parser._optionals.title "options")

  (.add_argument parser
                 "module"
                 :nargs "+"
                 :help argparse.SUPPRESS)
  (.add_argument parser
                 "--shared"
                 :action "store_true"
                 :help "create a shared library")
  (.add_argument parser
                 "--version"
                 :action "version")
  (.add_argument parser
                 "--help"
                 :action "help"
                 :help "show this help and exit")

  (setv options (.parse-args parser))
  
  (for [module options.module]
    (print (.format "compiling...: {}" module))
    (build module options.shared)))
