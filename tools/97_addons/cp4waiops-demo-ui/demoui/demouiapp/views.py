from django.shortcuts import render
from django.http import HttpResponse
from django.template import loader
from subprocess import check_output
import os
import sys 
import time 
import hashlib
from threading import Thread
sys.path.append(os.path.abspath("demouiapp"))
from functions import *
SLACK_URL=str(os.environ.get('SLACK_URL'))
SLACK_USER=str(os.environ.get('SLACK_USER'))
SLACK_PWD=str(os.environ.get('SLACK_PWD'))
INCIDENT_ACTIVE=False
ROBOT_SHOP_OUTAGE_ACTIVE=False
SOCK_SHOP_OUTAGE_ACTIVE=False

print ('*************************************************************************************************')
print ('*************************************************************************************************')
print ('            ________  __  ___     ___    ________       ')
print ('           /  _/ __ )/  |/  /    /   |  /  _/ __ \____  _____')
print ('           / // __  / /|_/ /    / /| |  / // / / / __ \/ ___/')
print ('         _/ // /_/ / /  / /    / ___ |_/ // /_/ / /_/ (__  ) ')
print ('        /___/_____/_/  /_/    /_/  |_/___/\____/ .___/____/  ')
print ('                                              /_/')
print ('*************************************************************************************************')
print ('*************************************************************************************************')
print ('')
print ('    🛰️  DemoUI for IBM Automation AIOps')
print ('')
print ('       Provided by:')
print ('        🇨🇭 Niklaus Hirt (nikh@ch.ibm.com)')
print ('')

print ('*************************************************************************************************')
print (' 🚀 Warming up')
print ('*************************************************************************************************')

#os.system('ls -l')
loggedin='false'
loginip='0.0.0.0'

mod_time=os.path.getmtime('./demouiapp')
mod_time_readable = datetime.datetime.fromtimestamp(mod_time)
print('     🛠️ Build Date: '+str(mod_time_readable))

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# GET NAMESPACES
# ----------------------------------------------------------------------------------------------------------------------------------------------------
print('     ❓ Getting CP4WAIOps Namespace')
stream = os.popen("oc get po -A|grep aiops-orchestrator-controller |awk '{print$1}'")
aimanagerns = stream.read().strip()
print('        ✅ CP4WAIOps Namespace:       '+aimanagerns)


print('     ❓ Getting Details Datalayer')
stream = os.popen("oc get route  -n "+aimanagerns+" datalayer-api  -o jsonpath='{.status.ingress[0].host}'")
DATALAYER_ROUTE = stream.read().strip()
stream = os.popen("oc get secret -n "+aimanagerns+" aiops-ir-core-ncodl-api-secret -o jsonpath='{.data.username}' | base64 --decode")
DATALAYER_USER = stream.read().strip()
stream = os.popen("oc get secret -n "+aimanagerns+" aiops-ir-core-ncodl-api-secret -o jsonpath='{.data.password}' | base64 --decode")
DATALAYER_PWD = stream.read().strip()


url = 'https://'+DATALAYER_ROUTE+'/irdatalayer.aiops.io/active/v1/stories'
auth=HTTPBasicAuth(DATALAYER_USER, DATALAYER_PWD)
headers = {'Content-Type': 'application/json', 'Accept-Charset': 'UTF-8', 'x-username' : 'admin', 'x-subscription-id' : 'cfd95b7e-3bc7-4006-a4a8-a73a79c71255'}
response = requests.get(url, headers=headers, auth=auth, verify=False)
responseJSON=response.json()
responseStr=str(json.dumps(responseJSON))
#print(responseStr)
#if 'pirsoscom.github.io/SNOW_INC' in responseStr and '"closed"' not in responseStr and '"resolved"' not in responseStr:
if '"state": "assignedToIndividual"' in responseStr or '"state": "inProgress"' in responseStr:
    print('     🔴 INCIDENT FOUND')
    INCIDENT_ACTIVE=True
else:
    print('     🟢 NO INCIDENT')
    INCIDENT_ACTIVE=False

stream = os.popen("oc get deployment  -n robot-shop ratings  -o yaml")
RATINGS_YAML = stream.read().strip()
if 'ratings-dev' in RATINGS_YAML:
    print('     🔴 ROBOT SHOP OUTAGE ACTIVE')
    ROBOT_SHOP_OUTAGE_ACTIVE=True
else:
    print('     🟢 ROBOT SHOP OUTAGE INACTIVE')
    ROBOT_SHOP_OUTAGE_ACTIVE=False

stream = os.popen("oc get service  -n sock-shop catalogue  -o yaml")
CATALOG_YAML = stream.read().strip()
if '-outage' in CATALOG_YAML:
    print('     🔴 SOCK SHOP OUTAGE ACTIVE')
    SOCK_SHOP_OUTAGE_ACTIVE=True
else:
    print('     🟢 SOCK SHOP OUTAGE INACTIVE')
    SOCK_SHOP_OUTAGE_ACTIVE=False



print('     🟠 OUTAGE - Incident:'+str(INCIDENT_ACTIVE)+' - RS-OUTAGE:'+str(ROBOT_SHOP_OUTAGE_ACTIVE))

#assignedToIndividual
#inProgress


cmd = '''
echo "  <BR>"
echo "  <h1>🚀 CloudPak for Watson AIOps - Logins and URLs </h1><BR>"
echo "  <BR>"
echo "  <BR>"
echo "  <BR>"
export TEMP_PATH=~/aiops-install

# ---------------------------------------------------------------------------------------------------------------------------------------------------<BR>"
# ---------------------------------------------------------------------------------------------------------------------------------------------------<BR>"
# Do Not Edit Below
# ---------------------------------------------------------------------------------------------------------------------------------------------------<BR>"
# ---------------------------------------------------------------------------------------------------------------------------------------------------<BR>"



export WAIOPS_NAMESPACE=$(oc get po -A|grep aiops-orchestrator-controller |awk '{print$1}')
export EVTMGR_NAMESPACE=$(oc get po -A|grep noi-operator |awk '{print$1}')

: "${WAIOPS_NAMESPACE:=cp4waiops}<BR>"
: "${EVTMGR_NAMESPACE:=noi}<BR>"

CLUSTER_ROUTE=$(oc get routes console -n openshift-console | tail -n 1 2>&1 ) 
CLUSTER_FQDN=$( echo $CLUSTER_ROUTE | awk '{print $2}')
CLUSTER_NAME=${CLUSTER_FQDN##*console.}

echo "<HR><BR>"
echo "<h2>🚀 1. CloudPak for Watson AIOps</h2><BR>"
echo "<BR>"

    echo "    -----------------------------------------------------------------------------------------------------------------------------------------------<BR>"
    echo "<h3>    🐣 1.1 Demo UI</h3><BR>"
    appURL=$(oc get routes -n $WAIOPS_NAMESPACE-demo-ui $WAIOPS_NAMESPACE-demo-ui  -o jsonpath="{['spec']['host']}")|| true
    appToken=$(oc get cm -n $WAIOPS_NAMESPACE-demo-ui $WAIOPS_NAMESPACE-demo-ui-config -o jsonpath='{.data.TOKEN}')
    echo "<table>"
    echo "<tr><td style=\"min-width:300px\">🌏 URL:</td><td><a target="_blank" href=\"https://$appURL/\">https://$appURL/</a></td></tr>"
    echo "<tr><td style=\"min-width:300px\">🔐 Token:</td><td>$appToken<BR>"
    echo "</table>"

    echo "<BR>"
    echo "<BR>"

echo "    -----------------------------------------------------------------------------------------------------------------------------------------------<BR>"
echo " <h3>   🚀 1.2 CP4WAIOps</h3><BR>"

appURL=$(oc get route -n $WAIOPS_NAMESPACE cpd -o jsonpath={.spec.host})

echo "<table>"
echo "<tr><td style=\"min-width:300px\"><h4>📥 CP4WAIOps</h4></td><td></td></tr>"
echo "<tr><td style=\"min-width:300px\">🌏 URL:</td><td><a target="_blank" href=\"https://$appURL/\">https://$appURL/</a></td></tr>"
echo "<tr><td style=\"min-width:300px\">🧑 User:</td><td>demo</td></tr>"
echo "<tr><td style=\"min-width:300px\">🔐 Password:</td><td>Defined at installation</td></tr>"
echo "<tr><td style=\"min-width:300px\">&nbsp;</td><td></td></tr>"
echo "<tr><td style=\"min-width:300px\">🧑 User:</td><td>$(oc -n ibm-common-services get secret platform-auth-idp-credentials -o jsonpath='{.data.admin_username}' | base64 --decode && echo)</td></tr>"
echo "<tr><td style=\"min-width:300px\">🔐 Password:</td><td>$(oc -n ibm-common-services get secret platform-auth-idp-credentials -o jsonpath='{.data.admin_password}' | base64 --decode)</td></tr>"
echo "<tr><td style=\"min-width:300px\">&nbsp;</td><td></td></tr>"

appURL=$(oc get route -n ibm-common-services cp-console -o jsonpath={.spec.host})

echo "<tr><td colspan="2" style=\"min-width:300px\"><h4>📥 Administration hub / Common Services</h4></td></tr>"
echo "<tr><td style=\"min-width:300px\">🌏 URL:</td><td><a target="_blank" href=\"https://$appURL/\">https://$appURL/</a></td></tr>"
echo "<tr><td style=\"min-width:300px\">🧑 User:</td><td>demo</td></tr>"
echo "<tr><td style=\"min-width:300px\">🔐 Password:</td><td>Defined at installation</td></tr>"
echo "<tr><td style=\"min-width:300px\">&nbsp;</td><td></td></tr>"
echo "<tr><td style=\"min-width:300px\">🧑 User:</td><td>$(oc -n ibm-common-services get secret platform-auth-idp-credentials -o jsonpath='{.data.admin_username}' | base64 --decode && echo)</td></tr>"
echo "<tr><td style=\"min-width:300px\">🔐 Password:</td><td>$(oc -n ibm-common-services get secret platform-auth-idp-credentials -o jsonpath='{.data.admin_password}' | base64 --decode)</td></tr>"
echo "</table>"
echo "    <BR>"
echo "    <BR>"



    echo "    -----------------------------------------------------------------------------------------------------------------------------------------------<BR>"
    echo "    <h3>🚀 1.3 Demo Apps - Details</h3><BR>"
    appURL=$(oc get routes -n robot-shop robotshop  -o jsonpath="{['spec']['host']}")|| true

    echo "<table>"
    echo "<tr><td style=\"min-width:300px\"><h4>📥 RobotShop:</h4></td><td></td></tr>"
    echo "<tr><td style=\"min-width:300px\">🌏 URL:</td><td><a target="_blank" href=\"https://$appURL/\">https://$appURL/</a></td></tr>"
    echo "</table>"

    echo "<BR>"
    echo "<BR>"

  
echo "    <BR>"
echo "    <BR>"

echo "<HR><BR>"
echo "<h2>🚀 2. CP4WAIOps Configuration Information</h2><BR>"
echo "    <BR>"
echo "    -----------------------------------------------------------------------------------------------------------------------------------------------<BR>"
echo "    <h3>🚀 2.1 Configure LDAP - Access Control </h3><BR>"

appURL=$(oc get route -n openldap admin -o jsonpath={.spec.host})

echo "<table>"

echo "<tr><td style=\"min-width:300px\"><h4>📥 Identity providers</h4></td><td></td></tr>"
echo "<tr><td style=\"min-width:300px\">🌏 Connection name:</td><td>LDAP</td></tr>"
echo "<tr><td style=\"min-width:300px\">🛠️  Server type:</td><td>Custom</td></tr>"
echo "<tr><td style=\"min-width:300px\">&nbsp;</td><td></td></tr>"
echo "<tr><td style=\"min-width:300px\">🧒 Base DN:</td><td>dc=ibm,dc=com</td></tr>"
echo "<tr><td style=\"min-width:300px\">🧒 Bind DN:</td><td>cn=admin,dc=ibm,dc=com</td></tr>"
echo "<tr><td style=\"min-width:300px\">🔐 Bind DN password:</td><td>Defined at installation </td></tr>"
echo "<tr><td style=\"min-width:300px\">&nbsp;</td><td></td></tr>"
echo "<tr><td style=\"min-width:300px\">🌏 LDAP server URL:</td><td>ldap://openldap.openldap:389</td></tr>"
echo "<tr><td style=\"min-width:300px\">&nbsp;</td><td></td></tr>"
echo "<tr><td style=\"min-width:300px\">🛠️  Group filter:</td><td>(&(cn=%v)(objectclass=groupOfUniqueNames))</td></tr>"
echo "<tr><td style=\"min-width:300px\">🛠️  User filter:</td><td>(&(uid=%v)(objectclass=Person))</td></tr>"
echo "<tr><td style=\"min-width:300px\">🛠️  Group ID map:</td><td>*:cn</td></tr>"
echo "<tr><td style=\"min-width:300px\">🛠️  User ID map:</td><td>*:uid</td></tr>"
echo "<tr><td style=\"min-width:300px\">🛠️  Group member ID map:</td><td>groupOfUniqueNames:uniqueMember</td></tr>"
echo "<tr><td style=\"min-width:300px\">&nbsp;</td><td></td></tr>"
echo "<tr><td style=\"min-width:300px\"><h4>📥 OpenLDAP Admin Login</h4></td><td></td></tr>"
echo "<tr><td style=\"min-width:300px\">&nbsp;</td><td></td></tr>"
echo "<tr><td style=\"min-width:300px\">🌏 URL:</td><td><a target="_blank" href=\"https://$appURL/\">https://$appURL/</a></td></tr>"
echo "<tr><td style=\"min-width:300px\">🧑 User:</td><td>cn=admin,dc=ibm,dc=com</td></tr>"
echo "<tr><td style=\"min-width:300px\">🔐 Password:</td><td>Defined at installation</td></tr>"

echo "</table>"
echo "    <BR>"
echo "    <BR>"




    echo "    -----------------------------------------------------------------------------------------------------------------------------------------------<BR>"
    echo "    <h3>🚀 2.2 Configure ELK </h3><BR>"
    token=$(oc sa get-token cluster-logging-operator -n openshift-logging)
    routeES=`oc get route elasticsearch -o jsonpath={.spec.host} -n openshift-logging`
    routeKIBANA=`oc get route kibana -o jsonpath={.spec.host} -n openshift-logging`

    echo "<table>"
    echo "<tr><td style=\"min-width:300px\"><h4>📥 ELK</h4></td><td></td></tr>"
    echo "<tr><td style=\"min-width:300px\">🌏 ELK service URL:</td><td>https://$routeES/app*</td></tr>"
    echo "<tr><td style=\"min-width:300px\">🌏 Kibana URL:</td><td><a target="_blank" href=\"https://$routeKIBANA/\">https://$routeKIBANA/</a></td></tr>"
    echo "<tr><td style=\"min-width:300px\">🔐 Authentication type:</td><td>Token</td></tr>"
    echo "<tr><td style=\"min-width:300px\">🔐 Token:</td><td>$token</td></tr>"
    echo "<tr><td style=\"min-width:300px\">🕦 TimeZone:</td><td>set to your Timezone</td></tr>"
    echo "<tr><td style=\"min-width:300px\">🚪 Kibana port:</td><td>443</td></tr>"
    echo "<tr><td style=\"min-width:300px\">&nbsp;</td><td></td></tr>"
    echo "<tr><td style=\"min-width:300px\">🗺️  Mapping:</td><td>"
    echo "&nbsp;{ <BR>"
    echo '&nbsp;&nbsp;&nbsp;  \"codec\": \"elk\",<BR>'
    echo '&nbsp;&nbsp;&nbsp;  \"message_field\": \"message\",<BR>'
    echo '&nbsp;&nbsp;&nbsp;  \"log_entity_types\": \"kubernetes.container_image_id, kubernetes.host, kubernetes.pod_name, kubernetes.namespace_name\",<BR>'
    echo '&nbsp;&nbsp;&nbsp;  \"instance_id_field\": \"kubernetes.container_name\",<BR>'
    echo '&nbsp;&nbsp;&nbsp;  \"rolling_time\": 10,<BR>'
    echo '&nbsp;&nbsp;&nbsp;  \"timestamp_field\": \"@timestamp\"<BR>'
    echo '&nbsp;}</td></tr>'
    echo "<tr><td style=\"min-width:300px\">&nbsp;</td><td></td></tr>"
    echo "<tr><td style=\"min-width:300px\">🗺️  Filter: </td><td>"
    echo "&nbsp;      {<BR>"
    echo "&nbsp;&nbsp;&nbsp;          \"query\": {<BR>"
    echo "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;          \"bool\": {<BR>"
    echo "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;   \"must\": {<BR>"
    echo "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;      \"term\" : { \"kubernetes.namespace_name\" : \"robot-shop\" }<BR>"
    echo "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;   }<BR>"
    echo "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  }<BR>"
    echo "&nbsp;&nbsp;&nbsp;        }<BR>"
    echo "&nbsp;      }</td></tr>"
    echo "</table>"
    echo "<BR>"
    echo "<BR>"     
echo "    -----------------------------------------------------------------------------------------------------------------------------------------------<BR>"
echo "    <h3>🚀 2.3 Configure Runbooks - Ansible Automation Controller </h3><BR>"
appURL=$(oc get route -n awx awx -o jsonpath={.spec.host})

echo "<table>"
echo "<tr><td style=\"min-width:300px\">🌏 URL for REST API:</td><td><a target="_blank" href=\"https://$appURL/\">https://$appURL/</a></td></tr>"
echo "<tr><td style=\"min-width:300px\">🔐 Authentication type:</td><td>User ID/Password</td></tr>"
echo "<tr><td style=\"min-width:300px\">🧑 User:</td><td>admin</td></tr>"
echo "<tr><td style=\"min-width:300px\">🔐 Password:</td><td>$(oc -n awx get secret awx-admin-password -o jsonpath='{.data.password}' | base64 --decode && echo)</td></tr>"
echo "</table>"
echo "<BR>"
echo "<BR>"


echo "    -----------------------------------------------------------------------------------------------------------------------------------------------<BR>"
echo "    <h3>🚀 2.4 Configure Runbooks - Runbook Parameters </h3><BR>"
DEMO_TOKEN=$(oc -n default get secret $(oc get secret -n default |grep -m1 demo-admin-token|awk '{print$1}') -o jsonpath='{.data.token}'|base64 --decode)
DEMO_URL=$(oc status|grep -m1 "In project"|awk '{print$6}')

echo "<table>"
echo "<tr><td style=\"min-width:300px\">🌏 Action:</td><td>CP4WAIOPS Mitigate Robotshop Ratings Outage<BR>"
echo "<tr><td style=\"min-width:300px\">🔐 Mapping:</td><td>Fixed Value<BR>"
echo "<tr><td style=\"min-width:300px\">🗺️ Value:</td><td>"
echo "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{<BR>"
echo "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; \"my_k8s_apiurl\": \"$DEMO_URL\",<BR>"
echo "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;   \"my_k8s_apikey\": \"$DEMO_TOKEN\"<BR>"
echo "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<BR></tr>"
echo "</table>"
echo "<BR>"
echo "<BR>"




echo "    -----------------------------------------------------------------------------------------------------------------------------------------------<BR>"
echo "    <h3>🚀 2.5 Configure Applications - RobotShop Kubernetes Observer </h3><BR>"
API_TOKEN=$(oc -n default get secret $(oc get secret -n default |grep -m1 demo-admin-token|awk '{print$1}') -o jsonpath='{.data.token}'|base64 --decode)
API_URL=$(oc status|grep -m1 "In project"|awk '{print$6}')
API_SERVER=$(echo $API_URL| cut -d ":" -f 2| tr -d '/')
API_PORT=$(echo $API_URL| cut -d ":" -f 3)

echo "<table>"
echo "<tr><td style=\"min-width:300px\">🛠️  Name:</td><td>RobotShop</td></tr>"
echo "<tr><td>🛠️  Data center:</td><td>robot-shop</td></tr>"
echo "<tr><td>🛠️  Kubernetes master IP address:</td><td>$API_SERVER</td></tr>"
echo "<tr><td>🛠️  Kubernetes API port:</td><td>$API_PORT</td></tr>"
echo "<tr><td>🛠️  Token:</td><td>$API_TOKEN</td></tr>"
echo "<tr><td>🛠️  Trust all HTTPS certificates:</td><td>true</td></tr>"
echo "<tr><td>🛠️  Correlate analytics events:</td><td>true</td></tr>"
echo "<tr><td>🛠️  Namespaces to observe:</td><td>robot-shop</td></tr>"
echo "</table>"
echo "<BR>"
echo "<BR>"


'''

