#!/bin/bash






# FORMAT:
#   resource_name, metric_name, group_name, fixed base value, random value
#
#   Example for "fixed base value"=100 and 2random value"=10
#   Gives metrics values between 100 and 110
#   If you put "fixed base value"=ITERATIONS then it will use the counter (for PodRestarts for example)
declare -a MY_RES_IDS=(
  "mysql-predictive,MemoryUsagePercent,MemoryUsage,45,20"
  "mysql-predictive,MemoryUsageMean,MemoryUsage,30000,1000"
  "mysql-predictive,MemoryUsageMax,MemoryUsage,35000,4000"
  "mysql-predictive,PodRestarts,PodRestarts,1,1"
  "mysql-predictive,TransactionsPerSecond,TransactionsPerSecond,169,40"
  "mysql-predictive,Latency,Latency,2,1"
  "ratings-predictive,MemoryUsagePercent,MemoryUsage,45,10"
  "ratings-predictive,MemoryUsageMean,MemoryUsage,30000,1000"
  "ratings-predictive,MemoryUsageMax,MemoryUsage,35000,10000"
  "ratings-predictive,PodRestarts,PodRestarts,1,1"
  "ratings-predictive,TransactionsPerSecond,TransactionsPerSecond,160,40"
  "ratings-predictive,Latency,Latency,2,1"
  "DCWest1-Rack045-DELL3762,CPU1Temperature,System,ITERATIONS,90"
  "dSwitch-1-vm-network-port-1,TransactionsPerSecond,TransactionsPerSecond,0,1"
  "dcwest1-switch023,TransactionsPerSecond,TransactionsPerSecond,60,30"
)


export MAX_ITERATIONS_DAYS=40



#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# DO NOT MODIFY BELOW
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Number of Hours to iterate
export MAX_ITERATIONS_HOURS=24
# Number of 5 minute steps to iterate
export MAX_ITERATIONS_BUNDLE=12

#Minutes
export TIME_INCREMENT_MINUTES="0" 
# 5 minutes
export TIME_INCREMENT_SECONDS="300" 
export ADD_MSECONDS_STRING=000
export DATE_FORMAT="+%s"
export DATE_FORMAT_READABLE="+%Y-%m-%d %H:%M:%S"



echo "   "
echo "   "
echo "   "
echo "   "
echo "   ----------------------------------------------------------------------------------------------------------------------------------------"
echo "     🚀  Create Synthetic Metrics for Anomaly generation"
echo "   ----------------------------------------------------------------------------------------------------------------------------------------"



export BASE_TIMESTAMP=$(date "$DATE_FORMAT")
export HR_BASE_TIMESTAMP=$(date "$DATE_FORMAT_READABLE")





