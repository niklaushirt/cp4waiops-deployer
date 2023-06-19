
echo "------------------------------------------------------------------------------------------------------------------------------"
echo " 📥 Initialization"

export TURBO_PASSWORD=CHANGEME
export WORKFLOW_NAME="EDA_WEBHOOK"

export EDA_URL=$(oc get route -n eda eda-instance -o jsonpath={.spec.host})
echo "    🌏 EDA_URL:   $EDA_URL"



export TURBO_URL=$(oc get route -n turbonomic nginx -o jsonpath={.spec.host})
echo "    🌏 TURBO_URL: $TURBO_URL"
echo ""

echo "------------------------------------------------------------------------------------------------------------------------------"
echo " 📥 Login to Turbo"
export result=$(curl -XPOST -s -k -c /tmp/cookies -H 'accept: application/json' "https://$TURBO_URL/api/v3/login?disable_hateoas=true" -d "username=administrator&password=$TURBO_PASSWORD")
echo $result

echo "------------------------------------------------------------------------------------------------------------------------------"
echo " 📥 Get Existing Workflows"
export workflows=$(curl -XGET -s -k "https://$TURBO_URL/api/v3/workflows" -b /tmp/cookies  -H 'Content-Type: application/json;' -H 'accept: application/json')
echo $workflows|jq
echo ""
echo ""
echo ""

echo "------------------------------------------------------------------------------------------------------------------------------"
echo " 📥 Get Existing EDA Workflow"
export existingWorkflow=$(echo $workflows|jq  '.[]|select(.displayName | contains("'$WORKFLOW_NAME'"))'| jq -r ".uuid")

if [[ $existingWorkflow != "" ]] ;
then
    echo "   ✅ Webhook already exists."
    #curl -XDELETE -s -k "https://$TURBO_URL/api/v3/workflows/$existingWorkflow" -b /tmp/cookies  -H 'Content-Type: application/json;' -H 'accept: application/json'
    WF_ID=$existingWorkflow
else
    echo "------------------------------------------------------------------------------------------------------------------------------"
    echo " ❌ Workflow not defined! Aborting"
    exit 1
fi


echo "------------------------------------------------------------------------------------------------------------------------------"
echo " 📥 Actions for RobotShop"
export robotshop_id=$(curl -XGET -s -k "https://$TURBO_URL/api/v3/search?types=BusinessApplication" -b /tmp/cookies  -H 'Content-Type: application/json;' -H 'accept: application/json'|jq '.[]|select(.displayName | contains("RobotShop"))'|jq -r ".uuid")
#echo $robotshop_id
#curl -XGET -s -k "https://$TURBO_URL/api/v3/entities/$robotshop_id/actions?limit=500&cursor=0" -b /tmp/cookies  -H 'Content-Type: application/json;' -H 'accept: application/json'|jq ".[].uuid"
export actions1=$(curl -XGET -s -k "https://$TURBO_URL/api/v3/entities/$robotshop_id/actions?limit=500&cursor=0" -b /tmp/cookies  -H 'Content-Type: application/json;' -H 'accept: application/json')
echo $actions1|jq ".[].details"


echo "------------------------------------------------------------------------------------------------------------------------------"
echo " 📥 Actions for VMs"
export apiSearch=$(curl -XGET -s -k "https://$TURBO_URL/api/v3/search?types=Group" -d '{"className": "VirtualMachine"}' -b /tmp/cookies  -H 'Content-Type: application/json;' -H 'accept: application/json'|jq)
#echo $apiSearch
#echo $apiSearch|jq '.[].displayName'

export entity_id=$(echo $apiSearch|jq '.[]|select(.displayName | contains("vSphere VMs"))'|jq -r ".uuid")
#echo $entity_id
export actions2=$(curl -XGET -s -k "https://$TURBO_URL/api/v3/entities/$entity_id/actions?limit=500&cursor=0" -b /tmp/cookies  -H 'Content-Type: application/json;' -H 'accept: application/json')
echo $actions2|jq ".[].details"






