from django.shortcuts import render
from django.http import HttpResponse
from django.template import loader
import os
import sys 
import time 
sys.path.append(os.path.abspath("demouiapp"))
from functions import *
SLACK_URL=str(os.environ.get('SLACK_URL'))
SLACK_USER=str(os.environ.get('SLACK_USER'))
SLACK_PWD=str(os.environ.get('SLACK_PWD'))

print ('*************************************************************************************************')
print ('*************************************************************************************************')
print ('         __________  __ ___       _____    ________            ')
print ('        / ____/ __ \\/ // / |     / /   |  /  _/ __ \\____  _____')
print ('       / /   / /_/ / // /| | /| / / /| |  / // / / / __ \\/ ___/')
print ('      / /___/ ____/__  __/ |/ |/ / ___ |_/ // /_/ / /_/ (__  ) ')
print ('      \\____/_/      /_/  |__/|__/_/  |_/___/\\____/ .___/____/  ')
print ('                                                /_/            ')
print ('*************************************************************************************************')
print ('*************************************************************************************************')
print ('')
print ('    🛰️  DemoUI for CP4WAIOPS AI Manager')
print ('')
print ('       Provided by:')
print ('        🇨🇭 Niklaus Hirt (nikh@ch.ibm.com)')
print ('')

print ('*************************************************************************************************')
print (' 🚀 Initializing')
print ('*************************************************************************************************')

#os.system('ls -l')
loggedin='false'
loginip='0.0.0.0'
# ----------------------------------------------------------------------------------------------------------------------------------------------------
# GET NAMESPACES
# ----------------------------------------------------------------------------------------------------------------------------------------------------
print('     ❓ Getting AIManager Namespace')
stream = os.popen("oc get po -A|grep aiops-orchestrator-controller |awk '{print$1}'")
aimanagerns = stream.read().strip()
print('        ✅ AIManager Namespace:       '+aimanagerns)

print('     ❓ Getting EventManager Namespace')
stream = os.popen("oc get po -A|grep noi-operator |awk '{print$1}'")
eventmanagerns = stream.read().strip()
print('        ✅ EventManager Namespace:    '+eventmanagerns)




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
stream = os.popen("oc get secret -n "+aimanagerns+" kafka-secrets  -o jsonpath='{.data.ca\.crt}'| base64 -d")
KAFKA_CERT = stream.read().strip()

print('     ❓ Getting Details Datalayer')
stream = os.popen("oc get route  -n "+aimanagerns+" datalayer-api  -o jsonpath='{.status.ingress[0].host}'")
DATALAYER_ROUTE = stream.read().strip()
stream = os.popen("oc get secret -n "+aimanagerns+" aiops-ir-core-ncodl-api-secret -o jsonpath='{.data.username}' | base64 --decode")
DATALAYER_USER = stream.read().strip()
stream = os.popen("oc get secret -n "+aimanagerns+" aiops-ir-core-ncodl-api-secret -o jsonpath='{.data.password}' | base64 --decode")
DATALAYER_PWD = stream.read().strip()

print('     ❓ Getting Details Metric Endpoint')
stream = os.popen("oc get route -n "+aimanagerns+"| grep ibm-nginx-svc | awk '{print $2}'")
METRIC_ROUTE = stream.read().strip()
stream = os.popen("oc get secret -n "+aimanagerns+" admin-user-details -o jsonpath='{.data.initial_admin_password}' | base64 -d")
tmppass = stream.read().strip()
stream = os.popen('curl -k -s -X POST https://'+METRIC_ROUTE+'/icp4d-api/v1/authorize -H "Content-Type: application/json" -d "{\\\"username\\\": \\\"admin\\\",\\\"password\\\": \\\"'+tmppass+'\\\"}" | jq .token | sed "s/\\\"//g"')
METRIC_TOKEN = stream.read().strip()










