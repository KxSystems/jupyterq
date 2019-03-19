set QHOME=%PREFIX%\q
mkdir %QHOME%
where q
call build\compile.bat
copy /Y kernelspec\winkernel.json kernelspec\kernel.json || goto :error
copy /Y jupyterq*.q? %QHOME%\ || goto :error
xcopy kxpy %QHOME%\kxpy /I/S/E/H|| goto :error
copy /Y /B w64\jupyterq.dll %QHOME%\w64\ || goto :error
set JK=%PREFIX%\share\jupyter\kernels\qpk
set JL=jupyterq_licensemgr\jupyterq_licensemgr
mkdir %JK%
mkdir %PREFIX%\etc\jupyter\jupyter_notebook_config.d
mkdir %PREFIX%\etc\jupyter\nbconfig\notebook.d
mkdir %PREFIX%\share\jupyter\nbextensions\jupyterq_licensemgr
copy kernelspec\* %JK%

cd jupyterq_licensemgr
python setup.py install
cd ..

copy %JL%\index.js %PREFIX%\share\jupyter\nbextensions\jupyterq_licensemgr
copy %JL%\jupyterq_licensemgr.json %PREFIX%\etc\jupyter\nbconfig\notebook.d
copy %JL%\jupyterq_licensemgr_config.json %PREFIX%\etc\jupyter\jupyter_notebook_config.d

exit /b 0
:error
exit /b %errorlevel%

