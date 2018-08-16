set QHOME=%PREFIX%\q
mkdir %QHOME%
where q
call build\compile.bat
call install.bat
exit /b 0
:error
exit /b %errorlevel%

