---------------------------------------------------------------
## 4. Configure Applications and Topology
---------------------------------------------------------------



### 4.1 Create Kubernetes Observer for the Demo Applications

Do this for your applications (RobotShop by default)

* In CP4WAIOPS go into `Define` / `Data and tool integrations` / `Advanced` / `Manage ObserverJobs` / `Add a new Job`
* Select `Kubernetes` / `Configure`
* Choose “local”
* Set Unique ID to `<app-namespace>` (robot-shop,...)
* Set Datacenter (I use "demo")
* Set `Correlate` to `true`
* Set Namespace to `<app-namespace>` (robot-shop, ...)
* Set Provider to whatever you like (usually I set it to “listenJob” as well)
* `Save`


### 4.2 Create REST Observer to Load Topologies

* In CP4WAIOPS go into `Define` / `Data and tool integrations` / `Advanced` / `Manage ObserverJobs` / `Add a new Job`
* Select `REST`/ `Configure`
* Choose “bulk_replace”
* Set Unique ID to “listenJob” (important!)
* Set Provider to whatever you like (usually I set it to “listenJob” as well)
* `Save`



### 4.3 Create Merge Rules for Kubernetes Observer

Launch the following:

```bash
./tools/5_topology/create-merge-rules.sh
```


### 4.4 Load Merge Topologies

This will load the overlay topology for RobotShop:

```bash
./tools/5_topology/create-merge-topology-robotshop.sh

```

This will create Merge Topologies for RobotShop.

❗ Please manually re-run the Kubernetes Observer to make sure that the merge has been done.


### 4.5 Create AIOps Application

#### Robotshop

* In CP4WAIOPS go into `Operate` / `Application Management` 
* Click `Create Application`
* Select `robot-shop` namespace
* Click `Add to Application`
* Name your Application (RobotShop)
* If you like check `Mark as favorite`
* Click `Save`







---------------------------------------------------------------
## 6. Training
---------------------------------------------------------------
### 6.1 Train Log Anomaly - RobotShop


#### 6.1.1 Create Kafka Training Integration

