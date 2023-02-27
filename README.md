<center> <h1>CP4WatsonAIOps CP4WAIOPS v3.6.0</h1> </center>
<center> <h2>Demo Environment Installation 🚀</h2> </center>

![K8s CNI](./doc/pics/front.png)


<center> ©2023 Niklaus Hirt / IBM </center>


<div style="page-break-after: always;"></div>


### ❗ This is provided `as-is`:

* I'm sure there are errors
* I'm sure it's not complete
* It clearly can be improved


Please contact me if you have feedback or if you find glitches or problems.

- on Slack: @niklaushirt or
- by Mail: nikh@ch.ibm.com


**❗The installation has been tested for the CP4WAIOPS v3.6.0 release on OpenShift 4.10 on:**

- IBM RedHat Openshift Kubernetes Service (ROKS) with IBM Cloud Storage (ibmc-xxx)
- IBM RedHat Openshift Kubernetes Service (ROKS) with NFS Storage
- IBM RedHat Openshift Kubernetes Service (VPC Gen2 with ODF)
- OpenShift Cluster (VMware on IBM Cloud) - IPI


> ❗Those are **non-production** installations and are suited only for demo and PoC environments. ❗
> Please refer to the official IBM Documentation for production ready installations.

<div style="page-break-after: always;"></div>


## 🚀 Get started


