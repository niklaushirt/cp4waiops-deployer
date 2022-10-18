#!/bin/bash
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# DO NOT MODIFY BELOW
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

export LATENCY_SEC_MAX=2
export MEMORY_BASE=50000

#Minutes
export TIME_INCREMENT_MINUTES="0" 
export TIME_INCREMENT_SECONDS="5" 
export ADD_MSECONDS_STRING=000

export APP_NAME=robot-shop


#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# DO NOT MODIFY BELOW
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

echo "***************************************************************************************************************************************"
echo "***************************************************************************************************************************************"
echo ""
echo " 🚀  CP4WAIOPS Inject Synthetic Metrics for $APP_NAME"
echo ""
echo "***************************************************************************************************************************************"
echo ""
echo ""



export DATE_FORMAT="+%s"
export DATE_FORMAT_READABLE="+%Y-%m-%d %H:%M:%S"
export WORKING_DIR_METRICS="./tools/02_training/metrics/$APP_NAME"


#--------------------------------------------------------------------------------------------------------------------------------------------
# Get Credentials
#--------------------------------------------------------------------------------------------------------------------------------------------

echo "***************************************************************************************************************************************"
echo "  🔐  Getting credentials"
echo "***************************************************************************************************************************************"
export WAIOPS_NAMESPACE=$(oc get po -A|grep aiops-orchestrator-controller |awk '{print$1}')

oc project $WAIOPS_NAMESPACE 

