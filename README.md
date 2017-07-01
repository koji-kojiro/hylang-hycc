# WIP; USE AT YOUR OWN RISK

# HyCC

[![MIT License](http://img.shields.io/badge/license-MIT-blue.svg?style=flat)](https://github.com/koji-kojiro/hylang-hycc/blob/master/LICENSE) [![python](https://img.shields.io/badge/python-2.7%2B%2C%203.3%2B-red.svg)](https://pypi.python.org/pypi/hycc) [![PyPI](https://img.shields.io/pypi/v/hycc.svg)](https://pypi.python.org/pypi/hycc) [![Build Status](https://travis-ci.org/koji-kojiro/hylang-hycc.svg?branch=master)](https://travis-ci.org/koji-kojiro/hylang-hycc)

**HyCC** is a static compiler for [**Hy**](https://github.com/hylang/hy), can create shared libraries and standalone executables from Hy source files.<br>
The input source file is once translated to C and then compiled to machine code.<br>
You may also get the generated C source code and compile it mannually with any C/C++ compilers.

One of the recommended uses is to compile a Hy module and create a shared library in order to improve its performance.<br>
In most cases, the compiled module runs much faster than Hy as well as Python, so we can say that `hycc` replaces `hyc` completely.

## Requirements

- hy >= 0.13.0 (or, the latest version on github)
- Cython >= 0.25.2

## Installation

```
$ pip install hycc
```

## Usage

```
$ hycc --help
usage: hycc [options] module...

options:
  -o <file>  place the output into <file>
  --clang    create c code; do not compile
  --python   create python code; do not compile
  --shared   create shared library
  --version  show program's version number and exit
  --help     show this help and exit
```

## Example

- hello.hy

```clojure
(defn hello []
  (print "hello"))

(defmain [&rest args]
  (hello))
```

### Create an executable file

```
$ hycc hello.hy
$ ./hello
hello
```

### Create a shared library

```
$ hycc hello.hy --shared
```

You can import this from Hy as well as Python.

```clojure
(import hello)
(hello.hello)
; > hello
```

```python
import hello
hello()
# > hello
```

**_Note: if you want to import module as a part of package, `__init__.py` is required instead of `--init--.hy`._**

## License

HyCC is distributed under [MIT license](LICENSE).

## Author

[TANI Kojiro](https://github.com/koji-kojiro) (kojiro0531@gmail.com)
