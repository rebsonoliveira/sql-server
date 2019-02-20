
# The README will help you deploy a mleap application and consume the same. 

# Application `mleap/v1`



## Deploy Application

```bash
> mssqlctl login --entrypoint http://host:port --u <username> --p <password>
> mssqlctl app create --spec ./mleap
```

## Consume Application
# The following command will work if you use the sample

```bash
> mssqlctl app run --name mleap --version v1 --inputs mleap-frame=@frame.json
```

## Application `spec.yaml`

All your apps should be specified in a YAML file like this - it tells the CLI 
what to deploy onto your cluster:

```yaml
name: mleap
version: v1
runtime: Mleap
bundleFileName: model.lr.zip
replicas: 2
poolsize: 2
```

You can use this generated `/mleap/spec.yaml` as a starting point to modify the
application as you see fit.