# ----------------------------------------------------------------------------------------------------------------------------------------------------
# GET CONNECTION DETAILS
# ----------------------------------------------------------------------------------------------------------------------------------------------------
print('     ❓ Getting Details AIManager')
stream = os.popen('oc get route -n '+aimanagerns+' cpd -o jsonpath={.spec.host}')
aimanager_url = stream.read().strip()
stream = os.popen('oc -n ibm-common-services get secret platform-auth-idp-credentials -o jsonpath={.data.admin_username} | base64 --decode && echo')
aimanager_user = stream.read().strip()
stream = os.popen('oc -n ibm-common-services get secret platform-auth-idp-credentials -o jsonpath={.data.admin_password} | base64 --decode')
aimanager_pwd = stream.read().strip()

print('     ❓ Getting Details EventManager')
stream = os.popen('oc get route -n '+eventmanagerns+'  evtmanager-ibm-hdm-common-ui -o jsonpath={.spec.host}')
eventmanager_url = stream.read().strip()
stream = os.popen('oc -n ibm-common-services get secret platform-auth-idp-credentials -o jsonpath={.data.admin_username} | base64 --decode && echo')
eventmanager_user = 'smadmin'
stream = os.popen('oc get secret -n '+eventmanagerns+'  evtmanager-was-secret -o jsonpath={.data.WAS_PASSWORD}| base64 --decode ')
eventmanager_pwd = stream.read().strip()



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
stream = os.popen('oc get route -n turbonomic api -o jsonpath={.spec.host}')
turonomic_url = stream.read().strip()

print('     ❓ Getting Details Openshift Console')
stream = os.popen('oc get route -n openshift-console console -o jsonpath={.spec.host}')
openshift_url = stream.read().strip()
stream = os.popen("oc -n default get secret $(oc get secret -n default |grep -m1 demo-admin-token|awk '{print$1}') -o jsonpath='{.data.token}'|base64 --decode")
openshift_token = stream.read().strip()
stream = os.popen("oc status|head -1|awk '{print$6}'")
openshift_server = stream.read().strip()


print('     ❓ Getting Details Vault')
stream = os.popen('oc get route -n '+aimanagerns+' ibm-vault-deploy-vault-route -o jsonpath={.spec.host}')
vault_url = stream.read().strip()
stream = os.popen('oc get secret -n '+aimanagerns+' ibm-vault-deploy-vault-credential -o jsonpath={.data.token} | base64 --decode')
vault_token = stream.read().strip()

print('     ❓ Getting Details LDAP ')
stream = os.popen('oc get route -n openldap openldap-admin -o jsonpath={.spec.host}')
ladp_url = stream.read().strip()
ladp_user = 'cn=admin,dc=ibm,dc=com'
ladp_pwd = 'P4ssw0rd!'

print('     ❓ Getting Details Flink Task Manager')
stream = os.popen('oc get routes -n '+aimanagerns+' job-manager  -o jsonpath={.spec.host}')
flink_url = stream.read().strip()
stream = os.popen('oc get routes -n '+aimanagerns+' job-manager-policy  -o jsonpath={.spec.host}')
flink_url_policy = stream.read().strip()

print('     ❓ Getting Details Spark Master')
stream = os.popen('oc get routes -n '+aimanagerns+' spark  -o jsonpath={.spec.host}')
spark_url = stream.read().strip()

print('     ❓ Getting Details RobotShop')
stream = os.popen('oc get routes -n robot-shop web  -o jsonpath={.spec.host}')
robotshop_url = stream.read().strip()



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
def injectAllREST(request):
    print('🌏 injectAllREST')
    global loggedin
    verifyLogin(request)

    if loggedin=='true':
        template = loader.get_template('demouiapp/home.html')
        
        print('🌏 Create RobotShop MySQL outage')
        os.system('oc patch service mysql -n robot-shop --patch "{\\"spec\\": {\\"selector\\": {\\"service\\": \\"mysql-outage\\"}}}"')
        
        injectEventsMem(DATALAYER_ROUTE,DATALAYER_USER,DATALAYER_PWD)
        injectMetricsMem(METRIC_ROUTE,METRIC_TOKEN)
        injectLogs(KAFKA_BROKER,KAFKA_USER,KAFKA_PWD,KAFKA_TOPIC_LOGS,KAFKA_CERT,LOG_TIME_FORMAT,DEMO_LOGS)
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
        'turonomic_url': turonomic_url,
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
        'spark_url': spark_url,
        'eventmanager_url': eventmanager_url,
        'eventmanager_user': eventmanager_user,
        'eventmanager_pwd': eventmanager_pwd,
        'INSTANCE_NAME': INSTANCE_NAME,
        'ADMIN_MODE': ADMIN_MODE,
        'SIMULATION_MODE': SIMULATION_MODE,
        'PAGE_TITLE': '🚀 Demo UI for ' + INSTANCE_NAME + ' Environment',
        'PAGE_NAME': 'index'
    }
    return HttpResponse(template.render(context, request))


