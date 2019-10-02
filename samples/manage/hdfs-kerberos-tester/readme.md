# HDFS Kerberos Tester
Use the HDFS Kerberos tester to troubleshoot HDFS Kerberos connections for PolyBase, when you experience HDFS Kerberos failure while creating an external table in a Kerberos secured HDFS cluster. 

This tool will assist in ruling out non-SQL Server issues, to help you concentrate on resolving HDFS Kerberos setup issues, namely identifying the following issues:
- Username/password misconfigurations
- Cluster Kerberos setup misconfigurations     

This tool is completely independent from SQL Server. It is available as a Jupyter Notebook, requires Azure Data Studio, and around 40 MB of hard disk space. 

## Instructions
1. Download all the content in this location to your local machine. Please make sure all these files are co-located in same folder.

2. Open the Azure Data Studio.

3. In Azure Data studio click the **File** top menu -> **Open File** -> navigate to the folder where you saved the hdfs-kerberos-tester.ipynb. Choose hdfs-kerberos-tester.ipynb and click open.
 
4. After the Notebook has loaded, choose **Python3** as kernel.

5. Click on all **RunCells** button in the Notebook and follow instruction in the Notebook.
