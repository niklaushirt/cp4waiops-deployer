
import requests
from requests.auth import HTTPBasicAuth
import json
import datetime
import time
import random
import os
from functions import *
import discord
from discord.ext import commands
from urllib.parse import quote_plus
from threading import Thread

# ('--------------------------------------------------')('--------------------------------------------------')--------------
# GET VARIABLES
# ('--------------------------------------------------')('--------------------------------------------------')--------------
DEMO_EVENTS_MEM=os.environ.get('DEMO_EVENTS_MEM')
DEMO_EVENTS_FAN=os.environ.get('DEMO_EVENTS_FAN')
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


# READ ENVIRONMENT VARIABLES
DEBUG_ME=os.environ.get('DEBUG_ME',"False")
ACTIVE=os.environ.get('ACTIVE',"False")
DISCORD_BOT_TOKEN=os.environ.get('DISCORD_BOT_TOKEN',"None")
DISCORD_BOT_NAME=INSTANCE_NAME.lower()
DISCORD_BOT_PREFIX=os.environ.get('DISCORD_BOT_PREFIX',"/")
ITERATE_ELEMENT=os.environ.get('ITERATE_ELEMENT')
WEBHOOK_DEBUG=os.environ.get('WEBHOOK_DEBUG')

TOKEN=os.environ.get('TOKEN',"None")


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
print ('    🛰️  Discord Bot')
print ('')
print ('       Provided by:')
print ('        🇨🇭 Niklaus Hirt (nikh@ch.ibm.com)')
print ('')

print ('--------------------------------------------------------------------------------')
print (' 🚀 Warming up')
print ('--------------------------------------------------------------------------------')


# ('--------------------------------------------------')('--------------------------------------------------')--------------
# GET NAMESPACES
# ('--------------------------------------------------')('--------------------------------------------------')--------------
print('     ❓ Getting CP4WAIOps Namespace')
stream = os.popen("oc get po -A|grep aiops-orchestrator-controller |awk '{print$1}'")
aimanagerns = stream.read().strip()
print('        ✅ CP4WAIOps Namespace:       '+aimanagerns)




# ('--------------------------------------------------')('--------------------------------------------------')--------------
# DEFAULT VALUES
# ('--------------------------------------------------')('--------------------------------------------------')--------------



# ('--------------------------------------------------')('--------------------------------------------------')--------------
# GET CONNECTIONS
# ('--------------------------------------------------')('--------------------------------------------------')--------------
global DATALAYER_ROUTE
global DATALAYER_USER
global DATALAYER_PWD
global api_url

# ('--------------------------------------------------')('--------------------------------------------------')--------------
# GET CONNECTIONS
# ('--------------------------------------------------')('--------------------------------------------------')--------------
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
stream = os.popen("oc get secret -n "+aimanagerns+" admin-user-details -o jsonpath='{.data.initial_admin_password}' | base64 --decode")
tmppass = stream.read().strip()
stream = os.popen('curl -k -s -X POST https://'+METRIC_ROUTE+'/icp4d-api/v1/authorize -H "Content-Type: application/json" -d "{\\\"username\\\": \\\"admin\\\",\\\"password\\\": \\\"'+tmppass+'\\\"}" | jq .token | sed "s/\\\"//g"')
METRIC_TOKEN = stream.read().strip()

print('     ❓ Getting Details AIOPS UIs')
stream = os.popen("oc get route  -n "+aimanagerns+" cpd  -o jsonpath='{.status.ingress[0].host}'")
CPD_ROUTE = stream.read().strip()
stream = os.popen("oc get route  -n cp4waiops-demo-ui cp4waiops-demo-ui  -o jsonpath='{.status.ingress[0].host}'")
DENO_UI_ROUTE = stream.read().strip()
stream = os.popen("oc get route  -n instana-core dev-aiops -o jsonpath='{.status.ingress[0].host}'")
INSTANA_ROUTE = stream.read().strip()
stream = os.popen("oc get route  -n turbonomic nginx -o jsonpath='{.status.ingress[0].host}'")
TURBO_ROUTE = stream.read().strip()





