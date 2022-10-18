
export APP_NAME=robot-shop
export INDEX_TYPE=logs


#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# DO NOT EDIT BELOW
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



if [[  $WAIOPS_NAMESPACE =~ "" ]]; then
    # Get Namespace from Cluster 
    echo "   ------------------------------------------------------------------------------------------------------------------------------"
    echo "   🔬 Getting Installation Namespace"
    echo "   ------------------------------------------------------------------------------------------------------------------------------"
    export WAIOPS_NAMESPACE=$(oc get po -A|grep aiops-orchestrator-controller |awk '{print$1}')
    echo "       ✅ AI Manager:         OK - $WAIOPS_NAMESPACE"
else
    echo "       ✅ AI Manager:         OK - $WAIOPS_NAMESPACE"
fi




if [[ $ROUTE =~ "ai-platform-api" ]]; then
    echo "       ✅ OK - Route:         OK"
else
    echo "       🛠️   Creating Route"
    oc create route passthrough ai-platform-api -n $WAIOPS_NAMESPACE  --service=aimanager-aio-ai-platform-api-server --port=4000 --insecure-policy=Redirect --wildcard-policy=None
    export ROUTE=$(oc get route -n $WAIOPS_NAMESPACE ai-platform-api  -o jsonpath={.spec.host})
    echo "        Route: $ROUTE"
    echo ""
fi
echo ""


if [[ $ZEN_TOKEN == "" ]]; then
      echo "       🛠️   Getting ZEN Token"
     
      ZEN_API_HOST=$(oc get route -n $WAIOPS_NAMESPACE cpd -o jsonpath='{.spec.host}')
      ZEN_LOGIN_URL="https://${ZEN_API_HOST}/v1/preauth/signin"
      LOGIN_USER=admin
      LOGIN_PASSWORD="$(oc get secret admin-user-details -n $WAIOPS_NAMESPACE -o jsonpath='{ .data.initial_admin_password }' | base64 --decode)"

      ZEN_LOGIN_RESPONSE=$(
      curl -k \
      -H 'Content-Type: application/json' \
      -XPOST \
      "${ZEN_LOGIN_URL}" \
      -d '{
            "username": "'"${LOGIN_USER}"'",
            "password": "'"${LOGIN_PASSWORD}"'"
      }' 2> /dev/null
      )

      ZEN_LOGIN_MESSAGE=$(echo "${ZEN_LOGIN_RESPONSE}" | jq -r .message)

      if [ "${ZEN_LOGIN_MESSAGE}" != "success" ]; then
      echo "Login failed: ${ZEN_LOGIN_MESSAGE}" 1>&2

      exit 2
      fi

      ZEN_TOKEN=$(echo "${ZEN_LOGIN_RESPONSE}" | jq -r .token)
      echo "${ZEN_TOKEN}"

      echo "Sucessfully logged in" 1>&2

      echo ""
fi

echo "  ***************************************************************************************************************************************************"
echo "   🛠️   Turn off RSA - Log Anomaly Statistical Baseline"
export FILE_NAME=deactivate-analysis-RSA.graphql
./tools/02_training/scripts/execute-graphql-local.sh



echo "  ***************************************************************************************************************************************************"
echo "   🛠️   Create Data Set: Log Anomaly Detection"
echo "     "	
echo "      📥 Launch Query for file: create-dataset-LAD.graphql"	
echo "     "
QUERY="$(cat ./tools/02_training/training-definitions/create-dataset-LAD.graphql)"
JSON_QUERY=$(echo "${QUERY}" | jq -sR '{"operationName": null, "variables": {}, "query": .}')
export result=$(curl -XPOST "https://$ROUTE/graphql" -k -s  -H "Authorization: bearer $ZEN_TOKEN" -H 'Content-Type: application/json' -d "${JSON_QUERY}")
export DATA_SET_ID=$(echo $result| jq -r ".data.createDataSet.dataSetId")
echo "      🔎 Result: "
echo "       "$result|jq ".data" | sed 's/^/          /'
echo "     "	
echo "     "	



echo "  ***************************************************************************************************************************************************"
echo "   🛠️   Create Analysis Definiton: Log Anomaly Detection"
echo "     "	
echo "      📥 Launch Query for file: create-analysis-LAD.graphql"	
echo "     "
QUERY_TMPL="$(cat ./tools/02_training/training-definitions/create-analysis-LAD.graphql)"
QUERY=$(echo $QUERY_TMPL | sed "s/<DATA_SET_ID>/$DATA_SET_ID/g")
JSON_QUERY=$(echo "${QUERY}" | jq -sR '{"operationName": null, "variables": {}, "query": .}')
export result=$(curl -XPOST "https://$ROUTE/graphql" -k -s  -H "Authorization: bearer $ZEN_TOKEN" -H 'Content-Type: application/json' -d "${JSON_QUERY}")
echo "      🔎 Result: "
echo "       "$result|jq ".data" | sed 's/^/          /'
echo "     "	
echo "     "	



echo "  ***************************************************************************************************************************************************"
echo "   🛠️   Run Analysis: Log Anomaly Detection"
export FILE_NAME=run-analysis-LAD.graphql
./tools/02_training/scripts/execute-graphql-local.sh


