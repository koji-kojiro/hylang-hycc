# -*- coding: utf-8 -*-
import os
from hycc.util import hycc_main


def clean():
    for path in os.listdir("tests/resources"):
        if path not in ["hello.hy", "__init__.py"]:
            os.remove(os.path.join("tests/resources", path))


def test_build_executable():
    hycc_main("tests/resources/hello.hy".split())
    assert os.path.exists("tests/resources/hello")
    clean()


def test_shared_library():
    hycc_main("tests/resources/hello.hy --shared".split())
    from tests.resources.hello import hello
    assert hello() == "hello"
    clean()