print ('')
print ('')
print ('')
print ('--------------------------------------------------------------------------------')
print (' 🔎 Parameters')
print ('--------------------------------------------------------------------------------')
print ('')
print ('    --------------------------------------------------------------------------------')
print ('     🔎 Global Parameters')
print ('    --------------------------------------------------------------------------------')
print ('           🔐 DEBUG:                        '+DEBUG_ME)
print ('           🚀 ACTIVE:                       '+ACTIVE)
print ('           🔐 Token:                        '+TOKEN)
print ('')
print ('           👩‍💻 BOT NAME:                     '+DISCORD_BOT_NAME)
print ('           👩‍💻 BOT PREFIX:                   '+DISCORD_BOT_PREFIX)
print ('')
print ('')
print ('    --------------------------------------------------------------------------------')
print ('     🔎 CP4WAIOps Connection Parameters')
print ('    --------------------------------------------------------------------------------')
print ('           🌏 CP4WAIOPS:                    '+DATALAYER_ROUTE)
print ('           🌏 Demo UI:                      '+DATALAYER_ROUTE)
print ('           🌏 Instana:                      '+INSTANA_ROUTE)
print ('           🌏 Turbonomic:                   '+TURBO_ROUTE)
print ('')
print ('')
print ('    --------------------------------------------------------------------------------')
print ('     🔎 CP4WAIOps Datalayer Parameters')
print ('    --------------------------------------------------------------------------------')
print ('           🌏 Datalayer Route:              '+DATALAYER_ROUTE)
print ('           👩‍💻 Datalayer User:               '+DATALAYER_USER)
print ('           🔐 Datalayer Pwd:                '+DATALAYER_PWD)
print ('')
print ('')
print ('    --------------------------------------------------------------------------------')
print ('     🔎 Simulation Parameters')
print ('    --------------------------------------------------------------------------------')
print ('           INSTANCE_NAME:                    '+str(INSTANCE_NAME))
print ('           LOG_ITERATIONS:                   '+str(LOG_ITERATIONS))
print ('           LOG_TIME_FORMAT:                  '+LOG_TIME_FORMAT)
print ('           LOG_TIME_STEPS:                   '+str(LOG_TIME_STEPS))
print ('           LOG_TIME_SKEW Logs:               '+str(LOG_TIME_SKEW))
print ('           LOG_TIME_ZONE Cert:               '+str(LOG_TIME_ZONE))
print ('')  
print ('           EVENTS_TIME_SKEW:                 '+str(EVENTS_TIME_SKEW))
print ('           DEMO_EVENTS_MEM:                  '+str(len(DEMO_EVENTS_MEM)))
print ('           DEMO_EVENTS_FAN:                  '+str(len(DEMO_EVENTS_FAN)))
print ('')  
print ('           METRIC_TIME_SKEW:                 '+str(METRIC_TIME_SKEW))
print ('           METRIC_TIME_STEP:                 '+str(METRIC_TIME_STEP))
print ('           METRICS_TO_SIMULATE_MEM:          '+str(len(METRICS_TO_SIMULATE_MEM)))
print ('           METRICS_TO_SIMULATE_FAN_TEMP:     '+str(len(METRICS_TO_SIMULATE_FAN_TEMP)))
print ('           METRICS_TO_SIMULATE_FAN:          '+str(len(METRICS_TO_SIMULATE_FAN)))
print ('')
print ('')
print ('    --------------------------------------------------------------------------------')
print('')
print('')

print ('    --------------------------------------------------------------------------------')
print ('     🔎 Simulation Endpoints')
print ('    --------------------------------------------------------------------------------')
print ('           KafkaBroker:                      '+KAFKA_BROKER)
print ('           KafkaUser:                        '+KAFKA_USER)
print ('           KafkaPWD:                         '+KAFKA_PWD)
print ('           KafkaTopic Logs:                  '+KAFKA_TOPIC_LOGS)
print ('           Kafka Cert:                       '+KAFKA_CERT[:25]+'...')
print ('')     
print ('')     
print ('           Datalayer Route:                  '+DATALAYER_ROUTE)
print ('           Datalayer User:                   '+DATALAYER_USER)
print ('           Datalayer Pwd:                    '+DATALAYER_PWD)
print ('')     
print ('           Metric Route:                     '+METRIC_ROUTE)
print ('           Metric Token:                     '+METRIC_TOKEN[:25]+'...')
print ('')     
print ('           Token:                            '+TOKEN)
print ('')   

print ('--------------------------------------------------------------------------------')
print (' 🚀 Initializing Simulator')
print ('--------------------------------------------------------------------------------')



# --------------------------------------------------------------------------------
# --------------------------------------------------------------------------------
# ACTIONS
# --------------------------------------------------------------------------------
# --------------------------------------------------------------------------------

# --------------------------------------------------------------------------------
# INSTANA
# --------------------------------------------------------------------------------
def createIncidentInstana():
    print ('    --------------------------------------------------------------------------------')
    print ('     🚀 Creating - Incident Instana')
    print ('    --------------------------------------------------------------------------------')
    instanaCreateIncident()
    print ('     ✅ DONE"')


