
# Interacting with the Metrics API

## Documentation

All the following stuff comes from here:

[https://github.ibm.com/katamari/architecture/blob/master/feature-specs/metrics-anomaly/Testing.md#kafka-ingestion](https://github.ibm.com/katamari/architecture/blob/master/feature-specs/metrics-anomaly/Testing.md#kafka-ingestion)

and here:

[https://ibmdocs-test.mybluemix.net/docs/en/cloud-paks/cloud-pak-watson-aiops/3.3.0?topic=ma-swagger-document](https://ibmdocs-test.mybluemix.net/docs/en/cloud-paks/cloud-pak-watson-aiops/3.3.0?topic=ma-swagger-document)


## Interact with the API

* Initialize the connection variables

	```bash
	export WAIOPS_NAMESPACE=$(oc get po -A|grep aiops-orchestrator-controller |awk '{print$1}')
	export ROUTE=$(oc get route -n $WAIOPS_NAMESPACE| grep ibm-nginx-svc | awk '{print $2}')
	PASS=$(oc get secret -n $WAIOPS_NAMESPACE admin-user-details -o jsonpath='{.data.initial_admin_password}' | base64 -d)
	export TOKEN=$(curl -k -X POST https://$ROUTE/icp4d-api/v1/authorize -H 'Content-Type: application/json' -d "{\"username\": \"admin\",\"password\": \"$PASS\"}" | jq .token | sed 's/\"//g')
	
	echo "ROUTE:    "$ROUTE
	echo "TOKEN:    "$TOKEN
	```


* Get Metrics

	```bash
	export METRIC=latency.max
	export GROUP=Latency
	export RESOURCE=mysql
	
	curl -k "https://${ROUTE}/aiops/api/app/metric-api/v1/metrics?resource=$RESOURCE&group=$GROUP&metric=$METRIC" --header "Authorization: Bearer ${TOKEN}" --header 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' --insecure
	```
	

* Get Forecast

	```bash
	export METRIC=latency.max
	export GROUP=Latency
	export RESOURCE=mysql
	
	curl -k "https://${ROUTE}/aiops/api/app/metric-api/v1/forecast?resource=$RESOURCE&group=$GROUP&metric=$METRIC" --header "Authorization: Bearer ${TOKEN}" --header 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' --insecure
	```
	
* Push a metrics file into Metrics API

	```bash
	export IMPORT_FILE_JSON=demo__metrics__training__20200901-0100__20201003-0500.json
	
	curl -v -X POST "https://${ROUTE}/aiops/api/app/metric-api/v1/metrics" --header 'Content-Type: application/json' --header "Authorization: Bearer ${TOKEN}" --header 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' --data @$IMPORT_FILE_JSON
	```

# Create synthetic data

1. Copy files to Pod filesystem

	```bash
	./synthetic-metrics.sh
	```


# Interacting with Cassandra

## Load the data into Cassandra

1. Copy files to Pod filesystem

    ```bash
    oc rsync ./dumps/ aiops-topology-cassandra-0:/tmp/
    ```

1. Truncate the tables

    ```bash
    oc exec -ti aiops-topology-cassandra-0 -- bash -c "/opt/ibm/cassandra/bin/cqlsh --ssl -u \$CASSANDRA_USER -p \$CASSANDRA_PASS -e \"TRUNCATE  tararam.dt_metric_value;\""
    oc exec -ti aiops-topology-cassandra-0 -- bash -c "/opt/ibm/cassandra/bin/cqlsh --ssl -u \$CASSANDRA_USER -p \$CASSANDRA_PASS -e \"TRUNCATE  tararam.md_metric_resource;\""
    ```
    
1. Load the dumps

    ```bash
    oc exec -ti aiops-topology-cassandra-0 -- bash -c "/opt/ibm/cassandra/bin/cqlsh --ssl -u \$CASSANDRA_USER -p \$CASSANDRA_PASS -e \"copy tararam.dt_metric_value from '/tmp/tararam.dt_metric_value.csv' with header=true;\""
    oc exec -ti aiops-topology-cassandra-0 -- bash -c "/opt/ibm/cassandra/bin/cqlsh --ssl -u \$CASSANDRA_USER -p \$CASSANDRA_PASS -e \"copy tararam.md_metric_resource from '/tmp/tararam.md_metric_resource.csv' with header=true;\""
    ```



1. Check the data

    ```bash
    oc exec -ti aiops-topology-cassandra-0 -- bash -c "/opt/ibm/cassandra/bin/cqlsh --ssl -u \$CASSANDRA_USER -p \$CASSANDRA_PASS -e \"SELECT * FROM tararam.dt_metric_value;\""
    oc exec -ti aiops-topology-cassandra-0 -- bash -c "/opt/ibm/cassandra/bin/cqlsh --ssl -u \$CASSANDRA_USER -p \$CASSANDRA_PASS -e \"SELECT * FROM tararam.md_metric_resource;\""
    ```

## Infer metric anomaly

1. Define Metrics Training


1. Run Metrics Training

1. Use `anomaly-metrics.sh`to infer an anomaly





## Get the data from Cassandra

1. Dump the tables to the Pod filesystem

	```bash
	oc exec -ti aiops-topology-cassandra-0 -- bash -c "/opt/ibm/cassandra/bin/cqlsh --ssl -u \$CASSANDRA_USER -p \$CASSANDRA_PASS -e \"copy tararam.md_metric_resource to '/tmp/tararam.md_metric_resource.csv' with header=true;\""
	oc exec -ti aiops-topology-cassandra-0 -- bash -c "/opt/ibm/cassandra/bin/cqlsh --ssl -u \$CASSANDRA_USER -p \$CASSANDRA_PASS -e \"copy tararam.dt_metric_value to '/tmp/tararam.dt_metric_value.csv' with header=true;\""
	```

1. Copy the dumps from the Pod to the local filesystem

	You can ignore the WARNING: cannot use rsync: rsync not available in container
	
	```bash
	oc rsync aiops-topology-cassandra-0:/tmp/tararam.md_metric_resource.csv ./dumps
	oc rsync aiops-topology-cassandra-0:/tmp/tararam.dt_metric_value.csv ./dumps
	```


## Debugging in Cassandra

### Connecting to Cassandra

* Open Session to Cassandra

	```bash
	oc exec -ti aiops-topology-cassandra-0 -- bash -c '/opt/ibm/cassandra/bin/cqlsh --ssl -u $CASSANDRA_USER -p $CASSANDRA_PASS'
	```

### Some Commands

* Empty the tables

	```bash
	TRUNCATE  tararam.dt_metric_value;
	TRUNCATE  tararam.md_metric_resource;
	```

* Check the data

	```bash
	SELECT * FROM tararam.dt_metric_value;
	SELECT * FROM tararam.md_metric_resource;
	```

* Get the Schema DDL

	```bash
	describe keyspace tararam;
	```

* Get all Cassandra Tables

	```bash
	describe tables;
	```





```bash
export WAIOPS_NAMESPACE=$(oc get po -A|grep aiops-orchestrator-controller |awk '{print$1}')

oc expose svc aiops-ir-analytics-metric-api -n $WAIOPS_NAMESPACE --name aiops-ir-analytics-metric-api
oc expose svc aiops-ir-analytics-metric-spark -n $WAIOPS_NAMESPACE --name aiops-ir-analytics-metric-spark


export METRIC_ROUTE=$(oc get route -n $WAIOPS_NAMESPACE aiops-ir-analytics-metric-api -o jsonpath={.spec.host})
export SPARK_ROUTE=$(oc get route -n $WAIOPS_NAMESPACE aiops-ir-analytics-metric-spark -o jsonpath={.spec.host})

echo "SWAGGER ROUTE:    http://"$METRIC_ROUTE"/metrics/api/swagger"

echo "SPARK ROUTE:    http://"$SPARK_ROUTE"/api/metricspark/swagger"

```

export PATH=/metrics/api/service/environment
echo "http://$METRIC_ROUTE$PATH"


export PATH=/api/metricspark
echo "http://$SPARK_ROUTE$PATH"



oc create route passthrough aiops-ir-analytics-metric-api -n cp4waiops --insecure-policy="Redirect" --service=aiops-ir-analytics-metric-api --port=unsecure-port
oc create route passthrough aiops-ir-analytics-metric-api -n cp4waiops --insecure-policy="Redirect" --service=aiops-ir-analytics-metric-api --port=unsecure-port
oc expose svc aiops-ir-analytics-metric-api -n cp4waiops --name aiops-ir-analytics-metric-api

http://aiops-ir-analytics-metric-api-cp4waiops.itzroks-270003bu3k-mxbvso-6ccd7f378ae819553d37d5f2ee142bd6-0000.eu-de.containers.appdomain.cloud/metrics/api/swagger

    GET     /metrics/api/1.0/forecast (com.ibm.itsm.analytics.metric.service.rest.MetricRetrievalApi)
    GET     /metrics/api/1.0/metrics (com.ibm.itsm.analytics.metric.service.rest.MetricRetrievalApi)
    POST    /metrics/api/1.0/metrics (com.ibm.itsm.analytics.metric.service.rest.MetricIngestionApi)
    POST    /metrics/api/1.0/metrics/bulkget (com.ibm.itsm.analytics.metric.service.rest.MetricRetrievalApi)
    GET     /metrics/api/service/environment (com.ibm.itsm.topology.service.resource.service.EnvironmentApi)
    GET     /metrics/api/service/info (com.ibm.itsm.topology.service.resource.service.ServiceInfoResource)
    GET     /metrics/api/servicemonitor (com.ibm.itsm.servicemonitor.api.ServiceMonitorApi)
    GET     /metrics/api/swagger (com.ibm.itsm.topology.service.resource.swagger.SwaggerResource)
    GET     /metrics/api/swagger.{type:json|yaml} (io.swagger.jaxrs.listing.ApiListingResource)

curl -k "https://${METRIC_ROUTE}/metrics/api/service/environment" --header "Authorization: Bearer ${TOKEN}" --header 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' --insecure
	```


https://cpd-cp4waiops.itzroks-270003bu3k-mxbvso-6ccd7f378ae819553d37d5f2ee142bd6-0000.eu-de.containers.appdomain.cloud/aiops/api/app/metric-api/swagger




aiops-ir-analytics-metric-spark

    GET     /api/metricspark/libs/{filename} (com.ibm.itsm.analytics.metric.service.rest.FileServiceApi)
    GET     /api/metricspark/service/environment (com.ibm.itsm.topology.service.resource.service.EnvironmentApi)
    GET     /api/metricspark/service/info (com.ibm.itsm.topology.service.resource.service.ServiceInfoResource)
    GET     /api/metricspark/servicemonitor (com.ibm.itsm.servicemonitor.api.ServiceMonitorApi)
    GET     /api/metricspark/swagger (com.ibm.itsm.topology.service.resource.swagger.SwaggerResource)
    GET     /api/metricspark/swagger.{type:json|yaml} (io.swagger.jaxrs.listing.ApiListingResource)

INFO  [2022-03-17 11:38:10,803] org.eclipse.jetty.server.handler.ContextHandler: Started i.d.j.MutableServletContextHandler@50e7667{/,null,AVAILABLE}
INFO  [2022-03-17 11:38:10,817] io.dropwizard.setup.AdminEnvironment: tasks =

    POST    /tasks/log-level (io.dropwizard.servlets.tasks.LogConfigurationTask)
    POST    /tasks/gc (io.dropwizard.servlets.tasks.GarbageCollectionTask)


{
	"_index": "postchecktrainingdetails",
	"_type": "_doc",
	"_id": "1000-1000-MetricAnomaly-v4",
	"_version": 1,
	"_seq_no": 19,
	"_primary_term": 1,
	"found": true,
	"_source": {
		"definitionName": "MetricAnomaly",
		"version": "v4",
		"postcheckStartTimestamp": "2022-03-17T17:10:42.080Z",
		"postcheckEndTimestamp": "2022-03-17T17:10:42.080Z",
		"modelsCreatedList": [
			{
				"modelId": "Metric_Anomaly_Detection_v4",
				"associatedResourceList": []
			}
		]
	}
}



TRUNCATE  tararam.dt_metric_value;
TRUNCATE  tararam.md_metric_resource;

