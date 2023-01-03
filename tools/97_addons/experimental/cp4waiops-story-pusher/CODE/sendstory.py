import requests
import json
import os

DEBUG_ME=os.environ.get('DEBUG_ME',"False")
DISCORD_WEBHOOK=os.environ.get('DISCORD_WEBHOOK','not provided')
MAIL_USER=os.environ.get('MAIL_USER','not provided')
MAIL_PWD=os.environ.get('MAIL_PWD','not provided')
MIN_RANK=int(os.environ.get('MIN_RANK',1))

stream = os.popen("oc get po -A|grep aiops-orchestrator-controller |awk '{print$1}'")
aimanagerns = stream.read().strip()



def debug(text):
    if DEBUG_ME=="True":
        print(text)

stream = os.popen("oc get route  -n "+aimanagerns+" cpd  -o jsonpath='{.status.ingress[0].host}'")
CPD_ROUTE = stream.read().strip()

debug('CPD_ROUTE:'+CPD_ROUTE)


def sendDiscord(currentStory, DATALAYER_USER, DATALAYER_PWD, DATALAYER_ROUTE):
    print('')
    print ('        ---------------------------------------------------------------------------------------------')
    print ('         ✉️ Send Discord')

    api_url = "https://"+DATALAYER_ROUTE+"/irdatalayer.aiops.io/active/v1/alerts"

    debug ('           🌏 Datalayer Route:    '+DATALAYER_ROUTE)
    debug ('           👩‍💻 Datalayer User:     '+DATALAYER_USER)
    debug ('           🔐 Datalayer Pwd:      '+DATALAYER_PWD)
    debug ('           🔐 Datalayer api_url:  '+api_url)

    similar_incident=''
    resolution=''
    alertsJSONString=''
    #debug(currentStory)
    debug ('        ---------------------------------------------------------------------------------------------')

    # Get story information
    id=currentStory['id']
    title=currentStory['title']
    debug('             ❗ Story: '+title)
    createdBy=currentStory['createdBy']
    description=currentStory['description']
    priority=currentStory['priority']
    state=currentStory['state']
    owner=currentStory['owner']
    team=currentStory['team']
    lastChangedTime=currentStory['lastChangedTime']
    insights=currentStory['insights']
    alertIds=currentStory['alertIds']


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

    alertsJSONString='{"fields": [{"name": "Priority","value": "'+str(priority)+'","inline": "true"},{"name": "Owner:","value": "'+owner+'   of Team: '+team+'","inline": "true"},{"name": "State","value": "'+state+'","inline": "true"},{"name": "Similar Incidents","value": "'+similar_incident+'"},{"name": "Remediation","value": "'+resolution+'","inline": "true"},{"name": "Ticket","value": "'+similar_incident_urls+'","inline": "true"},{"name": "Alerts","value": "----------------"},'

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
        "content": "CP4WAIOPS Story",
        "embeds": [{
            "author": {
            "name": "CP4WAIOPS ChatBot",
            "url": "https://"+CPD_ROUTE+"/aiops/cfd95b7e-3bc7-4006-a4a8-a73a79c71255/resolution-hub/stories/all/"+id+"/overview",
            "icon_url": "https://github.com/niklaushirt/cp4waiops-deployer/raw/main/doc/avatars/hero_stan_sm_avatar.png"
            },
            "title": title,
            "url": "https://"+CPD_ROUTE+"/aiops/cfd95b7e-3bc7-4006-a4a8-a73a79c71255/resolution-hub/stories/all/"+id+"/overview",
            "description": description,
            "color": 15258703,  
        }]
        }
    MESSAGE_TEMPLATE['embeds'][0].update(alertsJSON)
    #debug(MESSAGE_TEMPLATE)
    # debug(type(MESSAGE_TEMPLATE))

    sendSession = requests.Session()
    sendSession.headers.update({'Content-Type':'application/json'})
    print('         🌏 Sending Story to Discord')
    response = sendSession.post(DISCORD_WEBHOOK, json=MESSAGE_TEMPLATE)
    if response.status_code==204:
        print('         ✅ Query OK: '+str(response.status_code))
        print(response.text)
    else:   
        print('         ❗ ERROR: '+str(response.status_code))
        print(response.text)


    print ('         ✅ Sending to Discord, DONE...')
    print ('        ---------------------------------------------------------------------------------------------')
    print('')





def sendMail(currentStory, DATALAYER_USER, DATALAYER_PWD, DATALAYER_ROUTE):
    print('')
    print('')
    print ('        ---------------------------------------------------------------------------------------------')
    print ('         ✉️ Send Mail')
    print('')
    print('')
    id=currentStory['id']
    title=currentStory['title']
    createdBy=currentStory['createdBy']
    description=currentStory['description']
    priority=currentStory['priority']
    state=currentStory['state']
    owner=currentStory['owner']
    team=currentStory['team']
    lastChangedTime=currentStory['lastChangedTime']
    insights=currentStory['insights']


    #print(title)
    similar_incident_urls=''
    similar_incident_score_max=0
    for insight in insights:
        if insight['type'] == 'aiops.ibm.com/insight-type/similar-incidents':
            for si in insight['details']['similar_incidents']:
                similar_incident_score=si['score']
                #print(similar_incident_score)
                if similar_incident_score>=similar_incident_score_max:
                    similar_incident_score_max=similar_incident_score
                    similar_incident=si['title']
                    similar_incident_urls=si['url']
            #print(similar_incident)
            #print(similar_incident_urls)
            #print(similar_incident_score_max)

    resolution=''
    for insight in insights:
        if insight['type'] == 'aiops.ibm.com/insight-type/similar-incidents':
            for action in insight['details']['recommended_actions']:
                resolution=resolution+action['sentence']+'\r\n'
            #print(resolution)

    storyString=''
    storyString=storyString+'Story: '+title+'\r\n'
    storyString=storyString+'createdBy'+createdBy+'\r\n'
    storyString=storyString+'description'+description+'\r\n'
    storyString=storyString+'priority'+str(priority)+'\r\n'
    storyString=storyString+'state'+state+'\r\n'
    storyString=storyString+'owner'+owner+' of Team '+team+'\r\n'
    storyString=storyString+'lastChangedTime'+lastChangedTime+'\r\n'
    storyString=storyString+'Similar Incident: '+similar_incident+'\r\n'
    storyString=storyString+'URL: '+similar_incident_urls+'\r\n'
    storyString=storyString+'Score '+str(similar_incident_score_max)+'\r\n'
    storyString=storyString+'Remediation: '+resolution+'\r\n'

    debug (storyString)



    print ('         ✅ Sending to Mail, DONE...')
    print ('        ---------------------------------------------------------------------------------------------')
    print('')
    print('')