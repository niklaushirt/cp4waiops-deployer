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
#  CP4WAIOPS - Get Logins and URLs
#
#
#  ©2023 nikh@ch.ibm.com
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"


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
echo "  🚀 CloudPak for Watson AIOps - Logins and URLs"
echo "  "
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo "  "
echo "  "
export TEMP_PATH=~/aiops-install

# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# Do Not Edit Below
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"



export WAIOPS_NAMESPACE=$(oc get po -A|grep aiops-orchestrator-controller |awk '{print$1}')

: "${WAIOPS_NAMESPACE:=cp4waiops}"

CLUSTER_ROUTE=$(oc get routes console -n openshift-console | tail -n 1 2>&1 ) 
CLUSTER_FQDN=$( echo $CLUSTER_ROUTE | awk '{print $2}')
CLUSTER_NAME=${CLUSTER_FQDN##*console.}






echo "        -----------------------------------------------------------------------------------------------------------------------------------------------"
echo "        -----------------------------------------------------------------------------------------------------------------------------------------------"
echo "        🚀 AI Platform API - GRAPHQL Playground "
echo "        -----------------------------------------------------------------------------------------------------------------------------------------------"
echo "        -----------------------------------------------------------------------------------------------------------------------------------------------"
apiURL=$(oc get routes -n $WAIOPS_NAMESPACE ai-platform-api -o jsonpath="{['spec']['host']}")
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


ZEN_TOKEN=$(echo "${ZEN_LOGIN_RESPONSE}" | jq -r .token)


echo "        " 
echo "                📥 Playground:"
echo "        " 
echo "                    🌏 URL:                   https://$apiURL/graphql"
echo "    "
echo "    "
echo "        " 
echo "                    🔐 HTTP HEADERS"
echo "                            {"
echo "                            \"authorization\": \"Bearer $ZEN_TOKEN\""
echo "                            }"
echo "        " 
echo "        " 
echo "        " 
echo "                    📥 Example Payload"
echo "                            query {"
echo "                                getTrainingDefinitions {"
echo "                                  definitionName"
echo "                                  algorithmName"
echo "                                  version"
echo "                                  deployedVersion"
echo "                                  description"
echo "                                  createdBy"
echo "                                  modelDeploymentDate"
echo "                                  promoteOption"
echo "                                  trainingSchedule {"
echo "                                    frequency"
echo "                                    repeat"
echo "                                    timeRangeValidStart"
echo "                                    timeRangeValidEnd"
echo "                                    noEndDate"
echo "                                  }"
echo "                                }"
echo "                              }"
echo "        " 
echo "        " 
echo "        " 
echo "                    🔐 ZEN Token:             $ZEN_TOKEN"



