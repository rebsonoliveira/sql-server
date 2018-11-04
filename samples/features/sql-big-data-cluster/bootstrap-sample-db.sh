#!/bin/bash
set -e
set -o pipefail
USAGE_MESSAGE="USAGE: $0 <CLUSTER_NAMESPACE> <SQL_MASTER_IP> <SQL_MASTER_SA_PASSWORD> <KNOX_IP> [<KNOX_PASSWORD>]"
ERROR_MESSAGE="Bootstrap of the sample database failed."

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


for util in sqlcmd.exe bcp.exe kubectl.exe curl.exe
    do
    echo Verifying $util is in path & which $util 1>NUL 2>NUL || (echo Unable to locate $util && exit 1)
done

# Copy the backup file, restore the database, create necessary objects and data file
pushd "/tmp"
echo Downloading sample database backup file...
$DEBUG curl -G "https://sqlchoice.blob.core.windows.net/sqlchoice/static/tpcxbb_1gb.bak" -o tpcxbb_1gb.bak

echo Copying database backup file...
$DEBUG kubectl cp tpcxbb_1gb.bak mssql-master-pool-0:/var/opt/mssql/data -c mssql-server -n $CLUSTER_NAMESPACE || (echo $ERROR_MESSAGE && exit 1)
rm tpcxbb_1gb.bak
popd

echo Configuring sample database...
# WSL ex: "/mnt/c/Program Files/Microsoft SQL Server/Client SDK/ODBC/130/Tools/Binn/SQLCMD.EXE"
$DEBUG sqlcmd -S $SQL_MASTER_INSTANCE -Usa -P$SQL_MASTER_SA_PASSWORD -i "bootstrap-sample-db.sql" -o "bootstrap.out" -I -b || (echo $ERROR_MESSAGE && exit 2)

for table in web_clickstreams inventory
    do
    echo Exporting $table data...
    # WSL ex: "/mnt/c/Program Files/Microsoft SQL Server/Client SDK/ODBC/130/Tools/Binn/bcp.exe"
    $DEBUG bcp sales.dbo.$table out "$table.csv" -S $SQL_MASTER_INSTANCE -Usa -P$SQL_MASTER_SA_PASSWORD -c -t, -e "$table.err" || (echo $ERROR_MESSAGE && exit 3)
done

echo Exporting product_reviews data...
$DEBUG bcp "select pr_review_sk, replace(replace(pr_review_content, ',', ';'), '\"', '') from sales.dbo.product_reviews" queryout "product_reviews.csv" -S $SQL_MASTER_INSTANCE -Usa -P$SQL_MASTER_SA_PASSWORD -c -t, -e "product_reviews.err" || (echo $ERROR_MESSAGE && exit 3)

# Copy the data file to HDFS
echo Uploading web_clickstreams data to HDFS...
$DEBUG curl -i -L -k -u root:$KNOX_PASSWORD -X PUT "https://$KNOX_ENDPOINT/gateway/default/webhdfs/v1/clickstream_data?op=MKDIRS" || (echo $ERROR_MESSAGE && exit 4)
$DEBUG curl -i -L -k -u root:$KNOX_PASSWORD -X PUT "https://$KNOX_ENDPOINT/gateway/default/webhdfs/v1/clickstream_data/web_clickstreams.csv?op=create" -H 'Content-Type: application/octet-stream' -T "web_clickstreams.csv" || (echo $ERROR_MESSAGE && exit 5)

echo Uploading product_reviews data to HDFS...
$DEBUG curl -i -L -k -u root:$KNOX_PASSWORD -X PUT "https://$KNOX_ENDPOINT/gateway/default/webhdfs/v1/product_review_data?op=MKDIRS" || (echo $ERROR_MESSAGE && exit 6)
$DEBUG curl -i -L -k -u root:$KNOX_PASSWORD -X PUT "https://$KNOX_ENDPOINT/gateway/default/webhdfs/v1/product_review_data/product_reviews.csv?op=create" -H "Content-Type: application/octet-stream" -T "product_reviews.csv" || (echo $ERROR_MESSAGE && exit 7)

# rm -f *.out *.err *.csv
exit