* In the CP4WAIOPS "Hamburger" Menu select `Operate`/`Data and tool integrations`
* Under `Kafka`, click on `Add Integration`
* Name it `HumioInject`
* Select `Data Source` / `Logs`
* Select `Mapping Type` / `Humio`
* Paste the following in `Mapping` (the default is **incorrect**!:

	```json
	{
	"codec": "humio",
	"message_field": "@rawstring",
	"log_entity_types": "kubernetes.namespace_name,kubernetes.container_hash,kubernetes.host,kubernetes.container_name,kubernetes.pod_name",
	"instance_id_field": "kubernetes.container_name",
	"rolling_time": 10,
	"timestamp_field": "@timestamp"
	}
	```
	
* Toggle `Data Flow` to the `ON` position
* Select `Data feed for initial AI Training`
* Click `Save`

#### 6.1.2 Load Training Data into Kafka (Option 1: faster)

1. First unzip the file robotshop-12h.zip
	
	```bash
	cd ./training/TRAINING_FILES/KAFKA/robot-shop/logs
	unzip robotshop-12h.zip
	cd -
	```


1. Run the script to inject training data:
	
	```bash
	./training/robotshop-train-logs.sh
	```
	This takes some time (20-60 minutes depending on your Internet speed).




#### 6.1.2.1 Load Training Data directly into ElasticSearch (Option 2: Slower)

1. First unzip the file robotshop-logtrain.zip
	
	```bash
	cd ./training/TRAINING_FILES/ELASTIC/robot-shop/logs/
	unzip robotshop-logtrain.zip
	cd -
	```

1. Run this command in a separate terminal window to gain access to the Elasticsearch cluster:

	```bash
	while true; do oc port-forward statefulset/$(oc get statefulset | grep es-server-all | awk '{print $1}') 9200; done
	```


1. Run the script to inject training data:
	
	```bash
	./training/robotshop-train-logs-es.sh
	```
	This takes some time (40-90 minutes depending on your Internet speed).


If you want to check if the training data has been loaded you can execute (make sure you're on your aiops project/namespace):

```bash
oc exec -it $(oc get po |grep aimanager-aio-ai-platform-api-server|awk '{print$1}') -- bash


bash-4.4$ curl -u elastic:$ES_PASSWORD -XGET https://elasticsearch-ibm-elasticsearch-ibm-elasticsearch-srv.<YOUR WAIOPS NAMESPACE>.svc.cluster.local:443/_cat/indices  --insecure | grep logtrain | sort
```

You should get something like this (for 20210505 and 20210506):

```bash
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  2716  100  2716    0     0   9769      0 --:--:-- --:--:-- --:--:--  9769
yellow open 1000-1000-20210505-logtrain      06XVqpPTTlCPYlIfZqr-bA 1 1 315652 0  94.2mb  94.2mb
yellow open 1000-1000-20210506-logtrain      slP32RncT-eCEPiUPWrDDg 1 1 385026 0 114.4mb 114.4mb
```


#### 6.1.3 Create Training Definition

* In the CP4WAIOPS "Hamburger" Menu select `Operate`/`AI model management`
* Select `Log anomaly detection`
* Select `Create Training Definition`
* Select `Add Data`
* Select `05/05/21` (May 5th 2021 - dd/mm/yy) to `07/05/21` (May 7th 2021) as date range (this is when the logs we're going to inject have been created)
* Click `Next`
* Name it "LogAnomaly"
* Click `Next`
* Click `Create`


#### 6.1.4 Train the model

* In the training definition click on `Actions` / `Start Training`
* This will start a precheck that should tell you after a while that you are ready for training
* Click on `Actions` / `Start Training` again

After successful training you should get: 

![](./pics/training1.png)

* In the training definition click on `Actions` / `Deploy`


⚠️ If the training shows errors, please make sure that the date range of the training data is set to May 5th 2021 through May 7th 2021 (this is when the logs we're going to inject have been created)

#### 6.1.5 Enable Log Anomaly detection


* In the CP4WAIOPS "Hamburger" Menu select `Operate`/`Data and tool integrations`
* Under `Kafka`, click on `2 integrations`
* Select `HumioInject`
* Scroll down and select `Data feed for continuous AI training and anomaly detection`
* Switch `Data Flow` to `on`
* Click `Save`



### 6.2 Train Event Grouping



#### 6.2.1 Create Integration

* In the CP4WAIOPS "Hamburger" Menu select `Operate`/`Data and tool integrations`
* Under `Kafka`, click on `1 integration`
* Select `noi-default`
* Scroll down and select `Data feed for initial AI Training`
* Toggle `Data Flow` to the `ON` position
* Click `Save`

#### 6.2.2 Load Kafka Training Data

First we have to create some Events to train on.

* Make sure that you have pasted the Webhook (Generic Demo Webhook) from above into the file `./00_config-secrets.sh` for the variable `NETCOOL_WEBHOOK_GENERIC`.
* Run the Event Generation for 2-3 minutes. Then quit with `Ctrl-C`.
	
	```bash
	./training/robotshop-train-events.sh
	```

#### 6.2.3 Create Training Definition

* In the CP4WAIOPS "Hamburger" Menu select `Operate`/`AI model management`
* Select `Event grouping service`
* Select `Create Training Definition`
* Select `Add Data`
* Select `Last 90 Days` but set the end date to tomorrow
* Click `Next`
* Name it "EventGrouping"
* Click `Next`
* Click `Create`


#### 6.2.4 Train the model

* In the training definition click on `Actions` / `Start Training`

After successful training you should get: 

![](./pics/training2.png)

The "Needs improvement" is no concern for the time being.

* In the training definition click on `Actions` / `Deploy`

#### 6.2.5 Enable Event Grouping

* In the CP4WAIOPS "Hamburger" Menu select `Operate`/`Data and tool integrations`
* Under `Kafka`, click on `1 integration`
* Select `noi-default`
* Scroll down and select `Data feed for continuous AI training and anomaly detection`
* Switch `Data Flow` to `on`








### 6.3 Train Incident Similarity

### ❗ Only needed if you don't plan on doing the Service Now Integration

#### 6.3.1 Load Training Data directly into ElasticSearch



1. Run this command in a separate terminal window to gain access to the Elasticsearch cluster:

	```bash
	while true; do oc port-forward statefulset/$(oc get statefulset | grep es-server-all | awk '{print $1}') 9200; done
	```


1. Run the script to inject training data:
	
	```bash
	./training/robotshop-train-incidents.sh
	```
	This should not take more than 15-20 minutes.

	If you get asked if you want to Replace or Append, just choose Append.

If you want to check if the training data has been loaded you can execute (make sure you're on your aiops project/namespace):

```bash
oc exec -it $(oc get po |grep aimanager-aio-ai-platform-api-server|awk '{print$1}') -- bash


bash-4.4$ curl -u elastic:$ES_PASSWORD -XGET https://elasticsearch-ibm-elasticsearch-ibm-elasticsearch-srv.<YOUR WAIOPS NAMESPACE>.svc.cluster.local:443/_cat/indices  --insecure | grep incidenttrain | sort
```

You should get something like this (for 20210505 and 20210506):

```bash
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  4841  100  4841    0     0  28644      0 --:--:-- --:--:-- --:--:-- 28644
yellow open incidenttrain                        X6FAhONnRrGzHy9qOVIk8Q 1 1    139   0 142.9kb 142.9kb
```


#### 6.3.2 Create Training Definition

* In the CP4WAIOPS "Hamburger" Menu select `Operate`/`AI model management`
* Select `Similar incidents`
* Select `Create Training Definition`
* Click `Next`
* Name it "SimilarIncidents"
* Click `Next`
* Click `Create`


#### 6.3.3 Train the model

* In the training definition click on `Actions` / `Start Training`
* This will start a precheck that should tell you after a while that you are ready for training and start the training


After successful training you should get: 

![](./pics/training3.png)

* In the training definition click on `Actions` / `Deploy`











---------------------------------------------------------------
## 7. Configure Runbooks
---------------------------------------------------------------


### 7.1 Create Bastion Server

This creates a simple Pod with the needed tools (oc, kubectl) being used as a bastion host for Runbook Automation. 

```bash
oc apply -n default -f ./tools/6_bastion/create-bastion.yaml
```

### 7.2 Create the NOI Integration

#### 7.2.1 In NOI

* Go to  `Administration` / `Integration with other Systems` / `Automation Type` / `Script`
* Copy the SSH KEY


#### 7.2.2 Adapt SSL Certificate in Bastion Host Deployment. 

* Select the `bastion-host` Deployment in Namespace `default`
* Adapt Environment Variable SSH_KEY with the key you have copied above.



### 7.3 Create Automation


#### 7.3.1 Connect to Cluster
`Automation` / `Runbooks` / `Automations` / `New Automation`


```bash
oc login --token=$token --server=$ocp_url
```

Use these default values

```yaml
target: bastion-host-service.default.svc
user:   root
$token	 : Token from your login (from 80_get_logins.sh)	
$ocp_url : URL from your login (from 80_get_logins.sh, something like https://c102-e.eu-de.containers.cloud.ibm.com:32236)		
```


#### 7.3.2 RobotShop Mitigate MySql
`Automation` / `Runbooks` / `Automations` / `New Automation`


```bash
oc scale deployment --replicas=1 -n robot-shop ratings
oc delete pod -n robot-shop $(oc get po -n robot-shop|grep ratings |awk '{print$1}') --force --grace-period=0
```

Use these default values

```yaml
target: bastion-host-service.default.svc
user:   root		
```


### 7.4 Create Runbooks


* `Library` / `New Runbook`
* Name it `Mitigate RobotShop Problem`
* `Add Automated Step`
* Add `Connect to Cluster`
* Select `Use default value` for all parameters
* Then `RobotShop Mitigate Ratings`
* Select `Use default value` for all parameters
* Click `Publish`



-------
### 7.5 Add Runbook Triggers

* `Triggers` / `New Trigger`
* Name and Description: `Mitigate RobotShop Problem`
* Conditions
	* Name: RobotShop
	* Attribute: Node
	* Operator: Equals
	* Value: mysql-deployment or web
* Click `Run Test`
* You should get an Event `[Instana] Robotshop available replicas is less than desired replicas - Check conditions and error events - ratings`
* Select `Mitigate RobotShop Problem`
* Click `Select This Runbook`
* Toggle `Execution` / `Automatic` to `off`
* Click `Save`



---------------------------------------------------------------
## 9. Service Now integration
---------------------------------------------------------------



### 9.1 Integration 

1. Follow [this](./tools/9_servicenow/snow-Integrate.md) document to get and configure your Service Now Dev instance with CP4WAIOPS.
	Stop at `Testing the ServiceNow Integration`. 
	❗❗Don’t do the training as of yet.
2. Import the Changes from ./tools/9_servicenow/import_change.xlsx
	1. Select `Change - All` from the right-hand menu
	2. Right Click on `Number`in the header column
	3. Select Import
	![](./pics/snow3.png)
	3. Chose the ./tools/9_servicenow/import_change.xlsx file and click `Upload`
	![](./pics/snow4.png)
	3. Click on `Preview Imported Data`
	![](./pics/snow5.png)
	3. Click on `Complete Import` (if there are errors or warnings just ignore them and import anyway)
	![](./pics/snow6.png)
	
	
3. Import the Incidents from ./tools/9_servicenow/import_incidents.xlsx
	1. Select `Incidents - All` from the right-hand menu
	2. Proceed as for the Changes but for Incidents
	
4. Now you can finish configuring your Service Now Dev instance with CP4WAIOPS by [going back](./tools/9_servicenow/snow-Integrate.md#testing-the-servicenow-integration) and continue whre you left off at `Testing the ServiceNow Integration`. 






---------------------------------------------------------------
## 10. Some Polishing
---------------------------------------------------------------

### 10.1 Add LDAP Logins to CP4WAIOPS


* Go to CP4AIOps Dashboard
* Click on the top left "Hamburger" menu
* Select `User Management`
* Select `User Groups` Tab
* Click `New User Group`
* Enter demo (or whatever you like)
* Click Next
* Select `LDAP Groups`
* Search for `demo`
* Select `cn=demo,ou=Groups,dc=ibm,dc=com`
* Click Next
* Select Roles (I use Administrator for the demo environment)
* Click Next
* Click Create



### 10.2 Get Passwords and Credentials

At any moment you can run `./82_monitor_kafka.sh` this allows you to:

* List all Kafka Topics
* Monitor Derived Stories
* Monitor any specific Topic

You can monitor:

* **derived-stories**: Here you see the stories that get created and pushed to Slack/Teams
* **alerts-noi-1000-1000**: Check if Events from Event Manager are coming in and the Gateway is working as expected (only INSERTS are appearing here, so you might have to delete the Events in Event Manager first in order to recreate them)
* **windowed-logs-1000-1000**: Check log data flowing for log anomaly detection (NOT training)


