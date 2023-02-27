
import os
import sys 
import time 
import requests
import time
from functions import *
import os
import sqlite3
import hashlib

DEBUG_ME=os.environ.get('DEBUG_ME',"False")
TOKEN=os.environ.get('TOKEN',"P4ssw0rd!")

MIN_RANK=int(os.environ.get('MIN_RANK',1))

DISCORD_WEBHOOK=os.environ.get('DISCORD_WEBHOOK','CHANGEME')
MAIL_USER=os.environ.get('MAIL_USER','not provided')
MAIL_PWD=os.environ.get('MAIL_PWD','not provided')

POLL_DELAY=int(os.environ.get('POLL_DELAY',5))

ACTIVE=os.environ.get('ACTIVE',"False")


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
print ('    🛰️  PAgerduty Story Pusher for CP4WAIOPS AI Manager')
print ('')
print ('       Provided by:')
print ('        🇨🇭 Niklaus Hirt (nikh@ch.ibm.com)')
print ('')

print ('-------------------------------------------------------------------------------------------------')
print (' 🚀 Warming up')
print ('-------------------------------------------------------------------------------------------------')

#os.system('ls -l')
loggedin='false'
loginip='0.0.0.0'

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# GET NAMESPACES
# ----------------------------------------------------------------------------------------------------------------------------------------------------

print('     🛠️ Initializing DB')
conn = sqlite3.connect('./db/stories.db')

print('        ✅ Opened database successfully')

try:
    conn.execute('''CREATE TABLE STORIES
            (ID TEXT PRIMARY KEY     NOT NULL, MESSAGE_HASH TEXT NOT NULL, DISCORD_ID TEXT NOT NULL);''')
except sqlite3.OperationalError as e:
   # handle ConnectionError the exception
   print('        ℹ️  DB: '+str(e))


print ('')

print('     ❓ Getting AIManager Namespace')
stream = os.popen("oc get po -A|grep aiops-orchestrator-controller |awk '{print$1}'")
aimanagerns = stream.read().strip()
print('        ✅ AIManager Namespace:       '+aimanagerns)




# ----------------------------------------------------------------------------------------------------------------------------------------------------
# DEFAULT VALUES
# ----------------------------------------------------------------------------------------------------------------------------------------------------
TOKEN='test'


# ----------------------------------------------------------------------------------------------------------------------------------------------------
# GET CONNECTIONS
# ----------------------------------------------------------------------------------------------------------------------------------------------------
global DATALAYER_ROUTE
global DATALAYER_USER
global DATALAYER_PWD
global api_url

print('     ❓ Getting Details Datalayer')
stream = os.popen("oc get route  -n "+aimanagerns+" datalayer-api  -o jsonpath='{.status.ingress[0].host}'")
DATALAYER_ROUTE = stream.read().strip()
stream = os.popen("oc get secret -n "+aimanagerns+" aiops-ir-core-ncodl-api-secret -o jsonpath='{.data.username}' | base64 --decode")
DATALAYER_USER = stream.read().strip()
stream = os.popen("oc get secret -n "+aimanagerns+" aiops-ir-core-ncodl-api-secret -o jsonpath='{.data.password}' | base64 --decode")
DATALAYER_PWD = stream.read().strip()


ITERATE_ELEMENT=os.environ.get('ITERATE_ELEMENT')
WEBHOOK_DEBUG=os.environ.get('WEBHOOK_DEBUG')



print ('')
print ('')
print ('')
print ('-------------------------------------------------------------------------------------------------')
print (' 🔎 Parameters')
print ('-------------------------------------------------------------------------------------------------')
print ('')
print ('    ---------------------------------------------------------------------------------------------')
print ('     🔎 Global Parameters')
print ('    ---------------------------------------------------------------------------------------------')
print ('           🔐 DEBUG:              '+DEBUG_ME)
print ('           🕦 POLL_DELAY:         '+str(POLL_DELAY))
print ('           🔐 Token:              '+TOKEN)
print ('')
print ('')

print ('    ---------------------------------------------------------------------------------------------')
print ('     🔎 AI Manager Connection Parameters')
print ('    ---------------------------------------------------------------------------------------------')
print ('           🌏 Datalayer Route:    '+DATALAYER_ROUTE)
print ('           👩‍💻 Datalayer User:     '+DATALAYER_USER)
print ('           🔐 Datalayer Pwd:      '+DATALAYER_PWD)
print ('')
print ('')
print ('    ---------------------------------------------------------------------------------------------')
print ('     🔎 Target Connection Parameters')
print ('    ---------------------------------------------------------------------------------------------')
print ('           🌏 Discord Webhook:    '+DISCORD_WEBHOOK)
print ('')
print ('           👩‍💻 Mail User:          '+MAIL_USER)
print ('           🔐 Mail Pwd:           '+MAIL_PWD)
print ('')
print ('           📥 Minimum Alert Rank: '+str(MIN_RANK))
print ('')
print ('    ---------------------------------------------------------------------------------------------')
print('')
print('')


