
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# SIMULATE INCIDENT ON ROBOTSHOP
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



export APP_NAME=robot-shop
export LOG_TYPE=elk   # humio, elk, splunk, ...
export EVENTS_TYPE=noi
export EVENTS_SKEW="-120M"
export LOGS_SKEW="-90M"
export METRICS_SKEW="+0M"

#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# DO NOT MODIFY BELOW
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
clear

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
echo " 🚀  CP4WAIOPS Simulate Outage for $APP_NAME"
echo ""
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"

OS=$(uname -s | tr '[:upper:]' '[:lower:]')
if [ "${OS}" == "darwin" ]; then
      echo "       ✅ OK - MacOS"
else
      echo "❗ This tool currently only runs on Mac OS due to shell limitations."
      echo "❗ Please use the Demo Web UI for Incident simulation."
      echo "❌ Exiting....."
      exit 1 
fi

# Get Namespace from Cluster 
echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "    🔬 Getting Installation Namespace"
echo "   ------------------------------------------------------------------------------------------------------------------------------"

export WAIOPS_NAMESPACE=$(oc get po -A|grep aiops-orchestrator-controller |awk '{print$1}')
echo "       ✅ OK - CP4WAIOps:    $WAIOPS_NAMESPACE"



# Define Log format
export log_output_path=/dev/null 2>&1
export TYPE_PRINT="📝 "$(echo $TYPE | tr 'a-z' 'A-Z')


#------------------------------------------------------------------------------------------------------------------------------------
#  Check Defaults
#------------------------------------------------------------------------------------------------------------------------------------

if [[ $APP_NAME == "" ]] ;
then
      echo " ⚠️ AppName not defined. Launching this script directly?"
      echo "    Falling back to $DEFAULT_APP_NAME"
      export APP_NAME=$DEFAULT_APP_NAME
fi

if [[ $LOG_TYPE == "" ]] ;
then
      echo " ⚠️ Log Type not defined. Launching this script directly?"
      echo "    Falling back to humio"
      export LOG_TYPE=elk
fi

if [[ $EVENTS_TYPE == "" ]] ;
then
      echo " ⚠️ Event Type not defined. Launching this script directly?"
      echo "    Falling back to noi"
      export LOG_TYPE=noi
fi

oc project $WAIOPS_NAMESPACE  >/tmp/demo.log 2>&1  || true


export USER_PASS="$(oc get secret aiops-ir-core-ncodl-api-secret -o jsonpath='{.data.username}' | base64 --decode):$(oc get secret aiops-ir-core-ncodl-api-secret -o jsonpath='{.data.password}' | base64 --decode)"
oc apply -n $WAIOPS_NAMESPACE -f ./tools/01_demo/scripts/datalayer-api-route.yaml >/tmp/demo.log 2>&1  || true
sleep 2
export DATALAYER_ROUTE=$(oc get route  -n $WAIOPS_NAMESPACE datalayer-api  -o jsonpath='{.status.ingress[0].host}')


echo ""
echo ""
echo "   ------------------------------------------------------------------------------------------------------------------------------"
read  -t 5 -p "    ❓ Do you want to close existing Stories and Alerts❓ [y,N] " DO_COMM
echo "   ------------------------------------------------------------------------------------------------------------------------------"
if [[ $DO_COMM == "y" ||  $DO_COMM == "Y" ]]; then
      echo ""
      echo ""
      echo "   ------------------------------------------------------------------------------------------------------------------------------"
      echo "   🚀  ❎ Closing existing Stories and Alerts..."
      echo "   ------------------------------------------------------------------------------------------------------------------------------"

      export result=$(curl "https://$DATALAYER_ROUTE/irdatalayer.aiops.io/active/v1/stories" --insecure --silent -X PATCH -u "${USER_PASS}" -d '{"state": "resolved"}' -H 'Content-Type: application/json' -H "x-username:admin" -H "x-subscription-id:cfd95b7e-3bc7-4006-a4a8-a73a79c71255")
      echo "       Stories closed: "$(echo $result | jq ".affected")

      #export result=$(curl "https://$DATALAYER_ROUTE/irdatalayer.aiops.io/active/v1/alerts?filter=type.classification%20%3D%20%27robot-shop%27" --insecure --silent -X PATCH -u "${USER_PASS}" -d '{"state": "closed"}' -H 'Content-Type: application/json' -H "x-username:admin" -H "x-subscription-id:cfd95b7e-3bc7-4006-a4a8-a73a79c71255")
      export result=$(curl "https://$DATALAYER_ROUTE/irdatalayer.aiops.io/active/v1/alerts" --insecure --silent -X PATCH -u "${USER_PASS}" -d '{"state": "closed"}' -H 'Content-Type: application/json' -H "x-username:admin" -H "x-subscription-id:cfd95b7e-3bc7-4006-a4a8-a73a79c71255")
      echo "       Alerts closed: "$(echo $result | jq ".affected")
      #curl "https://$DATALAYER_ROUTE/irdatalayer.aiops.io/active/v1/alerts" -X GET -u "${USER_PASS}" -H "x-username:admin" -H "x-subscription-id:cfd95b7e-3bc7-4006-a4a8-a73a79c71255" | grep '"state": "open"' | wc -l
