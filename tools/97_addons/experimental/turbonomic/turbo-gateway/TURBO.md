## 12.3 Turbo to WAIOPS Gateway

**❗This is not an officialy supported tool by any means and is still under heavy development!**

In order to push Turbonomic Actions into Event Manager you can use my tool.
This tool needs existing `Business Applications`, you can either integrate with Instana (or other APMs) or create one under Settings/Topology.

1. Adapt the `./tools/10_turbonomic/turbo-gateway/create-turbo-gateway.yaml` file 

	| Variable | Default Value | Description |
	| -------- | ------------- | ----------- |
	|POLLING_INTERVAL| '300' | Poll every X seconds |
	|NOI_SUMMARY_PREFIX| '[Turbonomic] ' | Prefix in the event summary |
	|NOI_WEBHOOK_URL| netcool-evtmanager.apps.clustername.domain | Event Manager hostname |
	|NOI_WEBHOOK_PATH| /norml/xxxx | Webhook URL from Event Manager (does not inclue the hostname, only `/norml/xxxx`) |
	|TURBO_API_URL| api-turbonomic.apps.clustername.domain | Turbonomic API URL |
	|TURBO_BA_NAME| 'RobotShop:robot-shop'| Turbonomic application name in the format APPNAME:ALERTGROUP. This links an event manager alertgroup with an application |
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
	
	
	- replace the secret in the yaml file with
	
	
		```
		oc -n default create secret generic turbo-creds --from-literal=TURBO_USER=apiuser --from-literal=TURBO_PWD=turboadmin -o yaml --dry-run=client
		```
		
3. Create Generic Webhook in NOI with:

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
	oc apply -n default -f ./tools/10_turbonomic/turbo-gateway/create-turbo-gateway.yaml
	```
