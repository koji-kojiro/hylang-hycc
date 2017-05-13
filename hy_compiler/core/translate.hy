(import re ast
        [hy._compat [PY3]]
        [hy.importer [import-buffer-to-ast]]
        [astor [iter-node]]
        [astor.codegen [to-source]])

(defn mangle [name]
  (re.sub "[^a-zA-Z_.]"
          (fn [matchobj](->> (ord (.group matchobj)) (.format "x{0:X}")))
          name))

(defn attr-to-call [attr &optional [value None]]
  (ast.Call
   :func (ast.Name :id (lif value "setattr" "getattr"))
   :args [attr.value (ast.Str attr.attr) value]
   :keywords None
   :starargs None
   :kwargs None))

(defn fix-from-imports [node]
  (for [[index item] (enumerate node.body)]
    (if (isinstance item ast.ImportFrom)
      (do (setv (get node.body index)
                (ast.parse (.format "import {} as _" item.module)))
          (for [name (map (fn [item] item.name) item.names)]
            (.insert node.body
                     (inc index)
                     (ast.Assign
                      :targets [(ast.Name :id name :ctx (ast.Store))]
                      :value (ast.Call
                              :func (ast.Name :id "getattr" :ctx (ast.Load))
                              :args [(ast.Name :id "_" :ctx (ast.Load))
                                     (ast.Str name)]
                              :keywords []
                              :starargs None
                              :kwargs None)))))
      (hasattr item "body")
      (fix-from-imports item))))

(defn fix-dot-access [node]
  (if (isinstance node ast.Assign)
    (do
     (fix-dot-access (get node.targets 0))
     (if (isinstance (get node.targets 0) ast.Assign)
       (setv node.value (attr-to-call (get node.targets 0) node.value)
             node.targets "_")))
    (for [[item field] (iter-node node)]
      (fix-dot-access item)
      (if (isinstance item ast.Attribute)
        (setattr node field (attr-to-call item))))))

(defn mangle-all [node]
  (for [item (ast.walk node)]
    (cond [(isinstance item ast.Name) (setv item.id (mangle item.id))]
          [(isinstance item ast.FunctionDef) (setv item.name (mangle item.name))]
          [(isinstance item ast.ClassDef) (setv item.name (mangle item.name))]
          [(isinstance item ast.alias) (setv item.name (mangle item.name))])))

(defn to-python [filepath]
  (with [fp (open filepath "r")]
        (setv tree (import-buffer-to-ast (.read fp) :module-name "<string>"))
        (fix-dot-access tree)
        (fix-from-imports tree)
        (mangle-all tree))
  (+ (if-not PY3 "from __future__ import print_function\n" "")
     (to-source tree)))
