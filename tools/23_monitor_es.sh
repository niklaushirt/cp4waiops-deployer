#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#       __________  __ ___       _____    ________            
#      / ____/ __ \/ // / |     / /   |  /  _/ __ \____  _____
#     / /   / /_/ / // /| | /| / / /| |  / // / / / __ \/ ___/
#    / /___/ ____/__  __/ |/ |/ / ___ |_/ // /_/ / /_/ (__  ) 
#    \____/_/      /_/  |__/|__/_/  |_/___/\____/ .___/____/  
#                                              /_/            
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------------------------------------------------------------------"
#  CP4WAIOPS - Monitor Elastic Search Indexes
#
#
#  ©2022 nikh@ch.ibm.com
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
clear

echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo "  "
echo "  🚀 CloudPak for Watson AIOps - Monitor Elastic Search Indexes"
echo "  "
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo "  "
echo "  "
export TEMP_PATH=~/aiops-install

echo "  Initializing......"



export WAIOPS_NAMESPACE=$(oc get po -A|grep aiops-orchestrator-controller |awk '{print$1}')


export LOG_TYPE=elk   # humio, elk, splunk, ...




echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo " 🚀 AI OPS DEBUG - ElastcSearch"
echo "***************************************************************************************************************************************************"

echo "  Initializing......"







#--------------------------------------------------------------------------------------------------------------------------------------------
#  Get Credentials
#--------------------------------------------------------------------------------------------------------------------------------------------

echo "***************************************************************************************************************************************************"
echo "  🔐  Getting credentials"
echo "***************************************************************************************************************************************************"
oc project $WAIOPS_NAMESPACE

export username=$(oc get secret $(oc get secrets | grep elastic-secret | awk '!/-min/' | awk '{print $1;}') -o jsonpath="{.data.username}"| base64 --decode)
export password=$(oc get secret $(oc get secrets | grep elastic-secret | awk '!/-min/' | awk '{print $1;}') -o jsonpath="{.data.password}"| base64 --decode)

export WORKING_DIR_ES="./training/TRAINING_FILES/ELASTIC/$APP_NAME/$INDEX_TYPE"


echo "      ✅ OK"
echo ""
echo ""





#--------------------------------------------------------------------------------------------------------------------------------------------
#  Check Credentials
#--------------------------------------------------------------------------------------------------------------------------------------------

echo "***************************************************************************************************************************************************"
echo "  🔗  Checking credentials"
echo "***************************************************************************************************************************************************"

if [[ $username == "" ]] ;
then
      echo "❌ Could not get Elasticsearch Username. Aborting..."
      exit 1
else
      echo "      ✅ OK - Elasticsearch Username"
fi

if [[ $password == "" ]] ;
then
      echo "❌ Could not get Elasticsearch Password. Aborting..."
      exit 1
else
      echo "      ✅ OK - Elasticsearch Password"
fi



echo ""
echo ""
echo ""
echo ""






echo "    ***************************************************************************************************************************************************"
echo "      🛠️   Getting exising Indexes"
echo "    ***************************************************************************************************************************************************"

export existingIndexes=$(curl -s -k -u $username:$password -XGET https://localhost:9200/_cat/indices)


if [[ $existingIndexes == "" ]] ;
then
      echo "❗ Please start port forward in separate terminal."
      echo "❗ Run:"
      echo "    ./tools/28_access_elastic.sh"
      echo "❗ or run the following:"
      echo "    while true; do oc port-forward statefulset/$(oc get statefulset | grep es-server-all | awk '{print $1}') 9200; done"
      echo "❌ Aborting..."
      exit 1
fi
echo "      ✅ OK"
echo ""
echo ""




















#!/bin/bash
menu_option_1 () {
  echo "ElastcSearch Indexes"
  export NODE_TLS_REJECT_UNAUTHORIZED=0
  curl -k -u $username:$password -XGET https://localhost:9200/_cat/indices | sort
  echo ""
  echo ""
  echo ""
  echo "Press Enter to continue"
  read selection

}

menu_option_2() {
  echo "ES Indexes - LOGS"
  curl -k -u $username:$password -XGET https://localhost:9200/_cat/indices | grep "1000-1000"| sort
  echo ""
  echo ""
  echo ""
  echo "Press Enter to continue"
  read selection
}


menu_option_3() {
  echo "ES Indexes - LOG TRAIN"
  curl -k -u $username:$password -XGET https://localhost:9200/_cat/indices | grep "logtrain"| sort
  echo ""
  echo ""
  echo ""
  echo "Press Enter to continue"
  read selection
}


menu_option_4() {
  echo "ES Indexes - INCIDENTS"
  curl -k -u $username:$password -XGET https://localhost:9200/_cat/indices | grep -E "snow|incidenttrain"| sort
  echo ""
  echo ""
  echo ""
  echo "Press Enter to continue"
  read selection
}

menu_option_5() {
  echo "ElastcSearch Indexes"
  curl -k -u $username:$password -XGET https://localhost:9200/prechecktrainingdetails/_search | jq "."
  echo ""
  echo ""
  echo ""
  echo "Press Enter to continue"
  read selection

}

menu_option_6() {
  echo "ElastcSearch Indexes"
  curl -k -u $username:$password -XGET https://localhost:9200/postchecktrainingdetails/_search | jq "."
  echo ""
  echo ""
  echo ""
  echo "Press Enter to continue"
  read selection
  clear

}



clear





echo "***************************************************************************************************************************************************"
echo "  "



until [ "$selection" = "0" ]; do
  
  echo ""
  
  echo "  🔎 Observe ES Indexes "
  echo "    	1  - Get all ES Indexes"
  echo ""
  echo "    	2  - Get ES Indexes - LOGS"
  echo "    	3  - Get ES Indexes - LOGS TRAIN"
  echo ""
  echo "    	4  - Get ES Indexes - SNOW INCIDENTS"
  echo ""
  echo "    	5  - Pre Check Training details"
  echo "    	6  - Post Check Training details"
  echo "      "
  echo "    	0  -  Exit"
  echo ""
  echo ""
  echo "           🙎‍♂️ User                        : $username"
  echo "           🔐 Password                    : $password"
  echo ""
  echo ""
  echo ""

  echo "  Enter selection: "
  read selection
  echo ""

  case $selection in
    1 ) clear ; menu_option_1  ;;
    2 ) clear ; menu_option_2  ;;
    3 ) clear ; menu_option_3  ;;
    4 ) clear ; menu_option_4  ;;
    5 ) clear ; menu_option_5  ;;
    6 ) clear ; menu_option_6  ;;

    0 ) clear ; exit ;;
    * ) clear ; incorrect_selection  ;;
  esac
done