for value in "${MY_RES_IDS[@]}"
do
      #echo ":"$value| sed 's/^/             /'

      MY_RESOURCE_ID=$(echo $value | cut -d',' -f1)
      MY_METRIC_NAME=$(echo $value | cut -d',' -f2)
      MY_GROUP_ID=$(echo $value | cut -d',' -f3)
      MY_FIX_VALUE=$(echo $value | cut -d',' -f4)
      #echo ":"$MY_FIX_VALUE
      # if [[ $MY_FIX_VALUE == "ITERATIONS" ]]; then
      #       MY_FIX_VALUE=$(( BUNDLE_ITERATIONS+ITERATIONS*MAX_ITERATIONS_BUNDLE ))
      #       #echo ":::::"$MY_FIX_VALUE
      # fi
      MY_VARIATION=$(echo $value | cut -d',' -f5)


      echo "   "
      echo "   "
      echo "   "
      echo "   "
      echo "   ----------------------------------------------------------------------------------------------------------------------------------------"
      echo "     🚀  Create Synthetic Metrics for $MY_RESOURCE_ID:$MY_GROUP_ID:$MY_METRIC_NAME"
      echo "   ----------------------------------------------------------------------------------------------------------------------------------------"


      export fileName="metrics-$MY_RESOURCE_ID-$MY_GROUP_ID-$MY_METRIC_NAME.json"


      echo '{"groups":['> $fileName




      export  ADD_SECONDS=0
      export DAY_ITERATIONS=0
      # Loop until CTRL-C
      while true
      do
            export  HOUR_ITERATIONS=0
            ((DAY_ITERATIONS++))
            # {"timestamp":"MY_TIMESTAMP","resourceID":"qotd-rating (qotd/qotd-rating-76d4964f5-8l8z6):::7QthWgdy4IaSS0KkxFUkYmBCLC0","metrics":{"cpu.user_usage":CPU_USAGE},"attributes":{"group":"docker","node":"qotd-rating (qotd/qotd-rating-76d4964f5-8l8z6):::7QthWgdy4IaSS0KkxFUkYmBCLC0"}},
            # {"timestamp":"MY_TIMESTAMP","resourceID":"MY_RESOURCE_ID","metrics":{"MY_METRIC_NAME":MY_METRIC_VALUE},"attributes":{"group":"MY_GROUP_ID","node":"MY_RESOURCE_ID"}},
            # {"timestamp":"MY_TIMESTAMP","resourceID":"mysql-predictive","metrics":{"MemoryUsageMax":MSQL_MEM_MAX,"MemoryUsageMean":MSQL_MEM_MEAN,"MemoryUsagePercent":MSQL_MEM_PERCENT},"attributes":{"group":"MemoryUsage","node":"mysql-predictive"}}

            # mysql-predictive,MemoryUsageMax,MemoryUsage,FIX, VARIATION



            # Loop until CTRL-C
            while true
            do
                  ((HOUR_ITERATIONS++))
                        # echo "        ♻️  ITERATION: $DAY_ITERATIONS - $HOUR_ITERATIONS     at "$act_timestamp_readable"   -     Seconds skew "$ADD_SECONDS
                        # echo ""

                  for (( BUNDLE_ITERATIONS=1; BUNDLE_ITERATIONS <= $MAX_ITERATIONS_BUNDLE; ++BUNDLE_ITERATIONS ))
                  do
                        ADD_SECONDS=$(($ADD_SECONDS+($TIME_INCREMENT_MINUTES*60)))
                        export act_timestamp_readable=$(date -v "+"$ADD_SECONDS"S" "$DATE_FORMAT_READABLE")

                        # echo "        ♻️  ITERATION: $HOUR_ITERATIONS-$BUNDLE_ITERATIONS     at "$act_timestamp_readable"   -     Seconds skew "$ADD_SECONDS
                        # echo ""

                        # Clear incection file
                        ADD_SECONDS=$(($ADD_SECONDS+$TIME_INCREMENT_SECONDS))

                        # Get timestamp in ELK format
                        export MY_TIMESTAMP=$(date -v "+"$ADD_SECONDS"S" "$DATE_FORMAT")"$ADD_MSECONDS_STRING"
                        #export my_timestamp_readable=$(date -v "+"$ADD_SECONDS"S" "$DATE_FORMAT_READABLE")

                      

                        export CURRENT_VALUE=$(($RANDOM%$MY_VARIATION+$MY_FIX_VALUE))

                        #echo ":"$MY_METRIC_NAME"CURRENT_VALUE:"$CURRENT_VALUE
                        # echo ":"$MY_RESOURCE_ID
                        # echo ":"$MY_METRIC_NAME
                        # echo ":"$MY_GROUP_ID
                        # echo ":"$MY_FIX_VALUE
                        # echo ":"$MY_VARIATION
                        # echo "CURRENT_VALUE:"$CURRENT_VALUE
                        # echo "MY_TIMESTAMP:"$MY_TIMESTAMP

                        echo "{\"timestamp\":\"$MY_TIMESTAMP\",\"resourceID\":\"$MY_RESOURCE_ID\",\"metrics\":{\"$MY_METRIC_NAME\":$CURRENT_VALUE},\"attributes\":{\"group\":\"$MY_GROUP_ID\",\"node\":\"$MY_RESOURCE_ID\"}},">>$fileName
                        
                  done 


                  if [[ $HOUR_ITERATIONS -gt $MAX_ITERATIONS_HOURS ]]; then
                        echo "        Done for the Day $DAY_ITERATIONS ..."
                        
                        break
                  fi

            done 

            echo "{\"timestamp\":\"$MY_TIMESTAMP\",\"resourceID\":\"$MY_RESOURCE_ID\",\"metrics\":{\"$MY_METRIC_NAME\":$CURRENT_VALUE},\"attributes\":{\"group\":\"$MY_GROUP_ID\",\"node\":\"$MY_RESOURCE_ID\"}}">>$fileName
            echo ']}'>> /tmp/tmp_inject.json

            # export result=$(curl -k -s -X POST "https://${ROUTE}/aiops/api/app/metric-api/v1/metrics" --header 'Content-Type: application/json' --header "Authorization: Bearer ${TOKEN}" --header 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' --data @/tmp/tmp_inject.json)
            # echo $result


            if [[ $DAY_ITERATIONS -gt $MAX_ITERATIONS_DAYS ]]; then
                  echo "        Done Iterating..."
                 
                  break
            fi

      done 



      #echo ":"$MY_METRIC_NAME"CURRENT_VALUE:"$CURRENT_VALUE
      # echo ":"$MY_RESOURCE_ID
      # echo ":"$MY_METRIC_NAME
      # echo ":"$MY_GROUP_ID
      # echo ":"$MY_FIX_VALUE
      # echo ":"$MY_VARIATION
      # echo "CURRENT_VALUE:"$CURRENT_VALUE
      # echo "MY_TIMESTAMP:"$MY_TIMESTAMP

