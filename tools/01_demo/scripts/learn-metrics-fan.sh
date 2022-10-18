#!/bin/bash






# FORMAT:
#   resource_name, metric_name, group_name, fixed base value, random value
#
#   Example for "fixed base value"=100 and 2random value"=10
#   Gives metrics values between 100 and 110
#   If you put "fixed base value"=ITERATIONS then it will use the counter (for PodRestarts for example)
declare -a MY_RES_IDS=(
"DCWest1-Rack045-DELL3762,CPU1Temperature,System,85,10"
)
#"DCWest1-Rack045-DELL3762,CPU1Temperature,SystemTemperature,ITERATIONS,90"
# "mysql-predictive,TransactionsPerSecond,TransactionsPerSecond,0,1"
# "mysql-predictive,Latency,Latency,40000,1000"
# "ratings-predictive,PodRestarts,PodRestarts,0,1"
# "ratings-predictive,TransactionsPerSecond,TransactionsPerSecond,10,10"
# "ratings-predictive,Latency,Latency,2000,1000"



# Number of Global Iterations
export MAX_ITERATIONS=100000




#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# DO NOT MODIFY BELOW
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# Number of Bundle Iterations inside Global Iterations
export MAX_ITERATIONS_BUNDLE=100

#Minutes
export TIME_INCREMENT_MINUTES="0" 
export TIME_INCREMENT_SECONDS="60" 
export ADD_MSECONDS_STRING=000
export DATE_FORMAT="+%s"
export DATE_FORMAT_READABLE="+%Y-%m-%d %H:%M:%S"



echo "   "
echo "   "
echo "   "
echo "   "
echo "   ----------------------------------------------------------------------------------------------------------------------------------------"
echo "     🚀  Inject Synthetic Metrics for Anomaly generation"
echo "   ----------------------------------------------------------------------------------------------------------------------------------------"



echo "   ----------------------------------------------------------------------------------------------------------------------------------------"
echo "     🔐  Getting credentials"
echo "   ----------------------------------------------------------------------------------------------------------------------------------------"
export WAIOPS_NAMESPACE=$(oc get po -A|grep aimanager-operator |awk '{print$1}')

oc project $WAIOPS_NAMESPACE >/dev/null 2>/dev/null