def injectAllFanREST(request):
    print('🌏 injectAllFanREST')
    global loggedin
    verifyLogin(request)
    if loggedin=='true':
        template = loader.get_template('demouiapp/home.html')

        print('🌏 Create RobotShop MySQL outage')
        os.system('oc patch service mysql -n robot-shop --patch "{\\"spec\\": {\\"selector\\": {\\"service\\": \\"mysql-outage\\"}}}"')

        injectMetricsFanTemp(METRIC_ROUTE,METRIC_TOKEN)
        time.sleep(3)
        injectEventsFan(DATALAYER_ROUTE,DATALAYER_USER,DATALAYER_PWD)
        injectMetricsFan(METRIC_ROUTE,METRIC_TOKEN)
        injectLogs(KAFKA_BROKER,KAFKA_USER,KAFKA_PWD,KAFKA_TOPIC_LOGS,KAFKA_CERT,LOG_TIME_FORMAT,DEMO_LOGS)
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
        'turonomic_url': turonomic_url,
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
        'spark_url': spark_url,
        'eventmanager_url': eventmanager_url,
        'eventmanager_user': eventmanager_user,
        'eventmanager_pwd': eventmanager_pwd,
        'INSTANCE_NAME': INSTANCE_NAME,
        'ADMIN_MODE': ADMIN_MODE,
        'SIMULATION_MODE': SIMULATION_MODE,
        'PAGE_TITLE': '🚀 Demo UI for ' + INSTANCE_NAME + ' Environment',
        'PAGE_NAME': 'index'
    }
    return HttpResponse(template.render(context, request))





def injectLogsREST(request):
    print('🌏 injectLogsREST')
    global loggedin
    verifyLogin(request)
    if loggedin=='true':
        template = loader.get_template('demouiapp/home.html')
        injectLogs(KAFKA_BROKER,KAFKA_USER,KAFKA_PWD,KAFKA_TOPIC_LOGS,KAFKA_CERT,LOG_TIME_FORMAT,DEMO_LOGS)
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
        'turonomic_url': turonomic_url,
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
        'spark_url': spark_url,
        'eventmanager_url': eventmanager_url,
        'eventmanager_user': eventmanager_user,
        'eventmanager_pwd': eventmanager_pwd,
        'INSTANCE_NAME': INSTANCE_NAME,
        'ADMIN_MODE': ADMIN_MODE,
        'SIMULATION_MODE': SIMULATION_MODE,
        'PAGE_TITLE': '🚀 Demo UI for ' + INSTANCE_NAME + ' Environment',
        'PAGE_NAME': 'index'
    }
    return HttpResponse(template.render(context, request))


def injectEventsREST(request):
    print('🌏 injectEventsREST')
    global loggedin
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
        'turonomic_url': turonomic_url,
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
        'spark_url': spark_url,
        'eventmanager_url': eventmanager_url,
        'eventmanager_user': eventmanager_user,
        'eventmanager_pwd': eventmanager_pwd,
        'INSTANCE_NAME': INSTANCE_NAME,
        'ADMIN_MODE': ADMIN_MODE,
        'SIMULATION_MODE': SIMULATION_MODE,
        'PAGE_TITLE': '🚀 Demo UI for ' + INSTANCE_NAME + ' Environment',
        'PAGE_NAME': 'index'
    }
    return HttpResponse(template.render(context, request))

