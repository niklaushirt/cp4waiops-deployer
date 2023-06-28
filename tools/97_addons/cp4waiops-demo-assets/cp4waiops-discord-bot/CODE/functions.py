import requests
from requests.auth import HTTPBasicAuth
import json
import datetime
import random
import os

DEMO_EVENTS_MEM=os.environ.get('DEMO_EVENTS_MEM')
DEMO_EVENTS_FAN=os.environ.get('DEMO_EVENTS_FAN')
DEMO_EVENTS_NET=os.environ.get('DEMO_EVENTS_NET')

DEMO_LOGS=os.environ.get('DEMO_LOGS')
LOG_ITERATIONS=int(os.environ.get('LOG_ITERATIONS'))
LOG_TIME_FORMAT=os.environ.get('LOG_TIME_FORMAT')
LOG_TIME_STEPS=int(os.environ.get('LOG_TIME_STEPS'))
LOG_TIME_SKEW=int(os.environ.get('LOG_TIME_SKEW'))
LOG_TIME_ZONE=int(os.environ.get('LOG_TIME_ZONE'))

EVENTS_TIME_SKEW=int(os.environ.get('EVENTS_TIME_SKEW'))

INSTANCE_NAME=os.environ.get('INSTANCE_NAME')
if INSTANCE_NAME == None:
    INSTANCE_NAME="CP4WAIOPS"


METRIC_TIME_SKEW=int(os.environ.get('METRIC_TIME_SKEW'))
METRIC_TIME_STEP=int(os.environ.get('METRIC_TIME_STEP'))
METRICS_TO_SIMULATE_MEM=str(os.environ.get('METRICS_TO_SIMULATE_MEM')).split(';')
METRICS_TO_SIMULATE_FAN_TEMP=str(os.environ.get('METRICS_TO_SIMULATE_FAN_TEMP')).split(';')
METRICS_TO_SIMULATE_FAN=str(os.environ.get('METRICS_TO_SIMULATE_FAN')).split(';')
METRICS_TO_SIMULATE_NET=str(os.environ.get('METRICS_TO_SIMULATE_NET')).split(';')



# ----------------------------------------------------------------------------------------------------------------------------------------------------
# GET Incidents
# ----------------------------------------------------------------------------------------------------------------------------------------------------
 
def getIncidents(DATALAYER_ROUTE,DATALAYER_USER,DATALAYER_PWD, CPD_ROUTE):


    url = 'https://'+DATALAYER_ROUTE+'/irdatalayer.aiops.io/active/v1/stories'
    auth=HTTPBasicAuth(DATALAYER_USER, DATALAYER_PWD)
    headers = {'Content-Type': 'application/json', 'Accept-Charset': 'UTF-8', 'x-username' : 'admin', 'x-subscription-id' : 'cfd95b7e-3bc7-4006-a4a8-a73a79c71255'}
    response = requests.get(url, headers=headers, auth=auth)#, verify=False)
    actIncidents=response.json()

    return actIncidents





# ----------------------------------------------------------------------------------------------------------------------------------------------------
# CLOSE ALERTS AND Incidents
# ----------------------------------------------------------------------------------------------------------------------------------------------------
#open
#clear
#closed
def updateAlerts(DATALAYER_ROUTE,DATALAYER_USER,DATALAYER_PWD, STATE):
    #print('              ')
    #print('               ------------------------------------------------------------------------------------------------')
    #print('               📛 Close Alerts')
    data = '{"state": "'+STATE+'"}'
    # print(data)
    # print(type(data))
    url = 'https://'+DATALAYER_ROUTE+'/irdatalayer.aiops.io/active/v1/alerts'
    auth=HTTPBasicAuth(DATALAYER_USER, DATALAYER_PWD)
    headers = {'Content-Type': 'application/json', 'Accept-Charset': 'UTF-8', 'x-username' : 'admin', 'x-subscription-id' : 'cfd95b7e-3bc7-4006-a4a8-a73a79c71255'}
    response = requests.patch(url, data=data, headers=headers, auth=auth)#, verify=False)
    #print('                   RESULT:'+str(response.content))
    #print('               ✅ Close Alerts')
    #print('               ------------------------------------------------------------------------------------------------')

    return 'OK'

