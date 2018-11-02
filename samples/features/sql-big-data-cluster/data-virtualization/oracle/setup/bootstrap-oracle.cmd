@echo off
REM bootstrap sample oracle tables CMD script
setlocal enableextensions
set ORACLE_SERVER=%1
set ORACLE_USER=%2
set ORACLE_PASSWORD=%3

if NOT DEFINED ORACLE_SERVER goto :usage
if NOT DEFINED ORACLE_USER goto :usage
if NOT DEFINED ORACLE_PASSWORD goto :usage

echo Verifying sqlplus.exe is in path & CALL WHERE /Q sqlplus.exe || GOTO exit
echo Verifying sqlldr.exe is in path & CALL WHERE /Q sqlldr.exe || GOTO exit

echo Creating user & tables...
echo exit | sqlplus -S %ORACLE_USER%/%ORACLE_PASSWORD%@%ORACLE_SERVER% @sales-user.sql || GOTO exit
echo exit | sqlplus -S %ORACLE_USER%/%ORACLE_PASSWORD%@%ORACLE_SERVER% @inventory.sql || GOTO exit
echo exit | sqlplus -S %ORACLE_USER%/%ORACLE_PASSWORD%@%ORACLE_SERVER% @customer.sql || GOTO exit

echo Loading tables data...
sqlldr CONTROL=inventory.ctl userid=%ORACLE_USER%/%ORACLE_PASSWORD%@%ORACLE_SERVER% || GOTO exit
sqlldr CONTROL=customer.ctl userid=%ORACLE_USER%/%ORACLE_PASSWORD%@%ORACLE_SERVER% || GOTO exit

:: del /q *.out *.err *.csv
endlocal
exit /b 0
goto :eof

:exit
    echo Bootstrap of the sample tables failed.
    exit /b 1

:usage
    echo USAGE: %0 ^<ORACLE_SERVER^> ^<ORACLE_USER^> ^<ORACLE_PASSWORD^>
    exit /b 0