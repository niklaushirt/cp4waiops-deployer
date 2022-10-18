echo "Create Rules - Starting..."
export WAIOPS_NAMESPACE=$(oc get po -A|grep aiops-orchestrator-controller |awk '{print$1}')
export EVTMGR_NAMESPACE=$(oc get po -A|grep noi-operator |awk '{print$1}')





export EVTMGR_REST_USR=$(oc get secret aiops-topology-asm-credentials -n $WAIOPS_NAMESPACE -o jsonpath='{.data.username}' | base64 --decode)
export EVTMGR_REST_PWD=$(oc get secret aiops-topology-asm-credentials -n $WAIOPS_NAMESPACE -o jsonpath='{.data.password}' | base64 --decode)
export LOGIN="$EVTMGR_REST_USR:$EVTMGR_REST_PWD"

oc delete route  topology-merge -n $WAIOPS_NAMESPACE
oc create route reencrypt topology-merge -n $WAIOPS_NAMESPACE --insecure-policy="Redirect" --service=aiops-topology-merge --port=https-merge-api
export MERGE_ROUTE="https://"$(oc get route -n $WAIOPS_NAMESPACE topology-merge -o jsonpath={.spec.host})


echo "URL: $MERGE_ROUTE/1.0/merge/"
echo "LOGIN: $LOGIN"


echo "Wait 5 seconds"
sleep 5

echo "Create Merge RULE..."

## MERGE CREATE
curl -X "POST" "$MERGE_ROUTE/1.0/merge/rules" --insecure \
     -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' \
     -H 'content-type: application/json' \
     -u $LOGIN \
     -d $'{
     "name": "MatchTokenDeployName",
    "ruleType": "matchTokensRule",
    "entityTypes": ["deployment"],
    "tokens": ["name"],
    "ruleStatus": "enabled",
    "observers": ["*"],
    "providers": ["*"]
}'

## MERGE CREATE
curl -X "POST" "$MERGE_ROUTE/1.0/merge/rules" --insecure \
     -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' \
     -H 'content-type: application/json' \
     -u $LOGIN \
     -d $'{
     "name": "MergeTokenDeployName",
    "ruleType": "mergeRule",
    "entityTypes": ["deployment"],
    "tokens": ["name"],
    "ruleStatus": "enabled",
    "observers": ["*"],
    "providers": ["*"]
}'



echo "Disable RULE k8ServiceName..."

export RULE_ID=$(curl "$MERGE_ROUTE/1.0/merge/rules?ruleType=matchTokensRule&_filter=name=k8ServiceName&_include_count=false&_field=*" -s --insecure \
     -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' \
     -u $LOGIN| jq -r "._items[0]._id")



curl -XPUT "$MERGE_ROUTE/1.0/merge/rules/$RULE_ID" -s --insecure \
    --header 'Content-Type: application/json' \
    --header 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' \
    -u $LOGIN \
    -d '{
      "name": "k8ServiceName",
      "keyIndexName": "k8ServiceName",
      "ruleType": "matchTokensRule",
      "entityTypes": [
        "service"
      ],
      "tokens": [
        "name"
      ],
      "ruleStatus": "disabled",
      
      "observers": [
        "kubernetes-observer"
      ],
      "providers": [
        "*"
      ]
    }' 