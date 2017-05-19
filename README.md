# WIP; USE AT YOUR OWN RISK
# HyCC
**HyCC** is a static compiler for [**Hy**](https://github.com/hylang/hy), can create shared libraries and standalone executables from Hy source files.
The input source file is once translated to C and then compiled to machine code.
You may also get the generated C source code and compile it mannually with any C/C++ compilers.

One of the recommended uses is to compile a Hy module and create a shared library in order to improve its performance.
In most cases, the compiled module runs much faster than Hy as well as Python, so we can say that `hycc` replaces `hyc` completely.

## Requirements
- hy (latest)
- Cython >= 0.25.2

## Installation
```
$ pip install hycc
$ activate-hycc
```

## Usage
```
$ hycc --help
usage: hycc [options] module...

options:
  -o <file>      place the output into <file>
  --with-c       generate c code
  --with-python  generate python code
  --shared       create shared library
  --version      show program's version number and exit
  --help         show this help and exit

```
## Example
- hello.hy

```clj
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

```clj
(import hello)
(hello.hello)
; > hello
```

```py
import hello
hello()
# > hello
```

## License
HyCC is distributed under [MIT license](LICENSE).

## Author
[TANI Kojiro](https://github.com/koji-kojiro) (kojiro0531@gmail.com)
