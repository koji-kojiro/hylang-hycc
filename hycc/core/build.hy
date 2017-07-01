(import os sys
        [tempfile [mkdtemp]]
        [shutil [copy rmtree]]
        [Cython.Build.Cythonize [main :as cythonize-main]]
        [Cython.Build.BuildExecutable [build :as cython-build]]
        [hycc.core.translate [to-python]])

(defn print-and-exit [msg]
  (sys.exit (+ "hycc: error: " msg)))

(defn build-executable [filepath]
  (cython-build filepath))

(defn build-shared-library [filepath]
  (cythonize-main [(str filepath) (str "--inplace") (str "--quiet")])
  (setv dirpath (os.path.dirname filepath))
  (as-> (os.listdir dirpath) it
        (list-comp (os.path.join dirpath x) [x it])
        (filter os.path.isfile it)
        (sorted it :key os.path.getatime)
        (last it)))


(defn do-quiet [func &rest args]
  (try
   (with [null (open os.devnull "w")]
         (setv stderr sys.stderr
               stdout sys.stdout
               sys.stderr null
               sys.stdout null
               ret (apply func args)
               sys.stderr stderr
               sys.stdout stdout)
         ret)
   (except []
     (do
      (setv sys.stderr stderr
            sys.stdout stdout)
      (print-and-exit "compile error")))))

(defn mkcopy [module-dir filepath]
  (setv dest-filepath (os.path.join module-dir (os.path.basename filepath)))
  (copy filepath dest-filepath)
  (print (+ "-> " dest-filepath)))

(defn build [module &optional [output None]
                              [shared? False]
                              [clang? False]
                              [python? False]]

  (print (+ "compiling: " module))
  (if-not (os.path.exists module)
          (print-and-exit (+ "file does not exist: " module)))
  (setv ext (last (os.path.splitext module)))
  (if-not (= ext  ".hy")
          (print-and-exit (+ "invalid file type: " ext)))

  (setv temp-dir (mkdtemp))

  (lif output
       (setv py-filepath (os.path.join temp-dir
                                       (+ (os.path.basename output) ".py"))
             dest-dir (os.path.dirname output))
       (setv py-filepath (os.path.join temp-dir
                                       (.replace (os.path.basename module) ".hy" ".py"))
             dest-dir (os.path.dirname module)))
  (if-not dest-dir
          (setv dest-dir "./"))
  (if-not (os.path.exists dest-dir)
          (os.makedirs dest-dir))

  (try
   (setv pysrc (to-python module))
   (except []
     (do
      (rmtree temp-dir)
      (print-and-exit (+ "cannot convert to python: " module)))))

  (try
   (do
    (with [fp (open py-filepath "w")]
          (.write fp pysrc))

    (if python?
      (mkcopy dest-dir py-filepath)
      (do
       (setv build-func (if shared? build-shared-library build-executable)
             bin-filepath (do-quiet build-func py-filepath)
             c-filepath (.replace py-filepath ".py" ".c"))
       (if clang?
         (mkcopy dest-dir c-filepath)
         (mkcopy dest-dir bin-filepath)))))
   (except [] (print (+ "hycc: error: failed to compile file: " module)))
   (finally (rmtree temp-dir))))
