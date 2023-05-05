import requests
import json
#from sendincident-discord import *
#from sendincident-pagerduty import *
#from sendincident_pushover import *
import datetime
import sqlite3
import os

DEBUG_ME=os.environ.get('DEBUG_ME',"False")

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# DYNAMICALLY LOADING THE PROVIDER MODULE
# ----------------------------------------------------------------------------------------------------------------------------------------------------
PROVIDER_NAME=os.environ.get('PROVIDER_NAME','NONE')
import importlib
modulename='sendincident_'+str(PROVIDER_NAME).lower()
print ('---------------------------------------------------------------------------------------------')
print ('📛 Using Provider Module: '+modulename)
send_module = importlib.import_module(modulename)
send_module.testModuleLoad()
print('')
print('')
print('')
print('')


# ----------------------------------------------------------------------------------------------------------------------------------------------------
# GENERIC PROCESS THE INCIDENT
# ----------------------------------------------------------------------------------------------------------------------------------------------------
def processIncident(currentIncident, DATALAYER_USER, DATALAYER_PWD, DATALAYER_ROUTE, conn, incident_id, message_hash):
    print('')
    print ('    ---------------------------------------------------------------------------------------------')
    print ('     📛 Processing Incident: '+currentIncident['title'])


    messageID=send_module.sendIncidentToProvider(currentIncident, DATALAYER_USER, DATALAYER_PWD, DATALAYER_ROUTE)
    debug('messageID:'+messageID)
    
    timestamp = datetime.datetime.now()
    insertIDIntoDB(conn, incident_id, messageID, message_hash)
    print ('     ✅ Processing Incident, DONE...'+str(timestamp))
    print ('    ---------------------------------------------------------------------------------------------')
    print('')
    print('')



# ----------------------------------------------------------------------------------------------------------------------------------------------------
# GENERIC UPDATE THE INCIDENT
# ----------------------------------------------------------------------------------------------------------------------------------------------------
def updateIncident(currentIncident, DATALAYER_USER, DATALAYER_PWD, DATALAYER_ROUTE, messageID):
    print('')
    print ('    ---------------------------------------------------------------------------------------------')
    print ('     📛 Updating Incident: '+currentIncident['title'])


    messageID=send_module.updateIncidentToProvider(currentIncident, DATALAYER_USER, DATALAYER_PWD, DATALAYER_ROUTE, messageID)
    debug('messageID:'+messageID)

    timestamp = datetime.datetime.now()
    print ('     ✅ Processing Incident, DONE...'+str(timestamp))
    print ('    ---------------------------------------------------------------------------------------------')
    print('')
    print('')


# ----------------------------------------------------------------------------------------------------------------------------------------------------
# GENERIC RESOLVE THE INCIDENT
# ----------------------------------------------------------------------------------------------------------------------------------------------------
def closeIncident(conn, incident_id, DATALAYER_USER, DATALAYER_PWD, DATALAYER_ROUTE):
    debug('         🚀 closeIncident: '+incident_id)
    cursor = conn.execute("SELECT provider_id from INCIDENTS where ID='"+str(incident_id)+"'")
    provider_id = cursor.fetchone()
    debug('PROVIDER MESSAGE ID:'+provider_id[0])
    
    send_module.resolveIncidentToProvider(incident_id, DATALAYER_USER, DATALAYER_PWD, DATALAYER_ROUTE, provider_id[0])

    cursor = conn.execute("DELETE FROM INCIDENTS where ID='"+str(incident_id)+"'")
    conn.commit()


# ----------------------------------------------------------------------------------------------------------------------------------------------------
# TOOLS
# ----------------------------------------------------------------------------------------------------------------------------------------------------
def debug(text):
    if DEBUG_ME=="True":
        print(text)

def printSameLine(text):
    print('test', end='text')

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# LOCAL DB
# ----------------------------------------------------------------------------------------------------------------------------------------------------
def insertIDIntoDB(conn, incident_id, provider_id, message_hash):
    debug('         🚀 insertIDIntoDB: '+str(incident_id))
    debug('                            '+str(provider_id))
    try:
        conn.execute("INSERT INTO INCIDENTS (ID, MESSAGE_HASH, provider_id) \
            VALUES ('"+str(incident_id)+"', '"+str(message_hash)+"', '"+str(provider_id)+"')");
        conn.commit()
    except sqlite3.IntegrityError as e:
        # handle ConnectionError the exception
        print('        ℹ️ ID Already exists: '+str(e))



def checkIDExistsDB(conn, incident_id):
    debug('         🚀 checkIDExistsDB: '+incident_id)
    cursor = conn.execute("SELECT count(id) from INCIDENTS where ID='"+str(incident_id)+"'")
    count = cursor.fetchone()
    debug ("            📥 checkIDExistsDB: "+str(count[0]))
    debug ("")
    return count[0]


def getMessageIdDB(conn, incident_id):
    debug('         🚀 getMessageIdDB: '+incident_id)
    cursor = conn.execute("SELECT provider_id from INCIDENTS where ID='"+str(incident_id)+"'")
    provider_id = cursor.fetchone()
    debug ("            📥 needsUpdate: "+str(provider_id[0]))
    return provider_id[0]


def needsUpdate(conn, incident_id, messageHash):
    debug('         🚀 needsUpdate: '+incident_id)
    cursor = conn.execute("SELECT MESSAGE_HASH from INCIDENTS where ID='"+str(incident_id)+"'")
    updateMessageHash = cursor.fetchone()
    debug ("            🛠️ NEW messageHash: "+str(messageHash))
    debug ("            🛠️ OLD messageHash: "+str(updateMessageHash[0]))

    if updateMessageHash[0] != messageHash:
        debug ("            ❗❗HASHES ARE DIFFERENT - UPDATE INCIDENT")
        cursor = conn.execute("UPDATE INCIDENTS SET MESSAGE_HASH='"+str(messageHash)+"'where ID='"+str(incident_id)+"'")
        conn.commit()
        updateNeeded=1
    else:
        updateNeeded=0

    debug ("            📥 needsUpdate: "+str(updateNeeded))
    debug ("")
    return updateNeeded