print('     ❓ Getting ALL LOGINS - this may take a minute or two')
#ALL_LOGINS = check_output(cmd, shell=True, executable='/bin/bash')


stream = os.popen(cmd)
ALL_LOGINS = stream.read().strip()
#ALL_LOGINS="aaa"
#print ('           ALL_LOGINS:              '+ALL_LOGINS)



# ----------------------------------------------------------------------------------------------------------------------------------------------------
# DEFAULT VALUES
# ----------------------------------------------------------------------------------------------------------------------------------------------------
LOG_ITERATIONS=5
TOKEN='test'
LOG_TIME_FORMAT="%Y-%m-%dT%H:%M:%S.000000"
LOG_TIME_STEPS=1000
LOG_TIME_SKEW=60
LOG_TIME_ZONE="-1"



# ----------------------------------------------------------------------------------------------------------------------------------------------------
# GET CONNECTIONS
# ----------------------------------------------------------------------------------------------------------------------------------------------------
print('     ❓ Getting Details Kafka')
stream = os.popen("oc get kafkatopics -n "+aimanagerns+"  | grep -v cp4waiopscp4waiops| grep cp4waiops-cartridge-logs-elk| awk '{print $1;}'")
KAFKA_TOPIC_LOGS = stream.read().strip()
stream = os.popen("oc get secret -n "+aimanagerns+" |grep 'aiops-kafka-secret'|awk '{print$1}'")
KAFKA_SECRET = stream.read().strip()
stream = os.popen("oc get secret "+KAFKA_SECRET+" -n "+aimanagerns+" --template={{.data.username}} | base64 --decode")
KAFKA_USER = stream.read().strip()
stream = os.popen("oc get secret "+KAFKA_SECRET+" -n "+aimanagerns+" --template={{.data.password}} | base64 --decode")
KAFKA_PWD = stream.read().strip()
stream = os.popen("oc get routes iaf-system-kafka-0 -n "+aimanagerns+" -o=jsonpath={.status.ingress[0].host}")
KAFKA_BROKER = stream.read().strip()
stream = os.popen("oc get secret -n "+aimanagerns+" kafka-secrets  -o jsonpath='{.data.ca\.crt}'| base64 --decode")
KAFKA_CERT = stream.read().strip()




print('     ❓ Getting Details Metric Endpoint')
stream = os.popen("oc get route -n "+aimanagerns+"| grep ibm-nginx-svc | awk '{print $2}'")
METRIC_ROUTE = stream.read().strip()
stream = os.popen("oc get secret -n "+aimanagerns+" admin-user-details -o jsonpath='{.data.initial_admin_password}' | base64 --decode")
tmppass = stream.read().strip()
stream = os.popen('curl -k -s -X POST https://'+METRIC_ROUTE+'/icp4d-api/v1/authorize -H "Content-Type: application/json" -d "{\\\"username\\\": \\\"admin\\\",\\\"password\\\": \\\"'+tmppass+'\\\"}" | jq .token | sed "s/\\\"//g"')
METRIC_TOKEN = stream.read().strip()










# ----------------------------------------------------------------------------------------------------------------------------------------------------
# GET CONNECTION DETAILS
# ----------------------------------------------------------------------------------------------------------------------------------------------------
print('     ❓ Getting Details CP4WAIOps')
stream = os.popen('oc get route -n '+aimanagerns+' cpd -o jsonpath={.spec.host}')
aimanager_url = stream.read().strip()
stream = os.popen('oc -n ibm-common-services get secret platform-auth-idp-credentials -o jsonpath={.data.admin_username} | base64 --decode && echo')
aimanager_user = stream.read().strip()
stream = os.popen('oc -n ibm-common-services get secret platform-auth-idp-credentials -o jsonpath={.data.admin_password} | base64 --decode')
aimanager_pwd = stream.read().strip()



print('     ❓ Getting AWX Connection Details')
stream = os.popen('oc get route -n awx awx -o jsonpath={.spec.host}')
awx_url = stream.read().strip()
awx_user = 'admin'
stream = os.popen('oc -n awx get secret awx-admin-password -o jsonpath={.data.password} | base64 --decode && echo')
awx_pwd = stream.read().strip()
 
print('     ❓ Getting Details ELK ')
stream = os.popen('oc get route -n openshift-logging elasticsearch -o jsonpath={.spec.host}')
elk_url = stream.read().strip()

print('     ❓ Getting Details Turbonomic Dashboard')
stream = os.popen('oc get route -n turbonomic nginx -o jsonpath={.spec.host}')
turbonomic_url = stream.read().strip()

print('     ❓ Getting Details Instana Dashboard')
stream = os.popen('oc get route -n instana-core dev-aiops -o jsonpath={.spec.host}')
instana_url = stream.read().strip()


print('     ❓ Getting Details Openshift Console')
stream = os.popen('oc get route -n openshift-console console -o jsonpath={.spec.host}')
openshift_url = stream.read().strip()
stream = os.popen("oc -n default get secret $(oc get secret -n default |grep -m1 demo-admin-token|awk '{print$1}') -o jsonpath='{.data.token}'|base64 --decode")
openshift_token = stream.read().strip()
stream = os.popen("oc config view --minify|grep 'server:'| sed 's/.*server: .*\///'| head -1")
#stream = os.popen("oc status|head -1|awk '{print$6}'")
openshift_server = stream.read().strip()
stream = os.popen("oc get deployment -n cp4waiops-demo-ui cp4waiops-demo-ui -ojson|jq -r '.spec.template.spec.containers[0].image'")
demo_image = stream.read().strip()



