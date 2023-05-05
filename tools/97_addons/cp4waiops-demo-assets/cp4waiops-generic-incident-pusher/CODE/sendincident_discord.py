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
        stateString="🔵 Assigned To Individual"
    elif state=="inProgress":
        stateString="🟢 In Progress"
    elif state=="onHold":
        stateString="🟠 On Hold"
    elif state=="resolved":
        stateString="🔴 Resolved"
    elif state=="closed":
        stateString="❌ Closed"
    else:
        stateString=state
    debug(stateString)

    owner=currentIncident['owner']
    team=currentIncident['team']
    lastChangedTime=currentIncident['lastChangedTime']
    insights=currentIncident['insights']
    alertIds=currentIncident['alertIds']


    # Get similar incidents information
    similar_incident_urls=''
    similar_incident_score_max=0
    for insight in insights:
        if insight['type'] == 'aiops.ibm.com/insight-type/similar-incidents':
            for si in insight['details']['similar_incidents']:
                similar_incident_score=si['score']
                #debug(similar_incident_score)
                if similar_incident_score>=similar_incident_score_max:
                    similar_incident_score_max=similar_incident_score
                    similar_incident=si['title']
                    similar_incident_urls=si['url']
            #debug(similar_incident)
            #print(similar_incident_urls)
            #print(similar_incident_score_max)
    if similar_incident=='':
        similar_incident='none'
    if similar_incident_urls=='':
        similar_incident_urls='none'
    # Get resolution information
    resolution=''
    for insight in insights:
        if insight['type'] == 'aiops.ibm.com/insight-type/similar-incidents':
            for action in insight['details']['recommended_actions']:
                resolution=resolution+action['sentence']
            #print(resolution)
    if resolution=='':
        resolution='none'



  

    # Get Alerts information
    alerts=''
    alertsJSONString='{"fields": ['

    alertsJSONString='{"fields": [{"name": "Priority","value": "'+str(priority)+'","inline": "true"},{"name": "Owner:","value": "'+owner+' (Team '+team+')","inline": "true"},{"name": "State","value": "'+stateString+'","inline": "true"},{"name": "Similar Incidents","value": "'+similar_incident+'"},{"name": "Remediation","value": "'+resolution+'","inline": "true"},{"name": "Ticket","value": "'+similar_incident_urls+'","inline": "true"},{"name": "Alerts","value": "----------------"},'

    for alertId in alertIds:
        s = requests.Session()
        s.auth = (DATALAYER_USER, DATALAYER_PWD)
        s.headers.update({'Content-Type':'application/json','x-username':'admin','x-subscription-id':'cfd95b7e-3bc7-4006-a4a8-a73a79c71255'})
        debug('             🌏 Getting Alert '+alertId)
        response = s.get(api_url+'/'+str(alertId))
        #print(response.json())
        debug('             ✅ Query Status: '+str(response.status_code))
        actAlert=response.json()
        actAlertSummary=actAlert['summary']
        actAlertType=actAlert['type']['classification']
        actAlertCount=actAlert['eventCount']
        actAlertSeverity=actAlert['severity']
        insights=actAlert['insights']

        
        for insight in insights:
            if insight['type'] == 'aiops.ibm.com/insight-type/probable-cause':
                actRank=insight['details']['rank']
                if actRank <= MIN_RANK:
                    #debug('RANK: '+str(actRank))
                    alerts=alerts+'Rank: '+str(actRank)+' - Sev:'+str(actAlertSeverity)+' - '+actAlertType+' - Count: '+str(actAlertCount)+' - Summary: '+actAlertSummary+'\r\n' 
                    alertsJSONString=alertsJSONString+'{ "name": "Alert - Rank: '+str(actRank)+'","value": "'+actAlertSummary+'"},{"name": "Type","value": "'+actAlertType+'","inline": "true"},{"name": "Count","value": "'+str(actAlertCount)+'","inline": "true"},{"name": "Severity","value": "'+str(actAlertSeverity)+'","inline": "true"},'
                else:
                    debug('skipping')
    alertsJSONString=alertsJSONString[:-1]
    alertsJSONString=alertsJSONString+']}'

    debug('             ❗ '+alerts)
    #debug(alertsJSONString)
    #debug(type(alertsJSONString))
    alertsJSON=json.loads(alertsJSONString)
    #debug(type(alertsJSON))




    MESSAGE_TEMPLATE={
        "username": "CP4WAIOPS Bot",
        "avatar_url": "https://i.imgur.com/4M34hi2.png",
        "content": "CP4WAIOPS Incident",
        "embeds": [{
            "author": {
            "name": INSTANCE_NAME+" ChatBot",
            "url": "https://"+CPD_ROUTE+"/aiops/cfd95b7e-3bc7-4006-a4a8-a73a79c71255/resolution-hub/incidents/all/"+id+"/overview",
            "icon_url": "https://github.com/niklaushirt/cp4waiops-deployer/raw/main/doc/avatars/hero_stan_sm_avatar.png"
            },
            "title": title,
            "url": "https://"+CPD_ROUTE+"/aiops/cfd95b7e-3bc7-4006-a4a8-a73a79c71255/resolution-hub/incidents/all/"+id+"/overview",
            "description": description,
            "color": 15258703,  
        }]
        }
    MESSAGE_TEMPLATE['embeds'][0].update(alertsJSON)
    debug(MESSAGE_TEMPLATE)
    # debug(type(MESSAGE_TEMPLATE))

    sendSession = requests.Session()
    sendSession.headers.update({'Content-Type':'application/json'})
    print('           🌏 Sending Incident to '+PROVIDER_NAME+'')
    response = sendSession.post(PROVIDER_URL+"?wait=true", json=MESSAGE_TEMPLATE)
    
    try:
        response.raise_for_status()
    except response.exceptions.HTTPError as err:
        print(err)
    else:
        print("Payload delivered successfully, code {}.".format(response.status_code))


    if response.status_code==200:
        print('           🟢 Query OK: '+str(response.status_code))
        #debug(response.content)
        message=json.loads(response.content)
        debug("         🚀 CREATED MESSAGE ID: "+message['id'])

    else:   
        print('           ❗ ERROR: '+str(response.status_code))
        print(response.text)

    print ('         ✅ Sending to '+PROVIDER_NAME+', DONE...')
    print ('        ---------------------------------------------------------------------------------------------')
    print('')
    return message['id']








