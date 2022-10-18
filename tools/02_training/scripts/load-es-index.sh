#!/bin/bash
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	
# DO NOT MODIFY BELOW	
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	


echo "   ***************************************************************************************************************************************"	
echo "    🚀  Load \"$INDEX_TYPE\" Indexes for $APP_NAME"	
echo "     "	

#--------------------------------------------------------------------------------------------------------------------------------------------	
#  Check Defaults	
#--------------------------------------------------------------------------------------------------------------------------------------------	

if [[ $APP_NAME == "" ]] ;	
then	
      echo "     ⚠️ AppName not defined. Launching this script directly?"	
      echo "     ❌ Aborting..."	
      exit 1	
fi	

if [[ $INDEX_TYPE == "" ]] ;	
then	
      echo "     ⚠️ Index Type not defined. Launching this script directly?"	
      echo "     ❌ Aborting..."	
      exit 1	
fi	



#--------------------------------------------------------------------------------------------------------------------------------------------	
#  Get Credentials	
#--------------------------------------------------------------------------------------------------------------------------------------------	

echo "     ------------------------------------------------------------------------------------------------------------------------------"
echo "       🔐  Getting credentials"	
echo "     ------------------------------------------------------------------------------------------------------------------------------"
oc project $WAIOPS_NAMESPACE > /dev/null 2>&1	


export username=$(oc get secret $(oc get secrets | grep elastic-secret | awk '!/-min/' | awk '{print $1;}') -o jsonpath="{.data.username}"| base64 --decode)	
export password=$(oc get secret $(oc get secrets | grep elastic-secret | awk '!/-min/' | awk '{print $1;}') -o jsonpath="{.data.password}"| base64 --decode)	

export WORKING_DIR_ES="./tools/02_training/TRAINING_FILES/ELASTIC/$APP_NAME/$INDEX_TYPE"	


echo "           ✅ Credentials:               OK"	

echo "     ------------------------------------------------------------------------------------------------------------------------------"
echo "       🔐  Elasticsearch credentials"	
echo "     ------------------------------------------------------------------------------------------------------------------------------"

if [[ $username == "" ]] ;	
then	
      echo "     ❌ Could not get Elasticsearch Username. Aborting..."	
      exit 1	
fi	

if [[ $password == "" ]] ;	
then	
      echo "     ❌ Could not get Elasticsearch Password. Aborting..."	
      exit 1	
fi	


echo ""	
echo "           📥 App Name:                     $APP_NAME"
echo "           🧰 Index Type:                   $INDEX_TYPE"	
echo ""	
echo "           🙎‍♂️ User:                         $username"	
echo "           🔐 Password:                     $password"	
echo ""	
echo "          ❗ Overwrite existing indexes:    $INDEX_OVERWRITE"
echo ""	
echo "          📂 Working Directory:             $WORKING_DIR_ES"
echo ""
echo ""


#ls -Ral ./tools/02_training/TRAINING_FILES| sed 's/^/          /'


export ES_FILES=$(ls -1 $WORKING_DIR_ES | grep "json")	
if [[ $ES_FILES == "" ]] ;	
then	
      echo "           ❗ No Elasticsearch import files found"	
      echo "           ❗    No Elasticsearch import files found to ingest in path $WORKING_DIR_LOGS"	
      echo "           ❗    Please place them in the directory."	
      echo "           ❌ Aborting..."	
      exit 1	
else	
      echo "           ✅ Log Files:                 OK"	
fi	
echo "     "	


#--------------------------------------------------------------------------------------------------------------------------------------------	
#  Check Credentials	
#--------------------------------------------------------------------------------------------------------------------------------------------	

echo "     ------------------------------------------------------------------------------------------------------------------------------"
echo "       🗄️  Indexes to be loaded from $WORKING_DIR_ES"	
echo "     ------------------------------------------------------------------------------------------------------------------------------"
ls -1 $WORKING_DIR_ES | grep "json"	 | sed 's/^/          /'
echo "       "	
echo "       "	


#--------------------------------------------------------------------------------------------------------------------------------------------	
#  Import Indexes	
#--------------------------------------------------------------------------------------------------------------------------------------------	
echo "     ------------------------------------------------------------------------------------------------------------------------------"
echo "       🔬  Getting exising Indexes"
echo "     ------------------------------------------------------------------------------------------------------------------------------"

export existingIndexes=$(curl -s -k -u $username:$password -XGET https://localhost:9200/_cat/indices)


if [[ $existingIndexes == "" ]] ;
then
    echo "        ❗ Please start port forward in separate terminal."
    echo "        ❗ Run the following:"
    echo "            while true; do oc port-forward statefulset/iaf-system-elasticsearch-es-aiops 9200; done"
    echo "        ❌ Aborting..."
    echo "     "
    echo "     "
    echo "     "
    echo "     "
    exit 1
fi

echo "     "





export NODE_TLS_REJECT_UNAUTHORIZED=0

for actFile in $(ls -1 $WORKING_DIR_ES | grep "json");
do
      if [[ $existingIndexes =~ "${actFile%".json"}" ]] ;
      then
            echo "        ❗  Index already exist in Cluster."
            if [ "$INDEX_OVERWRITE" = true ] ; then
                  #curl -k -u $username:$password -XGET https://localhost:9200/_cat/indices | grep ${actFile%".json"} | sort

                  echo "        ❗ Overwriting the index due to INDEX_OVERWRITE=true..."
                  echo "        ✅ Ok, continuing..."
                  echo "     "
                  echo "     "
                  echo "     ------------------------------------------------------------------------------------------------------------------------------"
                  echo "       ❌  Deleting Index: ${actFile%".json"}"
                  echo "     ------------------------------------------------------------------------------------------------------------------------------"
                  curl -k -u $username:$password -XDELETE https://$username:$password@localhost:9200/${actFile%".json"}
                  echo "     "
                  echo "     "
                  echo "     "
                  echo "     ------------------------------------------------------------------------------------------------------------------------------"
                  echo "       🛠️   Uploading Index: ${actFile%".json"}"
                  echo "     ------------------------------------------------------------------------------------------------------------------------------"

                  elasticdump --input="$WORKING_DIR_ES/${actFile}" --output=https://$username:$password@localhost:9200/${actFile%".json"} --type=data --limit=1000;
                  echo "        ✅  OK"
            else
                  echo "        ✅ Ok, skipping due to INDEX_OVERWRITE=false..."
                  echo "    "
            fi
      else 

            echo "     "
            echo "     ------------------------------------------------------------------------------------------------------------------------------"
            echo "       🛠️   Uploading Index: ${actFile%".json"}"
            echo "     ------------------------------------------------------------------------------------------------------------------------------"

            elasticdump --input="$WORKING_DIR_ES/${actFile}" --output=https://$username:$password@localhost:9200/${actFile%".json"} --type=data --limit=1000;
            echo "        ✅  OK"


      fi
    
    
done
