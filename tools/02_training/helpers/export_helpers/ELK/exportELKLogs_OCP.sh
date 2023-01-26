#!/bin/bash
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ADAPT VALUES
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
oc project openshift-logging

ES_INDEX=app-000003

export routeES=`oc get route elasticsearch -o jsonpath={.spec.host}`
export token=$(oc whoami -t)
export ES_URL=https://$routeES



QUALITYTY_CHECKPOINT=2

#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# DO NOT MODIFY BELOW
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# fix sed issue on mac
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
SED="sed"
if [ "${OS}" == "darwin" ]; then
    SED="gsed"
    if [ ! -x "$(command -v ${SED})"  ]; then
    __output "This script requires $SED, but it was not found.  Perform \"brew install gnu-sed\" and try again."
    exit
    fi
fi


echo "         ________  __  ___     ___    ________       "     
echo "        /  _/ __ )/  |/  /    /   |  /  _/ __ \____  _____"
echo "        / // __  / /|_/ /    / /| |  / // / / / __ \/ ___/"
echo "      _/ // /_/ / /  / /    / ___ |_/ // /_/ / /_/ (__  ) "
echo "     /___/_____/_/  /_/    /_/  |_/___/\____/ .___/____/  "
echo "                                           /_/            "
echo ""
echo ""
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo ""
echo " 🚀  CP4WAIOPS Export ElasticSearch Logs from Index $ES_INDEX"
echo ""
echo "***************************************************************************************************************************************************"

#--------------------------------------------------------------------------------------------------------------------------------------------
#  Select the Index to export
#--------------------------------------------------------------------------------------------------------------------------------------------
echo "***************************************************************************************************************************************************"
echo "  ❓  Select the Index to export"
echo "***************************************************************************************************************************************************"

curl -tlsv1.2 --insecure -H "Authorization: Bearer ${token}" -XGET $ES_URL/_cat/indices | awk '{print $3}'
read -p "🔣 Copy Paste Index from above: " ES_INDEX
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""


#--------------------------------------------------------------------------------------------------------------------------------------------
#  Get First part of Index
#--------------------------------------------------------------------------------------------------------------------------------------------
echo "***************************************************************************************************************************************************"
echo "  🌏  Get first part of Index"
echo "***************************************************************************************************************************************************"

echo "curl -tlsv1.2 --insecure -H 'Authorization: Bearer ${token}' -H 'Content-Type: application/json' -s $ES_URL/$ES_INDEX/_search?scroll=1m -d @query.json"
response=$(curl -tlsv1.2 --insecure -H "Authorization: Bearer ${token}" -H'Content-Type: application/json' -s $ES_URL/$ES_INDEX/_search?scroll=1m -d @query.json)


scroll_id=$(echo $response | jq -r ._scroll_id)
hits_count=$(echo $response | jq -r '.hits.hits | length')
hits_so_far=hits_count


echo $response | jq -r '.hits.hits' > /tmp/es_export_temp.json

echo "      Got initial response with $hits_count hits and scroll ID $scroll_id"
echo "      ✅ OK"
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""

#--------------------------------------------------------------------------------------------------------------------------------------------
#  Get First part of Index
#--------------------------------------------------------------------------------------------------------------------------------------------
echo "***************************************************************************************************************************************************"
echo "  🌏  Get subsequent parts of Index"
echo "      Hit q-ENTER to stop loading at the next checkpoint (every $((QUALITYTY_CHECKPOINT+1)) scrolls)"
echo "***************************************************************************************************************************************************"
q_check_counter=0
while [ "$hits_count" != "0" ]; do
  response=$(curl -tlsv1.2 --insecure -H "Authorization: Bearer ${token}" -H'Content-Type: application/json' -s $ES_URL/_search/scroll -d "{ \"scroll\": \"1m\", \"scroll_id\": \"$scroll_id\" }")

  scroll_id=$(echo $response | jq -r ._scroll_id)
  hits_count=$(echo $response | jq -r '.hits.hits | length')
  hits_so_far=$((hits_so_far + hits_count))
  q_check_counter=$((q_check_counter+1))

  echo "Got response with $hits_count hits (hits so far: $hits_so_far), new scroll ID $scroll_id"

#--------------------------------------------------------------------------------------------------------------------------------------------
#  Check how many entries per element
#--------------------------------------------------------------------------------------------------------------------------------------------
  if [[ $q_check_counter -gt $QUALITYTY_CHECKPOINT ]];
  then
    echo "***************************************************************************************************************************************************"
    echo "  🔎 Checkpoint"
    echo "***************************************************************************************************************************************************"
    cat  /tmp/es_export_temp.json|jq '.[]| ._source.kubernetes.container_name' | sort | uniq -c
    echo "***************************************************************************************************************************************************"

    q_check_counter=0

    # Check if "q" was pressed
    read -r -s -t 1 holder; RETVAL=$holder
    if [[ $RETVAL == "q" ]];
    then
    echo "      🚚 Continuing..."
      break
    fi
    echo "***************************************************************************************************************************************************"

  fi
  echo $response | jq -r '.hits.hits' >> /tmp/es_export_temp.json
done
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""

cp /tmp/es_export_temp.json es_export_raw_$ES_INDEX.json


#--------------------------------------------------------------------------------------------------------------------------------------------
#  Formatting into NDJSON
#--------------------------------------------------------------------------------------------------------------------------------------------
echo "***************************************************************************************************************************************************"
echo "  🌏  Formatting into NDJSON"
echo "***************************************************************************************************************************************************"
cat /tmp/es_export_temp.json| tr '\n' ' ' > es_export_formatted_$ES_INDEX.json
${SED} -i 's/ //g' es_export_formatted_$ES_INDEX.json
${SED} -i 's/\[{/{/g' es_export_formatted_$ES_INDEX.json
${SED} -i 's/]},{/\]}\n\{/g' es_export_formatted_$ES_INDEX.json
${SED} -i 's/\]}\]/\]}/g' es_export_formatted_$ES_INDEX.json
echo "      ✅ OK"
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""




#--------------------------------------------------------------------------------------------------------------------------------------------
#  Final Check
#--------------------------------------------------------------------------------------------------------------------------------------------
# echo "***************************************************************************************************************************************************"
# echo "  🔎 Lines per element: Must be greater than 2000 for each element"
# echo "***************************************************************************************************************************************************"
#cat  ./es_export_formatted_$ES_INDEX.json|jq '._source.kubernetes.container.name' | sort | uniq -c
echo "***************************************************************************************************************************************************"
echo "  🔎 Total Lines"
echo "***************************************************************************************************************************************************"
wc -l es_export_formatted_$ES_INDEX.json
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""



echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo ""
echo ""
echo "     📂 Your files are here ./es_export_formatted_$ES_INDEX.json"
echo "                            ./es_export_raw_$ES_INDEX.json"
echo ""
echo ""
echo " 🚀  CP4WAIOPS Export ElasticSearch Logs from Index $ES_INDEX"
echo " ✅  Done..... "
echo ""
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"