print('     ❓ Getting Details Vault')
stream = os.popen('oc get route -n '+aimanagerns+' ibm-vault-deploy-vault-route -o jsonpath={.spec.host}')
vault_url = stream.read().strip()
stream = os.popen('oc get secret -n '+aimanagerns+' ibm-vault-deploy-vault-credential -o jsonpath={.data.token} | base64 --decode')
vault_token = stream.read().strip()

print('     ❓ Getting Details LDAP ')
stream = os.popen('oc get route -n openldap admin -o jsonpath={.spec.host}')
ladp_url = stream.read().strip()
ladp_user = 'cn=admin,dc=ibm,dc=com'
ladp_pwd = 'Defined at installation'

print('     ❓ Getting Details Flink Task Manager')
stream = os.popen('oc get routes -n '+aimanagerns+' job-manager  -o jsonpath={.spec.host}')
flink_url = stream.read().strip()
stream = os.popen('oc get routes -n '+aimanagerns+' job-manager-policy  -o jsonpath={.spec.host}')
flink_url_policy = stream.read().strip()

print('     ❓ Getting Details Spark Master')
stream = os.popen('oc get routes -n '+aimanagerns+' spark  -o jsonpath={.spec.host}')
spark_url = stream.read().strip()

print('     ❓ Getting Details RobotShop')
stream = os.popen('oc get routes -n robot-shop robotshop  -o jsonpath={.spec.host}')
robotshop_url = stream.read().strip()


print('     ❓ Getting Details SockShop')
stream = os.popen('oc get routes -n sock-shop front-end  -o jsonpath={.spec.host}')
sockshop_url = stream.read().strip()

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# GET ENVIRONMENT VALUES
# ----------------------------------------------------------------------------------------------------------------------------------------------------
TOKEN=os.environ.get('TOKEN')
ADMIN_MODE=os.environ.get('ADMIN_MODE')
SIMULATION_MODE=os.environ.get('SIMULATION_MODE')
DEMO_USER=os.environ.get('DEMO_USER')
DEMO_PWD=os.environ.get('DEMO_PWD')




print ('*************************************************************************************************')
print ('*************************************************************************************************')
print ('')
print ('    **************************************************************************************************')
print ('     🔎 Demo Parameters')
print ('    **************************************************************************************************')
print ('           KafkaBroker:           '+KAFKA_BROKER)
print ('           KafkaUser:             '+KAFKA_USER)
print ('           KafkaPWD:              '+KAFKA_PWD)
print ('           KafkaTopic Logs:       '+KAFKA_TOPIC_LOGS)
print ('           Kafka Cert:            '+KAFKA_CERT[:25]+'...')
print ('')   
print ('')   
print ('           Datalayer Route:       '+DATALAYER_ROUTE)
print ('           Datalayer User:        '+DATALAYER_USER)
print ('           Datalayer Pwd:         '+DATALAYER_PWD)
print ('')   
print ('           Metric Route:          '+METRIC_ROUTE)
print ('           Metric Token:          '+METRIC_TOKEN[:25]+'...')
print ('')   
print ('           Token:                 '+TOKEN)
print ('')   
print ('           Admin:                 '+ADMIN_MODE)
print ('           Can create incident:   '+SIMULATION_MODE)
print ('')   
print ('           Demo User:             '+DEMO_USER)
print ('           Demo Password:         '+DEMO_PWD)
print ('')
print ('    **************************************************************************************************')

SLACK_URL=str(os.environ.get('SLACK_URL'))
SLACK_USER=str(os.environ.get('SLACK_USER'))
SLACK_PWD=str(os.environ.get('SLACK_PWD'))


print ('*************************************************************************************************')
print (' ✅ DEMOUI is READY')
print ('*************************************************************************************************')


# ----------------------------------------------------------------------------------------------------------------------------------------------------
# REST ENDPOINTS
# ----------------------------------------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------------------------------------
#    INSTANA
# ----------------------------------------------------------------------------------------------------------------------------------------------------

def instanaCreateIncident(request):
    print('🌏 instanaCreateIncident')
    global loggedin
    global INCIDENT_ACTIVE
    global ROBOT_SHOP_OUTAGE_ACTIVE
    global SOCK_SHOP_OUTAGE_ACTIVE
    print('     🟠 OUTAGE - Incident:'+str(INCIDENT_ACTIVE)+' - RS-OUTAGE:'+str(ROBOT_SHOP_OUTAGE_ACTIVE)+' - SOCK-OUTAGE:'+str(SOCK_SHOP_OUTAGE_ACTIVE))

    verifyLogin(request)
    if loggedin=='true':
        template = loader.get_template('demouiapp/home.html')

        print('🌏 Create Instana outage')
        os.system('oc set env deployment ratings -n robot-shop PDO_URL="mysql:host=mysql;dbname=ratings-dev;charset=utf8mb4"')
        os.system('oc set env deployment load -n robot-shop ERROR=1')

        url = 'https://'+DATALAYER_ROUTE+'/irdatalayer.aiops.io/active/v1/stories'
        auth=HTTPBasicAuth(DATALAYER_USER, DATALAYER_PWD)
        headers = {'Content-Type': 'application/json', 'Accept-Charset': 'UTF-8', 'x-username' : 'admin', 'x-subscription-id' : 'cfd95b7e-3bc7-4006-a4a8-a73a79c71255'}
        response = requests.get(url, headers=headers, auth=auth, verify=False)
        responseJSON=response.json()
        responseStr=str(json.dumps(responseJSON))
        if '"state": "assignedToIndividual"' in responseStr or '"state": "inProgress"' in responseStr:
            print('     🔴 INCIDENT FOUND')
            INCIDENT_ACTIVE=True
        else:
            print('     🟢 NO INCIDENT')
            INCIDENT_ACTIVE=False
        ROBOT_SHOP_OUTAGE_ACTIVE=True

    else:
        template = loader.get_template('demouiapp/loginui.html')
    context = {
        'loggedin': loggedin,
        'aimanager_url': aimanager_url,
        'aimanager_user': aimanager_user,
        'aimanager_pwd': aimanager_pwd,
        'SLACK_URL': SLACK_URL,
        'SLACK_USER': SLACK_USER,
        'SLACK_PWD': SLACK_PWD,
        'DEMO_USER': DEMO_USER,
        'DEMO_PWD': DEMO_PWD,
        'awx_url': awx_url,
        'awx_user': awx_user,
        'awx_pwd': awx_pwd,
        'elk_url': elk_url,
        'turbonomic_url': turbonomic_url,
        'instana_url': instana_url,
        'openshift_url': openshift_url,
        'openshift_token': openshift_token,
        'openshift_server': openshift_server,
        'vault_url': vault_url,
        'vault_token': vault_token,
        'ladp_url': ladp_url,
        'ladp_user': ladp_user,
        'ladp_pwd': ladp_pwd,
        'flink_url': flink_url,
        'flink_url_policy': flink_url_policy,
        'robotshop_url': robotshop_url,
        'sockshop_url': sockshop_url,
        'spark_url': spark_url,
        'INSTANCE_NAME': INSTANCE_NAME,
        'INSTANCE_IMAGE': INSTANCE_IMAGE,
        'ADMIN_MODE': ADMIN_MODE,
        'INCIDENT_ACTIVE': INCIDENT_ACTIVE,
        'ROBOT_SHOP_OUTAGE_ACTIVE': ROBOT_SHOP_OUTAGE_ACTIVE,
        'SOCK_SHOP_OUTAGE_ACTIVE': SOCK_SHOP_OUTAGE_ACTIVE,
        'SIMULATION_MODE': SIMULATION_MODE,
        'PAGE_TITLE': 'Demo UI for ' + INSTANCE_NAME,
        'PAGE_NAME': 'index'
    }
    return HttpResponse(template.render(context, request))

def instanaMitigateIncident(request):
    print('🌏 instanaMitigateIncident')
    global loggedin
    global INCIDENT_ACTIVE
    global ROBOT_SHOP_OUTAGE_ACTIVE
    global SOCK_SHOP_OUTAGE_ACTIVE

    print('     🟠 OUTAGE - Incident:'+str(INCIDENT_ACTIVE)+' - RS-OUTAGE:'+str(ROBOT_SHOP_OUTAGE_ACTIVE)+' - SOCK-OUTAGE:'+str(SOCK_SHOP_OUTAGE_ACTIVE))
    verifyLogin(request)
    if loggedin=='true':
        template = loader.get_template('demouiapp/home.html')

        print('🌏 Mitigate Instana outage')
        os.system('oc patch service mysql -n robot-shop --patch "{\\"spec\\": {\\"selector\\": {\\"service\\": \\"mysql\\"}}}"')
        os.system('oc set env deployment ratings -n robot-shop PDO_URL-')
        os.system('oc set env deployment load -n robot-shop ERROR=0')
        os.system("oc delete pod $(oc get po -n robot-shop|grep shipping|awk '{print$1}') -n robot-shop --ignore-not-found")
        print('🌏 Mitigate Sockshop Catalog outage')
        os.system('oc patch service catalogue -n sock-shop --patch "{\\"spec\\": {\\"selector\\": {\\"name\\": \\"catalog\\"}}}"')

        url = 'https://'+DATALAYER_ROUTE+'/irdatalayer.aiops.io/active/v1/stories'
        auth=HTTPBasicAuth(DATALAYER_USER, DATALAYER_PWD)
        headers = {'Content-Type': 'application/json', 'Accept-Charset': 'UTF-8', 'x-username' : 'admin', 'x-subscription-id' : 'cfd95b7e-3bc7-4006-a4a8-a73a79c71255'}
        response = requests.get(url, headers=headers, auth=auth, verify=False)
        responseJSON=response.json()
        responseStr=str(json.dumps(responseJSON))
        if '"state": "assignedToIndividual"' in responseStr or '"state": "inProgress"' in responseStr:
            print('     🔴 INCIDENT FOUND')
            INCIDENT_ACTIVE=True
        else:
            print('     🟢 NO INCIDENT')
            INCIDENT_ACTIVE=False

        ROBOT_SHOP_OUTAGE_ACTIVE=False
        SOCK_SHOP_OUTAGE_ACTIVE=False

    else:
        template = loader.get_template('demouiapp/loginui.html')
    context = {
        'loggedin': loggedin,
        'aimanager_url': aimanager_url,
        'aimanager_user': aimanager_user,
        'aimanager_pwd': aimanager_pwd,
        'SLACK_URL': SLACK_URL,
        'SLACK_USER': SLACK_USER,
        'SLACK_PWD': SLACK_PWD,
        'DEMO_USER': DEMO_USER,
        'DEMO_PWD': DEMO_PWD,
        'awx_url': awx_url,
        'awx_user': awx_user,
        'awx_pwd': awx_pwd,
        'elk_url': elk_url,
        'turbonomic_url': turbonomic_url,
        'instana_url': instana_url,
        'openshift_url': openshift_url,
        'openshift_token': openshift_token,
        'openshift_server': openshift_server,
        'vault_url': vault_url,
        'vault_token': vault_token,
        'ladp_url': ladp_url,
        'ladp_user': ladp_user,
        'ladp_pwd': ladp_pwd,
        'flink_url': flink_url,
        'flink_url_policy': flink_url_policy,
        'robotshop_url': robotshop_url,
        'sockshop_url': sockshop_url,
        'spark_url': spark_url,
        'INSTANCE_NAME': INSTANCE_NAME,
        'INSTANCE_IMAGE': INSTANCE_IMAGE,
        'ADMIN_MODE': ADMIN_MODE,
        'INCIDENT_ACTIVE': INCIDENT_ACTIVE,
        'ROBOT_SHOP_OUTAGE_ACTIVE': ROBOT_SHOP_OUTAGE_ACTIVE,
        'SOCK_SHOP_OUTAGE_ACTIVE': SOCK_SHOP_OUTAGE_ACTIVE,
        'SIMULATION_MODE': SIMULATION_MODE,
        'PAGE_TITLE': 'Demo UI for ' + INSTANCE_NAME,
        'PAGE_NAME': 'index'
    }
    return HttpResponse(template.render(context, request))



# ----------------------------------------------------------------------------------------------------------------------------------------------------
#    WAIOPS
# ----------------------------------------------------------------------------------------------------------------------------------------------------

