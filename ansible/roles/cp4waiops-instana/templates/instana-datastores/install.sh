oc create namespace instana-datastores
oc apply -f ./zookeeper-operator.yaml
oc apply -f ./zookeeper-instance.yaml
oc apply -f ./kafka-operator.yaml
oc apply -f ./kafka-instance.yaml
oc apply -f ./elasticsearch-operator.yaml
oc apply -f ./elasticsearch-instance.yaml
oc apply -f ./postgres-operator.yaml
oc apply -f ./postgres-scc.yaml
oc apply -f ./postgres-instance.yaml
oc apply -f ./cassandra-operator.yaml
oc apply -f ./cassandra-scc.yaml
oc apply -f ./cassandra-instance.yaml
oc apply -f ./clickhouse-operator.yaml
oc apply -f ./clickhouse-instance.yaml


oc delete -f ./zookeeper-operator.yaml
oc delete -f ./zookeeper-instance.yaml
oc delete -f ./kafka-operator.yaml
oc delete -f ./kafka-instance.yaml
oc delete -f ./elasticsearch-operator.yaml
oc delete -f ./elasticsearch-instance.yaml
oc delete -f ./postgres-operator.yaml
oc delete -f ./postgres-scc.yaml
oc delete -f ./postgres-instance.yaml
oc delete -f ./cassandra-operator.yaml
oc delete -f ./cassandra-scc.yaml
oc delete -f ./cassandra-instance.yaml
oc delete -f ./clickhouse-operator.yaml
oc delete -f ./clickhouse-instance.yaml

oc apply -f ./zookeeper-operator.yaml
oc apply -f ./zookeeper-instance.yaml
oc apply -f ./zookeeper-operator.yaml
oc apply -f ./zookeeper-instance.yaml
oc apply -f ./zookeeper-operator.yaml
oc apply -f ./zookeeper-instance.yaml
oc apply -f ./zookeeper-operator.yaml



oc apply -f 01_cert-manager.yaml

sleep 15
oc create clusterrolebinding instana-cert-manager-admin --clusterrole=cluster-admin --serviceaccount=cert-manager:cert-manager
oc create clusterrolebinding instana-cert-manager-cainjector-admin --clusterrole=cluster-admin --serviceaccount=cert-manager:cert-manager-cainjector
oc create clusterrolebinding instana-cert-manager-webhook-admin --clusterrole=cluster-admin --serviceaccount=cert-manager:cert-manager-webhook



# Zookeeper Operator installation
helm repo add pravega https://charts.pravega.io
helm repo update
#helm install instana -n instana-zookeeper  pravega/zookeeper-operator --version=0.2.14
helm template instana -n instana-datastores  pravega/zookeeper-operator --version=0.2.14 > zookeeper-operator.yaml
# Apply deployment
kubectl apply -f zookeeper/operator/manifests/instana-zookeeper.yaml -n instana-clickhouse



# Strimzi Operator installation
helm repo add strimzi https://strimzi.io/charts/
helm repo update
helm template strimzi strimzi/strimzi-kafka-operator --version 0.30.0 -n instana-datastores  > kafka-operator.yaml
# Apply deployment
kubectl apply -f kafka/operator/manifests/instana-kafka.yaml -n instana-kafka
kubectl wait kafka/instana --for=condition=Ready --timeout=300s -n instana-kafka



# Elasticsearch (ECK) Operator installation
helm repo add elastic https://helm.elastic.co
helm repo update
helm template elastic-operator elastic/eck-operator -n instana-datastores --version=2.5.0 > elasticsearch-operator.yaml
# Apply deployment
kubectl apply -f elasticsearch/operator/manifests/instana-elasticsearch.yaml -n instana-elastic


# Postgres operator installation
helm repo add postgres https://opensource.zalando.com/postgres-operator/charts/postgres-operator
helm repo update
helm template postgres-operator postgres/postgres-operator  --version=1.9.0 --set configGeneral.kubernetes_use_configmaps=true --set securityContext.runAsUser=101 --namespace=instana-datastores > postgres-operator.yaml
# Security Context Constraints, needed if you are running on RedHat OpenShift
kubectl apply -f postgres/operator/manifests/base/postgres_scc.yaml
# Apply deployment
kubectl apply -k postgres/operator/manifests/no-auth --namespace=instana-postgres





helm repo add k8ssandra https://helm.k8ssandra.io/stable
helm repo update
helm install cass-operator k8ssandra/cass-operator -n instana-datastores --create-namespace --version=0.40.0 --set securityContext.runAsGroup=999 --set securityContext.runAsUser=999

# Cass Operator installation
helm repo add k8ssandra https://helm.k8ssandra.io/stable
helm repo update
# Install Cass Operator with uid=999
#helm template cass-operator k8ssandra/cass-operator -n instana-datastores  --version=0.40.0 --set securityContext.runAsGroup=999 --set securityContext.runAsUser=999 > cassandra-operator.yaml
helm template cass-operator k8ssandra/cass-operator -n instana-datastores  --version=0.40.0 --set securityContext.runAsGroup=999 --set securityContext.runAsUser=999  -a cert-manager.io/v1 > cassandra-operator.yaml
# Security Context Constraints, needed if you are running on RedHat OpenShift
kubectl apply -f cassandra/operator/manifests/cassandra_scc.yaml
# Apply deployment
kubectl apply -f cassandra/operator/manifests/instana-cassandra.yaml -n instana-cassandra



# Clickhouse Operator installation
curl --silent https://raw.githubusercontent.com/Altinity/clickhouse-operator/0.19.1/deploy/operator/clickhouse-operator-install-bundle.yaml | sed 's|kube-system|instana-clickhouse|g' | kubectl apply --filename -
# Image pull secrets for Clickhouse image
kubectl create secret docker-registry clickhouse-image-secret \
  --namespace=instana-clickhouse \
  --docker-username=_ \
  --docker-password=<agent_key> \
  --docker-server=containers.instana.io
# Apply deployment
kubectl apply -f clickhouse/operator/manifests/instana-clickhouse.yaml -n instana-clickhouse