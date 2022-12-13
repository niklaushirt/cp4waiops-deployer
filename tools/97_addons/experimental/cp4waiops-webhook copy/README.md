# A Simple Webhook to CP4WAIOPS AIManager

This allows you to push generic JSON to AIManager Events throught a Webhook into AI Manager.

> Source code is included if you want to mess around a bit.


## Accessing the Web UI

You can access the Web UI via the external Route that you can determine like this:

```bash   
oc get route -n cp4waiops cp4waiops-event-gateway  -o jsonpath={.spec.host}
```

You have to use the Token to access the UI.


## Using the Webhook

The Webhook API is available at `http://<YOUR-CLUSTER>/xxx`

The APIs are:

```
http://YOUR-CLUSTER/webhookIterate - for events in an array

http://YOUR-CLUSTER/webhookSingle - for single events
```

It has to be called with the `POST` Method and the security `token` (defined in the ConfigMap) has to be provided in the Header.



## Configuring the Webhook

The base configuration:
```
    TOKEN: 'token2022'
    WEBHOOK_DEBUG: 'false'
```

The Iteration element:
```
  ITERATE_ELEMENT: 'events'
```
If the JSON contains an array of events use this to iterate over all events:

```json
"events": [
  {
    "EVENT": 1
  },
  {
    "EVENT": 2
  },
  {
    "EVENT": 3
  }
]
```

The mapping configuration has two parts (defined in the ConfigMap):

* The `Template`, that contains the final output to AI Manager with the Placeholders (the Placeholders must correspond to the Output Mapping Name prefixed by `@@`):

	```
	  EVENT_TEMPLATE: '{"id": "1a2a6787-59ad-4acd-bd0d-46c1ddfd8e00","occurrenceTime": "@@TIMESTAMP_DATE","summary": "@@SUMMARY_TEXT","severity": @@SEVERITY_NUMBER,"type": {"eventType": "problem","classification": "@@MANAGER_NAME"},"expirySeconds": @@EXPIRY_SECONDS,"links": [{"linkType": "webpage","name": "@@MANAGER_NAME","description": "@@MANAGER_NAME","url": "@@URL_TXT"}],"sender": {"type": "host","name": "@@SENDER_NAME","sourceId": "@@SENDER_NAME"},"resource": {"type": "host","name": "@@RESOURCE_NAME","sourceId": "@@RESOURCE_NAME"},"details": {@@DETAILS_JSON}}' 
	```

* The `Mapping` contains pairs of Input Mapping Names and Output Mapping Names:
* 
	```
	  EVENT_MAPPING: |- 
	    'kubernetes.container_name,RESOURCE_NAME;
	    kubernetes.namespace_name,SENDER_NAME;
	    @rawstring,SUMMARY_TEXT;
	    override_with_date,TIMESTAMP_DATE;
	    URL,URL_TXT;
	    Severity,SEVERITY_NUMBER;
	    Expiry,EXPIRY_SECONDS;
	    details,DETAILS_JSON;
	    Manager,MANAGER_NAME'
	```

So in the above example the Gateway would 

```
loop over all events
    Get the `Node` element from the Input Event
    Store it in `RESOURCE_NAME`
    Replace `@@RESOURCE_NAME` with the value 
```



## Sample Webhook

For the following example we will iterate over the `events` array and push them to AI Manager:


```bash
curl -X "POST" "http://<YOUR-CLUSTER>/webhookIterate" \
     -H 'token: test' \
     -H 'Content-Type: text/plain; charset=utf-8' \
     -d $'{
"events": [
  {
    "URL": "https://pirsoscom.github.io/git-commit-robot.html",
    "Manager": "ELK",
    "Severity": 2,
    "@rawstring": "[Git] Commit in repository robot-shop by Niklaus Hirt on file robot-shop.yaml - New Memory Limits",
    "kubernetes.container_name": "mysql-github",
    "kubernetes.namespace_name": "robot-shop",
    "@timestamp": "robot-shop"
  },
  {
    "URL": "https://pirsoscom.github.io/git-commit-robot.html",
    "Manager": "ELK",
    "Severity": 3,
    "@rawstring": "[Instana] MySQL - change detected - The value **resources/limits** has changed",
    "kubernetes.container_name": "mysql-instana",
    "kubernetes.namespace_name": "robot-shop",
    "@timestamp": "robot-shop"
  },
  {
    "URL": "https://pirsoscom.github.io/git-commit-robot.html",
    "Manager": "ELK",
    "Severity": 4,
    "@rawstring": "[Turbonomic] Container Resize - Controller Resize - Resize UP VMem Limit from 50 MB to 328 MB in Container Spec mysql ",
    "kubernetes.container_name": "mysql-turbonomic",
    "kubernetes.namespace_name": "robot-shop",
    "@timestamp": "robot-shop"
  },
    {
    "URL": "https://pirsoscom.github.io/git-commit-robot.html",
    "Manager": "ELK",
    "Severity": 5,
    "@rawstring": "[Log] Ratings - Error: unable to contact MYSQL failed with status code 500",
    "kubernetes.container_name": "ratings-log",
    "kubernetes.namespace_name": "robot-shop",
    "@timestamp": "robot-shop"
  },
    {
    "URL": "https://pirsoscom.github.io/git-commit-robot.html",
    "Manager": "ELK",
    "Severity": 6,
    "@rawstring": "[Instana] Robotshop Homepage call rate is too high- Robotshop call rate stays at a high level for an extended period of time",
    "kubernetes.container_name": "web-instana",
    "kubernetes.namespace_name": "robot-shop",
    "@timestamp": "robot-shop"
  }
],
"numberOfEvents": 3
}
'

```


# Deployment

The easiest way to deploy the webhook is by using the automated Ansible script.

```bash   
ansible-playbook ./ansible/19_aimanager-event-webhook.yaml 

oc get route -n cp4waiops cp4waiops-event-gateway  -o jsonpath={.spec.host}
```