def injectAllREST(request):
    print('🌏 injectAllREST')
    global loggedin
    global INCIDENT_ACTIVE
    global ROBOT_SHOP_OUTAGE_ACTIVE
    global SOCK_SHOP_OUTAGE_ACTIVE
    print('     🟠 OUTAGE - Incident:'+str(INCIDENT_ACTIVE)+' - RS-OUTAGE:'+str(ROBOT_SHOP_OUTAGE_ACTIVE)+' - SOCK-OUTAGE:'+str(SOCK_SHOP_OUTAGE_ACTIVE))
    verifyLogin(request)

    if loggedin=='true':
        template = loader.get_template('demouiapp/home.html')
        
        print('🌏 Create RobotShop MySQL outage')
        os.system('oc set env deployment ratings -n robot-shop PDO_URL="mysql:host=mysql;dbname=ratings-dev;charset=utf8mb4"')
        os.system('oc set env deployment load -n robot-shop ERROR=1')
        
        # injectEventsMem(DATALAYER_ROUTE,DATALAYER_USER,DATALAYER_PWD)
        # injectMetricsMem(METRIC_ROUTE,METRIC_TOKEN)
        # injectLogs(KAFKA_BROKER,KAFKA_USER,KAFKA_PWD,KAFKA_TOPIC_LOGS,KAFKA_CERT,LOG_TIME_FORMAT,DEMO_LOGS)

        print('  🟠 Create THREADS')
        threadEvents = Thread(target=injectEventsMem, args=(DATALAYER_ROUTE,DATALAYER_USER,DATALAYER_PWD))
        threadMetrics = Thread(target=injectMetricsMem, args=(METRIC_ROUTE,METRIC_TOKEN,))
        threadLogs = Thread(target=injectLogsRobotShop, args=(KAFKA_BROKER,KAFKA_USER,KAFKA_PWD,KAFKA_TOPIC_LOGS,KAFKA_CERT,LOG_TIME_FORMAT,DEMO_LOGS,))

        print('  🟠 Start THREADS')
        # start the threads
        threadEvents.start()
        threadMetrics.start()
        threadLogs.start()
        # print('  🟠 Join THREADS')
        # # wait for the threads to complete
        # threadEvents.join()
        # threadMetrics.join()
        # threadLogs.join()
        time.sleep(3)

        INCIDENT_ACTIVE=True
        ROBOT_SHOP_OUTAGE_ACTIVE=True

    else:
        template = loader.get_template('demouiapp/loginui.html')


    context = {
        'loggedin': loggedin,
        'aimanager_url': aimanager_url,
        'aimanager_user': aimanager_user,
        'aimanager_pwd': aimanager_pwd,
        'SLACK_URL': SLACK_URL,
        'SLACK_USER': SLACK_USER,
        'SLACK_PWD': SLACK_PWD,
        'DEMO_USER': DEMO_USER,
        'DEMO_PWD': DEMO_PWD,
        'awx_url': awx_url,
        'awx_user': awx_user,
        'awx_pwd': awx_pwd,
        'elk_url': elk_url,
        'turbonomic_url': turbonomic_url,
        'instana_url': instana_url,
        'instana_url': instana_url,
        'openshift_url': openshift_url,
        'openshift_token': openshift_token,
        'openshift_server': openshift_server,
        'vault_url': vault_url,
        'vault_token': vault_token,
        'ladp_url': ladp_url,
        'ladp_user': ladp_user,
        'ladp_pwd': ladp_pwd,
        'flink_url': flink_url,
        'flink_url_policy': flink_url_policy,
        'robotshop_url': robotshop_url,
        'sockshop_url': sockshop_url,
        'spark_url': spark_url,
        'INSTANCE_NAME': INSTANCE_NAME,
        'INSTANCE_IMAGE': INSTANCE_IMAGE,
        'ADMIN_MODE': ADMIN_MODE,
        'INCIDENT_ACTIVE': INCIDENT_ACTIVE,
        'ROBOT_SHOP_OUTAGE_ACTIVE': ROBOT_SHOP_OUTAGE_ACTIVE,
        'SOCK_SHOP_OUTAGE_ACTIVE': SOCK_SHOP_OUTAGE_ACTIVE,
        'SIMULATION_MODE': SIMULATION_MODE,
        'PAGE_TITLE': 'Demo UI for ' + INSTANCE_NAME,
        'PAGE_NAME': 'index'
    }
    return HttpResponse(template.render(context, request))


def injectAllFanREST(request):
    print('🌏 injectAllFanREST')
    global loggedin
    global INCIDENT_ACTIVE
    global ROBOT_SHOP_OUTAGE_ACTIVE
    global SOCK_SHOP_OUTAGE_ACTIVE
    print('     🟠 OUTAGE - Incident:'+str(INCIDENT_ACTIVE)+' - RS-OUTAGE:'+str(ROBOT_SHOP_OUTAGE_ACTIVE)+' - SOCK-OUTAGE:'+str(SOCK_SHOP_OUTAGE_ACTIVE))
    verifyLogin(request)
    if loggedin=='true':
        template = loader.get_template('demouiapp/home.html')

        print('🌏 Create RobotShop MySQL outage')
        os.system('oc set env deployment ratings -n robot-shop PDO_URL="mysql:host=mysql;dbname=ratings-dev;charset=utf8mb4"')
        os.system('oc set env deployment load -n robot-shop ERROR=1')

        INCIDENT_ACTIVE=True
        ROBOT_SHOP_OUTAGE_ACTIVE=True


        # injectMetricsFanTemp(METRIC_ROUTE,METRIC_TOKEN)
        # time.sleep(3)
        # injectEventsFan(DATALAYER_ROUTE,DATALAYER_USER,DATALAYER_PWD)
        # injectMetricsFan(METRIC_ROUTE,METRIC_TOKEN)
        # injectLogs(KAFKA_BROKER,KAFKA_USER,KAFKA_PWD,KAFKA_TOPIC_LOGS,KAFKA_CERT,LOG_TIME_FORMAT,DEMO_LOGS)


        print('  🟠 Create THREADS')
        threadMetrics1 = Thread(target=injectMetricsFanTemp, args=(METRIC_ROUTE,METRIC_TOKEN,))
        threadEvents = Thread(target=injectEventsFan, args=(DATALAYER_ROUTE,DATALAYER_USER,DATALAYER_PWD))
        threadMetrics2 = Thread(target=injectEventsFan, args=(METRIC_ROUTE,METRIC_TOKEN,DATALAYER_PWD))
        threadLogs = Thread(target=injectLogsRobotShop, args=(KAFKA_BROKER,KAFKA_USER,KAFKA_PWD,KAFKA_TOPIC_LOGS,KAFKA_CERT,LOG_TIME_FORMAT,DEMO_LOGS,))

        print('  🟠 Start THREADS')
        # start the threads
        threadMetrics1.start()
        threadEvents.start()
        threadMetrics2.start()
        threadLogs.start()
        time.sleep(3)

    else:
        template = loader.get_template('demouiapp/loginui.html')


    context = {
        'loggedin': loggedin,
        'aimanager_url': aimanager_url,
        'aimanager_user': aimanager_user,
        'aimanager_pwd': aimanager_pwd,
        'SLACK_URL': SLACK_URL,
        'SLACK_USER': SLACK_USER,
        'SLACK_PWD': SLACK_PWD,
        'DEMO_USER': DEMO_USER,
        'DEMO_PWD': DEMO_PWD,
        'awx_url': awx_url,
        'awx_user': awx_user,
        'awx_pwd': awx_pwd,
        'elk_url': elk_url,
        'turbonomic_url': turbonomic_url,
        'instana_url': instana_url,
        'openshift_url': openshift_url,
        'openshift_token': openshift_token,
        'openshift_server': openshift_server,
        'vault_url': vault_url,
        'vault_token': vault_token,
        'ladp_url': ladp_url,
        'ladp_user': ladp_user,
        'ladp_pwd': ladp_pwd,
        'flink_url': flink_url,
        'flink_url_policy': flink_url_policy,
        'robotshop_url': robotshop_url,
        'sockshop_url': sockshop_url,
        'spark_url': spark_url,
        'INSTANCE_NAME': INSTANCE_NAME,
        'INSTANCE_IMAGE': INSTANCE_IMAGE,
        'ADMIN_MODE': ADMIN_MODE,
        'INCIDENT_ACTIVE': INCIDENT_ACTIVE,
        'ROBOT_SHOP_OUTAGE_ACTIVE': ROBOT_SHOP_OUTAGE_ACTIVE,
        'SOCK_SHOP_OUTAGE_ACTIVE': SOCK_SHOP_OUTAGE_ACTIVE,
        'SIMULATION_MODE': SIMULATION_MODE,
        'PAGE_TITLE': 'Demo UI for ' + INSTANCE_NAME,
        'PAGE_NAME': 'index'
    }
    return HttpResponse(template.render(context, request))



def injectAllNetREST(request):
    print('🌏 injectAllNetREST')
    global loggedin
    global INCIDENT_ACTIVE
    global ROBOT_SHOP_OUTAGE_ACTIVE
    global SOCK_SHOP_OUTAGE_ACTIVE
    print('     🟠 OUTAGE - Incident:'+str(INCIDENT_ACTIVE)+' - RS-OUTAGE:'+str(ROBOT_SHOP_OUTAGE_ACTIVE)+' - SOCK-OUTAGE:'+str(SOCK_SHOP_OUTAGE_ACTIVE))

    verifyLogin(request)
    if loggedin=='true':
        template = loader.get_template('demouiapp/home.html')

        print('🌏 Create RobotShop Network outage')
        #os.system('oc patch service mysql -n robot-shop --patch "{\\"spec\\": {\\"selector\\": {\\"service\\": \\"mysql-outage\\"}}}"')

        print('  🟠 Create THREADS')
        threadMetrics1 = Thread(target=injectMetricsNet, args=(METRIC_ROUTE,METRIC_TOKEN,))
        threadEvents = Thread(target=injectEventsNet, args=(DATALAYER_ROUTE,DATALAYER_USER,DATALAYER_PWD))
        threadLogs = Thread(target=injectLogsRobotShop, args=(KAFKA_BROKER,KAFKA_USER,KAFKA_PWD,KAFKA_TOPIC_LOGS,KAFKA_CERT,LOG_TIME_FORMAT,DEMO_LOGS,))

        print('  🟠 Start THREADS')
        # start the threads
        threadMetrics1.start()
        threadEvents.start()
        threadLogs.start()
        time.sleep(3)

        INCIDENT_ACTIVE=True

        stream = os.popen("oc get deployment  -n robot-shop ratings  -o yaml")
        RATINGS_YAML = stream.read().strip()
        if 'ratings-dev' in RATINGS_YAML:
            print('     🔴 ROBOT SHOP OUTAGE ACTIVE')
            ROBOT_SHOP_OUTAGE_ACTIVE=True
        else:
            print('     🟢 ROBOT SHOP OUTAGE INACTIVE')
            ROBOT_SHOP_OUTAGE_ACTIVE=True

    else:
        template = loader.get_template('demouiapp/loginui.html')


    context = {
        'loggedin': loggedin,
        'aimanager_url': aimanager_url,
        'aimanager_user': aimanager_user,
        'aimanager_pwd': aimanager_pwd,
        'SLACK_URL': SLACK_URL,
        'SLACK_USER': SLACK_USER,
        'SLACK_PWD': SLACK_PWD,
        'DEMO_USER': DEMO_USER,
        'DEMO_PWD': DEMO_PWD,
        'awx_url': awx_url,
        'awx_user': awx_user,
        'awx_pwd': awx_pwd,
        'elk_url': elk_url,
        'turbonomic_url': turbonomic_url,
        'instana_url': instana_url,
        'openshift_url': openshift_url,
        'openshift_token': openshift_token,
        'openshift_server': openshift_server,
        'vault_url': vault_url,
        'vault_token': vault_token,
        'ladp_url': ladp_url,
        'ladp_user': ladp_user,
        'ladp_pwd': ladp_pwd,
        'flink_url': flink_url,
        'flink_url_policy': flink_url_policy,
        'robotshop_url': robotshop_url,
        'sockshop_url': sockshop_url,
        'spark_url': spark_url,
        'INSTANCE_NAME': INSTANCE_NAME,
        'INSTANCE_IMAGE': INSTANCE_IMAGE,
        'ADMIN_MODE': ADMIN_MODE,
        'INCIDENT_ACTIVE': INCIDENT_ACTIVE,
        'ROBOT_SHOP_OUTAGE_ACTIVE': ROBOT_SHOP_OUTAGE_ACTIVE,
        'SOCK_SHOP_OUTAGE_ACTIVE': SOCK_SHOP_OUTAGE_ACTIVE,
        'SIMULATION_MODE': SIMULATION_MODE,
        'PAGE_TITLE': 'Demo UI for ' + INSTANCE_NAME,
        'PAGE_NAME': 'index'
    }
    return HttpResponse(template.render(context, request))