#resolved
#assignedToIndividual
#inProgress
#resolved
#closed
def updateIncidentsID(DATALAYER_ROUTE,DATALAYER_USER,DATALAYER_PWD, STATE, incident_id):
    #print('              ')
    #print('               ------------------------------------------------------------------------------------------------')
    #print('               📛 Close Incidents')
    data = '{"state": "'+STATE+'"}'
    # print(data)
    # print(type(data))

    url = 'https://'+DATALAYER_ROUTE+'/irdatalayer.aiops.io/active/v1/stories/'+incident_id
    auth=HTTPBasicAuth(DATALAYER_USER, DATALAYER_PWD)
    headers = {'Content-Type': 'application/json', 'Accept-Charset': 'UTF-8', 'x-username' : 'admin', 'x-subscription-id' : 'cfd95b7e-3bc7-4006-a4a8-a73a79c71255'}
    response = requests.patch(url, data=data, headers=headers, auth=auth)#, verify=False)
    #print('                   RESULT:'+str(response.content))
    #print('               ✅ Close Incidents')
    #print('               ------------------------------------------------------------------------------------------------')

    return 'OK'


#resolved
#assignedToIndividual
#inProgress
#resolved
#closed
def updateIncidents(DATALAYER_ROUTE,DATALAYER_USER,DATALAYER_PWD, STATE):
    #print('              ')
    #print('               ------------------------------------------------------------------------------------------------')
    #print('               📛 Close Incidents')
    data = '{"state": "'+STATE+'"}'
    # print(data)
    # print(type(data))

    url = 'https://'+DATALAYER_ROUTE+'/irdatalayer.aiops.io/active/v1/stories'
    auth=HTTPBasicAuth(DATALAYER_USER, DATALAYER_PWD)
    headers = {'Content-Type': 'application/json', 'Accept-Charset': 'UTF-8', 'x-username' : 'admin', 'x-subscription-id' : 'cfd95b7e-3bc7-4006-a4a8-a73a79c71255'}
    response = requests.patch(url, data=data, headers=headers, auth=auth)#, verify=False)
    #print('                   RESULT:'+str(response.content))
    #print('               ✅ Close Incidents')
    #print('               ------------------------------------------------------------------------------------------------')

    return 'OK'

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# INSTANA INCIDENT
# ----------------------------------------------------------------------------------------------------------------------------------------------------
def instanaCreateIncident():
    stream = os.popen('oc set env deployment ratings -n robot-shop PDO_URL="mysql:host=mysql;dbname=ratings-dev;charset=utf8mb4"')
    RESULT = stream.read().strip()
    print(str(RESULT))
    stream = os.popen('oc set env deployment load -n robot-shop ERROR=1')
    RESULT = stream.read().strip()
    print(str(RESULT))


def instanaMitigateIncident():
    stream = os.popen('oc set env deployment ratings -n robot-shop PDO_URL-')
    RESULT = stream.read().strip()
    print(str(RESULT))
    stream = os.popen('oc set env deployment load -n robot-shop ERROR=0')
    RESULT = stream.read().strip()
    print(str(RESULT))







# ----------------------------------------------------------------------------------------------------------------------------------------------------
# INJECT LOGS
# ----------------------------------------------------------------------------------------------------------------------------------------------------
from confluent_kafka import Producer
import socket

def injectLogs(KAFKA_BROKER,KAFKA_USER,KAFKA_PWD,KAFKA_TOPIC_LOGS,KAFKA_CERT,LOG_TIME_FORMAT,DEMO_LOGS):
    #print('              ')
    #print('               ------------------------------------------------------------------------------------------------')
    #print('               📛 Inject Logs')

    stream = os.popen('echo "'+KAFKA_CERT+'" > ./ca.crt')
    stream.read().strip()


    conf = {'bootstrap.servers': KAFKA_BROKER+':443',
            'security.protocol': "SASL_SSL",
            'sasl.mechanisms': 'SCRAM-SHA-512',
            'sasl.username': KAFKA_USER,
            'sasl.password': KAFKA_PWD,
            'client.id': socket.gethostname(),
            #'ssl.rejectUnauthorized': 'false',
            'ssl.ca.location': './ca.crt'
            }

