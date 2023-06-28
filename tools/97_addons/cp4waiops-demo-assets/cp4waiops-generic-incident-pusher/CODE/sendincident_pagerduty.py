# ------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------
# This Module must implement:
#   def sendIncidentToProvider(currentIncident, DATALAYER_USER, DATALAYER_PWD, DATALAYER_ROUTE):
#   def updateIncidentToProvider(currentIncident, DATALAYER_USER, DATALAYER_PWD, DATALAYER_ROUTE, messageID):
#   def resolveIncidentToProvider(currentIncident, DATALAYER_USER, DATALAYER_PWD, DATALAYER_ROUTE, messageID):
# ------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------



import requests
import json
import os
import time
import http.client, urllib

ACTIVE=os.environ.get('ACTIVE',"False")
DEBUG_ME=os.environ.get('DEBUG_ME',"False")

POLL_DELAY=int(os.environ.get('POLL_DELAY',5))
INSTANCE_NAME=os.environ.get('INSTANCE_NAME','Demo')
MIN_RANK=int(os.environ.get('MIN_RANK',1))

PROVIDER_NAME=os.environ.get('PROVIDER_NAME','NONE')
PROVIDER_URL=os.environ.get('PROVIDER_URL','NONE')
PROVIDER_USER=os.environ.get('PROVIDER_USER','NONE')
PROVIDER_TOKEN=os.environ.get('PROVIDER_TOKEN','NONE')

print ('---------------------------------------------------------------------------------------------')
print ('📛 Loading Provider Module: '+PROVIDER_NAME)

def testModuleLoad():
    print('   ✅ Load OK')


stream = os.popen("oc get pod -A|grep aiops-orchestrator-controller |awk '{print$1}'")
aimanagerns = stream.read().strip()



def debug(text):
    if DEBUG_ME=="True":
        print(text)

stream = os.popen("oc get route  -n "+aimanagerns+" cpd  -o jsonpath='{.status.ingress[0].host}'")
CPD_ROUTE = stream.read().strip()

debug('CPD_ROUTE:'+CPD_ROUTE)






def sendIncidentToProvider(currentIncident, DATALAYER_USER, DATALAYER_PWD, DATALAYER_ROUTE):
    print('')
    print ('        ---------------------------------------------------------------------------------------------')
    print ('         ✉️  Send to '+PROVIDER_NAME+'')

    api_url = "https://"+DATALAYER_ROUTE+"/irdatalayer.aiops.io/active/v1/alerts"

    debug ('           🌏 Datalayer Route:    '+DATALAYER_ROUTE)
    debug ('           👩‍💻 Datalayer User:     '+DATALAYER_USER)
    debug ('           🔐 Datalayer Pwd:      '+DATALAYER_PWD)
    debug ('           🔐 Datalayer api_url:  '+api_url)

    similar_incident=''
    resolution=''
    alertsJSONString=''
    #debug(currentIncident)
    debug ('        ---------------------------------------------------------------------------------------------')

    # Get incident information
    id=currentIncident['id']
    title=currentIncident['title']
    debug('             ❗ Incident: '+title)
    createdBy=currentIncident['createdBy']
    description=currentIncident['description']
    priority=currentIncident['priority']
    state=currentIncident['state']
    if state=="assignedToIndividual":
        stateString="trigger"
    elif state=="inProgress":
        stateString="acknowledge"
    elif state=="onHold":
        stateString="acknowledge"
    elif state=="resolved":
        stateString="resolve"
    elif state=="closed":
        stateString="resolve"
    else:
        stateString="trigger"
    debug(stateString)

    owner=currentIncident['owner']
    team=currentIncident['team']
    lastChangedTime=currentIncident['lastChangedTime']


  

    MESSAGE_TEMPLATE={
    "routing_key": PROVIDER_TOKEN,
    "event_action": stateString,
    "dedup_key": id,
    "payload": {
        "summary": title,
        "source": INSTANCE_NAME+" ChatBot",
        "severity": "info",
        "component": "postgres",
        "group": "prod-datapipe",
        "class": "deploy",
        "custom_details": {
        "Description": description,
        "From": INSTANCE_NAME+" ChatBot",
        "Created By": createdBy,
        "Priority": priority,
        "URL": "https://"+CPD_ROUTE+"/aiops/cfd95b7e-3bc7-4006-a4a8-a73a79c71255/resolution-hub/incidents/all/"+id+"/overview",
        }
    }
    }

    debug(MESSAGE_TEMPLATE)
    debug(PROVIDER_URL)
    # debug(type(MESSAGE_TEMPLATE))

    sendSession = requests.Session()
    sendSession.headers.update({'Content-Type':'application/json'})
    print('           🌏 Sending Incident to Pagerduty')
    response = sendSession.post(PROVIDER_URL, json=MESSAGE_TEMPLATE)
    
    debug(str(response.text))



    if response.json()["status"]=="success":
        print('           🟢 Query OK: '+str(response.json()["message"]))
        #debug(response.content)
    else:   
        print('           ❗ ERROR: '+str(response.json()["status"]))
        print(response.text)

    print ('         ✅ Sending to '+PROVIDER_NAME+', DONE...')
    print ('        ---------------------------------------------------------------------------------------------')
    print('')
    return id






