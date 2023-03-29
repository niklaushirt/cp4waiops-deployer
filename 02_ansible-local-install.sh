#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#         ________  __  ___     ___    ________       
#        /  _/ __ )/  |/  /    /   |  /  _/ __ \____  _____
#        / // __  / /|_/ /    / /| |  / // / / / __ \/ ___/
#      _/ // /_/ / /  / /    / ___ |_/ // /_/ / /_/ (__  ) 
#     /___/_____/_/  /_/    /_/  |_/___/\____/ .___/____/  
#                                           /_/
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------------------------------"
#  CP4WAIOPS Installation
#
#
#  ©2022 nikh@ch.ibm.com
# ---------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------"
export WAIOPS_VERSION=35

export SHOW_MORE="false"
export WAIOPS_PODS_MIN=115
export DOC_URL="https://github.com/niklaushirt/cp4waiops-deployer#-demo-installation"


# ---------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------"
# Do Not Modify Below
# ---------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------"

export COLOR_SUPPORT=$(tput colors)
if [[ $COLOR_SUPPORT -gt 250 ]]; then
      source ./tools/99_colors.sh
fi

clear

echo "${BYellow}*****************************************************************************************************************************"
echo "*****************************************************************************************************************************"
echo "*****************************************************************************************************************************"
echo "*****************************************************************************************************************************"
echo "  "
echo "  🐥 CloudPak for Watson AIOps - Local Ansible Install"
echo "  "
echo "*****************************************************************************************************************************"
echo "*****************************************************************************************************************************"
echo "*****************************************************************************************************************************"
echo "${NC}  "
echo "  "





while getopts "t:v:r:hc:" opt
do
    case "$opt" in
        t ) INPUT_TOKEN="$OPTARG" ;;
        v ) VERBOSE="$OPTARG" ;;
        r ) REPLACE_INDEX="$OPTARG" ;;
        h ) HELP_USAGE=true ;;

    esac
done


    
if [[ $HELP_USAGE ]];
then
    echo " USAGE: $0 -t <REGISTRY_TOKEN> [-v true] [-r true]"
    echo "  "
    echo "     -t  Provide registry pull token              <REGISTRY_TOKEN> "
    echo "     -v  Verbose mode                             true/false"
    echo "     -r  Replace indexes if they already exist    true/false"

    exit 1
fi

echo "${Purple}"

if [[ $INPUT_TOKEN == "" ]];
then
    echo "${Red}"
    echo "❌ Registry entitlement/pull token not provided."
    echo "  "
    echo "${Cyan}"
    echo "    USAGE: $0 -t <REGISTRY_TOKEN> [-v true] [-r true]"
    echo "   "
    echo "        -t  Provide registry pull token              <REGISTRY_TOKEN> "
    echo "        -v  Verbose mode                             true/false"
    echo "        -r  Replace indexes if they already exist    true/false"
    echo "  "
    echo "${Red}"
    echo "❌ Aborting...."
    echo "  "
    echo "  "
    echo "  "
    echo "  "
    echo "  "
    echo "  "
    echo "  "
    echo "  "
    exit 1
else
    echo " 🔐  Token                               ${Green}Provided${Purple}"
    export cp_entitlement_key=$INPUT_TOKEN
fi


if [[ $VERBOSE ]];
then
    echo " ✅  Verbose Mode                        ${BRed}On${Purple}"
    export ANSIBLE_DISPLAY_SKIPPED_HOSTS=true
    export VERBOSE="-v"
else
    echo " ❎  Verbose Mode                        ${Green}Off ${Purple}         (enable it by appending '-v true')"
    export ANSIBLE_DISPLAY_SKIPPED_HOSTS=false
    export VERBOSE=""
fi


if [[ $REPLACE_INDEX ]];
then
    echo " ❌  Replace existing Indexes            ${BRed}On ❗         (existing training indexes will be replaced/reloaded)${Purple}"
    export SILENT_SKIP=false
else
    echo " ✅  Replace existing Indexes            ${Green}Off${Purple}          (default - enable it by appending '-r true')"
    export SILENT_SKIP=true

fi
echo ""
echo ""
echo "${NC}"

export TEMP_PATH=~/aiops-install


CHECK_RUNBOOKS () {
            export RUNBOOKS_EXISTS=0
}


