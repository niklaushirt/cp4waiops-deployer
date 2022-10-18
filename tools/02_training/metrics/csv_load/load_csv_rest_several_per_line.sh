#!/bin/bash

# Path to the CSV file
export CSV_FILE=./CSV_LOAD_SEVERAL_METRICS_PER_LINE.csv

# Position of parameters in the the CSV file
TIMESTAMP_POSITION=0
RESOURCE_ID_POSITION=0
# Set to a string if no group id in csv
GROUP_ID_POSITION=DEMO

# Format of the timestamp in the CSV file
export FORMAT_TIMESTAMP="%Y-%m-%d_%H:%M:%S"







#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# DO NOT MODIFY BELOW
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo ""
echo "   __________  __ ___       _____    ________            "
echo "  / ____/ __ \/ // / |     / /   |  /  _/ __ \____  _____"
echo " / /   / /_/ / // /| | /| / / /| |  / // / / / __ \/ ___/"
echo "/ /___/ ____/__  __/ |/ |/ / ___ |_/ // /_/ / /_/ (__  ) "
echo "\____/_/      /_/  |__/|__/_/  |_/___/\____/ .___/____/  "
echo "                                   /_/            "
echo ""

echo "  "
echo "  🚀 CloudPak for Watson AIOps - LOAD METRICS CSV (Several metrics per line)"
echo "  "
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo "  "
echo "  "

#Max lines per REST Call
export MAX_LINES_PER_CALL=500

export regexp_number='^[0-9]+$'

echo " "
echo " "
echo " "
echo " "
echo " ----------------------------------------------------------------------------------------------------------------------------------------"
echo "   🚀  Bulk inject Metrics CSV via REST"
echo " ----------------------------------------------------------------------------------------------------------------------------------------"
echo " "
echo " "
#--------------------------------------------------------------------------------------------------------------------------------------------	
#  Check Credentials	
#--------------------------------------------------------------------------------------------------------------------------------------------	

echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "    🗄️  File to be loaded from $CSV_FILE"	
echo "   ------------------------------------------------------------------------------------------------------------------------------"
if [[ ! -f "$CSV_FILE" ]]; then 
      echo "      ❌ File does not exist. $(pwd)$CSV_FILE"
      echo "      ❌ Aborting...."
      exit 1
else
      echo " "
      echo "      ✅ File exists "
fi

echo "       "	
echo "       "	
echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "    🔎  First line of file"	
echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   "
line=$(head -n 1 $CSV_FILE)
line_elements=($(echo $line | tr "," "\n"))


echo "      $line"
echo "   "
echo "   "

echo "   ----------------------------------------------------------------------------------------------------------------------------------------"
echo "    📥  Defined Mapping"
echo "   ----------------------------------------------------------------------------------------------------------------------------------------"
echo "   "



READABLE_TIMESTAMP=${line_elements[$TIMESTAMP_POSITION]}
echo "      🕦 READABLE_TIMESTAMP:     $READABLE_TIMESTAMP"
export MY_TIMESTAMP=$(date -j -f "$FORMAT_TIMESTAMP" "$READABLE_TIMESTAMP" +"%s" )
echo "      ⏳ REST_TIMESTAMP:         $MY_TIMESTAMP"

# Get Parameters
MY_RESOURCE_ID=${line_elements[$RESOURCE_ID_POSITION]}
echo "      📥 MY_RESOURCE_ID:         $MY_RESOURCE_ID"

echo "      🔢 METRIC_NAME:            DEFINED IN CODE"

echo "      ＄ CURRENT_VALUE:          DEFINED IN CODE"

if [[ $GROUP_ID_POSITION =~ $regexp_number ]] ; then
      MY_GROUP_ID=${line_elements[$GROUP_ID_POSITION]}
else            
      MY_GROUP_ID="DEMO"
fi
echo "      🎳 GROUP ID:               $MY_GROUP_ID"


echo "   "
echo "   "
echo "   "
echo "   ----------------------------------------------------------------------------------------------------------------------------------------"
echo "    🔐  Getting credentials"
echo "   ----------------------------------------------------------------------------------------------------------------------------------------"
export WAIOPS_NAMESPACE=$(oc get po -A|grep aiops-orchestrator-controller |awk '{print$1}')

oc project $WAIOPS_NAMESPACE >/dev/null 2>/dev/null