def resolveIncidentInstana():
    print ('    --------------------------------------------------------------------------------')
    print ('     🚀 Mitigating - Incident Instana')
    print ('    --------------------------------------------------------------------------------')
    instanaMitigateIncident()
    print ('     ✅ DONE"')


# --------------------------------------------------------------------------------
# WAIOPS
# --------------------------------------------------------------------------------
def createIncidentMem():
    print ('    --------------------------------------------------------------------------------')
    print ('     🚀 Running Simulator - RobotShop Memory')
    print ('    --------------------------------------------------------------------------------')
    stream = os.popen('oc set env deployment ratings -n robot-shop PDO_URL="mysql:host=mysql;dbname=ratings-dev;charset=utf8mb4"')
    RESULT = stream.read().strip()
    print(str(RESULT))
    stream = os.popen('oc set env deployment load -n robot-shop ERROR=1')
    RESULT = stream.read().strip()
    print(str(RESULT))


    print ('         🚀 Simulating Events')
    injectEventsMem(DATALAYER_ROUTE,DATALAYER_USER,DATALAYER_PWD)

    print ('         🚀 Simulating Metrics')
    injectMetricsMem(METRIC_ROUTE,METRIC_TOKEN)

    print ('         🚀 Simulating Logs')
    injectLogs(KAFKA_BROKER,KAFKA_USER,KAFKA_PWD,KAFKA_TOPIC_LOGS,KAFKA_CERT,LOG_TIME_FORMAT,DEMO_LOGS)
    print ('     ✅ DONE"')



def createIncidentFan():
    print ('    --------------------------------------------------------------------------------')
    print ('     🚀 Running Simulator - ACME Fan')
    print ('    --------------------------------------------------------------------------------')


    print ('         🚀 Simulating Events Fan')
    injectEventsFan(DATALAYER_ROUTE,DATALAYER_USER,DATALAYER_PWD)

    print ('         🚀 Simulating Metrics Fan Temp')
    injectMetricsFanTemp(METRIC_ROUTE,METRIC_TOKEN)
    time.sleep(3)

    print ('     ✅ DONE"')


def createIncidentNet():
    print ('    --------------------------------------------------------------------------------')
    print ('     🚀 Running Simulator - SockShop Network')
    print ('    --------------------------------------------------------------------------------')
    stream = os.popen('oc patch service catalogue -n sock-shop --patch "{\\"spec\\": {\\"selector\\": {\\"name\\": \\"catalog-outage\\"}}}"')
    RESULT = stream.read().strip()
    print(str(RESULT))


    print ('         🚀 Simulating Events')
    injectEventsNet(DATALAYER_ROUTE,DATALAYER_USER,DATALAYER_PWD)

    print ('         🚀 Simulating Metrics')
    injectMetricsNet(METRIC_ROUTE,METRIC_TOKEN)

    print ('     ✅ DONE"')


def setInProgressID(incident_id):
    print ('    --------------------------------------------------------------------------------')
    print ('     🚀 Updating Incident')
    print ('    --------------------------------------------------------------------------------')

    print ('         🚀 Updating Incident to "inProgress" - '+incident_id)
    updateStoriesID(DATALAYER_ROUTE,DATALAYER_USER,DATALAYER_PWD,"inProgress",incident_id)
    print ('     ✅ DONE"')


def setResolvedID(incident_id):
    print ('    --------------------------------------------------------------------------------')
    print ('     🚀 Updating Incident')
    print ('    --------------------------------------------------------------------------------')
    stream = os.popen('oc set env deployment ratings -n robot-shop PDO_URL-')
    RESULT = stream.read().strip()
    print(str(RESULT))
    stream = os.popen('oc set env deployment load -n robot-shop ERROR=0')
    RESULT = stream.read().strip()
    print(str(RESULT))
    stream = os.popen('oc patch service catalogue -n sock-shop --patch "{\\"spec\\": {\\"selector\\": {\\"name\\": \\"catalog\\"}}}"')
    RESULT = stream.read().strip()
    print(str(RESULT))

    print ('         🚀 Updating Incident to "resolved" - '+incident_id)
    updateStoriesID(DATALAYER_ROUTE,DATALAYER_USER,DATALAYER_PWD,"resolved",incident_id)
    print ('     ✅ DONE"')



