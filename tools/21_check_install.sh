#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#         ________  __  ___     ___    ________       
#        /  _/ __ )/  |/  /    /   |  /  _/ __ \____  _____
#        / // __  / /|_/ /    / /| |  / // / / / __ \/ ___/
#      _/ // /_/ / /  / /    / ___ |_/ // /_/ / /_/ (__  ) 
#     /___/_____/_/  /_/    /_/  |_/___/\____/ .___/____/  
#                                           /_/
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------------------------------------------------------------------"
#  CP4WAIOPS  - Debug WAIOPS Installation
#
#
#  ©2023 nikh@ch.ibm.com
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
clear


echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo ""
echo "       ________  __  ___     ___    ________       "
echo "      /  _/ __ )/  |/  /    /   |  /  _/ __ \____  _____"
echo "      / // __  / /|_/ /    / /| |  / // / / / __ \/ ___/"
echo "    _/ // /_/ / /  / /    / ___ |_/ // /_/ / /_/ (__  ) "
echo "   /___/_____/_/  /_/    /_/  |_/___/\____/ .___/____/  "
echo "                                         /_/"
echo ""

echo "  "
echo "  🚀 CloudPak for Watson AIOps - Check Installation"
echo "  "
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo "  "
echo "  "




export TEMP_PATH=~/aiops-install
export ERROR_STRING=""
export ERROR=false






# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# Do Not Edit Below
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
function handleError(){
    if  ([[ $CURRENT_ERROR == true ]]); 
    then
        ERROR=true
        ERROR_STRING=$ERROR_STRING"\n⭕ $CURRENT_ERROR_STRING"
        echo "      "
        echo "      "
        echo "      ❗***************************************************************************************************************************************************"
        echo "      ❗***************************************************************************************************************************************************"
        echo "      ❗  ❌ The following error was found: "
        echo "      ❗"
        echo "      ❗      ⭕ $CURRENT_ERROR_STRING"; 
        echo "      ❗"
        echo "      ❗***************************************************************************************************************************************************"
        echo "      ❗***************************************************************************************************************************************************"
        echo "      "
        echo "      "

    fi
}