export ROUTE=$(oc get route | grep ibm-nginx-svc | awk '{print $2}')
PASS=$(oc get secret admin-user-details -o jsonpath='{.data.initial_admin_password}' | base64 -d)
export TOKEN=$(curl -k -s -X POST https://$ROUTE/icp4d-api/v1/authorize -H 'Content-Type: application/json' -d "{\"username\": \"admin\",\"password\": \"$PASS\"}" | jq .token | sed 's/\"//g')
if [[ "$TOKEN" == "" ]]; then 
      echo "      ❌ Could not connect to Metrics REST API"
      echo "      ❌ Aborting...."
      exit 1
fi
echo "   "
echo "      🌏 ROUTE:                  $ROUTE"
echo "      🔐 TOKEN:                  ${TOKEN:0:50}..."




echo ""
echo ""
echo ""
echo "   -------------------------------------------------------------------------------------------------------------------------------------"
echo "    🌏  Injecting Metrics Data" 
echo "         Quit with Ctrl-Z"
echo "   -------------------------------------------------------------------------------------------------------------------------------------"
echo ""

LINES_READ=0
ITERATION=1
echo '{"groups":['> /tmp/tmp_inject.json
echo "      -------------------------------------------------------------------------------------------------------------------------------------"
echo "       📂 Preparing injection ($ITERATION)"
echo ""

while IFS= read -r line
do
      actLine=$(echo $line)
      if [[ ! $actLine == "" ]];
      then
            ((LINES_READ++))

            # Split elements from line
            export line_elements=($(echo $actLine | tr "," "\n"))

            #echo " - "$LINES_READ"::"$READABLE_TIMESTAMP
            printf "\r         - "$LINES_READ/$MAX_LINES_PER_CALL"::"$READABLE_TIMESTAMP"                                        "






            #--------------------------------------------------------------------------------------------------------------------------------------------
            #  Handle common values
            #--------------------------------------------------------------------------------------------------------------------------------------------
            # Convert Timestamp
            READABLE_TIMESTAMP=${line_elements[$TIMESTAMP_POSITION]}
            export MY_TIMESTAMP=$(date -j -f "$FORMAT_TIMESTAMP" "$READABLE_TIMESTAMP" +"%s")"000"
           
            # Get Parameters
            MY_RESOURCE_ID=${line_elements[$RESOURCE_ID_POSITION]}
            if [[ $GROUP_ID_POSITION =~ $regexp_number ]] ; then
                  MY_GROUP_ID=${line_elements[$GROUP_ID_POSITION]}
            else            
                  MY_GROUP_ID="$GROUP_ID_POSITION"
            fi



            #--------------------------------------------------------------------------------------------------------------------------------------------
            #  Handle first metric
            #--------------------------------------------------------------------------------------------------------------------------------------------
            VALUE_POSITION=3
            MY_METRIC_NAME="ResponseTime"
            CURRENT_VALUE=${line_elements[$VALUE_POSITION]}

            # Add to injection file
            if [[ $CURRENT_VALUE =~ $regexp_number ]] ; then
            echo "{\"timestamp\":\"$MY_TIMESTAMP\",\"resourceID\":\"$MY_RESOURCE_ID\",\"metrics\":{\"$MY_METRIC_NAME\":$CURRENT_VALUE},\"attributes\":{\"group\":\"$MY_GROUP_ID\",\"node\":\"$MY_RESOURCE_ID\"}},">> /tmp/tmp_inject.json
            fi


            # #--------------------------------------------------------------------------------------------------------------------------------------------
            # #  Handle second metric
            # #--------------------------------------------------------------------------------------------------------------------------------------------
            VALUE_POSITION=4
            MY_METRIC_NAME="CPUUtil"
            CURRENT_VALUE=${line_elements[$VALUE_POSITION]}

            # Add to injection file
            if [[ $CURRENT_VALUE =~ $regexp_number ]] ; then
            echo "{\"timestamp\":\"$MY_TIMESTAMP\",\"resourceID\":\"$MY_RESOURCE_ID\",\"metrics\":{\"$MY_METRIC_NAME\":$CURRENT_VALUE},\"attributes\":{\"group\":\"$MY_GROUP_ID\",\"node\":\"$MY_RESOURCE_ID\"}},">> /tmp/tmp_inject.json
            fi

  



            #--------------------------------------------------------------------------------------------------------------------------------------------
            #  Inject MEtrics via REST every MAX_LINES_PER_CALL lines
            #--------------------------------------------------------------------------------------------------------------------------------------------
            if [[ $LINES_READ -ge $MAX_LINES_PER_CALL ]]; then
                  echo ""
                  echo ""
                  echo "       🚀 Writing $MAX_LINES_PER_CALL lines to AI Manager"
                  echo ""

                  #Finalise injection file
                  echo "{\"timestamp\":\"$MY_TIMESTAMP\",\"resourceID\":\"$MY_RESOURCE_ID\",\"metrics\":{\"$MY_METRIC_NAME\":$CURRENT_VALUE},\"attributes\":{\"group\":\"$MY_GROUP_ID\",\"node\":\"$MY_RESOURCE_ID\"}}">> /tmp/tmp_inject.json
                  echo ']}'>> /tmp/tmp_inject.json

                  # Inject metrics via rest
                  export result=$(curl -k -s -X POST "https://${ROUTE}/aiops/api/app/metric-api/v1/metrics" --header 'Content-Type: application/json' --header "Authorization: Bearer ${TOKEN}" --header 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' --data @/tmp/tmp_inject.json)
                  echo "       ✅ Injected: "$result
                  echo ""
                  # Reinitialise for next batch
                  LINES_READ=0
                  ((ITERATION++))
                  echo '{"groups":['> /tmp/tmp_inject.json
                  echo "      -------------------------------------------------------------------------------------------------------------------------------------"
                  echo "       📂 Preparing injection ($ITERATION)"
                  echo ""
                  
            fi                

      fi



done < $CSV_FILE

#Finalise injection file
echo "{\"timestamp\":\"$MY_TIMESTAMP\",\"resourceID\":\"$MY_RESOURCE_ID\",\"metrics\":{\"$MY_METRIC_NAME\":$CURRENT_VALUE},\"attributes\":{\"group\":\"$MY_GROUP_ID\",\"node\":\"$MY_RESOURCE_ID\"}}">> /tmp/tmp_inject.json
echo ']}'>> /tmp/tmp_inject.json

# Inject metrics via rest
export result=$(curl -k -s -X POST "https://${ROUTE}/aiops/api/app/metric-api/v1/metrics" --header 'Content-Type: application/json' --header "Authorization: Bearer ${TOKEN}" --header 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' --data @/tmp/tmp_inject.json)
echo ""
echo "       ✅ Injected: "$result



echo " "
echo " "
echo " "
echo " "
echo " ----------------------------------------------------------------------------------------------------------------------------------------"
echo "   ✅  Bulk inject Metrics DONE...."
echo " ----------------------------------------------------------------------------------------------------------------------------------------"
echo " "



exit 1


