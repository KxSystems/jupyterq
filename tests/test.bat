if defined QLIC_KC (
	jupyter nbconvert --allow-errors --to notebook --execute --ExecutePreprocessor.timeout=60 --output tests/test.out kdb+Notebooks.ipynb
)
