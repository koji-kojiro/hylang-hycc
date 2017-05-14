(import os sys shutil tempfile
        [Cython.Build.Cythonize [main :as cythonize-main]]
        [Cython.Build.BuildExecutable [build :as cython-build]]
        [hy-compiler.core.translate [to-python]])

(defn print-and-exit [msg]
  (print "error:" msg)
  (sys.exit))

(defn build [module &optional [shared False]]
  (if-not (os.path.exists module)
          (print-and-exit (.format "file does not exist: {}" module)))
  (try
   (setv pysrc (to-python module))
   (except [] (print-and-exit (.format "cannot convert to python: {}" module))))
  (setv temp-dir (tempfile.mkdtemp))
  (setv py-filepath
        (os.path.join
         temp-dir
         (+ (first (os.path.splitext (os.path.basename module))) ".py")))
  (try
   (do
    (with [fp (open py-filepath "w")]
          (.write fp pysrc))
    (with [null (open os.devnull "w")]
          (setv stderr sys.stderr
                stdout sys.stdout
                sys.stderr null
                sys.stdout null)
          (try
           (setv exe-filepath
                 (if shared
                   (do (cythonize-main [(str py-filepath) (str "--inplace") (str "--quiet")])
                       (last (sorted (list-comp (os.path.join temp-dir x)
                                                [x (os.listdir temp-dir)])
                                     :key os.path.getatime)))
                   (cython-build py-filepath))
                 sys.stderr stderr
                 sys.stdout stdout)
           (except [] (do (setv sys.stderr stderr
                                sys.stdout stdout)
                          (print-and-exit (.format "compile error: {}" module))))))
    (shutil.copy exe-filepath (os.path.join (os.path.dirname module)
                                            (os.path.basename exe-filepath))))
   (except [] None)
   (finally (shutil.rmtree temp-dir))))
