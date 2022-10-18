
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# SIMULATE INCIDENT ON ROBOTSHOP
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



export APP_NAME=robot-shop
export LOG_TYPE=elk   # humio, elk, splunk, ...
export EVENTS_TYPE=noi
export EVENTS_SKEW="-120M"
export LOGS_SKEW="-110M"
export METRICS_SKEW="+5M"

#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# DO NOT MODIFY BELOW
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
clear

echo ""
echo ""
echo ""
echo ""
echo ""
echo "   __________  __ ___       _____    ________            "
echo "  / ____/ __ \/ // / |     / /   |  /  _/ __ \____  _____"
echo " / /   / /_/ / // /| | /| / / /| |  / // / / / __ \/ ___/"
echo "/ /___/ ____/__  __/ |/ |/ / ___ |_/ // /_/ / /_/ (__  ) "
echo "\____/_/      /_/  |__/|__/_/  |_/___/\____/ .___/____/  "
echo "                                          /_/            "
echo ""
echo ""
echo ""
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo ""
echo " 🚀  CP4WAIOPS Close Incidents and Stories"
echo ""
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"


# Get Namespace from Cluster 
echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "    🔬 Getting Installation Namespace"
echo "   ------------------------------------------------------------------------------------------------------------------------------"

export WAIOPS_NAMESPACE=$(oc get po -A|grep aiops-orchestrator-controller |awk '{print$1}')
echo "       ✅ OK - AI Manager:    $WAIOPS_NAMESPACE"



# Define Log format
export log_output_path=/dev/null 2>&1
export TYPE_PRINT="📝 "$(echo $TYPE | tr 'a-z' 'A-Z')


#------------------------------------------------------------------------------------------------------------------------------------
#  Check Defaults
#------------------------------------------------------------------------------------------------------------------------------------

if [[ $APP_NAME == "" ]] ;
then
      echo " ⚠️ AppName not defined. Launching this script directly?"
      echo "    Falling back to $DEFAULT_APP_NAME"
      export APP_NAME=$DEFAULT_APP_NAME
fi

if [[ $LOG_TYPE == "" ]] ;
then
      echo " ⚠️ Log Type not defined. Launching this script directly?"
      echo "    Falling back to humio"
      export LOG_TYPE=elk
fi

if [[ $EVENTS_TYPE == "" ]] ;
then
      echo " ⚠️ Event Type not defined. Launching this script directly?"
      echo "    Falling back to noi"
      export LOG_TYPE=noi
fi

oc project $WAIOPS_NAMESPACE  >/tmp/demo.log 2>&1  || true


export USER_PASS="$(oc get secret aiops-ir-core-ncodl-api-secret -o jsonpath='{.data.username}' | base64 --decode):$(oc get secret aiops-ir-core-ncodl-api-secret -o jsonpath='{.data.password}' | base64 --decode)"
oc apply -n $WAIOPS_NAMESPACE -f ./tools/01_demo/scripts/datalayer-api-route.yaml >/tmp/demo.log 2>&1  || true
sleep 2
export DATALAYER_ROUTE=$(oc get route  -n $WAIOPS_NAMESPACE datalayer-api  -o jsonpath='{.status.ingress[0].host}')



export result=$(curl "https://$DATALAYER_ROUTE/irdatalayer.aiops.io/active/v1/stories" --insecure --silent -X PATCH -u "${USER_PASS}" -d '{"state": "resolved"}' -H 'Content-Type: application/json' -H "x-username:admin" -H "x-subscription-id:cfd95b7e-3bc7-4006-a4a8-a73a79c71255")
echo "       Stories closed: "$(echo $result | jq ".affected")

#export result=$(curl "https://$DATALAYER_ROUTE/irdatalayer.aiops.io/active/v1/alerts?filter=type.classification%20%3D%20%27robot-shop%27" --insecure --silent -X PATCH -u "${USER_PASS}" -d '{"state": "closed"}' -H 'Content-Type: application/json' -H "x-username:admin" -H "x-subscription-id:cfd95b7e-3bc7-4006-a4a8-a73a79c71255")
export result=$(curl "https://$DATALAYER_ROUTE/irdatalayer.aiops.io/active/v1/alerts" --insecure --silent -X PATCH -u "${USER_PASS}" -d '{"state": "closed"}' -H 'Content-Type: application/json' -H "x-username:admin" -H "x-subscription-id:cfd95b7e-3bc7-4006-a4a8-a73a79c71255")
echo "       Alerts closed: "$(echo $result | jq ".affected")
#curl "https://$DATALAYER_ROUTE/irdatalayer.aiops.io/active/v1/alerts" -X GET -u "${USER_PASS}" -H "x-username:admin" -H "x-subscription-id:cfd95b7e-3bc7-4006-a4a8-a73a79c71255" | grep '"state": "open"' | wc -l


echo " "
echo " "
echo " "
echo " "
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo ""
echo " 🚀  Incidents and Stories closed"
echo "  ✅  Done..... "
echo ""
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"



