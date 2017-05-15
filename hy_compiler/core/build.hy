(import os sys shutil tempfile
        [Cython.Build.Cythonize [main :as cythonize-main]]
        [Cython.Build.BuildExecutable [build :as cython-build]]
        [hy-compiler.core.translate [to-python]])

(defn print-and-exit [msg]
  (print "error:" msg)
  (sys.exit))

(defn build [module &optional [output None] [shared False] [with-c False] [with-python False]]
  (print (.format "compiling: {}" module))
  (if-not (os.path.exists module)
          (print-and-exit (.format "file does not exist: {}" module)))
  (try
   (setv pysrc (to-python module))
   (except [] (print-and-exit (.format "cannot convert to python: {}" module))))
  (setv temp-dir (tempfile.mkdtemp)
        module-dir (os.path.dirname module))
  (setv py-filepath
        (os.path.join
         temp-dir
         (+ (lif output output
                 (first (os.path.splitext (os.path.basename module)))) ".py")))

  (with [fp (open py-filepath "w")]
        (.write fp pysrc))
  (with [null (open os.devnull "w")]
        (setv stderr sys.stderr
              stdout sys.stdout
              sys.stderr null
              sys.stdout null)
        (setv exe-filepath
              (if shared
                (do (cythonize-main [(str py-filepath) (str "--inplace") (str "--quiet")])
                    (last (sorted (list-comp (os.path.join temp-dir x)
                                             [x (os.listdir temp-dir)])
                                  :key os.path.getatime)))
                (cython-build py-filepath))
              sys.stderr stderr
              sys.stdout stdout))
  (if with-python
    (do
     (shutil.copy py-filepath
                  (os.path.join module-dir (os.path.basename py-filepath)))
     (print (.format "-> {}" (os.path.join module-dir
                                           (os.path.basename py-filepath))))))
  (if with-c
    (do
     (setv c-filepath (.replace py-filepath ".py" ".c"))
     (shutil.copy c-filepath
                  (os.path.join (os.path.dirname module)
                                (os.path.basename c-filepath)))
     (print (.format "-> {}" (os.path.join (os.path.dirname module)
                                           (os.path.basename c-filepath))))))

  (shutil.copy exe-filepath (os.path.join module-dir
                                          (os.path.basename exe-filepath)))
  (print (.format "-> {}" (os.path.join module-dir
                                        (os.path.basename exe-filepath))))
  (shutil.rmtree temp-dir))
