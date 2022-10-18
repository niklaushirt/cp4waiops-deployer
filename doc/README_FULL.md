<center> <h1>CP4WatsonAIOps CP4WAIOPS v3.4.1</h1> </center>
<center> <h2>Demo Environment Installation - 🐥 EASY INSTALL</h2> </center>

![K8s CNI](./doc/pics/front.png)


<center> ©2022 Niklaus Hirt / IBM </center>


<div style="page-break-after: always;"></div>


### ❗ THIS IS WORK IN PROGRESS
Please drop me a note on Slack or by mail nikh@ch.ibm.com if you find glitches or problems.




<div style="page-break-after: always;"></div>

---------------------------------------------------------------
# Installation
---------------------------------------------------------------

1. [Changelog](./doc/CHANGELOG.md)
1. [Architecture](./doc/ARCHITECTURE.md)
1. [Prerequisites](./doc/PREREQUISITES.md)
1. [Troubleshooting](./doc/TROUBLESHOOTING.md)
1. [Uninstall CP4WAIOPS](./doc/UNINSTALL.md)
1. [AI Manager Install](./doc/INSTALL_AI_MANAGER.md)
1. [Event Manager Install](./doc/INSTALL_EVENT_MANAGER.md)
1. [Event Manager Configuration](./doc/CONF_EVENT_MANAGER.md)
1. [Runbook Configuration](./doc/CONF_RUNBOOKS.md)
1. [Installing Turbonomic](./doc/INSTALL_TURBONOMIC.md)
1. [Installing ELK (optional)](./doc/INSTALL_ELK.md)
1. [Installing Humio (optional)](./doc/INSTALL_HUMIO.md)
1. [Installing ServiceMesh/Istio](./doc/INSTALL_INSTALL_SERVICE_MESH.md)
1. [Installing AWX/AnsibleTower](./doc/INSTALL_AWX.md)
1. [Detailed Prerequisites](#18-detailed-prerequisites)
1. [Additional Configuration](./doc/CONF_MISC.md)
1. [Service Now integration](./doc/TRAINING_MANUAL.md)
1. [Manually train the models](./doc/TRAINING_MANUAL.md)


<div style="page-break-after: always;"></div>


# ❗ This Documentation is work in progress


---------------------------------------------------------------
# 1 Introduction
---------------------------------------------------------------

This repository contains the scrips for installing a Watson AIOps demo environment with an Ansible based installer.

They have been ported over from the shell scripts here [https://github.ibm.com/NIKH/aiops-3.1](https://github.ibm.com/NIKH/aiops-3.1).



This is provided `as-is`:

* I'm sure there are errors
* I'm sure it's not complete
* It clearly can be improved


**❗This has been tested for the new CP4WAIOPS v3.4.1 release on OpenShift 4.8.**

**I have tested on ROKS 4.8 and the scripts run to completion.**


So please if you have any feedback contact me 

- on Slack: Niklaus Hirt or
- by Mail: nikh@ch.ibm.com


<div style="page-break-after: always;"></div>



---------------------------------------------------------------
# 🐥 2 Easy Install
---------------------------------------------------------------

I have provided a tool to very easily install the different components.

Please follow this chapter and execute all steps marked with 🟢.


## 2.1 Get the code 🟢

Clone the GitHub Repository


```
git clone https://<YOUR GIT TOKEN>@github.ibm.com/NIKH/aiops-install-ansible-fvt-33.git 
```


## 2.2 Prerequisites 

### 2.2.1 OpenShift requirements 🟢

I installed the demo in a ROKS environment.

You'll need:

- ROKS 4.8 (4.6 should work also)
- 5x worker nodes Flavor `b3c.16x64` (so 16 CPU / 64 GB) 

You might get away with less if you don't install some components (Event Manager, ELK, Turbonomic,...):

- Typically 3x worker nodes Flavor `b3c.16x64` _**for only AI Manager**_

<div style="page-break-after: always;"></div>

### 2.2.2 Tooling 🟢

You need the following tools installed in order to follow through this guide:

- ansible
- oc (4.7 or greater)
- jq
- kafkacat (only for training and debugging)
- elasticdump (only for training and debugging)
- IBM cloudctl (only for LDAP)



#### 2.2.1 On Mac - Automated (preferred) 🟢

Use Option 🐥`81` in [Easy Install](#-2-easy-install) to install the `Prerequisites for Mac`

or run:

```bash
13_install_prerequisites_mac.sh
```

#### 2.2.2 On Ubuntu - Automated (preferred) 🟢

Use Option 🐥`82` in [Easy Install](#-2-easy-install) to install the `Prerequisites for Ubuntu`

or run:

```bash
14_install_prerequisites_ubuntu.sh
```

> If you want the detailed prerequisites you can have a look [here](#18-detailed-prerequisites) 

<div style="page-break-after: always;"></div>

## 2.3 Create Pull Secrets 🟢



### 2.3.1 Get the CP4WAIOPS installation token 🟢

You can get the installation (pull) token from [https://myibm.ibm.com/products-services/containerlibrary](https://myibm.ibm.com/products-services/containerlibrary).

This allows the CP4WAIOPS images to be pulled from the IBM Container Registry.

<div style="page-break-after: always;"></div>



### 2.3.2 Create the Artifactory Pull Secrets 🟢

### ❗This is only needed for pre-GA/FVT testing!

You can get the ICR_TOKEN installation (pull) token from [https://myibm.ibm.com/products-services/containerlibrary](https://myibm.ibm.com/products-services/containerlibrary).

This allows the CP4WAIOPS images to be pulled from the IBM Container Registry.





Quick and dirty way to create the pull secrets without need for a global secret

```bash
oc create ns cp4waiops
oc create ns cp4waiops-evtmgr


export ICR_TOKEN=<IBM PULL TOKEN>

export ARTIFACTORY_USER=<YOUR IBM EMAIL>
export ARTIFACTORY_TOKEN=<TOKEN FOR ARTIFACTORY>

oc get secret/pull-secret -n openshift-config -oyaml > pull-secret-backup.yaml
oc get secret/pull-secret -n openshift-config --template='{{index .data ".dockerconfigjson" | base64decode}}' > temp-pull-secret.yaml
oc registry login --registry="hyc-katamari-cicd-team-docker-local.artifactory.swg-devops.com" --auth-basic="$ARTIFACTORY_USER:$ARTIFACTORY_TOKEN" --to=temp-pull-secret.yaml
oc registry login --registry="cp.icr.io" --auth-basic="cp:$ICR_TOKEN" --to=temp-pull-secret.yaml
oc set data secret/pull-secret -n openshift-config --from-file=.dockerconfigjson=temp-pull-secret.yaml

oc get secret/pull-secret -n openshift-config --template='{{index .data ".dockerconfigjson" | base64decode}}' > temp-ibm-entitlement-key.yaml



oc create secret generic ibm-entitlement-key -n cp4waiops --type=kubernetes.io/dockerconfigjson --from-file=.dockerconfigjson=temp-ibm-entitlement-key.yaml
oc create secret generic ibm-entitlement-key -n cp4waiops-evtmgr --type=kubernetes.io/dockerconfigjson --from-file=.dockerconfigjson=temp-ibm-entitlement-key.yaml
oc create secret generic ibm-entitlement-key -n openshift-marketplace --type=kubernetes.io/dockerconfigjson --from-file=.dockerconfigjson=temp-ibm-entitlement-key.yaml
oc create secret generic ibm-entitlement-key -n openshift-operators --type=kubernetes.io/dockerconfigjson --from-file=.dockerconfigjson=temp-ibm-entitlement-key.yaml

oc create secret generic ibm-entitlement-key -n cp4waiops --type=kubernetes.io/dockerconfigjson --from-file=.dockerconfigjson=temp-ibm-entitlement-key.yaml


```

Once you have started the installation you have to patch the ibm-operator-catalog serviceaccount


```bash
kubectl patch -n openshift-marketplace serviceaccount ibm-operator-catalog -p '{"imagePullSecrets": [{"name": "ibm-entitlement-key"}]}'
oc delete pod $(oc get po -n openshift-marketplace|grep ImagePull|awk '{print$1}') -n openshift-marketplace
```

<div style="page-break-after: always;"></div>

## 2.4 Install AI Manager 🟢

![K8s CNI](./doc/pics/install-aimanager.png)

<div style="page-break-after: always;"></div>

### 2.4.1 Launch the Easy Install Tool 🟢

Just run:

```bash
./01_easy-install.sh -t <REGISTRY_TOKEN> 
```


For a vanilla install you will see this:

![K8s CNI](./doc/pics/tool0.png)



<div style="page-break-after: always;"></div>

### 2.4.1 Start AI Manager Installation 🟢

1. Select option 🐥`11` to install a base `AI Manager` instance.
2. Click through the assistant, enter the installation token (if not provided on the command line):

![K8s CNI](./doc/pics/tool1.png)


or run:

```bash
ansible-playbook ./ansible/10_install-cp4waiops_ai_manager_only_with_demo_runbooks.yaml -e CP_ENTITLEMENT_KEY=<REGISTRY_TOKEN> 
```


For complete example log, you can have a look [here](#99-example-installation-log)

### 2.4.2 First Login 🟢

After successful installation, the Easy Installer gives you the URL and the Login Information for your first connections.


You can also run `./tools/20_get_logins.sh` at any moment. This will print out all the relevant passwords and credentials.

Usually it's a good idea to store this in a file for later use:

```bash
./tools/20_get_logins.sh > my_credentials.txt
```

<div style="page-break-after: always;"></div>

## 2.5 Configure AI Manager 🟢

There are some minimal configurations that you have to do to use the demo system and that are covered by the 🅰️ flow:

### Minimal Configuration
 
Those are the minimal configurations you'll need to demo the system and that are covered by the flow above.
 
 
**Basic Configuration**
 
1. [Configure LDAP Logins](#41-add-ldap-logins-to-cp4waiops-🅰%EF%B8%8F)

**Configure Topology**
 

1. [Create REST Observer](#421-create-rest-observer-to-load-topologies-🅰%EF%B8%8F)
1. [Create Topology](#422--load-topology-🅰%EF%B8%8F) (🐥 - Option 51)

 
**Models Training**
 
1. [Train the Models](#431--perform-training-🅰%EF%B8%8F) (🐥 - Option 55)
1. [Create Integrations](#432-create-integrations-🅰%EF%B8%8F)

**Advanced Configuration**

1. [Enable Story creation Policy](#44-enable-story-creation-policy-🅰%EF%B8%8F)
1. [Create AWX Connection](#45-create-awx-connection-🅰%EF%B8%8F)
1. [Create AI Manager Runbook](#46-create-ai-manager-runbook-🅰%EF%B8%8F)
1. [Create Runbook Policy](#47-create-runbook-policy-🅰%EF%B8%8F)

**Configure Slack**
 
1. [Setup Slack](#61-initial-slack-setup-🅰%EF%B8%8F)

 

Just click and follow the 🚀 and execute the steps marked with  🟢🅰️:
 
###  🟢🅰️ 🚀 Start here [Add LDAP Logins to CP4WAIOPS](#41-add-ldap-logins-to-cp4waiops-🅰%EF%B8%8F)




<div style="page-break-after: always;"></div>


### 2.5.1 Installing with parameters

You can also provide the following (optional) parameters:

- `t`  Provide registry pull token              <REGISTRY_TOKEN>
- `v`  Verbose mode                             true/false
- `r`  Replace indexes if they already exist    true/false

```bash
./01_easy-install.sh [-t <REGISTRY_TOKEN>] [-v true] [-r true]"
```

In this case you will see the selected options:

![K8s CNI](./doc/pics/tool3.png)

<div style="page-break-after: always;"></div>






---------------------------------------------------------------
# 4 Basic Configuration
---------------------------------------------------------------

## 4.1 Add LDAP Logins to CP4WAIOPS 🟢🅰️


* Go to `AI Manager` Dashboard
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


---


<div style="page-break-after: always;"></div>

## 4.2 Create Topology



### 4.2.1 Create REST Observer to Load Topologies 🟢🅰️

* In the `AI Manager` "Hamburger" Menu select `Operate`/`Data and tool integrations`
* Click `Add connection`
* On the left click on `Topology`
* On the top right click on `You can also configure, schedule, and manage other observer jobs` 
* Click on  `Add a new Job`
* Select `REST`/ `Configure`
* Choose `bulk_replace`
* Set Unique ID to `restTopology` (important!)
* Set Provider to whatever you like (usually I set it to “restTopology” as well)
* `Save`



<div style="page-break-after: always;"></div>

### 4.2.2 🐥 Load Topology 🟢🅰️

##### Use 🐥 [Easy Install](#-2-easy-install) - Option `51` for creating the Robot-Shop topology or use the manual procedure in chapter 4.5. 

or run:

```bash
ansible-playbook ./ansible/80_load-topology-all.yaml 
```

❗ Please manually re-run the Kubernetes Observer to make sure that the merge has been done.


### 🟢🅰️ 🚀 Continue here: [Train the Models](#43-training)




### 4.2.3 Optional Steps 

#### Those steps have already been executed by the 🐥 Easy Installer

#### 4.2.3.1 Create Kubernetes Observer for the Demo Applications (optional)



Do this for your applications (RobotShop by default)

* In the `AI Manager` "Hamburger" Menu select `Operate`/`Data and tool integrations`
* Click `Add connection`
* Under `Kubernetes`, click on `Add Integration`
* Click `Connect`
* Name it `RobotShop`
* Data Center `demo`
* Click `Next`
* Choose `local` for Connection Type
* Set `Hide pods that have been terminated` to `On`
* Set `Correlate analytics events on the namespace groups created by this job` to `On`
* Set Namespace to `robot-shop`
* Click `Next`
* Click `Done`



	
#### 4.2.3.2 Create AIOps Application (optional)


* In the `AI Manager` go into `Operate` / `Application Management` 
* Click `Define Application`
* Select `robot-shop` namespace
* Click `Next`
* Click `Next`
* Name your Application (RobotShop)
* If you like check `Mark as favorite`
* Click `Define Application`






<div style="page-break-after: always;"></div>




## 4.3 Training

### 4.3.1 🐥 Perform Training 🟢🅰️

> ❗This can take some time (up to 45 minutes). Go grab yourself a nice coffe ☕

#### Use 🐥 [Easy Install](#-2-easy-install) - Option `55` to automatically:
- Load the training data
- Create the training definitions
- Launch the trainings

This will be done for:

- Log Anomaly Detection (Logs)
- Temporal Grouping (Events)
- Similar Incidents (Service Now)
- Change Risk (Service Now)

or run:

```bash
ansible-playbook ./ansible/85_training-all.yaml
```


or use the procedure in [Chapter 22](#22-manually-train-the-models) to do this manually. 

❗ Wait for the training to complete before continuing

<div style="page-break-after: always;"></div>

### 4.3.2 Create Integrations 🟢🅰️

❗ Do this only after the training has completed!

#### 4.3.2.1 Create Kafka ELK Log Inception Integration 🟢🅰️

* In the `AI Manager` "Hamburger" Menu select `Define`/`Data and tool integrations`
* Click `Add connection`
* Under `Kafka`, click on `Add Integration`
* Click `Connect`
* Name it `ELKInject`
* Click `Next`
* Select `Data Source` / `Logs`
* Select `Mapping Type` / `ELK`
* Paste the following in `Mapping` (the default is **incorrect**!:

	```json
	{ 
	  "codec": "elk",
	  "message_field": "message",
	  "log_entity_types": "kubernetes.container_image_id, kubernetes.host, kubernetes.pod_name, kubernetes.namespace_name",
	  "instance_id_field": "kubernetes.container_name",
	  "rolling_time": 10,
	  "timestamp_field": "@timestamp"
	}
	```
* Click `Next`
* Toggle `Data Flow` to the `ON` position
* Select `Live data for continuous AI training and anomaly detection`
* Click `Save`


<div style="page-break-after: always;"></div>

#### 4.3.2.2 Create Kafka Netcool Inception Integration 🟢🅰️

* In the `AI Manager` "Hamburger" Menu select `Operate`/`Data and tool integrations`
* Click `Add connection`
* Under `Kafka`, click on `Add Integration`
* Click `Connect`
* Name it `EvetnManager`
* Click `Next`
* Select `Data Source` / `Events`
* Select `Mapping Type` / `NOI`
* Click `Next`
* Toggle `Data Flow` to the `ON` position
* Click `Save`

<div style="page-break-after: always;"></div>

## 4.4 Enable Story creation Policy 🟢🅰️


* In the `AI Manager` "Hamburger" Menu select `Operate`/`Automations`
* Under `Policies`
* Select `Stories` from the `Tag` dropdown menu
* Enable `Default story creation policy for high severity alerts`
* Also enable `Default story creation policy for all alerts` if you want to get all alerts grouped into a story

![K8s CNI](./doc/pics/policies1.png)

## 4.5 Create AWX Connection 🟢🅰️

🐥 Easy Install should aready have installed AWX (Open Source Ansible Tower) and preloaded the Job Templates.


* In the `AI Manager` "Hamburger" Menu select `Define`/`Data and tool integrations`
* Click `Add connection`
* Under `Ansible Tower`, click on `Add Integration`
* Click `Connect`
* Open the `LOGINS.txt` file that has been created by 🐥 Easy Install in your root directory
* Fill in `URL` with the URL from `LOGINS.txt`
* Fill in `User ID` with `admin`
* Fill in `Password` with the password from `LOGINS.txt`
* Click `Save`

<div style="page-break-after: always;"></div>

## 4.6 Create AI Manager Runbook 🟢🅰️

* Run the following to create the Runbooks `Live data for continuous AI training and anomaly detection`
	```bash
	ansible-playbook ./ansible/48_aiops-load-aimanager-runbooks.yaml
	```



## 4.7 Create Runbook Policy 🟢🅰️


* In the `AI Manager` "Hamburger" Menu select `Operate`/`Automations`
* Under `Policies`, click `Create Policy`
* Select `Assign a runbook to alerts`
* Name it `Mitigate RobotShop`
* Under `Condition set1`
* Select `resource.name` (you can type `name` and select the name field for resources)
* Set Operator to `contains`
* And for `value` you type `mysql` (select `String: mysql`)
* Under Runbooks
* Select the `Mitigate RobotShop Problem` Runbook
* Under Parameters, select Enter static value
* And input the login credentials in JSON Format (get the URL and token from the 20\_get\_logins.sh script)

	
	```json
	{     
		"my_k8s_apiurl": "https://c117-e.xyz.containers.cloud.ibm.com:12345",
		"my_k8s_apikey": "PASTE YOUR API KEY"
	}
	```
* Click `Create Policy`


![K8s CNI](./doc/pics/policies2.png)


### 🟢🅰️ 🚀 Continue here: [Setup Slack](#61-initial-slack-setup-🅰%EF%B8%8F)


<div style="page-break-after: always;"></div>


---------------------------------------------------------------
# 6 Slack integration
---------------------------------------------------------------

## 6.1 Initial Slack Setup 🟢🅰️

For the system to work you need to setup your own secure gateway and slack workspace. It is suggested that you do this within the public slack so that you can invite the customer to the experience as well. It also makes it easier for is to release this image to Business partners

You will need to create your own workspace to connect to your instance of CP4WAOps.

Here are the steps to follow:

1. [Create Slack Workspace](./doc/slack/1_slack_workspace.md)
1. [Create Slack App](./doc/slack/2_slack_app_create.md)
1. [Create Slack Channels](./doc/slack/3_slack_channel.md)
1. [Create Slack Integration](./doc/slack/4_slack_integrate.md)
1. [Get the Integration URL - Public Cloud - ROKS](./doc/slack/5_slack_url_public.md) OR 
1. [Get the Integration URL - Private Cloud - Fyre/TEC](./doc/slack/5_slack_url_private.md)
1. [Create Slack App Communications](./doc/slack/6_slack_app_integration.md)
1. [Slack Reset](./doc/slack/7_slack_reset.md)

### 🟢🅰️ 🚀 Continue here: [Demo the solution](#81-simulate-incident---command-line)

If you run into problems validating the `Event Subscription` in the Slack Application, see 6.2

<div style="page-break-after: always;"></div>

## 6.2 Create valid CP4WAIOPS Certificate (optional)

🐥 Easy Install should aready have done this.

But if there still are problems, you can either:

```bash
./tools/10_debug_install.sh
```
and select Option `11  - Troubleshoot/Recreate Certificates for Slack`


or directly run: 

```bash
ansible-playbook ./ansible/31_aiops-patch-ingress.yaml
```


###  6.2.1 Manual Certificate creation

In order for Slack integration to work, there must be a signed certicate on the NGNIX pods. The default certificate is self-signed and Slack will not accept that. The method for updating the certificate has changed between AIOps v2.1 and V3.1.1. The NGNIX pods in V3.1.1 mount the certificate through a secret called `external-tls-secret` and that takes precedent over the certificates staged under `/user-home/_global_/customer-certs/`.

For customer deployments, it is required for the customer to provide their own signed certificates. An easy workaround for this is to use the Openshift certificate when deploying on ROKS. **Caveat**: The CA signed certificate used by Openshift is automatically cycled by ROKS (I think every 90 days), so you will need to repeat the below once the existing certificate is expired and possibly reconfigure Slack.



This method replaces the existing secret/certificate with the one that OpenShift ingress uses, not altering the NGINX deployment. An important note, these instructions are for configuring the certificate post-install. Best practice is to follow the installation instructions for configuring certificates during that time.

<div style="page-break-after: always;"></div>

#### 6.2.1.1 Patch AutomationUIConfig

The custom resource `AutomationUIConfig/iaf-system` controls the certificates and the NGINX pods that use those certificates. Any direct update to the certificates or pods will eventually get overwritten, unless you first reconfigure `iaf-system`. It's a bit tricky post-install as you will have to recreate the `iaf-system` resource quickly after deleting it, or else the installation operator will recreate it. For this reason it's important to run all the commands one after the other. **Ensure that you are in the project for AIOps**, then paste all the code on your command line to replace the `iaf-system` resource.

```bash
oc project $WAIOPS_NAMESPACE
AUTO_UI_INSTANCE=$(oc get AutomationUIConfig -n $WAIOPS_NAMESPACE --no-headers -o custom-columns=":metadata.name")
IAF_STORAGE=$(oc get AutomationUIConfig -n $WAIOPS_NAMESPACE -o jsonpath='{ .items[*].spec.zenService.storageClass }')
ZEN_STORAGE=$(oc get AutomationUIConfig -n $WAIOPS_NAMESPACE -o jsonpath='{ .items[*].spec.zenService.zenCoreMetaDbStorageClass }')
oc get -n $WAIOPS_NAMESPACE AutomationUIConfig $AUTO_UI_INSTANCE --ignore-not-found -o yaml > /tmp/AutomationUIConfig-backup-$(date +%Y%m%d-%H%M).yaml
oc delete -n $WAIOPS_NAMESPACE AutomationUIConfig $AUTO_UI_INSTANCE

cat <<EOF | oc apply -f -
apiVersion: core.automation.ibm.com/v1beta1
kind: AutomationUIConfig
metadata:
  name: $AUTO_UI_INSTANCE
  namespace: $WAIOPS_NAMESPACE
spec:
  description: AutomationUIConfig for cp4waiops
  license:
    accept: true
  version: v1.3
  zen: true
  zenService:
    iamIntegration: true
    storageClass: $IAF_STORAGE
    zenCoreMetaDbStorageClass: $ZEN_STORAGE
  tls:
    caSecret:
      key: ca.crt
      secretName: external-tls-secret
    certificateSecret:
      secretName: external-tls-secret
EOF
```

<div style="page-break-after: always;"></div>

#### 6.2.1.2 NGNIX Certificate

Again, **ensure that you are in the project for AIOps** and run the following to replace the existing secret with a secret containing the OpenShift ingress certificate.

```bash
ingress_pod=$(oc get secrets -n openshift-ingress | grep tls | grep -v router-metrics-certs-default | awk '{print $1}')
oc get secret -n openshift-ingress -o jsonpath='{.data.tls\.crt}' ${ingress_pod} | base64 -d > /tmp/cert.crt
oc get secret -n openshift-ingress -o jsonpath='{.data.tls\.key}' ${ingress_pod} | base64 -d > /tmp/cert.key
oc get secret -n $WAIOPS_NAMESPACE iaf-system-automationui-aui-zen-ca -o jsonpath='{.data.ca\.crt}' | base64 -d > /tmp/ca.crt

oc get secret -n $WAIOPS_NAMESPACE external-tls-secret --ignore-not-found -o yaml > /tmp/external-tls-secret-backup-$(date +%Y%m%d-%H%M).yaml
oc delete secret -n $WAIOPS_NAMESPACE --ignore-not-found external-tls-secret
oc create secret generic -n $WAIOPS_NAMESPACE external-tls-secret --from-file=ca.crt=/tmp/ca.crt --from-file=cert.crt=/tmp/cert.crt --from-file=cert.key=/tmp/cert.key --dry-run=client -o yaml | oc apply -f -
REPLICAS=2
oc scale Deployment/ibm-nginx --replicas=0
sleep 3
oc scale Deployment/ibm-nginx --replicas=${REPLICAS}
rm /tmp/cert.crt
rm /tmp/cert.key
rm /tmp/ca.crt
rm /tmp/external-tls-secret.yaml
```


Wait for the nginx pods to come back up

```bash
oc get pods -l component=ibm-nginx
```

When the integration is running, remove the backup file

```bash
rm ./iaf-system-backup.yaml
```

And then restart the Slack integration Pod

```bash
oc delete pod $(oc get po -n $WAIOPS_NAMESPACE|grep slack|awk '{print$1}') -n $WAIOPS_NAMESPACE --grace-period 0 --force
```

The last few lines scales down the NGINX pods and scales them back up. It takes about 3 minutes for the pods to fully come back up.

Once those pods have come back up, you can verify the certificate is secure by logging in to AIOps. Note that the login page is not part of AIOps, but rather part of Foundational Services. So you will have to login first and then check that the certificate is valid once logged in. If you want to update the certicate for Foundational Services you can find instructions [here](https://www.ibm.com/docs/en/cpfs?topic=operator-replacing-foundational-services-endpoint-certificates).




## 6.3 Change the Slack Slash Welcome Message (optional)

If you want to change the welcome message

```bash
oc set env deployment/$(oc get deploy -l app.kubernetes.io/component=chatops-slack-integrator -o jsonpath='{.items[*].metadata.name }') SLACK_WELCOME_COMMAND_NAME=/aiops-help
```


<div style="page-break-after: always;"></div>



---------------------------------------------------------------
# 8 Demo the Solution
---------------------------------------------------------------



## 8.1 Simulate incident - Command Line

**Make sure you are logged-in to the Kubernetes Cluster first** 

In the terminal type 

```bash
./tools/01_demo/incident_robotshop.sh
```

This will delete all existing Alerts/Stories and inject pre-canned event and logs to create a story.

ℹ️  Give it a minute or two for all events and anomalies to arrive in Slack.



### 🟢🅰️ 🚀 Continue here: [Back to Easy Install](#241-launch-the-easy-install-tool-)

<div style="page-break-after: always;"></div>

## 8.2 Simulate incident - Demo UI

> ❗**In order to use the DEMO UI, you have to have followed through all the steps in [AI Manager Configuration](#25-configure-ai-manager). Notably Configuring Topology, Integrations and having run the Models Training.**

### 8.2.1 Install Demo UI

#### Use 🐥 [Easy Install](#-2-easy-install) - Option `17` to automatically install a Demo UI instance.

or directly run: 

```bash
ansible-playbook ./ansible/18_aiops-demo-ui.yaml
```

## 8.2.2 Simulate incident - Demo UI

1. Run `./tools/20_get_logins.sh` to get the URL and Login Token.
1. Open the URL and enter the Token.
	![](./doc/pics/demoui1.png)
1. Click on Configuration
1. Verify that you have `Kafka Topics` shown for Events and Logs
	![](./doc/pics/demoui2.png)
1. Click `Back`
1. Now you can use the buttons to simulate:

	* Only Events
	* Only Log Anomalies
	* or Both
	![](./doc/pics/demoui1.png)

1. The UI will confirm that the incident creation has been launched
	![](./doc/pics/demoui3.png)
	
	
<div style="page-break-after: always;"></div>












### 19.1.4 Configure LDAP Users

1. Log in to AI Manager as admin
2. Select `Administration/Access` control from the "Hamburger manu"
3. Click on the `Identity provider configuration` (upper right) you should get the LDAP being registered
4. Go back
5. Select `User Groups Tab`
6. Click `New User Group`
7. Call it `demo`
8. Click `Next`
9. Click on `Identity provider groups`
10. Search for `demo`
11. Select `cn=demo,ou=Groups,dc=ibm,dc=com`
12. Click `Next`
13. Select `Administrator` rights
14. Click `Next`
15. Click `Create`

Now you will be able to login with all LDAP users that are part of the demo group (for example demo/P4ssw0rd!).

You can check/modify those in the OpenLDAPAdmin interface that you can access with the credentials described in 3.3.





<div style="page-break-after: always;"></div>




<div style="page-break-after: always;"></div>


## 19.4 Get Passwords and Credentials

At any moment you can run `./tools/20_get_logins.sh` that will print out all the relevant passwords and credentials.

Usually it's a good idea to store this in a file for later use:

```bash
./tools/20_get_logins.sh > my_credentials.txt
```

## 19.5 Check status of installation

At any moment you can run `./tools/11_check_install.sh` or for a more in-depth examination and troubleshooting `./tools/10_debug_install.sh` and select `Option 1` to check your installation.


<div style="page-break-after: always;"></div>