#while True:
# print ('test')
# api_url = "https://jsonplaceholder.typicode.com/todos/1"
# response = requests.get(api_url)
# print(response.json())
# print(response.status_code)

# curl "https://$DATALAYER_ROUTE/irdatalayer.aiops.io/active/v1/stories" --insecure --silent -X GET -u "$USER_PASS" -H "Content-Type: application/json" -H "x-username:admin" -H "x-subscription-id:cfd95b7e-3bc7-4006-a4a8-a73a79c71255"

print ('-------------------------------------------------------------------------------------------------')
print (' 🚀 Initializing Pusher')
print ('-------------------------------------------------------------------------------------------------')

api_url = "https://"+DATALAYER_ROUTE+"/irdatalayer.aiops.io/active/v1/stories"


s = requests.Session()
s.auth = (DATALAYER_USER, DATALAYER_PWD)
s.headers.update({'Content-Type':'application/json','x-username':'admin','x-subscription-id':'cfd95b7e-3bc7-4006-a4a8-a73a79c71255'})

print('     🌏 Running Initial Query')
try:
    response = s.get(api_url)
except requests.ConnectionError as e:
   # handle ConnectionError the exception
   print('     ❗ Connection Error')
   print(str(e))

#print(response.json())
print('     ✅ Query Status: '+str(response.status_code))

# headers =  "{'Content-Type':'application/json'; 'x-username':'admin'; 'x-subscription-id':'cfd95b7e-3bc7-4006-a4a8-a73a79c71255' }"
# response = requests.get(api_url, headers=headers, auth=(DATALAYER_USER, DATALAYER_PWD))

#print(response.json())
actStories=response.json()
#print(actStories['stories'])
#print(actStories['stories'][0]['description'])

savedStoryCount= len(actStories['stories'])

# if DEBUG_ME:
savedStoryCount=savedStoryCount-1

print('     🔄 Initial Story Count:'+str(savedStoryCount))
print('')
print('')


# ------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------
# RUN THIS PUPPY
# ------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------

if ACTIVE=="True": 
    if DISCORD_WEBHOOK=="CHANGEME": 
        print ('-------------------------------------------------------------------------------------------------')
        print (' ❗ Discord Webhook not defined!!!')
        print ('-------------------------------------------------------------------------------------------------')
    else:
        print ('-------------------------------------------------------------------------------------------------')
        print (' 🚀 Running Pusher')
        print ('-------------------------------------------------------------------------------------------------')

        treatedStories=[]

        while True:
            debug ('    🔎 treatedStories:'+str(treatedStories))
            debug('     🌏 Running Query')
            try:
                response = s.get(api_url)
            except requests.ConnectionError as e:
                # handle ConnectionError the exception
                print('     ❗ Connection Error')
                print(str(e))


            #print(response.json())
            debug('     ✅ Query Status: '+str(response.status_code))
            actStories=response.json()


            for currentStory in actStories['stories']:
                story_id=currentStory["id"]
                storyState=currentStory["state"]
                lastChangedTime=currentStory["lastChangedTime"]
                messageHash=hashlib.md5(str(currentStory).encode()).hexdigest()
                #debug(currentStory)
                debug('     ✅ Check for: '+story_id)
                debug('     ✅ Story State: '+storyState)
                debug('     ✅ Last Changed: '+lastChangedTime)
                debug('     ✅ Hash: '+messageHash)
                debug('      ')

                if storyState != 'closed':
                    if checkIDExistsDB(conn, story_id) == 0:
                    #if id not in treatedStories:
                            debug('     🛠️ Treating Story with ID: '+story_id)
                            treatedStories.append(story_id)
                            processStory(currentStory, DATALAYER_USER, DATALAYER_PWD, DATALAYER_ROUTE, conn, story_id, messageHash)
                            #closeStory(conn, story_id)

                            #debug(currentStory)
                    else:
                        if needsUpdate(conn, story_id, messageHash) == 1:
                            print('       🟠 NEEDS UPDATE: '+story_id)
                            discord_id=getMessageIdDB(conn, story_id)
                            updateStory(currentStory, DATALAYER_USER, DATALAYER_PWD, DATALAYER_ROUTE, discord_id)
                        else:
                            debug('       🟢 Already Treated: '+story_id)
                        
                else:
                    if checkIDExistsDB(conn, story_id) > 0:
                        print('       🔴 Closing Story: '+story_id)
                        closeStory(conn, story_id)

            debug ('     🕦 Wait '+str(POLL_DELAY)+' seconds')

            time.sleep(POLL_DELAY)
            debug ('    ---------------------------------------------------------------------------------------------')
else:
    while True:
        print ('-------------------------------------------------------------------------------------------------')
        print (' ❗ Story Pusher is DISABLED')
        print ('-------------------------------------------------------------------------------------------------')
        time.sleep(15)

print ('')
print ('')
print ('')
print ('-------------------------------------------------------------------------------------------------')
print (' ✅ Pusher is DONE')
print ('-------------------------------------------------------------------------------------------------')
print ('')
print ('')




