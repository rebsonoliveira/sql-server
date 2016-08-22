####################################################################################################
## Title: Telco Customer Churn
## Description: Train the Telco Churn Model with mxFastTree
## Author: Microsoft
####################################################################################################

trainModel = function(sqlSettings, trainTable) {
    sqlConnString = sqlSettings$connString

    trainDataSQL <- RxSqlServerData(connectionString = sqlConnString,
                                    table = trainTable,
                                    colInfo = cdrColInfo)

    ## Create training formula
    labelVar = "churn"
    trainVars <- rxGetVarNames(trainDataSQL)
    trainVars <- trainVars[!trainVars %in% c(labelVar)]
    temp <- paste(c(labelVar, paste(trainVars, collapse = "+")), collapse = "~")
    formula <- as.formula(temp)

    ## Train gradient tree boosting with mxFastTree on SQL data source
    library(MicrosoftRML)
    mx_fasttree_model <- mxFastTree(formula = formula,
                                    data = trainDataSQL,
                                    type = "binary",
                                    numTrees = 500,
                                    numLeaves = 20,
                                    learningRate = 0.2,
                                    minSplit = 10,
                                    unbalancedSets = TRUE,
                                    randomSeed = 8)

    return(mx_fasttree_model)
}