@echo off
REM CLICKSTREAM FILES
setlocal enableextensions
set CLUSTER_NAMESPACE=%1
set SQL_MASTER_IP=%2
set SQL_MASTER_SA_PASSWORD=%3
set BACKUP_FILE_PATH=%~4
set KNOX_IP=%5
set KNOX_PASSWORD=%6
set STARTUP_PATH=%~dp0

if NOT DEFINED CLUSTER_NAMESPACE goto :usage
if NOT DEFINED SQL_MASTER_IP goto :usage
if NOT DEFINED SQL_MASTER_SA_PASSWORD goto :usage
if NOT DEFINED BACKUP_FILE_PATH goto :usage
if NOT DEFINED KNOX_IP goto :usage
if NOT DEFINED KNOX_PASSWORD set KNOX_PASSWORD=%SQL_MASTER_SA_PASSWORD%

set SQL_MASTER_INSTANCE=%SQL_MASTER_IP%,31433
set KNOX_ENDPOINT=%KNOX_IP%:30443

echo Verifying sqlcmd.exe is in path & CALL WHERE /Q sqlcmd.exe || GOTO exit
echo Verifying bcp.exe is in path & CALL WHERE /Q bcp.exe || GOTO exit
echo Verifying kubectl.exe is in path & CALL WHERE /Q kubectl.exe || echo HINT: Install the kubernetes-cli - https://kubernetes.io/docs/tasks/tools/install-kubectl && GOTO exit
echo Verifying curl.exe is in path & CALL WHERE /Q curl.exe || echo HINT: Install curl - https://curl.haxx.se/download.html && GOTO exit

REM Copy the backup file, restore the database, create necessary objects and data file
echo Copying database backup file...
pushd "%BACKUP_FILE_PATH%"
%DEBUG% kubectl cp tpcxbb_1gb.bak mssql-master-pool-0:/var/opt/mssql/data -c mssql-server -n %CLUSTER_NAMESPACE% || goto exit
popd

echo Configuring sample database...
%DEBUG% sqlcmd -S %SQL_MASTER_INSTANCE% -Usa -P%SQL_MASTER_SA_PASSWORD% -i "%STARTUP_PATH%bootstrap-sample-db.sql" -o "%STARTUP_PATH%bootstrap.out" -I -b || goto exit

for %%F in (web_clickstreams inventory) do (
    echo Exporting %%F data...
    %DEBUG% bcp sales.dbo.%%F out "%STARTUP_PATH%%%F.csv" -S %SQL_MASTER_INSTANCE% -Usa -P%SQL_MASTER_SA_PASSWORD% -c -t, -o "%STARTUP_PATH%%%F.out" -e "%STARTUP_PATH%%%F.err" || goto exit
)

echo Exporting product_reviews data...
%DEBUG% bcp "select pr_review_sk, replace(replace(pr_review_content, ',', ';'), '\"', '') from sales.dbo.product_reviews" queryout "%STARTUP_PATH%product_reviews.csv" -S %SQL_MASTER_INSTANCE% -Usa -P%SQL_MASTER_SA_PASSWORD% -c -t, -o "%STARTUP_PATH%product_reviews.out" -e "%STARTUP_PATH%product_reviews.err" || goto exit

REM Copy the data file to HDFS
pushd "%STARTUP_PATH%"
echo Uploading web_clickstreams data to HDFS...
%DEBUG% curl -i -L -k -u root:%KNOX_PASSWORD% -X PUT "https://%KNOX_ENDPOINT%/gateway/default/webhdfs/v1/clickstream_data?op=MKDIRS" || goto exit
%DEBUG% curl -i -L -k -u root:%KNOX_PASSWORD% -X PUT "https://%KNOX_ENDPOINT%/gateway/default/webhdfs/v1/clickstream_data/web_clickstreams.csv?op=create" -H "Content-Type: application/octet-stream" -T "web_clickstreams.csv" || goto exit

echo Uploading product_reviews data to HDFS...
%DEBUG% curl -i -L -k -u root:%KNOX_PASSWORD% -X PUT "https://%KNOX_ENDPOINT%/gateway/default/webhdfs/v1/product_review_data?op=MKDIRS" || goto exit
%DEBUG% curl -i -L -k -u root:%KNOX_PASSWORD% -X PUT "https://%KNOX_ENDPOINT%/gateway/default/webhdfs/v1/product_review_data/product_reviews.csv?op=create" -H "Content-Type: application/octet-stream" -T "product_reviews.csv" || goto exit
:: del /q *.out *.err *.csv
popd

endlocal
exit /b 0
goto :eof

:exit
    echo Bootstrap of the sample database failed.
    exit /b %ERRORLEVEL%

:usage
    echo USAGE: %0 ^<CLUSTER_NAMESPACE^> ^<SQL_MASTER_IP^> ^<SQL_MASTER_SA_PASSWORD^> ^<BACKUP_FILE_PATH^> ^<KNOX_IP^> [^<KNOX_PASSWORD^>]
    echo Default ports are assumed for SQL Master instance ^& Knox gateway.
    exit /b 0