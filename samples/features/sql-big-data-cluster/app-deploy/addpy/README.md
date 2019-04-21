# Running a basic Python script in SQL Server big data cluster

### Contents

[About this sample](#about-this-sample)<br/>
[Before you begin](#before-you-begin)<br/>
[Run this sample](#run-this-sample)<br/>
[Sample details](#sample-details)<br/>
[Related links](#related-links)<br/>

<a name=about-this-sample></a>

## About this sample

This is a sample [Python](https://www.python.org/) app, which shows how to run a Python script in SQL Server big data cluster. This sample creates an app that adds two whole numbers and returns the result. The code for this sample is in [add.py](add.py). The inputs and outputs are shown below.

### Inputs
|Parameter|Description|
|-|-|
|`x`|The first whole number to add|
|`y`|The second whole number to add|

### Outputs
|Parameter|Description|
|-|-|
|`result`|The result of adding `x` and `y`|


<a name=before-you-begin></a>

## Before you begin

To run this sample, you need the following prerequisites.

**Software prerequisites:**

1. SQL Server big data cluster CTP 2.3 or later.
2. `mssqlctl`. Refer to [installing mssqlctl](https://docs.microsoft.com/en-us/sql/big-data-cluster/deploy-install-mssqlctl?view=sqlallproducts-allversions) document on setting up the `mssqlctl` and connecting to a SQL Server 2019 big data cluster.

<a name=run-this-sample></a>

## Run this sample

1. Clone or download this sample on your computer.
2. Log in to the SQL Server big data cluster using the command below using the IP address of the `mgmtproxy-svc-external` in your cluster. If you are not familiar with `mssqltctl` you can refer to the [documentation](https://docs.microsoft.com/en-us/sql/big-data-cluster/big-data-cluster-create-apps?view=sqlallproducts-allversions) and then return to this sample.

    ```bash
    mssqlctl login -e https://<ip-address-of-mgmtproxy-svc-external>:30777 -u <user-name> -p <password>
    ```
3. Deploy the application by running the following command, specifying the folder where your `spec.yaml` and `add.py` files are located:
    ```bash
    mssqlctl app create --spec ./addpy
    ```
4. Check the deployment by running the following command:
    ```bash
    mssqlctl app list -n addpy -v [version]
    ```
    Once the app is listed as `Ready` you can continue to the next step.
5. Test the app by running the following command:
    ```bash
    mssqlctl app run -n addpy -v [version] --input x=3,y=5
    ```
    You should get output like the example below. The result of adding 3+5 are returned as `result`.
    ```json
    {
      "changedFiles": [],
      "consoleOutput": "",
      "errorMessage": "",
      "outputFiles": {},
      "outputParameters": {
        "result": 8
      },
      "success": true
    }
    ```
6. <a name=restapi></a>Any app you create is also accessible using a RESTful web service that is [Swagger](swagger.io) compliant. You can get the endpoint for the web service by running:
   ```bash
   mssqlctl app describe --name addpy --version [version]
   ```
   This will return an output much like the following:
   ```json
   {
      "input_param_defs": [
        {
          "name": "x",
          "type": "int"
        },
        {
          "name": "y",
          "type": "int"
        }
      ],
      "links": {
        "app": "https://[IP]:[PORT]/api/app/addpy/[version]",
        "swagger": "https://[IP]:[PORT]/api/app/addpy/[version]/swagger.json"
      },
      "name": "addpy",
      "output_param_defs": [
        {
          "name": "result",
          "type": "int"
        }
      ],
      "state": "Ready",
      "version": "[version]"
    }
   ```
   Note the IP address and the port number in this output. Open the following URL in your browser:
   `https://[IP]:[PORT]/api/docs/swagger.json`. You will have to log in with the same credentials you used for `mssqlctl login`. The contents of the `swagger.json` you can paste into [Swagger Editor](https://editor.swagger.io) to understand what methods are available:
   ![API Swagger](api_swagger.png)

   Notice the `app` GET method as well as the `token` POST method. Since the authentication for apps uses JWT tokens you will need to get a token my using your favorite tool to make a POST call to the `token` method. Here is an example of how to do just that in [Postman](https://www.getpostman.com/):
   ![Postman Token](postman_token.png)

   The result of this request will give you an `access_token`, which you will need to call the URL to run the app.
   
   > *Optional*: If you want, you can open the URL for the `swagger` that was returned when you ran `mssqlctl app describe --name addpy --version [version]` in your browser. You will have to log in with the same credentials you used for `mssqlctl login`. The contents of the `swagger.json` you can paste into [Swagger Editor](https://editor.swagger.io). You will see that the web service exposes the `run` method.

   You can use your favorite tool to call the `run` method (`https://[IP]:30778/api/app/addpy/[version]/run`), passing in the parameters in the body of your POST request as json. In this example we will use [Postman](https://www.getpostman.com/). Before making the call, you will need to set the `Authorization` to `Bearer Token` and paste in the token you retrieved earlier. This will set a header on your request. See the screenshot below.
   ![Postman Run Headers](postman_run_1.png)
   Next, in the requests body, pass in the parameters to the app you are calling and set the `content-type` to `application/json`:
   ![Postman Run Body](postman_run_2.png)
   When you send the request, you will get the same output as you did when you ran the app through `mssqlctl app run`:
   ![Postman Run Result](postman_result.png)
   You have now successfully called the app through the web service!
   
7. You can clean up the sample by running the following commands:
    ```bash
    # delete app
    mssqlctl app delete --name addpy --version [version]
    ```

<a name=sample-details></a>

## Sample details

Please refer to [add.py](add.py) for the code for this sample.

### Spec file
Here is the spec file for this application. As you can see the sample uses the `Python` runtime and calls the `add` method in the `add.py` file, accepting two integer inputs named `x` and `y` and returning an integer output named `result`.

```yaml
name: addpy
version: v1
runtime: Python
src: ./add.py
entrypoint: add
replicas: 1
poolsize: 1
inputs:
  x: int
  y: int
output:
  result: int
```

<a name=related-links></a>

## Related Links
For more information, see these articles:

[How to deploy and app on SQL Server 2019 big data cluster (preview)](https://docs.microsoft.com/en-us/sql/big-data-cluster/big-data-cluster-create-apps?view=sqlallproducts-allversions)