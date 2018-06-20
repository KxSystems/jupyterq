if "%APPVEYOR_REPO_TAG%"=="true" (
        call :version %APPVEYOR_REPO_TAG_NAME%
    ) else (
        call :version %APPVEYOR_REPO_BRANCH%-%APPVEYOR_REPO_COMMIT%
)

exit /b 0
:version
	set PATH=C:\Perl;%PATH%
	perl -p -i.bak -e s/JUPYTERQVERSION/`\$\"%1\"/g jupyterq_kernel.q
        7z a jupyterq_windows-%1.zip jupyterq_*.q w64/jupyterq.dll install.bat kxpy kernelspec examples kdb+Notebooks.ipynb LICENSE README.md && appveyor PushArtifact jupyterq_windows-%1.zip