def setInProgress():
    print ('    --------------------------------------------------------------------------------')
    print ('     🚀 Updating Stories')
    print ('    --------------------------------------------------------------------------------')

    print ('         🚀 Updating Stories to "inProgress"')
    updateStories(DATALAYER_ROUTE,DATALAYER_USER,DATALAYER_PWD,"inProgress")
    print ('     ✅ DONE"')



def setResolved():
    print ('    --------------------------------------------------------------------------------')
    print ('     🚀 Updating Stories')
    print ('    --------------------------------------------------------------------------------')
    stream = os.popen('oc set env deployment ratings -n robot-shop PDO_URL-')
    RESULT = stream.read().strip()
    print(str(RESULT))
    stream = os.popen('oc set env deployment load -n robot-shop ERROR=0')
    RESULT = stream.read().strip()
    print(str(RESULT))

    stream = os.popen('oc patch service catalogue -n sock-shop --patch "{\\"spec\\": {\\"selector\\": {\\"name\\": \\"catalog-outage\\"}}}"')
    RESULT = stream.read().strip()
    print(str(RESULT))


    print ('         🚀 Updating Stories to "resolved"')
    updateStories(DATALAYER_ROUTE,DATALAYER_USER,DATALAYER_PWD,"resolved")
    print ('     ✅ DONE"')
 

    
def setClosed():
    print ('    --------------------------------------------------------------------------------')
    print ('     🚀 Updating Stories')
    print ('    --------------------------------------------------------------------------------')
    stream = os.popen('oc set env deployment ratings -n robot-shop PDO_URL-')
    RESULT = stream.read().strip()
    print(str(RESULT))
    stream = os.popen('oc set env deployment load -n robot-shop ERROR=0')
    RESULT = stream.read().strip()
    print(str(RESULT))

    print ('     🚀 Updating Stories and Alerts to "closed"')
    updateAlerts(DATALAYER_ROUTE,DATALAYER_USER,DATALAYER_PWD,"closed")
    updateStories(DATALAYER_ROUTE,DATALAYER_USER,DATALAYER_PWD,"closed")
    print ('     ✅ DONE"')





# --------------------------------------------------------------------------------
# --------------------------------------------------------------------------------
# IN BOT
# --------------------------------------------------------------------------------
# --------------------------------------------------------------------------------

