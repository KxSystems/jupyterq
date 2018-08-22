if not defined QLIC (
 goto :nokdb
)
call tests\test.bat || goto :error
exit /b 0

:error
exit /b %errorLevel%

:nokdb
echo no kdb
exit /b 0
