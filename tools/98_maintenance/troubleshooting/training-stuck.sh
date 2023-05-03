

oc rsh -n cp4waiops $(oc get po -n cp4waiops|grep aimanager-aio-ai-platform-api-server|awk '{print$1}') ./elastic.sh -X DELETE -E trainingdefinition/_doc/MetricAnomaly
oc rsh -n cp4waiops $(oc get po -n cp4waiops|grep aimanager-aio-ai-platform-api-server|awk '{print$1}') ./elastic.sh -X DELETE -E trainingstatus/_doc/MetricAnomaly



oc rsh -n cp4waiops $(oc get po -n cp4waiops|grep aimanager-aio-ai-platform-api-server|awk '{print$1}') ./elastic.sh -X DELETE -E trainingdefinition/_doc/metric_anomaly_detection_configuration






oc rsh -n cp4waiops $(oc get po -n cp4waiops|grep aimanager-aio-ai-platform-api-server|awk '{print$1}')  

./elastic.sh -X DELETE -E trainingdefinition/_doc/MetricAnomaly



<<comment
This script can be used on production envs to easily curl
Elastic and not have to constantly get the username/password combination
comment

while getopts X:E: flag
do
    case "${flag}" in
        X) type=${OPTARG};;
        E) endpoint="$ES_URL/${OPTARG}";;
    esac
done



















oc rsh -n cp4waiops $(oc get po -n cp4waiops|grep aimanager-aio-ai-platform-api-server|awk '{print$1}')  



usr=$(cat "$ELASTIC_SECRET_PATH/username")
pwd=$(cat "$ELASTIC_SECRET_PATH/password")


endpoint="$ES_URL/trainingstatus/_delete_by_query"
curl -XPOST -k -u $usr:$pwd $endpoint -H 'Content-Type: application/json' -d '
{
  "query": {
    "match": {
      "name":"MetricAnomaly"
    }
  }
}'


endpoint="$ES_URL/postchecktrainingdetails/_delete_by_query"
curl -XPOST -k -u $usr:$pwd $endpoint -H 'Content-Type: application/json' -d '
{
  "query": {
    "match": {
      "definitionName":"MetricAnomaly"
    }
  }
}'



endpoint="$ES_URL/precheckrun/_delete_by_query"
curl -XPOST -k -u $usr:$pwd $endpoint -H 'Content-Type: application/json' -d '
{
  "query": {
    "match": {
      "definitionName":"MetricAnomaly"
    }
  }
}'


endpoint="$ES_URL/prechecktrainingdetails/_delete_by_query"
curl -XPOST -k -u $usr:$pwd $endpoint -H 'Content-Type: application/json' -d '
{
  "query": {
    "match": {
      "definitionName":"MetricAnomaly"
    }
  }
}'


endpoint="$ES_URL/trainingrun/_delete_by_query"
curl -XPOST -k -u $usr:$pwd $endpoint -H 'Content-Type: application/json' -d '
{
  "query": {
    "match": {
      "definitionName":"MetricAnomaly"
    }
  }
}'


endpoint="$ES_URL/trainingsrunning/_delete_by_query"
curl -XPOST -k -u $usr:$pwd $endpoint -H 'Content-Type: application/json' -d '
{
  "query": {
    "match": {
      "definitionName":"MetricAnomaly"
    }
  }
}'


endpoint="$ES_URL/trainingstatus/_delete_by_query"
curl -XPOST -k -u $usr:$pwd $endpoint -H 'Content-Type: application/json' -d '
{
  "query": {
    "match": {
      "name":"MetricAnomaly"
    }
  }
}'


