---------------------------------------------------------------
# 15 HUMIO 
---------------------------------------------------------------

## 15.1 Installing HUMIO

Use Option 🐥`22` in Easy Install to install a `HUMIO ` instance

## 15.2 Live Humio integration with AI Manager

### 15.2.1 Humio URL

- Get the Humio Base URL from your browser
- Add at the end `/api/v1/repositories/aiops/query`


### 15.2.2 Accounts Token

Get it from Humio --> `Owl` in the top right corner / `Your Account` / `API Token
`

<div style="page-break-after: always;"></div>

### 15.2.3 Create Humio Log Integration

* In the `AI Manager` "Hamburger" Menu select `Operate`/`Data and tool integrations`
* Under `Humio`, click on `Add Connection`
* Click `Connect`
* Name it `Humio`
* Paste the URL from above (`Humio service URL`)
* Paste the Token from above (`API key`)
* In `Filters (optional)` put the following:

	```yaml
	"kubernetes.namespace_name" = /robot-shop/
	| "kubernetes.container_name" = web or ratings or catalogue
	```
* Click `Next`
* Put in the following mapping:

	```yaml
	{
	  "codec": "humio",
	  "message_field": "@rawstring",
	  "log_entity_types": "clusterName, kubernetes.container_image_id, kubernetes.host, kubernetes.container_name, kubernetes.pod_name",
	  "instance_id_field": "kubernetes.container_name",
	  "rolling_time": 10,
	  "timestamp_field": "@timestamp"
	}
	```

* Click `Test Connection`
* Switch `Data Flow` to the `ON` position ❗
* Select the option for your use case:
	* `Live data for continuous AI training and anomaly detection` if you want to enable log anomaly detection
	* `Live data for initial AI training` if you want to start ingesting live data for later training
	* `Historical data for initial AI training` if you want to ingest historical data to start training rapidly
* Click `Done`

<div style="page-break-after: always;"></div>

## 15.3 Manually installing HUMIO


> ❗This demo supports pre-canned events and logs, so you don't need to install and configure Humio unless you want to do a live integration (only partially covered in this document).

### 15.3.1 Create Licence Secret

Before starting the installation you have to create the Secret with the licence information.

```bash
oc create ns humio-logging
oc create secret generic humio-license -n humio-logging --from-literal=data=eyJhbGciOiJFUzxxxxaWmdRTrr_ksdfaa
```

### 15.3.2 Install Humio and Fluentbit

Just launch the following and this should automatically install:

* Kafka
* Zookeeper
* Humio Core
* Humio Repository
* Humio Ingest Token
* Fluentbit


```bash
ansible-playbook ./ansible/21_addons-install-humio.yaml
```

<div style="page-break-after: always;"></div>

## 15.4 Live Humio integration with Event Manager


### 15.4.1 Create Humio Events Integration

Events integration is done via EventManager/NOI.

For the time being this only takes the first alert being pushed over (no way to handle arrays).
The native Humio integration seems to have a bug that gives "mergeAdvanced is not a function".


#### 15.4.1.1 On the EventManager/NOI side

Create a Webhook integration:

| Field  | Value  | 
|---|---|
| Severity|"Critical"|
| Summary|  alert.name|
| Resource name | events[0]."kubernetes.container_name"|
| Event type |   events[0]."kubernetes.namespace_name"|



With this sample payload:

```json
{
  "repository": "aiops",
  "timestamp": "2021-11-19T15:50:04.958Z",
  "alert": {
    "name": "test1",
    "description": "",
    "query": {
      "queryString": "\"kubernetes.container_name\" = ratings\n| @rawstring = /error/i ",
      "end": "now",
      "start": "2s"
    },
    "notifierID": "Rq4a9KUbomSIBvEcdC7kzzmdBtPI3yPb",
    "id": "rCA2w5zaIE6Xr3RKlFfhAxqqbGqGxGLC"
  },
  "warnings": "",
  "events": [
    {
      "kubernetes.annotations.openshift_io/scc": "anyuid",
      "kubernetes.annotations.k8s_v1_cni_cncf_io/network-status": "[{\n    \"name\": \"k8s-pod-network\",\n    \"ips\": [\n        \"172.30.30.153\"\n    ],\n    \"default\": true,\n    \"dns\": {}\n}]",
      "kubernetes.annotations.cni_projectcalico_org/podIPs": "172.30.30.153/32",
      "@timestamp.nanos": "0",
      "kubernetes.annotations.k8s_v1_cni_cncf_io/networks-status": "[{\n    \"name\": \"k8s-pod-network\",\n    \"ips\": [\n        \"172.30.30.153\"\n    ],\n    \"default\": true,\n    \"dns\": {}\n}]",
      "kubernetes.pod_name": "ratings-5d9dff56bd-864kq",
      "kubernetes.labels.service": "ratings",
      "kubernetes.annotations.cni_projectcalico_org/podIP": "172.30.30.153/32",
      "kubernetes.host": "10.112.243.226",
      "kubernetes.container_name": "ratings",
      "kubernetes.labels.pod-template-hash": "5d9dff56bd",
      "kubernetes.docker_id": "87a98617a14684c02d9d52a6245af377f8b1a246d196f232cad494a7a2d125b7",
      "@ingesttimestamp": "1637337004272",
      "kubernetes.container_hash": "docker.io/robotshop/rs-ratings@sha256:4899c686c249464783663342620425dc8c75a5d59ca55c247cf6aec62a5fff1a",
      "kubernetes.container_image": "docker.io/robotshop/rs-ratings:latest",
      "#repo": "aiops",
      "@timestamp": 1637337003872,
      "kubernetes.namespace_name": "robot-shop",
      "@timezone": "Z",
      "@rawstring": "2021-11-19T09:50:03.872288692-06:00 stdout F [2021-11-19 15:50:03] php.INFO: User Deprecated: Since symfony/http-kernel 5.4: \"Symfony\\Component\\HttpKernel\\Event\\KernelEvent::isMasterRequest()\" is deprecated, use \"isMainRequest()\" instead. {\"exception\":\"[object] (ErrorException(code: 0): User Deprecated: Since symfony/http-kernel 5.4: \\\"Symfony\\\\Component\\\\HttpKernel\\\\Event\\\\KernelEvent::isMasterRequest()\\\" is deprecated, use \\\"isMainRequest()\\\" instead. at /var/www/html/vendor/symfony/http-kernel/Event/KernelEvent.php:88)\"} []",
      "@id": "tiMU0F8kdNf6x0qMduS9T31q_269_400_1637337003",
      "kubernetes.pod_id": "09d64ec8-c09f-4650-871f-adde27ca863e",
      "#type": "unparsed",
      "kubernetes.annotations.cni_projectcalico_org/containerID": "337bf300371c84500756a6e94e58b2d8ee54a1b9d1bc7e38eb410f1c1bbd6991"
    }
  ],
  "numberOfEvents": 1
}
```

#### 15.4.1.2 On Humio:

- Create Action:

	* Use the Webbhook from EventManager/NOI
	* Select `Skip Certificate Validation`
	* Click `Test Action` and check that you get it in EventManager/NOI Events

<div style="page-break-after: always;"></div>

- Create Alert:

	* 	With Query (for example):
	
		```json
		"kubernetes.container_name" = ratings
		| @rawstring = /error/i
		```

	* 	Time Window 2 seconds
	* 	1 second throttle window
	* 	Add action from above
	
	

### 15.5 Easily simulate erros

Simulate MySQL error by cutting the communication with the Pod:

```bash
oc patch -n robot-shop service mysql -p '{"spec": {"selector": {"service": "mysql-deactivate"}}}'
```

Restore the communication:

```bash
oc patch -n robot-shop service mysql -p '{"spec": {"selector": {"service": "mysql"}}}'
```

<div style="page-break-after: always;"></div>