def injectAllFanACMEREST(request):
    print('🌏 injectAllFanACMEREST')
    global loggedin
    global INCIDENT_ACTIVE
    global ROBOT_SHOP_OUTAGE_ACTIVE
    global SOCK_SHOP_OUTAGE_ACTIVE
    print('     🟠 OUTAGE - Incident:'+str(INCIDENT_ACTIVE)+' - ACME-OUTAGE:'+str(ROBOT_SHOP_OUTAGE_ACTIVE))
    verifyLogin(request)
    if loggedin=='true':
        template = loader.get_template('demouiapp/home.html')

        INCIDENT_ACTIVE=True

        # injectMetricsFanTemp(METRIC_ROUTE,METRIC_TOKEN)
        # time.sleep(3)
        # injectEventsFan(DATALAYER_ROUTE,DATALAYER_USER,DATALAYER_PWD)
        # injectMetricsFan(METRIC_ROUTE,METRIC_TOKEN)
        # injectLogs(KAFKA_BROKER,KAFKA_USER,KAFKA_PWD,KAFKA_TOPIC_LOGS,KAFKA_CERT,LOG_TIME_FORMAT,DEMO_LOGS)


        print('  🟠 Create THREADS')
        threadMetrics1 = Thread(target=injectMetricsFanTempACME, args=(METRIC_ROUTE,METRIC_TOKEN,))
        threadEvents = Thread(target=injectEventsFanACME, args=(DATALAYER_ROUTE,DATALAYER_USER,DATALAYER_PWD))
        threadMetrics2 = Thread(target=injectMetricsFanACME, args=(METRIC_ROUTE,METRIC_TOKEN,))

        print('  🟠 Start THREADS')
        # start the threads
        threadMetrics1.start()
        threadEvents.start()
        threadMetrics2.start()
        time.sleep(3)

    else:
        template = loader.get_template('demouiapp/loginui.html')


    context = {
        'loggedin': loggedin,
        'aimanager_url': aimanager_url,
        'aimanager_user': aimanager_user,
        'aimanager_pwd': aimanager_pwd,
        'SLACK_URL': SLACK_URL,
        'SLACK_USER': SLACK_USER,
        'SLACK_PWD': SLACK_PWD,
        'DEMO_USER': DEMO_USER,
        'DEMO_PWD': DEMO_PWD,
        'awx_url': awx_url,
        'awx_user': awx_user,
        'awx_pwd': awx_pwd,
        'elk_url': elk_url,
        'turbonomic_url': turbonomic_url,
        'instana_url': instana_url,
        'openshift_url': openshift_url,
        'openshift_token': openshift_token,
        'openshift_server': openshift_server,
        'vault_url': vault_url,
        'vault_token': vault_token,
        'ladp_url': ladp_url,
        'ladp_user': ladp_user,
        'ladp_pwd': ladp_pwd,
        'flink_url': flink_url,
        'flink_url_policy': flink_url_policy,
        'robotshop_url': robotshop_url,
        'sockshop_url': sockshop_url,
        'spark_url': spark_url,
        'INSTANCE_NAME': INSTANCE_NAME,
        'INSTANCE_IMAGE': INSTANCE_IMAGE,
        'ADMIN_MODE': ADMIN_MODE,
        'INCIDENT_ACTIVE': INCIDENT_ACTIVE,
        'ROBOT_SHOP_OUTAGE_ACTIVE': ROBOT_SHOP_OUTAGE_ACTIVE,
        'SOCK_SHOP_OUTAGE_ACTIVE': SOCK_SHOP_OUTAGE_ACTIVE,
        'SIMULATION_MODE': SIMULATION_MODE,
        'PAGE_TITLE': 'Demo UI for ' + INSTANCE_NAME,
        'PAGE_NAME': 'index'
    }
    return HttpResponse(template.render(context, request))



def injectAllNetSOCKREST(request):
    print('🌏 injectAllNetSOCKREST')
    global loggedin
    global INCIDENT_ACTIVE
    global ROBOT_SHOP_OUTAGE_ACTIVE
    global SOCK_SHOP_OUTAGE_ACTIVE
    print('     🟠 OUTAGE - Incident:'+str(INCIDENT_ACTIVE)+' - SOCK-OUTAGE:'+str(ROBOT_SHOP_OUTAGE_ACTIVE))
    verifyLogin(request)
    if loggedin=='true':
        template = loader.get_template('demouiapp/home.html')

        INCIDENT_ACTIVE=True
        SOCK_SHOP_OUTAGE_ACTIVE=True

        print('🌏 Create Sockshop Catalog outage')
        os.system('oc patch service catalogue -n sock-shop --patch "{\\"spec\\": {\\"selector\\": {\\"name\\": \\"catalog-outage\\"}}}"')
        # injectMetricsFanTemp(METRIC_ROUTE,METRIC_TOKEN)
        # time.sleep(3)
        # injectEventsFan(DATALAYER_ROUTE,DATALAYER_USER,DATALAYER_PWD)
        # injectMetricsFan(METRIC_ROUTE,METRIC_TOKEN)
        # injectLogs(KAFKA_BROKER,KAFKA_USER,KAFKA_PWD,KAFKA_TOPIC_LOGS,KAFKA_CERT,LOG_TIME_FORMAT,DEMO_LOGS)


        print('  🟠 Create THREADS')
        threadEvents = Thread(target=injectEventsNetSock, args=(DATALAYER_ROUTE,DATALAYER_USER,DATALAYER_PWD))
        threadMetrics = Thread(target=injectMetricsSockNet, args=(METRIC_ROUTE,METRIC_TOKEN,))
        threadLogs = Thread(target=injectLogsSockShop, args=(KAFKA_BROKER,KAFKA_USER,KAFKA_PWD,KAFKA_TOPIC_LOGS,KAFKA_CERT,LOG_TIME_FORMAT,DEMO_LOGS_SOCK,))
        threadLogs1 = Thread(target=injectLogsSockShop, args=(KAFKA_BROKER,KAFKA_USER,KAFKA_PWD,KAFKA_TOPIC_LOGS,KAFKA_CERT,LOG_TIME_FORMAT,DEMO_LOGS_SOCK,))
        threadLogs2 = Thread(target=injectLogsSockShop, args=(KAFKA_BROKER,KAFKA_USER,KAFKA_PWD,KAFKA_TOPIC_LOGS,KAFKA_CERT,LOG_TIME_FORMAT,DEMO_LOGS_SOCK,))

        print('  🟠 Start THREADS')
        # start the threads
        threadMetrics.start()
        threadEvents.start()
        threadLogs.start()
        time.sleep(5)
        threadLogs1.start()
        time.sleep(5)
        threadLogs2.start()

    else:
        template = loader.get_template('demouiapp/loginui.html')


    context = {
        'loggedin': loggedin,
        'aimanager_url': aimanager_url,
        'aimanager_user': aimanager_user,
        'aimanager_pwd': aimanager_pwd,
        'SLACK_URL': SLACK_URL,
        'SLACK_USER': SLACK_USER,
        'SLACK_PWD': SLACK_PWD,
        'DEMO_USER': DEMO_USER,
        'DEMO_PWD': DEMO_PWD,
        'awx_url': awx_url,
        'awx_user': awx_user,
        'awx_pwd': awx_pwd,
        'elk_url': elk_url,
        'turbonomic_url': turbonomic_url,
        'instana_url': instana_url,
        'openshift_url': openshift_url,
        'openshift_token': openshift_token,
        'openshift_server': openshift_server,
        'vault_url': vault_url,
        'vault_token': vault_token,
        'ladp_url': ladp_url,
        'ladp_user': ladp_user,
        'ladp_pwd': ladp_pwd,
        'flink_url': flink_url,
        'flink_url_policy': flink_url_policy,
        'robotshop_url': robotshop_url,
        'sockshop_url': sockshop_url,
        'spark_url': spark_url,
        'INSTANCE_NAME': INSTANCE_NAME,
        'INSTANCE_IMAGE': INSTANCE_IMAGE,
        'ADMIN_MODE': ADMIN_MODE,
        'INCIDENT_ACTIVE': INCIDENT_ACTIVE,
        'ROBOT_SHOP_OUTAGE_ACTIVE': ROBOT_SHOP_OUTAGE_ACTIVE,
        'SOCK_SHOP_OUTAGE_ACTIVE': SOCK_SHOP_OUTAGE_ACTIVE,
        'SIMULATION_MODE': SIMULATION_MODE,
        'PAGE_TITLE': 'Demo UI for ' + INSTANCE_NAME,
        'PAGE_NAME': 'index'
    }
    return HttpResponse(template.render(context, request))



def injectLogsREST(request):
    print('🌏 injectLogsREST')
    global loggedin
    global INCIDENT_ACTIVE
    global ROBOT_SHOP_OUTAGE_ACTIVE
    global SOCK_SHOP_OUTAGE_ACTIVE
    print('     🟠 OUTAGE - Incident:'+str(INCIDENT_ACTIVE)+' - RS-OUTAGE:'+str(ROBOT_SHOP_OUTAGE_ACTIVE)+' - SOCK-OUTAGE:'+str(SOCK_SHOP_OUTAGE_ACTIVE))
    verifyLogin(request)
    if loggedin=='true':
        template = loader.get_template('demouiapp/home.html')
        injectLogsRobotShop(KAFKA_BROKER,KAFKA_USER,KAFKA_PWD,KAFKA_TOPIC_LOGS,KAFKA_CERT,LOG_TIME_FORMAT,DEMO_LOGS)
    else:
        template = loader.get_template('demouiapp/loginui.html')

    context = {
        'loggedin': loggedin,
        'aimanager_url': aimanager_url,
        'aimanager_user': aimanager_user,
        'aimanager_pwd': aimanager_pwd,
        'SLACK_URL': SLACK_URL,
        'SLACK_USER': SLACK_USER,
        'SLACK_PWD': SLACK_PWD,
        'DEMO_USER': DEMO_USER,
        'DEMO_PWD': DEMO_PWD,
        'awx_url': awx_url,
        'awx_user': awx_user,
        'awx_pwd': awx_pwd,
        'elk_url': elk_url,
        'turbonomic_url': turbonomic_url,
        'instana_url': instana_url,
        'openshift_url': openshift_url,
        'openshift_token': openshift_token,
        'openshift_server': openshift_server,
        'vault_url': vault_url,
        'vault_token': vault_token,
        'ladp_url': ladp_url,
        'ladp_user': ladp_user,
        'ladp_pwd': ladp_pwd,
        'flink_url': flink_url,
        'flink_url_policy': flink_url_policy,
        'robotshop_url': robotshop_url,
        'sockshop_url': sockshop_url,
        'spark_url': spark_url,
        'INSTANCE_NAME': INSTANCE_NAME,
        'INSTANCE_IMAGE': INSTANCE_IMAGE,
        'ADMIN_MODE': ADMIN_MODE,
        'INCIDENT_ACTIVE': INCIDENT_ACTIVE,
        'ROBOT_SHOP_OUTAGE_ACTIVE': ROBOT_SHOP_OUTAGE_ACTIVE,
        'SOCK_SHOP_OUTAGE_ACTIVE': SOCK_SHOP_OUTAGE_ACTIVE,
        'SIMULATION_MODE': SIMULATION_MODE,
        'PAGE_TITLE': 'Demo UI for ' + INSTANCE_NAME,
        'PAGE_NAME': 'index'
    }
    return HttpResponse(template.render(context, request))


def injectEventsREST(request):
    print('🌏 injectEventsREST')
    global loggedin
    global INCIDENT_ACTIVE
    global ROBOT_SHOP_OUTAGE_ACTIVE
    global SOCK_SHOP_OUTAGE_ACTIVE
    print('     🟠 OUTAGE - Incident:'+str(INCIDENT_ACTIVE)+' - RS-OUTAGE:'+str(ROBOT_SHOP_OUTAGE_ACTIVE)+' - SOCK-OUTAGE:'+str(SOCK_SHOP_OUTAGE_ACTIVE))
    verifyLogin(request)

    if loggedin=='true':
        injectEventsMem(DATALAYER_ROUTE,DATALAYER_USER,DATALAYER_PWD)
        template = loader.get_template('demouiapp/home.html')
    else:
        template = loader.get_template('demouiapp/loginui.html')

    context = {
        'loggedin': loggedin,
        'aimanager_url': aimanager_url,
        'aimanager_user': aimanager_user,
        'aimanager_pwd': aimanager_pwd,
        'SLACK_URL': SLACK_URL,
        'SLACK_USER': SLACK_USER,
        'SLACK_PWD': SLACK_PWD,
        'DEMO_USER': DEMO_USER,
        'DEMO_PWD': DEMO_PWD,
        'awx_url': awx_url,
        'awx_user': awx_user,
        'awx_pwd': awx_pwd,
        'elk_url': elk_url,
        'turbonomic_url': turbonomic_url,
        'instana_url': instana_url,
        'openshift_url': openshift_url,
        'openshift_token': openshift_token,
        'openshift_server': openshift_server,
        'vault_url': vault_url,
        'vault_token': vault_token,
        'ladp_url': ladp_url,
        'ladp_user': ladp_user,
        'ladp_pwd': ladp_pwd,
        'flink_url': flink_url,
        'flink_url_policy': flink_url_policy,
        'robotshop_url': robotshop_url,
        'sockshop_url': sockshop_url,
        'spark_url': spark_url,
        'INSTANCE_NAME': INSTANCE_NAME,
        'INSTANCE_IMAGE': INSTANCE_IMAGE,
        'ADMIN_MODE': ADMIN_MODE,
        'INCIDENT_ACTIVE': INCIDENT_ACTIVE,
        'ROBOT_SHOP_OUTAGE_ACTIVE': ROBOT_SHOP_OUTAGE_ACTIVE,
        'SOCK_SHOP_OUTAGE_ACTIVE': SOCK_SHOP_OUTAGE_ACTIVE,
        'SIMULATION_MODE': SIMULATION_MODE,
        'PAGE_TITLE': 'Demo UI for ' + INSTANCE_NAME,
        'PAGE_NAME': 'index'
    }
    return HttpResponse(template.render(context, request))

