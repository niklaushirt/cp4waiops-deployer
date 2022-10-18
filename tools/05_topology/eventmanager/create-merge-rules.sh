echo "Starting..."
WAIOPS_PARAMETER=$(cat ./00_config_cp4waiops.yaml|grep EVTMGR_NAMESPACE:)
EVTMGR_NAMESPACE=${WAIOPS_PARAMETER##*:}
EVTMGR_NAMESPACE=$(echo $EVTMGR_NAMESPACE|tr -d '[:space:]')


CLUSTER_ROUTE=$(oc get routes console -n openshift-console | tail -n 1 2>&1 ) 
CLUSTER_FQDN=$( echo $CLUSTER_ROUTE | awk '{print $2}')
CLUSTER_NAME=${CLUSTER_FQDN##*console.}


export EVTMGR_REST_USR=$(oc get secret evtmanager-topology-asm-credentials -n $EVTMGR_NAMESPACE -o jsonpath='{.data.username}' | base64 --decode)
export EVTMGR_REST_PWD=$(oc get secret evtmanager-topology-asm-credentials -n $EVTMGR_NAMESPACE -o jsonpath='{.data.password}' | base64 --decode)
export LOGIN="$EVTMGR_REST_USR:$EVTMGR_REST_PWD"

oc create route passthrough topology-merge -n $EVTMGR_NAMESPACE --insecure-policy="Redirect" --service=evtmanager-topology-merge --port=https-merge-api

echo "Wait 10 seconds"
sleep 10

echo "URL: https://topology-merge-$EVTMGR_NAMESPACE.$CLUSTER_NAME/1.0/merge/"
echo "LOGIN: $LOGIN"  




## MERGE CREATE
curl -X "POST" "https://topology-merge-$EVTMGR_NAMESPACE.$CLUSTER_NAME/1.0/merge/rules?ruleType=matchTokensRule" --insecure \
     -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' \
     -H 'content-type: application/json' \
     -u $LOGIN \
     -d $'{
  "tokens": [
    "name"
  ],
  "entityTypes": [
    "deployment"
  ],
  "providers": [
    "*"
  ],
  "observers": [
    "*"
  ],
  "ruleType": "mergeRule",
  "name": "merge-name-type",
  "ruleStatus": "enabled"
}'



curl "https://topology-merge-$EVTMGR_NAMESPACE.$CLUSTER_NAME/1.0/merge/rules?ruleType=mergeRule&_include_count=false&_field=*" --insecure \
     -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' \
     -u $LOGIN


