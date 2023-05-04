

export sleepSecondsBetweenEvents=1
export restEvent1='{ "id": "1a2a6787-59ad-4acd-bd0d-46c1ddfd8e00", "occurrenceTime": "MY_TIMESTAMP", "summary": "Transactions per Second on component payment below threshold (100 TPS)                                              ", "severity": 3, "type": { "eventType": "problem", "classification": "Recurring" }, "expirySeconds": 60, "links": [ { "linkType": "webpage", "name": "Recurring", "description": "Recurring", "url": "https://pirsoscom.github.io/git-commit-mysql-vm.html" } ], "sender": { "type": "host", "name": "Instana", "sourceId": "kubernetes", "application": "robot-shop" }, "resource": { "type": "host", "name": "payment", "sourceId": "kubernetes" }, "details": { "event": "performance", "component": "payment", "rule": "tps below 100" }} '
export restEvent2='{ "id": "1a2a6787-59ad-4acd-bd0d-46c1ddfd8e01", "occurrenceTime": "MY_TIMESTAMP", "summary": "MySQL - change detected - The value **resources/limits** has changed                                                ", "severity": 4, "type": { "eventType": "problem", "classification": "Instana Change" }, "expirySeconds": 6000000, "links": [ { "linkType": "webpage", "name": "Instana", "description": "Instana", "url": "https://pirsoscom.github.io/INSTANA_CHANGE_ROB.html" } ], "sender": { "type": "host", "name": "Instana", "sourceId": "kubernetes", "application": "robot-shop" }, "resource": { "type": "host", "name": "payment", "sourceId": "kubernetes", "ipAddress": "9.123.123.1", "service": "robot-shop",  "interface": "eth0", "application": "robot-shop",  "location": "Dallas 10", "accessScope": "default" }, "details": {  }}'
echo ""
echo ""
echo ""
echo ""
echo ""
echo "         ________  __  ___     ___    ________       "     
echo "        /  _/ __ )/  |/  /    /   |  /  _/ __ \____  _____"
echo "        / // __  / /|_/ /    / /| |  / // / / / __ \/ ___/"
echo "      _/ // /_/ / /  / /    / ___ |_/ // /_/ / /_/ (__  ) "
echo "     /___/_____/_/  /_/    /_/  |_/___/\____/ .___/____/  "
echo "                                           /_/            "
echo ""
echo ""
echo ""
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo ""
echo " 🚀  CP4WAIOPS Simulate Event Flood for $APP_NAME"
echo ""
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"



echo " "
echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   🚀  Initializing..."
echo "   ------------------------------------------------------------------------------------------------------------------------------"
export WAIOPS_NAMESPACE=$(oc get po -A|grep aiops-orchestrator-controller |awk '{print$1}')
echo "       ✅ OK - CP4WAIOps:    $WAIOPS_NAMESPACE"
export USER_PASS="$(oc get -n $WAIOPS_NAMESPACE secret aiops-ir-core-ncodl-api-secret -o jsonpath='{.data.username}' | base64 --decode):$(oc get  -n $WAIOPS_NAMESPACE secret aiops-ir-core-ncodl-api-secret -o jsonpath='{.data.password}' | base64 --decode)"
export DATALAYER_ROUTE=$(oc get route  -n $WAIOPS_NAMESPACE datalayer-api  -o jsonpath='{.status.ingress[0].host}')

export DATE_FORMAT_EVENTS="+%Y-%m-%dT%H:%M:%S"

echo "   ----------------------------------------------------------------------------------------------------------------------------------------"
echo "     🔎  Parameters for Incident Simulation for $APP_NAME"
echo "   ----------------------------------------------------------------------------------------------------------------------------------------"
echo "     "
echo "       🌏 DATALAYER_ROUTE             : $DATALAYER_ROUTE"
echo "       🔐 USER_PASS                   : $USER_PASS"
echo "     "
echo "   ----------------------------------------------------------------------------------------------------------------------------------------"
echo "   "
echo "   "


#------------------------------------------------------------------------------------------------------------------------------------
#  Launch Injection
#------------------------------------------------------------------------------------------------------------------------------------
echo "   "
echo "   "
echo "   "
echo "   "
echo "   ----------------------------------------------------------------------------------------------------------------------------------------"
echo "    🚀  Launching Event Injection" 
echo "   ----------------------------------------------------------------------------------------------------------------------------------------"


echo "      ------------------------------------------------------------------------------------------------------------------------------------"
echo "       🌏  Injecting Event Data: ${restEvents}" 
echo "           Quit with Ctrl-Z"
echo "      ------------------------------------------------------------------------------------------------------------------------------------"



while true
do

    # Get timestamp in ELK format
    export my_timestamp=$(date $DATE_FORMAT_EVENTS)".000Z"
    echo "Event at $(date)"
    #echo $my_timestamp
    # Replace in line
    export line=${restEvent1//MY_TIMESTAMP/$my_timestamp}
    export line=${line//\"/\\\"}

    export c_string=$(echo "curl \"https://$DATALAYER_ROUTE/irdatalayer.aiops.io/active/v1/events\" --insecure --silent -X POST -u \"${USER_PASS}\" -H 'Content-Type: application/json' -H 'x-username:admin' -H 'x-subscription-id:cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -d \"${line}\"")
    #echo "       Q:$c_string"
    export result=$(eval $c_string)
    #export result=$(curl "https://$DATALAYER_ROUTE/irdatalayer.aiops.io/active/v1/events" --insecure --silent -X POST -u "${USER_PASS}" -H 'Content-Type: application/json' -H "x-username:admin" -H "x-subscription-id:cfd95b7e-3bc7-4006-a4a8-a73a79c71255" -d "${line}")
    myId=$(echo $result|jq -r ".deduplicationKey")
    echo "   $myId"
    #echo "       DONE:$result"
    sleep $sleepSecondsBetweenEvents
done

exit 1

oc delete pod $(oc get po -n cp4waiops|grep cp4waiops-eventprocessor|awk '{print$1}') -n cp4waiops --ignore-not-found


