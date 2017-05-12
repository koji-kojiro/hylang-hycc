# -*- coding: utf-8 -*-
import argparse
from compiler import build


def main():
    parser = argparse.ArgumentParser(usage='%(prog)s [options] file')
    parser._optionals.title = 'options'
    parser.add_argument('file', nargs=1, help=argparse.SUPPRESS)
    parser.add_argument('--shared', action='store_true')
    parser.add_argument('-v', '--version', action='version', version='test')
    options = parser.parse_args()
    build(options.file[0], options.shared)


if __name__ == '__main__':
    main()