def injectMetricsREST(request):
    print('🌏 injectMetricsREST')
    global loggedin
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
        'turonomic_url': turonomic_url,
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
        'spark_url': spark_url,
        'eventmanager_url': eventmanager_url,
        'eventmanager_user': eventmanager_user,
        'eventmanager_pwd': eventmanager_pwd,
        'INSTANCE_NAME': INSTANCE_NAME,
        'ADMIN_MODE': ADMIN_MODE,
        'SIMULATION_MODE': SIMULATION_MODE,
        'PAGE_TITLE': '🚀 Demo UI for ' + INSTANCE_NAME + ' Environment',
        'PAGE_NAME': 'index'
    }
    return HttpResponse(template.render(context, request))



def clearAllREST(request):
    print('🌏 clearAllREST')
    global loggedin
    verifyLogin(request)
    if loggedin=='true':
        template = loader.get_template('demouiapp/home.html')

        print('🌏 Reset RobotShop MySQL outage')
        os.system('oc patch service mysql -n robot-shop --patch "{\\"spec\\": {\\"selector\\": {\\"service\\": \\"mysql\\"}}}"')
        

        closeAlerts(DATALAYER_ROUTE,DATALAYER_USER,DATALAYER_PWD)
        closeStories(DATALAYER_ROUTE,DATALAYER_USER,DATALAYER_PWD)
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
        'turonomic_url': turonomic_url,
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
        'spark_url': spark_url,
        'eventmanager_url': eventmanager_url,
        'eventmanager_user': eventmanager_user,
        'eventmanager_pwd': eventmanager_pwd,
        'INSTANCE_NAME': INSTANCE_NAME,
        'ADMIN_MODE': ADMIN_MODE,
        'SIMULATION_MODE': SIMULATION_MODE,
        'PAGE_TITLE': '🚀 Demo UI for ' + INSTANCE_NAME + ' Environment',
        'PAGE_NAME': 'index'


        



    }
    return HttpResponse(template.render(context, request))

def clearEventsREST(request):
    print('🌏 clearEventsREST')
    global loggedin
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
        'turonomic_url': turonomic_url,
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
        'spark_url': spark_url,
        'eventmanager_url': eventmanager_url,
        'eventmanager_user': eventmanager_user,
        'eventmanager_pwd': eventmanager_pwd,
        'INSTANCE_NAME': INSTANCE_NAME,
        'ADMIN_MODE': ADMIN_MODE,
        'SIMULATION_MODE': SIMULATION_MODE,
        'PAGE_TITLE': '🚀 Demo UI for ' + INSTANCE_NAME + ' Environment',
        'PAGE_NAME': 'index'
    }
    return HttpResponse(template.render(context, request))

def clearStoriesREST(request):
    print('🌏 injectLogsREST')
    global loggedin
    verifyLogin(request)
    if loggedin=='true':
        template = loader.get_template('demouiapp/home.html')
        closeStories(DATALAYER_ROUTE,DATALAYER_USER,DATALAYER_PWD)
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
        'turonomic_url': turonomic_url,
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
        'spark_url': spark_url,
        'eventmanager_url': eventmanager_url,
        'eventmanager_user': eventmanager_user,
        'eventmanager_pwd': eventmanager_pwd,
        'INSTANCE_NAME': INSTANCE_NAME,
        'ADMIN_MODE': ADMIN_MODE,
        'SIMULATION_MODE': SIMULATION_MODE,
        'PAGE_TITLE': '🚀 Demo UI for ' + INSTANCE_NAME + ' Environment',
        'PAGE_NAME': 'index'
    }
    return HttpResponse(template.render(context, request))