CHECK_TRAINING () {
    export ROUTE=""
    export WAIOPS_NAMESPACE=$(oc get po -A|grep aiops-orchestrator-controller |awk '{print$1}')

      ZEN_API_HOST=$(oc get route --ignore-not-found -n $WAIOPS_NAMESPACE cpd -o jsonpath='{.spec.host}')
      if [[ ! $ZEN_API_HOST == "" ]]; then

            oc create route passthrough ai-platform-api -n $WAIOPS_NAMESPACE  --service=aimanager-aio-ai-platform-api-server --port=4000 --insecure-policy=Redirect --wildcard-policy=None>/dev/null 2>/dev/null
            export ROUTE=$(oc get route -n $WAIOPS_NAMESPACE ai-platform-api  -o jsonpath={.spec.host})



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



      QUERY="$(cat ./tools/02_training/training-definitions/checkLAD.graphql)"
      JSON_QUERY=$(echo "${QUERY}" | jq -sR '{"operationName": null, "variables": {}, "query": .}')
      export result=$(curl -XPOST -k -s "https://$ROUTE/graphql" -k \
      -H 'Accept-Encoding: gzip, deflate, br'  \
      -H 'Content-Type: application/json'  \
      -H 'Accept: application/json'  \
      -H 'Connection: keep-alive'  \
      -H 'DNT: 1'  \
      -H "Origin: $ROUTE"  \
      -H "authorization: Bearer $ZEN_TOKEN"  \
      --data-binary "${JSON_QUERY}"  \
      --compressed)
      export TRAINING_DEFINITIONS=$(echo $result| jq ".data.getTrainingDefinitions")
      if [[  $TRAINING_DEFINITIONS == "[]" ]]; then
            export TRAINING_EXISTS=false
      else
            export TRAINING_EXISTS=true
      fi
    else
            export TRAINING_EXISTS=false
    fi
}


echo ""
echo ""
echo ""
echo ""
echo "--------------------------------------------------------------------------------------------"
echo " 🐥  Initializing..." 
echo "--------------------------------------------------------------------------------------------"
echo ""

printf "${BYellow}\r  🥚🥚🥚🥚🥚🥚🥚🥚🥚🥚🥚🥚🥚 - Checking Command Line Tools                                  "

if [ ! -x "$(command -v oc)" ]; then
      echo "❌ Openshift Client not installed."
      echo "   🚀 Install prerequisites with ./ansible/scripts/02-prerequisites-mac.sh or ./ansible/scripts/03-prerequisites-ubuntu.sh"
      echo "❌ Aborting...."
      exit 1
fi
if [ ! -x "$(command -v jq)" ]; then
      echo "❌ jq not installed."
      echo "   🚀 Install prerequisites with ./ansible/scripts/02-prerequisites-mac.sh or ./ansible/scripts/03-prerequisites-ubuntu.sh"
      echo "❌ Aborting...."
      exit 1
fi
if [ ! -x "$(command -v ansible-playbook)" ]; then
      echo "❌ Ansible not installed."
      echo "   🚀 Install prerequisites with ./ansible/scripts/02-prerequisites-mac.sh or ./ansible/scripts/03-prerequisites-ubuntu.sh"
      echo "❌ Aborting...."
      exit 1
fi
if [ ! -x "$(command -v cloudctl)" ]; then
      echo "❌ cloudctl not installed."
      echo "   🚀 Install prerequisites with ./ansible/scripts/02-prerequisites-mac.sh or ./ansible/scripts/03-prerequisites-ubuntu.sh"
      echo "❌ Aborting...."
      exit 1
fi

printf "\r  🐣🥚🥚🥚🥚🥚🥚🥚🥚🥚🥚🥚🥚🥚 - Getting Cluster Status                                       "
export CLUSTER_STATUS=$(oc status | grep "In project")
printf "\r  🐥🐣🥚🥚🥚🥚🥚🥚🥚🥚🥚🥚🥚🥚 - Getting Cluster User                                         "

export CLUSTER_WHOAMI=$(oc whoami)

if [[ ! $CLUSTER_STATUS =~ "In project" ]]; then
      echo "❌ You are not logged into an Openshift Cluster."
      echo "❌ Aborting...."
      exit 1
else
      printf "${NC}\r ✅ $CLUSTER_STATUS as user $CLUSTER_WHOAMI\n\n${BYellow}"

fi


printf "  🐥🐥🐣🥚🥚🥚🥚🥚🥚🥚🥚🥚🥚🥚🥚 - Getting AI Manager Namespace                                    "
export WAIOPS_NAMESPACE=$(oc get po -A|grep aiops-orchestrator-controller |awk '{print$1}')
export WAIOPS_PODS=$(oc get pods -n $WAIOPS_NAMESPACE |grep -v Completed|grep -v "0/"|wc -l|tr -d ' ')

