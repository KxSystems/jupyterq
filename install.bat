@echo OFF
if not defined QHOME (
 echo set QHOME before running
 exit /b 1
)
if not exist %QHOME%\ (
 echo QHOME: %QHOME% does not exist
 exit /b 1
)
if not exist %QHOME%\w64\ (
 mkdir %QHOME%\w64 || goto :error
 )

jupyter kernelspec install --user --name=qpk %~dp0\kernelspec || goto :error
copy /Y %~dp0\jupyterq*.q %QHOME%\ || goto :error
xcopy %~dp0\kxpy %QHOME%\kxpy /I/S/E/H|| goto :error
copy /Y /B %~dp0\w64\jupyterq.dll %QHOME%\w64\ || goto :error
exit /b 0

:error
echo failed with error %errorLevel%
exit /b %errorLevel%
