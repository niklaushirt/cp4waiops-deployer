---------------------------------------------------------------
# 20 Additional Configuration
---------------------------------------------------------------

## 20.1 Setup remote Kubernetes Observer



### 20.1.1 Get Kubernetes Cluster Access Details

As part of the kubernetes observer, it is required to communicate with the target cluster. So it is required to have the URL and Access token details of the target cluster. 

Do the following.


#### 20.1.1.1 Login

Login into the remote Kubernetes cluster on the Command Line.

#### 20.1.1.2 Access user/token 


Run the following:

```
./tools/97_addons/k8s-remote/remote_user.sh
```

This will create the remote user if it does not exist and print the access token (also if you have already created).

Please jot this down.



### 20.1.1 Create Kubernetes Observer Connection



* In the `AI Manager` "Hamburger" Menu select `Operate`/`Data and tool integrations`
* Click `Add connection`
* Under `Kubernetes`, click on `Add Integration`
* Click `Connect`
* Name it `RobotShop`
* Data Center `demo`
* Click `Next`
* Choose `Load` for Connection Type
* Input the URL you have gotten from the step above in `Kubernetes master IP address` (without the https://)
* Input the port for the URL you have gotten from the step above in `Kubernetes API port`
* Input the `Token` you have gotten from the step above
* Set `Trust all certificates by bypassing certificate verification` to `On`
* Set `Hide pods that have been terminated` to `On`
* Set `Correlate analytics events on the namespace groups created by this job` to `On`
* Set Namespace to `robot-shop`
* Click `Next`
* Click `Done`


![](./pics/k8s-remote.png)



## 20.2 AiManager Event Gateway

A Simple Webhook to Kafka Gateway for CP4WAIOPS.
This allows you to push generic JSON to AIManager Events throught a Webhook into Kafka.

> Source code is included if you want to mess around a bit.


### 20.2.1 Message mapping Parameters

Those Strings define how the message is being decoded.

To adapt the mapping parameters to your needs, you have to modify in the `cp4waiops-event-gateway-config` ConfigMap in file `./tools/97_addons/webhook/create-cp4mcm-event-gateway.yaml`.


The following paramters have to be mapped:

```yaml
ITERATE_ELEMENT: 'events'
NODE_ELEMENT: 'kubernetes.container_name'
ALERT_ELEMENT: 'kubernetes.namespace_name'
SUMMARY_ELEMENT: '@rawstring'
TIMESTAMP_ELEMENT: '@timestamp'
URL_ELEMENT: 'none'
SEVERITY_ELEMENT: '5'
MANAGER_ELEMENT: 'KafkaWebhook'
```

1. The `ITERATE_ELEMENT` is the element of the Message that we iterate over.
	This means that the Gateway will get the `ITERATE_ELEMENT`element and iterate, map and push all messages in the array.
1. The sub-elements that will be mapped for each element in the array are:

	- Node
	- AlertGroup
	- Summary
	- URL
	- Severity
	- Manager
	- Timestamp

> Any element that cannot be found will be defaulted by the indicated value.
> Example for Severity: If we put the mapping value "5" in the config, this probably won't correspond to a JSON key and the severity for all messages is forced to 5.

> Exception is `Timestamp` which, when not found will default to the current EPOCH date.





### 20.2.2 Getting the Kafka Conncetion Parameters

This gives you the Parameters for the Kafka Connection that you have to modify in the `cp4waiops-event-gateway-config` ConfigMap in file `./tools/97_addons/webhook/create-cp4mcm-event-gateway.yaml`.

```bash
export WAIOPS_NAMESPACE=cp4waiops
export KAFKA_SECRET=$(oc get secret -n {{ WAIOPS_NAMESPACE }} |grep 'aiops-kafka-secret'|awk '{print$1}')
export KAFKA_TOPIC=$(oc get kafkatopics -n $WAIOPS_NAMESPACE | grep -v cp4waiopscp4waiops| grep cp4waiops-cartridge-alerts-$EVENTS_TYPE| awk '{print $1;}')
export KAFKA_USER=$(oc get secret $KAFKA_SECRET -n $WAIOPS_NAMESPACE --template={{.data.username}} | base64 --decode)
export KAFKA_PWD=$(oc get secret $KAFKA_SECRET -n $WAIOPS_NAMESPACE --template={{.data.password}} | base64 --decode)
export KAFKA_BROKER=$(oc get routes iaf-system-kafka-0 -n $WAIOPS_NAMESPACE -o=jsonpath='{.status.ingress[0].host}{"\n"}'):443
export CERT_ELEMENT=$(oc get secret -n $WAIOPS_NAMESPACE kafka-secrets  -o 'go-template={{index .data "ca.crt"}}'| base64 -d)

echo "KAFKA_BROKER: '"$KAFKA_BROKER"'"
echo "KAFKA_USER: '"$KAFKA_USER"'"
echo "KAFKA_PWD: '"$KAFKA_PWD"'"
echo "KAFKA_TOPIC: '"$KAFKA_TOPIC"'"
echo "CERT_ELEMENT:  |- "
echo $CERT_ELEMENT

```

> You will have to indent the Certificate!



### 20.2.2 Deploying 

```bash
oc apply -n default -f ./tools/97_addons/k8s-remote/create-cp4mcm-event-gateway.yaml

oc get route -n cp4waiops cp4waiops-event-gateway  -o jsonpath={.spec.host}

```


### 20.2.3 Using the Webhook

For the following example we will iterate over the `events` array and epush them to mapped version to Kafka:


```bash
curl -X "POST" "http://cp4waiops-event-gateway-cp4waiops.itzroks-270003bu3k-azsa8n-6ccd7f378ae819553d37d5f2ee142bd6-0000.us-south.containers.appdomain.cloud/webhook" \
     -H 'Content-Type: application/json' \
     -H 'Cookie: 36c13f7095ac25e696d30d7857fd2483=e345512191b5598e33b76be85dd7d3b6' \
     -d $'{
  "numberOfEvents": 3,
  "repository": "aiops",
  "timestamp": "2021-11-19T15:50:04.958Z",
  "alert": {
    "id": "rCA2w5zaIE6Xr3RKlFfhAxqqbGqGxGLC",
    "query": {
      "end": "now",
      "queryString": "\\"kubernetes.container_name\\" = ratings| @rawstring = /error/i ",
      "start": "2s"
    },
    "name": "MyAlert",
    "description": "",
    "notifierID": "Rq4a9KUbomSIBvEcdC7kzzmdBtPI3yPb"
  },
  "events": [
    {
      "@rawstring": "Message 1",
      "@timestamp": 1639143464971,
      "kubernetes.container_name": "ratings",
      "kubernetes.namespace_name": "robot-shop",
    },
    {
      "@rawstring": "Message 2",
      "@timestamp": 1639143464982,
      "kubernetes.container_name": "catalogue",
      "kubernetes.namespace_name": "robot-shop",
    },
    {
      "@rawstring": "Message 3",
      "@timestamp": 1639143464992,
      "kubernetes.container_name": "web",
      "kubernetes.namespace_name": "robot-shop",
    }
  ],
  "warnings": ""
}'
```


<div style="page-break-after: always;"></div>
