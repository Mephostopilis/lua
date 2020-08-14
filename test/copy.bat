@echo off

goto :main

:func_echo
set /a %1=%2+%3
goto :eof

:strlen
set str=%2
if not defined str (
  goto :eof
) else (
  echo %str%
)
set num=0
:label
set /a num+=1
set str=%str:~0,-1%
if defined str goto :label
set /a %1=%num%
goto :eof

:func_test
set arg=hello
call :strlen ret %arg%
echo %ret%
goto :eof

:func_test1
echo %cd%
set dst=%cd:~0,-5%\Assets\Resources
echo %dst%
call :strlen ret %dst%
echo %ret%
set -a a=%ret%-5
set srcfile=%cd%\AppConfig.lua
set dstfile=%dst%
for /l %%i in (%
%srcfile:%a%%
echo %dstfile%

rem for /r %cd% %%i in (*.lua) do (
rem echo %%i
rem echo %%~ni
rem echo %%~xi
rem echo %%~nxi
rem echo %%~pi
rem )
goto :eof

:main
call :func_test1

pause