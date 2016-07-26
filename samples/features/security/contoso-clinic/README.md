#Contoso Clinic Demo Application 

Sample application with database that showcases security features of Azure SQL DB (V12). 

## About this sample
- **Applies to:**  Azure SQL Database, Azure Web App Service, Azure Key Vault
- **Programming Language:** .NET C#, T-SQL
- **Authors:** Jakub Szymaszek [jaszymas-MSFT], Daniel Rediske [daredis-msft]

This project has adopted the [Microsoft Open Source Code of Conduct](http://microsoft.github.io/codeofconduct). For more information see the [Code of Conduct FAQ](http://microsoft.github.io/codeofconduct/faq.md) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments. 

##Contents
1. [Prerequisites] (#prerequisites) 
2. [Setup] (#setup) 
	* TODO: TransferSetup
4. [Azure SQL Security Features] (#azure-sql-security-features) 
	* Always Encrypted 
	* Row Level Security 
	* Dynamic Data Masking
5.  [Application Notes/Disclaimer] (#application-notes)



##Prerequisites
1. Visual Studio (Version dependencies?)


##Setup


###Retrieve User and Application ObjectID


## Azure SQL Security Features 
### Always Encrypted 
####Enable Always Encrypted
+ Connect to your database using SSMS: 
	- Connect using the Administrator Login (Default was adminLogin) and the password you defined during setup 
	- For more information on using SSMS to connect to an Azure Database, [click here](https://azure.microsoft.com/en-us/documentation/articles/sql-database-connect-query-ssms/)
+ Encrypt Sensitive Data Columns using the Column Encryption Wizard 
	- Right click on the **Patients** table in the **Clinic** database and select **Encrypt Columns...**
	- The Column Encryption wizard will open. Click **Next**.
	- Select the **SSN** and **BirthDate** columns. 
		* Select **Deterministic Encryption** for **SSN** as the application needs to be able to search patients by SSN; Deterministic Encryption preserves that functionality for our app without leaving data exposed. 
		* Select **Randomized Encryption** for *BirthDate** 
	- Leave **CEK_Auto1 (New)** as the Key for both columns. Click **Next**.
	- On the **Master Key Configuration** page, set the Master Key Source to **Azure Key Vault**, select the Subscription you used in the deployment of the application, and select your Key Vault  Click **Next**. 
		* The naming convention of the Key Vault begins "Contosoakv" followed by a unique string, which satisfies the universally unique naming convention necessary for the key vault. 
		* Should you see more than one Key Vault option, using `Get-AzureRmKeyVault -ResourceGroupName <yourResourceGroupName>` within powershell would be an option to ensure you choose the correct key vault. 
	- Click the **Next** button on the Validation page.
	- The Summary Page provides an overview of the settings we selected. Click **Finish**. 
	- Monitor the progress of the wizard; once finished, click **Close**. 
+ View the data in SSMS (in SSMS use: `SELECT SSN, BirthDate FROM dbo.Patients` or `SELECT * FROM dbo.Patients` ) 
	- Note that the data is now encrypted in both the **SSN** and **BirthDate** columns. 
+ Navigate to or refresh the /patients page
	- Notice that the application still works and the encryption does not hinder the presentation of the data
	
####How did that work? 

##### Azure Key Vault Creation and Permissions  
During the pre-deployment steps, you collected information which enabled the deployment to create an Azure Key Vault and the required permissions for both you (the user) and the Application Active Directory registration we created. During those steps, the Azure Active Directory registration for the application was necessary to enable key vault connectivity, because the application needs access to the key to enable the driver to transparently handle the decryption of the columns we encrypted. 

During the creation, we gave the user `create, list, wrapKey, unwrapKey, sign, verify` permissions in order to facilitate your Key Vault management; the application needs `get, wrapKey, unwrapKey, sign, verify`. As a best practice, you should *always follow the principle of least privelege*. For documentation on Key Vault Permissions, see [About Keys and Secrets](https://msdn.microsoft.com/en-us/library/azure/dn903623.aspx#BKMK_KeyAccessControl). 

This is the equivalent of creating a [key vault] (https://blogs.technet.microsoft.com/kv/2015/06/02/azure-key-vault-step-by-step) and permissions via Powershell- see the section/cmdlets under "Create and Configure a key vault". 
##### Connection String
Our connection string for our application contains `Column Encryption Setting=Enabled` which allows the driver to handle the necessary overhead to decrypt the newly encrypted data without code changes. Ordinarily, you would need to change the connection string- but in this demo, we preemptively included this within the connection string with the intent that you enable this functionality. Don't forget this for your app if you intend to use Always Encrypted functonality. 
##### Application Code Changes
We had to prepare our application to authenticate against our Key Vault- this code is discussed in more detail in this [Blog Post] (https://blogs.msdn.microsoft.com/sqlsecurity/2015/11/10/using-the-azure-key-vault-key-store-provider-for-always-encrypted/). The code changes referenced there are in our file *Startup.cs*, which can be found [here](ContosoClinicProject/ContosoClinic/Startup.cs). 

### Row Level Security (RLS) 

####Login to the application 
Sign in using (Rachel@contoso.com/Password1!) or (alice@contoso.com/Password1!)

####Enable Row Level Security (RLS) 
+ Connect to your database using SSMS: [Instructions](https://azure.microsoft.com/en-us/documentation/articles/sql-database-connect-query-ssms/)
+ Open Enable-RLS.sql ( [Find it here](Security%20Demo%20Queries/Enable-RLS.sql))
+ Execute the commands 
+ Observe the changes to the results returned on the /visits or /patients page

#### How did that work? 

#####The application leverages an Entity Framework feature called **interceptors** 
Specifically, we used a `DbConnectionInterceptor`. The `Opened()` function is called whenever Entity Framework opens a connection and we set SESSION_CONTEXT with the current application `UserId` there. 

##### Predicate functions
The predicate functions we created in Enable-RLS.sql identify users by the `UserId` which was set by our interceptor whenever a connection is established from the application. The two types of predicates we created were **Filter** and **Block**. 
+ **Filter** predicates silently filter `SELECT`, `UPDATE`, and `DELETE` operations to exclude rows that do not satisfy the predicate. 
+ **Block** predicates explicitly block (throw errors) on `INSERT`, `UPDATE`, and `DELETE` operations that do not satisfy the predicate. 

### Dynamic Data Masking

#### Enable Dynamic Data Masking
+ Navigate to the /patients page
+ Connect to your deployed database using SSMS: [Instructions](https://azure.microsoft.com/en-us/documentation/articles/sql-database-connect-query-ssms/)
+ Open Enable-DDM.sql ([Find it here](Security%20Demo%20Queries/Enable-DDM.sql)) 
+ Execute the commands
+ Observe the changes in results returned on the /visits page

#### How did that work? 
Dynamic data masking limits sensitive data exposure by masking the data according to policies defined on the database level while the data in the database remains unchanged; this is based on the database user's permissions. Those with the `UNMASK` permission will 
have the ability to see the data without masks. In our case, the application's database login did not have the `UNMASK` permission and saw the data as masked. For your administrator login, the data was visible, as the user had the `UNMASK` permission. For more information on Dynamic Data Masking, [see the documentation](https://msdn.microsoft.com/en-us/library/mt130841.aspx). 

## Application Notes
The code included in this sample is only intended to provide a simple demo platform for users to enable and gain experience with Azure SQL Database (V12) security features; the demo web app is not intended to hold sensitive data and should not be used as a reference for applications that use or store sensitive data.Please take adequate steps to securely develop your application and store your data.  