#ssl.ca.location

    producer = Producer(conf)
    timestamp = datetime.datetime.now()
    #print('              Base timestamp:'+str(timestamp))

    timestamp = timestamp + datetime.timedelta(minutes=LOG_TIME_SKEW)

    for i in range (1,LOG_ITERATIONS):
        for line in DEMO_LOGS.split('\n'):
            timestamp = timestamp + datetime.timedelta(milliseconds=LOG_TIME_STEPS)            
            timestampstr = timestamp.strftime(LOG_TIME_FORMAT)+'+00:00'
            line = line.replace("MY_TIMESTAMP", timestampstr).strip()
            ##print('                   XX:'+line)

            producer.produce(KAFKA_TOPIC_LOGS, value=line)
        producer.flush()
        print('             ✅ Iteration: '+str(i)+'  :  '+str(timestamp))




    #print('               ✅ Inject Logs')
    #print('               ------------------------------------------------------------------------------------------------')

    return 'OK'




# ----------------------------------------------------------------------------------------------------------------------------------------------------
# INJECT EVENTS
# ----------------------------------------------------------------------------------------------------------------------------------------------------

def injectEventsMem(DATALAYER_ROUTE,DATALAYER_USER,DATALAYER_PWD): 
    injectEventsGeneric(DATALAYER_ROUTE,DATALAYER_USER,DATALAYER_PWD,DEMO_EVENTS_MEM)
    return 'OK'


def injectEventsFan(DATALAYER_ROUTE,DATALAYER_USER,DATALAYER_PWD):  
    injectEventsGeneric(DATALAYER_ROUTE,DATALAYER_USER,DATALAYER_PWD,DEMO_EVENTS_FAN)
    return 'OK'

def injectEventsNet(DATALAYER_ROUTE,DATALAYER_USER,DATALAYER_PWD):  
    injectEventsGeneric(DATALAYER_ROUTE,DATALAYER_USER,DATALAYER_PWD,DEMO_EVENTS_NET)
    return 'OK'


def injectEventsGeneric(DATALAYER_ROUTE,DATALAYER_USER,DATALAYER_PWD,DEMO_EVENTS):
    #print('              ')
    #print('               ------------------------------------------------------------------------------------------------')
    #print('               📛 Inject Events')
    
    timestamp = datetime.datetime.now()
    #timestamp = str(datetime.datetime.now())
    #+%Y-%m-%dT%H:%M:%S

    url = 'https://'+DATALAYER_ROUTE+'/irdatalayer.aiops.io/active/v1/events'
    auth=HTTPBasicAuth(DATALAYER_USER, DATALAYER_PWD)
    headers = {'Content-Type': 'application/json', 'Accept-Charset': 'UTF-8', 'x-username' : 'admin', 'x-subscription-id' : 'cfd95b7e-3bc7-4006-a4a8-a73a79c71255'}


    for line in DEMO_EVENTS.split('\n'):
        timestamp = timestamp + datetime.timedelta(seconds=EVENTS_TIME_SKEW)
        timestampstr = timestamp.strftime("%Y-%m-%dT%H:%M:%S.000Z")

        line = line.replace("MY_TIMESTAMP", timestampstr)
        response = requests.post(url, data=line, headers=headers, auth=auth)#, verify=False)
    print('              ✅ LAST RESULT:'+str(response.content))


    #print('               ✅ Inject Events')
    #print('               ------------------------------------------------------------------------------------------------')

    return 'OK'





