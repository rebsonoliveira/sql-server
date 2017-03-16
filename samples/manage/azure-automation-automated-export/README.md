---
services: azure automation
platforms: azure
author: trgrie-msft
---

# Setting up Auto Export in Azure Automation

Provides the scripts and lists the steps to set up automatically exporting your databases to Azure Storage with Azure Automation.

## Prerequisite Set Up

1. Create and set up your Azure Automation Account
	- Create an Azure Automation Account by [following the instructions here](https://docs.microsoft.com/en-us/azure/automation/automation-sec-configure-azure-runas-account).
2. Add Azure Automation Credential assets for your SQL Azure servers
	- Create your Automation Credential for each of your SQL Azure servers you intend to export by [following the instructions here](https://docs.microsoft.com/en-us/azure/automation/automation-credentials#creating-a-new-credential-asset).
3. Create the Azure Storage Account to hold your bacpac files
	- Create the Storage Account by [following the instructions here](https://docs.microsoft.com/en-us/azure/storage/storage-create-storage-account#create-a-storage-account).
	- Copy your Storage Account access keys by [following the instructions here](https://docs.microsoft.com/en-us/azure/storage/storage-create-storage-account#view-and-copy-storage-access-keys).
	- Create an Azure Automation string Variable asset for your Storage Account access key by [following the instructions here](https://docs.microsoft.com/en-us/azure/automation/automation-variables#creating-an-automation-variable).
4. Set Up Log Analytics (OMS) and Alerts (optional for alerting)
	- If you don't have Log Analytics set up on your Azure account, [follow these](https://docs.microsoft.com/en-us/azure/automation/automation-manage-send-joblogs-log-analytics) instructions for setting it up.
5. Set Up Log Analytics Alerts
	- To send yourself an email if an error occurs or one of the jobs fails, you need to set up alerts.
	- Select your log analytics account that you want to use in the azure portal and click on the OMS Portal box under Management.
	- Click on Log Search and enter the queries you want to alert on. These are two that are suggested:
		- Category=JobStreams “Error occurred*”
		- Category=JobLogs ResultType=Failed
	- The first will alert on an the provided script saying an error occurred so you know if something didn't go quite right. The second alerts if the script fails entirely.

## Script Set Up

1. In the AutoExport.ps1 script, here are the values that need to be modified:
	- $databaseServerPairs: This is where you put in the names of the databases you want to export along with the name of the server they are on.
	- $serverCredentialsDictionary: If you are backing up from multiple servers, you can setup all of the credentials here and look them up by the server’s name later.
	- $batchingLimit: This tells the script how many databases can be worked on at the same time (basically, the maximum number of database copies that there will be at once).
	- $retryLimit: This tells the script how many times it can retry an operation.
	- $waitTimeInMinutes: This tells the script how long it can wait for an operation to complete before it fails.
	- $storageKeyVariableName: This is the AutomationAccount you created the StorageKey variable under (probably the same one you are running the RunBook under) and -Name is the name of the variable.
	- $storageAccountName: This is the name of the storage account you are exporting to.
	- $connectionAssetName: Connection Asset Name for Authenticating (Keep as AzureClassicRunAsConnection if you created the default RunAs accounts) 
2. In AutoExportBlobRetention, here are the values that need to be modified:
	- -Name for Get-AzureAutomationVariable: This is the AutomationAccount you created the StorageKey variable under (probably the same one you are running the RunBook under) and -Name is the name of the variable.
	- $storageContainer: This is the name of the storage container where you will be monitoring the exported blobs.
	- $retentionInDays: This is how many days you want to keep the exported blobs stored for before deleting.
