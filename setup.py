#!/usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import print_function
from setuptools import setup
from setuptools.command.install import _install

from sys import version_info
ver = version_info[0]


class install(_install):
    def __init__(self, *args, **kwargs):
        import pip
        import atexit

        pip.main("install git+https://github.com/hylang/hy".split())

        _install.__init__(self, *args, **kwargs)
        atexit.register(self._compile_hy)

    def _compile_hy(self):
        import os
        import hy
        import hycc

        print("hy version: {}".format(hy.__version__))

        for dirname, _, filenames in os.walk(os.path.dirname(hycc.__file__)):
            for filename in filenames:
                if filename.endswith('.hy'):
                    print('compiling: {}'.format(filename))
                    hy.importer.write_hy_as_pyc(
                        os.path.join(dirname, filename))


config = {
    'name': 'hycc',
    'author': 'koji-kojiro',
    'author_email': 'kojiro0531@gmail.com',
    'url': 'https://github.com/koji-kojiro/hylang-hycc',
    'description': 'HyCC - A static compiler for Hy',
    'long_description': 'HyCC - A static compiler for Hy',
    'license': 'MIT',
    'version': '0.0.1',
    'install_requires': ['Cython>=0.25.2', 'hy>=0.12.1'],
    'classifiers': [
        "Intended Audience :: Developers",
        "Programming Language :: Lisp",
        "Programming Language :: Python",
        "Programming Language :: Python :: 2",
        "Programming Language :: Python :: 2.7",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.3",
        "Programming Language :: Python :: 3.4",
        "Programming Language :: Python :: 3.5",
        "Topic :: Software Development :: Code Generators",
        "Topic :: Software Development :: Compilers",
        "License :: OSI Approved :: MIT License",
        "Development Status :: 1 - Planning",
    ],
    'packages': ['hycc', 'hycc.core'],
    'package_data': {
        'hycc': ['*.hy'],
        'hycc.core': ['*.hy'],
    },
    'entry_points': {
        'console_scripts': [
            'hycc=hycc.util:hycc_main',
            'hycc%d=hycc.util:hycc_main' % ver,
        ]
    },
    'cmdclass': {
        'install': install
    },
}

if __name__ == '__main__':
    setup(**config)
