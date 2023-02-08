---------------------------------------------------------------

# 9 TROUBLESHOOTING
---------------------------------------------------------------

## 9.1 Check with script

❗ There is a new script that can help you automate some common problems in your CP4WAIOPS installation.

Just run:

```
./tools/10_debug_install.sh
```

and select `Option 1`


## 9.2 Pods in Crashloop

If the evtmanager-topology-merge and/or evtmanager-ibm-hdm-analytics-dev-inferenceservice are crashlooping, apply the following patches. I have only seen this happen on ROKS.

```bash
export WAIOPS_NAMESPACE=cp4waiops

oc patch deployment evtmanager-topology-merge -n $WAIOPS_NAMESPACE --patch-file ./yaml/waiops/pazch/topology-merge-patch.yaml


oc patch deployment evtmanager-ibm-hdm-analytics-dev-inferenceservice -n $WAIOPS_NAMESPACE --patch-file ./yaml/waiops/patch/evtmanager-inferenceservice-patch.yaml
```


<div style="page-break-after: always;"></div>

## 9.3 Pods with Pull Error

If the ir-analytics or cassandra job pods are having pull errors, apply the following patches. 

```bash
export WAIOPS_NAMESPACE=cp4waiops

kubectl patch -n $WAIOPS_NAMESPACE serviceaccount aiops-topology-service-account -p '{"imagePullSecrets": [{"name": "ibm-entitlement-key"}]}'
kubectl patch -n $WAIOPS_NAMESPACE serviceaccount aiops-ir-analytics-spark-worker -p '{"imagePullSecrets": [{"name": "ibm-entitlement-key"}]}'
kubectl patch -n $WAIOPS_NAMESPACE serviceaccount aiops-ir-analytics-spark-pipeline-composer -p '{"imagePullSecrets": [{"name": "ibm-entitlement-key"}]}'
kubectl patch -n $WAIOPS_NAMESPACE serviceaccount aiops-ir-analytics-spark-master -p '{"imagePullSecrets": [{"name": "ibm-entitlement-key"}]}'
kubectl patch -n $WAIOPS_NAMESPACE serviceaccount aiops-ir-analytics-probablecause -p '{"imagePullSecrets": [{"name": "ibm-entitlement-key"}]}'
kubectl patch -n $WAIOPS_NAMESPACE serviceaccount aiops-ir-analytics-classifier -p '{"imagePullSecrets": [{"name": "ibm-entitlement-key"}]}'
kubectl patch -n $WAIOPS_NAMESPACE serviceaccount aiops-ir-lifecycle-eventprocessor-ep -p '{"imagePullSecrets": [{"name": "ibm-entitlement-key"}]}'
oc delete pod $(oc get po -n $WAIOPS_NAMESPACE|grep ImagePull|awk '{print$1}') -n $WAIOPS_NAMESPACE


```


## 9.4 Camel-K Handlers Error

If the scm-handler or snow-handler pods are not coming up, apply the following patches. 

```bash
export WAIOPS_NAMESPACE=cp4waiops

oc patch vaultaccess/ibm-vault-access -p '{"spec":{"token_period":"760h"}}' --type=merge -n $WAIOPS_NAMESPACE
oc delete pod $(oc get po -n $WAIOPS_NAMESPACE|grep 0/| grep -v "Completed"|awk '{print$1}') -n $WAIOPS_NAMESPACE

```




## 9.5 Slack integration not working

See [here](../README.md#57-create-valid-cp4waiops-certificate-optional)

<div style="page-break-after: always;"></div>



## 9.6 Check if data is flowing

### 9.6.1 Check Log injection

To check if logs are being injected through the demo script:

1. Launch 

	```bash
	./tools/22_monitor_kafka.sh
	```
2. Select option 4

You should see data coming in.

### 9.6.2 Check Events injection

To check if events are being injected through the demo script:

1. Launch 

	```bash
	./tools/22_monitor_kafka.sh
	```
2. Select option 3

You should see data coming in.

### 9.6.3 Check Stories being generated

To check if stories are being generated:

1. Launch 

	```bash
	./tools/22_monitor_kafka.sh
	```
2. Select option 2

You should see data being generated.

<div style="page-break-after: always;"></div>

## 9.7 Docker Pull secret

####  ❗⚠️ Make a copy of the secret before modifying 
####  ❗⚠️ On ROKS (any version) and before 4.7 you have to restart the worker nodes after the modification  

We learnt this the hard way...

```bash
oc get secret -n openshift-config pull-secret -oyaml > pull-secret_backup.yaml
```

or more elegant

```bash
oc get Secret -n openshift-config pull-secret -ojson | jq 'del(.metadata.annotations, .metadata.creationTimestamp, .metadata.generation, .metadata.managedFields, .metadata.resourceVersion , .metadata.selfLink , .metadata.uid, .status)' > pull-secret_backup.json
```

In order to avoid errors with Docker Registry pull rate limits, you should add your Docker credentials to the Cluster.
This can occur especially with Rook/Ceph installation.

* Go to Secrets in Namespace `openshift-config`
* Open the `pull-secret`Secret
* Select `Actions`/`Edit Secret` 
* Scroll down and click `Add Credentials`
* Enter your Docker credentials

	![](./pics/dockerpull.png)

* Click Save

If you already have Pods in ImagePullBackoff state then just delete them. They will recreate and should pull the image correctly.




<div style="page-break-after: always;"></div>

## 9.8 Monitor ElasticSearch Indexes

At any moment you can run `./tools/28_access_elastic.sh` in a separate terminal window.

This allows you to access ElasticSearch and gives you:

* ES User
* ES Password

	![](./pics/es0.png)
	

### 9.8.1 Monitor ElasticSearch Indexes from Firefox

I use the [Elasticvue](https://addons.mozilla.org/en-US/firefox/addon/elasticvue/) Firefox plugin.

Follow these steps to connects from Elasticvue:

- Select `Add Cluster` 
	![](./pics/es1.png)

<div style="page-break-after: always;"></div>

- Put in the credentials and make sure you put `https` and not `http` in the URL
	![](./pics/es2.png)
- Click `Test Connection` - you will get an error
- Click on the `https://localhost:9200` URL
	![](./pics/es3.png)
	
<div style="page-break-after: always;"></div>

- This will open a new Tab, select `Accept Risk and Continue` 
	![](./pics/es4.png)
- Cancel the login screen and go back to the previous tab
- Click `Connect` 
- You should now be connected to your AI Manager ElasticSearch instance 
	![](./pics/es5.png)

<div style="page-break-after: always;"></div>
