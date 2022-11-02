

## 12.4 Generate Metrics

**❗This is not an officialy supported tool by any means and is still under heavy development!**

If you have manually created a `Business Applications` you won't get any ResponseTime and Transactions metrics.
With this tool you can you can add randomized ResponseTime and Transactions metrics to the `Business Application` through the `Data Integration Framework (DIF)`.

> Note: The metrics pod can also serve metrics for other `Entity` types (businessApplication, businessTransaction, service, databaseServer, application)
> 
> Note: There is also a Route being created by the installer, so that you can test the URLs.
> 

1. Launch

	```shell
	oc apply -n default -f ./tools/97_addons/experimental/turbonomic/turbo-metrics-dif/create-data-ingestion.yaml
	```

1. Wait for the Pod to become available
1. Add the DIF Target
	2. Go to `Settings/Target Configurations`
	2. Click `New Target`
	2. Select `Custom/DataIngestionFramework`
	2. Put in the URL for the metrics (see below) and a name
	2. Click `Add`
	3. Make sure that Target is green and reads `Validated`

It takes some time for the metrics to start showing up. Polling is every 10 minutes 

### 12.4.1 Test URL

You can use the following URL to test if everything is working:

`http://turbo-metrics-dif-service.turbonomic:3000/helloworld`

This will create a standalone `Business Application` called `Hello World` without any other `Entities` attached to it. 
But with metrics being ingested.

### 12.4.2 Construct the URL

The URL has the format of:

```yaml
http://turbo-metrics-dif-service.default:3000/<TYPE>/<NAME>/<UUID>
```

where:

- TYPE: Type of the `Entity` (businessApplication/businessTransaction/service/databaseServer/application)
- NAME: The name of the `Entity`
- UUID: The UUID that you can find under `Entity Information / Show All / Vendor ID`

So an example might be:
`http://turbo-metrics-dif-service.default:3000/service/Service-robot-shop%2Fcatalogue/b2d6fd52-c895-469e-bb98-2a791faefce7`
`http://turbo-metrics-dif-service.default:3000/businessApplication/RobotShop/285215220007744`