class IncidentBot(commands.Bot):
    def __init__(self):
        intents = discord.Intents.default()
        intents.message_content = True
        super().__init__(command_prefix=commands.when_mentioned_or('/'), intents=intents)



    # --------------------------------------------------------------------------------
    # HANDLE MESSAGES
    # --------------------------------------------------------------------------------
    async def on_message(self, message):
        if message.author.id == self.user.id:
            return

        if message.content.startswith(DISCORD_BOT_PREFIX+'guess'):
            await message.channel.send('Guess a number between 1 and 10.')

        if message.content.startswith(DISCORD_BOT_PREFIX+DISCORD_BOT_NAME):
            myMessage=message.content
            myArguments=myMessage.split()

            # --------------------------------------------------------------------------------
            # EMPTY COMMAND
            if len(myArguments) < 2:
                print(" 📥 Command: EMPTY")
                await message.channel.send('--------------------------------------------------')
                await message.channel.send('**🤖 Welcome to the Watson AIOps Discord Bot for the "'+INSTANCE_NAME+'" Environment**')
                await message.channel.send('--------------------------------------------------')
                await message.channel.send('**🚀 Demo Assets**')
                view = AIOPSLink(DENO_UI_ROUTE,'Demo Dashboard')
                await message.channel.send(view=view)
                view = AIOPSLink(CPD_ROUTE,'CP4WAIOps')
                await message.channel.send(view=view)
                if INSTANA_ROUTE != '':
                    view = AIOPSLink(INSTANA_ROUTE,'Instana')
                    await message.channel.send(view=view)
                if TURBO_ROUTE != '':
                    view = AIOPSLink(TURBO_ROUTE,'Turbonomic')
                    await message.channel.send(view=view)

                await message.channel.send('--------------------------------------------------')
                await message.channel.send('**🚀 WAIOps Incidents**')
                view = StoriesActions()
                await message.channel.send(view=view)
                view = IncidentActions()
                await message.channel.send(view=view)

                
                await message.channel.send('--------------------------------------------------')
                await message.channel.send('**🚀 Instana Incidents**')
                view = IncidentInstana()
                await message.channel.send(view=view)


                await message.channel.send('--------------------------------------------------')
                await message.channel.send('**🚀 Open Stories**')
                await message.channel.send('--------------------------------------------------')
                actStories=getStories(DATALAYER_ROUTE,DATALAYER_USER,DATALAYER_PWD, CPD_ROUTE)
                for currentIncident in actStories['stories']:
                    outputString=""
                    incident_id=currentIncident["id"]
                    incidentState=currentIncident["state"]
                    if incidentState=="assignedToIndividual":
                        stateString="🔵 Assigned To Individual"
                    elif incidentState=="inProgress":
                        stateString="🟢 In Progress"
                    elif incidentState=="onHold":
                        stateString="🟠 On Hold"
                    elif incidentState=="resolved":
                        stateString="🔴 Resolved"
                    elif incidentState=="closed":
                        stateString="❌ Closed"
                    else:
                        stateString=state
                    title=currentIncident["title"]
                    priority=currentIncident["priority"]
                    owner=currentIncident["owner"]
                    url='https://'+CPD_ROUTE+'/aiops/cfd95b7e-3bc7-4006-a4a8-a73a79c71255/resolution-hub/stories/all/'+incident_id+'/overview'
                    #debug(currentIncident)
                    # print('     ✅ Name: '+title)
                    # print('     ✅ priority: '+str(priority))
                    # print('     ✅ owner: '+owner)

                    outputString=outputString+'\n\n📥 **'+title.strip()+'**\n   > Priority: '+str(priority)+'\n   > Owner: '+owner+'\n   > State: '+stateString+'\n\n' 
                    # print('     ✅ Incident: '+outputString)
                    # print('      ')
                    await message.channel.send(outputString)

                    # We create the view and assign it to a variable so we can wait for it later.
                    view = Incident(incident_id,url)
                    await message.channel.send(view=view)

                    view = IncidentActions(incident_id,url)
                    await message.channel.send(view=view)
                    await message.channel.send('--------------------------------------------------')
                await message.channel.send(' \ntype "'+DISCORD_BOT_PREFIX+DISCORD_BOT_NAME+' help" to get a list of all possible commands.')

            else:
                myArgument=myArguments[1]


                # --------------------------------------------------------------------------------
                # BOT COMMANDS
                # --------------------------------------------------------------------------------
                 # COMMAND BUTTONS

                if myArgument == "demo":
                    print(" 📥 Command: demo")
                    await message.channel.send('--------------------------------------------------')
                    await message.channel.send('**🚀 Demo Assets**')
                    view = AIOPSLink(DENO_UI_ROUTE,'Demo Dashboard')
                    await message.channel.send(view=view)
                    await message.channel.send('> Password: '+TOKEN)

                    view = AIOPSLink(CPD_ROUTE,'CP4WAIOps')
                    await message.channel.send(view=view)
                    await message.channel.send('> User    : demo')
                    await message.channel.send('> Password: '+TOKEN)

                    view = AIOPSLink(INSTANA_ROUTE,'Instana')
                    await message.channel.send(view=view)
                    await message.channel.send('> User    : admin@instana.local')
                    await message.channel.send('> Password: '+TOKEN)

                    view = AIOPSLink(TURBO_ROUTE,'Turbonomic')
                    await message.channel.send(view=view)
                    await message.channel.send('> User    : administrator')
                    await message.channel.send('> Password: '+TOKEN)

                elif myArgument == "waiops":
                    print(" 📥 Command: waiops")
                    await message.channel.send('--------------------------------------------------')
                    await message.channel.send('**🚀 WAIOps Incidents**')
                    view = StoriesActions()
                    await message.channel.send(view=view)
                    view = IncidentActions()
                    await message.channel.send(view=view)


                elif myArgument == "instana":
                    print(" 📥 Command: instana")
                    await message.channel.send('--------------------------------------------------')
                    await message.channel.send('**🚀 Instana Incidents**')
                    view = IncidentInstana()
                    await message.channel.send(view=view)
    
                
                # CREATE INCIDENT MEMORY LEAK
                elif myArgument == "incident":
                    print(" 📥 Command: incident")
                    await message.channel.send('🚀 '+INSTANCE_NAME+' Simulating Memory Incident')
                    print('    🟠 Create THREADS')
                    threadRun = Thread(target=createIncidentMem)
                    print('    🟠 Start THREADS')
                    threadRun.start()
                    await message.channel.send('✅ Simulation is running in the background')


                # --------------------------------------------------------------------------------
                # CREATE INCIDENT MEMORY LEAK
                elif myArgument == "incidentMem":
                    print(" 📥 Command: incidentMem")
                    await message.channel.send('🚀 '+INSTANCE_NAME+' Simulating Memory Incident')
                    print('    🟠 Create THREADS')
                    threadRun = Thread(target=createIncidentMem)
                    print('    🟠 Start THREADS')
                    threadRun.start()
                    await message.channel.send('✅ Simulation is running in the background')


                # --------------------------------------------------------------------------------
                # CREATE INCIDENT FAN FAILURE
                elif myArgument == "incidentFan":
                    print(" 📥 Command: incidentFan")
                    await message.channel.send('🚀 '+INSTANCE_NAME+' Simulating Fan Incident')
                    print('    🟠 Create THREADS')
                    threadRun = Thread(target=createIncidentFan)
                    print('    🟠 Start THREADS')
                    threadRun.start()
                    await message.channel.send('✅ Simulation is running in the background')


                # --------------------------------------------------------------------------------
                 # SET STORIES TO InProgress
                elif myArgument == "progress":
                    print(" 📥 Command: progress")
                    await message.channel.send('🚀 '+INSTANCE_NAME+' Set Stories to InProgress')
                    print('    🟠 Create THREADS')
                    threadRun = Thread(target=setInProgress)
                    print('    🟠 Start THREADS')
                    threadRun.start()


                # --------------------------------------------------------------------------------
                 # SET STORIES TO Resolved
                elif myArgument == "resolve":
                    print(" 📥 Command: resolve")
                    await message.channel.send('🚀 '+INSTANCE_NAME+' Set Stories to Resolved')
                    print('    🟠 Create THREADS')
                    threadRun = Thread(target=setResolved)
                    print('    🟠 Start THREADS')
                    threadRun.start()

                # --------------------------------------------------------------------------------
                 # SET STORIES TO Resolved
                elif myArgument == "close":
                    print(" 📥 Command: close")
                    await message.channel.send('🚀 '+INSTANCE_NAME+' Set Stories to Resolved')
                    print('    🟠 Create THREADS')
                    threadRun = Thread(target=setResolved)
                    print('    🟠 Start THREADS')
                    threadRun.start()


                # --------------------------------------------------------------------------------
                 # SET STORIES TO Resolved
                elif myArgument == "reset":
                    print(" 📥 Command: reset")
                    await message.channel.send('🚀 '+INSTANCE_NAME+' Reset Demo Environment')
                    print('    🟠 Create THREADS')
                    threadRun = Thread(target=setResolved)
                    print('    🟠 Start THREADS')
                    threadRun.start()
                    await message.channel.send('ℹ️ Give the environment 5 Minutes to clean up')


                # --------------------------------------------------------------------------------
                # WELCOME MESSAGE
                elif (myArgument == "welcome") or (myArgument == "help"):
                    print(" 📥 Command: "+myArgument)
                    await message.channel.send('**🚀 Available Commands**')
                    await message.channel.send('   🛠️ Demo Assets:')
                    await message.channel.send('      '+DISCORD_BOT_PREFIX+DISCORD_BOT_NAME+' **demo**        :  Prints links and logins to demo assets')
                    await message.channel.send('   🛠️ Command Buttons:')
                    await message.channel.send('      '+DISCORD_BOT_PREFIX+DISCORD_BOT_NAME+' **waiops**      :  Prints buttons to create or mitigate WAIOPS incidents')
                    await message.channel.send('      '+DISCORD_BOT_PREFIX+DISCORD_BOT_NAME+' **instana**     :  Prints buttons to create or mitigate Instana incidents')
                    await message.channel.send('   🛠️ Stories:')
                    await message.channel.send('      '+DISCORD_BOT_PREFIX+DISCORD_BOT_NAME+' **stories**     :  List all Stories')
                    await message.channel.send('   🛠️ Simulation:')
                    await message.channel.send('      '+DISCORD_BOT_PREFIX+DISCORD_BOT_NAME+' **incident**    :  Simulates a Memory leak in RobotShop')
                    await message.channel.send('      '+DISCORD_BOT_PREFIX+DISCORD_BOT_NAME+' **incidentMem** :  Simulates a Memory leak in RobotShop')
                    await message.channel.send('      '+DISCORD_BOT_PREFIX+DISCORD_BOT_NAME+' **incidentFan** :  Simulates a Fan problem in RobotShop')
                    await message.channel.send('   🛠️ Modify Stories:')
                    await message.channel.send('      '+DISCORD_BOT_PREFIX+DISCORD_BOT_NAME+' **progress**    :  Set all Stories to InProgress')
                    await message.channel.send('      '+DISCORD_BOT_PREFIX+DISCORD_BOT_NAME+' **resolve **    :  Set all Stories to Resolved')
                    await message.channel.send('      '+DISCORD_BOT_PREFIX+DISCORD_BOT_NAME+' **close**       :  Set all Stories to Resolved')
                    await message.channel.send('      '+DISCORD_BOT_PREFIX+DISCORD_BOT_NAME+' **reset**       :  Set all Stories to Resolved')




                # --------------------------------------------------------------------------------
                # GET STORIES
                elif myArgument == "stories":
                    print(" 📥 Command: stories")
                    await message.channel.send('**🚀 '+INSTANCE_NAME+' Open Stories**')
                    await message.channel.send('--------------------------------------------------')
                    actStories=getStories(DATALAYER_ROUTE,DATALAYER_USER,DATALAYER_PWD, CPD_ROUTE)
                    for currentIncident in actStories['stories']:
                        outputString=""
                        incident_id=currentIncident["id"]
                        incidentState=currentIncident["state"]
                        if incidentState=="assignedToIndividual":
                            stateString="🔵 Assigned To Individual"
                        elif incidentState=="inProgress":
                            stateString="🟢 In Progress"
                        elif incidentState=="onHold":
                            stateString="🟠 On Hold"
                        elif incidentState=="resolved":
                            stateString="🔴 Resolved"
                        elif incidentState=="closed":
                            stateString="❌ Closed"
                        else:
                            stateString=state
                        title=currentIncident["title"]
                        priority=currentIncident["priority"]
                        owner=currentIncident["owner"]
                        url='https://'+CPD_ROUTE+'/aiops/cfd95b7e-3bc7-4006-a4a8-a73a79c71255/resolution-hub/stories/all/'+incident_id+'/overview'
                        #debug(currentIncident)
                        # print('     ✅ Name: '+title)
                        # print('     ✅ priority: '+str(priority))
                        # print('     ✅ owner: '+owner)

                        outputString=outputString+'\n\n📥 **'+title.strip()+'**\n   > Priority: '+str(priority)+'\n   > Owner: '+owner+'\n   > State: '+stateString+'\n\n' 
                        # print('     ✅ Incident: '+outputString)
                        # print('      ')
                        await message.channel.send(outputString)

                        # We create the view and assign it to a variable so we can wait for it later.
                        view = Incident(incident_id,url)
                        await message.channel.send(view=view)

                        view = IncidentActions(incident_id,url)
                        await message.channel.send(view=view)
                        await message.channel.send('--------------------------------------------------')


                    #await message.channel.send('✅ DONE')





                # --------------------------------------------------------------------------------
                # UNKNOWN COMMAND
                else:
                    print(" ❗Unknown Command")
                    await message.channel.send('🟠 Unknown Command '+myArgument+'. Type "'+DISCORD_BOT_PREFIX+DISCORD_BOT_NAME+' welcome" to get a list of available commands.')




    # --------------------------------------------------------------------------------
    # HANDLE REACTIONS
    # --------------------------------------------------------------------------------
    async def on_raw_reaction_add(self, payload: discord.RawReactionActionEvent):
        """Gives a role based on a reaction emoji."""
        # Make sure that the message the user is reacting to is the one we care about.
        print('A:'+str(payload))
        print('B:'+str(self.fetch_user))






