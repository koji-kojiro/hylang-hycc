#!/usr/bin/env python
# -*- coding: utf-8 -*-


def main():
    import pip
    pip.main("install git+https://github.com/hylang/hy".split())

    import os
    import hy
    import hycc

    print("hy version: {}".format(hy.__version__))

    for dirname, _, filenames in os.walk(os.path.dirname(hycc.__file__)):
        for filename in filenames:
            if filename.endswith('.hy'):
                print('compiling: {}'.format(filename))
                hy.importer.write_hy_as_pyc(os.path.join(dirname, filename))