done
done 




#--------------------------------------------------------------------------------------------------------------------------------------------
#  Launch Log Injection as a parallel thread
#--------------------------------------------------------------------------------------------------------------------------------------------
echo "      -------------------------------------------------------------------------------------------------------------------------------------"
echo "       🌏  Injecting Metrics Anomaly Data" 
echo "           Quit with Ctrl-Z"
echo "      -------------------------------------------------------------------------------------------------------------------------------------"
echo ""

export  ADD_SECONDS=0
export DAY_ITERATIONS=0
# Loop until CTRL-C
while true
do
      export  HOUR_ITERATIONS=0
      ((DAY_ITERATIONS++))
      # {"timestamp":"MY_TIMESTAMP","resourceID":"qotd-rating (qotd/qotd-rating-76d4964f5-8l8z6):::7QthWgdy4IaSS0KkxFUkYmBCLC0","metrics":{"cpu.user_usage":CPU_USAGE},"attributes":{"group":"docker","node":"qotd-rating (qotd/qotd-rating-76d4964f5-8l8z6):::7QthWgdy4IaSS0KkxFUkYmBCLC0"}},
      # {"timestamp":"MY_TIMESTAMP","resourceID":"MY_RESOURCE_ID","metrics":{"MY_METRIC_NAME":MY_METRIC_VALUE},"attributes":{"group":"MY_GROUP_ID","node":"MY_RESOURCE_ID"}},
      # {"timestamp":"MY_TIMESTAMP","resourceID":"mysql-predictive","metrics":{"MemoryUsageMax":MSQL_MEM_MAX,"MemoryUsageMean":MSQL_MEM_MEAN,"MemoryUsagePercent":MSQL_MEM_PERCENT},"attributes":{"group":"MemoryUsage","node":"mysql-predictive"}}

      # mysql-predictive,MemoryUsageMax,MemoryUsage,FIX, VARIATION
            echo '{"groups":['> /tmp/tmp_inject.json

      # Loop until CTRL-C
      while true
      do
            ((HOUR_ITERATIONS++))
                  echo "        ♻️  ITERATION: $DAY_ITERATIONS - $HOUR_ITERATIONS     at "$act_timestamp_readable"   -     Seconds skew "$ADD_SECONDS
                  echo ""

            for (( BUNDLE_ITERATIONS=1; BUNDLE_ITERATIONS <= $MAX_ITERATIONS_BUNDLE; ++BUNDLE_ITERATIONS ))
            do
                  ADD_SECONDS=$(($ADD_SECONDS+($TIME_INCREMENT_MINUTES*60)))
                  export act_timestamp_readable=$(date -v "+"$ADD_SECONDS"S" "$DATE_FORMAT_READABLE")

                  # echo "        ♻️  ITERATION: $HOUR_ITERATIONS-$BUNDLE_ITERATIONS     at "$act_timestamp_readable"   -     Seconds skew "$ADD_SECONDS
                  # echo ""

                  # Clear incection file
                  ADD_SECONDS=$(($ADD_SECONDS+$TIME_INCREMENT_SECONDS))

                  # Get timestamp in ELK format
                  export MY_TIMESTAMP=$(date -v "+"$ADD_SECONDS"S" "$DATE_FORMAT")"$ADD_MSECONDS_STRING"
                  #export my_timestamp_readable=$(date -v "+"$ADD_SECONDS"S" "$DATE_FORMAT_READABLE")

                  for value in "${MY_RES_IDS[@]}"
                  do
                        #echo ":"$value| sed 's/^/             /'

                        MY_RESOURCE_ID=$(echo $value | cut -d',' -f1)
                        MY_METRIC_NAME=$(echo $value | cut -d',' -f2)
                        MY_GROUP_ID=$(echo $value | cut -d',' -f3)
                        MY_FIX_VALUE=$(echo $value | cut -d',' -f4)
                        #echo ":"$MY_FIX_VALUE
                        # if [[ $MY_FIX_VALUE == "ITERATIONS" ]]; then
                        #       MY_FIX_VALUE=$(( BUNDLE_ITERATIONS+ITERATIONS*MAX_ITERATIONS_BUNDLE ))
                        #       #echo ":::::"$MY_FIX_VALUE
                        # fi
                        MY_VARIATION=$(echo $value | cut -d',' -f5)

                        export CURRENT_VALUE=$(($RANDOM%$MY_VARIATION+$MY_FIX_VALUE))

                        #echo ":"$MY_METRIC_NAME"CURRENT_VALUE:"$CURRENT_VALUE
                        # echo ":"$MY_RESOURCE_ID
                        # echo ":"$MY_METRIC_NAME
                        # echo ":"$MY_GROUP_ID
                        # echo ":"$MY_FIX_VALUE
                        # echo ":"$MY_VARIATION
                        # echo "CURRENT_VALUE:"$CURRENT_VALUE
                        # echo "MY_TIMESTAMP:"$MY_TIMESTAMP

                        echo "{\"timestamp\":\"$MY_TIMESTAMP\",\"resourceID\":\"$MY_RESOURCE_ID\",\"metrics\":{\"$MY_METRIC_NAME\":$CURRENT_VALUE},\"attributes\":{\"group\":\"$MY_GROUP_ID\",\"node\":\"$MY_RESOURCE_ID\"}},">> /tmp/tmp_inject.json
                  done
            done 


            if [[ $HOUR_ITERATIONS -gt $MAX_ITERATIONS_HOURS ]]; then
                  echo "        Done for the Day..."
                  break
            fi

      done 

      echo "{\"timestamp\":\"$MY_TIMESTAMP\",\"resourceID\":\"$MY_RESOURCE_ID\",\"metrics\":{\"$MY_METRIC_NAME\":$CURRENT_VALUE},\"attributes\":{\"group\":\"$MY_GROUP_ID\",\"node\":\"$MY_RESOURCE_ID\"}}">> /tmp/tmp_inject.json
      echo ']}'>> /tmp/tmp_inject.json

      export result=$(curl -k -s -X POST "https://${ROUTE}/aiops/api/app/metric-api/v1/metrics" --header 'Content-Type: application/json' --header "Authorization: Bearer ${TOKEN}" --header 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' --data @/tmp/tmp_inject.json)
      echo $result


      if [[ $DAY_ITERATIONS -gt $MAX_ITERATIONS_DAYS ]]; then
            echo "        Done Iterating..."
            break
      fi

done 