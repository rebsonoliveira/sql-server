@echo off
REM bootstrap sample database CMD script
setlocal enableextensions
setlocal enabledelayedexpansion
set CLUSTER_NAMESPACE=%1
set SQL_MASTER_IP=%2
set SQL_MASTER_SA_PASSWORD=%3
set KNOX_IP=%4
set KNOX_PASSWORD=%5
set AW_WWI_SAMPLES=%6
set STARTUP_PATH=%~dp0
set TMP_DIR_NAME=%~nx0

if NOT DEFINED CLUSTER_NAMESPACE goto :usage
if NOT DEFINED SQL_MASTER_IP goto :usage
if NOT DEFINED SQL_MASTER_SA_PASSWORD goto :usage
if NOT DEFINED KNOX_IP goto :usage
if NOT DEFINED KNOX_PASSWORD set KNOX_PASSWORD=%SQL_MASTER_SA_PASSWORD%
if NOT DEFINED AW_WWI_SAMPLES set AW_WWI_SAMPLES=no

set SQL_MASTER_INSTANCE=%SQL_MASTER_IP%,31433
set KNOX_ENDPOINT=%KNOX_IP%:30443

for %%F in (sqlcmd.exe bcp.exe kubectl.exe curl.exe) do (
    echo Verifying %%F is in path & CALL WHERE /Q %%F || GOTO exit
)

pushd "%tmp%"
md %TMP_DIR_NAME%
cd %TMP_DIR_NAME%

if NOT EXIST tpcxbb_1gb.bak (
    echo Downloading sample database backup file...
    %DEBUG% curl -G "https://sqlchoice.blob.core.windows.net/sqlchoice/static/tpcxbb_1gb.bak" -o tpcxbb_1gb.bak
)

REM Copy the backup file, restore the database, create necessary objects and data file
echo Copying sales database backup file to SQL Master instance...
%DEBUG% kubectl cp tpcxbb_1gb.bak mssql-master-pool-0:/var/opt/mssql/data -c mssql-server -n %CLUSTER_NAMESPACE% || goto exit

if /i %AW_WWI_SAMPLES% EQU install_extra_samples (
    if NOT EXIST AdventureWorks2016_EXT.bak (
        echo Downloading AdventureWorks2016_EXT sample database backup file...
        %DEBUG% curl -L -G "https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorks2016_EXT.bak" -o AdventureWorks2016_EXT.bak
    )
    echo Copying AdventureWorks2016_EXT database backup file to SQL Master instance...
    %DEBUG% kubectl cp AdventureWorks2016_EXT.bak mssql-master-pool-0:/var/opt/mssql/data -c mssql-server -n %CLUSTER_NAMESPACE% || goto exit

    if NOT EXIST AdventureWorksDW2016_EXT.bak (
        echo Downloading AdventureWorksDW2016_EXT sample database backup file...
        %DEBUG% curl -L -G "https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorksDW2016_EXT.bak" -o AdventureWorksDW2016_EXT.bak
    )
    echo Copying AdventureWorksDW2016_EXT database backup file to SQL Master instance...
    %DEBUG% kubectl cp AdventureWorksDW2016_EXT.bak mssql-master-pool-0:/var/opt/mssql/data -c mssql-server -n %CLUSTER_NAMESPACE% || goto exit

    if NOT EXIST WideWorldImporters-Full.bak (
        echo Downloading WideWorldImporters sample database backup file...
        %DEBUG% curl -L -G "https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak" -o WideWorldImporters-Full.bak
    )
    echo Copying WideWorldImporters-Full database backup file to SQL Master instance...
    %DEBUG% kubectl cp WideWorldImporters-Full.bak mssql-master-pool-0:/var/opt/mssql/data -c mssql-server -n %CLUSTER_NAMESPACE% || goto exit

    if NOT EXIST WideWorldImportersDW-Full.bak (
        echo Downloading WideWorldImportersDW sample database backup file...
        %DEBUG% curl -L -G "https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImportersDW-Full.bak" -o WideWorldImportersDW-Full.bak
    )
    echo Copying WideWorldImportersDW-Full database backup file to SQL Master instance...
    %DEBUG% kubectl cp WideWorldImportersDW-Full.bak mssql-master-pool-0:/var/opt/mssql/data -c mssql-server -n %CLUSTER_NAMESPACE% || goto exit
)