# ----------------------------------------------------------------------------------------------------------------------------------------------------
# INJECT METRICS
# ----------------------------------------------------------------------------------------------------------------------------------------------------
# METRICS_TO_SIMULATE=[
# "mysql-predictive,MemoryUsagePercent,MemoryUsage,97,3",
# "mysql-predictive,MemoryUsageMean,MemoryUsage,50000,1000",
# "mysql-predictive,MemoryUsageMax,MemoryUsage,50000,10000",
# "mysql-predictive,PodRestarts,PodRestarts,ITERATIONS,1",
# "mysql-predictive,TransactionsPerSecond,TransactionsPerSecond,0,1",
# "mysql-predictive,Latency,Latency,1000,100",
# "ratings-predictive,MemoryUsagePercent,MemoryUsage,45,10",
# "ratings-predictive,MemoryUsageMean,MemoryUsage,50000,1000",
# "ratings-predictive,MemoryUsageMax,MemoryUsage,50000,10000",
# "ratings-predictive,PodRestarts,PodRestarts,0,1",
# "ratings-predictive,TransactionsPerSecond,TransactionsPerSecond,160,40",
# "ratings-predictive,Latency,Latency,2,1"
# ]

def injectMetricsMem(METRIC_ROUTE,METRIC_TOKEN): 
    METRIC_TIME_SKEW=int(os.environ.get('METRIC_TIME_SKEW'))
    METRIC_TIME_STEP=int(os.environ.get('METRIC_TIME_STEP'))
    injectMetrics(METRIC_ROUTE,METRIC_TOKEN,METRICS_TO_SIMULATE_MEM,METRIC_TIME_SKEW,METRIC_TIME_STEP)
    return 'OK'

def injectMetricsFanTemp(METRIC_ROUTE,METRIC_TOKEN):  
    METRIC_TIME_SKEW=0
    METRIC_TIME_STEP=120

    injectMetrics(METRIC_ROUTE,METRIC_TOKEN,METRICS_TO_SIMULATE_FAN_TEMP,METRIC_TIME_SKEW,METRIC_TIME_STEP)
    return 'OK'

def injectMetricsFan(METRIC_ROUTE,METRIC_TOKEN):  
    METRIC_TIME_SKEW=int(os.environ.get('METRIC_TIME_SKEW'))
    METRIC_TIME_STEP=int(os.environ.get('METRIC_TIME_STEP'))
    injectMetrics(METRIC_ROUTE,METRIC_TOKEN,METRICS_TO_SIMULATE_FAN,METRIC_TIME_SKEW,METRIC_TIME_STEP)
    return 'OK'

def injectMetricsNet(METRIC_ROUTE,METRIC_TOKEN): 
    METRIC_TIME_SKEW=int(os.environ.get('METRIC_TIME_SKEW'))
    METRIC_TIME_STEP=int(os.environ.get('METRIC_TIME_STEP'))
    injectMetrics(METRIC_ROUTE,METRIC_TOKEN,METRICS_TO_SIMULATE_NET,METRIC_TIME_SKEW,METRIC_TIME_STEP)
    return 'OK'