if [[ $WAIOPS_PODS -gt $WAIOPS_PODS_MIN ]]; then
      printf "\r  🐥🐥🐥🐣🥚🥚🥚🥚🥚🥚🥚🥚🥚🥚🥚 -  Getting Event Manager Namespace                              "
      export EVTMGR_NAMESPACE=$(oc get po -A|grep noi-operator |awk '{print$1}')
      printf "\r  🐥🐥🐥🐥🐣🥚🥚🥚🥚🥚🥚🥚🥚🥚🥚 - Getting RobotShop Status                                      "
      export RS_NAMESPACE=$(oc get ns robot-shop  --ignore-not-found|awk '{print$1}')
      printf "\r  🐥🐥🐥🐥🐥🐣🥚🥚🥚🥚🥚🥚🥚🥚🥚 - Check if models have been trained                             "
      CHECK_TRAINING
      printf "\r  🐥🐥🐥🐥🐥🐥🐣🥚🥚🥚🥚🥚🥚🥚🥚 - Check if Runbooks exist                                       "
      CHECK_RUNBOOKS
      printf "\r  🐥🐥🐥🐥🐥🐥🐥🐣🥚🥚🥚🥚🥚🥚🥚 - Getting Turbonomic Status                                     "
      export TURBO_NAMESPACE=$(oc get ns turbonomic  --ignore-not-found|awk '{print$1}')
      printf "\r  🐥🐥🐥🐥🐥🐥🐥🐥🐣🥚🥚🥚🥚🥚🥚 - Getting AWX Status                                            "
      export AWX_NAMESPACE=$(oc get ns awx  --ignore-not-found|awk '{print$1}')
      printf "\r  🐥🐥🐥🐥🐥🐥🐥🐥🐥🐣🥚🥚🥚🥚🥚 - Getting LDAP Status                                           "
      export LDAP_NAMESPACE=$(oc get po -n openldap --ignore-not-found| grep ldap |awk '{print$1}')
      printf "\r  🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐣🥚🥚🥚🥚 - Getting Aiops Toolbox Status                                  "
      export TOOLBOX_READY=$(oc get po -n default|grep cp4waiops-tools| grep 1/1 |awk '{print$1}')
      printf "\r  🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐣🥚🥚🥚 - Getting ELK Status                                            "
      export ELK_NAMESPACE=$(oc get ns openshift-logging  --ignore-not-found|awk '{print$1}')
      printf "\r  🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐣🥚🥚 - Getting Istio Status                                          "
      export ISTIO_NAMESPACE=$(oc get ns istio-system  --ignore-not-found|awk '{print$1}')
      printf "\r  🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐣🥚 - Getting Humio Status                                          "
      export HUMIO_NAMESPACE=$(oc get ns humio-logging  --ignore-not-found|awk '{print$1}')
      printf "\r  🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐣 - GettingDEMO UI Status                                          "
      export DEMOUI_READY=$(oc get pods -n $WAIOPS_NAMESPACE |grep waiops-demo-ui-python|awk '{print$1}')
      printf "\r  🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥 - Done ✅                                                        "
fi




# ------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------
# HELPER FUNCTIONS
# ------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------
openTheUrl () {
      if [[ ! $OPEN_URL == "" ]]; then
            if [ -x "$(command -v open)" ]; then
                  open $OPEN_URL
            else 
                  if [ -x "$(command -v firefox)" ]; then
                        firefox $OPEN_URL
                  else 
                        if [ -x "$(command -v google-chrome)" ]; then
                              google-chrome $OPEN_URL
                        else
                              echo "No executable to open URL $OPEN_URL. Skipping..."
                        fi
                  fi
            fi
    else
      echo "URL undefined"
    fi
}



checkToken () {
      #Get Pull Token
      if [[ $cp_entitlement_key == "" ]];
      then
            echo ""
            echo ""
            echo "  Enter CP4WAIOPS Pull token: "
            read TOKEN
      else
            TOKEN=$cp_entitlement_key
      fi

      echo ""
      echo "  🔐 You have provided the following Token:"
      echo "    "$TOKEN
      echo ""

      # Install
      read -p "  Are you sure that this is correct❓ [y,N] " DO_COMM
      if [[ $DO_COMM == "y" ||  $DO_COMM == "Y" ]]; then
            echo ""
            echo "     ✅ Ok, continuing..."
            echo ""
            echo  ""
      else
            echo "    ⚠️  Skipping"
            echo "--------------------------------------------------------------------------------------------"
            echo  ""    
            echo  ""
            exit
      fi
}

