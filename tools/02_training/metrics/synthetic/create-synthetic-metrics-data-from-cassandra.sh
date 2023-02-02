#!/bin/bash

# 20 ITERATIONS gives you about 2.5 months of synthetic data
export MAX_ITERATIONS=20

# The default work sub-directory
export DIR_PREFIX=my-data




export WAIOPS_NAMESPACE=$(oc get po -A|grep aiops-orchestrator-controller |awk '{print$1}')

oc project $WAIOPS_NAMESPACE >/dev/null 2>/dev/null



#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# DO NOT MODIFY BELOW
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

declare -a MY_RES_IDS=()
export DEFAULT_FILTER="."


echo "***************************************************************************************************************************************"
echo "***************************************************************************************************************************************"
echo ""
echo " 🚀  CP4WAIOPS Create Synthetic Metrics"
echo ""
echo "***************************************************************************************************************************************"
echo ""
echo ""
export DATE_FORMAT="+%Y-%m-%d %H:%M:00.000+0000"


if [[ $INPUT_DIR_PREFIX == "" ]];
then

      echo "     --------------------------------------------------------------------------------------------"
      echo "     📂 Specify the output sub-directory (default is $DIR_PREFIX): "
      read INPUT_DIR_PREFIX
else
      export DIR_PREFIX=$INPUT_DIR_PREFIX
fi
if [[ $INPUT_DIR_PREFIX == "" ]];
then 
      export DIR_PREFIX=$DIR_PREFIX
else
      export DIR_PREFIX=$INPUT_DIR_PREFIX
fi
echo ""
echo ""

export WORKING_DIR_OUTPUT="./$DIR_PREFIX/output"
export WORKING_DIR_DUMPS=./$DIR_PREFIX/dumps
export WORKING_DIR_TEMPLATES=./$DIR_PREFIX/templates/

mkdir -p $WORKING_DIR_OUTPUT

echo "***************************************************************************************************************************************"
echo "***************************************************************************************************************************************"
echo ""
echo ""
echo ""
echo ""

mkdir -p $WORKING_DIR_TEMPLATES
mkdir -p $WORKING_DIR_DUMPS


