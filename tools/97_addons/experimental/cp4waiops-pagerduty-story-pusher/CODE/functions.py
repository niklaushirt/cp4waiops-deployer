import requests
import json
from sendstory import *
import datetime
import sqlite3
import os

DEBUG_ME=os.environ.get('DEBUG_ME',"False")


def processIncident(currentIncident, DATALAYER_USER, DATALAYER_PWD, DATALAYER_ROUTE, conn, incident_id, message_hash):
    print('')
    print ('    ---------------------------------------------------------------------------------------------')
    print ('     📛 Processing Incident: '+currentIncident['title'])


    if PAGERDUTY_URL!="not provided":
        messageID=sendPagerduty(currentIncident, DATALAYER_USER, DATALAYER_PWD, DATALAYER_ROUTE)

    timestamp = datetime.datetime.now()
    insertIDIntoDB(conn, incident_id, messageID, message_hash)
    print ('     ✅ Processing Incident, DONE...'+str(timestamp))
    print ('    ---------------------------------------------------------------------------------------------')
    print('')
    print('')




def updateIncident(currentIncident, DATALAYER_USER, DATALAYER_PWD, DATALAYER_ROUTE, messageID):
    print('')
    print ('    ---------------------------------------------------------------------------------------------')
    print ('     📛 Updating Incident: '+currentIncident['title'])


    if PAGERDUTY_URL!="not provided":
        messageID=updatePagerduty(currentIncident, DATALAYER_USER, DATALAYER_PWD, DATALAYER_ROUTE)

    timestamp = datetime.datetime.now()
    print ('     ✅ Processing Incident, DONE...'+str(timestamp))
    print ('    ---------------------------------------------------------------------------------------------')
    print('')
    print('')



def closeIncident(conn, incident_id):
    debug('         🚀 closeIncident: '+incident_id)
    cursor = conn.execute("SELECT DISCORD_ID from STORIES where ID='"+str(incident_id)+"'")
    discord_id = cursor.fetchone()
    debug('DISCORD ID:'+discord_id[0])
    if PAGERDUTY_URL!="not provided":
        resolvePagerduty(incident_id, DATALAYER_USER, DATALAYER_PWD, DATALAYER_ROUTE)

    cursor = conn.execute("DELETE FROM STORIES where ID='"+str(incident_id)+"'")
    conn.commit()



def debug(text):
    if DEBUG_ME=="True":
        print(text)

def printSameLine(text):
    print('test', end='text')


def insertIDIntoDB(conn, incident_id, discord_id, message_hash):
    debug('         🚀 insertIDIntoDB: '+str(incident_id))
    debug('                            '+str(discord_id))
    try:
        conn.execute("INSERT INTO STORIES (ID, MESSAGE_HASH, DISCORD_ID) \
            VALUES ('"+str(incident_id)+"', '"+str(message_hash)+"', '"+str(discord_id)+"')");
        conn.commit()
    except sqlite3.IntegrityError as e:
        # handle ConnectionError the exception
        print('        ℹ️ ID Already exists: '+str(e))



def checkIDExistsDB(conn, incident_id):
    debug('         🚀 checkIDExistsDB: '+incident_id)
    cursor = conn.execute("SELECT count(id) from STORIES where ID='"+str(incident_id)+"'")
    count = cursor.fetchone()
    debug ("            📥 checkIDExistsDB: "+str(count[0]))
    debug ("")
    return count[0]


def getMessageIdDB(conn, incident_id):
    debug('         🚀 getMessageIdDB: '+incident_id)
    cursor = conn.execute("SELECT DISCORD_ID from STORIES where ID='"+str(incident_id)+"'")
    discord_id = cursor.fetchone()
    debug ("            📥 needsUpdate: "+str(discord_id[0]))
    return discord_id[0]


def needsUpdate(conn, incident_id, messageHash):
    debug('         🚀 needsUpdate: '+incident_id)
    cursor = conn.execute("SELECT MESSAGE_HASH from STORIES where ID='"+str(incident_id)+"'")
    updateMessageHash = cursor.fetchone()
    debug ("            🛠️ NEW messageHash: "+str(messageHash))
    debug ("            🛠️ OLD messageHash: "+str(updateMessageHash[0]))

    if updateMessageHash[0] != messageHash:
        debug ("            ❗❗HASHES ARE DIFFERENT - UPDATE INCIDENT")
        cursor = conn.execute("UPDATE STORIES SET MESSAGE_HASH='"+str(messageHash)+"'where ID='"+str(incident_id)+"'")
        conn.commit()
        updateNeeded=1
    else:
        updateNeeded=0

    debug ("            📥 needsUpdate: "+str(updateNeeded))
    debug ("")
    return updateNeeded