fi





echo ""
echo ""
echo "   ------------------------------------------------------------------------------------------------------------------------------"
read  -t 5 -p "    ❓ Do you want to open the webpages for the demo❓ [y,N] " DO_COMM
echo "   ------------------------------------------------------------------------------------------------------------------------------"
if [[ $DO_COMM == "y" ||  $DO_COMM == "Y" ]]; then
      export DEMOUI_ROUTE="http://"$(oc get route -n $WAIOPS_NAMESPACE waiops-demo-ui-python -o jsonpath={.spec.host})
      export CP4WAIOPS_ROUTE="https://"$(oc get route -n $WAIOPS_NAMESPACE cpd -o jsonpath={.spec.host})
      export ROBOTSHOP_ROUTE="http://"$(oc get routes -n robot-shop web  -o jsonpath="{['spec']['host']}")|| true
      export AWX_ROUTE="http://"$(oc get route -n awx awx -o jsonpath={.spec.host})|| true

      echo ""
      echo ""
      echo ""      
      echo "            📥 CP4WAIOps"
      echo ""
      echo "                🌏 URL:           $CP4WAIOPS_ROUTE"
      echo "                🧑 User:          demo"
      echo "                🔐 Password:      P4ssw0rd!"
      echo ""    
      echo "                🧑 User:          $(oc -n ibm-common-services get secret platform-auth-idp-credentials -o jsonpath='{.data.admin_username}' | base64 --decode && echo)"
      echo "                🔐 Password:      $(oc -n ibm-common-services get secret platform-auth-idp-credentials -o jsonpath='{.data.admin_password}' | base64 --decode)"
      echo ""
      echo ""
      echo ""
      appToken=$(oc get cm -n $WAIOPS_NAMESPACE demo-ui-python-config -o jsonpath='{.data.TOKEN}')
      echo "            📥 Demo UI:"   
      echo "    " 
      echo "                🌏 URL:           $DEMOUI_ROUTE"
      echo "                🔐 Token:         $(oc get cm -n $WAIOPS_NAMESPACE demo-ui-python-config -o jsonpath='{.data.TOKEN}' && echo)"
      echo ""
      echo ""
      echo ""
      echo "            📥 RobotShop:"   
      echo "    " 
      echo "                🌏 APP URL:      $ROBOTSHOP_ROUTE"
      echo ""
      echo ""
      echo ""
      echo "            📥 AWX :"
      echo ""
      echo "                🌏 URL:           $AWX_ROUTE"
      echo "                🧑 User:          admin"
      echo "                🔐 Password:      $(oc -n awx get secret awx-admin-password -o jsonpath='{.data.password}' | base64 --decode && echo)"

      echo ""
      echo ""
      echo ""
      echo ""
      echo ""
      echo ""



      if [ -x "$(command -v open)" ]; then
      open $DEMOUI_ROUTE
      open $AWX_ROUTE"/#/jobs"
      open $CP4WAIOPS_ROUTE"/aiops/cfd95b7e-3bc7-4006-a4a8-a73a79c71255/resolution-hub/stories"
      open $ROBOTSHOP_ROUTE
      else 
      if [ -x "$(command -v firefox)" ]; then
            firefox $DEMOUI_ROUTE
            firefox $AWX_ROUTE"/#/jobs"
            firefox $CP4WAIOPS_ROUTE"/aiops/cfd95b7e-3bc7-4006-a4a8-a73a79c71255/resolution-hub/stories"
            firefox $ROBOTSHOP_ROUTE
      else 
            if [ -x "$(command -v google-chrome)" ]; then
            google-chrome $DEMOUI_ROUTE
            google-chrome $AWX_ROUTE"/#/jobs"
            google-chrome $CP4WAIOPS_ROUTE"/aiops/cfd95b7e-3bc7-4006-a4a8-a73a79c71255/resolution-hub/stories"
            google-chrome $ROBOTSHOP_ROUTE
            fi
      fi
      fi
