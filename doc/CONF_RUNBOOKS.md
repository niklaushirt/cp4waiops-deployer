---------------------------------------------------------------
# 12 Runbook Configuration
---------------------------------------------------------------

## 12.1 Configure Runbooks with AWX 

This is the preferred method.

Use Option 🐥`23` in Easy Install to install an `AWX ` instance if you haven't done so yet.

or directly run: 

```bash
ansible-playbook ./ansible/23_addons-install-awx.yaml
```

### 12.1.1 Configure AWX 

There is some demo content available to RobotShop.

1. Log in to AWX
2. Add a new Project
	1. Name it `DemoCP4WAIOPS`
	1. Source Control Credential Type to `Git`
	1. Set source control URL to `https://github.com/niklaushirt/ansible-demo`
	2. Save
	
1. Add new Job Template
	1. Name it `Mitigate Robotshop Ratings Outage`
	2. Select Inventory `Demo Inventory`
	3. Select Project `DemoCP4WAIOPS`
	4. Select Playbook `cp4waiops/robotshop-restart/start-ratings.yaml`
	5. Select` Prompt on launch` for `Variables`  ❗
	2. Save



### 12.1.2 Configure AWX Integration 

In EventManager:

1. Select `Administration` / `Integration with other Systems`
1. Select `Automation type` tab
1. For `Ansible Tower` click  `Configure`
2. Enter the URL and credentials for your AWX instance (you can use the defautl `admin` user)
3. Click Save

<div style="page-break-after: always;"></div>

### 12.1.3 Configure Runbook 

In EventManager:

1. Select `Automations` / `Runbooks`
1. Select `Library` tab
1. Click  `New Runbook`
1. Name it `Mitigate Robotshop Ratings Outage`
1. Click `Add automated Step`
2. Select the `Mitigate Robotshop Ratings Outage` Job

	![](./pics/rb1.png)

3. Click `Select this automation`
4. Select `New Runbook Parameter`

	![](./pics/rb2.png)

5. Name it `ClusterCredentials`
6. Input the login credentials in JSON Format (get the URL and token from the 20\_get\_logins.sh script)

	![](./pics/rb5.png)
	
	```json
	{     
		"my_k8s_apiurl": "https://c117-e.xyz.containers.cloud.ibm.com:12345",
		"my_k8s_apikey": "PASTE YOUR API KEY"
	}
	```
	
	![](./pics/rb3.png)

7. Click Save

	![](./pics/rb4.png)
	
7. Click Publish


	
	
Now you can test the Runbook by clicking on `Run`.

<div style="page-break-after: always;"></div>

### 12.1.4 Add Runbook Triggers 

1. Select `Automations` / `Runbooks`
1. Select `Triggers` tab
1. Click  `New Trigger `
1. Name it `Mitigate Robotshop Ratings Outage`
1. Add conditions:
   * Conditions
	* Name: RobotShop
	* Attribute: Node
	* Operator: Equals
	* Value: mysql-instana or mysql-predictive
1. Click `Run Test`
2. You should get an Event `[Instana] Robotshop available replicas is less than desired replicas - Check conditions and error events - ratings`
3. Select `Mitigate RobotShop Problem`
4. Click `Select This Runbook`
5. Toggle `Execution` / `Automatic` to `off`
6. Under `Parameters for this runbook` select `Manual` and input the login credentials in JSON Format (get the URL and token from the 20\_get\_logins.sh script)

	```json
	{     
		"my_k8s_apiurl": "https://c117-e.xyz.containers.cloud.ibm.com:12345",
		"my_k8s_apikey": "PASTE YOUR API KEY"
	}
	```
6. Click `Save`




<div style="page-break-after: always;"></div>


## 12.2 Configure Runbooks with bastion server

> ### ❗Old method

### 12.2.1 Create Bastion Server

A simple Pod with the needed tools (oc, kubectl) being used as a bastion host for Runbook Automation should already have been created by the install script. 



### 12.2.2 Create the EventManager/NOI Integration

#### 12.2.2.1 In EventManager/NOI

* Go to  `Administration` / `Integration with other Systems` / `Automation Type` / `Script`
* Copy the SSH KEY


#### 12.2.2.2 Adapt SSL Certificate in Bastion Host Deployment. 

* Select the `bastion-host` Deployment in Namespace `default`
* Adapt Environment Variable SSH_KEY with the key you have copied above.



### 12.2.3 Create Automation


#### 12.2.3.1 Connect to Cluster
`Automation` / `Runbooks` / `Automations` / `New Automation`


```bash
oc login --token=$token --server=$ocp_url --insecure-skip-tls-verify
```

Use these default values

```yaml
target: bastion-host-service.default.svc
user:   root
$token	 : Token from your login (from ./tools/20_get_logins.sh)	
$ocp_url : URL from your login (from ./tools/20_get_logins.sh, something like https://c102-e.eu-de.containers.cloud.ibm.com:32236)		
```

<div style="page-break-after: always;"></div>

#### 12.2.3.2 RobotShop Mitigate MySql
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


### 12.2.4 Create Runbooks


* `Library` / `New Runbook`
* Name it `Mitigate RobotShop Problem`
* `Add Automated Step`
* Add `Connect to Cluster`
* Select `Use default value` for all parameters
* Then `RobotShop Mitigate Ratings`
* Select `Use default value` for all parameters
* Click `Publish`




### 12.2.5 Add Runbook Triggers

* `Triggers` / `New Trigger`
* Name and Description: `Mitigate RobotShop Problem`
* Conditions
	* Name: RobotShop
	* Attribute: Node
	* Operator: Equals
	* Value: mysql-instana or mysql-predictive
* Click `Run Test`
* You should get an Event `[Instana] Robotshop available replicas is less than desired replicas - Check conditions and error events - ratings`
* Select `Mitigate RobotShop Problem`
* Click `Select This Runbook`
* Toggle `Execution` / `Automatic` to `off`
* Click `Save`



<div style="page-break-after: always;"></div>