🐥 [Quick Install](https://github.com/niklaushirt/cp4waiops-deployer#-2-quick-install)

🚀 [Demo the Solution](#3-demo-the-solution)

📱 [Slack integration](#4-slack-integration) (optional)

🤓 [Demo Setup - Explained](#5-demo-setup---explained)


> ℹ️ You can find a more detailed presentation about how the automation works here: [PDF](https://ibm.box.com/s/gx0tcubl9k4phvdsrffd7taragrmvz02).
> 



Here is a quick video that walks you through the installation process
![K8s CNI](./doc/pics/JOB_INSTALL.gif)


### ⚠️ **This method creates an in-cluster installation**

- It's way faster
- You don't have to install all the tooling locally
- You don’t need a connection to the cluster during the installation (fire and forget)

### What you have to do:

* Get an OpenShift Cluster
* Get your entitlement key/pull token
* Paste the install file into the OpenShift web UI and insert your entitlement key
* Grab a coffe and come back after 2-3 hours depending on the modules you're installing

> 🤓 So this could basically be done from an iPhone or iPad	

🚀 Already have a cluster? [Dive right in](#-21-install-ai-manager-with-demo-content-turbonomic-and-instana)



<div style="page-break-after: always;"></div>


---------------------------------------------------------------
# 🚀 1 Preparation
---------------------------------------------------------------


 

<div style="page-break-after: always;"></div>

<details>
<summary>Prerequisites</summary>

## ✅ 1.1 Prerequisites 

### 1.1.1 OpenShift requirements 

I installed the demo in a Techzone environment.

You'll need:

- ROKS 4.10
- 5x worker nodes with **32 CPU / 128 GB**  ❗


You **might** get away with less if you don't install some components (Event Manager, ELK, Turbonomic,...) but no guarantee.



### 1.1.2 Get an OpenShift Cluster (IBMers and IBM Partners only)


IBMers and Partners can get a temporary cluster from [**Techzone**](https://techzone.ibm.com/collection/tech-zone-certified-base-images).


1. Select `OpenShift Cluster (VMware on IBM Cloud) - IPI - Public` Openshift that you want to use above

1. Create a cluster for `Practice/Self Education` or `Test` if you don't have an Opportunity Number

1. Select your preferred Geograpy

  ![K8s CNI](./doc/pics/roks01.png)

1. Select the maximum end date that fits your needs (you can extend the duration once after creation)

	![K8s CNI](./doc/pics/roks03.png)

1. Select Openshift Storage

   - Storage OCS/ODF Size: **2TiB** - This is important as with the 500MiB option your installation will run out of space rapidly.

   - OpenShift Version: **4.10**

	![K8s CNI](./doc/pics/roks02.png)

1. Select the Cluster Size

	- Worker node count: **5**
	- Flavour: **32 vCPU X 128 GB** ❗ 

	> ❗ If you want to install AIManager, Event Manager, Trubonomic and Instana please select **32 vCPU X 128 GB** 

	![K8s CNI](./doc/pics/roks04.png)

1. Click `Submit`
1. Once the cluster is provisioned, don't forget to extend it to 8 days if needed.


### 1.1.3 Get the CP4WAIOPS installation token (registry pull token) 

You can get the installation (registry pull token) token from [https://myibm.ibm.com/products-services/containerlibrary](https://myibm.ibm.com/products-services/containerlibrary).

This allows the CP4WAIOPS images to be pulled from the IBM Container Registry.

<div style="page-break-after: always;"></div>

</details>
<details>
<summary>Important remarks before you start</summary>

## ⚠️⚠️ 1.2 Important remarks before you start ⚠️⚠️

Those are remarks to feedback and problem reports I got from the field.

Those scripts have been tested thoroughly on different environments and have proven to be VERY reliable.

If you think that you hit a problem:

* Make sure that you have provisioned a cluster with **5 worker nodes with 32 CPU and 128 GB** each (`b3c.16x64` - it's easy to select the wrong size). If you have Pods in `0/0` state verify the `Events`. If you get `Not enough CPU` then delete the cluster and provision the correct size.
* If you want to install AIManager, Event Manager, Trubonomic and Instana please select **5 worker nodes with 32 CPU and 128 GB**
* The complete installation takes about 2.5 to 8 hours depending on your region where and how you deployed ROKS to (see above).
* If you see Pods in `CrashLoop` or other error states, try to wait it out (this can be due to dependencies on other componenets that are not ready yet). Chances are that the deployment will eventually go through. If after 8h you are still stuck, ping me.
* **Select and use ONLY ONE of the scripts** below, depending on which components you want to install.




### ❗ So simply put be patient and make sure you have the correct size of cluster provisioned!

<div style="page-break-after: always;"></div>

</details>


---------------------------------------------------------------
# 🐥 2 Quick Install
---------------------------------------------------------------



You can use the scritps in the `Quick_Install` folder to rapidly spin up a demo environment.
The names should be self explaining and the headers of the files explain the modules to be installed.

> Basically you would to the following:
> 
> 1. In the the OCP Web UI click on the `+` sign in the right upper corner
> 1. Select the `Quick Install File` that fits your need from  [this directory](./Quick_Install/)
> 3. Replace `<REGISTRY_TOKEN>` at the end of the file with your pull token from step 1.1.3 (the Entitlement key from https://myibm.ibm.com)
> 3. Click `Save`	


> ℹ️❗ If you get a ClusterRoleBinding already exists, just ignore it

You can find some examples below.


<details>
<summary>Install AI Manager with demo content, Turbonomic and Instana</summary>

## 🐥 2.1 Install AI Manager with demo content, Turbonomic and Instana 

> ### ✅ This is probably the one that you want.

You get AIManager installed and pre-trained in one simple script.
Ready to go.
On top of that you get Turbonomic and Instana instances to play around a bit (you'll need a license key for each).



![K8s CNI](./doc/pics/install01.png)

1. In the the OCP Web UI click on the `+` sign in the right upper corner
1. Copy and paste the content from [this file](./Quick_Install/01_INSTALL_AIMGR_TURBO_INSTANA.yaml)
3. Replace `<REGISTRY_TOKEN>` at the end of the file with your pull token from step 1.1.3 (the Entitlement key from https://myibm.ibm.com)
4. Replace `<YOUR_SALES_KEY>` and  `<YOUR_AGENT_KEY>` at the end of the file with your Instana license
5. Replace the TURBO_LICENSE `NONE` at the end of the file with your Turbonomic license
3. Click `Save`

### **🚀 You can now go to [Demo the Solution](#3-demo-the-solution)**

This installation cocntains:

> - **AI Manager**
> 	- IBM Operator
> 	- AI Manager Instance
> - **AI Manager Demo Content**
>    - **OpenLDAP** & Register with AI Manager
> 
>    
>    - **AWX** (Open Source Ansible Tower) with preloaded Playbooks
>    - **AI Models** - Load and Train 
>      - Create Training Definitions (TG, LAD, CR, SI. Turn off RSA) 
>      - Create Training Data (LAD, SNOW) 
>      - Train Models (TG, LAD, CR, SI) 
>    - **Topology**
>      - RobotShop Demo App
>      - Create K8s Observer
>      - Create ASM merge rules
>      - Load Overlay Topology
>      - Create AI Manager Application
>    - **Misc**
> 	   - Creates valid certificate for Ingress (Slack) 
> 	   - External Routes (Flink, Topology, ...)
> 	   - Disables ASM Service match rule 
> 	   - Create Policy Creation for Stories and Runbooks 
> 	   - Demo Service Account 
> - **Turbonomic**
> - **Turbonomic Demo Content**
> 		- Demo User
> 		- RobotShop Demo App with synthetic metric
> 		- Instana target (if Instana is installed - you have to enter the API Token Manually)
> 		- Groups for vCenter and RobotShop
> 		- Groups for licensing
> 		- Resource Hogs
> - **Instana**
> 

<div style="page-break-after: always;"></div>

</details>
<details>
<summary>Install AI Manager, Event Manager with demo content</summary>

## 🐥 2.2 Install AI Manager, Event Manager with demo content

You get all the CP4WAIOPS components installed and pre-trained in one simple script.
Ready to go.



![K8s CNI](./doc/pics/install01.png)

1. In the the OCP Web UI click on the `+` sign in the right upper corner
1. Copy and paste the content from [this file](./Quick_Install/01_INSTALL_AIMGR_EVTMGR.yaml)
3. Replace `<REGISTRY_TOKEN>` at the end of the file with your pull token from step 1.1.3 (the Entitlement key from https://myibm.ibm.com)
3. Click `Save`

### **🚀 You can now go to [Demo the Solution](#3-demo-the-solution)**

This installation cocntains:

> - **AI Manager**
> 	- IBM Operator
> 	- AI Manager Instance
> - **AI Manager Demo Content**
>    - **OpenLDAP** & Register with AI Manager
> 
>    
>    - **AWX** (Open Source Ansible Tower) with preloaded Playbooks
>    - **AI Models** - Load and Train 
>      - Create Training Definitions (TG, LAD, CR, SI. Turn off RSA) 
>      - Create Training Data (LAD, SNOW) 
>      - Train Models (TG, LAD, CR, SI) 
>    - **Topology**
>      - RobotShop Demo App
>      - Create K8s Observer
>      - Create ASM merge rules
>      - Load Overlay Topology
>      - Create AI Manager Application
>    - **Misc**
> 	   - Creates valid certificate for Ingress (Slack) 
> 	   - External Routes (Flink, Topology, ...)
> 	   - Disables ASM Service match rule 
> 	   - Create Policy Creation for Stories and Runbooks 
> 	   - Demo Service Account 
> - **Event Manager**
> 	- Event Manager
> - **Event Manager Demo Content**
>   - **Topology**
>     - Create ASM merge rules
>     - Load ASM merge Topology
>     - Create AI Manager Application
> 

<div style="page-break-after: always;"></div>


</details>
<details>
<summary>Custom Install</summary>

## 🐥 2.3 Custom Install

1. Open the [00\_INSTALL_CUSTOM.yaml](./Quick_Install/00_INSTALL_CUSTOM.yaml) file
1. Adap the installation configuration to your needs. Select the modules to install and their configuration.

	```yaml
	- name: cp4waiops-aimanager
	  kind: AIManager						<-- The feature to be configured
	  install: true							<-- Install yes/no
	
	  # current_cp4waiops_feature			<-- Configuration of the feature
	  # CP4WAIOPS Size of the install
	  waiops_size: small
	  ...
	  # Version of the catalog subscription
	  subscription_channel: v3.6
	
	```
	
1. Replace `<REGISTRY_TOKEN>` at the end of the file with your pull token from step 1.1.3 (the Entitlement key from https://myibm.ibm.com)
1. Copy the content
1. In the the OCP Web UI click on the `+` sign in the right upper corner
1. Paste the content
1. Click `Save`

### **🚀 You can now go to [Demo the Solution](#3-demo-the-solution)**


</details>



---------------------------------------------------------------
# 3 Demo the Solution
---------------------------------------------------------------

📹 Please use the [Demo Script](/./doc/CP4AIOps%20Live%20Environment%20Sample%20Demo%20Script_NO_CHATOPS.md) to prepare for the demo.

📹 I have also added a short [Demo Walkthrough video](https://ibm.box.com/s/a4zbl8rjevxqfe48yxgatgmhomsiu8wl) that you can watch to get an idea on how to do the demo. This is based on 3.2 and the [Click Through PPT](https://ibm.box.com/s/icgkxzlt2ja6dth16dpdin055uyysej1), but should work more or less with your own instance.


<details>
<summary>Access the Environment</summary>

## 3.1 Access the Environment

To access the demo environment:

* Click on the Application Menu <svg fill="currentColor" height="1em" width="1em" viewBox="0 0 512 512" aria-hidden="true" role="img" style="vertical-align: -0.125em;"><path d="M149.333 56v80c0 13.255-10.745 24-24 24H24c-13.255 0-24-10.745-24-24V56c0-13.255 10.745-24 24-24h101.333c13.255 0 24 10.745 24 24zm181.334 240v-80c0-13.255-10.745-24-24-24H205.333c-13.255 0-24 10.745-24 24v80c0 13.255 10.745 24 24 24h101.333c13.256 0 24.001-10.745 24.001-24zm32-240v80c0 13.255 10.745 24 24 24H488c13.255 0 24-10.745 24-24V56c0-13.255-10.745-24-24-24H386.667c-13.255 0-24 10.745-24 24zm-32 80V56c0-13.255-10.745-24-24-24H205.333c-13.255 0-24 10.745-24 24v80c0 13.255 10.745 24 24 24h101.333c13.256 0 24.001-10.745 24.001-24zm-205.334 56H24c-13.255 0-24 10.745-24 24v80c0 13.255 10.745 24 24 24h101.333c13.255 0 24-10.745 24-24v-80c0-13.255-10.745-24-24-24zM0 376v80c0 13.255 10.745 24 24 24h101.333c13.255 0 24-10.745 24-24v-80c0-13.255-10.745-24-24-24H24c-13.255 0-24 10.745-24 24zm386.667-56H488c13.255 0 24-10.745 24-24v-80c0-13.255-10.745-24-24-24H386.667c-13.255 0-24 10.745-24 24v80c0 13.255 10.745 24 24 24zm0 160H488c13.255 0 24-10.745 24-24v-80c0-13.255-10.745-24-24-24H386.667c-13.255 0-24 10.745-24 24v80c0 13.255 10.745 24 24 24zM181.333 376v80c0 13.255 10.745 24 24 24h101.333c13.255 0 24-10.745 24-24v-80c0-13.255-10.745-24-24-24H205.333c-13.255 0-24 10.745-24 24z"></path></svg> in your Openshift Web Console.
* Select `CP4WAIOps Demo UI`
* Login with the password `P4ssw0rd!`

	![demo](./doc/pics/demo-menu.png)




<div style="page-break-after: always;"></div>

</details>
<details>
<summary>Login to AI Manager as demo User</summary>

## 3.2 Login to AI Manager as demo User

* Click on the blue `AI Manager` button
* Login as User `demo` with the Password `P4ssw0rd!`


![demo](./doc/pics/demo01.png)


</details>
<details>
<summary>🚀 Demo the Solution</summary>

## 3.3 🚀 Demo the Solution

Please use the [Script](/./doc/CP4AIOps%20Live%20Environment%20Sample%20Demo%20Script_NO_CHATOPS.md) to prepare for the demo.

Then start the demo with the [Demo Script](/./doc/CP4AIOps%20Live%20Environment%20Sample%20Demo%20Script_NO_CHATOPS.md#3-deliver-the-demo).

</details>
<div style="page-break-after: always;"></div>



---------------------------------------------------------------
# 4 Slack integration
---------------------------------------------------------------


For the system to work you need to follow those steps:


1. Create Slack Workspace
1. Create Slack App
1. Create Slack Channels
1. Create Slack Integration
1. Get the Integration URL
1. Create Slack App Communications
1. Slack Reset

<div style="page-break-after: always;"></div>


<details>
<summary>Detailed Instructions</summary>

## 4.1 Create your Slack Workspace

1. Create a Slack workspace by going to https://slack.com/get-started#/createnew and logging in with an email <i>**which is not your IBM email**</i>. Your IBM email is part of the IBM Slack enterprise account and you will not be able to create an independent Slack workspace outside if the IBM slack service. 

  ![slack1](./doc/pics/slackws1.png)

2. After authentication, you will see the following screen:

  ![slack2](./doc/pics/slackws2.png)

3. Click **Create a Workspace** ->

4. Name your Slack workspace

  ![slack3](./doc/pics/slackws3.png)

  Give your workspace a unique name such as aiops-\<yourname\>.

5. Describe the workspace current purpose

  ![slack4](./doc/pics/slackws4.png)

  This is free text, you may simply write “demo for Watson AIOps” or whatever you like.

6. 

  ![slack5](./doc/pics/slackws5.png)

  You may add team members to your new Slack workspace or skip this step.


At this point you have created your own Slack workspace where you are the administrator and can perform all the necessary steps to integrate with CP4WAOps.

![slack6](./doc/pics/slackws6.png)

**Note** : This Slack workspace is outside the control of IBM and must be treated as a completely public environment. Do not place any confidential material in this Slack workspace.

<div style="page-break-after: always;"></div>


## 4.2 Create Your Slack App

1. Create a Slack app, by going to https://api.slack.com/apps and clicking `Create New App`. 

   ![slack7](./doc/pics/slack01.png)


2. Select `From an app manifest`


  ![slack7](./doc/pics/slack02.png)

3. Select the appropriate workspace that you have created before and click `Next`

4. Copy and paste the content of this file [./doc/slack/slack-app-manifest.yaml](./doc/slack/slack-app-manifest.yaml).

	Don't bother with the URLs just yet, we will adapt them as needed.

5. Click `Next`

5. Click `Create`

6. Scroll down to Display Information and name your CP4WAIOPS app.

7. You can add an icon to the app (there are some sample icons in the ./tools/4_integrations/slack/icons folder.

8. Click save changes

9. In the `Basic Information` menu click on `Install to Workspace` then click `Allow`

<div style="page-break-after: always;"></div>


## 4.3 Create Your Slack Channels


1. In Slack add a two new channels:
	* aiops-demo-reactive
	* aiops-demo-proactive

	![slack7](./doc/pics/slack03.png)


2. Right click on each channel and select `Copy Link`

	This should get you something like this https://xxxx.slack.com/archives/C021QOY16BW
	The last part of the URL is the channel ID (i.e. C021QOY16BW)
	Jot them down for both channels
	
3. Under Apps click Browse Apps

	![slack7](./doc/pics/slack13.png)

4. Select the App you just have created

5. Invite the Application to each of the two channels by typing

	```bash
	@<MyAppname>
	```

6. Select `Add to channel`

	You shoud get a message from <MyAppname> saying `was added to #<your-channel> by ...`


<div style="page-break-after: always;"></div>

## 4.4 Integrate Your Slack App

In the Slack App: 

1. In the `Basic Information` menu get the `Signing Secret` (not the Client Secret!) and jot it down

	![K8s CNI](./doc/pics/doc47.png)
	
3. In the `OAuth & Permissions` get the `Bot User OAuth Token` (not the User OAuth Token!) and jot it down

	![K8s CNI](./doc/pics/doc48.png)

In the AI Manager (CP4WAIOPS) 

1. In the `AI Manager` "Hamburger" Menu select `Define`/`Data and tool integrations`
1. Click `Add connection`

	![K8s CNI](./doc/pics/doc14.png)
	
1. Under `Slack`, click on `Add Connection`
	![K8s CNI](./doc/pics/doc45.png)

6. Name it "Slack"
7. Paste the `Signing Secret` from above
8. Paste the `Bot User OAuth Token` from above

	![K8s CNI](./doc/pics/doc50.png)
	
9. Paste the channel IDs from the channel creation step in the respective fields

	![K8s CNI](./doc/pics/doc49.png)
	
	![K8s CNI](./doc/pics/doc52.png)
		
		

10. Test the connection and click save




<div style="page-break-after: always;"></div>


## 4.5 Create the Integration URL

In the AI Manager (CP4WAIOPS) 

1. Go to `Data and tool integrations`
2. Under `Slack` click on `1 integration`
3. Copy out the URL

	![secure_gw_search](./doc/pics/slack04.png)

This is the URL you will be using for step 6.


<div style="page-break-after: always;"></div>


## 4.6 Create Slack App Communications

Return to the browser tab for the Slack app. 

### 4.6.1 Event Subscriptions

1. Select `Event Subscriptions`.

2. In the `Enable Events` section, click the slider to enable events. 

3. For the Request URL field use the `Request URL` from step 5.

	e.g: `https://<my-url>/aiops/aimanager/instances/xxxxx/api/slack/events`

4. After pasting the value in the field, a *Verified* message should display.

	![slacki3](./doc/pics/slacki3.png)

	If you get an error please check 5.7

5. Verify that on the `Subscribe to bot events` section you got:

	*  `app_mention` and 
	*  `member_joined_channel` events.

	![slacki4](./doc/pics/slacki4.png)

6. Click `Save Changes` button.


### 4.6.2 Interactivity & Shortcuts

7. Select `Interactivity & Shortcuts`. 

8. In the Interactivity section, click the slider to enable interactivity. For the `Request URL` field, use use the URL from above.

 **There is no automatic verification for this form**

![slacki5](./doc/pics/slacki5.png)

9. Click `Save Changes` button.

### 4.6.3 Slash Commands

Now, configure the `welcome` slash command. With this command, you can trigger the welcome message again if you closed it. 

1. Select  `Slash Commands`

2. Click `Create New Command` to create a new slash command. 

	Use the following values:
	
	
	| Field | Value |
	| --- | --- |
	|Command| /welcome|
	|Request URL|the URL from above|
	|Short Description| Welcome to Watson AIOps|

3. Click `Save`.

### 4.6.4 Reinstall App

The Slack app must be reinstalled, as several permissions have changed. 

1. Select `Install App` 
2. Click `Reinstall to Workspace`

Once the workspace request is approved, the Slack integration is complete. 

If you run into problems validating the `Event Subscription` in the Slack Application, see 5.2

<div style="page-break-after: always;"></div>

<div style="page-break-after: always;"></div>



<div style="page-break-after: always;"></div>

## 4.7 Slack Reset


### 4.7.1 Get the User OAUTH Token

This is needed for the reset scripts in order to empty/reset the Slack channels.

This is based on [Slack Cleaner2](https://github.com/sgratzl/slack_cleaner2).
You might have to install this:

```bash
pip3 install slack-cleaner2
```
#### Reset reactive channel 

In your Slack app

1. In the `OAuth & Permissions` get the `User OAuth Token` (not the Bot User OAuth Token this time!) and jot it down

In file `./tools/98_maintenance/scripts/13_reset-slack.sh`

2. Replace `not_configured` for the `SLACK_TOKEN` parameter with the token 
3. Adapt the channel name for the `SLACK_REACTIVE` parameter


#### Reset proactive channel 

In your Slack app

1. In the `OAuth & Permissions` get the `User OAuth Token` (not the Bot User OAuth Token this time!) and jot it down (same token as above)

In file `./tools/98_maintenance/scripts/14_reset-slack-changerisk.sh`

2. Replace `not_configured` for the `SLACK_TOKEN` parameter with the token 
3. Adapt the channel name for the `SLACK_PROACTIVE` parameter



### 4.7.2 Perform Slack Reset

Call either of the scripts above to reset the channel:

```bash

./tools/98_maintenance/scripts/13_reset-slack.sh

or

./tools/98_maintenance/scripts/14_reset-slack-changerisk.sh

```
</details>



---------------------------------------------------------------
# 5 Demo Setup - Explained
---------------------------------------------------------------


![demo](./doc/pics/waiops_arch_overview.jpg)

<details>
<summary>Basic Architecture</summary>

## 5.1 Basic Architecture

The environement (Kubernetes, Applications, ...) create logs that are being fed into a Log Management Tool (ELK in this case).

![demo](./doc/pics/waiops_arch_overview.jpg)

1. External Systems generate Alerts and send them into the AI Manager for Event Grouping.
1. At the same time AI Manager ingests the raw logs coming from the Log Management Tool (ELK) and looks for anomalies in the stream based on the trained model.
2. It also ingests Metric Data and looks for anomalies
1. If it finds an anomaly (logs and/or metrics) it forwards it to the Event Grouping as well.
1. Out of this, AI Manager creates a Story that is being enriched with Topology (Localization and Blast Radius) and with Similar Incidents that might help correct the problem.
1. The Story is then sent to Slack.
1. A Runbook is available to correct the problem but not launched automatically.

<div style="page-break-after: always;"></div>

</details>
<details>
<summary>Optimized Demo Architecture</summary>

## 5.2 Optimized Demo Architecture

The idea of this repo is to provide a optimised, complete, pre-trained demo environment that is self-contained (e.g. can be deployed in only one cluster)

It contains the following components (which can be installed independently):

 - **AI Manager**
 	- IBM Operator
 	- AI Manager Instance
 - **AI Manager Demo Content**  (optional)
    - **OpenLDAP** & Register with AI Manager
    - **AWX** (Open Source Ansible Tower) with preloaded Playbooks
    - **AI Models** - Load and Train 
      - Create Training Definitions (TG, LAD, CR, SI. Turn off RSA) 
      - Create Training Data (LAD, SNOW) 
      - Train Models (TG, LAD, CR, SI) 
    - **Topology**
      - RobotShop Demo App
      - Create K8s Observer
      - Create ASM merge rules
      - Load Overlay Topology
      - Create AI Manager Application
    - **Misc**
     	   - Creates valid certificate for Ingress (Slack) 
     	   	   	   	   - External Routes (Flink, Topology, ...)
     	   	   	   	    	   	   	    	   	    	   - Disables ASM Service match rule 
     	   	   	   	    	   	   	    	   	    	   	   	   	    	   	    	   	   	    	   	   - Create Policy Creation for Stories and Runbooks 
     	   	   	   	    	   	   	    	   	    	   	   	   	    	   	    	   	   	    	   	    	   	   	    	   	    	   	   	    	   	    	   	    	   	    	   - Demo Service Account 
 - **Event Manager**  (optional)
 	- Event Manager
 - **Event Manager Demo Content**  (optional)
   - **Topology**
     - Create ASM merge rules
     - Load ASM merge Topology
     - Create AI Manager Application
 - **Turbonomic**  (optional)
 - **Turbonomic Demo Content** (optional)
	- Demo User
	- RobotShop Demo App with synthetic metric
	- Instana target (if Instana is installed - you have to enter the API Token Manually)
	- Groups for vCenter and RobotShop
	- Groups for licensing
	- Resource Hogs
 - **Instana**  (optional)

![demo](./doc/pics/waiops_arch_dataflow.jpg)


For the this specific Demo environment:

* ELK is not needed as I am using pre-canned logs for training and for the anomaly detection (inception)
* Same goes for Metrics, I am using pre-canned metric data for training and for the anomaly detection (inception)
* The Events are also created from pre-canned content that is injected into AI Manager
* There are also pre-canned ServiceNow Incidents if you don’t want to do the live integration with SNOW
* The Webpages that are reachable from the Events are static and hosted on my GitHub
* The same goes for ServiceNow Incident pages if you don’t integrate with live SNOW

This allows us to:

* Install the whole Demo Environment in a self-contained OCP Cluster
* Trigger the Anomalies reliably
* Get Events from sources that would normally not be available (Instana, Turbonomic, Log Aggregator, Metric Provider, ...)
* Show some examples of SNOW integration without a live system


<div style="page-break-after: always;"></div>

</details>
<details>
<summary> Training </summary>

## 5.3 Training

### 5.3.1 Loading training data

![demo](./doc/pics/waiops_arch_training.jpg)

Loading Training data is done at the lowest possible level (for efficiency and speed):

* Logs: Loading Elastic Search indexes directly into ES - two days of logs for March 3rd and 4th 2022
* SNOW: Loading Elastic Search indexes directly into ES - synthetic data with 15k change requests and 5k incidents
* Metrics: Loading Cassandra dumps of metric data - 3 months of synthetic data for 13 KPIs


### 5.3.2 Training the models

The models can be trained directly on the data that has been loaded as described above.


<div style="page-break-after: always;"></div>

</details>
<details>
<summary>Incident creation</summary>

## 5.4 Incident creation (inception)

![demo](./doc/pics/waiops_arch_inception.jpg)

Incidents are being created by using the high level APIs in order to simulate a real-world scenario.

* Events: Pre-canned events are being injected through the corresponding REST API
* Logs: Pre-canned anomalous logs for a 30 min timerange are injected through Kafka
* Metrics: Anomalous metric data are generated on the fly and injected via the corresponding REST API
</details>


<div style="page-break-after: always;"></div>