fi

#------------------------------------------------------------------------------------------------------------------------------------
#  Deactivating MYSQL Service
#------------------------------------------------------------------------------------------------------------------------------------
echo " "
echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   🚀  Deactivating MYSQL Service for Demo Scenario..."
echo "   ------------------------------------------------------------------------------------------------------------------------------"
oc set env deployment ratings -n robot-shop PDO_URL="mysql:host=mysql;dbname=ratings-dev;charset=utf8mb4"
oc set env deployment load -n robot-shop ERROR=1



#------------------------------------------------------------------------------------------------------------------------------------
#  Get Credentials
#------------------------------------------------------------------------------------------------------------------------------------
echo " "
echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   🚀  Initializing..."
echo "   ------------------------------------------------------------------------------------------------------------------------------"



echo "     📥 Get Kafka Topics"
export KAFKA_TOPIC_LOGS=$(oc get kafkatopics -n $WAIOPS_NAMESPACE | grep cp4waiops-cartridge-logs-$LOG_TYPE| awk '{print $1;}')

echo " "
echo "     🔐 Get Kafka Password"
export KAFKA_SECRET=$(oc get secret -n $WAIOPS_NAMESPACE |grep 'aiops-kafka-secret'|awk '{print$1}')
export SASL_USER=$(oc get secret $KAFKA_SECRET -n $WAIOPS_NAMESPACE --template={{.data.username}} | base64 --decode)
export SASL_PASSWORD=$(oc get secret $KAFKA_SECRET -n $WAIOPS_NAMESPACE --template={{.data.password}} | base64 --decode)
export KAFKA_BROKER=$(oc get routes iaf-system-kafka-0 -n $WAIOPS_NAMESPACE -o=jsonpath='{.status.ingress[0].host}{"\n"}'):443
echo " "

echo "     📥 Get Working Directories"
export WORKING_DIR_LOGS="./tools/01_demo/INCIDENT_FILES/$APP_NAME/logs"
export WORKING_DIR_EVENTS="./tools/01_demo/INCIDENT_FILES/$APP_NAME/events_rest"
export WORKING_DIR_METRICS="./tools/01_demo/INCIDENT_FILES/$APP_NAME/metrics"

echo " "

echo "     📥 Get Date Formats"


OS=$(uname -s | tr '[:upper:]' '[:lower:]')
if [ "${OS}" == "darwin" ]; then
      # Suppose we're on Mac
      export DATE_FORMAT_EVENTS="-v$EVENTS_SKEW +%Y-%m-%dT%H:%M:%S"
      #export DATE_FORMAT_EVENTS="+%Y-%m-%dT%H:%M"
else
      # Suppose we're on a Linux flavour
      export DATE_FORMAT_EVENTS="-d$EVENTS_SKEW +%Y-%m-%dT%H:%M:%S" 
      #export DATE_FORMAT_EVENTS="+%Y-%m-%dT%H:%M" 
fi


OS=$(uname -s | tr '[:upper:]' '[:lower:]')
if [ "${OS}" == "darwin" ]; then
      # Suppose we're on Mac
      export DATE_FORMAT_LOGS="-v$LOGS_SKEW +%Y-%m-%dT%H:%M:%S.000000+00:00"
      #export DATE_FORMAT_LOGS="-v$LOGS_SKEW +%Y-%m-%dT%H:%M:%S.000000+00:00"
      # HUMIO export DATE_FORMAT_LOGS="+%s000"
else
      # Suppose we're on a Linux flavour
      export DATE_FORMAT_LOGS="-d$LOGS_SKEW +%Y-%m-%dT%H:%M:%S.000000+00:00"
      #export DATE_FORMAT_LOGS="-d$LOGS_SKEW +%Y-%m-%dT%H:%M:%S.000000+00:00" 
      # HUMIO export DATE_FORMAT_LOGS="+%s000"
fi

echo " "


#------------------------------------------------------------------------------------------------------------------------------------
#  Get Kafkacat executable
#------------------------------------------------------------------------------------------------------------------------------------
echo "     📥  Getting Kafkacat executable"
if [ -x "$(command -v kafkacat)" ]; then
      export KAFKACAT_EXE=kafkacat
else
      if [ -x "$(command -v kcat)" ]; then
            export KAFKACAT_EXE=kcat
      else
            echo "     ❗ ERROR: kafkacat is not installed."
            echo "     ❌ Aborting..."
            exit 1
      fi