def updateIncidentToProvider(currentIncident, DATALAYER_USER, DATALAYER_PWD, DATALAYER_ROUTE, messageID):
    print('')
    print ('        ---------------------------------------------------------------------------------------------')
    print ('         ✉️  Updating '+PROVIDER_NAME+' Message')

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
        stateString="🔵 Assigned To Individual"
    elif state=="inProgress":
        stateString="🟢 In Progress"
    elif state=="onHold":
        stateString="🟠 On Hold"
    elif state=="resolved":
        stateString="🔴 Resolved"
    elif state=="closed":
        stateString="❌ Closed"
    else:
        stateString=state
    debug(stateString)


    owner=currentIncident['owner']
    team=currentIncident['team']
    lastChangedTime=currentIncident['lastChangedTime']
    insights=currentIncident['insights']
    alertIds=currentIncident['alertIds']


    # Get similar incidents information
    similar_incident_urls=''
    similar_incident_score_max=0
    for insight in insights:
        if insight['type'] == 'aiops.ibm.com/insight-type/similar-incidents':
            for si in insight['details']['similar_incidents']:
                similar_incident_score=si['score']
                #debug(similar_incident_score)
                if similar_incident_score>=similar_incident_score_max:
                    similar_incident_score_max=similar_incident_score
                    similar_incident=si['title']
                    similar_incident_urls=si['url']
            #debug(similar_incident)
            #print(similar_incident_urls)
            #print(similar_incident_score_max)
    if similar_incident=='':
        similar_incident='none'
    if similar_incident_urls=='':
        similar_incident_urls='none'
    # Get resolution information
    resolution=''
    for insight in insights:
        if insight['type'] == 'aiops.ibm.com/insight-type/similar-incidents':
            for action in insight['details']['recommended_actions']:
                resolution=resolution+action['sentence']
            #print(resolution)
    if resolution=='':
        resolution='none'



  

    # Get Alerts information
    alerts=''
    alertsJSONString='{"fields": ['

    alertsJSONString='{"fields": [{"name": "Priority","value": "'+str(priority)+'","inline": "true"},{"name": "Owner:","value": "'+owner+' (Team '+team+')","inline": "true"},{"name": "State","value": "'+stateString+'","inline": "true"},{"name": "Similar Incidents","value": "'+similar_incident+'"},{"name": "Remediation","value": "'+resolution+'","inline": "true"},{"name": "Ticket","value": "'+similar_incident_urls+'","inline": "true"},{"name": "Alerts","value": "----------------"},'

    for alertId in alertIds:
        s = requests.Session()
        s.auth = (DATALAYER_USER, DATALAYER_PWD)
        s.headers.update({'Content-Type':'application/json','x-username':'admin','x-subscription-id':'cfd95b7e-3bc7-4006-a4a8-a73a79c71255'})
        debug('             🌏 Getting Alert '+alertId)
        response = s.get(api_url+'/'+str(alertId))
        #print(response.json())
        debug('             ✅ Query Status: '+str(response.status_code))
        actAlert=response.json()
        actAlertSummary=actAlert['summary']
        actAlertType=actAlert['type']['classification']
        actAlertCount=actAlert['eventCount']
        actAlertSeverity=actAlert['severity']
        insights=actAlert['insights']

        
        for insight in insights:
            if insight['type'] == 'aiops.ibm.com/insight-type/probable-cause':
                actRank=insight['details']['rank']
                if actRank <= MIN_RANK:
                    #debug('RANK: '+str(actRank))
                    alerts=alerts+'Rank: '+str(actRank)+' - Sev:'+str(actAlertSeverity)+' - '+actAlertType+' - Count: '+str(actAlertCount)+' - Summary: '+actAlertSummary+'\r\n' 
                    alertsJSONString=alertsJSONString+'{ "name": "Alert - Rank: '+str(actRank)+'","value": "'+actAlertSummary+'"},{"name": "Type","value": "'+actAlertType+'","inline": "true"},{"name": "Count","value": "'+str(actAlertCount)+'","inline": "true"},{"name": "Severity","value": "'+str(actAlertSeverity)+'","inline": "true"},'
                else:
                    debug('skipping')
    alertsJSONString=alertsJSONString[:-1]
    alertsJSONString=alertsJSONString+']}'

    debug('             ❗ '+alerts)

    #debug(alertsJSONString)
    #debug(type(alertsJSONString))
    alertsJSON=json.loads(alertsJSONString)
    #debug(type(alertsJSON))




    MESSAGE_TEMPLATE={
        "username": "CP4WAIOPS Bot",
        "avatar_url": "https://i.imgur.com/4M34hi2.png",
        "content": "CP4WAIOPS Incident",
        "embeds": [{
            "author": {
            "name": INSTANCE_NAME+" ChatBot - Incident Updated",
            "url": "https://"+CPD_ROUTE+"/aiops/cfd95b7e-3bc7-4006-a4a8-a73a79c71255/resolution-hub/incidents/all/"+id+"/overview",
            "icon_url": "https://github.com/niklaushirt/cp4waiops-deployer/raw/main/doc/avatars/hero_stan_sm_avatar.png"
            },
            "title": title,
            "url": "https://"+CPD_ROUTE+"/aiops/cfd95b7e-3bc7-4006-a4a8-a73a79c71255/resolution-hub/incidents/all/"+id+"/overview",
            "description": description,
            "color": 15258703,  
        }]
        }
    MESSAGE_TEMPLATE['embeds'][0].update(alertsJSON)
    #debug(MESSAGE_TEMPLATE)
    # debug(type(MESSAGE_TEMPLATE))

    sendSession = requests.Session()
    sendSession.headers.update({'Content-Type':'application/json'})
    print('           🌏 Sending Incident to '+PROVIDER_NAME+'')
    response = sendSession.patch(PROVIDER_URL+"/messages/"+messageID, json=MESSAGE_TEMPLATE)

    try:
        response.raise_for_status()
    except response.exceptions.HTTPError as err:
        print(err)
    else:
        print("Payload delivered successfully, code {}.".format(response.status_code))



    if response.status_code==200:
        print('           🟢 Query OK: '+str(response.status_code))
        #debug(response.content)
        message=json.loads(response.content)
        debug("         🚀 UPDATED MESSAGE ID: "+message['id'])

    else:   
        print('           ❗ ERROR: '+str(response.status_code))
        print(response.text)


    print ('         ✅ Updating '+PROVIDER_NAME+' Message, DONE...')
    print ('        ---------------------------------------------------------------------------------------------')
    print('')
    return message['id']