checkAIManager () {

      # Check if ${Green}Already installed${NC} 
      if [[ ! $WAIOPS_NAMESPACE == "" ]]; then
            echo "⚠️  CP4WAIOPS AI Manager seems to be installed already"

            read -p "   Are you sure you want to continue❓ [y,N] " DO_COMM
            if [[ $DO_COMM == "y" ||  $DO_COMM == "Y" ]]; then
                  echo ""
                  echo "     ✅ Ok, continuing..."
                  echo ""
                  echo ""
            else
                  echo ""
                  echo "    ❌  Aborting"
                  echo "--------------------------------------------------------------------------------------------"
                  echo  ""    
                  echo  ""
                  exit
            fi
      fi
}


checkEventManager () {
      # Check if ${Green}Already installed${NC} 
      if [[ ! $EVTMGR_NAMESPACE == "" ]]; then
            echo "⚠️  CP4WAIOPS Event Manager seems to be installed already"

            read -p "   Are you sure you want to continue❓ [y,N] " DO_COMM
            if [[ $DO_COMM == "y" ||  $DO_COMM == "Y" ]]; then
                  echo ""
                  echo "     ✅ Ok, continuing..."
                  echo ""
                  echo ""
            else
                  echo ""
                  echo "    ❌  Aborting"
                  echo "--------------------------------------------------------------------------------------------"
                  echo  ""    
                  echo  ""
                  exit
            fi
      fi
}


















# ************************************************************************************************************************************************
# ************************************************************************************************************************************************
# ************************************************************************************************************************************************
# ------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------
# WAIOPS INSTALLAION VIA LOCAL ANSIBLE
# ------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------

INSTALL_LOCAL () {
      echo "*****************************************************************************************************************************"
      echo "*****************************************************************************************************************************"
      echo " 🚀  Install "$INSTALL_TITLE 
      echo "*****************************************************************************************************************************"
      echo "*****************************************************************************************************************************"

      echo ""

      cd ansible
      ansible-playbook 00_cp4waiops-install.yaml -e cp_entitlement_key=$TOKEN  -e config_file_path=$INSTALL_CONFIG_FILE_PATH
      cd -

      echo ""
      echo ""
      echo ""
      echo "*****************************************************************************************************************************"
      echo "*****************************************************************************************************************************"
      echo "*****************************************************************************************************************************"
      echo "*****************************************************************************************************************************"
      echo "  "
      echo "  ✅ $INSTALL_TITLE  done"
      echo "  "
      echo "*****************************************************************************************************************************"
      echo "*****************************************************************************************************************************"

}






menu_EASY_AI_ALL () {
      export INSTALL_TITLE="Complete Demo Environment for AI Manager - cp4waiops-roks-aimanager-all-$WAIOPS_VERSION.yaml" 
      export INSTALL_CONFIG_FILE_PATH="./configs/cp4waiops-roks-aimanager-all-$WAIOPS_VERSION.yaml"

      checkAIManager
      checkToken

      INSTALL_LOCAL

}


menu_EASY_EVENT_ALL () {

      export INSTALL_TITLE="Complete Demo Environment for EVENT Manager - cp4waiops-roks-eventmanager-all-$WAIOPS_VERSION.yaml" 
      export INSTALL_CONFIG_FILE_PATH="./configs/cp4waiops-roks-aimanager-all-$WAIOPS_VERSION.yaml"

      checkEventManager
      checkToken

      INSTALL_LOCAL

}


menu_INSTALL_AIMGR () {

      export INSTALL_TITLE="Base Install for AI Manager - cp4waiops-roks-aimanager-$WAIOPS_VERSION.yaml" 
      export INSTALL_CONFIG_FILE_PATH="./configs/cp4waiops-roks-aimanager-$WAIOPS_VERSION.yaml"

      checkAIManager
      checkToken

      INSTALL_LOCAL

}

menu_INSTALL_EVTMGR () {

      export INSTALL_TITLE="Base Install for Event Manager - cp4waiops-roks-eventmanager-$WAIOPS_VERSION.yaml" 
      export INSTALL_CONFIG_FILE_PATH="./configs/cp4waiops-roks-eventmanager-$WAIOPS_VERSION.yaml"

      checkAIManager
      checkToken

      INSTALL_LOCAL

}


menu_INSTALL_TURBO () {

      export INSTALL_TITLE="Turbonomic - cp4waiops-roks-turbonomic.yaml" 
      export INSTALL_CONFIG_FILE_PATH="./configs/cp4waiops-roks-turbonomic.yaml"

      checkAIManager
      checkToken

      INSTALL_LOCAL

}


