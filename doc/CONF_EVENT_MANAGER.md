---------------------------------------------------------------
# 11 EventManager Configuration
---------------------------------------------------------------

## 11.1 Configure EventManager 

❗ You only have to do this if you have installed EventManager/NOI (As described in Easy Install - Chapter 6). For basic demoing with AI MAnager this is not needed.




### 11.1.1 Create Kubernetes Observer for the Demo Applications 

This is basically the same as for AI Manager as we need two separate instances of the Topology Manager. 


* In the `Event Manager` "Hamburger" Menu select `Administration`/`Topology Management`
* Under `Observer jobs` click `Configure`
* Click `Add new job`
* Under `Kubernetes`, click on `Configure`
* Choose `local` for `Connection Type`
* Set `Unique ID` to `robot-shop`
* Set `data_center` to `robot-shop`
* Under `Additional Parameters`
* Set `Terminated pods` to `true`
* Set `Correlate` to `true`
* Set Namespace to `robot-shop`
* Under `Job Schedule`
* Set `Time Interval` to 5 Minutes
* Click `Save`




### 11.1.2 Create REST Observer to Load Topologies 

* In the `Event Manager` "Hamburger" Menu select `Administration`/`Topology Management`
* Under `Observer jobs` click `Configure`
* Click `Add new job`
* Under `REST`, click on `Configure`
* Choose `bulk_replace` for `Job Type`
* Set `Unique ID` to `listenJob` (important!)
* Set `Provider` to `listenJob` 
* Click `Save`







<div style="page-break-after: always;"></div>

### 11.1.3 🐥 Create Topology 

❗ Currently broken!!!!

##### Use 🐥 Easy Install - Option `xx` for creating the Robot-Shop topology. 


❗ Please manually re-run the Kubernetes Observer to make sure that the merge has been done.



### 11.1.4 EventManager Webhook 

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



<div style="page-break-after: always;"></div>


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

Fill out the following fields and save:

* Severity: `severity`
* Summary: `summary`
* Resource name: `nodename`
* Event type: `alertgroup`
* Url: `url`
* Description: `"URL"`

Optionnally you can also add `Expiry Time` from `Optional event attributes` and set it to a convenient number of seconds (just make sure that you have time to run the demo before they expire.

<div style="page-break-after: always;"></div>

### 11.1.5 Create custom Filter and View in EventManager 






#### 11.1.5.1 Filter 


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

![](./pics/noi10.png)


#### 11.1.5.2 View 
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


### 11.1.6 Create grouping Policy 

* In the `Event Manager` "Hamburger" Menu select `Netcool WebGui`
* Click `Insights`
* Click `Scope Based Grouping`
* Click `Create Policy`
* `Action` select fielt `Alert Group`
* Toggle `Enabled` to `On`
* Save

<div style="page-break-after: always;"></div>

### 11.1.7 Create EventManager/NOI Menu item - Open URL 

in the Netcool WebGUI

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


<div style="page-break-after: always;"></div>

### 11.1.8 Create Templates for Topology Grouping (optional)

This gives you probale cause and is not strictly needed if you don't show EventManager!

* In the EventManager "Hamburger" Menu select `Operate`/`Topology Viewer`
* Then, in the top right corner, click on the icon with the three squares (just right of the cog)
* Select `Create a new Template`
* Select `Dynamic Template`

Create a template for RobotShop:

* Search for `web-deployment` (deployment)
* Create Topology 3 Levels
* Name the template (robotshop)
* Select `Namespace` in `Group type`
* Enter `robotshop_` for `Name prefix`
* Select `Application` 
* Add tag `namespace:robot-shop`
* Save

### 11.1.9 Manually create Topology (optional)

Only do this if you don't want to use 🐥 Easy Install

