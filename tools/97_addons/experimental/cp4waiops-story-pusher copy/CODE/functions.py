import requests
import json
from sendstory import *

import os

DEBUG_ME=os.environ.get('DEBUG_ME',False)
SEND_DISCORD=os.environ.get('SEND_DISCORD',False)
SEND_MAIL=os.environ.get('SEND_MAIL',False)

def processStory(currentStories, storyCount, DATALAYER_USER, DATALAYER_PWD, DATALAYER_ROUTE):
    print('')
    print('')
    print ('    ---------------------------------------------------------------------------------------------')
    print ('     📛 Processing Story')

    if SEND_DISCORD:
        sendDiscord(currentStories, storyCount, DATALAYER_USER, DATALAYER_PWD, DATALAYER_ROUTE)
    else:
        print('       ❗ Skipping Discord')
    if SEND_MAIL:
        sendMail(currentStories, storyCount, DATALAYER_USER, DATALAYER_PWD, DATALAYER_ROUTE)
    else:
        print('       ❗ Skipping Mail')

    print ('     ✅ Processing Story, DONE...')
    print ('    ---------------------------------------------------------------------------------------------')
    print('')
    print('')

def debug(text):
    if DEBUG_ME==True:
        print(text)

def printSameLine(text):
    print('test', end='text')


