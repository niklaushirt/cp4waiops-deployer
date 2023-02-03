

oc rsh -n cp4waiops $(oc get po -n cp4waiops|grep aimanager-aio-ai-platform-api-server|awk '{print$1}')  

./elastic.sh -X DELETE -E trainingdefinition/_doc/MetricAnomaly


