import requests
from requests.auth import HTTPBasicAuth
import json
import datetime
import random
import os





ITERATE_ELEMENT=os.environ.get('ITERATE_ELEMENT')
DEBUG=os.environ.get('WEBHOOK_DEBUG')

EVENT_MAPPING=os.environ.get('EVENT_MAPPING')
EVENT_TEMPLATE=os.environ.get('EVENT_TEMPLATE')


print ('   ------------------------------------------------------------------------------------------------')
print ('   📛 TEST')




# ----------------------------------------------------------------------------------------------------------------------------------------------------
# INJECT EVENTS IN ARRAY
# ----------------------------------------------------------------------------------------------------------------------------------------------------
def injectEvents(DATALAYER_ROUTE,DATALAYER_USER,DATALAYER_PWD,REQUEST,DEBUG):
    print('')
    print ('   ------------------------------------------------------------------------------------------------')
    print ('   📛 Inject Events')

    body_unicode = REQUEST.body.decode('utf-8')
    body = json.loads(body_unicode)
    if DEBUG=='true':
        print('**************************************************************************************')
        print('**************************************************************************************')
        print('DEBUG PAYLOAD')
        print('')
        print(str(body))
        print('**************************************************************************************')
        print('DEBUG EVENT_TEMPLATE')
        print('')
        print(str(EVENT_TEMPLATE))
        print('**************************************************************************************')
        print('DEBUG EVENT_MAPPING')
        print('')
        print(str(EVENT_MAPPING))
        print('**************************************************************************************')
        print('**************************************************************************************')


    events = body[ITERATE_ELEMENT]
    for event in events:
        payload=EVENT_TEMPLATE
        mappingelements=EVENT_MAPPING.split(';')
        for line in mappingelements:
            line=line.strip()
            elements=line.split(',')
            if DEBUG=='true':
                print('Mapping Line:'+str(line))
            actInputKey = elements[0].strip()
            actOutputKey = elements[1].strip()

            if actInputKey in event:
                actValue = str(event[actInputKey]).strip()
                if DEBUG=='true':
                    print('    📥 actInputKey:'+str(actInputKey))
                    print('    💾 actOutputKey:'+str(actOutputKey))
                    print('    ✅ actValue:'+str(actValue))
                payload=payload.replace('@@'+str(actOutputKey),actValue)
            else:
                if DEBUG=='true':
                    print('   ❗ Input field missing - Setting empty:'+str(actOutputKey))
                if 'EXPIRY' in actOutputKey:
                    payload=payload.replace('@@'+str(actOutputKey),'600000')
                elif'override_with_date' in actInputKey:
                    timestamp = datetime.datetime.now()
                    MY_TIMESTAMP_FORMATTED = timestamp.strftime("%Y-%m-%dT%H:%M:%S.000Z")
                    payload=payload.replace('@@'+str(actOutputKey),str(MY_TIMESTAMP_FORMATTED))
                else:
                    payload=payload.replace('@@'+str(actOutputKey),'')
            
        if DEBUG=='true':
            print ('PAYLOAD FINAL'+str(payload))

        
        #timestamp = str(datetime.datetime.now())
        #+%Y-%m-%dT%H:%M:%S

        url = 'https://'+DATALAYER_ROUTE+'/irdatalayer.aiops.io/active/v1/events'
        auth=HTTPBasicAuth(DATALAYER_USER, DATALAYER_PWD)
        headers = {'Content-Type': 'application/json', 'Accept-Charset': 'UTF-8', 'x-username' : 'admin', 'x-subscription-id' : 'cfd95b7e-3bc7-4006-a4a8-a73a79c71255'}
        


        response = requests.post(url, data=str(payload), headers=headers, auth=auth)#, verify=False)
        print ('    RESULT:'+str(response.content))
        print ('')
        print ('')
        print ('')
    #print(events)



    print ('   ✅ Inject Events')
    print ('   ------------------------------------------------------------------------------------------------')
    print ('')
    print ('')
    print ('')
    return 'OK'


# ----------------------------------------------------------------------------------------------------------------------------------------------------
# INJECT SingleEVENTS
# ----------------------------------------------------------------------------------------------------------------------------------------------------
def injectEventsSingle(DATALAYER_ROUTE,DATALAYER_USER,DATALAYER_PWD,REQUEST,DEBUG):
    print('')
    print ('   ------------------------------------------------------------------------------------------------')
    print ('   📛 Inject Events Single')

    body_unicode = REQUEST.body.decode('utf-8')
    body = json.loads(body_unicode)
    if DEBUG=='true':
        print('**************************************************************************************')
        print('**************************************************************************************')
        print('DEBUG PAYLOAD')
        print('')
        print(str(body))
        print('**************************************************************************************')
        print('DEBUG EVENT_TEMPLATE')
        print('')
        print(str(EVENT_TEMPLATE))
        print('**************************************************************************************')
        print('DEBUG EVENT_MAPPING')
        print('')
        print(str(EVENT_MAPPING))
        print('**************************************************************************************')
        print('**************************************************************************************')


    payload=EVENT_TEMPLATE
    event = body
    mappingelements=EVENT_MAPPING.split(';')
    for line in mappingelements:
        line=line.strip()
        elements=line.split(',')
        if DEBUG=='true':
            print('Mapping Line:'+str(line))
        actInputKey = elements[0].strip()
        actOutputKey = elements[1].strip()

        if actInputKey in event:
            actValue = str(event[actInputKey]).strip()
            if DEBUG=='true':
                print('    📥 actInputKey:'+str(actInputKey))
                print('    💾 actOutputKey:'+str(actOutputKey))
                print('    ✅ actValue:'+str(actValue))
            payload=payload.replace('@@'+str(actOutputKey),actValue)
        else:
            if DEBUG=='true':
                print('   ❗ Input field missing - Setting empty:'+str(actOutputKey))
            if 'EXPIRY' in actOutputKey:
                payload=payload.replace('@@'+str(actOutputKey),'600000')
            elif'override_with_date' in actInputKey:
                timestamp = datetime.datetime.now()
                MY_TIMESTAMP_FORMATTED = timestamp.strftime("%Y-%m-%dT%H:%M:%S.000Z")
                payload=payload.replace('@@'+str(actOutputKey),str(MY_TIMESTAMP_FORMATTED))
            else:
                payload=payload.replace('@@'+str(actOutputKey),'')
        

        if DEBUG=='true':
            print ('PAYLOAD FINAL'+str(payload))
        
    #timestamp = str(datetime.datetime.now())
    #+%Y-%m-%dT%H:%M:%S

    url = 'https://'+DATALAYER_ROUTE+'/irdatalayer.aiops.io/active/v1/events'
    auth=HTTPBasicAuth(DATALAYER_USER, DATALAYER_PWD)
    headers = {'Content-Type': 'application/json', 'Accept-Charset': 'UTF-8', 'x-username' : 'admin', 'x-subscription-id' : 'cfd95b7e-3bc7-4006-a4a8-a73a79c71255'}
    


    response = requests.post(url, data=str(payload), headers=headers, auth=auth)#, verify=False)
    print ('    RESULT:'+str(response.content))
    print ('')
    print ('')
    print ('')
#print(events)



    print ('   ✅ Inject Events')
    print ('   ------------------------------------------------------------------------------------------------')
    print ('')
    print ('')
    print ('')
    return 'OK'






