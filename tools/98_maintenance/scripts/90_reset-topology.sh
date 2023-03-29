#!/bin/bash

export WAIOPS_NAMESPACE=$(oc get po -A|grep aiops-orchestrator-controller |awk '{print$1}')


oc scale deployment -l release=aiops-topology -n $WAIOPS_NAMESPACE --replicas=0
oc scale deployment aiopsedge-instana-topology-integrator -n $WAIOPS_NAMESPACE --replicas=0

oc exec -ti aiops-topology-cassandra-0 -n $WAIOPS_NAMESPACE -- bash -c "/opt/ibm/cassandra/bin/cqlsh --ssl -u \$CASSANDRA_USER -p \$CASSANDRA_PASS -e \"DROP KEYSPACE janusgraph;\""


 sleep 10

PGPASSWORD=$(oc get secret aiops-topology-postgres-user -o jsonpath="{.data.password}"| base64 --decode)

 # Clear out the inventory data
 oc exec -it ibm-cp-watson-aiops-edb-postgres-1 -- /bin/bash -c 'export PGPASSWORD='$PGPASSWORD' && psql --host localhost --username aiops_topology_user --dbname aiops_topology --command "DO \
 \$\$ \
 BEGIN \
     EXECUTE (SELECT '\''TRUNCATE TABLE '\'' \
         || string_agg(format('\''%I.%I'\'', schemaname, tablename), '\'', '\'') \
         || '\'' CASCADE'\'' \
     FROM   pg_tables \
     WHERE    schemaname = '\''public'\'' \
     AND NOT tablename = '\''flyway_schema_history'\'' \
     ); \
 END \
 \$\$;"'

 sleep 30

 # Scale the core services back up
oc scale deployment -l release=aiops-topology -n $WAIOPS_NAMESPACE --replicas=1
oc scale deployment aiopsedge-instana-topology-integrator -n $WAIOPS_NAMESPACE --replicas=1

oc delete job -n $WAIOPS_NAMESPACE aiops-ir-lifecycle-create-policies-job
oc delete job -n $WAIOPS_NAMESPACE aiops-ir-lifecycle-policy-registry-svc-job


 echo "waiting for a while for pods to start up"
 sleep 120

 oc get pod|egrep "topology|cassandra"