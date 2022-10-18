#!/bin/bash

echo "Start in separate Terminal: while true; do oc port-forward statefulset/iaf-system-elasticsearch-es-aiops 9200; done"
export WAIOPS_NAMESPACE=$(oc get po -A|grep aiops-orchestrator-controller |awk '{print$1}')


oc scale deployment -l release=aiops-topology -n $WAIOPS_NAMESPACE --replicas=0
oc scale deployment aiopsedge-instana-topology-integrator -n $WAIOPS_NAMESPACE --replicas=0

oc exec -ti aiops-topology-cassandra-0 -n $WAIOPS_NAMESPACE -- bash -c "/opt/ibm/cassandra/bin/cqlsh --ssl -u \$CASSANDRA_USER -p \$CASSANDRA_PASS -e \"DROP KEYSPACE janusgraph;\""

export username=$(oc get secret $(oc get secrets | grep ibm-aiops-elastic-secret | awk '!/-min/' | awk '{print $1;}') -o jsonpath="{.data.username}"| base64 --decode)
export password=$(oc get secret $(oc get secrets | grep ibm-aiops-elastic-secret | awk '!/-min/' | awk '{print $1;}') -o jsonpath="{.data.password}"| base64 --decode)

for index in $(curl -k -u $username:$password -XGET https://localhost:9200/_cat/indices | grep -E "searchservice" | awk '{print $3;}'); do
    echo $index
done

for index in $(curl -k -u $username:$password -XGET https://localhost:9200/_cat/indices | grep -E "searchservice" | awk '{print $3;}'); do
    curl -k -u $username:$password -XDELETE "https://localhost:9200/$index"
done

for index in $(curl -k -u $username:$password -XGET https://localhost:9200/_cat/indices | grep -E "searchservice" | awk '{print $3;}'); do
    echo $index
done





oc scale deployment -l release=aiops-topology -n $WAIOPS_NAMESPACE --replicas=1
oc scale deployment aiopsedge-instana-topology-integrator -n $WAIOPS_NAMESPACE --replicas=1

oc delete job -n $WAIOPS_NAMESPACE aiops-ir-lifecycle-create-policies-job
oc delete job -n $WAIOPS_NAMESPACE aiops-ir-lifecycle-policy-registry-svc-job