menu_INSTALL_ELK () {

      export INSTALL_TITLE="OpenShift Logging (ELK) - cp4waiops-roks-elk.yaml" 
      export INSTALL_CONFIG_FILE_PATH="./configs/cp4waiops-roks-elk.yaml"

      checkAIManager
      checkToken

      INSTALL_LOCAL

}


menu_INSTALL_CUSTOM () {
      echo "----------------------------------------------------------------------------------------------------------------"
      echo " 🚀  Select Script for Custom Configuration" 
      echo "----------------------------------------------------------------------------------------------------------------"
      echo ""

      echo "-----------------------------------------------------------------------"
      echo "  🐥  Available Installation Configurations"
      echo "  "

      ls -1 ./ansible/configs|grep ".yaml" | sed 's/.yaml//'| sed 's/^/       /'



      echo "  "
      echo "  "
      echo "-----------------------------------------------------------------------"
      echo "  ❌    q  -  Exit"



      echo ""
      echo ""
      echo "  🚀 Copy and paste the name of the Playbook you want to run below: "
      read selection
      echo ""
      echo ""
      echo ""
      echo ""
      echo ""

      if [ $selection != "q" ];  then
            export ANSIBLE_CONFIGURATION=$selection
            export INSTALL_TITLE="Custom Configuration from Configuration File - $ANSIBLE_CONFIGURATION" 
            export INSTALL_CONFIG_FILE_PATH="./configs/$ANSIBLE_CONFIGURATION.yaml"

            INSTALL_LOCAL

      fi

}










# ************************************************************************************************************************************************
# ************************************************************************************************************************************************
# ************************************************************************************************************************************************
# ------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------
# OPEN OR DISPLAY Functions
# ------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------
menuDEMO_OPEN () {
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    🚀 Demo UI - Details"
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    "
      appURL=$(oc get routes -n $WAIOPS_NAMESPACE waiops-demo-ui-python  -o jsonpath="{['spec']['host']}")|| true
      appToken=$(oc get cm -n $WAIOPS_NAMESPACE demo-ui-python-config -o jsonpath='{.data.TOKEN}')
      echo "            📥 Demo UI:"   
      echo "    " 
      echo "                🌏 URL:           http://$appURL/"
      echo "                🔐 Token:         $appToken"
      echo ""
      echo ""
      export OPEN_URL="http://$appURL"
      openTheUrl
}


menuAWX_OPENDOC () {
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    🚀 Opening Documentation "
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    "
      export OPEN_URL=$DOC_URL
      openTheUrl
}


menuAWX_OPENAWX () {
      export AWX_ROUTE="https://"$(oc get route -n awx awx -o jsonpath={.spec.host})
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    🚀 AWX "
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    "
      echo "            📥 AWX :"
      echo ""
      echo "                🌏 URL:      $AWX_ROUTE"
      echo "                🧑 User:     admin"
      echo "                🔐 Password: $(oc -n awx get secret awx-admin-password -o jsonpath='{.data.password}' | base64 --decode && echo)"
      echo "    "
      echo "    "
      export OPEN_URL=$AWX_ROUTE
      openTheUrl

}


menuAIMANAGER_OPEN () {
      export ROUTE="https://"$(oc get route -n $WAIOPS_NAMESPACE cpd -o jsonpath={.spec.host})
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    🚀 AI Manager"
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    "
      echo "      📥 AI Manager"
      echo ""
      echo "                🌏 URL:      $ROUTE"
      echo ""
      echo "                🧑 User:     demo"
      echo "                🔐 Password: P4ssw0rd!"
      echo "    "
      echo "                🧑 User:     $(oc -n ibm-common-services get secret platform-auth-idp-credentials -o jsonpath='{.data.admin_username}' | base64 --decode && echo)"
      echo "                🔐 Password: $(oc -n ibm-common-services get secret platform-auth-idp-credentials -o jsonpath='{.data.admin_password}' | base64 --decode)"
      echo "    "
      echo "    "
      export OPEN_URL=$ROUTE
      openTheUrl

}


menuEVENTMANAGER_OPEN () {
      export ROUTE="https://"$(oc get route -n $EVTMGR_NAMESPACE  evtmanager-ibm-hdm-common-ui -o jsonpath={.spec.host})
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    🚀 Event Manager (Netcool Operations Insight)"
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    "
      echo "      📥 Event Manager"
      echo ""
      echo "            🌏 URL:      $ROUTE"
      echo ""
      echo "            🧑 User:     smadmin"
      echo "            🔐 Password: $(oc get secret -n $EVTMGR_NAMESPACE  evtmanager-was-secret -o jsonpath='{.data.WAS_PASSWORD}'| base64 --decode && echo)"
      echo "    "
      echo "    "
      export OPEN_URL=$ROUTE
      openTheUrl

}


