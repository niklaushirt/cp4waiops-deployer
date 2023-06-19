
---------------------------------------------------------------
# 🚀 3 Detailed Ansible Install
---------------------------------------------------------------

## ❗ This method will be deprecated and should not be used anymore. 
### ❗I WILL NOT TEST THIS FOR NEW RELEASES GOING FORWARD
Please use the in-cluster installation method in chapter 1:
- It's way faster
- You don't have to install all the tooling locally
- You don’t need a connection to the cluster during the installation (fire and forget)


## 3.1 Get the code 


Clone the GitHub Repository

```
git clone https://github.com/niklaushirt/cp4waiops-deployer.git -b cp4waiops_stable
```


## 3.2 Prerequisites 


### 3.2.1 OpenShift requirements 

I installed the demo in a ROKS environment.

You'll need:

- ROKS 4.12
- 5x worker nodes Flavour `b3c.16x64` (so 16 CPU / 64 GB) 




You **might** get away with less if you don't install some components (Event Manager, ELK, Turbonomic,...) but no guarantee:

- Typically 4x worker nodes Flavour `b3c.16x64` _**for only CP4WAIOps**_

<div style="page-break-after: always;"></div>

### 3.2.2 Get a ROKS Cluster (IBMers and IBM Partners only)

IBMers can get a temporary one from [Techzone](https://techzone.ibm.com/collection/custom-roks-vmware-requests) (ususally valid for 2 weeks)

1. Create a cluster for `Practice/Self Education` if you don't have an Opportunity Number

	![K8s CNI](./doc/pics/roks01.png)

1. Select the maximum end date that fits your needs (you can extend the duration once after creation)

	![K8s CNI](./doc/pics/roks03.png)
	
1. Fill-in the remaining fields

	1. Geograpy: whatever is closest to you
	2. Worker node count: 5
	3. Flavour: b3c.16x64
	4. OpenShift Version: 4.12

	![K8s CNI](./doc/pics/roks02.png)

1. Click `Submit`

<div style="page-break-after: always;"></div>

### 3.2.3 Tooling 

❗ Only needed if you decide to install from your PC

You need the following tools installed in order to follow through this guide:

- ansible
- oc (4.8 or greater)
- jq
- kafkacat (only for training and debugging)
- elasticdump (only for training and debugging)
- IBM cloudctl (only for LDAP)



#### 3.2.3.1 On Mac - Automated (preferred) 

*Only needed if you decide to install from your PC*

Just run:

```bash
./tools/10_prerequisites/install_prerequisites_mac.sh
```

#### 3.2.3.2 On Ubuntu - Automated (preferred) 

*Only needed if you decide to install from your PC*

Just run:

```bash
./tools/10_prerequisites/install_prerequisites_ubuntu.sh
```

 

<div style="page-break-after: always;"></div>

### 3.2.4 Get the CP4WAIOPS installation token (registry pull token) 

You can get the installation (registry pull token) token from [https://myibm.ibm.com/products-services/containerlibrary](https://myibm.ibm.com/products-services/containerlibrary).

This allows the CP4WAIOPS images to be pulled from the IBM Container Registry.

<div style="page-break-after: always;"></div>

## 3.3 CP4WAIOps Installation


You have different options:
	
1. **Install from your PC** *with the token from 1.3.1*
	```bash
	ansible-playbook ./ansible/01_cp4waiops-aimanager-all.yaml -e cp_entitlement_key=<REGISTRY_TOKEN> 
	```
	
1. **Install with the Easy Installer** *with the token from 1.3.1*
	1. Just run:
		```bash
		./01_easy-install.sh -t <REGISTRY_TOKEN>
		```

	2. Select option 🐥`10` to install the complete `CP4WAIOps` environment with Demo Content.




> This takes about 1.5 to 2 hours.
> After completion Easy Installer will open the documentation and the CP4WAIOps webpage (on Mac) and you'll have to to perform the last manual steps.

> You now have a full, basic installtion of CP4WAIOps with:
> 
>  - CP4WAIOps
>  - Open LDAP & Register with CP4WAIOps
>  - RobotShop demo application
>  - Trained Models based on pre-canned data (Log- and Metric Anomalies, Similar Incidents, Change Risk)
>  - Topologies for demo scenarios
>  - AWX (OpenSource Ansible Tower) with runbooks for the demo scenarios
>  - Demo UI
>  - Demo Service Account 
>  - Valid certificate for Ingress (Slack) 
>  - External Routes (Flink, Topology, ...)
>  - Policies for Stories and Runbooks 
> 


 <div style="page-break-after: always;"></div>
 

### 3.3.1 CP4WAIOps Configuration 


Those are the manual configurations you'll need to demo the system and that are covered by the flow above.
 

**Configure Slack**
 
Continue [here](#4-slack-integration) for [Slack integration](#4-slack-integration)



### 3.3.2 First Login

After successful installation, the Playbook creates a file `./LOGINS.txt` in your installation directory (only if you installed from your PC).

> ℹ️ You can also run `./tools/20_get_logins.sh` at any moment. This will print out all the relevant passwords and credentials.

#### 3.3.2.1 Get the URL

* Run `./tools/20_get_logins.sh` to get all the logins and URLs

or

* Run:

```bash
export WAIOPS_NAMESPACE=$(oc get po -A|grep aiops-orchestrator-controller |awk '{print$1}')
	
echo "🌏 CP4WAIOps:           https://$(oc get route -n $WAIOPS_NAMESPACE cpd -o jsonpath={.spec.host})"
echo "🌏 Demo UI:              https://$(oc get route -n $WAIOPS_NAMESPACE waiops-demo-ui-python -o jsonpath={.spec.host})"

```

<div style="page-break-after: always;"></div>

### 3.3.3 Login as demo User (preferred)

* Open the URL from the above
* Click on `Enterprise LDAP`
* Login as `demo` with the password `Defined at installation`


#### 3.3.3.1 Login as admin

* Open the URL from the above
* Click on `IBM provided credentials (admin only)`

	![K8s CNI](./doc/pics/doc53.png)



* Login as `admin` with the password from the `LOGINS.txt` file

	![K8s CNI](./doc/pics/doc55.png)



<div style="page-break-after: always;"></div>

## 3.4 Demo the Solution


### 3.4.1 Simulate incident - Web Demo UI


#### 3.4.1.1 Get the URL

* Run:

	```bash
	export WAIOPS_NAMESPACE=$(oc get po -A|grep aiops-orchestrator-controller |awk '{print$1}')
		
	echo "🌏 CP4WAIOps:           https://$(oc get route -n $WAIOPS_NAMESPACE cpd -o jsonpath={.spec.host})"
	echo "🌏 Demo UI:              https://$(oc get route -n $WAIOPS_NAMESPACE waiops-demo-ui-python -o jsonpath={.spec.host})"
	
	```
	
	![demo](./doc/pics/demo03.png)
	

#### 3.4.1.2 Open the Web Demo UI

* Open the Demo UI URL from the above
* Login with the password `Defined at installation`

<div style="page-break-after: always;"></div>

#### 3.4.1.3 Simulate the incident

Click on the red `Create Incident Memory Leak` button

This will create alerts and a story in CP4WAIOps.

![demo](./doc/pics/demo01.png)

<div style="page-break-after: always;"></div>

#### 3.4.1.2 Login to CP4WAIOps as demo User

* Open the CP4WAIOps URL from the above
* Click on `Enterprise LDAP`
* Login as `demo` with the password `Defined at installation`

ℹ️  Give it a minute or two for all events and anomalies to arrive in CP4WAIOps and Slack.


![demo](./doc/pics/demo02.png)


### 3.4.2 Simulate incident - Command Line

**Make sure you are logged-in to the Kubernetes Cluster first** 

In the terminal type 

```bash
./22_simulate_incident_memory.sh
```

This will delete all existing Alerts/Stories and inject pre-canned event, metrics and logs to create a story.

ℹ️  Give it a minute or two for all events and anomalies to arrive in CP4WAIOps and Slack.
ℹ️  You might have to run the script 3-4 times for the log anomalies to start appearing.




<div style="page-break-after: always;"></div>

## 3.5 Event Manager Installation


You have different options:

1. **Install directly from the OCP Web UI** *(no need to install anything on your PC)*
	1. In the the OCP Web UI click on the + sign in the right upper corner
	1. Copy and paste the content from [this file](./Quick_Install/03_INSTALL_EVTMGR_ALL.yaml)
	2. Replace `<REGISTRY_TOKEN>` at the end of the file with your pull token from step 1.3.1
	3. Click `Save`
	
1. **Install from your PC** *with the token from 1.3.1*
	```bash
	ansible-playbook ./ansible/04_cp4waiops-eventmanager-all.yaml -e cp_entitlement_key=<REGISTRY_TOKEN> 
	```
	
1. **Install with the Easy Installer** *with the token from 1.3.1*
	1. Just run:
		```bash
		./01_easy-install.sh -t <REGISTRY_TOKEN>
		```

	2. Select option 🐥`02` to install the complete `Event Manager` environment with Demo Content.




> This takes about 1 hour.



 <div style="page-break-after: always;"></div>
 



### 3.5.2 First Login

After successful installation, the Playbook creates a file `./LOGINS.txt` in your installation directory (only if you installed from your PC).

> ℹ️ You can also run `./tools/20_get_logins.sh` at any moment. This will print out all the relevant passwords and credentials.

#### 3.5.2.1 Login as smadmin

* Open the `LOGINS.txt` file that has been created by the Installer in your root directory
* Open the URL from the `LOGINS.txt` file
* Login as `smadmin` with the password from the `LOGINS.txt` file

<div style="page-break-after: always;"></div>

### 3.5.3 Integration with CP4WAIOps

* To get the connection parameters, run:

```bash
./tools/97_addons/prepareNetcoolIntegration.sh
```

> Execute the listed commads at the Objectserver prompt. 
> 
> This gives you all the parameters needed for creating the connection.
  
* In the `CP4WAIOps` "Hamburger" Menu select `Operate`/`Data and tool integrations`
* Click `Add connection`
* Under `Netcool`, click on `Add connection`
* Click `Connect`
* Name it `Netcool`
* Fill-in the information from the script above
![](./doc/pics/netcool01.png)
* Click `Test Connection`
* Click `Next`
* Toggle `Enable Data Collection` to the `ON` position
* Click `Save`


<div style="page-break-after: always;"></div>

### 3.5.4 Event Manager Configuration 

#### 3.5.4.1 EventManager Webhook 

Create Webhooks in EventManager for Event injection and incident simulation for the Demo.

The demo scripts (in the `demo` folder) give you the possibility to simulate an outage without relying on the integrations with other systems.

At this time it simulates:

- Git push event
- Log Events (ELK)
- Security Events (Falco)
- Instana Events
- Metric Manager Events (Predictive)
- Turbonomic Events
- CP4MCM Synthetic Selenium Test Events



You have to define the following Webhook in EventManager (NOI): 

* `Administration` / `Integration with other Systems`
* `Incoming` / `New Integration`
* `Webhook`
* Name it `Demo Generic`
* Jot down the WebHook URL and copy it to the `NETCOOL_WEBHOOK_GENERIC` in the `./tools/01_demo/incident_robotshop-noi.sh`file
* Click on `Optional event attributes`
* Scroll down and click on the + sign for `URL`
* Click `Confirm Selections`


Use this json:

```json
{
  "timestamp": "1619706828000",
  "severity": "Critical",
  "summary": "Test Event",
  "nodename": "productpage-v1",
  "alertgroup": "robotshop",
  "url": "https://pirsoscom.github.io/grafana-robotshop.html"
}
```
<div style="page-break-after: always;"></div>

Fill out the following fields and save:

* Severity: `severity`
* Summary: `summary`
* Resource name: `nodename`
* Event type: `alertgroup`
* Url: `url`
* Description: `"URL"`

Optionnally you can also add `Expiry Time` from `Optional event attributes` and set it to a convenient number of seconds (just make sure that you have time to run the demo before they expire.

<div style="page-break-after: always;"></div>


#### 3.5.4.2 Create custom Filters and Views


##### 3.5.4.2.1 Filter 


* In the `Event Manager` "Hamburger" Menu select `Netcool WebGui`
* Click `Administration`
* Click `Filters`
* Select `Global Filters` from the DropDown menu
* Select `Default`
* Click `Copy Filter` (the two papers on the top left) 
* Set to `global`
* Click `Ok`
* Name: AIOPS
* Logic: **Any** ❗ (the right hand option)
* Filter:
	* AlertGroup = 'CEACorrelationKeyParent'
	* AlertGroup = 'robot-shop'

![](./doc/pics/noi10.png)


##### 3.5.4.2.2 View 
* In the `Event Manager` "Hamburger" Menu select `Netcool WebGui`
* Click `Administration`
* Click `Views`
* Select `System Views` from the DropDown menu
* Select `Example_IBM_CloudAnalytics`
* Click `Copy View` (the two papers on the top left) 
* Set to `global`
* Click `Ok`
* Name: AIOPS
* Configure to your likings.


#### 3.5.4.3 Create grouping Policy 

* In the `Event Manager` "Hamburger" Menu select `Netcool WebGui`
* Click `Insights`
* Click `Scope Based Grouping`
* Click `Create Policy`
* `Action` select fielt `Alert Group`
* Toggle `Enabled` to `On`
* Save

<div style="page-break-after: always;"></div>

#### 3.5.4.4 Create Menu item

In the Netcool WebGUI

* Go to `Administration` / `Tool Configuration`
* Click on `LaunchRunbook`
* Copy it (the middle button with the two sheets)
* Name it `Launch URL`
* Replace the Script Command with the following code

	```javascript
	var urlId = '{$selected_rows.URL}';
	
	if (urlId == '') {
	    alert('This event is not linked to an URL');
	} else {
	    var wnd = window.open(urlId, '_blank');
	}
	```
* Save

Then 

* Go to `Administration` / `Menu Configuration`
* Select `alerts`
* Click on `Modify`
* Move Launch URL to the right column
* Save