export actionID_resize=$(echo $actions1|jq  '.[]|select(.actionType | contains("RESIZE"))'|jq  'select(.target.displayName | contains("catalogue"))'| jq -r ".uuid")
#echo $actionID_resize
export actionID_notresize=$(echo $actions1|jq  '[.[]|select(.actionType | contains("RESIZE")| not)][0]'| jq -r ".uuid")
#echo $actionID_notresize

echo "------------------------------------------------------------------------------------------------------------------------------"
echo " 📥 Test Event Catalogue through Turbonomic"
echo "curl -XPOST -s -k 'https://$TURBO_URL/api/v3/workflows/$WF_ID' -b /tmp/cookies  -H 'Content-Type: application/json;' -H 'accept: application/json' -d ' {\"operation\": \"TEST\",\"actionId\": $actionID_resize}'"
echo ""

echo " 📥 Test Event Other through Turbonomic"
echo "curl -XPOST -s -k 'https://$TURBO_URL/api/v3/workflows/$WF_ID' -b /tmp/cookies  -H 'Content-Type: application/json;' -H 'accept: application/json' -d ' {\"operation\": \"TEST\",\"actionId\": $actionID_notresize}'"
echo ""






export actionID_resize=$(echo $actions2|jq  '.[]|select(.actionType | contains("RESIZE"))'| jq -r ".uuid"|head -n 1)
#echo $actionID_resize
export actionID_reconfigure=$(echo $actions2|jq  '.[]|select(.actionType | contains("RECONFIGURE"))'| jq -r ".uuid"|head -n 1)
#echo $actionID_reconfigure
export actionID_notresize=$(echo $actions2|jq  '[.[]|select(.actionType | contains("RECONFIGURE")| not)]'|jq  '[.[]|select(.actionType | contains("RESIZE")| not)][0]'| jq -r ".uuid")
#echo $actionID_notresize



echo "------------------------------------------------------------------------------------------------------------------------------"
echo " 📥 Test Event VM Resize through Turbonomic"
echo "curl -XPOST -s -k 'https://$TURBO_URL/api/v3/workflows/$WF_ID' -b /tmp/cookies  -H 'Content-Type: application/json;' -H 'accept: application/json' -d ' {\"operation\": \"TEST\",\"actionId\": $actionID_resize}'"
echo ""


echo "------------------------------------------------------------------------------------------------------------------------------"
echo " 📥 Test Event VM Reconfigure through Turbonomic"
echo "curl -XPOST -s -k 'https://$TURBO_URL/api/v3/workflows/$WF_ID' -b /tmp/cookies  -H 'Content-Type: application/json;' -H 'accept: application/json' -d ' {\"operation\": \"TEST\",\"actionId\": $actionID_reconfigure}'"
echo ""


echo "------------------------------------------------------------------------------------------------------------------------------"
echo " 📥 Test Event Resize VM direct to EDA"
echo "curl -XPOST -s -k 'http://$EDA_URL/endpoint'   -H 'Content-Type: application/json;' -H 'accept: application/json' -d @./example_messages/turbo_webhook1.json"
echo ""



echo "------------------------------------------------------------------------------------------------------------------------------"
echo " 📥 Test Event Resize Catalogue Deployment direct to EDA"
echo "curl -XPOST -s -k 'http://$EDA_URL/endpoint'   -H 'Content-Type: application/json;' -H 'accept: application/json' -d @./example_messages/turbo_webhook1.json"
echo ""

echo ""
echo "------------------------------------------------------------------------------------------------------------------------------"
echo " 🧻 Delete Turbonomic Workflow Webhook"
echo "curl -XDELETE -s -k 'https://$TURBO_URL/api/v3/workflows/$WF_ID' -b /tmp/cookies  -H 'Content-Type: application/json;' -H 'accept: application/json'"
echo ""

