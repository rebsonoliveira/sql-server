# Oracle setup

This folder contains scripts that can be executed on Oracle server to create the necessary objects for data virtualization in SQL Server 2019 big data cluster.

# Instructions

1. Connect to Oracle instance.

1. Execute the [sales-user.sql](sales-user.sql). This script creates the sample user. If there is name conflict please change the script user/credentials.

1. Execute the [inventory.sql](inventory.sql). This script creates the inventory table.