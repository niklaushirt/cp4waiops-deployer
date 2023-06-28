
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# SIMULATE INCIDENT ON ROBOTSHOP
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



export APP_NAME=acme
export LOG_TYPE=elk   # humio, elk, splunk, ...
export EVENTS_TYPE=noi
export EVENTS_SKEW="-120M"
export LOGS_SKEW="0M"
export METRICS_SKEW="+5M"

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
      echo "OK"
else
      echo "❗ This tool currently only runs on Mac OS due to shell limitations."
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


#------------------------------------------------------------------------------------------------------------------------------------
#  Get Credentials
#------------------------------------------------------------------------------------------------------------------------------------
echo " "
echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   🚀  Initializing..."
echo "   ------------------------------------------------------------------------------------------------------------------------------"



echo " "

echo "     📥 Get Working Directories"
export WORKING_DIR_LOGS="./tools/01_demo/INCIDENT_FILES/$APP_NAME/logs"
export WORKING_DIR_EVENTS="./tools/01_demo/INCIDENT_FILES/$APP_NAME/events_rest"
export WORKING_DIR_METRICS="./tools/01_demo/INCIDENT_FILES/$APP_NAME/metrics"

echo "     📥 Get ASM Connection"
export TOPOLOGY_REST_USR=$(oc get secret aiops-topology-asm-credentials -n $WAIOPS_NAMESPACE -o jsonpath='{.data.username}' | base64 --decode)
export TOPOLOGY_REST_PWD=$(oc get secret aiops-topology-asm-credentials -n $WAIOPS_NAMESPACE -o jsonpath='{.data.password}' | base64 --decode)
export TOPO_ROUTE="https://"$(oc get route -n $WAIOPS_NAMESPACE topology-rest -o jsonpath={.spec.host})
export LOGIN="$TOPOLOGY_REST_USR:$TOPOLOGY_REST_PWD"




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



# curl -X "POST" "$TOPO_ROUTE/1.0/rest-observer/rest/resources" --insecure -H 'Content-Type: application/json' -u $LOGIN -H 'JobId: restTopology' -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -d $'{  "status":"not available", "dataCenter": "demo","architecture": "x86_64",  "cpuName": "DCWest1-Rack045-DELL3762-cpu",  "entityTypes": ["server"],  "hypervisor": "vsphere",  "matchTokens": ["DCWest1-Rack045-DELL3762"],  "monitoring-state": "disabled",  "name": "Baremetal DCWest1-Rack045-DELL3762",  "privateDnsName": "ip-172-31-22-67.dcwest1.compute.internal",  "privateIpAddress": "172.31.22.67",  "publicDnsName": "ec2-3-72-4-84.dcwest1.compute.amazonaws.com",  "publicIpAddress": "3.72.4.84",  "ramdiskId": "",  "requesterId": "",  "rootDeviceName": "/dev/sda1",  "rootDeviceType": "ebs",  "tags": ["Name:CustomerRelations", "DCWest1-Rack045-DELL3762"],  "uniqueId": "DCWest1-Rack045-DELL3762",  "vertexType": "resource",  "virtualizationType": "vsphere"}'
# curl -X "POST" "$TOPO_ROUTE/1.0/rest-observer/rest/resources" --insecure -H 'Content-Type: application/json' -u $LOGIN -H 'JobId: restTopology' -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -d $'{  "status":"not found", "dataCenter": "demo","architecture": "x86_64",  "cpuName": "DCW1-000483-cpu",  "entityTypes": ["vm"],  "hypervisor": "vsphere",  "matchTokens": ["DCW1-000483"],  "monitoring-state": "disabled",  "name": "VM DCW1-000483",  "privateDnsName": "ip-172-31-22-67.dcwest1.compute.internal",  "privateIpAddress": "172.31.22.67",  "publicDnsName": "ec2-3-72-4-84.dcwest1.compute.amazonaws.com",  "publicIpAddress": "3.72.4.84",  "ramdiskId": "",  "requesterId": "",  "rootDeviceName": "/dev/sda1",  "rootDeviceType": "ebs",  "tags": ["Name:CustomerRelations", "DCW1-000483"],  "uniqueId": "DCW1-000483",  "vertexType": "resource",  "virtualizationType": "vsphere"}'
# curl -X "POST" "$TOPO_ROUTE/1.0/rest-observer/rest/resources" --insecure -H 'Content-Type: application/json' -u $LOGIN -H 'JobId: restTopology' -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -d $'{  "status":"degraded", "dataCenter": "demo","dataCenter": "demo",  "entityTypes": ["cluster"],  "matchTokens": ["PROD-027-OCP001"],  "name": "K8s Cluster PROD-027-OCP001",  "tags": [],  "vertexType": "resource",  "uniqueId": "PROD-027-OCP001"}'
# curl -X "POST" "$TOPO_ROUTE/1.0/rest-observer/rest/resources" --insecure -H 'Content-Type: application/json' -u $LOGIN -H 'JobId: restTopology' -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -d $'{  "status":"not ready", "dataCenter": "demo","bootID": "c0dd874c-5c15-413d-b869-f460cb4ee65c",  "containerRuntimeVersion": "cri-o://1.21.6-2.rhaos4.8.gitb948fcd.el7",    "entityTypes": ["server"],  "hostname": "10.13.177.175",  "kernelVersion": "3.10.0-1160.62.1.el7.x86_64",  "kubeProxyVersion": "v1.21.8+ee73ea2",  "kubeletVersion": "v1.21.8+ee73ea2",    "machineID": "0865b9a9bc8944dd810f3626309faa7b",  "management": "N/A",  "matchTokens": ["worker-10.13.177.175","PROD-027-OCP001-WORKER01"],  "name": "Node PROD-027-OCP001-WORKER01",  "node_uid": "86c5007d-b47d-4e73-bbf3-b3c23087a5f7",    "pods_allocatable": "160",  "pods_capacity": "160",  "proxy": "N/A",  "role": "worker",  "systemUUID": "D015E6BB-83AC-8886-8606-4F6CC0BAEC06",  "tags": ["os:Red Hat", "robot-shop", "role:master"],  "uniqueId": "PROD-027-OCP001-WORKER01",  "vertexType": "resource"}'


# Inject the Metric Anomalies Fan/Temp
#./tools/01_demo/scripts/simulate-metrics-acme-temp.sh
./tools/01_demo/scripts/simulate-metrics-acme-app.sh


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



