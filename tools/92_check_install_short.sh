#!/bin/bash
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
