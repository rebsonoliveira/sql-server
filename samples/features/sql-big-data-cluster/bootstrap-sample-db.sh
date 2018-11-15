#!/bin/bash
set -e
set -o pipefail
STARTUP_PATH=$(dirname $0)
TMP_DIR_NAME=$(basename $0)
USAGE_MESSAGE="USAGE: $0 <CLUSTER_NAMESPACE> <SQL_MASTER_IP> <SQL_MASTER_SA_PASSWORD> <KNOX_IP> [<KNOX_PASSWORD>]"
ERROR_MESSAGE="Bootstrap of the sample database failed. Output and error files are in directory [/tmp/$TMP_DIR_NAME]."

# Print usage if mandatory parameters are missing
: "${1:?$USAGE_MESSAGE}"
: "${2:?$USAGE_MESSAGE}"
: "${3:?$USAGE_MESSAGE}"
: "${4:?$USAGE_MESSAGE}"
: "${DEBUG=}"

# Save the input parameters
CLUSTER_NAMESPACE=$1
SQL_MASTER_IP=$2
SQL_MASTER_SA_PASSWORD=$3
KNOX_IP=$4
KNOX_PASSWORD=$5
# If Knox password is not supplied then default to SQL Master password
KNOX_PASSWORD=${KNOX_PASSWORD:=$SQL_MASTER_SA_PASSWORD}

SQL_MASTER_INSTANCE=$SQL_MASTER_IP,31433
KNOX_ENDPOINT=$KNOX_IP:30443

for util in sqlcmd bcp kubectl curl
    do
    echo Verifying $util is in path & which $util 1>/dev/nul 2>/dev/nul || (echo Unable to locate $util && exit 1)
done

# Copy the backup file, restore the database, create necessary objects and data file
pushd "/tmp"
$DEBUG mkdir "$TMP_DIR_NAME"
$DEBUG cd "$TMP_DIR_NAME"

echo Downloading sample database backup file...
$DEBUG curl -G "https://sqlchoice.blob.core.windows.net/sqlchoice/static/tpcxbb_1gb.bak" -o tpcxbb_1gb.bak

echo Copying database backup file...
$DEBUG kubectl cp tpcxbb_1gb.bak mssql-master-pool-0:/var/opt/mssql/data -c mssql-server -n $CLUSTER_NAMESPACE || (echo $ERROR_MESSAGE && exit 1)
$DEBUG rm tpcxbb_1gb.bak

echo Configuring sample database...
# WSL ex: "/mnt/c/Program Files/Microsoft SQL Server/Client SDK/ODBC/130/Tools/Binn/SQLCMD.EXE"
$DEBUG sqlcmd -S $SQL_MASTER_INSTANCE -Usa -P$SQL_MASTER_SA_PASSWORD -i "$STARTUP_PATH\bootstrap-sample-db.sql" -o "bootstrap.out" -I -b || (echo $ERROR_MESSAGE && exit 2)

for table in web_clickstreams inventory customer
    do
    echo Exporting $table data...
    if [ $table == web_clickstreams ]
    then 
        DELIMITER=,
    else
        DELIMITER="|"
    fi
    # WSL ex: "/mnt/c/Program Files/Microsoft SQL Server/Client SDK/ODBC/130/Tools/Binn/bcp.exe"
    $DEBUG bcp sales.dbo.$table out "$table.csv" -S $SQL_MASTER_INSTANCE -Usa -P$SQL_MASTER_SA_PASSWORD -c -t"$DELIMITER" -e "$table.err" || (echo $ERROR_MESSAGE && exit 3)
done

echo Exporting product_reviews data...
$DEBUG bcp "select pr_review_sk, replace(replace(pr_review_content, ',', ';'), char(34), '') as pr_review_content from sales.dbo.product_reviews" queryout "product_reviews.csv" -S $SQL_MASTER_INSTANCE -Usa -P$SQL_MASTER_SA_PASSWORD -c -t, -e "product_reviews.err" || (echo $ERROR_MESSAGE && exit 3)

# Copy the data file to HDFS
echo Uploading web_clickstreams data to HDFS...
$DEBUG curl -i -L -k -u root:$KNOX_PASSWORD -X PUT "https://$KNOX_ENDPOINT/gateway/default/webhdfs/v1/clickstream_data?op=MKDIRS" || (echo $ERROR_MESSAGE && exit 4)
$DEBUG curl -i -L -k -u root:$KNOX_PASSWORD -X PUT "https://$KNOX_ENDPOINT/gateway/default/webhdfs/v1/clickstream_data/web_clickstreams.csv?op=create&overwrite=true" -H 'Content-Type: application/octet-stream' -T "web_clickstreams.csv" || (echo $ERROR_MESSAGE && exit 5)
$DEBUG rm -f web_clickstreams.*

echo
echo Uploading product_reviews data to HDFS...
$DEBUG curl -i -L -k -u root:$KNOX_PASSWORD -X PUT "https://$KNOX_ENDPOINT/gateway/default/webhdfs/v1/product_review_data?op=MKDIRS" || (echo $ERROR_MESSAGE && exit 6)
$DEBUG curl -i -L -k -u root:$KNOX_PASSWORD -X PUT "https://$KNOX_ENDPOINT/gateway/default/webhdfs/v1/product_review_data/product_reviews.csv?op=create&overwrite=true" -H "Content-Type: application/octet-stream" -T "product_reviews.csv" || (echo $ERROR_MESSAGE && exit 7)
$DEBUG rm -f product_reviews.*

echo
echo Bootstrap of the sample database completed successfully.
echo Data files for Oracle setup are located at [/tmp/$TMP_DIR_NAME].

# $DEBUG rm -f *.out *.err *.csv
popd
exit 0