export ROUTE=$(oc get route | grep ibm-nginx-svc | awk '{print $2}')
PASS=$(oc get secret admin-user-details -o jsonpath='{.data.initial_admin_password}' | base64 -d)
export TOKEN=$(curl -k -s -X POST https://$ROUTE/icp4d-api/v1/authorize -H 'Content-Type: application/json' -d "{\"username\": \"admin\",\"password\": \"$PASS\"}" | jq .token | sed 's/\"//g')

export BASE_TIMESTAMP=$(date "$DATE_FORMAT")
export HR_BASE_TIMESTAMP=$(date "$DATE_FORMAT_READABLE")


#--------------------------------------------------------------------------------------------------------------------------------------------
#  Launch Log Injection as a parallel thread
#--------------------------------------------------------------------------------------------------------------------------------------------
echo "      -------------------------------------------------------------------------------------------------------------------------------------"
echo "       🌏  Injecting Metrics Anomaly Data" 
echo "           Quit with Ctrl-Z"
echo "      -------------------------------------------------------------------------------------------------------------------------------------"
echo ""

export  ADD_SECONDS=120
export  ITERATIONS=0

# {"timestamp":"MY_TIMESTAMP","resourceID":"qotd-rating (qotd/qotd-rating-76d4964f5-8l8z6):::7QthWgdy4IaSS0KkxFUkYmBCLC0","metrics":{"cpu.user_usage":CPU_USAGE},"attributes":{"group":"docker","node":"qotd-rating (qotd/qotd-rating-76d4964f5-8l8z6):::7QthWgdy4IaSS0KkxFUkYmBCLC0"}},
# {"timestamp":"MY_TIMESTAMP","resourceID":"MY_RESOURCE_ID","metrics":{"MY_METRIC_NAME":MY_METRIC_VALUE},"attributes":{"group":"MY_GROUP_ID","node":"MY_RESOURCE_ID"}},
# {"timestamp":"MY_TIMESTAMP","resourceID":"mysql-predictive","metrics":{"MemoryUsageMax":MSQL_MEM_MAX,"MemoryUsageMean":MSQL_MEM_MEAN,"MemoryUsagePercent":MSQL_MEM_PERCENT},"attributes":{"group":"MemoryUsage","node":"mysql-predictive"}}

# mysql-predictive,MemoryUsageMax,MemoryUsage,FIX, VARIATION

# Loop until CTRL-C
while true
do


      echo '{"groups":['> /tmp/tmp_inject.json
      ((ITERATIONS++))

      for (( BUNDLE_ITERATIONS=1; BUNDLE_ITERATIONS <= $MAX_ITERATIONS_BUNDLE; ++BUNDLE_ITERATIONS ))
      do

            ADD_SECONDS=$(($ADD_SECONDS+($TIME_INCREMENT_MINUTES*60)))
            export act_timestamp_readable=$(date -v "$METRICS_SKEW" -v "+"$ADD_SECONDS"S" "$DATE_FORMAT_READABLE")


            echo "        ♻️  ITERATION: $ITERATIONS-$BUNDLE_ITERATIONS     at "$act_timestamp_readable"   -     Seconds skew "$ADD_SECONDS"   - "$MY_TIMESTAMP
            #echo ""

            # Clear incection file
            ADD_SECONDS=$(($ADD_SECONDS+$TIME_INCREMENT_SECONDS))

            # Get timestamp in ELK format
            export MY_TIMESTAMP=$(date -v "$METRICS_SKEW" -v "+"$ADD_SECONDS"S" "$DATE_FORMAT")"$ADD_MSECONDS_STRING"
            export my_timestamp_readable=$(date -v "$METRICS_SKEW" -v "+"$ADD_SECONDS"S" "$DATE_FORMAT_READABLE")


            for value in "${MY_RES_IDS[@]}"
            do
                  #echo ":"$value| sed 's/^/             /'

                  MY_RESOURCE_ID=$(echo $value | cut -d',' -f1)
                  MY_METRIC_NAME=$(echo $value | cut -d',' -f2)
                  MY_GROUP_ID=$(echo $value | cut -d',' -f3)
                  MY_FIX_VALUE=$(echo $value | cut -d',' -f4)
                  MY_VARIATION=$(echo $value | cut -d',' -f5)
                  #echo ":"$MY_FIX_VALUE
                  if [[ $MY_FIX_VALUE == "ITERATIONS" ]]; then
                        MY_FIX_VALUE=$(( ITERATIONS+BUNDLE_ITERATIONS*ITERATIONS+MY_VARIATION ))
                        #echo ":::::fix"$MY_FIX_VALUE
                        export CURRENT_VALUE=$MY_FIX_VALUE

                  else
                        export CURRENT_VALUE=$(($RANDOM%$MY_VARIATION+$MY_FIX_VALUE))

                  fi
                  
                  # echo ":"$MY_RESOURCE_ID
                  # echo ":"$MY_METRIC_NAME
                  # echo ":"$MY_GROUP_ID
                  # echo ":"$MY_FIX_VALUE
                  # echo ":"$MY_VARIATION




     
                  echo "CURRENT_VALUE:"$CURRENT_VALUE
                  #echo "MY_TIMESTAMP:"$MY_TIMESTAMP

                  echo "{\"timestamp\":\"$MY_TIMESTAMP\",\"resourceID\":\"$MY_RESOURCE_ID\",\"metrics\":{\"$MY_METRIC_NAME\":$CURRENT_VALUE},\"attributes\":{\"group\":\"$MY_GROUP_ID\",\"node\":\"$MY_RESOURCE_ID\"}},">> /tmp/tmp_inject.json
            done
      done 

      echo "{\"timestamp\":\"$MY_TIMESTAMP\",\"resourceID\":\"$MY_RESOURCE_ID\",\"metrics\":{\"$MY_METRIC_NAME\":$CURRENT_VALUE},\"attributes\":{\"group\":\"$MY_GROUP_ID\",\"node\":\"$MY_RESOURCE_ID\"}}">> /tmp/tmp_inject.json
      echo ']}'>> /tmp/tmp_inject.json

 cat /tmp/tmp_inject.json

      export result=$(curl -k -s -X POST "https://${ROUTE}/aiops/api/app/metric-api/v1/metrics" --header 'Content-Type: application/json' --header "Authorization: Bearer ${TOKEN}" --header 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' --data @/tmp/tmp_inject.json)
      #echo $result

      if [[ $ITERATIONS -gt $MAX_ITERATIONS ]]; then
            echo "        Done Iterating..."
            break
      fi

done 