def injectMetricsREST(request):
    print('🌏 injectMetricsREST')
    global loggedin
    global INCIDENT_ACTIVE
    global ROBOT_SHOP_OUTAGE_ACTIVE
    global SOCK_SHOP_OUTAGE_ACTIVE
    print('     🟠 OUTAGE - Incident:'+str(INCIDENT_ACTIVE)+' - RS-OUTAGE:'+str(ROBOT_SHOP_OUTAGE_ACTIVE)+' - SOCK-OUTAGE:'+str(SOCK_SHOP_OUTAGE_ACTIVE))
    verifyLogin(request)

    if loggedin=='true':
        injectMetricsMem(METRIC_ROUTE,METRIC_TOKEN)
        template = loader.get_template('demouiapp/home.html')
    else:
        template = loader.get_template('demouiapp/loginui.html')
    context = {
        'loggedin': loggedin,
        'aimanager_url': aimanager_url,
        'aimanager_user': aimanager_user,
        'aimanager_pwd': aimanager_pwd,
        'SLACK_URL': SLACK_URL,
        'SLACK_USER': SLACK_USER,
        'SLACK_PWD': SLACK_PWD,
        'DEMO_USER': DEMO_USER,
        'DEMO_PWD': DEMO_PWD,
        'awx_url': awx_url,
        'awx_user': awx_user,
        'awx_pwd': awx_pwd,
        'elk_url': elk_url,
        'turbonomic_url': turbonomic_url,
        'instana_url': instana_url,
        'openshift_url': openshift_url,
        'openshift_token': openshift_token,
        'openshift_server': openshift_server,
        'vault_url': vault_url,
        'vault_token': vault_token,
        'ladp_url': ladp_url,
        'ladp_user': ladp_user,
        'ladp_pwd': ladp_pwd,
        'flink_url': flink_url,
        'flink_url_policy': flink_url_policy,
        'robotshop_url': robotshop_url,
        'sockshop_url': sockshop_url,
        'spark_url': spark_url,
        'INSTANCE_NAME': INSTANCE_NAME,
        'INSTANCE_IMAGE': INSTANCE_IMAGE,
        'ADMIN_MODE': ADMIN_MODE,
        'INCIDENT_ACTIVE': INCIDENT_ACTIVE,
        'ROBOT_SHOP_OUTAGE_ACTIVE': ROBOT_SHOP_OUTAGE_ACTIVE,
        'SOCK_SHOP_OUTAGE_ACTIVE': SOCK_SHOP_OUTAGE_ACTIVE,
        'SIMULATION_MODE': SIMULATION_MODE,
        'PAGE_TITLE': 'Demo UI for ' + INSTANCE_NAME,
        'PAGE_NAME': 'index'
    }
    return HttpResponse(template.render(context, request))



def clearAllREST(request):
    print('🌏 clearAllREST')
    global loggedin
    global INCIDENT_ACTIVE
    global ROBOT_SHOP_OUTAGE_ACTIVE
    global SOCK_SHOP_OUTAGE_ACTIVE
    print('     🟠 OUTAGE - Incident:'+str(INCIDENT_ACTIVE)+' - RS-OUTAGE:'+str(ROBOT_SHOP_OUTAGE_ACTIVE)+' - SOCK-OUTAGE:'+str(SOCK_SHOP_OUTAGE_ACTIVE))
    verifyLogin(request)
    if loggedin=='true':
        template = loader.get_template('demouiapp/home.html')

        print('🌏 Reset RobotShop MySQL outage')
        os.system('oc patch service mysql -n robot-shop --patch "{\\"spec\\": {\\"selector\\": {\\"service\\": \\"mysql\\"}}}"')
        os.system('oc set env deployment ratings -n robot-shop PDO_URL-')
        os.system('oc set env deployment load -n robot-shop ERROR=0')
        os.system("oc delete pod $(oc get po -n robot-shop|grep shipping|awk '{print$1}') -n robot-shop --ignore-not-found")
        print('🌏 Mitigate Sockshop Catalog outage')
        os.system('oc patch service catalogue -n sock-shop --patch "{\\"spec\\": {\\"selector\\": {\\"name\\": \\"catalog\\"}}}"')

        stream = os.popen("oc get kafkatopics -n "+aimanagerns+"  | grep -v cp4waiopscp4waiops| grep cp4waiops-cartridge-logs-elk| awk '{print $1;}'")
        KAFKA_TOPIC_LOGS = stream.read().strip()


        # closeAlerts(DATALAYER_ROUTE,DATALAYER_USER,DATALAYER_PWD)
        # closeStories(DATALAYER_ROUTE,DATALAYER_USER,DATALAYER_PWD)

        print('  🟠 Create THREADS')
        threadCloseAlerts = Thread(target=closeAlerts, args=(DATALAYER_ROUTE,DATALAYER_USER,DATALAYER_PWD))
        threadCloseStories = Thread(target=closeStories, args=(DATALAYER_ROUTE,DATALAYER_USER,DATALAYER_PWD))

        print('  🟠 Start THREADS')
        # start the threads
        threadCloseAlerts.start()
        threadCloseStories.start()
        time.sleep(3)

        INCIDENT_ACTIVE=False
        ROBOT_SHOP_OUTAGE_ACTIVE=False
        SOCK_SHOP_OUTAGE_ACTIVE=False


    else:
        template = loader.get_template('demouiapp/loginui.html')

    context = {
        'loggedin': loggedin,
        'aimanager_url': aimanager_url,
        'aimanager_user': aimanager_user,
        'aimanager_pwd': aimanager_pwd,
        'SLACK_URL': SLACK_URL,
        'SLACK_USER': SLACK_USER,
        'SLACK_PWD': SLACK_PWD,
        'DEMO_USER': DEMO_USER,
        'DEMO_PWD': DEMO_PWD,
        'awx_url': awx_url,
        'awx_user': awx_user,
        'awx_pwd': awx_pwd,
        'elk_url': elk_url,
        'turbonomic_url': turbonomic_url,
        'instana_url': instana_url,
        'openshift_url': openshift_url,
        'openshift_token': openshift_token,
        'openshift_server': openshift_server,
        'vault_url': vault_url,
        'vault_token': vault_token,
        'ladp_url': ladp_url,
        'ladp_user': ladp_user,
        'ladp_pwd': ladp_pwd,
        'flink_url': flink_url,
        'flink_url_policy': flink_url_policy,
        'robotshop_url': robotshop_url,
        'sockshop_url': sockshop_url,
        'spark_url': spark_url,
        'INSTANCE_NAME': INSTANCE_NAME,
        'INSTANCE_IMAGE': INSTANCE_IMAGE,
        'ADMIN_MODE': ADMIN_MODE,
        'INCIDENT_ACTIVE': INCIDENT_ACTIVE,
        'ROBOT_SHOP_OUTAGE_ACTIVE': ROBOT_SHOP_OUTAGE_ACTIVE,
        'SOCK_SHOP_OUTAGE_ACTIVE': SOCK_SHOP_OUTAGE_ACTIVE,
        'SIMULATION_MODE': SIMULATION_MODE,
        'PAGE_TITLE': 'Demo UI for ' + INSTANCE_NAME,
        'PAGE_NAME': 'index'


        



    }
    return HttpResponse(template.render(context, request))

def clearEventsREST(request):
    print('🌏 clearEventsREST')
    global loggedin
    global INCIDENT_ACTIVE
    global ROBOT_SHOP_OUTAGE_ACTIVE
    global SOCK_SHOP_OUTAGE_ACTIVE
    print('     🟠 OUTAGE - Incident:'+str(INCIDENT_ACTIVE)+' - RS-OUTAGE:'+str(ROBOT_SHOP_OUTAGE_ACTIVE)+' - SOCK-OUTAGE:'+str(SOCK_SHOP_OUTAGE_ACTIVE))
    verifyLogin(request)
    if loggedin=='true':
        template = loader.get_template('demouiapp/home.html')
        closeAlerts(DATALAYER_ROUTE,DATALAYER_USER,DATALAYER_PWD)
    else:
        template = loader.get_template('demouiapp/loginui.html')

    context = {
        'loggedin': loggedin,
        'aimanager_url': aimanager_url,
        'aimanager_user': aimanager_user,
        'aimanager_pwd': aimanager_pwd,
        'SLACK_URL': SLACK_URL,
        'SLACK_USER': SLACK_USER,
        'SLACK_PWD': SLACK_PWD,
        'DEMO_USER': DEMO_USER,
        'DEMO_PWD': DEMO_PWD,
        'awx_url': awx_url,
        'awx_user': awx_user,
        'awx_pwd': awx_pwd,
        'elk_url': elk_url,
        'turbonomic_url': turbonomic_url,
        'instana_url': instana_url,
        'openshift_url': openshift_url,
        'openshift_token': openshift_token,
        'openshift_server': openshift_server,
        'vault_url': vault_url,
        'vault_token': vault_token,
        'ladp_url': ladp_url,
        'ladp_user': ladp_user,
        'ladp_pwd': ladp_pwd,
        'flink_url': flink_url,
        'flink_url_policy': flink_url_policy,
        'robotshop_url': robotshop_url,
        'sockshop_url': sockshop_url,
        'spark_url': spark_url,
        'INSTANCE_NAME': INSTANCE_NAME,
        'INSTANCE_IMAGE': INSTANCE_IMAGE,
        'ADMIN_MODE': ADMIN_MODE,
        'INCIDENT_ACTIVE': INCIDENT_ACTIVE,
        'ROBOT_SHOP_OUTAGE_ACTIVE': ROBOT_SHOP_OUTAGE_ACTIVE,
        'SOCK_SHOP_OUTAGE_ACTIVE': SOCK_SHOP_OUTAGE_ACTIVE,
        'SIMULATION_MODE': SIMULATION_MODE,
        'PAGE_TITLE': 'Demo UI for ' + INSTANCE_NAME,
        'PAGE_NAME': 'index'
    }
    return HttpResponse(template.render(context, request))

def clearStoriesREST(request):
    print('🌏 clearStoriesREST')
    global loggedin
    global INCIDENT_ACTIVE
    global ROBOT_SHOP_OUTAGE_ACTIVE
    global SOCK_SHOP_OUTAGE_ACTIVE
    print('     🟠 OUTAGE - Incident:'+str(INCIDENT_ACTIVE)+' - RS-OUTAGE:'+str(ROBOT_SHOP_OUTAGE_ACTIVE)+' - SOCK-OUTAGE:'+str(SOCK_SHOP_OUTAGE_ACTIVE))
    verifyLogin(request)
    if loggedin=='true':
        template = loader.get_template('demouiapp/home.html')
        closeStories(DATALAYER_ROUTE,DATALAYER_USER,DATALAYER_PWD)
    else:
        template = loader.get_template('demouiapp/loginui.html')
        INCIDENT_ACTIVE=False
        ROBOT_SHOP_OUTAGE_ACTIVE=False
        SOCK_SHOP_OUTAGE_ACTIVE=False

    context = {
        'loggedin': loggedin,
        'aimanager_url': aimanager_url,
        'aimanager_user': aimanager_user,
        'aimanager_pwd': aimanager_pwd,
        'SLACK_URL': SLACK_URL,
        'SLACK_USER': SLACK_USER,
        'SLACK_PWD': SLACK_PWD,
        'DEMO_USER': DEMO_USER,
        'DEMO_PWD': DEMO_PWD,
        'awx_url': awx_url,
        'awx_user': awx_user,
        'awx_pwd': awx_pwd,
        'elk_url': elk_url,
        'turbonomic_url': turbonomic_url,
        'instana_url': instana_url,
        'openshift_url': openshift_url,
        'openshift_token': openshift_token,
        'openshift_server': openshift_server,
        'vault_url': vault_url,
        'vault_token': vault_token,
        'ladp_url': ladp_url,
        'ladp_user': ladp_user,
        'ladp_pwd': ladp_pwd,
        'flink_url': flink_url,
        'flink_url_policy': flink_url_policy,
        'robotshop_url': robotshop_url,
        'sockshop_url': sockshop_url,
        'spark_url': spark_url,
        'INSTANCE_NAME': INSTANCE_NAME,
        'INSTANCE_IMAGE': INSTANCE_IMAGE,
        'ADMIN_MODE': ADMIN_MODE,
        'INCIDENT_ACTIVE': INCIDENT_ACTIVE,
        'ROBOT_SHOP_OUTAGE_ACTIVE': ROBOT_SHOP_OUTAGE_ACTIVE,
        'SOCK_SHOP_OUTAGE_ACTIVE': SOCK_SHOP_OUTAGE_ACTIVE,
        'SIMULATION_MODE': SIMULATION_MODE,
        'PAGE_TITLE': 'Demo UI for ' + INSTANCE_NAME,
        'PAGE_NAME': 'index'
    }
    return HttpResponse(template.render(context, request))

