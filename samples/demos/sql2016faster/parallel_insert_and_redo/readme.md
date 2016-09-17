This folder contains files for demonstrating the features of parallel INSERT..SELECT and parallel redo. This file contains the steps to demonstrate this feature. Only run this demonstration on a developerment or test computer runniung SQL Server 2016. Never run this on a production server.

All demonstrations were created on a 1 socket 4 core machine with HT enabled. 32Gb RAM with a 1TB PC1NVMe SSD drive using SQL Server 2016 CU1 (13.0.2149.0)
No changes were made to any SQL Server configuration options (aka sp_configure0

Steps to Prepare for the Demo

1. Create the database by using running the create_database.sql file. The db will require ~50Gb of space. Edit the paths according to your installation
2. Run the script fillupthedb.sql to create the table and populate data

Parallel INSERT...SELECT Demo

3. Load up the dmvs.sql script so observe execution of the inserts.
4. Go through the steps as outlined with comments in parallel_inserts.sql to see how inserts can perform serially and using parallelism

Parallel Redo

We will use the database created for parallel INSERT..SELECT to show parallel redo.  You must complete steps 1 and 2 before going through these steps for parallel redo

5. We will use Extended Evnent to see the details of recovery (aka recovery tracing) so run the script recovery_event_session.sql to create the Extended Event Session. The script is setup to write out the event data to the c:\temp directory so modify the script for the path of your choice
6. Follow the steps in the parallel_redo.sql script to demonstrate parallel redo for recovery. The script has comments that require you to terminate the SQLSERVR.EXE process as part of the excercise.
7. Run drop_event_session.sql to remove the extended events session. In addition, you can remove the .xel files created for the session in the path specified in recovery_event_session.sql
8. Run drop_database.sql to remove the demonwtration database.
