"""
Tests for jupyterq, adapted from test_ipykernel.py from jupyter_kernel_test
"""

import unittest
import jupyter_kernel_test as jkt
import os

class QKernelTests(jkt.KernelTests):

    kernel_name = "qpk"

    language_name = "q"

    file_extension = ".q"

    # code which should write the exact string `hello, world` to STDOUT
    code_hello_world = '-1"hello, world";'

    code_stderr = '-2"some error"'

    completion_samples = [
        {
            'text': 'ma',
            'matches': {'max','maxs','mavg'},
        },
    ]

    complete_code_samples = ['1', "p)print('hello, world')", "{amultiline\n function\n\t}","select from abc","select from\n abc",'"a string"']
    incomplete_code_samples = ["{incompletef", "{[a]incomplete","{incomplete\n\tmultiline","select","$["]
    invalid_code_samples = ['{[missing function params\n}',"missingopen}","missingopen]","missing[\nbutnotonlastline","missing{\nbutnotonlastline","invaliddsl)"]

    code_generate_error = '\'"anerror"'

    code_execute_result = [
        {'code': "1 2 3+4", 'result': "5 6 7"+os.linesep},
        {'code': "`a`b!1 2", 'result': "a| 1"+os.linesep+"b| 2"+os.linesep}
    ]

    code_display_data = [
        {'code': "p)from IPython.display import HTML, display; display(HTML('<b>test</b>'))",
         'mime': "text/html"},
        {'code': "p)from IPython.display import Math, display; display(Math('\\\\frac{1}{2}'))",
         'mime': "text/latex"}
    ]

    code_inspect_sample = "select"

    code_clear_output = ".qpk.clearoutput 1b "

if __name__ == '__main__':
    unittest.main()
