if "%APPVEYOR_REPO_TAG%"=="true" (
 for /F "tokens=*" %%P in (packagenames.txt) do anaconda -t %CONDATOKEN% upload -l dev %%P || goto :error
) 
:error
exit /b %errorLevel%