def login(request):
    print('🌏 login')

    global loggedin
    global loginip
    global INCIDENT_ACTIVE
    global ROBOT_SHOP_OUTAGE_ACTIVE
    global SOCK_SHOP_OUTAGE_ACTIVE
    print('     🟠 OUTAGE - Incident:'+str(INCIDENT_ACTIVE)+' - RS-OUTAGE:'+str(ROBOT_SHOP_OUTAGE_ACTIVE)+' - SOCK-OUTAGE:'+str(SOCK_SHOP_OUTAGE_ACTIVE))

    response = HttpResponse()

    verifyLogin(request)
    currenttoken=request.GET.get("token", "none")
    token=os.environ.get('TOKEN')
    print ('  🔐 Login attempt with Password/Token: '+currenttoken)
    if token==currenttoken:
        loggedin='true'
        template = loader.get_template('demouiapp/home.html')
        print ('  ✅ Login SUCCESSFUL')

        response.set_cookie('last_visit', time.localtime())
        actloginip=request.META.get('REMOTE_ADDR')
        response.set_cookie('IP', actloginip)
        response.set_cookie('token', hashlib.md5((token).encode()).hexdigest())

        context = {
            'loggedin': loggedin,
            'aimanager_url': aimanager_url,
            'aimanager_user': aimanager_user,
            'aimanager_pwd': aimanager_pwd,
            'SLACK_URL': SLACK_URL,
            'SLACK_USER': SLACK_USER,
            'SLACK_PWD': SLACK_PWD,
            'DEMO_USER': DEMO_USER,
            'DEMO_PWD': DEMO_PWD,
            'ADMIN_MODE': ADMIN_MODE,
            'INCIDENT_ACTIVE': INCIDENT_ACTIVE,
            'ROBOT_SHOP_OUTAGE_ACTIVE': ROBOT_SHOP_OUTAGE_ACTIVE,
            'SOCK_SHOP_OUTAGE_ACTIVE': SOCK_SHOP_OUTAGE_ACTIVE,
            'SIMULATION_MODE': SIMULATION_MODE,  
            'INSTANCE_NAME': INSTANCE_NAME,
            'INSTANCE_IMAGE': INSTANCE_IMAGE,
            'SIMULATION_MODE': SIMULATION_MODE,
            'PAGE_TITLE': 'Demo UI for ' + INSTANCE_NAME,
            'PAGE_NAME': 'index'
        }
    else:
        loggedin='false'
        template = loader.get_template('demouiapp/loginui.html')
        print ('  ❗ Login NOT SUCCESSFUL')

        response.set_cookie('last_visit', 'none')
        response.set_cookie('IP', 'none')
        response.set_cookie('token', 'none')


        context = {
            'loggedin': loggedin,
            'aimanager_url': aimanager_url,
            'aimanager_user': aimanager_user,
            'aimanager_pwd': aimanager_pwd,
            'SLACK_URL': SLACK_URL,
            'SLACK_USER': SLACK_USER,
            'SLACK_PWD': SLACK_PWD,
            'DEMO_USER': DEMO_USER,
            'DEMO_PWD': DEMO_PWD,
            'ADMIN_MODE': ADMIN_MODE,
            'INCIDENT_ACTIVE': INCIDENT_ACTIVE,
            'ROBOT_SHOP_OUTAGE_ACTIVE': ROBOT_SHOP_OUTAGE_ACTIVE,
            'SOCK_SHOP_OUTAGE_ACTIVE': SOCK_SHOP_OUTAGE_ACTIVE,
            'SIMULATION_MODE': SIMULATION_MODE,  
            'INSTANCE_NAME': INSTANCE_NAME,
            'INSTANCE_IMAGE': INSTANCE_IMAGE,
            'SIMULATION_MODE': SIMULATION_MODE,
            'PAGE_TITLE': 'Demo UI for ' + INSTANCE_NAME,
            'PAGE_NAME': 'login'
        }



    response.write(template.render(context, request))
    return response
    #return HttpResponse("Hello, world. You're at the polls index.")

def verifyLogin(request):
    actToken=request.COOKIES.get('token', 'none')
    print('   🔎 SESSION TOKEN:'+str(actToken))

    global loggedin
    
    actloginip=request.META.get('REMOTE_ADDR')
    token=os.environ.get('TOKEN')

    if str(actToken)!=hashlib.md5((token).encode()).hexdigest():
        loggedin='false'

        #print('        ❌ LOGIN NOK: NEW IP')
        print('   🔎 Check IP : ❌ LOGIN NOK: ACT SESSION TOKEN:'+str(actToken)+' - LOGGED IN: '+str(loggedin))
    else:
        print('   🔎 Check IP : ✅ LOGIN OK: '+str(loggedin))
        #print('        ✅ LOGIN OK')
        #loggedin='true'
        loginip=request.META.get('REMOTE_ADDR')



# def verifyLogin(request):
#     actloginip=request.META.get('REMOTE_ADDR')

#     global loggedin
#     global loginip


#     if str(loginip)!=str(actloginip):
#         loggedin='false'
#         loginip=request.META.get('REMOTE_ADDR')

#         #print('        ❌ LOGIN NOK: NEW IP')
#         print('   🔎 Check IP : ❌ LOGIN NOK: ACT IP:'+str(actloginip)+'  - SAVED IP:'+str(loginip))
#     else:
#         print('   🔎 Check IP : ✅ LOGIN OK: '+str(loggedin))
#         #print('        ✅ LOGIN OK')
#         #loggedin='true'
#         loginip=request.META.get('REMOTE_ADDR')




# ----------------------------------------------------------------------------------------------------------------------------------------------------
# PAGE ENDPOINTS
# ----------------------------------------------------------------------------------------------------------------------------------------------------


def loginui(request):
    print('🌏 loginui')
    global loggedin


    verifyLogin(request)
    template = loader.get_template('demouiapp/login.html')
    context = {
        'loggedin': loggedin,
    }
    return HttpResponse(template.render(context, request))


def index(request):
    print('🌏 index')
    global loggedin
    global INCIDENT_ACTIVE
    global ROBOT_SHOP_OUTAGE_ACTIVE
    global SOCK_SHOP_OUTAGE_ACTIVE
    print('     🟠 OUTAGE - Incident:'+str(INCIDENT_ACTIVE)+' - RS-OUTAGE:'+str(ROBOT_SHOP_OUTAGE_ACTIVE)+' - SOCK-OUTAGE:'+str(SOCK_SHOP_OUTAGE_ACTIVE))

    verifyLogin(request)

    if loggedin=='true':
        template = loader.get_template('demouiapp/home.html')
        url = 'https://'+DATALAYER_ROUTE+'/irdatalayer.aiops.io/active/v1/stories'
        auth=HTTPBasicAuth(DATALAYER_USER, DATALAYER_PWD)
        headers = {'Content-Type': 'application/json', 'Accept-Charset': 'UTF-8', 'x-username' : 'admin', 'x-subscription-id' : 'cfd95b7e-3bc7-4006-a4a8-a73a79c71255'}
        response = requests.get(url, headers=headers, auth=auth, verify=False)
        responseJSON=response.json()
        responseStr=str(json.dumps(responseJSON))
        if '"state": "assignedToIndividual"' in responseStr or '"state": "inProgress"' in responseStr:
            print('     🔴 INCIDENT FOUND')
            INCIDENT_ACTIVE=True
        else:
            print('     🟢 NO INCIDENT')
            INCIDENT_ACTIVE=False

        stream = os.popen("oc get deployment  -n robot-shop ratings  -o yaml")
        RATINGS_YAML = stream.read().strip()
        if 'ratings-dev' in RATINGS_YAML:
            print('     🔴 ROBOT SHOP OUTAGE ACTIVE')
            ROBOT_SHOP_OUTAGE_ACTIVE=True
        else:
            print('     🟢 ROBOT SHOP OUTAGE INACTIVE')
            ROBOT_SHOP_OUTAGE_ACTIVE=False

        stream = os.popen("oc get service  -n sock-shop catalogue  -o yaml")
        CATALOG_YAML = stream.read().strip()
        if '-outage' in CATALOG_YAML:
            print('     🔴 SOCK SHOP OUTAGE ACTIVE')
            SOCK_SHOP_OUTAGE_ACTIVE=True
        else:
            print('     🟢 SOCK SHOP OUTAGE INACTIVE')
            SOCK_SHOP_OUTAGE_ACTIVE=False


    else:
        template = loader.get_template('demouiapp/loginui.html')

    context = {
        'loggedin': loggedin,
        'aimanager_url': aimanager_url,
        'aimanager_user': aimanager_user,
        'aimanager_pwd': aimanager_pwd,
        'SLACK_URL': SLACK_URL,
        'SLACK_USER': SLACK_USER,
        'SLACK_PWD': SLACK_PWD,
        'ADMIN_MODE': ADMIN_MODE,
        'INCIDENT_ACTIVE': INCIDENT_ACTIVE,
        'ROBOT_SHOP_OUTAGE_ACTIVE': ROBOT_SHOP_OUTAGE_ACTIVE,
        'SOCK_SHOP_OUTAGE_ACTIVE': SOCK_SHOP_OUTAGE_ACTIVE,
        'SIMULATION_MODE': SIMULATION_MODE,  
        'DEMO_USER': DEMO_USER,
        'DEMO_PWD': DEMO_PWD,
        'INSTANCE_NAME': INSTANCE_NAME,
        'INSTANCE_IMAGE': INSTANCE_IMAGE,
        'ADMIN_MODE': ADMIN_MODE,
        'INCIDENT_ACTIVE': INCIDENT_ACTIVE,
        'ROBOT_SHOP_OUTAGE_ACTIVE': ROBOT_SHOP_OUTAGE_ACTIVE,
        'SOCK_SHOP_OUTAGE_ACTIVE': SOCK_SHOP_OUTAGE_ACTIVE,
        'SIMULATION_MODE': SIMULATION_MODE,
        'PAGE_TITLE': 'Demo UI for ' + INSTANCE_NAME,
        'PAGE_NAME': 'index'
        
    }
    return HttpResponse(template.render(context, request))

def doc(request):
    print('🌏 doc')
    global loggedin
    global INCIDENT_ACTIVE
    global ROBOT_SHOP_OUTAGE_ACTIVE
    global SOCK_SHOP_OUTAGE_ACTIVE
    print('     🟠 OUTAGE - Incident:'+str(INCIDENT_ACTIVE)+' - RS-OUTAGE:'+str(ROBOT_SHOP_OUTAGE_ACTIVE)+' - SOCK-OUTAGE:'+str(SOCK_SHOP_OUTAGE_ACTIVE))

    verifyLogin(request)

    if loggedin=='true':
        template = loader.get_template('demouiapp/doc.html')
    else:
        template = loader.get_template('demouiapp/loginui.html')
    context = {
        'loggedin': loggedin,
        'aimanager_url': aimanager_url,
        'aimanager_user': aimanager_user,
        'aimanager_pwd': aimanager_pwd,
        'awx_url': awx_url,
        'awx_user': awx_user,
        'awx_pwd': awx_pwd,
        'elk_url': elk_url,
        'turbonomic_url': turbonomic_url,
        'instana_url': instana_url,
        'openshift_url': openshift_url,
        'openshift_token': openshift_token,
        'openshift_server': openshift_server,
        'vault_url': vault_url,
        'vault_token': vault_token,
        'ladp_url': ladp_url,
        'ladp_user': ladp_user,
        'ladp_pwd': ladp_pwd,
        'flink_url': flink_url,
        'flink_url_policy': flink_url_policy,
        'robotshop_url': robotshop_url,
        'sockshop_url': sockshop_url,
        'spark_url': spark_url,
        'INSTANCE_NAME': INSTANCE_NAME,
        'INSTANCE_IMAGE': INSTANCE_IMAGE,
        'ADMIN_MODE': ADMIN_MODE,
        'INCIDENT_ACTIVE': INCIDENT_ACTIVE,
        'ROBOT_SHOP_OUTAGE_ACTIVE': ROBOT_SHOP_OUTAGE_ACTIVE,
        'SOCK_SHOP_OUTAGE_ACTIVE': SOCK_SHOP_OUTAGE_ACTIVE,
        'SIMULATION_MODE': SIMULATION_MODE,
        'PAGE_TITLE': 'CloudPak for Watson AIOps Demo UI',
        'PAGE_NAME': 'doc'
    }
    return HttpResponse(template.render(context, request))

