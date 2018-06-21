#!/bin/bash
jupyter nbconvert --allow-errors --to notebook --execute --ExecutePreprocessor.timeout=60 --output tests/test.out kdb+Notebooks.ipynb
jupyter nbconvert --to notebook --execute --ExecutePreprocessor.timeout=60 --output test.out examples/html_display.ipynb
pip -q install -r tests/requirements.txt
pytest -rx tests/test_jupyterq.py

