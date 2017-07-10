#############################################################
#CRM Demo on CDNOW
#Fang Zhou
#############################################################
#install package
install.packages("rmarkdown")
install.packages("fpc")

#set directory
setwd("C:/Users/zhouf/Documents/Revolution Analytics/Demo/RREDemo/CRM")
data.path<-"C:/Users/zhouf/Documents/Revolution Analytics/Demo/RREDemo/CRM/Data/CDNOW_master"


##connect to SQL database using ODBC and read data from SQL via Open Source R
library(RODBC)
getSqlTypeInfo()
#connect from local PC
channel<-odbcDriverConnect("driver={SQL Server Native Client 11.0};server=tcp:sqlserver2012-81yms1ai.cloudapp.net,57500;database=RREDemoSql;uid=zhouf;pwd=Microsoft2;")
#connect from Windows201201
channel<-odbcConnect(dsn="MiningDatabaseSql",uid="zhouf",pwd="Microsoft1")
#connect with error
channel<-odbcDriverConnect('driver={SQL Server};server=tcp:192.168.220.128,1433;database=sqlr;uid=sa;pwd=Microsoft1')
						

df<-sqlFetch(channel, 'CDNOW')
df<- sqlQuery(channel,paste("select * from dbo.CDNOW"))
df$Date<-as.Date(df$Date)
str(df)
head(df)

#remove the rows with the duplicated IDs to see how many customers in total
uid <- df[!duplicated(df[,"ID"]),]
dim(uid)

#call RFM source code 
source("RFM_Analysis_R_Source_Codes_V1.3.R")

#set the startDate and endDate, we will only analysis the records in this date range
startDate <- as.Date("19970101","%Y%m%d")
endDate <- as.Date("19980701","%Y%m%d")

#calculate RFM value
df <- getDataFrame(df,startDate,endDate,tIDColName="ID",tDateColName="Date",tAmountColName="Amount")
head(df)

#obtain Independent RFM score
df1 <-getIndependentScore(df)
head(df1)

#draw the histograms in the R, F, and M dimensions 
drawHistograms(df1)

S500<-df1[df1$Total_Score>500,]
dim(S500)

S400<-df1[df1$Total_Score>400,]
dim(S400)


#obtain RFM score with breaks
#take a look at the distribution of R, F, M
par(mfrow = c(1,3))
hist(df$Recency)
hist(df$Frequency)
hist(df$Monetary)

#set the Recency ranges as 0-120 days, 120-240 days, 240-450 days, 450-500days, and more than 500days.
r <-c(120,240,450,500)
#set the Frequency ranges as 0 – 2times, 2-5 times,5-8 times, 8-10 times, and more than 10 times.
f <-c(2,5,8,10)
#set the Monetary ranges as 0-10 dollars, 10-20 dollars, and so on.
m <-c(10,20,30,100)

#calculate RFM score with breaks
df2<-getScoreWithBreaks(df,r,f,m)
drawHistograms(df2)

S500<-df2[df2$Total_Score>500,]
dim(S500)

S400<-df2[df2$Total_Score>400,]
dim(S400)

target <- df2[df2$Total_Score>=441,]
dim(target)

#obtain RFM scores with quantiles as breaks
r <-c(cutpoint(df$Recency))
f <-c(cutpoint(df$Frequency))
m <-c(cutpoint(df$Monetary))

df3<-getScoreWithBreaks(df,r,f,m)
str(df3)
head(df3)
tail(df3)

RFM_Result_osr<-subset(df3,select=c("ID","Recency","Frequency","Monetary","R_Score","F_Score","M_Score","Total_Score"))
colnames(RFM_Result_osr)<-c("ID","R","F","M","R_Score","F_Score","M_Score","Total_Score")
head(RFM_Result_osr)

system.time(
sqlSave(channel,RFM_Result_osr,rownames=FALSE,append=FALSE,varTypes=list(numeric="float",integer="int"))
)

sqlUpdate(channel,df)
odbcClose(channel)

#Clustering using RFM
library(fpc)
library(cluster)
#kmeans clustering with cluster =8
cl.fit1<-kmeans(RFM_Result_osr[,2:8],centers=8,iter.max=10,nstart=1)
cl.fit2<-kmeans(RFM_Result_osr[,2:8],centers=8,iter.max=20,nstart=200)

summary(cl.fit1)
cluster<-cl.fit1$cluster
centers<-cl.fit1$centers
size<-cl.fit1$size
plot(RFM_Result_osr[,2:4],col=cl.fit1$cluster)
title(main="K-means",line=3)	

##Classification using RFM
#Create IsVIP variable
IsVIP<-ifelse(RFM_Result_osr[,'Total_Score']>=441,1,0);
Cluster<-cl.fit1$cluster
RFMVIPCluster<-cbind(RFM_Result_osr,IsVIP,Cluster)

#Create training/testing data set
RD<-sample(1:10,dim(RFMVIPCluster)[1],replace=TRUE)
str(RD)
table(RD)
RFMVIPCluster$RD<-RD;
urv=factor(ifelse(RD<=8,'TRAIN','TEST'))
TrainTest<-cbind(RFMVIPCluster,urv)
Train<-TrainTest[which(TrainTest$urv=="TRAIN"),]
Test<-TrainTest[which(TrainTest$urv=="TEST"),]

#logistic model
##Build our Logistic Regression Model with IsVIP as response
r1<-glm(IsVIP~R+F+M, data=Train, family = binomial)
summary(r1)

p1<-predict.glm(r1,data=Test,type="response")
head(p1)
tail(p1)

#decision tree
#grow tree 
fit <- rpart(Cluster~R+F+M,
  	method="class", data=Train)

#display the results 
printcp(fit) 
#visualize cross-validation results 
plotcp(fit) 
#detailed summary of splits
summary(fit) 

# plot tree 
library(rpart)
plot(fit, uniform=TRUE, 
  	main="Classification Tree for CDNOW")
text(fit, use.n=TRUE, all=TRUE, cex=.8)

# prune the tree 
pfit<- prune(fit, cp= fit$cptable[which.min(fit$cptable[,"xerror"]),"CP"])

# plot the pruned tree 
plot(pfit, uniform=TRUE, 
  	main="Pruned Classification Tree for CDNOW")
text(pfit, use.n=TRUE, all=TRUE, cex=.8)