def injectMetrics(METRIC_ROUTE,METRIC_TOKEN,METRICS_TO_SIMULATE,METRIC_TIME_SKEW,METRIC_TIME_STEP):
    #print('              ')
    #print('               ------------------------------------------------------------------------------------------------')
    #print('               📛 Inject Metrics')
    
    #print('                          METRIC_TIME_SKEW:               '+str(METRIC_TIME_SKEW))
    #print('                          METRIC_TIME_STEP:               '+str(METRIC_TIME_STEP))
    #print('                   ❓ Getting CP4WAIOps Namespace')
    stream = os.popen("oc get po -A|grep aiops-orchestrator-controller |awk '{print$1}'")
    aimanagerns = stream.read().strip()
    #print('                      ✅ CP4WAIOps Namespace:       '+aimanagerns)

    #print('                   ❓ Getting Details Metric Endpoint')
    stream = os.popen("oc get route -n "+aimanagerns+" | grep ibm-nginx-svc | awk '{print $2}'")
    METRIC_ROUTE = stream.read().strip()
    stream = os.popen("oc get secret  -n "+aimanagerns+" admin-user-details -o jsonpath='{.data.initial_admin_password}' | base64 --decode")
    tmppass = stream.read().strip()
    stream = os.popen('curl -k -s -X POST https://'+METRIC_ROUTE+'/icp4d-api/v1/authorize -H "Content-Type: application/json" -d "{\\\"username\\\": \\\"admin\\\",\\\"password\\\": \\\"'+tmppass+'\\\"}" | jq .token | sed "s/\\\"//g"')
    METRIC_TOKEN = stream.read().strip()

    requests.packages.urllib3.disable_warnings()

    timestamp = datetime.datetime.now()
    timestamp = timestamp + datetime.timedelta(seconds=METRIC_TIME_SKEW)

    CURR_ITERATIONS=0
    url = 'https://'+METRIC_ROUTE+'/aiops/api/app/metric-api/v1/metrics'

    #print('url:'+url)
    #print('METRIC_TOKEN:'+METRIC_TOKEN)
    headers = {'Content-Type': 'application/json', 'Accept-Charset': 'UTF-8', 'Authorization': 'Bearer '+METRIC_TOKEN, 'X-TenantID' : 'cfd95b7e-3bc7-4006-a4a8-a73a79c71255'}

    for i in range (1,80):
        output_json='{"groups":['
        CURR_ITERATIONS=CURR_ITERATIONS+1

        for i in range (1,40):
            for line in METRICS_TO_SIMULATE:

                line=line.strip()
                timestamp = timestamp + datetime.timedelta(milliseconds=METRIC_TIME_STEP)
                MY_TIMESTAMP = timestamp.strftime("%s")
                MY_TIMESTAMP=MY_TIMESTAMP+"000"
                MY_TIMESTAMP_READABLE = timestamp.strftime("%Y-%m-%dT%H:%M:%S.000Z")
                #print (MY_TIMESTAMP)
                #print (MY_TIMESTAMP_READABLE)

                elements=line.split(',')
                MY_RESOURCE_ID=elements[0]
                #print (MY_RESOURCE_ID)
                MY_METRIC_NAME=elements[1]
                MY_GROUP_ID=elements[2]
                MY_FIX_VALUE=elements[3]
                MY_VARIATION=elements[4]

                if MY_FIX_VALUE == 'ITERATIONS':
                    CURRENT_VALUE=str(int(MY_VARIATION)+2*int(CURR_ITERATIONS))
                    ##print('               ITER:'+str(CURRENT_VALUE))
                else:
                    CURRENT_VALUE = str(random.randint(int(MY_FIX_VALUE), int(MY_FIX_VALUE)+int(MY_VARIATION)))



                CURRENT_LINE='{"timestamp":"'+MY_TIMESTAMP+'","resourceID":"'+MY_RESOURCE_ID+'","metrics":{"'+MY_METRIC_NAME+'":'+CURRENT_VALUE+'},"attributes":{"group":"'+MY_GROUP_ID+'","node":"'+MY_RESOURCE_ID+'"} },'

                output_json=output_json+CURRENT_LINE


        LAST_LINE='{"timestamp":"'+MY_TIMESTAMP+'","resourceID":"'+MY_RESOURCE_ID+'","metrics":{"'+MY_METRIC_NAME+'":'+CURRENT_VALUE+'},"attributes":{"group":"'+MY_GROUP_ID+'","node":"'+MY_RESOURCE_ID+'"} }'
        output_json=output_json+LAST_LINE
        output_json=output_json+']}'
        #print (output_json)
        # print (MY_TIMESTAMP_READABLE)
        # print (MY_TIMESTAMP)
        #print('output_json:'+output_json)
        response = requests.post(url, data=output_json, headers=headers, verify=False)
        print('                   RESULT:'+str(response.content)+' at '+MY_TIMESTAMP_READABLE)
    #print('               ✅ Inject Metrics')
    #print('               ------------------------------------------------------------------------------------------------')
    print('              ✅ LAST RESULT:'+str(response.content)+' at '+MY_TIMESTAMP_READABLE)

    return 'OK'





