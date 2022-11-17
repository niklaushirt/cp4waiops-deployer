export WAIOPS_NAMESPACE=$(oc get po -A|grep aiops-orchestrator-controller |awk '{print$1}')
export EVTMGR_NAMESPACE=$(oc get po -A|grep noi-operator |awk '{print$1}')

echo "       🛠️   Get Route"
export ROUTE=$(oc get route -n $WAIOPS_NAMESPACE cpd  -o jsonpath={.spec.host})          
echo "        Route: $ROUTE"
echo ""

echo "       🛠️   Getting ZEN Token"

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
echo "Login failed: ${ZEN_LOGIN_MESSAGE}" 1>&2

exit 2
fi

ZEN_TOKEN=$(echo "${ZEN_LOGIN_RESPONSE}" | jq -r .token)
echo "${ZEN_TOKEN}"

echo "Sucessfully logged in" 1>&2

echo ""


curl -X "DELETE" -k "https://$ROUTE/zen-data/v1/custom_cards/welcomecard" -H "Authorization: Bearer $ZEN_TOKEN" -H "Content-Type: application/json"
curl -X "DELETE" -k "https://$ROUTE/zen-data/v1/custom_cards/aiopscard" -H "Authorization: Bearer $ZEN_TOKEN" -H "Content-Type: application/json"
curl -X "DELETE" -k "https://$ROUTE/zen-data/v1/custom_cards/appscard" -H "Authorization: Bearer $ZEN_TOKEN" -H "Content-Type: application/json"
curl -X "DELETE" -k "https://$ROUTE/zen-data/v1/custom_cards/systemcard" -H "Authorization: Bearer $ZEN_TOKEN" -H "Content-Type: application/json"


    export result=$(curl -X "PUT" -k "https://$ROUTE/zen-data/v1/custom_cards/welcomecard" -H "Authorization: Bearer $ZEN_TOKEN" -H "Content-Type: application/json" -d'
    {
    "permissions": ["administrator"],
    "order": 1,
    "title": "Welcome to the Tyrion Environment",
    "template_type": "text_list",
    "data": {
        "text_list_data": {
            "rows": [
               {
                "drilldown_url": "",
                "label": "Welcome to your WAIOPS Demo Environment",
                "sub_text": ""
                },
                               {
                "drilldown_url": "",
                "label": "You can find access details for other modules next to this card.",
                "sub_text": ""
                },
                {
                "drilldown_url": "",
                "label": " ",
                "sub_text": "  "
                }

            ]
        }
    }
}
')
    echo "      🔎 Result: "
    echo "       "$result|jq





instanaURL=$(oc get routes -n instana-core dev-aiops -o jsonpath={.spec.host})
turboURL=$(oc get route -n turbonomic api -o jsonpath={.spec.host})
evtMgrURL=$(oc get pod -n $EVTMGR_NAMESPACE --ignore-not-found| grep webgui-0)
evtMgrPwd=$(oc get secret -n $EVTMGR_NAMESPACE  evtmanager-was-secret -o jsonpath='{.data.WAS_PASSWORD}'| base64 --decode && echo)

export ROWS=""

if [[ $instanaURL =~ "dev-aiops" ]]; then
echo "Instana Present"
ROWS="$ROWS{\"drilldown_url\":  \"https://$instanaURL\", \"label\": \"Instana\", \"sub_text\": \"User: admin@instana.local - Password: P4ssw0rd! \"},"
fi
if [[ $turboURL =~ "api-turbonomic" ]]; then
echo "Turbonomic Present"
ROWS="$ROWS{\"drilldown_url\":  \"https://$turboURL\", \"label\": \"Turbonomic\", \"sub_text\": \"User: administrator - Password: P4ssw0rd! \"},"
fi
if [[ $evtMgrURL =~ "evt" ]]; then
echo "EventManager Present "
ROWS="$ROWS{\"drilldown_url\":  \"https://$evtMgrURL\", \"label\": \"EventManager\", \"sub_text\": \"User: smadmin - Password: $evtMgrPwd! \"},"
fi

ROWS="$ROWS{\"drilldown_url\":  \"\", \"label\": \"Select your module above.\", \"sub_text\": \" \"}"

echo $ROWS|jq



    export result=$(curl -X "PUT" -k "https://$ROUTE/zen-data/v1/custom_cards/aiopscard" -H "Authorization: Bearer $ZEN_TOKEN" -H "Content-Type: application/json" -d'
{
    "permissions": ["administrator"],
    "order": 2,
    "title": "IBM AIOps",
    "template_type": "text_list",
    "data": {
        "text_list_data": {
            "rows": [
               '$ROWS'
            ]
        }
    }
}
')
    echo "      🔎 Result: "
    echo "       "$result|jq





demoURL=$(oc get routes -n $WAIOPS_NAMESPACE-demo-ui $WAIOPS_NAMESPACE-demo-ui  -o jsonpath="{['spec']['host']}")
demoToken=$(oc get cm -n $WAIOPS_NAMESPACE-demo-ui $WAIOPS_NAMESPACE-demo-ui-config -o jsonpath='{.data.TOKEN}')
appURL=$(oc get routes -n robot-shop robotshop  -o jsonpath="{['spec']['host']}")
ldapURL=$(oc get route -n openldap admin -o jsonpath={.spec.host})
awxUrl=$(oc get ns awx  --ignore-not-found) 
awxPwd=$(oc -n awx get secret awx-admin-password -o jsonpath='{.data.password}' | base64 --decode && echo)
ocpURL=$(oc get route -n openshift-console console -o jsonpath={.spec.host})



export ROWS=""

if [[ $demoURL =~ "demo-ui" ]]; then
echo "DemoUI Present"
ROWS="$ROWS{\"drilldown_url\":  \"https://$demoURL\", \"label\": \"DemoUI\", \"sub_text\": \"Token/Password: $demoToken \"},"
fi
if [[ $appURL =~ "robot-shop" ]]; then
echo "RobotShop Present"
ROWS="$ROWS{\"drilldown_url\":  \"https://$appURL\", \"label\": \"RobotShop\", \"sub_text\": \"  \"},"
fi
if [[ $ldapURL =~ "openldap" ]]; then
echo "LDAP Present"
ROWS="$ROWS{\"drilldown_url\":  \"https://$ldapURL\", \"label\": \"OpenLDAP\", \"sub_text\": \"User: cn=admin,dc=ibm,dc=com - Password: P4ssw0rd! \"},"
fi
if [[ $awxUrl =~ "awx" ]]; then
echo "AWX Present"
ROWS="$ROWS{\"drilldown_url\":  \"https://$ldapURL\", \"label\": \"Ansible Tower\", \"sub_text\": \"User: admin - Password: $awxPwd \"},"
fi
if [[ $ocpURL =~ "openshift" ]]; then
echo "OCP Present"
ROWS="$ROWS{\"drilldown_url\":  \"https://$ocpURL\", \"label\": \"OCP\", \"sub_text\": \"  \"},"
fi


ROWS="$ROWS{\"drilldown_url\":  \"\", \"label\": \"Select your app above.\", \"sub_text\": \" \"}"

echo $ROWS|jq

export result=$(curl -X "PUT" -k "https://$ROUTE/zen-data/v1/custom_cards/appscard" -H "Authorization: Bearer $ZEN_TOKEN" -H "Content-Type: application/json" -d'
{
    "permissions": ["administrator"],
    "order": 3,
    "title": "Demo Apps",
    "template_type": "text_list",
    "data": {
        "text_list_data": {
            "rows": [
               '$ROWS'
            ]
        }
    }
}
')
    echo "      🔎 Result: "
    echo "       "$result|jq





jobURL=$(oc get routes -n $WAIOPS_NAMESPACE job-manager  -o jsonpath="{['spec']['host']}")
jobPolicyURL=$(oc get routes -n $WAIOPS_NAMESPACE job-manager-policy  -o jsonpath="{['spec']['host']}")
sparkURL=$(oc get routes -n $WAIOPS_NAMESPACE sparkadmin  -o jsonpath="{['spec']['host']}")


export ROWS=""

if [[ $jobURL =~ "demo-ui" ]]; then
echo "DemoUI Present"
ROWS="$ROWS{\"drilldown_url\":  \"https://$jobURL\", \"label\": \"Flink Task Manager - Ingestion\", \"sub_text\": \" \"},"
fi
if [[ $jobPolicyURL =~ "robot-shop" ]]; then
echo "RobotShop Present"
ROWS="$ROWS{\"drilldown_url\":  \"https://$jobPolicyURL\", \"label\": \"Flink Task Manager - Policy Framework\", \"sub_text\": \"  \"},"
fi
if [[ $sparkURL =~ "openldap" ]]; then
echo "LDAP Present"
ROWS="$ROWS{\"drilldown_url\":  \"https://$sparkURL\", \"label\": \"Spark Master\", \"sub_text\": \" \"},"
fi


ROWS="$ROWS{\"drilldown_url\":  \"\", \"label\": \"Select your app above.\", \"sub_text\": \" \"}"

echo $ROWS|jq



    export result=$(curl -X "PUT" -k "https://$ROUTE/zen-data/v1/custom_cards/systemcard" -H "Authorization: Bearer $ZEN_TOKEN" -H "Content-Type: application/json" -d'
{
    "permissions": ["administrator"],
    "order": 4,
    "title": "System Links",
    "template_type": "text_list",
    "data": {
        "text_list_data": {
            "rows": [
               '$ROWS'
            ]
        }
    }
}
')
    echo "      🔎 Result: "
    echo "       "$result|jq








echo "                🌏 URL:           https://$(oc get route -n $WAIOPS_NAMESPACE ibm-vault-deploy-vault-route -o jsonpath={.spec.host})"
echo "                🔐 Token:         $(oc get secret -n $WAIOPS_NAMESPACE ibm-vault-deploy-vault-credential -o jsonpath='{.data.token}' | base64 --decode && echo)"














    export result=$(curl -X "PUT" -k "https://$ROUTE/zen-data/v1/custom_cards/unique-card-key" -H "Authorization: Bearer $ZEN_TOKEN" -H "Content-Type: application/json" -d'
{
    "permissions": ["administrator"],
    "order": 1,
    "title": "IBM AIOps test",
    "template_type": "text_list",
    "data": {
        "text_list_data": {
            "rows": [
                {
                    "drilldown_url":  "https://'$instanaURL'",
                    "label": "Instana",
                    "sub_text": "User: admin@instana.local - Password: P4ssw0rd! "
                },
                {
                    "drilldown_url":  "https://'$turboURL'",
                    "label": "Turbonomic",
                    "sub_text": "User: admin@instana.local - Password: P4ssw0rd! "
                }
            ]
        }
    }
}
')
    echo "      🔎 Result: "
    echo "       "$result|jq
















curl -k -XGET https://$ROUTE/zen-data/v1/custom_cards -H "Authorization: Bearer $ZEN_TOKEN" -H "Content-Type: application/json"



    export result=$(curl -X "PUT" -k "https://$ROUTE/zen-data/v1/custom_cards/unique-card-key" -H "Authorization: Bearer $ZEN_TOKEN" -H "Content-Type: application/json" -d'
        {
               "permissions": ["administrator"],
               "order": 1,
               "title": "IBM AIOps",
               "template_type": "list",
               "data": { "list_data": {
                      "headers": [
                             "project_name",
                             "last_updated_time"
                      ],
                      "rows": [{
                             "project_name": "Instana",
                             "last_updated_time": "2 min ago",
                             "sub_text": "aios",
                             "nav_url": "https://'$instanaURL'"
                      },
                      {
                             "project_name": "Turbonomic",
                             "last_updated_time": "2 min ago",
                             "nav_url": "https://'$turboURL'"
                      },
                      {
                             "project_name": "Improving customer online registration",
                             "last_updated_time": "2 min ago",
                             "nav_url": "/projects/49753ad5-dcf5-4f94-913f-10acf78a4e71"
                      },
                      {
                             "project_name": "Improving customer online registration",
                             "last_updated_time": "2 min ago",
                             "nav_url": "/projects/49753ad5-dcf5-4f94-913f-10acf78a4e71"
                      }]
               }
        }
}
')
    echo "      🔎 Result: "
    echo "       "$result|jq





    export result=$(curl -X "PUT" -k "https://$ROUTE/zen-data/v1/custom_cards/unique-card-key" -H "Authorization: Bearer $ZEN_TOKEN" -H "Content-Type: application/json" -d'
{
    "permissions": ["administrator"],
    "order": 1,
    "title": "IBM AIOps test",
    "template_type": "text_list",
    "data": {
        "text_list_data": {
            "rows": [
                {
                    "drilldown_url":  "https://'$instanaURL'",
                    "label": "Instana",
                    "sub_text": "User: admin@instana.local - Password: P4ssw0rd! "
                },
                {
                    "drilldown_url":  "https://'$turboURL'",
                    "label": "Turbonomic",
                    "sub_text": "User: admin@instana.local - Password: P4ssw0rd! "
                }
            ]
        }
    }
}
')
    echo "      🔎 Result: "
    echo "       "$result|jq





"data”: {
       "text_list_data”: {
              rows: [
              {
                     drilldown_url: '/zen/#/openSource/packages',
                     label: 'Data virtualization',
                     sub_text: 'dv'
              },
              {
                     label: 'Watson assistant',
                     sub_text: 'assistant'
              },
              {
                     label: 'Watson openscale',
                     sub_text: 'aios'
              }
              ]
       }
}





curl -X "PUT" -k "https://$ROUTE/zen-data/v1/custom_cards/unique-card-key" -H "Authorization: Bearer $ZEN_TOKEN" -H "Content-Type: application/json" -d'
        {
               "permissions": ["administrator"],
               "order": 1,
               "title": "IBM AIOps",
               "template_type": "list",
               "data": { "list_data": {
                      "headers": [
                             "project_name",
                             "last_updated_time"
                      ],
                      "rows": [{
                             "project_name": "Improving customer online registration",
                             "last_updated_time": "2 min ago",
                             "nav_url": "/projects/49753ad5-dcf5-4f94-913f-10acf78a4e71"
                      }]
               }
        }
}
'


    export result=$(curl -X "PUT" -k "https://$ROUTE/zen-data/v1/custom_cards/unique-card-key" -H "Authorization: Bearer $ZEN_TOKEN" -H "Content-Type: application/json" -d'
{
  "permissions": ["administrator"],
  "order": 1,
  "title": "Disk usage",
  "template_type": "big_number",
  "data": {      "big_number_data": {
        "metric":  "59",
        "sub_text": "Increase since last month",
        "prefix": "ArrowUp32",
        "suffix": "%",
        "footer_1": "867 Total vulnerabilities",
        "footer_2": "AskPQL 2.3 package most at risk"
      }
    }
}')
    echo "      🔎 Result: "
    echo "       "$result|jq



