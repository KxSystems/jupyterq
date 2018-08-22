7z a jupyterq_windows-%JUPYTERQ_VERSION%.zip jupyterq_*.q w64/jupyterq.dll install.bat requirements.txt kxpy kernelspec examples kdb+Notebooks.ipynb LICENSE README.md
appveyor PushArtifact jupyterq_windows-%JUPYTERQ_VERSION%.zip
exit /b 0
