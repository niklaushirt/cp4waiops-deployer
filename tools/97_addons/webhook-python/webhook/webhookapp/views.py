from django.shortcuts import render
from django.http import HttpResponse
from django.template import loader
import os
import sys 
import time 
sys.path.append(os.path.abspath("webhookapp"))
from functions import *

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
print ('    🛰️  Generic Webhook for CP4WAIOPS AI Manager')
print ('')
print ('       Provided by:')
print ('        🇨🇭 Niklaus Hirt (nikh@ch.ibm.com)')
print ('')

print ('*************************************************************************************************')
print (' 🚀 Initializing')
print ('*************************************************************************************************')

#os.system('ls -l')
loggedin='false'
loginip='0.0.0.0'
# ----------------------------------------------------------------------------------------------------------------------------------------------------
# GET NAMESPACES
# ----------------------------------------------------------------------------------------------------------------------------------------------------
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

print('     ❓ Getting Details Datalayer')
stream = os.popen("oc get route  -n "+aimanagerns+" datalayer-api  -o jsonpath='{.status.ingress[0].host}'")
DATALAYER_ROUTE = stream.read().strip()
stream = os.popen("oc get secret aiops-ir-core-ncodl-api-secret -o jsonpath='{.data.username}' | base64 --decode")
DATALAYER_USER = stream.read().strip()
stream = os.popen("oc get secret aiops-ir-core-ncodl-api-secret -o jsonpath='{.data.password}' | base64 --decode")
DATALAYER_PWD = stream.read().strip()


ITERATE_ELEMENT=os.environ.get('ITERATE_ELEMENT')
WEBHOOK_DEBUG=os.environ.get('WEBHOOK_DEBUG')




print ('*************************************************************************************************')
print ('*************************************************************************************************')
print ('')
print ('    **************************************************************************************************')
print ('     🔎 Mapping Parameters')
print ('    **************************************************************************************************')

EVENT_MAPPING=os.environ.get('EVENT_MAPPING')
mappingelements=EVENT_MAPPING.split(';')
print ('           KEY IN JSON PAYLOAD      -->       KEY IN JSON TEMPLATE')
print ('           ----------------------------------------------------------------------------')

for line in mappingelements:
    elements=line.split(',')

    actOutputKey = elements[1].strip()
    actInputKey = elements[0].strip()
    print ('           '+str(actInputKey)+'      -->       '+str(actOutputKey))

print ('')
print ('')
print ('    **************************************************************************************************')
print ('     🔎 JSON Template')
print ('    **************************************************************************************************')
EVENT_TEMPLATE=os.environ.get('EVENT_TEMPLATE')
print ('      TEMPLATE'+str(EVENT_TEMPLATE))


print ('')
print ('')
print ('    **************************************************************************************************')
print ('')
print ('')









# ----------------------------------------------------------------------------------------------------------------------------------------------------
# GET CONNECTION DETAILS
# ----------------------------------------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# GET ENVIRONMENT VALUES
# ----------------------------------------------------------------------------------------------------------------------------------------------------
TOKEN=os.environ.get('TOKEN')



print ('*************************************************************************************************')
print ('*************************************************************************************************')
print ('')
print ('    **************************************************************************************************')
print ('     🔎 Connection Parameters')
print ('    **************************************************************************************************')
print ('           🌏 Datalayer Route:    '+DATALAYER_ROUTE)
print ('           👩‍💻 Datalayer User:     '+DATALAYER_USER)
print ('           🔐 Datalayer Pwd:      '+DATALAYER_PWD)
print ('')
print ('')
print ('')
print ('           🔐 Token:              '+TOKEN)
print ('')
print ('    **************************************************************************************************')



print ('*************************************************************************************************')
print (' ✅ Webhook is READY')
print ('*************************************************************************************************')


