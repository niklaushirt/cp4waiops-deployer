# Turbo to WAIOPS Gateway (actions-->events)
1. Configure ```create-turbo-gateway.yaml``` file with your Turbo login and URL
2. Configure ```create-turbo-gateway.yaml``` file with the name of your Turbo Business Application
3. Create Generic Webhook in NOI with:
    ```
    {
    "timestamp": "1619706828000",
    "severity": "Critical",
    "summary": "Test Event",
    "nodename": "productpage-v1",
    "alertgroup": "robotshop",
    "url": "https://pirsoscom.github.io/grafana-robotshop.html"
    }
    ````
4. Configure ```create-turbo-gateway.yaml``` file with your NOI Webhook


1. Edit `create-turbo-gateway.yaml` ConfigMap details

| Variable | Default Value | Description |
| -------- | ------------- | ----------- |
|POLLING_INTERVAL| '300' | Poll every X seconds |
|NOI_SUMMARY_PREFIX| '[Turbonomic] ' | Prefix in the event summary |
|NOI_WEBHOOK_URL| netcool-evtmanager.apps.clustername.domain | Event Manager hostname |
|NOI_WEBHOOK_PATH| /norml/xxxx | Webhook URL from Event Manager (does not inclue the hostname, only `/norml/xxxx`) |
|TURBO_API_URL| api-turbonomic.apps.clustername.domain | Turbonomic API URL |
|TURBO_BA_NAME| 'Quote of the Day Hybrid:qotd-hybrid' | Turbonomic application name in the format APPNAME:ALERTGROUP. This links an event manager alertgroup with an application |
|ACTION_STATES| 'SUCCEEDED,FAILED,READY,IN_PROGRESS' | The list of ACTION_STATES to filter on |
|ACTION_TYPES| 'MOVE,RESIZE_FOR_PERFORMANCE,RESIZE_FOR_EFFICIENCY,RESIZE' | The list of ACTION_TYPES to filter on |
|DEBUG_ENABLED| 'false' | Enable additional log output |
|ENTITY_TYPES| 'VirtualMachine,Application,PhysicalMachine,ContainerSpec,WorkloadController,Container' | The list of ENTITY_TYPES to filter on |
|ACTION_START_TIME| '-30m'| Period of time in which actions are retrieved. E.g. -5m, -30m, -1h, -1d, -3d, -7d | 