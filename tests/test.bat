if defined QLIC_KC (
        pip -q install -r tests\requirements.txt
        jupyter nbconvert --allow-errors --to notebook --execute --ExecutePreprocessor.timeout=60 --output tests\test.out kdb+Notebooks.ipynb
        jupyter nbconvert --to notebook --execute --ExecutePreprocessor.timeout=60 --output test.out examples\html_display.ipynb
        jupyter nbconvert --allow-errors --to notebook --execute --ExecutePreprocessor.timeout=60 --output remotetest.out examples\remote_example.ipynb
        pytest -rx tests\test_jupyterq.py         
        python tests\pswdtest.py
        jupyter kernelspec install --user --name=qpk tests\kernelspec > NUL 2>&1
        set JUPYTERQ_LOGIN=user1:password
        pytest -rx tests\test_jupyterq.py
        set JUPYTERQ_LOGIN=
        jupyter kernelspec install --user --name=qpk kernelspec > NUL 2>&1
        
)
