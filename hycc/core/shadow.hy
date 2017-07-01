(defmacro set-dict-method [name]
  `(setattr self ~name
            (fn [&rest args &kwargs kwargs]
              (apply (getattr self.--dict ~name) args kwargs))))

(defclass hycc-dict [object]
  (defn --init-- [self dictionary]
    (setv self.--dict dictionary)
    (for [method ["clear" "keys" "viewkeys" "setdefault"
                  "iteritems" "itervalues" "fromkeys" "pop"
                  "values" "copy" "popitem" "viewitems"
                  "viewvalues" "viewkeys" "items" "iterkeys"
                  "update"]]
      (set-dict-method method)))

  (defn --mangle [self name]
    (import [hycc.core.translate [mangle]]
            [hy.compiler [hy-symbol-mangle]])
    (->> name hy-symbol-mangle mangle))

  (defn --repr-- [self]
    (.--repr-- self.--dict))

  (defn --getitem-- [self key]
    (try
     (get self.--dict key)
     (except [KeyError]
        (get self.--dict (.--mangle self key)))))

  (defn --setitem-- [self key value]
    (import [hycc.core.translate [mangle]]
            [hy.compiler [hy-symbol-mangle]])
    (try
     (setv (get self.--dict key) value)
     (except [KeyError]
       (do
        (setv (get self.--dict (.--mangle self key)) value)
        value))))

  (defn get [self key &optional default]
    (lif-not (.get self.--dict key)
     (lif-not (.get self.--dict (.--mangle self key))
       default (.get self.--dict (.--mangle self key)))
     (.get self.--dict key)))

  (defn has-key [self key]
    (if (.has-key self.--dict key)
      True (.has-key self.--dict (.--mangle self key))))

  (defn update [self &rest args &kwargs kwargs]
    (.append (list args) kwargs)
    (setv arg (.pop args))
    (for [item args]
      (.update arg args))
    (setv dummy-arg {})
    (for [key (.keys arg)]
      (setv (get dummy-arg (.--mangle self key)) (get arg key)))
    (.update self.--dict dummy-arg)))
