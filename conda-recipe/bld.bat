set QHOME=%PREFIX%\q
mkdir %QHOME%
where q
call build\compile.bat
copy /Y kernelspec\winkernel.json kernelspec\kernel.json || goto :error
copy /Y jupyterq*.q? %QHOME%\ || goto :error
xcopy kxpy %QHOME%\kxpy /I/S/E/H|| goto :error
copy /Y /B w64\jupyterq.dll %QHOME%\w64\ || goto :error
set JK=%PREFIX%\share\jupyter\kernels\qpk
mkdir %JK%
copy kernelspec\* %JK%

exit /b 0
:error
exit /b %errorlevel%