menuAWX_OPENELK () {
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    🚀 ELK "
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      token=$(oc sa get-token cluster-logging-operator -n openshift-logging)
      routeES=`oc get route elasticsearch -o jsonpath={.spec.host} -n openshift-logging`
      routeKIBANA=`oc get route kibana -o jsonpath={.spec.host} -n openshift-logging`
      echo "      "
      echo "            📥 ELK:"
      echo "      "
      echo "               🌏 ELK service URL             : https://$routeES/app*"
      echo "               🔐 Authentication type         : Token"
      echo "               🔐 Token                       : $token"
      echo "      "
      echo "               🌏 Kibana URL                  : https://$routeKIBANA"
      echo "               🚪 Kibana port                 : 443"
      export OPEN_URL=https://$routeKIBANA
      openTheUrl

}


menuAWX_OPENISTIO () {
      export KIALI_ROUTE="https://"$(oc get route -n istio-system kiali -o jsonpath={.spec.host})
      export RS_ROUTE="http://"$(oc get route -n istio-system istio-ingressgateway -o jsonpath={.spec.host})
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    🚀 ServiceMesh/ISTIO "
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    "
      echo "            📥 ServiceMesh:"
      echo ""
      echo "                🌏 RobotShop:     $RS_ROUTE"
      echo "                🌏 Kiali:         $KIALI_ROUTE"
      echo "                🌏 Jaeger:        https://$(oc get route -n istio-system jaeger -o jsonpath={.spec.host})"
      echo "                🌏 Grafana:       https://$(oc get route -n istio-system grafana -o jsonpath={.spec.host})"
      echo "    "
      echo "    "
      echo "          In the begining all traffic is routed to ratings-test"
      echo "            You can modify the routing by executing:"
      echo "              All Traffic to test:    oc apply -n robot-shop -f ./ansible/templates/demo_apps/robotshop/istio/ratings-100-0.yaml"
      echo "              Traffic split 50-50:    oc apply -n robot-shop -f ./ansible/templates/demo_apps/robotshop/istio/ratings-50-50.yaml"
      echo "              All Traffic to prod:    oc apply -n robot-shop -f ./ansible/templates/demo_apps/robotshop/istio/ratings-0-100.yaml"
      echo "    "
      echo "    "
      echo "    "
      export OPEN_URL=$KIALI_ROUTE
      openTheUrl    
      export OPEN_URL=$RS_ROUTE
      openTheUrl

}

menuAWX_OPENTURBO () {
      export ROUTE="https://"$(oc get route -n turbonomic nginx -o jsonpath={.spec.host})
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    🚀 Turbonomic Dashboard "
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    "
      echo "            📥 Turbonomic Dashboard :"
      echo ""
      echo "                🌏 URL:      $ROUTE"
      echo "                🧑 User:     administrator"
      echo "                🔐 Password: As set at init step"
      echo "    "
      echo "    "
      export OPEN_URL=$ROUTE
      openTheUrl

}


menuAWX_OPENHUMIO () {
      export ROUTE="https://"$(oc get route -n humio-logging humio -o jsonpath={.spec.host})
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    🚀 HUMIO "
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    "
      echo "            📥 HUMIO:"
      echo ""
      echo "                🌏 URL:      $ROUTE"
      echo "                🧑 User:     developer"
      echo "                🔐 Password: P4ssw0rd!"
      echo "    "
      echo "    "
      export OPEN_URL=$ROUTE
      openTheUrl

}


menuAWX_OPENLDAP () {
      export ROUTE="http://"$(oc get route -n openldap openldap-admin -o jsonpath={.spec.host})
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    🚀 LDAP "
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    " 
      echo "            📥 OPENLDAP:"
      echo "    " 
      echo "                🌏 URL:      $ROUTE"
      echo "                🧑 User:     cn=admin,dc=ibm,dc=com"
      echo "                🔐 Password: P4ssw0rd!"
      echo "    "
      echo "    "
      export OPEN_URL=$ROUTE
      openTheUrl
}


menuAWX_OPENRS () {
      export ROUTE="http://"$(oc get routes -n robot-shop web  -o jsonpath="{['spec']['host']}")
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    🚀 RobotShop "
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    "
      echo "    "
      export OPEN_URL=$ROUTE
      openTheUrl

}