def apps(request):
    print('🌏 apps')
    global loggedin
    global INCIDENT_ACTIVE
    global ROBOT_SHOP_OUTAGE_ACTIVE
    global SOCK_SHOP_OUTAGE_ACTIVE
    print('     🟠 OUTAGE - Incident:'+str(INCIDENT_ACTIVE)+' - RS-OUTAGE:'+str(ROBOT_SHOP_OUTAGE_ACTIVE)+' - SOCK-OUTAGE:'+str(SOCK_SHOP_OUTAGE_ACTIVE))

    verifyLogin(request)

    if loggedin=='true':
        template = loader.get_template('demouiapp/apps.html')
    else:
        template = loader.get_template('demouiapp/loginui.html')
    context = {
        'loggedin': loggedin,
        'aimanager_url': aimanager_url,
        'aimanager_user': aimanager_user,
        'aimanager_pwd': aimanager_pwd,
        'awx_url': awx_url,
        'awx_user': awx_user,
        'awx_pwd': awx_pwd,
        'elk_url': elk_url,
        'turbonomic_url': turbonomic_url,
        'instana_url': instana_url,
        'openshift_url': openshift_url,
        'openshift_token': openshift_token,
        'openshift_server': openshift_server,
        'vault_url': vault_url,
        'vault_token': vault_token,
        'ladp_url': ladp_url,
        'ladp_user': ladp_user,
        'ladp_pwd': ladp_pwd,
        'flink_url': flink_url,
        'flink_url_policy': flink_url_policy,
        'robotshop_url': robotshop_url,
        'sockshop_url': sockshop_url,
        'spark_url': spark_url,

        'SLACK_URL': SLACK_URL,
        'SLACK_USER': SLACK_USER,
        'SLACK_PWD': SLACK_PWD,
        'ADMIN_MODE': ADMIN_MODE,
        'INCIDENT_ACTIVE': INCIDENT_ACTIVE,
        'ROBOT_SHOP_OUTAGE_ACTIVE': ROBOT_SHOP_OUTAGE_ACTIVE,
        'SOCK_SHOP_OUTAGE_ACTIVE': SOCK_SHOP_OUTAGE_ACTIVE,
        'SIMULATION_MODE': SIMULATION_MODE,  
        'DEMO_USER': DEMO_USER,
        'DEMO_PWD': DEMO_PWD,
        'INSTANCE_NAME': INSTANCE_NAME,
        'INSTANCE_IMAGE': INSTANCE_IMAGE,
        'PAGE_TITLE': 'IBM AIOps Applications',
        'PAGE_NAME': 'apps'
        
    }
    return HttpResponse(template.render(context, request))

def apps_system(request):
    print('🌏 apps_system')
    global loggedin
    global INCIDENT_ACTIVE
    global ROBOT_SHOP_OUTAGE_ACTIVE
    global SOCK_SHOP_OUTAGE_ACTIVE
    print('     🟠 OUTAGE - Incident:'+str(INCIDENT_ACTIVE)+' - RS-OUTAGE:'+str(ROBOT_SHOP_OUTAGE_ACTIVE)+' - SOCK-OUTAGE:'+str(SOCK_SHOP_OUTAGE_ACTIVE))

    verifyLogin(request)

    if loggedin=='true':
        template = loader.get_template('demouiapp/apps_system.html')
    else:
        template = loader.get_template('demouiapp/loginui.html')
    context = {
        'loggedin': loggedin,
        'aimanager_url': aimanager_url,
        'aimanager_user': aimanager_user,
        'aimanager_pwd': aimanager_pwd,
        'awx_url': awx_url,
        'awx_user': awx_user,
        'awx_pwd': awx_pwd,
        'elk_url': elk_url,
        'turbonomic_url': turbonomic_url,
        'instana_url': instana_url,
        'openshift_url': openshift_url,
        'openshift_token': openshift_token,
        'openshift_server': openshift_server,
        'vault_url': vault_url,
        'vault_token': vault_token,
        'ladp_url': ladp_url,
        'ladp_user': ladp_user,
        'ladp_pwd': ladp_pwd,
        'flink_url': flink_url,
        'flink_url_policy': flink_url_policy,
        'robotshop_url': robotshop_url,
        'sockshop_url': sockshop_url,
        'spark_url': spark_url,

        'SLACK_URL': SLACK_URL,
        'SLACK_USER': SLACK_USER,
        'SLACK_PWD': SLACK_PWD,
        'ADMIN_MODE': ADMIN_MODE,
        'INCIDENT_ACTIVE': INCIDENT_ACTIVE,
        'ROBOT_SHOP_OUTAGE_ACTIVE': ROBOT_SHOP_OUTAGE_ACTIVE,
        'SOCK_SHOP_OUTAGE_ACTIVE': SOCK_SHOP_OUTAGE_ACTIVE,
        'SIMULATION_MODE': SIMULATION_MODE,  
        'DEMO_USER': DEMO_USER,
        'DEMO_PWD': DEMO_PWD,
        'INSTANCE_NAME': INSTANCE_NAME,
        'INSTANCE_IMAGE': INSTANCE_IMAGE,
        'PAGE_TITLE': 'System Links',
        'PAGE_NAME': 'system'
        
    }
    return HttpResponse(template.render(context, request))


def apps_demo(request):
    print('🌏 apps_demo')
    global loggedin
    global INCIDENT_ACTIVE
    global ROBOT_SHOP_OUTAGE_ACTIVE
    global SOCK_SHOP_OUTAGE_ACTIVE
    print('     🟠 OUTAGE - Incident:'+str(INCIDENT_ACTIVE)+' - RS-OUTAGE:'+str(ROBOT_SHOP_OUTAGE_ACTIVE)+' - SOCK-OUTAGE:'+str(SOCK_SHOP_OUTAGE_ACTIVE))

    verifyLogin(request)

    if loggedin=='true':
        template = loader.get_template('demouiapp/apps_demo.html')
    else:
        template = loader.get_template('demouiapp/loginui.html')
    context = {
        'loggedin': loggedin,
        'aimanager_url': aimanager_url,
        'aimanager_user': aimanager_user,
        'aimanager_pwd': aimanager_pwd,
        'awx_url': awx_url,
        'awx_user': awx_user,
        'awx_pwd': awx_pwd,
        'elk_url': elk_url,
        'turbonomic_url': turbonomic_url,
        'instana_url': instana_url,
        'openshift_url': openshift_url,
        'openshift_token': openshift_token,
        'openshift_server': openshift_server,
        'vault_url': vault_url,
        'vault_token': vault_token,
        'ladp_url': ladp_url,
        'ladp_user': ladp_user,
        'ladp_pwd': ladp_pwd,
        'flink_url': flink_url,
        'flink_url_policy': flink_url_policy,
        'robotshop_url': robotshop_url,
        'sockshop_url': sockshop_url,
        'spark_url': spark_url,

        'SLACK_URL': SLACK_URL,
        'SLACK_USER': SLACK_USER,
        'SLACK_PWD': SLACK_PWD,
        'ADMIN_MODE': ADMIN_MODE,
        'INCIDENT_ACTIVE': INCIDENT_ACTIVE,
        'ROBOT_SHOP_OUTAGE_ACTIVE': ROBOT_SHOP_OUTAGE_ACTIVE,
        'SOCK_SHOP_OUTAGE_ACTIVE': SOCK_SHOP_OUTAGE_ACTIVE,
        'SIMULATION_MODE': SIMULATION_MODE,  
        'DEMO_USER': DEMO_USER,
        'DEMO_PWD': DEMO_PWD,
        'INSTANCE_NAME': INSTANCE_NAME,
        'INSTANCE_IMAGE': INSTANCE_IMAGE,
        'PAGE_TITLE': 'Demo Scenarios',
        'PAGE_NAME': 'demo'
        
    }
    return HttpResponse(template.render(context, request))



def apps_additional(request):
    print('🌏 apps_additional')
    global loggedin
    global INCIDENT_ACTIVE
    global ROBOT_SHOP_OUTAGE_ACTIVE
    global SOCK_SHOP_OUTAGE_ACTIVE
    print('     🟠 OUTAGE - Incident:'+str(INCIDENT_ACTIVE)+' - RS-OUTAGE:'+str(ROBOT_SHOP_OUTAGE_ACTIVE)+' - SOCK-OUTAGE:'+str(SOCK_SHOP_OUTAGE_ACTIVE))

    verifyLogin(request)

    if loggedin=='true':
        template = loader.get_template('demouiapp/apps_additional.html')
    else:
        template = loader.get_template('demouiapp/loginui.html')
    context = {
        'loggedin': loggedin,
        'aimanager_url': aimanager_url,
        'aimanager_user': aimanager_user,
        'aimanager_pwd': aimanager_pwd,
        'awx_url': awx_url,
        'awx_user': awx_user,
        'awx_pwd': awx_pwd,
        'elk_url': elk_url,
        'turbonomic_url': turbonomic_url,
        'instana_url': instana_url,
        'openshift_url': openshift_url,
        'openshift_token': openshift_token,
        'openshift_server': openshift_server,
        'vault_url': vault_url,
        'vault_token': vault_token,
        'ladp_url': ladp_url,
        'ladp_user': ladp_user,
        'ladp_pwd': ladp_pwd,
        'flink_url': flink_url,
        'flink_url_policy': flink_url_policy,
        'robotshop_url': robotshop_url,
        'sockshop_url': sockshop_url,
        'spark_url': spark_url,

        'SLACK_URL': SLACK_URL,
        'SLACK_USER': SLACK_USER,
        'SLACK_PWD': SLACK_PWD,
        'ADMIN_MODE': ADMIN_MODE,
        'INCIDENT_ACTIVE': INCIDENT_ACTIVE,
        'ROBOT_SHOP_OUTAGE_ACTIVE': ROBOT_SHOP_OUTAGE_ACTIVE,
        'SOCK_SHOP_OUTAGE_ACTIVE': SOCK_SHOP_OUTAGE_ACTIVE,
        'SIMULATION_MODE': SIMULATION_MODE,  
        'DEMO_USER': DEMO_USER,
        'DEMO_PWD': DEMO_PWD,
        'INSTANCE_NAME': INSTANCE_NAME,
        'INSTANCE_IMAGE': INSTANCE_IMAGE,
        'PAGE_TITLE': 'Third-party Applications',
        'PAGE_NAME': 'TEST'
        
    }
    return HttpResponse(template.render(context, request))



def about(request):
    print('🌏 about')

    global loggedin
    global INCIDENT_ACTIVE
    global ROBOT_SHOP_OUTAGE_ACTIVE
    global SOCK_SHOP_OUTAGE_ACTIVE
    print('     🟠 OUTAGE - Incident:'+str(INCIDENT_ACTIVE)+' - RS-OUTAGE:'+str(ROBOT_SHOP_OUTAGE_ACTIVE)+' - SOCK-OUTAGE:'+str(SOCK_SHOP_OUTAGE_ACTIVE))

    verifyLogin(request)

    if loggedin=='true':
        template = loader.get_template('demouiapp/about.html')
    else:
        template = loader.get_template('demouiapp/loginui.html')
    context = {
        'loggedin': loggedin,
        'INSTANCE_NAME': INSTANCE_NAME,
        'INSTANCE_IMAGE': INSTANCE_IMAGE,
        'ADMIN_MODE': ADMIN_MODE,
        'INCIDENT_ACTIVE': INCIDENT_ACTIVE,
        'ROBOT_SHOP_OUTAGE_ACTIVE': ROBOT_SHOP_OUTAGE_ACTIVE,
        'SOCK_SHOP_OUTAGE_ACTIVE': SOCK_SHOP_OUTAGE_ACTIVE,
        'SIMULATION_MODE': SIMULATION_MODE,
        'INSTANCE_NAME': INSTANCE_NAME,
        'INSTANCE_IMAGE': INSTANCE_IMAGE,
        'PAGE_TITLE': 'About',
        'PAGE_NAME': 'about',
        'DEMO_IMAGE': demo_image,
        'ALL_LOGINS': ALL_LOGINS,
        'mod_time_readable': mod_time_readable
    }
    return HttpResponse(template.render(context, request))

def config(request):
    print('🌏 config')
    global loggedin
    global INCIDENT_ACTIVE
    global ROBOT_SHOP_OUTAGE_ACTIVE
    global SOCK_SHOP_OUTAGE_ACTIVE
    print('     🟠 OUTAGE - Incident:'+str(INCIDENT_ACTIVE)+' - RS-OUTAGE:'+str(ROBOT_SHOP_OUTAGE_ACTIVE)+' - SOCK-OUTAGE:'+str(SOCK_SHOP_OUTAGE_ACTIVE))

    verifyLogin(request)

    if loggedin=='true':
        template = loader.get_template('demouiapp/config.html')
    else:
        template = loader.get_template('demouiapp/loginui.html')
    context = {
        'loggedin': loggedin,
        'INSTANCE_NAME': INSTANCE_NAME,
        'INSTANCE_IMAGE': INSTANCE_IMAGE,
        'ADMIN_MODE': ADMIN_MODE,
        'INCIDENT_ACTIVE': INCIDENT_ACTIVE,
        'ROBOT_SHOP_OUTAGE_ACTIVE': ROBOT_SHOP_OUTAGE_ACTIVE,
        'SOCK_SHOP_OUTAGE_ACTIVE': SOCK_SHOP_OUTAGE_ACTIVE,
        'SIMULATION_MODE': SIMULATION_MODE,
        'INSTANCE_NAME': INSTANCE_NAME,
        'INSTANCE_IMAGE': INSTANCE_IMAGE,
        'PAGE_TITLE': 'Configuration for the IBM AIOps Training',
        'PAGE_NAME': 'config',
        'ALL_LOGINS': ALL_LOGINS

    }
    return HttpResponse(template.render(context, request))



def index1(request):
    template = loader.get_template('demouiapp/index.html')
    context = {
        'loggedin': loggedin,
        'INSTANCE_NAME': INSTANCE_NAME
    }
    return HttpResponse(template.render(context, request))


def health(request):
    return HttpResponse('healthy')