def resolveIncidentToProvider(currentIncidentID, DATALAYER_USER, DATALAYER_PWD, DATALAYER_ROUTE, messageID):
    print('')
    print ('        ---------------------------------------------------------------------------------------------')
    print ('         🧻  Closing '+PROVIDER_NAME+' Message')

    readSession = requests.Session()
    readSession.headers.update({'Content-Type':'application/json'})
    print('           🌏 Getting Incident from '+PROVIDER_NAME+'')
    responseGet = readSession.get(PROVIDER_URL+"/messages/"+str(messageID))
    currentMessage=responseGet.json()

    debug(str(currentMessage))

    currentMessage['embeds'][0]['fields'].clear()
    currentMessage['embeds'][0]['color']='15548997'
    currentMessage['embeds'][0]['url']=''
    currentMessage['embeds'][0]['author']['url']=''
    currentMessage['embeds'][0]['author']['icon_url']=''
    currentMessage['embeds'][0]['author']['proxy_icon_url']=''
    currentMessage['embeds'][0]['author']['name']='🔴 '+INSTANCE_NAME+' ChatBot - Incident Closed'
    currentMessage['content']='🔴 CP4WAIOPS Incident - CLOSED'

    debug("CURRENT:"+str(currentMessage))
    debug("A:"+str(PROVIDER_URL))
    debug("B:"+str(currentIncidentID))

    sendSession = requests.Session()
    sendSession.headers.update({'Content-Type':'application/json'})
    print('           🔴 Closing Incident on '+PROVIDER_NAME+'')
    response = sendSession.patch(PROVIDER_URL+"/messages/"+str(messageID), json=currentMessage)
    if response.status_code==200:
        print('           🟢 Query OK: '+str(response.status_code))
        debug(response.content)
        message=json.loads(response.content)
        debug(message['id'])

    else:   
        print('           ❗ ERROR: '+str(response.status_code))
        print(response.text)


    print ('         ✅ Closing '+PROVIDER_NAME+' Message, DONE...')
    print ('        ---------------------------------------------------------------------------------------------')
    print('')




