(import re ast copy
        [hy.importer [import-buffer-to-ast]]
        [astor [iter-node]]
        [astor.codegen [to-source]])

(defn mangle [name]
  (re.sub "[^a-zA-Z0-9_.]"
          (fn [m](->> (ord (.group m)) (.format "x{0:X}"))) name))

(defn attr-to-call [attr &optional [value None]]
  (ast.Call
   :func (ast.Name :id (lif value "setattr" "getattr"))
   :args (+ [attr.value (ast.Str attr.attr)] (lif value [value] []))
   :keywords []
   :starargs None
   :kwargs None))

(defn fix-from-imports [node]
  (for [[index item] (enumerate node.body)]
    (when (instance? ast.ImportFrom item)
      (setv (get node.body index)
            (ast.parse (.format "import {} as _" item.module)))
      (for [name item.names]
        (setv dst-name (lif name.asname name.asname name.name)
              src-name name.name)
        (.insert node.body
                 (inc index)
                 (ast.Assign
                  :targets [(ast.Name :id dst-name :ctx (ast.Store))]
                  :value (ast.Call
                          :func (ast.Name :id "getattr" :ctx (ast.Load))
                          :args [(ast.Name :id "_" :ctx (ast.Load))
                                 (ast.Str src-name)]
                          :keywords []
                          :starargs None
                          :kwargs None)))))
      (when (hasattr item "body")
        (fix-from-imports item))))

(defn fix-dot-access [node]
  (if (instance? ast.Assign node)
    (do
     (fix-dot-access (first node.targets))
     (when (instance? ast.Attribute (first node.targets))
       (setv node.value (attr-to-call (first node.targets) node.value)
             node.targets "_")))
    (for [[item field] (iter-node node)]
      (fix-dot-access item)
      (when (instance? ast.Attribute item)
        (if (hasattr node "_fields")
          (setattr node field (attr-to-call item))
          (for [[index _] (enumerate node)]
            (setv (get node index) (attr-to-call (get node index)))))))))

(defn mangle-all [node]
  (for [item (ast.walk node)]
    (cond [(instance? ast.Name item)
           (setv item.id (mangle item.id))]
          [(instance? ast.FunctionDef item)
           (setv item.name (mangle item.name))]
          [(instance? ast.ClassDef item)
           (setv item.name (mangle item.name))]
          [(instance? ast.alias item)
           (do (lif item.asname (setv item.asname (mangle item.asname)))
               (setv item.name (mangle item.name)))])))

(defn fix-globals-and-locals [node]
  (setv fixed? False)
  (for [item (ast.walk node)]
    (when (instance? ast.Call item)
      (when (instance? ast.Name item.func)
        (when (in item.func.id ["globals" "locals"])
          (setv fixed? True)
          (.append item.args (copy.deepcopy item))
          (setv item.func.id "hycc.core.shadow.hycc_dict")))))
  fixed?)

(defn add-imports [src add-shadow?]
  (+ "from __future__ import print_function\n"
     (if add-shadow? "import hycc.core.shadow\n" "import hy\n")
     src))


(defn to-python [filepath]
  (with [fp (open filepath "r")]
        (setv src (.read fp)))
  (setv tree (import-buffer-to-ast src :module-name "<string>"))
  (fix-dot-access tree)
  (fix-from-imports tree)
  (mangle-all tree)
  (setv fixed? (fix-globals-and-locals tree))
  (add-imports (to-source tree) fixed?))
