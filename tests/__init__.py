# -*- coding: utf-8 -*-
import os
from hycc.util import hycc_main


def clean():
    for path in os.listdir("tests/resources"):
        if path not in ["hello.hy", "__init__.py"]:
            path = os.path.join("tests/resources", path)
            if os.path.isdir(path):
                os.rmdir(path)
            else:
                os.remove(path)


def test_build_executable():
    hycc_main("tests/resources/hello.hy".split())
    assert os.path.exists("tests/resources/hello")
    clean()


def test_shared_library():
    hycc_main("tests/resources/hello.hy --shared".split())
    from tests.resources.hello import hello
    assert hello() == "hello"
    clean()
