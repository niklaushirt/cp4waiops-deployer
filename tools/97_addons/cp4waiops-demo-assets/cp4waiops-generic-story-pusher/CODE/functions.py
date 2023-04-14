import requests
import json
#from sendstory-discord import *
#from sendstory-pagerduty import *
#from sendstory_pushover import *
import datetime
import sqlite3
import os

DEBUG_ME=os.environ.get('DEBUG_ME',"False")

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# DYNAMICALLY LOADING THE PROVIDER MODULE
# ----------------------------------------------------------------------------------------------------------------------------------------------------
PROVIDER_NAME=os.environ.get('PROVIDER_NAME','NONE')
import importlib
modulename='sendstory_'+str(PROVIDER_NAME).lower()
print ('---------------------------------------------------------------------------------------------')
print ('📛 Using Provider Module: '+modulename)
send_module = importlib.import_module(modulename)
send_module.testModuleLoad()
print('')
print('')
print('')
print('')


# ----------------------------------------------------------------------------------------------------------------------------------------------------
# GENERIC PROCESS THE STORY
# ----------------------------------------------------------------------------------------------------------------------------------------------------
def processStory(currentStory, DATALAYER_USER, DATALAYER_PWD, DATALAYER_ROUTE, conn, story_id, message_hash):
    print('')
    print ('    ---------------------------------------------------------------------------------------------')
    print ('     📛 Processing Story: '+currentStory['title'])


    messageID=send_module.sendStoryToProvider(currentStory, DATALAYER_USER, DATALAYER_PWD, DATALAYER_ROUTE)
    debug('messageID:'+messageID)
    
    timestamp = datetime.datetime.now()
    insertIDIntoDB(conn, story_id, messageID, message_hash)
    print ('     ✅ Processing Story, DONE...'+str(timestamp))
    print ('    ---------------------------------------------------------------------------------------------')
    print('')
    print('')



# ----------------------------------------------------------------------------------------------------------------------------------------------------
# GENERIC UPDATE THE STORY
# ----------------------------------------------------------------------------------------------------------------------------------------------------
def updateStory(currentStory, DATALAYER_USER, DATALAYER_PWD, DATALAYER_ROUTE, messageID):
    print('')
    print ('    ---------------------------------------------------------------------------------------------')
    print ('     📛 Updating Story: '+currentStory['title'])


    messageID=send_module.updateStoryToProvider(currentStory, DATALAYER_USER, DATALAYER_PWD, DATALAYER_ROUTE, messageID)
    debug('messageID:'+messageID)

    timestamp = datetime.datetime.now()
    print ('     ✅ Processing Story, DONE...'+str(timestamp))
    print ('    ---------------------------------------------------------------------------------------------')
    print('')
    print('')


# ----------------------------------------------------------------------------------------------------------------------------------------------------
# GENERIC RESOLVE THE STORY
# ----------------------------------------------------------------------------------------------------------------------------------------------------
def closeStory(conn, story_id, DATALAYER_USER, DATALAYER_PWD, DATALAYER_ROUTE):
    debug('         🚀 closeStory: '+story_id)
    cursor = conn.execute("SELECT provider_id from STORIES where ID='"+str(story_id)+"'")
    provider_id = cursor.fetchone()
    debug('PROVIDER MESSAGE ID:'+provider_id[0])
    
    send_module.resolveStoryToProvider(story_id, DATALAYER_USER, DATALAYER_PWD, DATALAYER_ROUTE, provider_id[0])

    cursor = conn.execute("DELETE FROM STORIES where ID='"+str(story_id)+"'")
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
def insertIDIntoDB(conn, story_id, provider_id, message_hash):
    debug('         🚀 insertIDIntoDB: '+str(story_id))
    debug('                            '+str(provider_id))
    try:
        conn.execute("INSERT INTO STORIES (ID, MESSAGE_HASH, provider_id) \
            VALUES ('"+str(story_id)+"', '"+str(message_hash)+"', '"+str(provider_id)+"')");
        conn.commit()
    except sqlite3.IntegrityError as e:
        # handle ConnectionError the exception
        print('        ℹ️ ID Already exists: '+str(e))



def checkIDExistsDB(conn, story_id):
    debug('         🚀 checkIDExistsDB: '+story_id)
    cursor = conn.execute("SELECT count(id) from STORIES where ID='"+str(story_id)+"'")
    count = cursor.fetchone()
    debug ("            📥 checkIDExistsDB: "+str(count[0]))
    debug ("")
    return count[0]


def getMessageIdDB(conn, story_id):
    debug('         🚀 getMessageIdDB: '+story_id)
    cursor = conn.execute("SELECT provider_id from STORIES where ID='"+str(story_id)+"'")
    provider_id = cursor.fetchone()
    debug ("            📥 needsUpdate: "+str(provider_id[0]))
    return provider_id[0]


def needsUpdate(conn, story_id, messageHash):
    debug('         🚀 needsUpdate: '+story_id)
    cursor = conn.execute("SELECT MESSAGE_HASH from STORIES where ID='"+str(story_id)+"'")
    updateMessageHash = cursor.fetchone()
    debug ("            🛠️ NEW messageHash: "+str(messageHash))
    debug ("            🛠️ OLD messageHash: "+str(updateMessageHash[0]))

    if updateMessageHash[0] != messageHash:
        debug ("            ❗❗HASHES ARE DIFFERENT - UPDATE STORY")
        cursor = conn.execute("UPDATE STORIES SET MESSAGE_HASH='"+str(messageHash)+"'where ID='"+str(story_id)+"'")
        conn.commit()
        updateNeeded=1
    else:
        updateNeeded=0

    debug ("            📥 needsUpdate: "+str(updateNeeded))
    debug ("")
    return updateNeeded