from django.views.decorators.csrf import csrf_exempt
# ----------------------------------------------------------------------------------------------------------------------------------------------------
# REST ENDPOINTS
# ----------------------------------------------------------------------------------------------------------------------------------------------------
@csrf_exempt
def webhookDebug(request):
    print('🌏 webhook')
    print('🌏 webhook1')
    if request.method == 'POST':
        if 'token' in request.headers:        
            if TOKEN == request.headers['token']:
                #test=str(request.headers.get('token'))
                #print('AAAAAA:'+str(test))
                injectEvents(DATALAYER_ROUTE,DATALAYER_USER,DATALAYER_PWD,request,'true')
                return HttpResponse('DONE')
            else:
                return HttpResponse('Unauthorized: Please use correct Token in header to authentify', status=401)  

        else:
            return HttpResponse('Unauthorized: Please use Token in header to authentify', status=401)  
    else:
            return HttpResponse('Method not allowed: Please use POST Method', status=405)


@csrf_exempt
def webhook(request):
    print('🌏 webhook')
    if request.method == 'POST':
        if 'token' in request.headers:
            if TOKEN == request.headers['token']:
                #test=str(request.headers.get('token'))
                #print('AAAAAA:'+str(test))
                injectEvents(DATALAYER_ROUTE,DATALAYER_USER,DATALAYER_PWD,request,WEBHOOK_DEBUG)
                return HttpResponse('DONE')
            else:
                return HttpResponse('Unauthorized: Please use correct Token in header to authentify', status=401)  
        else:
            return HttpResponse('Unauthorized: Please use Token in header to authentify', status=401)  
    else:
            return HttpResponse('Method not allowed: Please use POST Method', status=405)



@csrf_exempt
def webhookIterate(request):
    print('🌏 webhookIterate')
    if request.method == 'POST':
        if 'token' in request.headers:
            if TOKEN == request.headers['token']:
                #test=str(request.headers.get('token'))
                #print('AAAAAA:'+str(test))
                injectEvents(DATALAYER_ROUTE,DATALAYER_USER,DATALAYER_PWD,request,WEBHOOK_DEBUG)
                return HttpResponse('DONE')
            else:
                return HttpResponse('Unauthorized: Please use correct Token in header to authentify', status=401)  

        else:
            return HttpResponse('Unauthorized: Please use Token in header to authentify', status=401)  
    else:
            return HttpResponse('Method not allowed: Please use POST Method', status=405)

@csrf_exempt
def webhookSingle(request):
    print('🌏 webhookSingle')
    if request.method == 'POST':
        if 'token' in request.headers:
            if TOKEN == request.headers['token']:

                #test=str(request.headers.get('token'))
                #print('AAAAAA:'+str(test))
                injectEventsSingle(DATALAYER_ROUTE,DATALAYER_USER,DATALAYER_PWD,request,WEBHOOK_DEBUG)
                return HttpResponse('DONE')
            else:
                return HttpResponse('Unauthorized: Please use correct Token in header to authentify', status=401)  

        else:
            return HttpResponse('Unauthorized: Please use Token in header to authentify', status=401)  
    else:
            return HttpResponse('Method not allowed: Please use POST Method', status=405)






# ----------------------------------------------------------------------------------------------------------------------------------------------------
# PAGE ENDPOINTS
# ----------------------------------------------------------------------------------------------------------------------------------------------------


def index(request):
    print('🌏 index')
    global loggedin

    template = loader.get_template('webhookapp/home.html')
    context = {
        'DATALAYER_ROUTE': DATALAYER_ROUTE,
        'DATALAYER_USER': DATALAYER_USER,
        'DATALAYER_PWD': DATALAYER_PWD,
        'EVENT_MAPPING': EVENT_MAPPING,
        'EVENT_TEMPLATE': EVENT_TEMPLATE
        }
    return HttpResponse(template.render(context, request))


def doc(request):
    print('🌏 doc')
    template = loader.get_template('webhookapp/doc.html')
    context = {
        'DATALAYER_ROUTE': DATALAYER_ROUTE,
        'DATALAYER_USER': DATALAYER_USER,
        'DATALAYER_PWD': DATALAYER_PWD,
        'EVENT_MAPPING': EVENT_MAPPING,
        'EVENT_TEMPLATE': EVENT_TEMPLATE

    }
    return HttpResponse(template.render(context, request))

def about(request):
    print('🌏 about')

    template = loader.get_template('webhookapp/about.html')
    context = {
        'loggedin': loggedin,
    }
    return HttpResponse(template.render(context, request))