export ROUTE=$(oc get route | grep ibm-nginx-svc | awk '{print $2}')
PASS=$(oc get secret admin-user-details -o jsonpath='{.data.initial_admin_password}' | base64 -d)
export TOKEN=$(curl -k -s -X POST https://$ROUTE/icp4d-api/v1/authorize -H 'Content-Type: application/json' -d "{\"username\": \"admin\",\"password\": \"$PASS\"}" | jq .token | sed 's/\"//g')


echo $HR_BASE_TIMESTAMP"="$BASE_TIMESTAMP

echo ""
echo ""




echo "***************************************************************************************************************************************"
echo "***************************************************************************************************************************************"
echo "  "
echo "  🔎  Parameter for Injection"
echo "  "
echo "           🌏 Metrics URL                       : $ROUTE"
echo "           🔐 Metrics Token                     : $TOKEN"
echo "  "
echo "           📅 Date Format                       : $(date "$DATE_FORMAT") ("$DATE_FORMAT")"
echo "  "
echo "  "
echo "           📂 Directory for Metric Templates    : $WORKING_DIR_METRICS"
echo "  "
echo "***************************************************************************************************************************************"
echo "***************************************************************************************************************************************"
echo ""
echo ""
echo "***************************************************************************************************************************************"
echo "***************************************************************************************************************************************"
echo "  🗄️  Files to be injected"
echo "***************************************************************************************************************************************"
ls -1 $WORKING_DIR_METRICS | grep "json"
echo "  "
echo "  "
echo "***************************************************************************************************************************************"
echo "***************************************************************************************************************************************"

echo ""
echo ""



# echo "***************************************************************************************************************************************"
# echo "***************************************************************************************************************************************"
#   read -p " ❗❓ Start Injection? [y,N] " DO_COMM
#   if [[ $DO_COMM == "y" ||  $DO_COMM == "Y" ]]; then
#       echo "   ✅ Ok, continuing..."
#       echo ""
#       echo ""
#       echo ""
#       echo ""

#   else
#     echo "❌ Aborted"
#     exit 1
#   fi
echo "***************************************************************************************************************************************"
echo "***************************************************************************************************************************************"
echo ""
echo ""
echo ""
echo ""


export BASE_TIMESTAMP=$(date "$DATE_FORMAT")
export HR_BASE_TIMESTAMP=$(date "$DATE_FORMAT_READABLE")


#--------------------------------------------------------------------------------------------------------------------------------------------
#  Launch Log Injection as a parallel thread
#--------------------------------------------------------------------------------------------------------------------------------------------
echo "***************************************************************************************************************************************"
echo "***************************************************************************************************************************************"
echo " 🚀  Launching Metrics Injection at $HR_BASE_TIMESTAMP"="$BASE_TIMESTAMP - Hit CTRL-C to stop" 
echo "***************************************************************************************************************************************"
echo "***************************************************************************************************************************************"
echo ""



export  ADD_SECONDS=0



# Loop until CTRL-C
while true
do

      ADD_SECONDS=$(($ADD_SECONDS+($TIME_INCREMENT_MINUTES*60)))
      #export my_timestamp=$(date "$DATE_FORMAT")"$ADD_MSECONDS_STRING"
      export act_timestamp_readable=$(date -v "+"$ADD_SECONDS"S" "$DATE_FORMAT_READABLE")
      echo "Injecting at "$act_timestamp_readable"     -     Seconds skew "$ADD_SECONDS"                    "


      # Clear incection file
      echo "" > /tmp/timestampedMetricFile.json

      # For all injection Files
      for actFile in $(ls -1 $WORKING_DIR_METRICS | grep "json"); 
      do 
            #echo "Injecting at "$BASE_TIMESTAMP"000 - File "$actFile

            # Start at 100 ms

            while IFS= read -r line
            do
                  # Increase MS
                  ADD_SECONDS=$(($ADD_SECONDS+$TIME_INCREMENT_SECONDS))

                  #------------------------------------------------------------------------------------------------
                  # RANDOM METRICS FOR MYSQL
                  #------------------------------------------------------------------------------------------------
                        # Random Latency for MYSQL
                        # MEAN: 1.000-2.000
                        # MAX: 1.000 - 4.000
                        export MSQL_LAT_MS_MAX=$(($RANDOM%1000))
                        export MSQL_LAT_SEC_MAX=$(($RANDOM%$LATENCY_SEC_MAX+1))
                        export MSQL_LAT_MS_MEAN=$(($RANDOM%1000))
                        export MSQL_LAT_SEC_MEAN=1

                        export MSQL_LAT_MEAN="$MSQL_LAT_SEC_MEAN.$MSQL_LAT_MS_MEAN"
                        export MSQL_LAT_MAX="$MSQL_LAT_SEC_MAX.$MSQL_LAT_MS_MAX"

                        # Random TransactionsPerSecond for MYSQL
                        # MEAN: 50-100
                        # MAX: 100-200
                        export MSQL_TPS_MAX=$(($RANDOM%100+100))
                        export MSQL_TPS_MEAN=$(($RANDOM%50+50))

                        # Random Memory Usage for MYSQL
                        # MEAN: 50000-501000
                        # MAX: 50000-60000
                        export MSQL_MEM_MAX=$(($RANDOM%10000+$MEMORY_BASE))
                        export MSQL_MEM_MEAN=$(($RANDOM%1000+$MEMORY_BASE))


                  #------------------------------------------------------------------------------------------------
                  # RANDOM METRICS FOR RATINGS
                  #------------------------------------------------------------------------------------------------
                        # Random Latency for RATINGS
                        # MEAN: 1.000-2.000
                        # MAX: 1.000 - 4.000
                        export RAT_LAT_MS_MAX=$(($RANDOM%1000))
                        export RAT_LAT_SEC_MAX=$(($RANDOM%$LATENCY_SEC_MAX+1))
                        export RAT_LAT_MS_MEAN=$(($RANDOM%1000))
                        export RAT_LAT_SEC_MEAN=1

                        export RAT_LAT_MEAN="$RAT_LAT_SEC_MEAN.$RAT_LAT_MS_MEAN"
                        export RAT_LAT_MAX="$RAT_LAT_SEC_MAX.$RAT_LAT_MS_MAX"

                        # Random TransactionsPerSecond for RATINGS
                        # MEAN: 50-100
                        # MAX: 100-200
                        export RAT_TPS_MAX=$(($RANDOM%100+100))
                        export RAT_TPS_MEAN=$(($RANDOM%50+50))

                        # Random Memory Usage for RATINGS
                        # MEAN: 50000-501000
                        # MAX: 50000-60000
                        export RAT_MEM_MAX=$(($RANDOM%10000+$MEMORY_BASE))
                        export RAT_MEM_MEAN=$(($RANDOM%1000+$MEMORY_BASE))



                  # Get timestamp in ELK format
                  export my_timestamp=$(date -v "+"$ADD_SECONDS"S" "$DATE_FORMAT")"$ADD_MSECONDS_STRING"
                  export my_timestamp_readable=$(date -v "+"$ADD_SECONDS"S" "$DATE_FORMAT_READABLE")


                  # Replace in the file to be injected
                  line=${line//MY_TIMESTAMP/$my_timestamp}
                  line=${line//MSQL_LATENCY_MAX/$MSQL_LAT_MAX}
                  line=${line//MSQL_LATENCY_MEAN/$MSQL_LAT_MEAN}
                  line=${line//MSQL_TPS_MAX/$MSQL_TPS_MAX}
                  line=${line//MSQL_TPS_MEAN/$MSQL_TPS_MEAN}
                  line=${line//MSQL_MEM_MAX/$MSQL_MEM_MAX}
                  line=${line//MSQL_MEM_MEAN/$MSQL_MEM_MEAN}

                  line=${line//RAT_LATENCY_MAX/$RAT_LAT_MAX}
                  line=${line//RAT_LATENCY_MEAN/$RAT_LAT_MEAN}
                  line=${line//RAT_TPS_MAX/$RAT_TPS_MAX}
                  line=${line//RAT_TPS_MEAN/$RAT_TPS_MEAN}
                  line=${line//RAT_MEM_MAX/$RAT_MEM_MAX}
                  line=${line//RAT_MEM_MEAN/$RAT_MEM_MEAN}

                  # Write line to temp file
                  echo $line >> /tmp/timestampedMetricFile.json

            done < "$WORKING_DIR_METRICS/$actFile"


            # Inject temp file
            export result=$(curl -k -s -X POST "https://${ROUTE}/aiops/api/app/metric-api/v1/metrics" --header 'Content-Type: application/json' --header "Authorization: Bearer ${TOKEN}" --header 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' --data @/tmp/timestampedMetricFile.json)

      done
done 
#--------------------------------------------------------------------------------------------------------------------------------------------
#  Clean up
#--------------------------------------------------------------------------------------------------------------------------------------------



echo ""
echo ""
echo ""
echo ""
echo "***************************************************************************************************************************************"
echo "***************************************************************************************************************************************"
echo ""
echo " 🚀  P4WAIOPS Inject Synthetic Metrics for $APP_NAME"
echo " ✅  Done..... "
echo ""
echo "***************************************************************************************************************************************"
echo "***************************************************************************************************************************************"