echo Configuring sample database(s)...
%DEBUG% sqlcmd -S %SQL_MASTER_INSTANCE% -Usa -P%SQL_MASTER_SA_PASSWORD% -i "%STARTUP_PATH%bootstrap-sample-db.sql" -o "bootstrap.out" -I -b -v SA_PASSWORD="%KNOX_PASSWORD%" || goto exit

for %%F in (web_clickstreams inventory customer) do (
    if NOT EXIST %%F.csv (
        echo Exporting %%F data...
        if /i %%F EQU web_clickstreams (set DELIMITER=,) else (SET DELIMITER=^|)
        %DEBUG% bcp sales.dbo.%%F out "%%F.csv" -S %SQL_MASTER_INSTANCE% -Usa -P%SQL_MASTER_SA_PASSWORD% -c -t"!DELIMITER!" -o "%%F.out" -e "%%F.err" || goto exit
    )
)


if NOT EXIST product_reviews.csv (
    echo Exporting product_reviews data...
    %DEBUG% bcp "select pr_review_sk, replace(replace(pr_review_content, ',', ';'), char(34), '') as pr_review_content from sales.dbo.product_reviews" queryout "product_reviews.csv" -S %SQL_MASTER_INSTANCE% -Usa -P%SQL_MASTER_SA_PASSWORD% -c -t, -o "product_reviews.out" -e "product_reviews.err" || goto exit
)

REM Copy the data file to HDFS
echo Uploading web_clickstreams data to HDFS...
%DEBUG% curl -i -L -k -u root:%KNOX_PASSWORD% -X PUT "https://%KNOX_ENDPOINT%/gateway/default/webhdfs/v1/clickstream_data?op=MKDIRS" || goto exit
%DEBUG% curl -i -L -k -u root:%KNOX_PASSWORD% -X PUT "https://%KNOX_ENDPOINT%/gateway/default/webhdfs/v1/clickstream_data/web_clickstreams.csv?op=create&overwrite=true" -H "Content-Type: application/octet-stream" -T "web_clickstreams.csv" || goto exit
:: del /q web_clickstreams.*

echo.
echo Uploading product_reviews data to HDFS...
%DEBUG% curl -i -L -k -u root:%KNOX_PASSWORD% -X PUT "https://%KNOX_ENDPOINT%/gateway/default/webhdfs/v1/product_review_data?op=MKDIRS" || goto exit
%DEBUG% curl -i -L -k -u root:%KNOX_PASSWORD% -X PUT "https://%KNOX_ENDPOINT%/gateway/default/webhdfs/v1/product_review_data/product_reviews.csv?op=create&overwrite=true" -H "Content-Type: application/octet-stream" -T "product_reviews.csv" || goto exit
:: del /q product_reviews.*

REM %DEBUG% del /q *.out *.err *.csv
echo Bootstrap of the sample database completed successfully.
echo You can now login using "root" and Knox password to get the unified experience in Azure Data Studio.
echo Data files for Oracle setup are located at [%TMP%\%TMP_DIR_NAME%].

popd
endlocal
exit /b 0
goto :eof

:exit
    echo Bootstrap of the sample database failed.
    echo Output and error files are in directory [%TMP%\%TMP_DIR_NAME%].
    exit /b 1

:usage
    echo USAGE: %0 ^<CLUSTER_NAMESPACE^> ^<SQL_MASTER_IP^> ^<SQL_MASTER_SA_PASSWORD^> ^<KNOX_IP^> [^<KNOX_PASSWORD^>]
    echo Default ports are assumed for SQL Master instance ^& Knox gateway.
    exit /b 0