# --------------------------------------------------------------------------------
# --------------------------------------------------------------------------------
# CUSTOM VIEWS
# --------------------------------------------------------------------------------
# --------------------------------------------------------------------------------
class AIOPSLink(discord.ui.View):
    def __init__(self, URL: str, label: str):
        super().__init__()
        # print ("label "+label)
        # print ("URL "+URL)
        self.add_item(discord.ui.Button(label=label, style=discord.ButtonStyle.green, url='https://'+URL))


class Incident(discord.ui.View):
    def __init__(self, incidentID: str, incidentURL: str):
        super().__init__()
        # print ("incidentID"+incidentID)
        # print ("incidentURL"+incidentURL)

        self.add_item(discord.ui.Button(label='Open Incident: ', style=discord.ButtonStyle.green, url=incidentURL))


class IncidentActions(discord.ui.View):
    def __init__(self, incidentID: str, incidentURL: str):
        super().__init__(timeout=None)
        self.currentIncidentID=incidentID
        self.add_buttons(self.currentIncidentID)

    def add_buttons(self,currentIncidentID):
            button_green = discord.ui.Button(label='Acknowledge Incident', style=discord.ButtonStyle.green)
            button_red = discord.ui.Button(label='Resolve Incident', style=discord.ButtonStyle.red)

            async def fbutton_green(interaction: discord.Interaction):
                await interaction.response.send_message('🟠 Acknowledge Incident', ephemeral=True)
                print('AWAIT'+currentIncidentID)
                setInProgressID(currentIncidentID)

            async def fbutton_red(interaction: discord.Interaction):
                print(self.currentIncidentID)
                await interaction.response.send_message('🔴 Resolve Incident', ephemeral=True)
                print('AWAIT'+currentIncidentID)
                setResolvedID(currentIncidentID)

            button_green.callback = fbutton_green
            self.add_item(button_green)
            button_red.callback = fbutton_red
            self.add_item(button_red)


