#!/usr/bin/env python
# -*- coding: utf-8 -*-
from setuptools import setup
from sys import version_info

ver = version_info[0]

config = {
    'name': 'hycc',
    'author': 'koji-kojiro',
    'author_email': 'kojiro0531@gmail.com',
    'url': 'https://github.com/koji-kojiro/hylang-hycc',
    'description': 'HyCC - A static compiler for Hy',
    'long_description': 'HyCC - A static compiler for Hy',
    'license': 'MIT',
    'version': '0.1.1',
    'install_requires': ['Cython>=0.25.2', 'hy>=0.12.1'],
    'classifiers': [
        "Operating System :: POSIX",
        "Operating System :: MacOS",
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
        "Development Status :: 4 - Beta",
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
    'test_suite': 'nose.collector',
}

if __name__ == '__main__':
    setup(**config)
