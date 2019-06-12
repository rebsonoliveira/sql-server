#!/bin/bash
set -e
set -o pipefail
STARTUP_PATH=$(pwd)
TMP_DIR_NAME=$(basename $0)
USAGE_MESSAGE="USAGE: $0 <CLUSTER_NAMESPACE> <SQL_MASTER_IP> <SQL_MASTER_SA_PASSWORD> <KNOX_IP> [<KNOX_PASSWORD>] [--install-extra-samples] [SQL_MASTER_PORT] [KNOX_PORT]"
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
AW_WWI_SAMPLES=$6
SQL_MASTER_PORT=$7
KNOX_PORT=$8

# If Knox password is not supplied then default to SQL Master password
KNOX_PASSWORD=${KNOX_PASSWORD:=$SQL_MASTER_SA_PASSWORD}

# Skip if extra samples doesn't need to be installed
AW_WWI_SAMPLES=${AW_WWI_SAMPLES:=no}

# Use default ports if not specified
SQL_MASTER_PORT=${SQL_MASTER_PORT:=31433}
KNOX_PORT=${KNOX_PORT:=30443}
SQL_MASTER_INSTANCE=$SQL_MASTER_IP,$SQL_MASTER_PORT
KNOX_ENDPOINT=$KNOX_IP:$KNOX_PORT

for util in sqlcmd bcp kubectl curl
    do
    echo Verifying $util is in path & which $util 1>/dev/null 2>/dev/null || (echo Unable to locate $util && exit 1)
done

# Copy the backup file, restore the database, create necessary objects and data file
pushd "/tmp"
$DEBUG mkdir -p "$TMP_DIR_NAME"
$DEBUG cd "$TMP_DIR_NAME"

if [ ! -f tpcxbb_1gb.bak ]
then
    echo Downloading sample database backup file...
    $DEBUG curl -G "https://sqlchoice.blob.core.windows.net/sqlchoice/static/tpcxbb_1gb.bak" -o tpcxbb_1gb.bak
fi

CTP_VERSION=$(sqlcmd -S $SQL_MASTER_INSTANCE -Usa -P$SQL_MASTER_SA_PASSWORD -I -b -h-1 -Q "print RTRIM((CAST(SERVERPROPERTY('ProductLevel') as nvarchar(128))));")

if [ "$CTP_VERSION" == "CTP2.4" ]
then
    MASTER_POD_NAME=mssql-master-pool-0
else
    MASTER_POD_NAME=master-0
fi

echo Copying sales database backup file...
$DEBUG kubectl cp tpcxbb_1gb.bak $CLUSTER_NAMESPACE/$MASTER_POD_NAME:var/opt/mssql/data -c mssql-server || (echo $ERROR_MESSAGE && exit 1)
# $DEBUG rm tpcxbb_1gb.bak

if [ "$AW_WWI_SAMPLES" == "--install-extra-samples" ]
then
    for file in AdventureWorks2016_EXT.bak AdventureWorksDW2016_EXT.bak
    do
        if [ ! -f $file ]
        then
            echo Downloading $file sample database backup file...
            $DEBUG curl -L -G "https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/$file" -o $file
        fi
        echo Copying $file database backup file to SQL Master instance...
        $DEBUG kubectl cp $file $CLUSTER_NAMESPACE/$MASTER_POD_NAME:var/opt/mssql/data -c mssql-server || (echo $ERROR_MESSAGE && exit 1)
    done


    for file in WideWorldImporters-Full.bak WideWorldImportersDW-Full.bak
    do
        if [ ! -f $file ]
        then
            echo Downloading $file sample database backup file...
            $DEBUG curl -L -G "https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/$file" -o $file
        fi
        echo Copying $file database backup file to SQL Master instance...
        $DEBUG kubectl cp $file $CLUSTER_NAMESPACE/$MASTER_POD_NAME:var/opt/mssql/data -c mssql-server || (echo $ERROR_MESSAGE && exit 1)
    done
fi

echo Configuring sample database...
# WSL ex: "/mnt/c/Program Files/Microsoft SQL Server/Client SDK/ODBC/130/Tools/Binn/SQLCMD.EXE"
export SA_PASSWORD=$KNOX_PASSWORD
$DEBUG sqlcmd -S $SQL_MASTER_INSTANCE -Usa -P$SQL_MASTER_SA_PASSWORD -I -b -i "$STARTUP_PATH/bootstrap-sample-db.sql" -o "bootstrap.out" || (echo $ERROR_MESSAGE && exit 2)

# remove files copied into the pod:
echo Removing database backup files...
$DEBUG kubectl exec $MASTER_POD_NAME -n $CLUSTER_NAMESPACE -c mssql-server -i -t -- bash -c "rm -rvf /var/opt/mssql/data/*.bak"

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
    if [ ! -f $table.csv ]
    then
        $DEBUG bcp sales.dbo.$table out "$table.csv" -S $SQL_MASTER_INSTANCE -Usa -P$SQL_MASTER_SA_PASSWORD -c -t"$DELIMITER" -e "$table.err" || (echo $ERROR_MESSAGE && exit 3)
    fi
done

if [ ! -f product_reviews.csv ]
then
    echo Exporting product_reviews data...
    $DEBUG bcp "select pr_review_sk, replace(replace(pr_review_content, ',', ';'), char(34), '') as pr_review_content from sales.dbo.product_reviews" queryout "product_reviews.csv" -S $SQL_MASTER_INSTANCE -Usa -P$SQL_MASTER_SA_PASSWORD -c -t, -e "product_reviews.err" || (echo $ERROR_MESSAGE && exit 3)
fi

# Copy the data file to HDFS
echo Uploading web_clickstreams data to HDFS...
$DEBUG curl -i -L -k -u root:$KNOX_PASSWORD -X PUT "https://$KNOX_ENDPOINT/gateway/default/webhdfs/v1/clickstream_data?op=MKDIRS" || (echo $ERROR_MESSAGE && exit 4)
$DEBUG curl -i -L -k -u root:$KNOX_PASSWORD -X PUT "https://$KNOX_ENDPOINT/gateway/default/webhdfs/v1/clickstream_data/web_clickstreams.csv?op=create&overwrite=true" -H 'Content-Type: application/octet-stream' -T "web_clickstreams.csv" || (echo $ERROR_MESSAGE && exit 5)
#$DEBUG rm -f web_clickstreams.*

echo
echo Uploading product_reviews data to HDFS...
$DEBUG curl -i -L -k -u root:$KNOX_PASSWORD -X PUT "https://$KNOX_ENDPOINT/gateway/default/webhdfs/v1/product_review_data?op=MKDIRS" || (echo $ERROR_MESSAGE && exit 6)
$DEBUG curl -i -L -k -u root:$KNOX_PASSWORD -X PUT "https://$KNOX_ENDPOINT/gateway/default/webhdfs/v1/product_review_data/product_reviews.csv?op=create&overwrite=true" -H "Content-Type: application/octet-stream" -T "product_reviews.csv" || (echo $ERROR_MESSAGE && exit 7)
#$DEBUG rm -f product_reviews.*

echo
echo Bootstrap of the sample database completed successfully.
echo You can now login using "root" and Knox password to get the unified experience in Azure Data Studio.
echo Data files for Oracle setup are located at [/tmp/$TMP_DIR_NAME].

# $DEBUG rm -f *.out *.err *.csv
popd
exit 0
