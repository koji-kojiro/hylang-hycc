# -*- coding: utf-8 -*-
from __future__ import print_function
import os
import sys
import shutil
import tempfile
from Cython.Build.Cythonize import main as cythonize_main
from Cython.Build.BuildExecutable import build as cython_build
from to_python import to_python


def _print_and_exit(msg, status=1):
    print(msg)
    sys.exit(status)


def build(module, shared=False):
    try:
        pysrc = to_python(module)
    except:
        _print_and_exit('cannot open file: {}'.format(module))
    temp_dir = tempfile.mkdtemp()
    try:
        py_filepath = os.path.join(
            temp_dir, os.path.splitext(os.path.basename(module))[0] + '.py')
        with open(py_filepath, 'w') as f:
            try:
                f.write(pysrc)
            except:
                _print_and_exit('cannot convert to python: {}'.format(module))
        with open(os.devnull, 'w') as null:
            err, out = sys.stderr, sys.stdout
            sys.stderr, sys.stdout = null, null
            try:
                if shared:
                    cythonize_main([py_filepath, '--build', '--inplace'])
                    exe_filepath = sorted(
                        [
                            os.path.join(temp_dir, x)
                            for x in os.listdir(temp_dir)
                        ],
                        key=os.path.getmtime)[-1]
                else:
                    exe_filepath = cython_build(py_filepath)
                    sys.stderr, sys.stdout = err, out
            except:
                sys.stderr, sys.stdout = err, out
                _print_and_exit('compile error: {}'.format(module))
        shutil.copy(exe_filepath,
                    os.path.join(
                        os.path.dirname(module),
                        os.path.basename(exe_filepath)))
    except:
        pass
    finally:
        shutil.rmtree(temp_dir)
