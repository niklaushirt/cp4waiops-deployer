
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
print ('    🛰️  Turbo Topology for CP4WAIOPS AI Manager')
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
stream = os.popen("oc get route -n turbonomic api -o jsonpath={.spec.host}")
TURBO_URL = stream.read().strip()




print (str(TURBO_URL))

stream = os.popen("curl -XPOST -s -k -c /tmp/cookies -H 'accept: application/json' 'https://"+TURBO_URL+"/api/v3/login?hateoas=true' -d 'username=administrator&password="+TURBO_PASSWORD+"'")
TURBO_LOGIN = stream.read().strip()
TURBO_LOGIN_JSON=json.loads(TURBO_LOGIN)
#print(actStories['stories'])
#print(actStories['stories'][0]['description'])

print (str(TURBO_LOGIN_JSON["username"]))

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# GET VMs
# ----------------------------------------------------------------------------------------------------------------------------------------------------
parseEntity("VirtualMachine", TURBO_URL, topology_file)
parseEntity("AvailabilityZone", TURBO_URL, topology_file)
parseEntity("Region", TURBO_URL, topology_file)
parseEntity("DataCenter", TURBO_URL, topology_file)
parseEntity("Host", TURBO_URL, topology_file)
parseEntity("VirtualMachineCluster", TURBO_URL, topology_file)
parseEntity("VirtualDataCenter", TURBO_URL, topology_file)
parseEntity("WorkloadController", TURBO_URL, topology_file)
parseEntity("Container", TURBO_URL, topology_file)
parseEntity("ContainerPod", TURBO_URL, topology_file)
parseEntity("ContainerCluster", TURBO_URL, topology_file)
parseEntity("ContainerPod", TURBO_URL, topology_file)
parseEntity("ApplicationComponent", TURBO_URL, topology_file)
parseEntity("BusinessTransaction", TURBO_URL, topology_file)
parseEntity("BusinessApplication", TURBO_URL, topology_file)
parseEntity("VirtualVolume", TURBO_URL, topology_file)
parseEntity("Storage", TURBO_URL, topology_file)
parseEntity("Service", TURBO_URL, topology_file)










print ('-------------------------------------------------------------------------------------------------')
print (' 🚀 Waiting')
print ('-------------------------------------------------------------------------------------------------')

while True:
    if ACTIVE=="True": 
        print ('     🚀 Simulating Events')


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