def login(request):
    print('🌏 login')

    global loggedin
    global loginip

    verifyLogin(request)

    currenttoken=request.GET.get("token", "0")
    token=os.environ.get('TOKEN')
    print ('  🔐 Login attempt with Token: '+currenttoken)
    if token==currenttoken:
        loggedin='true'
        template = loader.get_template('demouiapp/home.html')
        print ('  ✅ Login SUCCESSFUL')
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
            'SIMULATION_MODE': SIMULATION_MODE,  
            'INSTANCE_NAME': INSTANCE_NAME,
            'ADMIN_MODE': ADMIN_MODE,
            'SIMULATION_MODE': SIMULATION_MODE,
            'PAGE_TITLE': '🚀 Demo UI for ' + INSTANCE_NAME + ' Environment',
            'PAGE_NAME': 'index'
        }
    else:
        loggedin='false'
        template = loader.get_template('demouiapp/loginui.html')
        print ('  ❗ Login NOT SUCCESSFUL')
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
            'SIMULATION_MODE': SIMULATION_MODE,  
            'INSTANCE_NAME': INSTANCE_NAME,
            'ADMIN_MODE': ADMIN_MODE,
            'SIMULATION_MODE': SIMULATION_MODE,
            'PAGE_TITLE': '🚀 Demo UI for ' + INSTANCE_NAME + ' Environment',
            'PAGE_NAME': 'login'
        }

    return HttpResponse(template.render(context, request))
    #return HttpResponse("Hello, world. You're at the polls index.")


def verifyLogin(request):
    actloginip=request.META.get('REMOTE_ADDR')

    global loggedin
    global loginip


    if str(loginip)!=str(actloginip):
        loggedin='false'
        loginip=request.META.get('REMOTE_ADDR')

        #print('        ❌ LOGIN NOK: NEW IP')
        print('   🔎 Check IP : ❌ LOGIN NOK: ACT IP:'+str(actloginip)+'  - SAVED IP:'+str(loginip))
    else:
        print('   🔎 Check IP : ✅ LOGIN OK: '+str(loggedin))
        #print('        ✅ LOGIN OK')
        #loggedin='true'
        loginip=request.META.get('REMOTE_ADDR')






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

    verifyLogin(request)

    if loggedin=='true':
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
        'ADMIN_MODE': ADMIN_MODE,
        'SIMULATION_MODE': SIMULATION_MODE,  
        'DEMO_USER': DEMO_USER,
        'DEMO_PWD': DEMO_PWD,
        'INSTANCE_NAME': INSTANCE_NAME,
        'ADMIN_MODE': ADMIN_MODE,
        'SIMULATION_MODE': SIMULATION_MODE,
        'PAGE_TITLE': '🚀 Demo UI for ' + INSTANCE_NAME + ' Environment',
        'PAGE_NAME': 'index'
        
    }
    return HttpResponse(template.render(context, request))

def doc(request):
    print('🌏 doc')
    global loggedin

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
        'turonomic_url': turonomic_url,
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
        'spark_url': spark_url,
        'eventmanager_url': eventmanager_url,
        'eventmanager_user': eventmanager_user,
        'eventmanager_pwd': eventmanager_pwd,
        'INSTANCE_NAME': INSTANCE_NAME,
        'ADMIN_MODE': ADMIN_MODE,
        'SIMULATION_MODE': SIMULATION_MODE,
        'PAGE_TITLE': 'CloudPak for Watson AIOps Demo UI',
        'PAGE_NAME': 'doc'
    }
    return HttpResponse(template.render(context, request))

def apps(request):
    print('🌏 apps')
    global loggedin

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
        'turonomic_url': turonomic_url,
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
        'spark_url': spark_url,
        'eventmanager_url': eventmanager_url,
        'eventmanager_user': eventmanager_user,
        'eventmanager_pwd': eventmanager_pwd,
        'SLACK_URL': SLACK_URL,
        'SLACK_USER': SLACK_USER,
        'SLACK_PWD': SLACK_PWD,
        'ADMIN_MODE': ADMIN_MODE,
        'SIMULATION_MODE': SIMULATION_MODE,  
        'DEMO_USER': DEMO_USER,
        'DEMO_PWD': DEMO_PWD,
        'INSTANCE_NAME': INSTANCE_NAME,
        'PAGE_TITLE': '🚀 CP4WAIOPS Applications',
        'PAGE_NAME': 'apps'
        
    }
    return HttpResponse(template.render(context, request))

