
# How to deploy an MLeap app

This sample assumes you are familar with MLeap. MLeap provides simple interfaces to execute entire ML pipelines. You can get additional information about MLeap [here](http://mleap-docs.combust.ml/). When you build a model in Spark, typically for training and need score this outside of Spark environment you can serialize the model as an MLeap bundle and score this outside of Spark. This allows model portability. This example  will demonstrate how a trained model serialized as MLeap bundle can be deployed as a RESTful webservice with a single line of code in SQL Server BDC 2019 and use as sample input in leap frame format to test it.

# Pre-requisites
SQL Server Big Data Cluster - CTP 2.3 or later
Clone or download this sample on your computer to a folder called mleap (note if you have downloaded it to a different folder then you'l have to modify the folder location appropriately in the sample below)


## Deploying the Application
Login to the SQL Server Big Data Cluster using the command below by replacing the hostIf you are not familar you can refer to the document [here](https://docs.microsoft.com/en-us/sql/big-data-cluster/big-data-cluster-create-apps?view=sqlallproducts-allversions) and then return to this sample.

```bash
mssqlctl login -e https://<ip-address-of-service-proxy-lb>:30777 -u <user-name> -p <password>
```

This example uses a Machine Learning Model that predicts the price per sq. ft given the location along wiht addtional paramters such as the type of dwelling. You can refer to the details and the example [here] (http://mleap-docs.combust.ml/mleap-serving/#load-model)
Deploy the app using the create command and pass the location of the spec file. Here the specification file is expected to be in the mleap folder. The specification file serves as the data required for deploying that app and it contains basic information about the app such as the name, version, inputs, outputs , replicas and poolsize you need for this app.

Here is the spec file for this application

```yaml
name: mleap
version: v1
runtime: Mleap
bundleFileName: model.lr.zip
replicas: 2
poolsize: 2
```

```bash
> mssqlctl app create --spec ./mleap
```

You can verify if the app has succesfully deployed by running the following command. The application you are deploying is Random Forest Model that was built in Spark and has been serialized in as an MLeap bundle. 

```bash
> mssqlctl app list -n mleap -v v1
```
Once you see the app state as "Ready" you can proceed to the next step below.

Now that the app has been deployed you can test if the app works correctly by passing in a sample input that is available in the mleap folder. The deployed app is a RESTful webservice that is swagger compliant. For this sample we will show you how you can test this using the CLI. 

The input parameter is a LeapFrame, a json file that describes the parameters and the values provided to the model for predicting the cost per square feet. 

Note that the input paramter has a special character '@' to indicate that a json file is being passed. This command needs to be run within the mleap folder. 

```bash
> mssqlctl app run --name mleap --version v1 --inputs mleap-frame=@frame.json
```
The result will be a json output that includes the prediction along with additional data. 

# Next Steps
You can learn how to train your model in Spark within SQL Server BDC and export to MLeap.(here) [https://docs.microsoft.com/en-us/sql/big-data-cluster/train-and-create-machinelearning-models-with-spark?view=sqlallproducts-allversions]