def updateIncidentToProvider(currentIncident, DATALAYER_USER, DATALAYER_PWD, DATALAYER_ROUTE, messageID):
    print('')
    print ('        ---------------------------------------------------------------------------------------------')
    print ('         ✉️  Updating '+PROVIDER_NAME+'')

    api_url = "https://"+DATALAYER_ROUTE+"/irdatalayer.aiops.io/active/v1/alerts"

    debug ('           🌏 Datalayer Route:    '+DATALAYER_ROUTE)
    debug ('           👩‍💻 Datalayer User:     '+DATALAYER_USER)
    debug ('           🔐 Datalayer Pwd:      '+DATALAYER_PWD)
    debug ('           🔐 Datalayer api_url:  '+api_url)

    similar_incident=''
    resolution=''
    alertsJSONString=''
    #debug(currentIncident)
    debug ('        ---------------------------------------------------------------------------------------------')

    # Get incident information
    id=currentIncident['id']
    title=currentIncident['title']
    debug('             ❗ Incident: '+title)
    createdBy=currentIncident['createdBy']
    description=currentIncident['description']
    priority=currentIncident['priority']
    state=currentIncident['state']
    if state=="assignedToIndividual":
        stateString="trigger"
    elif state=="inProgress":
        stateString="acknowledge"
    elif state=="onHold":
        stateString="acknowledge"
    elif state=="resolved":
        stateString="resolve"
    elif state=="closed":
        stateString="resolve"
    else:
        stateString="trigger"
    debug(stateString)

    owner=currentIncident['owner']
    team=currentIncident['team']
    lastChangedTime=currentIncident['lastChangedTime']


  

    MESSAGE_TEMPLATE={
    "routing_key": PROVIDER_TOKEN,
    "event_action": stateString,
    "dedup_key": id,
    "payload": {
        "summary": title,
        "source": INSTANCE_NAME+" ChatBot",
        "severity": "info",
        "component": "postgres",
        "group": "prod-datapipe",
        "class": "deploy",
        "custom_details": {
        "Description": description,
        "From": INSTANCE_NAME+" ChatBot",
        "Created By": createdBy,
        "Priority": priority,
        "URL": "https://"+CPD_ROUTE+"/aiops/cfd95b7e-3bc7-4006-a4a8-a73a79c71255/resolution-hub/incidents/all/"+id+"/overview",
        }
    }
    }

    debug(MESSAGE_TEMPLATE)
    # debug(type(MESSAGE_TEMPLATE))

    sendSession = requests.Session()
    sendSession.headers.update({'Content-Type':'application/json'})
    print('           🌏 Updating Incident on '+PROVIDER_NAME+'')
    response = sendSession.post(PROVIDER_URL, json=MESSAGE_TEMPLATE)
    
    debug(response.json())



    if response.json()["status"]=="success":
        print('           🟢 Query OK: '+str(response.json()["message"]))
        #debug(response.content)
    else:   
        print('           ❗ ERROR: '+str(response.json()["status"]))
        print(response.text)

    print ('         ✅ Updating '+PROVIDER_NAME+', DONE...')
    print ('        ---------------------------------------------------------------------------------------------')
    print('')
    return id






def resolveIncidentToProvider(currentIncidentID, DATALAYER_USER, DATALAYER_PWD, DATALAYER_ROUTE, messageID):
    print('')
    print ('        ---------------------------------------------------------------------------------------------')
    print ('         ✉️  Resolve '+PROVIDER_NAME+'')

    api_url = "https://"+DATALAYER_ROUTE+"/irdatalayer.aiops.io/active/v1/alerts"

    debug ('           🌏 Datalayer Route:    '+DATALAYER_ROUTE)
    debug ('           👩‍💻 Datalayer User:     '+DATALAYER_USER)
    debug ('           🔐 Datalayer Pwd:      '+DATALAYER_PWD)
    debug ('           🔐 Datalayer api_url:  '+api_url)

    similar_incident=''
    resolution=''
    alertsJSONString=''
    #debug(currentIncident)
    debug ('        ---------------------------------------------------------------------------------------------')

  

    MESSAGE_TEMPLATE={
    "routing_key": PROVIDER_TOKEN,
    "event_action": "resolve",
    "dedup_key": currentIncidentID,
    "payload": {
        "summary": "Resolved",
        }
    }
    

    debug(MESSAGE_TEMPLATE)
    # debug(type(MESSAGE_TEMPLATE))

    sendSession = requests.Session()
    sendSession.headers.update({'Content-Type':'application/json'})
    print('           🌏 Resolving Incident on '+PROVIDER_NAME+'')
    response = sendSession.post(PROVIDER_URL, json=MESSAGE_TEMPLATE)
    
    debug(response.json())



    if response.json()["status"]=="success":
        print('           🟢 Query OK: '+str(response.json()["message"]))
        #debug(response.content)
    else:   
        print('           ❗ ERROR: '+str(response.json()["status"]))
        print(response.text)

    print ('         ✅Resolve '+PROVIDER_NAME+', DONE...')
    print ('        ---------------------------------------------------------------------------------------------')
    print('')
    return id







