echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
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
echo " 🚀  CP4WAIOPS Inject Logs through Kafka"
echo ""
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"



export LOG_TYPE=elk   # humio, elk, splunk, ...
echo "   "
echo "   "




echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "    🔬 Getting Installation Namespace"
echo "   ------------------------------------------------------------------------------------------------------------------------------"

export WAIOPS_NAMESPACE=$(oc get po -A|grep aiops-orchestrator-controller |awk '{print$1}')
echo "       ✅ OK - CP4WAIOps:    $WAIOPS_NAMESPACE"

echo " "
echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   🚀  Initializing..."
echo "   ------------------------------------------------------------------------------------------------------------------------------"

echo "     📥 Get Working Directories"
export WORKING_DIR_LOGS="./logs"


echo "     📥 Get Kafka Topics"
export KAFKA_TOPIC_LOGS=$(oc get kafkatopics -n $WAIOPS_NAMESPACE | grep cp4waiops-cartridge-logs-$LOG_TYPE| awk '{print $1;}')

if [[ "${KAFKA_TOPIC_LOGS}" == "" ]]; then
    echo "          ❗ Please define a Kafka connection in CP4WAIOps of type $LOG_TYPE."
    echo "          ❗ Existing Log Topics are:"
    oc get kafkatopics -n $WAIOPS_NAMESPACE | grep cp4waiops-cartridge-logs-| awk '{print $1;}'| sed 's/^/                /'
    echo ""
    echo "          ❌ Exiting....."
    #exit 1 

else
    echo "        🟢 OK"
fi


echo "     🔐 Get Kafka Password"
export KAFKA_SECRET=$(oc get secret -n $WAIOPS_NAMESPACE |grep 'aiops-kafka-secret'|awk '{print$1}')
export SASL_USER=$(oc get secret $KAFKA_SECRET -n $WAIOPS_NAMESPACE --template={{.data.username}} | base64 --decode)
export SASL_PASSWORD=$(oc get secret $KAFKA_SECRET -n $WAIOPS_NAMESPACE --template={{.data.password}} | base64 --decode)
export KAFKA_BROKER=$(oc get routes iaf-system-kafka-0 -n $WAIOPS_NAMESPACE -o=jsonpath='{.status.ingress[0].host}{"\n"}'):443


#------------------------------------------------------------------------------------------------------------------------------------
#  Get the cert for kafkacat
#------------------------------------------------------------------------------------------------------------------------------------
echo "     🥇 Getting Kafka Cert"
oc extract secret/kafka-secrets -n $WAIOPS_NAMESPACE --keys=ca.crt --confirm| sed 's/^/            /'
echo ""
echo ""




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
echo "     "
echo "       📂 Directory for Logs          : $WORKING_DIR_LOGS"
echo "   ----------------------------------------------------------------------------------------------------------------------------------------"
echo "   "
echo "   "
echo "   ----------------------------------------------------------------------------------------------------------------------------------------"
echo "     🗄️  Log Files to be loaded"
echo "   ----------------------------------------------------------------------------------------------------------------------------------------"
ls -1 $WORKING_DIR_LOGS | grep "json"| sed 's/^/          /'
echo "     "


echo "   "
echo "   "
echo "   ----------------------------------------------------------------------------------------------------------------------------------------"
echo "     🚀  Preparing Log Data"
echo "   ----------------------------------------------------------------------------------------------------------------------------------------"

for actFile in $(ls -1 $WORKING_DIR_LOGS | grep "json"); 
do 

#------------------------------------------------------------------------------------------------------------------------------------
#  Prepare the Data
#------------------------------------------------------------------------------------------------------------------------------------
    echo "   "
    echo "   "
    echo "   "
    echo "   "
    echo "      -------------------------------------------------------------------------------------------------------------------------------------"
    echo "        🛠️   Preparing Data for file $actFile"
    echo "      -------------------------------------------------------------------------------------------------------------------------------------"

    #------------------------------------------------------------------------------------------------------------------------------------
    #  Create file and structure in /tmp
    #------------------------------------------------------------------------------------------------------------------------------------
    mkdir /tmp/training-files-logs/  >/tmp/demo.log 2>&1 
    rm /tmp/training-files-logs/* 
    cp $WORKING_DIR_LOGS/$actFile /tmp/training-files-logs/logFile.json

    cd /tmp/training-files-logs/
    #------------------------------------------------------------------------------------------------------------------------------------
    #  Split the files in 1500 line chunks for kafkacat
    #------------------------------------------------------------------------------------------------------------------------------------
    echo "          🔨 Splitting Log File:"
    split -l 1500 ./logFile.json 
    export NUM_FILES=$(ls | wc -l)
    ls -1 /tmp/training-files-logs/x*| sed 's/^/             /'
    #cat xaa
    cd -  >/tmp/demo.log 2>&1 
    echo " "
    echo "          ✅ OK"

    echo "   "
    echo "      ----------------------------------------------------------------------------------------------------------------------------------------"
    echo "       🚀  Inject Log Files for file $actFile"
    echo "      ----------------------------------------------------------------------------------------------------------------------------------------"


    #------------------------------------------------------------------------------------------------------------------------------------
    #  Inject the Data
    #------------------------------------------------------------------------------------------------------------------------------------
    echo "         -------------------------------------------------------------------------------------------------------------------------------------"
    echo "          🌏  Injecting Log Anomaly Data" 
    echo "              Quit with Ctrl-Z"
    echo "         -------------------------------------------------------------------------------------------------------------------------------------"
    ACT_COUNT=0
    for FILE in /tmp/training-files-logs/*; do 
        if [[ $FILE =~ "x"  ]]; then
                ACT_COUNT=`expr $ACT_COUNT + 1`
                echo "          Injecting file ($ACT_COUNT/$(($NUM_FILES-1))) - $FILE"
                #echo "                 ${KAFKACAT_EXE} -v -X security.protocol=SASL_SSL -X ssl.ca.location=./ca.crt -X sasl.mechanisms=SCRAM-SHA-512  -X sasl.username=token -X sasl.password=$KAFKA_PASSWORD -b $KAFKA_BROKER -P -t $KAFKA_TOPIC_LOGS -l $FILE   "
                kcat -v -X security.protocol=SASL_SSL -X ssl.ca.location=./ca.crt -X sasl.mechanisms=SCRAM-SHA-512  -X sasl.username=$SASL_USER -X sasl.password=$SASL_PASSWORD -b $KAFKA_BROKER -P -t $KAFKA_TOPIC_LOGS -l $FILE
                echo "          ✅ OK"
                echo " "
        fi
    done


done