rm $WORKING_DIR_TEMPLATES/*>/dev/null 2>/dev/null



echo "***************************************************************************************************************************************"
echo "***************************************************************************************************************************************"
echo " 📂  Directories" 
echo "***************************************************************************************************************************************"
echo "***************************************************************************************************************************************"
echo ""
echo "Existing Dumps:       $WORKING_DIR_DUMPS"
echo "Temporary Templates:  $WORKING_DIR_TEMPLATES"
echo "Synthetic Data:       $WORKING_DIR_OUTPUT"
echo ""
echo ""
echo ""


echo "***************************************************************************************************************************************"
echo "***************************************************************************************************************************************"
echo " 🚀  DUMP existing Cassandra tables into $WORKING_DIR_DUMPS" 
echo "***************************************************************************************************************************************"
echo "***************************************************************************************************************************************"
echo ""

DUMPS_EXIST=$(ls -1 $WORKING_DIR_DUMPS| wc -l)

if [[ ! $DUMPS_EXIST -gt "0" ]]; then
echo "    ✅ No Dumps Present - you have to create dumps first or copy them manually to $WORKING_DIR_DUMPS"

else
echo "    ❗ Dumps Already Exist"

fi
echo  ""    
echo  ""

read -p "  Do you want to dump the Cassandra tables❓ [y,N] " DO_COMM
if [[ $DO_COMM == "y" ||  $DO_COMM == "Y" ]]; then
      echo  ""    
      echo  ""
      echo "     --------------------------------------------------------------------------------------------"
      echo "     💾 Dump the tables to the Pod filesystem"

     	oc exec -ti aiops-topology-cassandra-0 -- bash -c "/opt/ibm/cassandra/bin/cqlsh --ssl -u \$CASSANDRA_USER -p \$CASSANDRA_PASS -e \"copy tararam.md_metric_resource to '/tmp/tararam.md_metric_resource.csv' with header=true;\""| sed 's/^/           /'
	oc exec -ti aiops-topology-cassandra-0 -- bash -c "/opt/ibm/cassandra/bin/cqlsh --ssl -u \$CASSANDRA_USER -p \$CASSANDRA_PASS -e \"copy tararam.dt_metric_value to '/tmp/tararam.dt_metric_value.csv' with header=true;\""| sed 's/^/           /'

      echo  ""    
      echo  ""
      echo "     --------------------------------------------------------------------------------------------"
      echo "     📥 Copy the dumps from the Pod to the local filesystem (you can ignore rsync errors)"

	oc rsync aiops-topology-cassandra-0:/tmp/tararam.md_metric_resource.csv $WORKING_DIR_DUMPS| sed 's/^/           /'
	oc rsync aiops-topology-cassandra-0:/tmp/tararam.dt_metric_value.csv $WORKING_DIR_DUMPS| sed 's/^/           /'


else
      echo  ""    
      echo  ""
      if [[ ! $DUMPS_EXIST -gt "0" ]]; then
            echo "    ❗ No Dumps Present - you have to create dumps first"
            echo "    ❗ Aborting...."
            exit 0
      else
            echo "    ⚠️  Skipping"
            echo  ""    
            echo  ""
      fi



fi
      echo  ""    
      echo  ""
      echo  ""    
      echo  ""



echo "***************************************************************************************************************************************"
echo "***************************************************************************************************************************************"
echo " 🚀  Extract Entities" 
echo "***************************************************************************************************************************************"
echo "***************************************************************************************************************************************"
echo ""


      if [[ $MY_FILTER1 == "" ]];
      then
 
            echo "     --------------------------------------------------------------------------------------------"
            echo "     🔎 Enter Search String (leave empty to get all resources): "
            read MY_FILTER1
      else
            MY_FILTER1=$DEFAULT_FILTER
      fi
      if [[ $MY_FILTER1 == "" ]];
      then 
            MY_FILTER1="."
      fi
      echo ""
      echo ""

      if [[ $MY_FILTER2 == "" ]];
      then

            echo "     --------------------------------------------------------------------------------------------"
            echo "     🔎 Enter additional Search String (leave empty to get all resources): "
            read MY_FILTER2
      else
            MY_FILTER2=$DEFAULT_FILTER
      fi
      if [[ $MY_FILTER2 == "" ]];
      then 
       MY_FILTER2="."
      fi
      echo ""
      echo ""


      echo "     --------------------------------------------------------------------------------------------"
      echo "     🌏 Available Resources"
      echo ""
      while IFS= read -r line
      do
            
            actLine=$(echo $line| grep $MY_FILTER1| grep $MY_FILTER2| grep -v "t_uid")
            #echo ":::"$actLine
            if [[ ! $actLine == "" ]];
            then
                  #echo $actLine

                  echo $actLine| grep $MY_FILTER1| grep $MY_FILTER2 | awk '{split($0,a,","); print a[3],"\t",a[2],"\t",a[4],"\t"}'| sed 's/^/           /'
                  echo "ID:   "${actLine##*,}  | sed 's/^/           /'
                  echo ""
                  

                  # Add new element at the end of the array
                  #echo "---"$line
                  #echo $line| grep $MY_FILTER1 | awk '{split($0,a,","); print a[7]}'

                  export CURRENT_RES_ID=$(echo ${line##*,}| tr -d '\r' | tr -d '\n' )
                  
                  if [[ ! $CURRENT_RES_ID == "" ]];
                  then
                        #echo "add"$CURRENT_RES_ID
                        MY_RES_IDS+=($CURRENT_RES_ID)
            
                  fi

                  # Replace in the file to be injected
                  line=${line//MY_TIMESTAMP/$my_timestamp}
            fi
            # Write line to temp file
            #echo $line >> $WORKING_DIR_OUTPUT"/tararam.dt_metric_value.csv"
            #echo $line 

      done < "$WORKING_DIR_DUMPS/tararam.md_metric_resource.csv"
      echo "DONE"
  

      echo ""
      echo ""
      echo "     --------------------------------------------------------------------------------------------"
      echo "     ❓ Enter specific Resource ID (hit enter to use all displayed resource IDs): "
      echo ""
      read MY_RES_ID

      if [[ ! $MY_RES_ID == "" ]];
      then 
            export MY_RES_IDS=($MY_RES_ID)
      fi


      # echo ""
      # echo ""
      # echo "     --------------------------------------------------------------------------------------------"
      # echo "     📥 Resource IDs to be taken into account"
      # echo ""
      # for value in "${MY_RES_IDS[@]}"
      # do
      #       echo $value| sed 's/^/             /'
      # done
      # echo ""
      # echo ""
      rm $WORKING_DIR_OUTPUT/tararam.dt_metric_value.csv>/dev/null 2>/dev/null
      rm $WORKING_DIR_OUTPUT/tararam.md_metric_resource.csv>/dev/null 2>/dev/null


      echo "     --------------------------------------------------------------------------------------------"
      echo "     📥 Preparing Resource File $WORKING_DIR_OUTPUT/tararam.md_metric_resource.csv" 
      echo ""
      echo "t_uid,metric_name,resource_name,group_name,attributes,mr_id">$WORKING_DIR_OUTPUT/tararam.md_metric_resource.csv

      for value in "${MY_RES_IDS[@]}"
      do
            export MY_RES_ID=$(echo $value| tr -d '\r' | tr -d '\n' )
            echo "Preparing $MY_RES_ID"| sed 's/^/           /'
            #echo "t_uid,mr_id,tstamp,anomalous,expected,max,min,value" > $WORKING_DIR_TEMPLATES"/$MY_RES_ID"
            #cat $WORKING_DIR_DUMPS/tararam.dt_metric_value.csv | grep $MY_RES_ID
            cat $WORKING_DIR_DUMPS/tararam.md_metric_resource.csv | grep $MY_RES_ID  >> $WORKING_DIR_OUTPUT/tararam.md_metric_resource.csv
      done
      echo ""
      echo ""



      echo "     --------------------------------------------------------------------------------------------"
      echo "     📥 Preparing Templates in $WORKING_DIR_TEMPLATES" 
      echo ""
      for value in "${MY_RES_IDS[@]}"
      do
            export MY_RES_ID=$(echo $value| tr -d '\r' | tr -d '\n' )
            echo "Preparing $MY_RES_ID"| sed 's/^/           /'
            #echo "t_uid,mr_id,tstamp,anomalous,expected,max,min,value" > $WORKING_DIR_TEMPLATES"/$MY_RES_ID"
            #cat $WORKING_DIR_DUMPS/tararam.dt_metric_value.csv | grep $MY_RES_ID
            
            cat $WORKING_DIR_DUMPS/tararam.dt_metric_value.csv | grep $MY_RES_ID| tail -n 1000|sed 's/,20.*-.*000+/,MY_TIMESTAMP000+/'  >> $WORKING_DIR_TEMPLATES"/$MY_RES_ID"
      done




      # Init RESOURCES File

echo ""
echo ""
echo ""
echo ""


# echo "***************************************************************************************************************************************"
# echo "***************************************************************************************************************************************"
# echo " 🚀  Files to be used" 
# echo "***************************************************************************************************************************************"
# echo "***************************************************************************************************************************************"
# echo ""
# ls -1 $WORKING_DIR_TEMPLATES| sed 's/^/           /'
# echo ""
# echo ""
# echo ""
# echo ""


echo "***************************************************************************************************************************************"
echo "***************************************************************************************************************************************"
echo " 🚀  Launching Cassandra Dump Files Creation" 
echo "***************************************************************************************************************************************"
echo "***************************************************************************************************************************************"
echo ""


echo "     --------------------------------------------------------------------------------------------"
echo "     📥 Preparting Values File $WORKING_DIR_OUTPUT/tararam.dt_metric_value.csv" 
echo ""
echo ""
echo ""
LOOP_COUNT=0

export  ADD_SECONDS=0

# Init VALUES File
echo "t_uid,mr_id,tstamp,anomalous,expected,max,min,value" > $WORKING_DIR_OUTPUT"/tararam.dt_metric_value.csv"

export start_timestamp=$(date -j -v-31d "+%Y%m%d-%H0000")
export base_timestamp=$start_timestamp
export my_timestamp=$(date -j -f %Y%m%d-%H%M%S $start_timestamp  +%Y-%m-%d\ %H:%M:00)

# Loop until CTRL-C
while true
do

      export RUN_SECONDS=$ADD_SECONDS

      #echo "RUN SECS:  $RUN_SECONDS   ADD SECS:  $ADD_SECONDS"

      ((LOOP_COUNT++))

      # For all injection Files
      for actFile in $(ls -1 $WORKING_DIR_TEMPLATES ); 
      do 

            export ADD_SECONDS=$RUN_SECONDS
            #echo "----RUN SECS:  $RUN_SECONDS   ADD SECS:  $ADD_SECONDS"
            
             echo "$LOOP_COUNT/$MAX_ITERATIONS - Creating for file "$actFile| sed 's/^/       /'

            # Start at 100 ms

            while IFS= read -r line
            do
                  # Increase Seconds by 5
                  ADD_SECONDS=$(($ADD_SECONDS+(5*60)))

                  # Get timestamp in format 2022-03-18 16:20:00.000+0000
                  export my_timestamp=$(date -j -v "+"$ADD_SECONDS"S" -f %Y%m%d-%H%M%S $base_timestamp  +%Y-%m-%d\ %H:%M:00.)
                  #echo $my_timestamp

                  # Replace in the file to be injected
                  line=${line//MY_TIMESTAMP/$my_timestamp}

                  # Write line to temp file
                  echo $line >> $WORKING_DIR_OUTPUT"/tararam.dt_metric_value.csv"
                  #echo $line 

            done < "$WORKING_DIR_TEMPLATES/$actFile"

            #cat /tmp/timestampedMetricFile.json
      done
      echo "STEP DONE AT:"$my_timestamp| sed 's/^/            /'
      echo ""

      if [[ $LOOP_COUNT -gt $MAX_ITERATIONS ]]; then
            echo "        Done Iterating..."
            break
      fi

done 

echo ""
echo ""
echo "***************************************************************************************************************************************"
echo "***************************************************************************************************************************************"
echo ""
echo " Synthetic Metric Files can be found here:"
echo "    $WORKING_DIR_OUTPUT"
echo ""
echo " Original Metric Files can be found here:"
echo "    $WORKING_DIR_DUMPS"
echo ""
echo ""






echo "***************************************************************************************************************************************"
echo "***************************************************************************************************************************************"
echo " 🚀   LOAD files into Cassandra tables from $WORKING_DIR_OUTPUT" 
echo "***************************************************************************************************************************************"
echo "***************************************************************************************************************************************"
echo ""

read -p "  Do you want to load the new synthetic data into Cassandra❓ [y,N] " DO_COMM
if [[ $DO_COMM == "y" ||  $DO_COMM == "Y" ]]; then

      echo  ""    
      echo  ""
      echo "     --------------------------------------------------------------------------------------------"
      echo "     💾 Copy files to Pod filesystem (you can ignore rsync not available in container)"
      oc exec -ti aiops-topology-cassandra-0 -- bash -c "rm /tmp/tara*"| sed 's/^/           /'
      #ls -1 $WORKING_DIR_OUTPUT| sed 's/^/           /'
      oc rsync $WORKING_DIR_OUTPUT/ aiops-topology-cassandra-0:/tmp/| sed 's/^/           /'


      echo  ""    
      echo  ""
      echo "     --------------------------------------------------------------------------------------------"
      echo "     🧻 Empty the tables"
      oc exec -ti aiops-topology-cassandra-0 -- bash -c "/opt/ibm/cassandra/bin/cqlsh --ssl -u \$CASSANDRA_USER -p \$CASSANDRA_PASS -e \"TRUNCATE  tararam.dt_metric_value;\""| sed 's/^/           /'
      oc exec -ti aiops-topology-cassandra-0 -- bash -c "/opt/ibm/cassandra/bin/cqlsh --ssl -u \$CASSANDRA_USER -p \$CASSANDRA_PASS -e \"TRUNCATE  tararam.md_metric_resource;\""| sed 's/^/           /'


      echo  ""    
      echo  ""
      echo "     --------------------------------------------------------------------------------------------"
      echo "     📥 Load the dumps"
      oc exec -ti aiops-topology-cassandra-0 -- bash -c "/opt/ibm/cassandra/bin/cqlsh --ssl -u \$CASSANDRA_USER -p \$CASSANDRA_PASS -e \"copy tararam.dt_metric_value from '/tmp/tararam.dt_metric_value.csv' with header=true;\""| sed 's/^/           /'
      oc exec -ti aiops-topology-cassandra-0 -- bash -c "/opt/ibm/cassandra/bin/cqlsh --ssl -u \$CASSANDRA_USER -p \$CASSANDRA_PASS -e \"copy tararam.md_metric_resource from '/tmp/tararam.md_metric_resource.csv' with header=true;\""| sed 's/^/           /'



      echo  ""    
      echo  ""
      echo "     --------------------------------------------------------------------------------------------"
      echo "     🔎 Check the data"
      oc exec -ti aiops-topology-cassandra-0 -- bash -c "/opt/ibm/cassandra/bin/cqlsh --ssl -u \$CASSANDRA_USER -p \$CASSANDRA_PASS -e \"SELECT COUNT(*) FROM tararam.dt_metric_value;\""| sed 's/^/           /'
      oc exec -ti aiops-topology-cassandra-0 -- bash -c "/opt/ibm/cassandra/bin/cqlsh --ssl -u \$CASSANDRA_USER -p \$CASSANDRA_PASS -e \"SELECT * FROM tararam.md_metric_resource;\""| sed 's/^/           /'


else
      echo "    ⚠️  Skipping"
      echo "--------------------------------------------------------------------------------------------"
      echo  ""    
      echo  ""
fi
      echo  ""    
      echo  ""
      echo  ""    
      echo  ""




echo "***************************************************************************************************************************************"
echo "***************************************************************************************************************************************"
echo ""
echo " 🚀  CP4WAIOPS Create Synthetic Metrics"
echo " ✅  Done..... "
echo ""
echo "***************************************************************************************************************************************"
echo "***************************************************************************************************************************************"


