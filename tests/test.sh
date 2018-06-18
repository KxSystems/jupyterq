#!/bin/bash
jupyter nbconvert --allow-errors --to notebook --execute --ExecutePreprocessor.timeout=60 --output tests/test.out kdb+Notebooks.ipynb
pip -q install tests/requirements.txt
py.test -rx tests/test_jupyterq.py

