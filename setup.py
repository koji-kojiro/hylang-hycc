#!/usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import print_function
import atexit
from setuptools import setup
from setuptools.command.install import install


class install_with_compile_hy(install):
    def __init__(self, *args, **kwargs):
        install.__init__(self, *args, **kwargs)
        atexit.register(self._compile_hy)

    def _compile_hy(self):
        import hy
        import hy_compiler.util
        import hy_compiler.core

        print("hy version: {}".format(hy.__version__))
        print("compiled: {}".format(hy_compiler.util.__file__))
        print("compiled: {}".format(hy_compiler.core.__file__))


config = {
    'name': 'hy-compiler',
    'author': 'koji-kojiro',
    'author_email': 'kojiro0531@gmail.com',
    'url': '',
    'description': '',
    'long_description': open('README.rst', 'r').read(),
    'license': 'MIT',
    'version': '0.0.1',
    'install_requires': [],
    'classifiers': [
        "Programming Language :: Python",
        "Programming Language :: Python :: 2",
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: MIT License",
        "Development Status :: 1 - Planning",
    ],
    'packages': ['hy_compiler', 'hy_compiler.core'],
    'package_data': {
        'hy_compiler': ['*.hy'],
        'hy_compiler.core': ['*.hy'],
    },
    'entry_points':
    '[console_scripts]\nhy-compiler=hy_compiler.util:hy_compiler_main',
    'cmdclass': {
        'install': install_with_compile_hy
    },
}

if __name__ == '__main__':
    setup(**config)
