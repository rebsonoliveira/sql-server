This folder contains files for demonstrating the features of parallel INSERT..SELECT and parallel redo. This file contains the steps to demonstrate this feature

All demonstrations were created on a 1 socket 4 core machine with HT enabled. 32Gb RAM with a 1TB PC1NVMe SSD drive using SQL Server 2016 CU1 (13.0.2149.0)
No changes were made to any SQL Server configuration options (aka sp_configure0

Steps to Prepare for the Demo

1. Create the database by using running the createdb.sql file. The db will require ~50Gb of space. Edit the paths according to your installation
2. Run the script fillupthedb.sql to create the table and populate data

Parallel INSERT...SELECT Demo

1. Go through the steps as outlined with comments in parallel_inserts.sql to see how inserts can perform serially and using parallelism
2. 