class StoriesActions(discord.ui.View):
    def __init__(self):
        super().__init__()

    @discord.ui.button(label='Acknowledge all Stories', style=discord.ButtonStyle.green, custom_id='persistent_view:ackall')
    async def green(self, interaction: discord.Interaction, button: discord.ui.Button):
        await interaction.response.send_message('🟠 Acknowledged all Stories', ephemeral=True)
        setInProgress()

    @discord.ui.button(label='Resolve all Stories', style=discord.ButtonStyle.green, custom_id='persistent_view:closeall')
    async def red(self, interaction: discord.Interaction, button: discord.ui.Button):
        await interaction.response.send_message('🔴 Resolved all Stories', ephemeral=True)
        setResolved()


class IncidentActions(discord.ui.View):
    def __init__(self):
        super().__init__()

    @discord.ui.button(label='RobotShop - Memory Leak', style=discord.ButtonStyle.red, custom_id='persistent_view:mem')
    async def green(self, interaction: discord.Interaction, button: discord.ui.Button):
        await interaction.response.send_message('🚀 Simulating Memory Incident', ephemeral=True)
        print('    🟠 Create THREADS')
        threadRun = Thread(target=createIncidentMem)
        print('    🟠 Start THREADS')
        threadRun.start()

    @discord.ui.button(label='SockShop - Network Failure', style=discord.ButtonStyle.red, custom_id='persistent_view:net')
    async def orange(self, interaction: discord.Interaction, button: discord.ui.Button):
        await interaction.response.send_message('🚀 Simulating Network Incident', ephemeral=True)
        print('    🟠 Create THREADS')
        threadRun = Thread(target=createIncidentNet)
        print('    🟠 Start THREADS')
        threadRun.start()


    @discord.ui.button(label='ACME - Fan Failure', style=discord.ButtonStyle.red, custom_id='persistent_view:fan')
    async def red(self, interaction: discord.Interaction, button: discord.ui.Button):
        await interaction.response.send_message('🚀 Simulating Fan Incident', ephemeral=True)
        print('    🟠 Create THREADS')
        threadRun = Thread(target=createIncidentFan)
        print('    🟠 Start THREADS')
        threadRun.start()


