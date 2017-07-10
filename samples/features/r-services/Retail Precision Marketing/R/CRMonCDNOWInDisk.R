
#############################################################
#CRM Demo on CDNOW
#Fang Zhou
#############################################################
##check if necessary R packages are installed
install.packages("RODBC")

library(RODBC)

##set directory
setwd("C:/Users/zhouf/Documents/Revolution Analytics/Demo/RREDemo/CRM")
data.path<-"C:/Users/zhouf/Documents/Revolution Analytics/Demo/RREDemo/CRM/Data/CDNOW_master"
output.path<-"C:/Users/zhouf/Documents/Revolution Analytics/Demo/RREDemo/CRM/Output/Xdf"

##Set Compute Context
#rxOptions(computeContext=RxLocalSeq())
rxOptions(computeContext=RxLocalParallel())
rxOptions(xdfCompressionLevel = -1)
rxOptions(reportProgress=1)
#-----------------------------------------------------------------------------------------------------------------------------------------------

##Connect to SQL database via RxOdbcData
CRMSQL = "SELECT * FROM dbo.CDNOW"
CRMDS<- RxOdbcData(sqlQuery = CRMSQL,
	       connectionString = "Driver={SQL Server Native Client 11.0};
	                           Server=tcp:sqlserver2012-81yms1ai.cloudapp.net,57500;
							   Database=RREDemoSql;Uid=zhouf;Pwd=Microsoft1;")
						
CRMDS<- RxOdbcData(sqlQuery = CRMSQL,
	       connectionString = "Driver=SQL Server;
		                      Server=tcp:192.168.220.128,1433;
							  Database=sqlr;
							  Uid=sa;
							  Pwd=Microsoft1")						

#CRMDS<- RxOdbcData(sqlQuery = CRMSQL,
#	connectionString = "Driver={SQL Server Native Client 11.0};Server=tcp:168.63.172.116,57500;Database=RREDemoSql;Uid=zhouf;Pwd=Microsoft1;")
#CRMDS<- RxOdbcData(sqlQuery = CRMSQL,
#connectionString = "DSN=MiningDatabaseSql;Uid=zhouf;Pwd=Microsoft1;")
#CRMDataFile <- RxXdfData("CDNOW_master.xdf")
CRMDataFile<-file.path(output.path,"CDNOW_master.xdf")
##Read data with RRE
dfcolInfo<-list(
	ID=list(type="factor"),
	Date=list(type="character"),
	Volume=list(type="numeric"),
	Amount=list(type="numeric")
	)
rxImport(inData=CRMDS,outFile =CRMDataFile,colInfo=dfcolInfo,overwrite =TRUE,useFastRead=TRUE)
#rxImport(inData=CRMDS,outFile =CRMDataFile,overwrite =TRUE,useFastRead=TRUE)
rxGetInfo(CRMDataFile,getVarInfo=T,numRows=3)
#------------------------------------------------------------------------------------------------------------------------------------------------------------

##Connect to SQL database via odbcConnect
#channel<-odbcConnect("Driver={SQL Server Native Client 11.0};Server=tcp:sqlserver2012-81yms1ai.cloudapp.net,57500;Database=AIAPoVSql;Uid=zhouf;Pwd=Microsoft2;")
channel<-odbcConnect(dsn="MiningDatabaseSql",uid="zhouf",pwd="Microsoft1")

channel<-odbcDriverConnect(connection="Driver=SQL Server;
		                      Server=tcp:192.168.176.132,1433;
							  Database=sqlr;
							  Uid=sa;
							  Pwd=Microsoft1")
##Read data from SQL via OSR
aia<-sqlQuery(channel,paste(" select * from dbo.AIOE_MODAL_RAWDATAL_revised"))
df<-sqlFetch(channel, 'CDNOW')
df<- sqlQuery(channel,paste("select * from dbo.CDNOW"))
#df.csv <- file.path(data.path,"CDNOW_master.csv")
df.xdf<-file.path(output.path,"CDNOW_master.xdf")
dfcolInfo<-list(
	ID=list(type="factor"),
	Date=list(type="Date"),
	Volume=list(type="numeric"),
	Amount=list(type="numeric")
	)
rxImport(inData=df,outFile =df.xdf,colInfo=dfcolInfo,overwrite =TRUE,useFastRead=F)
rxGetInfo(df.xdf,getVarInfo=T,numRows=3)
#------------------------------------------------------------------------------------------------------

df.xdf<-file.path(output.path,"CDNOW_master.xdf")
df1.xdf<-file.path(output.path,"CDNOW_master1.xdf")
rxDataStep(inData=df.xdf,outFile=df1.xdf,
	    transforms=list(
		Date=as.Date(Date,"%Y-%m-%d")
		),
	    removeMissings=TRUE,
	    overwrite=T)
rxGetInfo(df1.xdf,getVarInfo=T,numRows=3)
#rxSummary(~ID+Date+Volume+Amount,df.xdf)

##Step 1: RFM Model
# set the startDate and endDate, we will only analysis the records in this date range
RFMSQL="SELECT * FROM dbo.RFM_Result"
RFMDS<- RxOdbcData(sqlQuery = RFMSQL,
	       connectionString = "Driver=SQL Server;
		                      Server=tcp:192.168.176.130,1433;
							  Database=sqlr;
							  Uid=sa;
							  Pwd=Microsoft1")			
RFMResult.xdf<-file.path(output.path,"RFM_Result.xdf")
rxImport(inData=RFMDS,outFile =RFMResult.xdf,overwrite =TRUE,useFastRead=TRUE)
rxGetInfo(RFMResult.xdf,getVarInfo=T,numRows=3)
#visualize the RFM values
rxHistogram(~R,data=RFMResult.xdf, xNumTicks=20)
rxHistogram(~F,data=RFMResult.xdf,rowSelection=F<30,
            xNumTicks=20)
rxHistogram(~M,data=RFMResult.xdf,rowSelection=M<200,
            xNumTicks=20)  

#count frequency of each RFMscore Level
tmp<-rxCube(~F(Total_Score),data=RFMResult.xdf)
results <- rxResultsDF(tmp)
results<-results[results$Counts!=0,]
results[order(results$Counts,decreasing=TRUE),]

##Step 2: K-means Clustering

#K-means Clustering 
Kmeans.xdf<-file.path(output.path,"Kmeans.xdf")
md.km <- rxKmeans(formula=~R+F+M+R_Score+F_Score+M_Score, 
						data = RFMResult.xdf, 
 						outFile =Kmeans.xdf,
						numClusters=8,
						algorithm = "lloyd",
						writeModelVars=TRUE,
						overwrite=TRUE)
rxGetInfo(Kmeans.xdf,getVarInfo=TRUE,numRows=10)

centers<-round(md.km$centers,digits=2)
size<-md.km$size
centers.txt<-file.path(output.path,"centers.txt")
write.table(centers,file=centers.txt,sep=" ")
size.txt<-file.path(output.path,"size.txt")
write.table(size,file=size.txt,sep=" ")

mdDf <- rxXdfToDataFrame(file=Kmeans.xdf)
head(mdDf)
plot(mdDf[,2:7],col=mdDf$.rxCluster)
title(main="RFM-based K-means on CDNOW Data",line=3)	
##Step 3: Prediction-logistic and decision tree

##1.Prediction on Personal Customer Data without considering age and sex
#Create IsVIP variable
RFMVIP.xdf<-file.path(output.path,"RFMVIP.xdf")
rxDataStep(inData=RFMResult.xdf,outFile=RFMVIP.xdf,
         transforms=list(IsVIP=ifelse(Toltal_Score>=441,1,0)),
        overwrite=TRUE,reportProgress=1
)
RFMVIPInfo<-rxGetInfo(RFMVIP.xdf,getVarInfo=T,numRows=3)

#Write IsVIP and Cluster result to SQL database 
RFMVIP.df<-rxXdfToDataFrame(file=RFMVIP.xdf)
Cluster<-factor(mdDf$.rxCluster)
RFMVIPCluster<-cbind(RFMVIP.df,Cluster)
sqlSave(channel,RFMVIPCluster,rownames=FALSE,append=FALSE,varTypes=list(numeric="float",integer="int",Date="date"))


#Creat training/testing data set
RD<-sample(1:10,RFMVIPInfo$numRows,replace=TRUE)
str(RD)
table(RD)
RFMVIPCluster$RD<-RD;
RFMVIPCluster.xdf<-file.path(output.path,"RFMVIPCluster.xdf")
rxDataFrameToXdf(data=RFMVIPCluster,outFile=RFMVIPCluster.xdf,overwrite=TRUE)

TrainTest.xdf<-file.path(output.path,"TrainTest.xdf")
rxDataStep(inData=RFMVIPCluster.xdf,outFile=TrainTest.xdf,
	       transforms=list(
			urv=factor(ifelse(RD<=8,'TRAIN','TEST'))
			),
           overwrite=T)
rxGetInfo(TrainTest.xdf,T,numRows=3)

##Split data into training/testing data set
train.xdf <- file.path(output.path,'TrainTest.urv.TRAIN.xdf')
test.xdf <- file.path(output.path,'TrainTest.urv.TEST.xdf')

rxSplit(TrainTest.xdf,outFilesBase=TrainTest.xdf,splitByFactor='urv',overwrite=T,reportProgress=1)

##Build our Logistic Regression Model with IsVIP as response
r1<- rxLogit(IsVIP~R+F+M,
data =train.xdf,
variableSelection = rxStepControl(method="stepwise",
scope = ~ R+F+M))
summary(r1)


##r1:stepwise selection shows that Monetary,Recency are significant.
##Build our Logistic REgression MOdel
r2<- rxLogit(IsVIP ~R+F,
data =train.xdf,covCoef=TRUE)
summary(r2)

##Predict our Logistic Model on our test Dataset
LogisticPred.xdf<-file.path(output.path,"LogisticPred.xdf")
rxPredict(r2,data=test.xdf,outData=LogisticPred.xdf,writeModelVars = TRUE,extraVarsToWrite="ID",computeResiduals=TRUE,computeStdErr = TRUE,
interval = "confidence",predVarNames='LogitPredict',overwrite=TRUE)
rxGetInfo(LogisticPred.xdf,getVarInfo=T,numRows=10)
LogisticPredInfoTop10<-rxGetInfo(LogisticPred.xdf,getVarInfo=T,numRows=10)
LogisticPredInfoTop10.txt<-file.path(output.path,"LogisticPredInfoTop10.txt")
write.table(LogisticPredInfoTop10$data,file=LogisticPredInfoTop10.txt,sep=" ")

LogisticPred<-rxXdfToDataFrame(file=LogisticPred.xdf)
sqlSave(channel,LogisticPred,rownames=FALSE,append=FALSE,varTypes=list(numeric="float",integer="int",Date="date"))


##Draw a ROC curve
rxRocCurve(actualVarName='IsVIP',predVarNames='LogitPredict',data=LogisticPred.xdf)

##Build a Decision Tree with Cluster as response
d1 <- rxDTree(Cluster~R+F+M,data=train.xdf,blocksPerRead=5)
d1 <- rxDTree(Cluster~R_Score+F_Score+M_Score,data=train.xdf,blocksPerRead=5)
d1Cp<- rxDTreeBestCp(d1)
d1 <- prune.rxDTree(d1, cp=d1Cp)
d1
d2 <- rxDTree(Cluster~R+F+M,data=train.xdf, pruneCp="auto")
d2 <- rxDTree(Cluster~R_Score+F_Score+M_Score,data=train.xdf, pruneCp="auto")
d2

#View Decision Tree
#View 1
library(RevoTreeView)
plot(createTreeView(d1))
plot(createTreeView(d2))

#View 2
library(rpart)
plot(rxAddInheritance(d1))
text(rxAddInheritance(d1))
title(main="RFM-based Decision Tree on CDNOW Data",line=3)	
plot(rxAddInheritance(d2))
text(rxAddInheritance(d2))
title(main="RFM-based Decision Tree on CDNOW Data",line=3)	

#Prediction
DTreePred.xdf<-file.path(output.path,"DTreePred.xdf")
rxPredict(d2, data=test.xdf,outData=DTreePred.xdf,predVarNames=c('prob1','prob2','prob3','prob4','prob5','prob6','prob7','prob8'),writeModelVars = TRUE,extraVarsToWrite="ID",computeResiduals=T,overwrite=TRUE)
rxGetInfo(DTreePred.xdf,getVarInfo=T,numRows=3)
DTreePredInfoTop10<-rxGetInfo(DTreePred.xdf,getVarInfo=T,numRows=10)
DTreePredInfoTop10.txt<-file.path(output.path,"DTreePredInfoTop10.txt")
write.table(DTreePredInfoTop10$data,file=DTreePredInfoTop10.txt,sep=" ")

DTreePred<-rxXdfToDataFrame(file=DTreePred.xdf)
sqlSave(channel,DTreePred,rownames=FALSE,append=FALSE,varTypes=list(numeric="float",integer="int",Date="date"))
odbcClose(channel)

#-------------------------------------------------------------------------------------
##Build a Decision Tree with IsVIP as response
d<-rxDTree(IsVIP~R+F+M,data=train.xdf,maxDepth=5,blocksPerRead=5)
d1 <- rxDTree(IsVIP~R+F+M,data=train.xdf,blocksPerRead=5)
d1
d1Cp<- rxDTreeBestCp(d1)
d1 <- prune.rxDTree(d1, cp=d1Cp)
d2 <- rxDTree(IsVIP~R+F+M,data=train.xdf, pruneCp="auto")
d2

#View Decision Tree
#View 1
library(RevoTreeView)
plot(createTreeView(d))
plot(createTreeView(d1))
plot(createTreeView(d2))

#View 2
library(rpart)
plot(rxAddInheritance(d))
text(rxAddInheritance(d))
title(main="RFM-based Decision Tree on CDNOW Data",line=3)	
plot(rxAddInheritance(d1))
text(rxAddInheritance(d1))
title(main="RFM-based Decision Tree on CDNOW Data",line=3)	
plot(rxAddInheritance(d2))
text(rxAddInheritance(d2))
title(main="RFM-based Decision Tree on CDNOW Data",line=3)	

#Prediction
DTreePred.xdf<-file.path(output.path,"DTreePred.xdf")
rxPredict(d, data=test.xdf,outData=DTreePred.xdf,writeModelVars = TRUE,extraVarsToWrite="ID",computeResiduals=T,overwrite=TRUE)
rxGetInfo(DTreePred.xdf,getVarInfo=T,numRows=3)
DTreePredInfoTop10<-rxGetInfo(DTreePred.xdf,getVarInfo=T,numRows=10)
DTreePredInfoTop10.txt<-file.path(output.path,"DTreePredInfoTop10.txt")
write.table(DTreePredInfoTop10$data,file=DTreePredInfoTop10.txt,sep=" ")

#Draw ROC
rxRocCurve(actualVarName='IsVIP',predVarNames='IsVIP_Pred',data=DTreePred.xdf)