function check_array_crd(){

      echo ""
      echo ""
      echo "    --------------------------------------------------------------------------------------------"
      echo "    🔎 Check $CHECK_NAME"
      echo "    --------------------------------------------------------------------------------------------"

      for ELEMENT in ${CHECK_ARRAY[@]}; do
            ELEMENT_NAME=${ELEMENT##*/}
            ELEMENT_TYPE=${ELEMENT%%/*}
       echo "   Check $ELEMENT_NAME ($ELEMENT_TYPE) ..."

            ELEMENT_OK=$(oc get $ELEMENT -n $WAIOPS_NAMESPACE | grep "AGE" || true) 

            if  ([[ ! $ELEMENT_OK =~ "AGE" ]]); 
            then 
                  echo "      ⭕ $ELEMENT not present"; 
                  echo ""
            else
                  echo "      ✅ OK: $ELEMENT"; 

            fi
      done
      export CHECK_NAME=""
}

function check_array(){

      echo ""
      echo ""
      echo "    --------------------------------------------------------------------------------------------"
      echo "    🔎 Check $CHECK_NAME"
      echo "    --------------------------------------------------------------------------------------------"

      for ELEMENT in ${CHECK_ARRAY[@]}; do
            ELEMENT_NAME=${ELEMENT##*/}
            ELEMENT_TYPE=${ELEMENT%%/*}
       echo "   Check $ELEMENT_NAME ($ELEMENT_TYPE) ..."

            ELEMENT_OK=$(oc get $ELEMENT -n $WAIOPS_NAMESPACE | grep $ELEMENT_NAME || true) 

            if  ([[ ! $ELEMENT_OK =~ "$ELEMENT_NAME" ]]); 
            then 
                  echo "      ⭕ $ELEMENT not present"; 
                  echo ""
            else
                  echo "      ✅ OK: $ELEMENT"; 

            fi
      done
      export CHECK_NAME=""
}











































#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# EXAMINE INSTALLATION
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    echo "*************************************************************************************************************************************"
    echo " 🚀  Examining CP4WAIOPS CP4WAIOps Configuration...." 
    echo "*************************************************************************************************************************************"
      echo ""
      echo "  ------------------------------------------------------------------------------------------------------------------------------------------------------"
      echo "  ------------------------------------------------------------------------------------------------------------------------------------------------------"
      echo "  🚀 Initializing"
      echo "  ------------------------------------------------------------------------------------------------------------------------------------------------------"
      echo ""
      echo "    ------------------------------------------------------------------------------------------------------------------------------------------------------"
      echo "   🛠️  Get Namespaces"

        export WAIOPS_NAMESPACE=$(oc get po -A|grep aiops-orchestrator-controller |awk '{print$1}')

      echo ""
      echo "    ------------------------------------------------------------------------------------------------------------------------------------------------------"
      echo "   🛠️  Get Cluster Route"

        CLUSTER_ROUTE=$(oc get routes console -n openshift-console | tail -n 1 2>&1 ) 
        CLUSTER_FQDN=$( echo $CLUSTER_ROUTE | awk '{print $2}')
        CLUSTER_NAME=${CLUSTER_FQDN##*console.}



      echo ""
      echo "    ------------------------------------------------------------------------------------------------------------------------------------------------------"
      echo "   🛠️  Get API Route"
      oc create route passthrough ai-platform-api -n $WAIOPS_NAMESPACE  --service=aimanager-aio-ai-platform-api-server --port=4000 --insecure-policy=Redirect --wildcard-policy=None>/dev/null 2>/dev/null
      export ROUTE=$(oc get route -n $WAIOPS_NAMESPACE ai-platform-api  -o jsonpath={.spec.host})
      echo "        Route: $ROUTE"
      echo ""
      echo ""
      echo "    ------------------------------------------------------------------------------------------------------------------------------------------------------"
      echo "   🛠️  Getting ZEN Token"
     
      ZEN_API_HOST=$(oc get route -n $WAIOPS_NAMESPACE cpd -o jsonpath='{.spec.host}')
      ZEN_LOGIN_URL="https://${ZEN_API_HOST}/v1/preauth/signin"
      LOGIN_USER=admin
      LOGIN_PASSWORD="$(oc get secret admin-user-details -n $WAIOPS_NAMESPACE -o jsonpath='{ .data.initial_admin_password }' | base64 --decode)"

      ZEN_LOGIN_RESPONSE=$(
      curl -k \
      -H 'Content-Type: application/json' \
      -XPOST \
      "${ZEN_LOGIN_URL}" \
      -d '{
            "username": "'"${LOGIN_USER}"'",
            "password": "'"${LOGIN_PASSWORD}"'"
      }' 2> /dev/null
      )

      ZEN_LOGIN_MESSAGE=$(echo "${ZEN_LOGIN_RESPONSE}" | jq -r .message)

      if [ "${ZEN_LOGIN_MESSAGE}" != "success" ]; then
            echo "Login failed: ${ZEN_LOGIN_MESSAGE}"
            exit 2
      fi

      ZEN_TOKEN=$(echo "${ZEN_LOGIN_RESPONSE}" | jq -r .token)
      #echo "${ZEN_TOKEN}"
      echo "        ✅ Sucessfully logged in" 

      echo ""
      echo ""
      echo ""
      echo ""
      echo ""
      echo ""
      echo "  ----------------------------------------------------------------------------------------------------------------------------------------------------------"
      echo "  ----------------------------------------------------------------------------------------------------------------------------------------------------------"
      echo "   🚀  CHECK CP4WAIOPS basic Installation...." 
      echo "  ----------------------------------------------------------------------------------------------------------------------------------------------------------"
      echo ""
      echo "    --------------------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    🔎 Installed Openshift Operator Versions"
      echo ""
      oc get -n $WAIOPS_NAMESPACE ClusterServiceVersion | sed 's/^/       /'
      echo ""








    checkNamespace () {
      echo ""
      echo ""
      echo "    --------------------------------------------------------------------------------------------"
      echo "    🔎 Pods not ready in Namespace $CURRENT_NAMESPACE"
      echo ""

      export ERROR_PODS=$(oc get pods -n $CURRENT_NAMESPACE | grep -v "Completed" | grep "0/"|awk '{print$1}')
      export ERROR_PODS_COUNT=$(oc get pods -n $CURRENT_NAMESPACE | grep -v "Completed" | grep "0/"| grep -c "")
      if  ([[ $ERROR_PODS_COUNT -gt 0 ]]); 
      then 
            export CURRENT_ERROR=true
            export CURRENT_ERROR_STRING="$ERROR_PODS_COUNT Pods not running in Namespace "$CURRENT_NAMESPACE"  \n"$ERROR_PODS
            handleError
      else  
            echo "      ✅ OK: All Pods running and ready in Namespace $CURRENT_NAMESPACE"; 
      fi
    }



      export CURRENT_NAMESPACE=ibm-common-services
      checkNamespace

      export CURRENT_NAMESPACE=$WAIOPS_NAMESPACE
      checkNamespace


      export CURRENT_NAMESPACE=awx
      checkNamespace

      export CURRENT_NAMESPACE=turbonomic
      checkNamespace

      

#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# EXAMINE TRAINING
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

      echo ""
      echo ""
      echo ""
      echo ""
      echo ""
      echo ""
      echo "  ----------------------------------------------------------------------------------------------------------------------------------------------------------"
      echo "  ----------------------------------------------------------------------------------------------------------------------------------------------------------"
      echo "  🚀 CHECK Trained Models"
      echo "  ----------------------------------------------------------------------------------------------------------------------------------------------------------"
      echo ""

      export result=$(curl "https://$ROUTE/graphql" -k -s -H "authorization: Bearer $ZEN_TOKEN" -H 'Accept-Encoding: gzip, deflate, br' -H 'Content-Type: application/json' -H 'Accept: application/json' -H 'Connection: keep-alive' -H 'DNT: 1' -H 'Origin: https://ai-platform-api-cp4waiops.itzroks-270003bu3k-qd899z-6ccd7f378ae819553d37d5f2ee142bd6-0000.eu-de.containers.appdomain.cloud' --data-binary '{"query":"query {\n    getTrainingDefinitions {\n      definitionName\n      algorithmName\n      version\n      deployedVersion\n      description\n      createdBy\n      modelDeploymentDate\n   }\n   }"}' --compressed --compressed)
      export trainedAlgorithms=$(echo $result |jq -r ".data.getTrainingDefinitions[].algorithmName")
      

      if  ([[ $trainedAlgorithms =~ "Log_Anomaly_Detection" ]]); 
      then
            echo "      ✅ OK: Trained - Log_Anomaly_Detection"; 
      else
            export CURRENT_ERROR=true
            export CURRENT_ERROR_STRING="Log_Anomaly_Detection not trained"
            handleError
      fi

      if  ([[ $trainedAlgorithms =~ "Similar_Incidents" ]]); 
      then
            echo "      ✅ OK: Trained - Similar_Incidents"; 
      else
            export CURRENT_ERROR=true
            export CURRENT_ERROR_STRING="Similar_Incidents not trained"
            handleError
      fi

      if  ([[ $trainedAlgorithms =~ "Metric_Anomaly_Detection" ]]); 
      then
            echo "      ✅ OK: Trained - Metric_Anomaly_Detection"; 
      else
            export CURRENT_ERROR=true
            export CURRENT_ERROR_STRING="Metric_Anomaly_Detection not trained"
            handleError
      fi

      if  ([[ $trainedAlgorithms =~ "Change_Risk" ]]); 
      then
            echo "      ✅ OK: Trained - Change_Risk"; 
      else
            export CURRENT_ERROR=true
            export CURRENT_ERROR_STRING="Change_Risk not trained"
            handleError
      fi


      if  ([[ $trainedAlgorithms =~ "Temporal_Grouping" ]]); 
      then
            echo "      ✅ OK: Trained - Temporal_Grouping"; 
      else
            export CURRENT_ERROR=true
            export CURRENT_ERROR_STRING="Temporal_Grouping not trained"
            handleError
      fi

      # if  ([[ $trainedAlgorithms =~ "Alert_Seasonality_Detection" ]]); 
      # then
      #       echo "      ✅ OK: Trained - Alert_Seasonality_Detection"; 
      # else
      #       export CURRENT_ERROR=true
      #       export CURRENT_ERROR_STRING="Alert_Seasonality_Detection not trained"
      #       handleError
      # fi


      # if  ([[ $trainedAlgorithms =~ "Alert_X_In_Y_Supression" ]]); 
      # then
      #       echo "      ✅ OK: Trained - Alert_X_In_Y_Supression"; 
      # else
      #       export CURRENT_ERROR=true
      #       export CURRENT_ERROR_STRING="Alert_X_In_Y_Supression not trained"
      #       handleError
      # fi







#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# EXAMINE AWX
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      echo ""
      echo ""
      echo ""
      echo ""
      echo ""
      echo ""
      echo "  ----------------------------------------------------------------------------------------------------------------------------------------------------------"
      echo "  ----------------------------------------------------------------------------------------------------------------------------------------------------------"
      echo "  🚀 CHECK Runbooks"
      echo "  ----------------------------------------------------------------------------------------------------------------------------------------------------------"
      echo ""

      echo "    --------------------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    🔎 CHECK AWX Configuration"
      echo "    --------------------------------------------------------------------------------------------------------------------------------------------------------"

    export AWX_ROUTE=$(oc get route -n awx awx -o jsonpath={.spec.host})
    export AWX_URL=$(echo "https://$AWX_ROUTE")
    export AWX_PWD=$(oc -n awx get secret awx-admin-password -o jsonpath='{.data.password}' | base64 --decode && echo)


    echo "      ------------------------------------------------------------------------------------------------------------------------------------------------------"
    echo "      🔎 Check AWX Project"
    export AWX_PROJECT_STATUS=$(curl -X "GET" -s "$AWX_URL/api/v2/projects/" -u "admin:$AWX_PWD" --insecure -H 'content-type: application/json'|jq|grep successful|grep -c "")
    if  ([[ $AWX_PROJECT_STATUS -lt 4 ]]); 
      then 
            export CURRENT_ERROR=true
            export CURRENT_ERROR_STRING="AWX Project not ready"
            handleError
      else  
            echo "      ✅ OK"; 
      fi

    echo "      ------------------------------------------------------------------------------------------------------------------------------------------------------"
    echo "      🔎 Check AWX Inventory"
    export AWX_INVENTORY_COUNT=$(curl -X "GET" -s "$AWX_URL/api/v2/inventories/" -u "admin:$AWX_PWD" --insecure -H 'content-type: application/json'| jq ".count")
    if  ([[ $AWX_INVENTORY_COUNT -lt 2 ]]); 
      then 
            export CURRENT_ERROR=true
            export CURRENT_ERROR_STRING="AWX Inventory not ready"
            handleError
      else  
            echo "      ✅ OK"; 
      fi

    echo "      ------------------------------------------------------------------------------------------------------------------------------------------------------"
    echo "      🔎 Check AWX Templates"
    export AWX_TEMPLATE_COUNT=$(curl -X "GET" -s "$AWX_URL/api/v2/job_templates/" -u "admin:$AWX_PWD" --insecure -H 'content-type: application/json'| jq ".count")
    if  ([[ $AWX_TEMPLATE_COUNT -lt 5 ]]); 
      then 
            export CURRENT_ERROR=true
            export CURRENT_ERROR_STRING="AWX Templates not ready"
            handleError
      else  
            echo "      ✅ OK"; 
      fi

      echo ""
      echo ""
      echo ""
      echo ""
      echo "    --------------------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    🔎 CHECK Runbooks in CP4WAIOps"
      echo "    --------------------------------------------------------------------------------------------------------------------------------------------------------"
          CPD_ROUTE=$(oc get route cpd -n $WAIOPS_NAMESPACE  -o jsonpath={.spec.host} || true) 

    
    export result=$(curl -X "GET" -s -k "https://$CPD_ROUTE/aiops/api/story-manager/rba/v1/runbooks" \
        -H "Authorization: bearer $ZEN_TOKEN" \
        -H 'Content-Type: application/json; charset=utf-8')
    export RB_COUNT=$(echo $result|jq ".[].name"|grep -c "")
    if  ([[ $AWX_TEMPLATE_COUNT -lt 3 ]]); 
      then 
            export CURRENT_ERROR=true
            export CURRENT_ERROR_STRING="CP4WAIOps Runbooks not ready"
            handleError
      else  
            echo "      ✅ OK"; 
      fi


#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# CHECK MORE IN DETAIL
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


      echo ""
      echo ""
      echo ""
      echo ""
      echo ""
      echo ""
      echo "  ----------------------------------------------------------------------------------------------------------------------------------------------------------"
      echo "  ----------------------------------------------------------------------------------------------------------------------------------------------------------"
      echo "   🚀  CHECK CP4WAIOPS Detailed Installation...." 
      echo "  ----------------------------------------------------------------------------------------------------------------------------------------------------------"
      echo ""

      echo ""
      echo ""
      echo "    --------------------------------------------------------------------------------------------"
      echo "    🔎 Pods with Image Pull Errors in Namespace $WAIOPS_NAMESPACE"
      echo ""

      export IMG_PULL_ERROR=$(oc get pods -n $WAIOPS_NAMESPACE | grep "ImagePull")

      if  ([[ ! $IMG_PULL_ERROR == "" ]]); 
      then 
            echo "      ⭕ There are Image Pull Errors:"; 
            echo "$IMG_PULL_ERROR"
            echo ""
            echo ""

            echo "      🔎 Check your Pull Secrets:"; 
            echo ""
            echo ""
            echo "ibm-entitlement-key Pull Secret"
            oc get secret/ibm-entitlement-key -n $WAIOPS_NAMESPACE --template='{{index .data ".dockerconfigjson" | base64decode}}'

            echo ""
            echo ""
            echo "ibm-entitlement-key Pull Secret"
            oc get secret/ibm-entitlement-key -n $WAIOPS_NAMESPACE --template='{{index .data ".dockerconfigjson" | base64decode}}'

      else
            echo "      ✅ OK: All images can be pulled"; 
      fi




      echo ""
      echo ""
      echo "    --------------------------------------------------------------------------------------------"
      echo "    🔎 Check ZEN Operator"
      echo ""

      export ZEN_LOGS=$(oc logs $(oc get po -n ibm-common-services|grep ibm-zen-operator|awk '{print$1}') -c ibm-zen-operator -n ibm-common-services|grep "failed=1")
      export ZEN_FAILED=$(echo $ZEN_LOGS|grep -i -w "failed=[1-9]")
      if  ([[ $ZEN_FAILED == "" ]]); 
      then 
            echo "      ✅ OK: ZEN Operator has run successfully"; 
        else
            echo ""
            export CURRENT_ERROR=true
            export CURRENT_ERROR_STRING="Zen has errors"
            handleError
        fi


      echo ""
      echo ""
      echo "    --------------------------------------------------------------------------------------------"
      echo "    🔎 Check Topology"
      echo ""

      CP4AIOPS_CHECK_LIST=(
        "aiops-topology-file-observer"
        "aiops-topology-kubernetes-observer"
        "aiops-topology-layout"
        "aiops-topology-merge"
        "aiops-topology-observer-service"
        "aiops-topology-rest-observer"
        "aiops-topology-servicenow-observer"
        "aiops-topology-status"
        "aiops-topology-topology"
        "aiops-topology-ui-api"
        "aiops-topology-vmvcenter-observer")
      for ELEMENT in ${CP4AIOPS_CHECK_LIST[@]}; do
        #echo "     Check $ELEMENT.."
            ELEMENT_OK=$(oc get pod -n $WAIOPS_NAMESPACE --ignore-not-found | grep $ELEMENT || true) 
            if  ([[ ! $ELEMENT_OK =~ "1/1" ]]); 
            then 
                echo "      ⭕ Pod $ELEMENT not running successfully"; 
                echo ""
                export CURRENT_ERROR=true
                export CURRENT_ERROR_STRING="Pod $ELEMENT not runing successfully"
                handleError
            else
                  echo "      ✅ OK: Pod $ELEMENT"; 

            fi

      done





      echo ""
      echo ""
      echo "    --------------------------------------------------------------------------------------------"
      echo "    🔎 Check Data Stores"
      echo ""

      CP4AIOPS_CHECK_LIST=(
        "aimanager-aio-luigi-daemon-0"
        "aimanager-ibm-minio-0"
        "aiops-topology-cassandra-0"
        "c-example-couchdbcluster-m-0"
        "c-example-redis-m-0"
        "c-example-redis-m-1"
        "c-example-redis-m-2"
        "c-example-redis-s-0"
        "c-example-redis-s-1"
        "c-example-redis-s-2"
        "cp4waiops-postgres-keeper-0"
        "iaf-system-kafka-0"
        "iaf-system-zookeeper-0"
        "ibm-cp-watson-aiops-edb-postgres-1"
        "ibm-vault-deploy-consul-0"
        "ibm-vault-deploy-vault-0"
        "sre-tunnel-controller-0"
        "zen-metastoredb-0"
        "zen-metastoredb-1"
        "zen-metastoredb-2")
      for ELEMENT in ${CP4AIOPS_CHECK_LIST[@]}; do
        #echo "     Check $ELEMENT.."
            ELEMENT_OK=$(oc get pod -n $WAIOPS_NAMESPACE --ignore-not-found | grep $ELEMENT || true) 
            if  ([[ ! $ELEMENT_OK =~ "0/" ]]); 
            then
                echo "      ✅ OK: Pod $ELEMENT";  
            else
                  
                echo "      ⭕ Pod $ELEMENT not running successfully"; 
                echo ""
                export CURRENT_ERROR=true
                export CURRENT_ERROR_STRING="Pod $ELEMENT not runing successfully"
                handleError

            fi

      done








      echo ""
      echo ""
      echo "    --------------------------------------------------------------------------------------------"
      echo "    🔎 Check AIO"
      echo ""

      CP4AIOPS_CHECK_LIST=(
        "aimanager-aio-ai-platform-api-server"
        "aimanager-aio-change-risk"
        "aimanager-aio-chatops-orchestrator"
        "aimanager-aio-chatops-slack-integrator"
        "aimanager-aio-chatops-teams-integrator"
        "aimanager-aio-controller"
        "aimanager-aio-cr-api"
        "aimanager-aio-log-anomaly-detector"
        "aimanager-aio-luigi-daemon-0"
        "aimanager-aio-oob-recommended-actions"
        "aimanager-aio-similar-incidents-service"
        "aimanager-ibm-minio-0")
      for ELEMENT in ${CP4AIOPS_CHECK_LIST[@]}; do
        #echo "     Check $ELEMENT.."
            ELEMENT_OK=$(oc get pod -n $WAIOPS_NAMESPACE --ignore-not-found | grep $ELEMENT || true) 
            if  ([[ ! $ELEMENT_OK =~ "1/1" ]]); 
            then 
                echo "      ⭕ Pod $ELEMENT not running successfully"; 
                echo ""
                export CURRENT_ERROR=true
                export CURRENT_ERROR_STRING="Pod $ELEMENT not runing successfully"
                handleError
            else
                  echo "      ✅ OK: Pod $ELEMENT"; 

            fi

      done






      echo ""
      echo ""
      echo "    --------------------------------------------------------------------------------------------"
      echo "    🔎 Check IR"
      echo ""

      CP4AIOPS_CHECK_LIST=(
        "aiops-ir-analytics-classifier"
        "aiops-ir-analytics-metric-action"
        "aiops-ir-analytics-metric-api"
        "aiops-ir-analytics-metric-spark"
        "aiops-ir-analytics-probablecause"
        "aiops-ir-analytics-spark-master"
        "aiops-ir-analytics-spark-pipeline-composer"
        "aiops-ir-analytics-spark-worker"
        "aiops-ir-analytics-spark-worker"
        "aiops-ir-core-archiving"
        "aiops-ir-core-cem-users"
        "aiops-ir-core-datarouting"
        "aiops-ir-core-esarchiving"
        "aiops-ir-core"
        "aiops-ir-core-ncodl-api"
        "aiops-ir-core-ncodl-if"
        "aiops-ir-core-ncodl-jobmgr"
        "aiops-ir-core-ncodl-std"
        "aiops-ir-core-ncodl-std"
        "aiops-ir-core"
        "aiops-ir-core-rba-as"
        "aiops-ir-core-rba-rbs"
        "aiops-ir-core-usercfg"
        "aiops-ir-lifecycle-datarouting"
        "aiops-ir-lifecycle-eventprocessor-ep"
        "aiops-ir-lifecycle-eventprocessor-ep"
        "aiops-ir-lifecycle-policy-grpc-svc"
        "aiops-ir-lifecycle-policy-registry-svc"
        "aiops-ir-ui-api-graphql")
      for ELEMENT in ${CP4AIOPS_CHECK_LIST[@]}; do
        #echo "     Check $ELEMENT.."
            ELEMENT_OK=$(oc get pod -n $WAIOPS_NAMESPACE --ignore-not-found | grep $ELEMENT || true) 
            if  ([[ ! $ELEMENT_OK =~ "1/1" ]]); 
            then 
                echo "      ⭕ Pod $ELEMENT not running successfully"; 
                echo ""
                export CURRENT_ERROR=true
                export CURRENT_ERROR_STRING="Pod $ELEMENT not runing successfully"
                handleError
            else
                  echo "      ✅ OK: Pod $ELEMENT"; 

            fi

      done





      echo ""
      echo ""
      echo "    --------------------------------------------------------------------------------------------"
      echo "    🔎 Check Routes"
      echo ""
      ROUTE_OK=$(oc get route job-manager -n $WAIOPS_NAMESPACE || true) 
      if  ([[ ! $ROUTE_OK =~ "job-manager" ]]); 
      then 
        echo "      ⭕ job-manager Route does not exist"; 
        echo "      ⭕ (You may want to run option: 12  - Recreate custom Routes)";  
        echo ""
        export CURRENT_ERROR=true
        export CURRENT_ERROR_STRING="job-manager Route does not exist"
        handleError
      else
        echo "      ✅ OK: job-manager Route exists"; 
      fi

  





      echo ""
      echo ""
      echo ""
      echo ""
      echo ""
      echo ""
      echo "  ----------------------------------------------------------------------------------------------------------------------------------------------------------"
      echo "  ----------------------------------------------------------------------------------------------------------------------------------------------------------"
      echo "  🚀 CHECK Various things"
      echo "  ----------------------------------------------------------------------------------------------------------------------------------------------------------"
      echo ""

      echo "    --------------------------------------------------------------------------------------------"
      echo "    🔎 Check Error Events"
      echo ""
      oc get events -A|grep Error| sed 's/^/       /'


      echo ""
      echo ""
      echo ""
      echo ""
      echo ""
      echo ""
    if  ([[ $ERROR == true ]]); 
    then
        echo ""
        echo ""
        echo "***************************************************************************************************************************************************"
        echo "***************************************************************************************************************************************************"
        echo "  ❗ Your installation has the following errors ❗"
        echo ""
        echo "      $ERROR_STRING" | sed 's/^/       /'
        echo ""
        echo "***************************************************************************************************************************************************"
        echo "***************************************************************************************************************************************************"
        echo ""
        echo ""
    else
        echo ""
        echo ""
        echo "***************************************************************************************************************************************************"
        echo "***************************************************************************************************************************************************"
        echo "  "
        echo ""
        echo "      ✅ Your installation seems to be fine"
        echo ""
        echo "***************************************************************************************************************************************************"
        echo "***************************************************************************************************************************************************"
        echo ""
        echo ""

    fi