class IncidentInstana(discord.ui.View):
    def __init__(self):
        super().__init__()

    @discord.ui.button(label='Resolve Incident - Instana', style=discord.ButtonStyle.green, custom_id='persistent_view:instr')
    async def green(self, interaction: discord.Interaction, button: discord.ui.Button):
        await interaction.response.send_message('🚀 Mitigating Incident - Instana', ephemeral=True)
        print('    🟠 Create THREADS')
        threadRun = Thread(target=resolveIncidentInstana)
        print('    🟠 Start THREADS')
        threadRun.start()


    @discord.ui.button(label='Create Incident - Instana', style=discord.ButtonStyle.red, custom_id='persistent_view:instc')
    async def red(self, interaction: discord.Interaction, button: discord.ui.Button):
        await interaction.response.send_message('🚀 Simulating Incident - Instana', ephemeral=True)
        print('    🟠 Create THREADS')
        threadRun = Thread(target=createIncidentInstana)
        print('    🟠 Start THREADS')
        threadRun.start()



# --------------------------------------------------------------------------------
# --------------------------------------------------------------------------------
# RUN THIS PUPPY
# --------------------------------------------------------------------------------
# --------------------------------------------------------------------------------
bot = IncidentBot()


if ACTIVE=="True": 
    if DISCORD_BOT_TOKEN=="CHANGEME": 
        print ('--------------------------------------------------------------------------------')
        print (' ❗ Bot Token not defined!!!')
        print ('--------------------------------------------------------------------------------')
    else:
        bot.run(DISCORD_BOT_TOKEN)
else:
    while True:
        print ('--------------------------------------------------------------------------------')
        print (' ❗ Bot is DISABLED')
        print ('--------------------------------------------------------------------------------')
        time.sleep(15)


print ('')
print ('')
print ('')
print ('--------------------------------------------------------------------------------')
print (' ✅ Bot is DONE')
print ('--------------------------------------------------------------------------------')
print ('')
print ('')