# ************************************************************************************************************************************************
# ************************************************************************************************************************************************
# ************************************************************************************************************************************************
# ------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------
# PATCHES
# ------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------
menuDEBUG_PATCH () {
      echo "--------------------------------------------------------------------------------------------"
      echo " 🚀  Launch Debug Patches" 
      echo "--------------------------------------------------------------------------------------------"
      echo ""

      read -p "   Are you sure you want to continue❓ [y,N] " DO_COMM
      if [[ $DO_COMM == "y" ||  $DO_COMM == "Y" ]]; then
            echo ""
            echo "   ✅ Ok, continuing..."
            echo ""
      else
            echo ""
            echo "    ❌  Aborting"
            echo "--------------------------------------------------------------------------------------------"
            echo  ""    
            echo  ""
            return
      fi


      cd ansible
      ansible-playbook 91_aimanager-debug-patches.yaml
      cd -

}









# ************************************************************************************************************************************************
# ************************************************************************************************************************************************
# ************************************************************************************************************************************************
# ------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------
# MENU
# ------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------
incorrect_selection() {
      echo "--------------------------------------------------------------------------------------------"
      echo " ❗ This option does not exist!" 
      echo "--------------------------------------------------------------------------------------------"
}

until [ "$selection" = "0" ]; do
  
clear

echo "${BYellow}*****************************************************************************************************************************"
echo "*****************************************************************************************************************************"
echo "       ________  __  ___     ___    ________       "
echo "      /  _/ __ )/  |/  /    /   |  /  _/ __ \____  _____"
echo "      / // __  / /|_/ /    / /| |  / // / / / __ \/ ___/"
echo "    _/ // /_/ / /  / /    / ___ |_/ // /_/ / /_/ (__  ) "
echo "   /___/_____/_/  /_/    /_/  |_/___/\____/ .___/____/  "
echo "                                         /_/"
echo ""
echo "   🐥 CloudPak for Watson AIOPs - EASY INSTALL"
echo ""
echo "*****************************************************************************************************************************"
echo ""
echo "${Purple}"
if [[ $cp_entitlement_key == "" ]];
then
echo "      🔐 Image Pull Token:           ${Red}Not Provided (will be asked during installation)${Purple}"
else
echo "      🔐 Image Pull Token:           ${Green}Provided${Purple}"
fi