fi
echo " "

#------------------------------------------------------------------------------------------------------------------------------------
#  Get the cert for kafkacat
#------------------------------------------------------------------------------------------------------------------------------------
echo "     🥇 Getting Kafka Cert"
oc extract secret/kafka-secrets -n $WAIOPS_NAMESPACE --keys=ca.crt --confirm  >/tmp/demo.log 2>&1  || true
echo "      ✅ OK"



#------------------------------------------------------------------------------------------------------------------------------------
#  Check Credentials
#------------------------------------------------------------------------------------------------------------------------------------
echo " "
echo " "
echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   🔗  Checking credentials"
echo "   ------------------------------------------------------------------------------------------------------------------------------"

if [[ $KAFKA_TOPIC_LOGS == "" ]] ;
then
      echo " ❌ Please create the $LOG_TYPE Kafka Log Integration. Aborting..."
      exit 1
else
      echo "       ✅ OK - Logs Topic"
fi


if [[ $KAFKA_BROKER == "" ]] ;
then
      echo " ❌ Make sure that your Kafka instance is accesssible. Aborting..."
      exit 1
else
      echo "       ✅ OK - Kafka Broker"
fi

echo " "
echo " "
echo " "
echo " "



echo "   ----------------------------------------------------------------------------------------------------------------------------------------"
echo "     🔎  Parameters for Incident Simulation for $APP_NAME"
echo "   ----------------------------------------------------------------------------------------------------------------------------------------"
echo "     "
echo "       🗂  Log Topic                   : $KAFKA_TOPIC_LOGS"
echo "       🌏 Kafka Broker URL            : $KAFKA_BROKER"
echo "       🔐 Kafka User                  : $SASL_USER"
echo "       🔐 Kafka Password              : $SASL_PASSWORD"
echo "       🖥️  Kafka Executable            : $KAFKACAT_EXE"
echo "     "
echo "       📝 Log Type                    : $LOG_TYPE"
echo "       📅 Date Format Logs            : $DATE_FORMAT_LOGS"
echo "       📝 Events Type                 : $EVENTS_TYPE"
echo "       📅 Date Format Events          : $DATE_FORMAT_EVENTS"
echo "     "
echo "       📂 Directory for Logs          : $WORKING_DIR_LOGS"
echo "       📂 Directory for Events        : $WORKING_DIR_EVENTS"
echo "   ----------------------------------------------------------------------------------------------------------------------------------------"
echo "   "
echo "   "
echo "   ----------------------------------------------------------------------------------------------------------------------------------------"
echo "     🗄️  Log Files to be loaded"
echo "   ----------------------------------------------------------------------------------------------------------------------------------------"
ls -1 $WORKING_DIR_LOGS | grep "json"
echo "     "

echo "   ----------------------------------------------------------------------------------------------------------------------------------------"
echo "     🗄️  Event Files to be loaded"
echo "   ----------------------------------------------------------------------------------------------------------------------------------------"
ls -1 $WORKING_DIR_EVENTS | grep "json"
echo "     "
echo "   ----------------------------------------------------------------------------------------------------------------------------------------"



#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# RUNNING Injection
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# # Inject the Events Inception files
# ./tools/01_demo/scripts/simulate-events-rest.sh

# # Prepare the Log Inception files
# ./tools/01_demo/scripts/prepare-logs-fast.sh

# # Inject the Log Inception files
# ./tools/01_demo/scripts/simulate-logs.sh 

# # Inject the Metric Anomalies
./tools/01_demo/scripts/simulate-metrics-ok-past.sh
#./tools/01_demo/scripts/simulate-metrics_predict.sh

# # Inject the Log Inception files
# ./tools/01_demo/scripts/simulate-logs.sh 
# ./tools/01_demo/scripts/simulate-logs.sh 
# ./tools/01_demo/scripts/simulate-logs.sh 

export result=$(curl "https://$DATALAYER_ROUTE/irdatalayer.aiops.io/active/v1/stories" --insecure --silent -X PATCH -u "${USER_PASS}" -d '{"priority": 1,"state": "inProgress","owner": "demo","team": "All users"}' -H 'Content-Type: application/json' -H "x-username:admin" -H "x-subscription-id:cfd95b7e-3bc7-4006-a4a8-a73a79c71255")
echo "       Stories assigned: "$(echo $result | jq ".affected")


echo " "
echo " "
echo " "
echo " "
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo ""
echo " 🚀  CP4WAIOPS Simulate Outage for $APP_NAME"
echo "  ✅  Done..... "
echo ""
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
