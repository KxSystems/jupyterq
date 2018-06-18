if defined QLIC_KC (
	jupyter nbconvert --allow-errors --to notebook --execute --ExecutePreprocessor.timeout=60 --output tests/test.out kdb+Notebooks.ipynb
        pip -q install -r tests\requirements.txt
        pytest -rx tests\test_jupyterq.py
)
