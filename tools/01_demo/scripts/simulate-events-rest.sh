#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# DO NOT MODIFY BELOW
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


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

echo "   ----------------------------------------------------------------------------------------------------------------------------------------"
echo "     🔐  Getting credentials"
echo "   ----------------------------------------------------------------------------------------------------------------------------------------"
export WAIOPS_NAMESPACE=$(oc get po -A|grep aiops-orchestrator-controller |awk '{print$1}')
echo "       ✅ OK - AI Manager:    $WAIOPS_NAMESPACE"
export USER_PASS="$(oc get secret aiops-ir-core-ncodl-api-secret -o jsonpath='{.data.username}' | base64 --decode):$(oc get secret aiops-ir-core-ncodl-api-secret -o jsonpath='{.data.password}' | base64 --decode)"
export DATALAYER_ROUTE=$(oc get route  -n $WAIOPS_NAMESPACE datalayer-api  -o jsonpath='{.status.ingress[0].host}')


for actFile in $(ls -1 $WORKING_DIR_EVENTS | grep "json"); 
do 

#------------------------------------------------------------------------------------------------------------------------------------
#  Prepare the Data
#------------------------------------------------------------------------------------------------------------------------------------

      echo "      ------------------------------------------------------------------------------------------------------------------------------------"
      echo "       🌏  Injecting Event Data from File: ${actFile}" 
      echo "           Quit with Ctrl-Z"
      echo "      ------------------------------------------------------------------------------------------------------------------------------------"


      EVENTS_SECONDS=10

      while IFS= read -r line
      do
            ((EVENTS_SECONDS++))
            EVENTS_SECONDS=$((EVENTS_SECONDS+60))
            EVENTS_SECONDS_SKEW="-v+"$EVENTS_SECONDS"S"

            # Get timestamp in ELK format
            export my_timestamp=$(date $EVENTS_SECONDS_SKEW $DATE_FORMAT_EVENTS)".000Z"
            
            #echo $my_timestamp
            # Replace in line
            line=${line//MY_TIMESTAMP/$my_timestamp}
            line=${line//\"/\\\"}

            export c_string=$(echo "curl \"https://$DATALAYER_ROUTE/irdatalayer.aiops.io/active/v1/events\" --insecure  -X POST -u \"${USER_PASS}\" -H 'Content-Type: application/json' -H 'x-username:admin' -H 'x-subscription-id:cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -d \"${line}\"")
            #echo "       Q:$c_string"
            export result=$(eval $c_string)
            #export result=$(curl "https://$DATALAYER_ROUTE/irdatalayer.aiops.io/active/v1/events" --insecure --silent -X POST -u "${USER_PASS}" -H 'Content-Type: application/json' -H "x-username:admin" -H "x-subscription-id:cfd95b7e-3bc7-4006-a4a8-a73a79c71255" -d "${line}")
            myId=$(echo $result|jq ".deduplicationKey")
            echo "       DONE:$myId"
            #echo "       DONE:$result"

      done < "$WORKING_DIR_EVENTS/$actFile"
      echo "          ✅ OK"
      echo " "

done


