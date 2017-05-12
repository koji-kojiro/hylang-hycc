# -*- coding: utf-8 -*-
import re
import ast
import astor
from hy._compat import PY3
from hy.importer import import_buffer_to_ast


def _mangle(name):
    return re.sub('[^a-zA-Z0-9_.]', lambda m: "x%X" % ord(m.group()), name)


def _attr_to_call(item, value=None):
    return ast.Call(
        func=ast.Name(id='setattr' if value else 'getattr'),
        args=(item.value, ast.Str(item.attr)) + ((value, ) if value else ()),
        keywords=(),
        starargs=None,
        kwargs=None)


def fix_from_imports(node):
    for i, item in enumerate(node.body):
        if isinstance(item, ast.ImportFrom):
            node.body[i] = ast.parse("import %s as _" % item.module)
            for name in map(lambda _: _.name, item.names):
                node.body.insert(
                    i + 1,
                    ast.Assign(
                        targets=[ast.Name(
                            id=name, ctx=ast.Store())],
                        value=ast.Call(
                            func=ast.Name(
                                id='getattr', ctx=ast.Load()),
                            args=[
                                ast.Name(
                                    id='_', ctx=ast.Load()), ast.Str(name)
                            ],
                            keywords=[],
                            starargs=None,
                            kwargs=None)))
        elif hasattr(item, 'body'):
            fix_from_imports(item)


def fix_dot_access(node):
    if isinstance(node, ast.Assign):
        fix_dot_access(node.targets[0])
        if isinstance(node.targets[0], ast.Attribute):
            node.value = _attr_to_call(node.targets[0], node.value)
            node.targets = '_'
    else:
        for item, field in astor.iter_node(node):
            fix_dot_access(item)
            if isinstance(item, ast.Attribute):
                setattr(node, field, _attr_to_call(item))


def mangle_all_names(node):
    for item in ast.walk(node):
        if isinstance(item, ast.Name):
            item.id = _mangle(item.id)
        elif isinstance(item, ast.FunctionDef):
            item.name = _mangle(item.name)
        elif isinstance(item, ast.ClassDef):
            item.name = _mangle(item.name)
        elif isinstance(item, ast.alias):
            item.name = _mangle(item.name)


def to_python(filepath):
    with open(filepath, 'r') as f:
        src = f.read()
    _ast = import_buffer_to_ast(src, module_name='<string>')
    fix_dot_access(_ast)
    fix_from_imports(_ast)
    mangle_all_names(_ast)

    return ('from __future__ import print_function\n'
            if not PY3 else '') + astor.codegen.to_source(_ast)
