import requests
from requests.auth import HTTPBasicAuth
import json
import datetime
import random
import os


# ----------------------------------------------------------------------------------------------------------------------------------------------------
# CREATE ENTITY
# ----------------------------------------------------------------------------------------------------------------------------------------------------
def writeEntity(topology_file, name, uniqueId,matchTokens,tags,entityType ):
    entityString='V:{"_operation":"InsertReplace","uniqueId":"'+uniqueId+'","mergeTokens":["'+name+'-turbonomic-topology"],"matchTokens":['+matchTokens+'],"tags":['+tags+'],"name":"'+name+'","entityTypes":["'+entityType+'"]}\n'
    topology_file.write(entityString)


# ----------------------------------------------------------------------------------------------------------------------------------------------------
# CREATE LINK
# ----------------------------------------------------------------------------------------------------------------------------------------------------
def writeLink(topology_file, fromUniqueId, toUniqueId, edgeType ):
    entityString='E:{"_toUniqueId":"'+toUniqueId+'","_edgeType":"'+edgeType+'","_fromUniqueId":"'+fromUniqueId+'"}\n'
    topology_file.write(entityString)


# ----------------------------------------------------------------------------------------------------------------------------------------------------
# CREATE LINK
# ----------------------------------------------------------------------------------------------------------------------------------------------------
def translateType(className):
    className=className.lower()
    if className == "virtualmachine":
        newClassName = "vm"
    elif className == "workloadcontroller":
        newClassName = "deployment"
    elif className == "containerpod":
        newClassName = "pod"
    elif className == "persistentvolume":
        newClassName = "volume"
    elif className == "virtualvolume":
        newClassName = "volume"
    else:
        newClassName=className
    return newClassName



# ----------------------------------------------------------------------------------------------------------------------------------------------------
# CREATE ENTITY
# ----------------------------------------------------------------------------------------------------------------------------------------------------
def parseEntity(entity_name, TURBO_URL, topology_file):
    entityList=[]
    cursor=0
    TURBO_ENTITIES_JSON =[]
    while True:
        stream = os.popen("curl -XGET -s -k -b /tmp/cookies -H 'accept: application/json' 'https://"+TURBO_URL+"/api/v3/search?types="+entity_name+"&cursor="+str(cursor)+"&limit=1000&order_by=NAME&ascending=true'")
        TURBO_ENTITIES_PAGE = stream.read().strip()
        TURBO_ENTITIES_PAGE_JSON=json.loads(TURBO_ENTITIES_PAGE)
        TURBO_ENTITIES_JSON=TURBO_ENTITIES_JSON + TURBO_ENTITIES_PAGE_JSON
        cursor=cursor+500
        if len(TURBO_ENTITIES_PAGE) < 3:
            break

    #TURBO_ENTITIES_JSON=json.loads(TURBO_ENTITIES)
    #print (str(TURBO_ENTITIES_JSON))
    jsonCount= len(TURBO_ENTITIES_JSON)
    print ("    📥  "+str(entity_name)+": "+str(jsonCount))


    for entity in TURBO_ENTITIES_JSON:
        #print ("         - "+entity["displayName"])
        #writeEntity(topology_file, name, uniqueId,matchTokens,tags,entityType )
        currentEntity=(entity["uuid"],entity["displayName"],entity["className"])
        if not currentEntity in entityList:
            writeEntity(topology_file, entity["displayName"], entity["uuid"],'"'+entity["displayName"]+'"','"TurbonomicTopology"', translateType(entity["className"]))
            entityList = entityList + [currentEntity]

    return entityList

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# CREATE Links
# ----------------------------------------------------------------------------------------------------------------------------------------------------
def parseDependencies(entity_name, TURBO_URL, topology_file, globalEntities):
    entityList=[]
    cursor=0
    TURBO_ENTITIES_JSON =[]
    print ("    🔗  Creating links for "+str(entity_name))

    while True:
        stream = os.popen("curl -XGET -s -k -b /tmp/cookies -H 'accept: application/json' 'https://"+TURBO_URL+"/api/v3/search?types="+entity_name+"&cursor="+str(cursor)+"&limit=1000&order_by=NAME&ascending=true'")
        TURBO_ENTITIES_PAGE = stream.read().strip()
        TURBO_ENTITIES_PAGE_JSON=json.loads(TURBO_ENTITIES_PAGE)
        TURBO_ENTITIES_JSON=TURBO_ENTITIES_JSON + TURBO_ENTITIES_PAGE_JSON
        cursor=cursor+500
        if len(TURBO_ENTITIES_PAGE) < 3:
            break

    #TURBO_ENTITIES_JSON=json.loads(TURBO_ENTITIES)
    #print (str(TURBO_ENTITIES_JSON))


    for entity in TURBO_ENTITIES_JSON:

        if "providers" in entity:
            for provider in entity["providers"]:
                currentEntity=(provider["uuid"],provider["displayName"],provider["className"])
                if not currentEntity in globalEntities:
                    entityList = entityList + [currentEntity]
                    print ("Provider not in Type list:"+str(currentEntity))
                    writeEntity(topology_file, provider["displayName"], provider["uuid"],'"'+provider["displayName"]+'"','"TurbonomicTopology"',translateType(provider["className"]))

                writeLink(topology_file, entity["uuid"], provider["uuid"], "uses" )
        if "consumers" in entity:
            for consumer in entity["consumers"]:
                #writeLink(topology_file, fromUniqueId, toUniqueId, edgeType )
                writeLink(topology_file, consumer["uuid"], entity["uuid"], "uses" )
                currentEntity=(consumer["uuid"],consumer["displayName"],consumer["className"])
                if not currentEntity in globalEntities:
                    entityList = entityList + [currentEntity]
                    print ("Consumer not in Type list:"+str(currentEntity))
                    writeEntity(topology_file, consumer["displayName"], consumer["uuid"],'"'+consumer["displayName"]+'"','"TurbonomicTopology"',translateType(consumer["className"]))
     

    return entityList