def apps_system(request):
    print('🌏 apps_system')
    global loggedin

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
        'turonomic_url': turonomic_url,
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
        'spark_url': spark_url,
        'eventmanager_url': eventmanager_url,
        'eventmanager_user': eventmanager_user,
        'eventmanager_pwd': eventmanager_pwd,
        'SLACK_URL': SLACK_URL,
        'SLACK_USER': SLACK_USER,
        'SLACK_PWD': SLACK_PWD,
        'ADMIN_MODE': ADMIN_MODE,
        'SIMULATION_MODE': SIMULATION_MODE,  
        'DEMO_USER': DEMO_USER,
        'DEMO_PWD': DEMO_PWD,
        'INSTANCE_NAME': INSTANCE_NAME,
        'PAGE_TITLE': '🛠️ System Links',
        'PAGE_NAME': 'system'
        
    }
    return HttpResponse(template.render(context, request))


def apps_demo(request):
    print('🌏 apps_demo')
    global loggedin

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
        'turonomic_url': turonomic_url,
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
        'spark_url': spark_url,
        'eventmanager_url': eventmanager_url,
        'eventmanager_user': eventmanager_user,
        'eventmanager_pwd': eventmanager_pwd,
        'SLACK_URL': SLACK_URL,
        'SLACK_USER': SLACK_USER,
        'SLACK_PWD': SLACK_PWD,
        'ADMIN_MODE': ADMIN_MODE,
        'SIMULATION_MODE': SIMULATION_MODE,  
        'DEMO_USER': DEMO_USER,
        'DEMO_PWD': DEMO_PWD,
        'INSTANCE_NAME': INSTANCE_NAME,
        'PAGE_TITLE': '🌏 Demo Content',
        'PAGE_NAME': 'demo'
        
    }
    return HttpResponse(template.render(context, request))



def apps_additional(request):
    print('🌏 apps_additional')
    global loggedin

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
        'turonomic_url': turonomic_url,
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
        'spark_url': spark_url,
        'eventmanager_url': eventmanager_url,
        'eventmanager_user': eventmanager_user,
        'eventmanager_pwd': eventmanager_pwd,
        'SLACK_URL': SLACK_URL,
        'SLACK_USER': SLACK_USER,
        'SLACK_PWD': SLACK_PWD,
        'ADMIN_MODE': ADMIN_MODE,
        'SIMULATION_MODE': SIMULATION_MODE,  
        'DEMO_USER': DEMO_USER,
        'DEMO_PWD': DEMO_PWD,
        'INSTANCE_NAME': INSTANCE_NAME,
        'PAGE_TITLE': '📥 Third-party Applications',
        'PAGE_NAME': 'TEST'
        
    }
    return HttpResponse(template.render(context, request))



def about(request):
    print('🌏 about')

    global loggedin

    verifyLogin(request)

    if loggedin=='true':
        template = loader.get_template('demouiapp/about.html')
    else:
        template = loader.get_template('demouiapp/loginui.html')
    context = {
        'loggedin': loggedin,
        'INSTANCE_NAME': INSTANCE_NAME,
        'ADMIN_MODE': ADMIN_MODE,
        'SIMULATION_MODE': SIMULATION_MODE,
        'INSTANCE_NAME': INSTANCE_NAME,
        'PAGE_TITLE': '👽 About',
        'PAGE_NAME': 'about'

    }
    return HttpResponse(template.render(context, request))

def config(request):
    print('🌏 config')
    global loggedin

    verifyLogin(request)

    if loggedin=='true':
        template = loader.get_template('demouiapp/config.html')
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
        'turonomic_url': turonomic_url,
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
        'spark_url': spark_url,
        'eventmanager_url': eventmanager_url,
        'eventmanager_user': eventmanager_user,
        'eventmanager_pwd': eventmanager_pwd,
        'INSTANCE_NAME': INSTANCE_NAME,
        'ADMIN_MODE': ADMIN_MODE,
        'SIMULATION_MODE': SIMULATION_MODE,
        'PAGE_TITLE': 'Third-party Applications',
        'PAGE_NAME': 'TEST'

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
