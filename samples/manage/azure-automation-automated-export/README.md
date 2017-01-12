---
services: azure automation
platforms: azure
author: trgrie-msft
---

# Setting up Auto Export in Azure Automation

Provides the scripts and lists the steps to set up automatically exporting your databases to Azure Storage with Azure Automation.

## Azure Automation Set Up

1. Create and uploade the certificates that you will use to authenticate your connection to azure.
	- Run powershell as admin.
	- Run the New-SelfSignedCertificate command: `$cert = New-SelfSignedCertificate -CertStoreLocation cert:\localmachine\my -DnsName <certificateName>`
	- Export the certificate as a .cer file
		- `Export-Certificate -Cert "cert:\localmachine\my\$($cert.Thumbprint)" -FilePath <PathAndFileName>.cer`
	- Create a corresponding pfx certificate by taking the thumbprint of the newly created certificate and running these commands:
		- $CertPassword = ConvertTo-SecureString -String &lt;YourPassword&gt; -Force -AsPlainText
		- Export-PfxCertificate -Cert "cert:\localmachine\my\$($cert.Thumbprint)" -FilePath &lt;PathAndFileName&gt;.pfx -Password $CertPassword
	- Upload the .cer file to your subscription [in the old portal](https://manage.windowsazure.com/)
	- Upload the .pfx file to the certificates under Assets in the automation account that you want to use on Azure. You will use the password you gave in the previous step to authenticate it.
2. Create new a new credentials asset to authenticate your server with.
	- Under assets, click on Credentials, and then click on Add a credential.
	- Name the credential and give the username and password that you will be logging into the server with.
3. Create a new variable asset to pass the storage key of the Azure storage account you will be using.
	- Under assets, click on variables and then Add a variable.
	- Give the value of the storage key and you can make it encrypted so that only Azure Automation can read the variable and it won't show the key in plaintext if someone looks at the variable.
4. Set Up Log Analytics (OMS) and Alerts
	- If you don't have Log Analytics set up on your Azure account, follow [these](https://azure.microsoft.com/en-us/documentation/articles/automation-manage-send-joblogs-log-analytics/) instructions for setting it up.
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
	- $automationCertificateName for Get-AutomationCertificate: This is the name of the certificate you setup to authenticate with Azure.
	- $subId: The ID of the subscription you are using. This will be used to tell Azure Automation which subscription to use.
	- $subName: The name of the subscription you are using. This will be used to tell Azure Automation which subscription to use.
2. In AutoExportBlobRetention, here are the values that need to be modified:
	- -Name for Get-AzureAutomationVariable: This is the AutomationAccount you created the StorageKey variable under (probably the same one you are running the RunBook under) and -Name is the name of the variable.
	- $storageContainer: This is the name of the storage container where you will be monitoring the exported blobs.
	- $retentionInDays: This is how many days you want to keep the exported blobs stored for before deleting.
