(import os sys
        [tempfile [mkdtemp]]
        [shutil [copy rmtree]]
        [Cython.Build.Cythonize [main :as cythonize-main]]
        [Cython.Build.BuildExecutable [build :as cython-build]]
        [hy-compiler.core.translate [to-python]])

(defn print-and-exit [msg]
  (print "error:" msg)
  (sys.exit))

(defn build-executable [filepath]
  (cython-build filepath))

(defn build-shared-library [filepath]
  (cythonize-main [(str filepath) (str "--inplace") (str "--quiet")])
  (setv dirpath (os.path.dirname filepath))
  (last (sorted (list-comp (os.path.join dirpath x) [x (os.listdir dirpath)])
                :key os.path.getatime)))

(defn do-quiet [func &rest args]
  (with [null (open os.devnull "w")]
        (setv stderr sys.stderr
              stdout sys.stdout
              sys.stderr null
              sys.stdout null
              ret (apply func args))
        (setv sys.stderr stderr
              sys.stdout stdout))
  ret)

(defn mkcopy [module-dir filepath]
  (setv dest-filepath (os.path.join module-dir (os.path.basename filepath)))
  (copy filepath dest-filepath)
  (print (.format "-> {}" dest-filepath)))

(defn build [module &optional [output None]
                              [shared False]
                              [with-c False]
                              [with-python False]]

  (print (.format "compiling: {}" module))
  (if-not (os.path.exists module)
          (print-and-exit (.format "file does not exist: {}" module)))
  (if-not (= (last (os.path.splitext module)) ".hy")
          (print-and-exit (.format "only `.hy` file is acceptable: {}" module)))

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
   (except [] (print-and-exit (.format "cannot convert to python: {}" module))))

  (with [fp (open py-filepath "w")]
        (.write fp pysrc))

  (setv build-func (if shared build-shared-library build-executable)
        bin-filepath (do-quiet build-func py-filepath)
        )

  (if with-python
    (mkcopy dest-dir py-filepath))
  (setv c-filepath (.replace py-filepath ".py" ".c"))
  (if with-c
    (mkcopy dest-dir c-filepath))
  (mkcopy dest-dir bin-filepath)
  (rmtree temp-dir))
