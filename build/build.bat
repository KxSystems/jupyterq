set OP=%PATH%
call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars64.bat"
call build\compile.bat                               || goto :error
if "%APPVEYOR_REPO_TAG%"=="true" (
 set JUPYTERQ_VERSION=%APPVEYOR_REPO_TAG_NAME%
) else (
 set JUPYTERQ_VERSION=%APPVEYOR_REPO_BRANCH%_%APPVEYOR_REPO_COMMIT%
)
set PATH=C:\Perl;%PATH%
perl -p -i.bak -e s/JUPYTERQVERSION/`\$\"%JUPYTERQ_VERSION%\"/g jupyterq_kernel.q

if not defined QLIC_KC (
 goto :nokdb
)

@echo OFF
set PATH=%OP%
call build\getkdb.bat                                || goto :error
set PATH=C:\Miniconda3-x64;C:\Miniconda3-x64\Scripts;%PATH%
mkdir embedpy
cd embedpy
echo getembedpy"latest" | q ..\build\getembedpy.q -q || goto :error
cd ..
pip install -r requirements.txt                      || goto :error
call install.bat                                     || goto :error
exit /b 0

:error
echo failed with error %errorLevel%
set PATH=%OP%
exit /b %errorLevel%

:nokdb
echo no kdb
set PATH=%OP%
exit /b 0