echo "      🌏 Namespace:                  ${Green}$WAIOPS_NAMESPACE${Purple}"	
echo "      💾 Skip Data Load if exists:   ${Green}$SILENT_SKIP${Purple}"	
echo "      🔎 Verbose Mode:               ${Green}$ANSIBLE_DISPLAY_SKIPPED_HOSTS${Purple}"
echo "${NC}"
echo "${BYellow}   "
echo "*****************************************************************************************************************************"
echo "*****************************************************************************************************************************"
echo "${NC}"





      echo "  🐥 ${UBlue}CP4WAIOPS - Local Ansible Install${NC}"
      if [[ $WAIOPS_PODS -lt $WAIOPS_PODS_MIN ]]; then
            echo "     🚀  10  - Install AI Manager Demo${NC}                                 - Install AI Manager with Demo Content"
      else
            echo "     ✅  10  - Install AI Manager Demo${NC}                                 - ${Green}Already installed${NC}  "
      fi

      if [[ $EVTMGR_NAMESPACE == "" ]]; then
            echo "         11  - Install Event Manager Demo                              - Install Event Manager with Demo Content"
      else
            echo "     ✅  11  - Install Event Manager Demo${NC}                              - ${Green}Already installed${NC}  "
      fi

      if [[ $WAIOPS_PODS -lt $WAIOPS_PODS_MIN ]]; then
            echo "         15  - Install AI Manager                                      - Install CP4WAIOPS AI Manager Component Only"
      else
            echo "     ✅  15  - Install AI Manager                                      - ${Green}Already installed${NC}  "
      fi

      if [[ $EVTMGR_NAMESPACE == "" ]]; then
            echo "         16  - Install Event Manager                                   - Install CP4WAIOPS Event Manager Component Only"
      else
            echo "     ✅  16  - Install Event Manager                                   - ${Green}Already installed${NC}  "
      fi



      echo "         19  - Open Documentation                                      - Open the AI Manager installation Documentation"
      echo "  "
      echo "  "
      echo "  "



      echo "  🐥 ${UBlue}Third Party Solutions${NC}"
      if [[ $TURBO_NAMESPACE == "" ]]; then
            echo "         21  - Install Turbonomic                                      - Install Turbonomic (needs a separate license)"
      else
            echo "     ✅  21  - Install Turbonomic                                      - ${Green}Already installed${NC}  "
      fi


      if [[  $ELK_NAMESPACE == "" ]]; then
            echo "         25  - Install OpenShift Logging                               - Install OpenShift Logging (ELK)"
            else
            echo "     ✅  25  - Install OpenShift Logging                               - ${Green}Already installed${NC}  "
            fi


      echo "  "
      echo "  "
      echo "  "
      echo "  🌏 ${UBlue}Access Information${NC}"
      echo "         81  - Get logins                                              - Get logins for all installed components"
      echo "         82  - Write logins to file                                    - Write logins for all installed components to file LOGIN.txt"
      echo "  "

      if [[ ! $WAIOPS_NAMESPACE == "" ]]; then
            echo "         90  - Open AI Manager                                         - Open AI Manager"
      fi

      if [[ ! $DEMOUI_READY == "" ]]; then
            echo "         91  - Open AI Manager Demo                                    - Open AI Manager Incident Demo UI"
      fi

      if [[ ! $EVTMGR_NAMESPACE == "" ]]; then
            echo "         92  - Open Event Manager                                      - Open Event Manager"
      fi

      if [[ ! $TURBO_NAMESPACE == "" ]]; then
            echo "         93  - Open Turbonomic                                         - Open Turbonomic Instance"
      fi

      if [[ ! $ELK_NAMESPACE == "" ]]; then
            echo "         94  - Open ELK                                                - Open ELK Instance"
      fi

      if [[ ! $HUMIO_NAMESPACE == "" ]]; then
            echo "         95  - Open Humio                                              - Open Humio Instance"
      fi

      if [[ ! $ISTIO_NAMESPACE == "" ]]; then
            echo "         96  - Open Istio                                              - Open ServcieMesh/Istio Kiali Instance"
      fi

      if [[ ! $LDAP_NAMESPACE == "" ]]; then
            echo "         97  - Open OpenLDAP                                           - Open OpenLDAP Instance"
      fi

      if [[ ! $RS_NAMESPACE == "" ]]; then
            echo "         98  - Open RobotShop                                          - Open RobotShop Demo Application"
      fi

      if [[ ! $AWX_NAMESPACE == "" ]]; then
            echo "         99  - Open AWX                                                - Open AWX Instance (Open Source Ansible Tower)"
      fi
      echo "  "
      echo "  "
      echo "  "



      echo "  🐥 ${UBlue}Prerequisites Install${NC}"
      echo "         71  - Install Prerequisites Mac                               - Install Prerequisites for Mac"
      echo "         72  - Install Prerequisites Ubuntu                            - Install Prerequisites for Ubuntu"
      echo "  "
      echo "  "
      echo "  "







  echo "      "
  echo "      ❌  ${Red}0  -  Exit${NC}"
  echo ""
  echo ""
  echo "  ${BGreen}Enter selection: ${NC}"
  read selection
  echo ""
  case $selection in

      01 ) clear ; menu_JOB_AI_ALL  ;;
      02 ) clear ; menu_JOB_EVENT_ALL  ;;



      10 ) clear ; menu_EASY_AI_ALL  ;;
      11 ) clear ; menu_EASY_EVENT_ALL  ;;

      15 ) clear ; menu_INSTALL_AIMGR  ;;
      16 ) clear ; menu_INSTALL_EVTMGR  ;;

      19 ) clear ; menuAWX_OPENDOC  ;;


      21 ) clear ; menu_INSTALL_TURBO  ;;
      22 ) clear ; menu_INSTALL_ELK  ;;
      30 ) clear ; menu_INSTALL_CUSTOM  ;;

      71 ) clear ; ./10_install_prerequisites_mac.sh  ;;
      72 ) clear ; ./11_install_prerequisites_ubuntu.sh  ;;

      81 ) clear ; ./tools/20_get_logins.sh  ;;
      82 ) clear ; ./tools/20_get_logins.sh > LOGINS.txt  ;;

      90 ) clear ; menuAIMANAGER_OPEN  ;;
      91 ) clear ; menuDEMO_OPEN  ;;
      92 ) clear ; menuEVENTMANAGER_OPEN  ;;
      93 ) clear ; menuAWX_OPENTURBO  ;;
      94 ) clear ; menuAWX_OPENELK  ;;
      95 ) clear ; menuAWX_OPENHUMIO  ;;
      96 ) clear ; menuAWX_OPENISTIO  ;;
      97 ) clear ; menuAWX_OPENLDAP  ;;
      98 ) clear ; menuAWX_OPENRS  ;;
      99 ) clear ; menuAWX_OPENAWX  ;;

      999 ) clear ; menuDEBUG_PATCH  ;;

      m ) clear ; SHOW_MORE=true  ;;



      0 ) clear ; exit ;;
      * ) clear ; incorrect_selection  ;;
  esac
  read -p "Press Enter to continue..."
  clear 
done


