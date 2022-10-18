-----------------------------------------------------------------------------------
# 13 Configuring Turbonomic Addons
---------------------------------------------------------------



## 13.3 Installing kubeturbo

In order to get other Kubernetes clusters to show up in Turbonomic, you have to install `kubeturbo` (your main cluster is already registered).

1. Adapt `./ansible/templates/kubeturbo/my_kubeturbo_instance_cr.yaml` with the Turbonomic URL and the login
2. Launch

	```bash
	ansible-playbook ./ansible/20_addons-turbonomic-kubeturbo.yaml
	```
<div style="page-break-after: always;"></div>

## 13.4 Turbo to WAIOPS Gateway

**❗This is not an officialy supported tool by any means and is still under heavy development!**

In order to push Turbonomic Actions into EventManager you can use my tool.
This tool needs existing `Business Applications`, you can either integrate with Instana (or other APMs) or create one under Settings/Topology.

1. Adapt the `./ansible/templates/turbo-gateway/create-turbo-gateway.yaml` file 

	| Variable | Default Value | Description |
	| -------- | ------------- | ----------- |
	|POLLING_INTERVAL| '300' | Poll every X seconds |
	|EVTMGR_SUMMARY_PREFIX| '[Turbonomic] ' | Prefix in the event summary |
	|EVTMGR_WEBHOOK_URL| netcool-evtmanager.apps.clustername.domain | EventManager hostname |
	|EVTMGR_WEBHOOK_PATH| /norml/xxxx | Webhook URL from EventManager (does not inclue the hostname, only `/norml/xxxx`) |
	|TURBO_API_URL| api-turbonomic.apps.clustername.domain | Turbonomic API URL |
	|TURBO_BA_NAME| 'RobotShop:robot-shop'| Turbonomic application name in the format APPNAME:ALERTGROUP. This links an EventManager alertgroup with an application |
	|ACTION_STATES| 'SUCCEEDED,FAILED,READY,IN_PROGRESS' | The list of ACTION_STATES to filter on |
	|ACTION_TYPES| 'MOVE,RESIZE_FOR_PERFORMANCE,RESIZE_FOR_EFFICIENCY,RESIZE' | The list of ACTION_TYPES to filter on |
	|DEBUG_ENABLED| 'false' | Enable additional log output |
	|ENTITY_TYPES| 'VirtualMachine,Application,PhysicalMachine,ContainerSpec,WorkloadController,Container' | The list of ENTITY_TYPES to filter on |
	|ACTION_START_TIME| '-30m'| Period of time in which actions are retrieved. E.g. -5m, -30m, -1h, -1d, -3d, -7d | 

2. Create Turbonomic Credentials Secret

	You can either:
	
	- create the secret from the command line (which will throw a warning for the already existing Secret when installing)
	
		```
		oc -n default create secret generic turbo-creds --from-literal=TURBO_USER=<youruser> --from-literal=TURBO_PWD=<yourpw>
		```

<div style="page-break-after: always;"></div>

	- replace the secret in the yaml file with
	
		```
		oc -n default create secret generic turbo-creds --from-literal=TURBO_USER=apiuser --from-literal=TURBO_PWD=turboadmin -o yaml --dry-run=client
		```


​	
3. Create Generic Webhook in EventManager/NOI with:

	```json
	{
	"timestamp": "1619706828000",
	"severity": "Critical",
	"summary": "Test Event",
	"nodename": "productpage-v1",
	"alertgroup": "robotshop",
	"url": "https://myturbo/something.html"
	}
	```
4. Launch 

	```shell
	ansible-playbook ./ansible/20_3_addons-turbonomic-gateway.yaml
	```

<div style="page-break-after: always;"></div>

## 13.5 Generate Metrics

**❗This is not an officialy supported tool by any means and is still under heavy development!**

If you have manually created a `Business Applications` you won't get any ResponseTime and Transactions metrics.
With this tool you can you can add randomized ResponseTime and Transactions metrics to the `Business Application` through the `Data Integration Framework (DIF)`.

> Note: The metrics pod can also serve metrics for other `Entity` types (businessApplication, businessTransaction, service, databaseServer, application)
> 
> Note: There is also a Route being created by the installer, so that you can test the URLs.
> 

1. Launch

	```shell
	ansible-playbook ./ansible/20_2_addons-turbonomic-metrics.yaml
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

### 13.5.1 Test URL

You can use the following URL to test if everything is working:

`http://turbo-dif-service.default:3000/helloworld`

This will create a standalone `Business Application` called `Hello World` without any other `Entities` attached to it. 
But with metrics being ingested.

<div style="page-break-after: always;"></div>

### 13.5.2 Construct the URL

The URL has the format of:

```yaml
http://turbo-dif-service.default:3000/<TYPE>/<NAME>/<UUID>
```

where:

- TYPE: Type of the `Entity` (businessApplication/businessTransaction/service/databaseServer/application)
- NAME: The name of the `Entity`
- UUID: The UUID that you can find under `Entity Information / Show All / Vendor ID`

So an example might be:
`http://turbo-dif-service.default:3000/service/Service-robot-shop%2Fcatalogue/b2d6fd52-c895-469e-bb98-2a791faefce7`
`http://turbo-dif-service.default:3000/businessApplication/RobotShop/285333133684640`
`http://turbo-dif-service.default:3000/businessTransaction/RobotShopCatalog/285333292080720`
`http://turbo-dif-service.default:3000/businessTransaction/RobotShoßpPayment/285333133684640`
`http://turbo-dif-service.default:3000/businessTransaction/RobotShopUser/285333133684640`


<div style="page-break-after: always;"></div>
