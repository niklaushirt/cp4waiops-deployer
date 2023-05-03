
import requests
from requests.auth import HTTPBasicAuth
import json
import datetime
import random
import os
import time
from functions import *



DEBUG_ME=os.environ.get('DEBUG_ME',"False")

ACTIVE=os.environ.get('ACTIVE',"False")

TURBO_PASSWORD=os.environ.get('TURBO_PASSWORD',"P4ssw0rd!")





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
print ('    🛰️  Turbo Topology for CP4WAIOPS CP4WAIOps')
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


topology_file = open("/tmp/topology.txt", "w")




print('     ❓ Turbonomic Login')
stream = os.popen("oc get route -n turbonomic nginx -o jsonpath={.spec.host}")
TURBO_URL = stream.read().strip()


stream = os.popen("curl -XPOST -s -k -c /tmp/cookies -H 'accept: application/json' 'https://"+TURBO_URL+"/api/v3/login?hateoas=true' -d 'username=administrator&password="+TURBO_PASSWORD+"'")
TURBO_LOGIN = stream.read().strip()
TURBO_LOGIN_JSON=json.loads(TURBO_LOGIN)
#print(actStories['stories'])
#print(actStories['stories'][0]['description'])

print ("       🌏 Turbonomic API URL: "+str(TURBO_URL))

print ("       🔐 Logged-in as:       "+str(TURBO_LOGIN_JSON["username"]))
print ('')
print ('')
print ('')


globalEntities=[]

entitiesToParse = ["VirtualMachine",
"AvailabilityZone",
"Region",
"DataCenter",
"Host",
"VirtualMachineCluster",
"VirtualDataCenter",
"WorkloadController",
"Container",
"ContainerPod",
"ContainerCluster",
"ContainerPod",
"ApplicationComponent",
"BusinessTransaction",
"BusinessApplication",
"VirtualVolume",
"Storage",
"ComputeTier",
"Namespace",
"StorageTier",
"DiskArray",
"PhysicalMachine",
"ContainerPlatformCluster",
"Service",
"ApplicationComponentSpec",
"VirtualMachineSpec"]


# ----------------------------------------------------------------------------------------------------------------------------------------------------
# Create Topology file for Entity Types
# ----------------------------------------------------------------------------------------------------------------------------------------------------

print ('-------------------------------------------------------------------------------------------------')
print (' 🚀 Get Entities')
for entityType in entitiesToParse:
    entities=parseEntity(entityType, TURBO_URL, topology_file)
    globalEntities=globalEntities+entities
    #print (globalEntities)
print ('')
print ('-------------------------------------------------------------------------------------------------')
print (' 🚀 Get Links')
for entityType in entitiesToParse:
    entities=parseDependencies(entityType, TURBO_URL, topology_file, globalEntities)










print ('-------------------------------------------------------------------------------------------------')
print (' 🚀 Waiting')
print ('-------------------------------------------------------------------------------------------------')

while True:
    if ACTIVE=="True": 
        print ('     🚀 Waiting')


        time.sleep(60)
    else:
        print ('     ❌ Inactive - Waiting 15 Seconds')
        time.sleep(15)



print ('')
print ('')
print ('')
print ('-------------------------------------------------------------------------------------------------')
print (' ✅ Pusher is DONE')
print ('-------------------------------------------------------------------------------------------------')
print ('')
print ('')




