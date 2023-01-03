import requests
import json
from sendstory import *
import datetime

import os

DEBUG_ME=os.environ.get('DEBUG_ME',"False")
SEND_DISCORD=os.environ.get('SEND_DISCORD',"False")
SEND_MAIL=os.environ.get('SEND_MAIL',"False")

def processStory(currentStory, DATALAYER_USER, DATALAYER_PWD, DATALAYER_ROUTE):
    print('')
    print ('    ---------------------------------------------------------------------------------------------')
    print ('     📛 Processing Story: '+currentStory['title'])

    if SEND_DISCORD=="True":
        sendDiscord(currentStory, DATALAYER_USER, DATALAYER_PWD, DATALAYER_ROUTE)
    else:
        print ('        ---------------------------------------------------------------------------------------------')
        print('        ⚠️ Skipping Discord')
        print ('        ---------------------------------------------------------------------------------------------')
        print('')

    if SEND_MAIL=="True":
        sendMail(currentStory, DATALAYER_USER, DATALAYER_PWD, DATALAYER_ROUTE)
    else:
        print ('        ---------------------------------------------------------------------------------------------')
        print('        ⚠️ Skipping Mail')
        print ('        ---------------------------------------------------------------------------------------------')
        print('')
    timestamp = datetime.datetime.now()
    print ('     ✅ Processing Story, DONE...'+str(timestamp))
    print ('    ---------------------------------------------------------------------------------------------')
    print('')
    print('')

def debug(text):
    if DEBUG_ME=="True":
        print(text)

def printSameLine(text):
    print('test', end='text')


