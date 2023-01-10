import requests
import json


def sendDiscord(currentStories, storyCount):
    print('')
    print ('        ---------------------------------------------------------------------------------------------')
    print ('         ✉️ Send Discord')
    print('')


    id=currentStories['stories'][storyCount-1]['id']
    title=currentStories['stories'][storyCount-1]['title']
    createdBy=currentStories['stories'][storyCount-1]['createdBy']
    description=currentStories['stories'][storyCount-1]['description']
    priority=currentStories['stories'][storyCount-1]['priority']
    state=currentStories['stories'][storyCount-1]['state']
    owner=currentStories['stories'][storyCount-1]['owner']
    team=currentStories['stories'][storyCount-1]['team']
    lastChangedTime=currentStories['stories'][storyCount-1]['lastChangedTime']
    insights=currentStories['stories'][storyCount-1]['insights']


    #print(title)
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

    WEBHOOK_URL="https://discord.com/api/webhooks/1055155521155518584/fA-Entc_aRSQyiQVvzpZjVBfPBnb3MwNqfxS9PVp-fW7w7ZoKpe_-qzlBSaHog2-F9ck"



    MESSAGE_TEMPLATE={
        "username": "CP4WAIOPS Bot",
        "avatar_url": "https://i.imgur.com/4M34hi2.png",
        "content": "CP4WAIOPS Story",
        "embeds": [{
            "author": {
            "name": "CP4WAIOPS ChatBot",
            "url": "https://cpd-cp4waiops.itzroks-270003bu3k-3pjlss-4b4a324f027aea19c5cbc0c3275c4656-0000.eu-gb.containers.appdomain.cloud/aiops/cfd95b7e-3bc7-4006-a4a8-a73a79c71255/resolution-hub/stories/all/"+id+"/overview",
            "icon_url": "https://github.com/niklaushirt/cp4waiops-deployer/raw/main/doc/avatars/hero_stan_sm_avatar.png"
            },
            "title": title,
            "url": "https://cpd-cp4waiops.itzroks-270003bu3k-3pjlss-4b4a324f027aea19c5cbc0c3275c4656-0000.eu-gb.containers.appdomain.cloud/aiops/cfd95b7e-3bc7-4006-a4a8-a73a79c71255/resolution-hub/stories/all/"+id+"/overview",
            "description": description,
            "color": 15258703,
            "fields": [{
                "name": "Priority",
                "value": str(priority),
                "inline": "true"
            },
            {
                "name": "Owner",
                "value": owner+' of Team '+team,
                "inline": "true"
            },
            {
                "name": "State",
                "value": state,
                "inline": "true"
            },
            {
                "name": "Similar Incidents",
                "value": similar_incident
            },
             {
                "name": "Ticket",
                "value": similar_incident_urls,
                "inline": "true"
            },
                      {
                "name": "Remediation",
                "value": resolution,
                "inline": "true"
            },
            ]
          
        }]
        }

    sendSession = requests.Session()
    sendSession.headers.update({'Content-Type':'application/json'})
    print('         🌏 Sending Story to Discord')
    response = sendSession.post(WEBHOOK_URL, json=MESSAGE_TEMPLATE)
    print('         ✅ Query Status: '+str(response.status_code))
    print(response.text)


    print ('         ✅ Sending to Discord, DONE...')
    print ('        ---------------------------------------------------------------------------------------------')
    print('')
    print('')





def sendMail(currentStories, storyCount):
    print('')
    print('')
    print ('        ---------------------------------------------------------------------------------------------')
    print ('         ✉️ Send Mail')
    print('')
    print('')
    id=currentStories['stories'][storyCount-1]['id']
    title=currentStories['stories'][storyCount-1]['title']
    createdBy=currentStories['stories'][storyCount-1]['createdBy']
    description=currentStories['stories'][storyCount-1]['description']
    priority=currentStories['stories'][storyCount-1]['priority']
    state=currentStories['stories'][storyCount-1]['state']
    owner=currentStories['stories'][storyCount-1]['owner']
    team=currentStories['stories'][storyCount-1]['team']
    lastChangedTime=currentStories['stories'][storyCount-1]['lastChangedTime']
    insights=currentStories['stories'][storyCount-1]['insights']


    #print(title)
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

    print (storyString)



    print ('         ✅ Sending to Mail, DONE...')
    print ('        ---------------------------------------------------------------------------------------------')
    print('')
    print('')