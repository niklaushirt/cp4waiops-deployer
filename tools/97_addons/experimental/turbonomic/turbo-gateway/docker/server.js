// ---------------------------------------------------------------------------------------------------------------------------------------------------"
// ---------------------------------------------------------------------------------------------------------------------------------------------------"
// ---------------------------------------------------------------------------------------------------------------------------------------------------"
// Event Push for Turbonomic --> CP4WAIOPS
//
// V3.1 
//
// ©2021 nikh@ch.ibm.com
// ---------------------------------------------------------------------------------------------------------------------------------------------------"
// ---------------------------------------------------------------------------------------------------------------------------------------------------"
// ---------------------------------------------------------------------------------------------------------------------------------------------------"
// ---------------------------------------------------------------------------------------------------------------------------------------------------"
// Requiring express in our server
// npm install express --save
// http://91.121.172.228:3000/businessApplication/285167049934720/RobotShopApplication


const express = require('express');
const axios = require('axios')
const https = require('https');
const fs = require('fs')
const path = require('path')
const {
    exit
} = require('process');
const app = express();

const POLLING_INTERVAL = process.env.POLLING_INTERVAL

const TURBO_USER = process.env.TURBO_USER
const TURBO_PWD = process.env.TURBO_PWD
const TURBO_API_URL = process.env.TURBO_API_URL

const TURBO_BA_NAME = process.env.TURBO_BA_NAME
const NOI_SUMMARY_PREFIX = process.env.NOI_SUMMARY_PREFIX
const NOI_WEBHOOK_URL = process.env.NOI_WEBHOOK_URL
const NOI_WEBHOOK_PATH = process.env.NOI_WEBHOOK_PATH
const DEBUG_ENABLED = process.env.DEBUG_ENABLED
//const ALERTGROUP_POSTFIX = process.env.ALERTGROUP_POSTFIX
const ENTITY_TYPES = process.env.ENTITY_TYPES
const ACTION_TYPES = process.env.ACTION_TYPES
const ACTION_STATES = process.env.ACTION_STATES

var turbocookie = ""
var currentJSON = "Waiting for first refresh"
var previousJSON = "Waiting for first refresh"
var currentBAs = "Waiting for first refresh"

if (process.env.ACTION_START_TIME !== 'undefined' && process.env.ACTION_START_TIME !== '' ){
    const ACTION_START_TIME = process.env.ACTION_START_TIME;
} else {
    ACTION_START_TIME = "-1d"
}

function timestamp() {
    function pad(n) {
        return n < 10 ? "0" + n : n
    }
    d = new Date()
    dash = "-"
    colon = ":"
    return d.getFullYear() + dash +
        pad(d.getMonth() + 1) + dash +
        pad(d.getDate()) + " " +
        pad(d.getHours()) + colon +
        pad(d.getMinutes()) + colon +
        pad(d.getSeconds()) + "  " + colon + "  "
}




// Defining get request at '/' route
app.get('/', function (req, res) {
    console.log(timestamp() + " 🚀 Request received on endpoint /");
    
    res.write('<H1>Turbonomic Gateway</H1>')
    res.write('<H2>Push Turbonomic Actions to CP4WAIOPS Event Manager</H2>')
    res.write('<H4>Currently pushing actions for BA "' + TURBO_BA_NAME + '" to Watson AIOPS</H4>')
    res.write('')
    res.write('<H3>Available Endpoints</H3>')
    res.write('/getCurrentActions<BR>')
    res.write('/getBusinessApplications<BR>')
    res.write('/getConfiguration<BR>')


    res.send()
});


// Defining get request at '/currentActions' route
app.get('/getCurrentActions', function (req, res) {
    console.log(timestamp() + " 🚀 Request received on endpoint /currentActions");
    res.write('<H1>Turbonomic Gateway</H1>')
    res.write('<H2>Push Turbonomic Actions to CP4WAIOPS Event Manager</H2>')
    res.write('<H3>TURBONOMIC Current Actions for BA: ' + TURBO_BA_NAME + '</H3>')
    res.write('')
    res.write(currentJSON)


    res.send()
});


// Defining get request at '/businessApplications' route
app.get('/getBusinessApplications', function (req, res) {
    console.log(timestamp() + " 🚀 Request received on endpoint /businessApplications");
    
    res.write('<H1>Turbonomic Gateway</H1>')
    res.write('<H2>Push Turbonomic Actions to CP4WAIOPS Event Manager</H2>')
    res.write('<H3>Current Business Applications</H3>')
    res.write('')
    res.write(currentBAs)


    res.send()
});



// Defining get request at '/getConfiguration' route
app.get('/getConfiguration', function (req, res) {
    console.log(timestamp() + " 🚀 Request received on endpoint /businessApplications");

    res.write('<H1>Turbonomic Gateway</H1>')
    res.write('<H2>Push Turbonomic Actions to CP4WAIOPS Event Manager</H2>')
    res.write('<H3>Current Configuration</H3>')
    res.write('')
    res.write("<BR> POLLING_INTERVAL    : " + POLLING_INTERVAL + " seconds");
    res.write("<BR>");
    res.write("<BR> TURBO_USER          : " + TURBO_USER);
    res.write("<BR> TURBO_PWD           : PASSWORD SET");
    res.write("<BR> TURBO_API_URL       : " + TURBO_API_URL);
    res.write("<BR> TURBO_BA_NAME       : " + TURBO_BA_NAME);
    res.write("<BR>");
    res.write("<BR> NOI_SUMMARY_PREFIX  : " + NOI_SUMMARY_PREFIX);
    res.write("<BR> NOI_WEBHOOK_URL     : " + NOI_WEBHOOK_URL);
    res.write("<BR> NOI_WEBHOOK_PATH    : " + NOI_WEBHOOK_PATH);
    res.write("<BR>");
    //res.write("<BR> ALERTGROUP_POSTFIX    : " + ALERTGROUP_POSTFIX);


    res.send()
});









// Push Turbo Actions to Watson AIOPS 
function pushBA(BAnames) {

    //cater for multiple business apps being passed as comma separated list e.g. app1:alertgroup,app2:alertgroup,app3:alertgroup and loop through results
    // BAnames is a sort of map where we have BANAME:ALERTGROUP so we can loop through multiple applications with separate event manager alert groups
    BAnames.split(',').forEach(function(BAmap) {

        var BAname = BAmap.split(':')[0];
        var ALERTGROUP_POSTFIX = BAmap.split(':')[1];

        console.log(timestamp() + '------------------------------------------------------------------------------------------------------------------------------------------------------------------------');
        console.log(timestamp() + '------------------------------------------------------------------------------------------------------------------------------------------------------------------------');
        console.log(timestamp() + '------------------------------------------------------------------------------------------------------------------------------------------------------------------------');
        console.log(timestamp() + '------------------------------------------------------------------------------------------------------------------------------------------------------------------------');
        console.log(timestamp() + '------------------------------------------------------------------------------------------------------------------------------------------------------------------------');
        console.log(timestamp() + " 📥 Starting Action ingestion for " + BAname);
        console.log(timestamp() + '------------------------------------------------------------------------------------------------------------------------------------------------------------------------');
        console.log(timestamp() + '------------------------------------------------------------------------------------------------------------------------------------------------------------------------');

        

        // --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        // --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        // --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        // Get Credentials
        // --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        // --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        // --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        const httpTransportAuth = require('https');
        const responseEncodingAuth = 'utf8';
        const httpOptionsAuth = {
            hostname: TURBO_API_URL,
            port: '443',
            path: '/api/v3/login',
            method: 'POST',
            headers: {
                "Accept": "application/json",
                "Content-Type": "application/x-www-form-urlencoded; charset=utf-8"
            }
        };
        httpOptionsAuth.headers['User-Agent'] = 'node ' + process.version;

        const requestAuth = httpTransportAuth.request(httpOptionsAuth, (res) => {
                let responseBufs = [];
                let responseStr = '';

                res.on('data', (chunk) => {
                    if (Buffer.isBuffer(chunk)) {
                        responseBufs.push(chunk);
                    } else {
                        responseStr = responseStr + chunk;
                    }
                }).on('end', () => {
                    responseStr = responseBufs.length > 0 ?
                        Buffer.concat(responseBufs).toString(responseEncodingAuth) : responseStr;
                    console.log(timestamp() + 'HEADERS:', res.headers['set-cookie']);
                    console.log(timestamp() + 'Token:', responseStr);
                    turbocookie = res.headers['set-cookie']



                    // --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                    // --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                    // --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                    // GET Business Applications
                    // --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                    // --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                    // --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                    const httpTransport = require('https');
                    const responseEncoding = 'utf8';
                    const httpOptions = {
                        hostname: TURBO_API_URL,
                        port: '443',
                        path: '/api/v3/search?types=BusinessApplication&limit=500&cursor=0',
                        method: 'GET',
                        headers: {
                            "Accept": "application/json",
                            "Content-Type": "application/x-www-form-urlencoded; charset=utf-8",
                            "Cookie": turbocookie
                        }
                    };
                    httpOptions.headers['User-Agent'] = 'node ' + process.version;

                    const request = httpTransport.request(httpOptions, (res) => {
                            let responseBufs = [];
                            let responseStr = '';

                            res.on('data', (chunk) => {
                                if (Buffer.isBuffer(chunk)) {
                                    responseBufs.push(chunk);
                                } else {
                                    responseStr = responseStr + chunk;
                                }
                            }).on('end', () => {
                                responseStr = responseBufs.length > 0 ?
                                    Buffer.concat(responseBufs).toString(responseEncoding) : responseStr;
                                var baValues = JSON.parse(responseStr);
                                console.log(timestamp() + '------------------------------------------------------------------------------------------------------------------------------------------------------------------------');
                                console.log(timestamp() + '------------------------------------------------------------------------------------------------------------------------------------------------------------------------');

                                currentBAs = JSON.stringify(baValues)

                                if (DEBUG_ENABLED == "true"){
                                    console.log(timestamp() + 'DEBUG RESPONSE: ' + baValues);
                                }
                                

                                baValues.forEach(function (baValue) {
                                    var displayName = baValue.displayName;
                                    var displayUUID = baValue.uuid;
                                    var previousActions = [];

                                    console.log(timestamp() + displayName);
                                    if (displayName == BAname) {
                                        console.log(timestamp() + "FOUND:" + displayName + ":" + displayUUID);
                                        
                                        const tmpfile = '/tmp/'+displayName.replace(/\s/g, "")+'_previousJSON.txt'
                                        try {
                                            if (fs.existsSync(tmpfile)) {
                                                fs.readFile(tmpfile, 'utf8' , (err, data) => {
                                                    if (err) {
                                                    console.error(err)
                                                    console.log(timestamp() + 'Failed to read previously persisted actions state. Does the file exist?');
                                                    return
                                                    }
                                                    //console.log(data)
                                                    previousActions = JSON.parse(data);
                                                    console.log(timestamp() + 'Read previously persisted actions state successfully. Total: ' + previousActions.length + ' actions.');
                                                })
                                            }
                                        } catch(err) {
                                            console.log(timestamp() + 'Failed to read previously persisted actions state.');
                                            console.error(err)
                                        }

                                        // --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                                        // --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                                        // --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                                        // GET ACTIONS
                                        // --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                                        // --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                                        // --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                                        const httpTransport = require('https');
                                        const responseEncoding = 'utf8';
                                        const httpOptions = {
                                            hostname: TURBO_API_URL,
                                            port: '443',
                                            path: '/api/v3/entities/' + displayUUID + '/actions?limit=500&cursor=0',
                                            method: 'POST',
                                            //method: 'GET',
                                            headers: {
                                                "Accept": "application/json",
                                                "Content-Type": "application/json",
                                                "Cookie": turbocookie
                                            }
                                        };
                                        httpOptions.headers['User-Agent'] = 'node ' + process.version;

                                        if (DEBUG_ENABLED == "true"){
                                            console.log(timestamp() + ' Defined action data json ' + actiondata);
                                        }
                                        
                                        var actiondata = new Object();
                                        actiondata.startTime = "-7d";
                                        actiondata.groupBy = ["actionTypes"];
                                        actiondata.limitEntities = 0;
                                        actiondata.detailLevel = "STANDARD";
                                        actiondata.relatedEntityTypes = [];
                                        actiondata.actionTypeList = [];
                                        actiondata.actionStateList = [];

                                        ENTITY_TYPES.split(',').forEach(function(type) {
                                            actiondata.relatedEntityTypes.push(type.toString());
                                        });

                                        ACTION_TYPES.split(',').forEach(function(type) {
                                            actiondata.actionTypeList.push(type.toString());
                                        });

                                        ACTION_STATES.split(',').forEach(function(type) {
                                            actiondata.actionStateList.push(type.toString());
                                        });

                                        var actiondataJSON = JSON.stringify(actiondata);

                                        if (DEBUG_ENABLED == "true"){
                                            console.log(timestamp() + ' Defined action data json ' + actiondataJSON);
                                        }

                                        const request = httpTransport.request(httpOptions, (res) => {
                                                let responseBufs = [];
                                                let responseStr = '';

                                                res.on('data', (chunk) => {
                                                    if (Buffer.isBuffer(chunk)) {
                                                        responseBufs.push(chunk);
                                                    } else {
                                                        responseStr = responseStr + chunk;
                                                    }
                                                }).on('end', () => {
                                                    responseStr = responseBufs.length > 0 ?
                                                        Buffer.concat(responseBufs).toString(responseEncoding) : responseStr;
                                                    var actionValues = JSON.parse(responseStr);
                                                    console.log(timestamp() + '------------------------------------------------------------------------------------------------------------------------------------------------------------------------');
                                                    console.log(timestamp() + '------------------------------------------------------------------------------------------------------------------------------------------------------------------------');

                                                    console.log(timestamp() + ' 🔎 CHECK FOR NEW ACTIONS');

                                                    //currentJSON = JSON.stringify(actionValues)

                                                    if (DEBUG_ENABLED == "true"){
                                                        console.log(timestamp() + 'DEBUG RESPONSE: ' + responseStr);
                                                    }

                                                    console.log(timestamp() + 'Total of ' + actionValues.length + ' retrieved from API for ' + displayName);
                                                    
                                                    // create a new object where the discriminator is a property
                                                    // this list will be the reference to which we decide if new actions are opened
                                                    var newActions = [];
                                                    var oldActionsArr = [];
                                                    var indexedObj = {};

                                                    console.log(timestamp() + "There are " + previousActions.length + " previous actions to check");
                                                    for( var i=0; i<previousActions.length; i++){
                                                        var o = previousActions[i];
                                                        indexedObj[o.uuid] = o;
                                                    }

                                                    //Get a list of new found actions by comparing the actions on disk to the latest API call
                                                    //if the action is a IN_PROGRESS action do we actually still want to push it as a new action to increase the event count?? This might signify an action is taking too long and may eventually fail
                                                    for( var i=0;i<actionValues.length; i++) {
                                                        if( indexedObj[actionValues[i].uuid] && actionValues[i].actionState !== "IN_PROGRESS" ) {
                                                            // the object in the new array is in the old one
                                                            //console.log("Action " + actionValues[i].uuid + " is an old action");
                                                            oldActionsArr.push(actionValues[i].uuid)
                                                        } else {
                                                            //console.log("New action found");
                                                            actionValues[i].status = "OPEN"
                                                            newActions.push(actionValues[i]);
                                                        }
                                                    }

                                                    console.log(timestamp() + 'Found ' + oldActionsArr.length + ' old actions, ' + newActions.length + ' new actions.');

                                                    //Get a list of new old actions that no longer exist in the new list to close them in event manager (since they are redundant events)
                                                    //old actions come from reading the json file earlier
                                                    var expiredActions = [];
                                                    var indexedObj = {};
                                                    for( var i=0; i<actionValues.length; i++){
                                                        var o = actionValues[i];
                                                        indexedObj[o.uuid] = o;
                                                    }

                                                    //loop through the previously found actions and if they exist, do nothing, since they're still technically open. Else we set the action to resolved for event manager to clear it automatically
                                                    //the exception is a FAILED state action where we want to keep it open, but they will always exist in Turbonomic anyway for the given time period so they should always remain in the state file. 
                                                    //Anything FAILED outside of the time period will get cleared
                                                    for( var i=0;i<previousActions.length; i++) {
                                                        if( indexedObj[previousActions[i].uuid] ) {
                                                            // the object in the new array is in the old one, or the action is in FAILED state so we don't want to resolve it
                                                            //console.log("Action " + previousActions[i].uuid + " is an old action");
                                                        } else {
                                                            //console.log("Found an expired action. Setting status of " + previousActions[i].uuid + " to CLOSED");
                                                            previousActions[i].status = "CLOSED";
                                                            previousActions[i].resolution = true;
                                                            expiredActions.push(previousActions[i]);
                                                        }
                                                    }

                                                    console.log(timestamp() + 'Got ' + expiredActions.length + ' expired actions');

                                                    // Push the expired actions into the newActions array so they get pushed to WAIOps without having to loop through them separately (status field is different)
                                                    for( var i=0;i<expiredActions.length; i++) {
                                                        newActions.push(expiredActions[i]);
                                                    }

                                                    currentJSON = JSON.stringify(newActions)

                                                    if ( newActions.length == 0 ){
                                                    //if (currentJSON == previousJSON) {

                                                        console.log(timestamp() + '------------------------------------------------------------------------------------------------------------------------------------------------------------------------');
                                                        console.log(timestamp() + '------------------------------------------------------------------------------------------------------------------------------------------------------------------------');
                                                        console.log(timestamp() + ' ⬇ NO CHANGE - SKIPPING');
                                                        console.log(timestamp() + '------------------------------------------------------------------------------------------------------------------------------------------------------------------------');


                                                    } else {
                                                        //var objcount = Object.keys(newActions).length;
                                                        console.log(timestamp() + '------------------------------------------------------------------------------------------------------------------------------------------------------------------------');
                                                        console.log(timestamp() + '------------------------------------------------------------------------------------------------------------------------------------------------------------------------');
                                                        console.log(timestamp() + ' ✅ ' + newActions.length + ' ACTION CHANGES FOUND - PUSHING TO WAIOPS');
                                                        console.log(timestamp() + '------------------------------------------------------------------------------------------------------------------------------------------------------------------------');

                                                        previousJSON = currentJSON;
                                                        //persist previous json to filesystem for when we want a volume attached (solves the issue that when a container is restarted it pushes the same actions again)
                                                        //const content = previousJSON;
                                                        fs.writeFile('/tmp/'+displayName.replace(/\s/g, "")+'_previousJSON.txt', currentJSON, err => {
                                                            if (err) {
                                                                console.error(err);
                                                                return;
                                                            }
                                                            //file written successfully
                                                            console.log(timestamp() + 'New actions state persisted.');
                                                        })

                                                        //actionValues.forEach(function (actionValue) {
                                                        newActions.forEach(function (actionValue) {

                                                            actionObj = new Object()
                                                            const secondsSinceEpoch = Math.round(Date.now() / 1000)
                                                            actionObj.timestamp = secondsSinceEpoch
                                                            //actionObj.timestamp = actionValue.createTime
                                                            myseverity = actionValue.risk.severity
                                                            actionObj.severity = myseverity.charAt(0).toUpperCase() + myseverity.slice(1).toLowerCase()
                                                            //actionObj.summary = NOI_SUMMARY_PREFIX + actionValue.risk.description
                                                            // Action description will look similar to this
                                                            /// [Performance Assurance] [MOVE] [READY|FAILED|SUCCEEDED] Mem Congestion - Move Virtual Machine node-infra-infra-1 from gpu.vmware.chechu.com to host17.vmware.chechu.com
                                                            if ( typeof actionValue.details !== 'undefined' && actionValue.details !== "" ){
                                                                actionObj.summary = "["+actionValue.risk.subCategory+"] " + "["+actionValue.actionType+"] " + "["+actionValue.actionState+"] " + actionValue.risk.description + " - " + actionValue.details
                                                            }else{
                                                                actionObj.summary = "["+actionValue.risk.subCategory+"] " + "["+actionValue.actionType+"] " + "["+actionValue.actionState+"] " + actionValue.risk.description
                                                            }
                                                            actionObj.summary = "["+actionValue.risk.subCategory+"] " + "["+actionValue.actionType+"] " + "["+actionValue.actionState+"] " + actionValue.risk.description + " - " + actionValue.details
                                                            
                                                            // set the namespace if it exists for greater accuracy (cloud native deployments)
                                                            /*
                                                            if ( typeof actionValue.target.aspects !== 'undefined' && 
                                                                typeof actionValue.target.aspects.containerPlatformContextAspect !== 'undefined' && 
                                                                typeof actionValue.target.aspects.containerPlatformContextAspect.namespace !== 'undefined' && 
                                                                actionValue.target.aspects.containerPlatformContextAspect.namespace !== '' ){                                                           
                                                                    actionObj.alertgroup = actionValue.target.aspects.containerPlatformContextAspect.namespace + '_' + ALERTGROUP_POSTFIX
                                                            }else{
                                                                //set the ALERTGROUP_PREFIX if a namespace does not exist
                                                                actionObj.alertgroup = ALERTGROUP_POSTFIX
                                                            }
                                                            */

                                                            actionObj.alertgroup = ALERTGROUP_POSTFIX
                                                            actionObj.actionState = actionValue.actionState
                                                            actionObj.actionMode = actionValue.actionMode
                                                            actionObj.actionType = actionValue.actionType
                                                            actionObj.nodename = actionValue.target.displayName
                                                            actionObj.url = "https://" + TURBO_API_URL + "/app/index.html#/view/main/" + actionValue.target.uuid + "/overview"
                                                            actionObj.actionID = actionValue.target.uuid
                                                            actionObj.market = actionValue.marketID
                                                            actionObj.status = actionValue.status ;
                                                            actionObj.resolution = actionValue.resolution;


                                                            var jsonObj = JSON.stringify(actionObj)

                                                            console.log(timestamp() + '------------------------------------------------------------------------------------------------------------------------------------------------------------------------');
                                                            console.log(timestamp() + ' 📥 TURBO ACTION');
                                                            console.log(timestamp() + '------------------------------------------------------------------------------------------------------------------------------------------------------------------------');

                                                            console.log(timestamp() + jsonObj.toString());

                                                            // --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                                                            // --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                                                            // --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                                                            // Send actions to NOI Webhook
                                                            // --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                                                            // --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                                                            // --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                                                            const httpTransport = require('https');
                                                            const responseEncoding = 'utf8';
                                                            const httpOptions = {
                                                                hostname: NOI_WEBHOOK_URL,
                                                                port: '443',
                                                                path: NOI_WEBHOOK_PATH,
                                                                method: 'POST',
                                                                headers: {
                                                                    "Accept": "application/json",
                                                                    "Content-Type": "application/x-www-form-urlencoded; charset=utf-8"
                                                                }
                                                            };
                                                            httpOptions.headers['User-Agent'] = 'node ' + process.version;

                                                            const request = httpTransport.request(httpOptions, (res) => {
                                                                    let responseBufs = [];
                                                                    let responseStr = '';

                                                                    res.on('data', (chunk) => {
                                                                        if (Buffer.isBuffer(chunk)) {
                                                                            responseBufs.push(chunk);
                                                                        } else {
                                                                            responseStr = responseStr + chunk;
                                                                        }
                                                                    }).on('end', () => {
                                                                        responseStr = responseBufs.length > 0 ?
                                                                            Buffer.concat(responseBufs).toString(responseEncoding) : responseStr;
                                                                        console.log(timestamp() + 'Pushing Action to NOI');
                                                                        console.log(timestamp() + 'Result:', responseStr);
                                                                        turbocookie = res.headers['set-cookie']
                                                                    });
                                                                })
                                                                .setTimeout(0)
                                                                .on('error', (error) => {
                                                                    console.log(timestamp() + 'e:', error);
                                                                });
                                                            request.write(jsonObj)
                                                            request.end();
                                                        });
                                                    }
                                                });
                                            })
                                            .setTimeout(0)
                                            .on('error', (error) => {
                                                console.log(timestamp() + 'e:', error);
                                            });
                                        
                                        request.write(actiondataJSON)
                                        //request.write("username=" + TURBO_USER + "&password=" + TURBO_PWD)
                                        //console.log(timestamp() + ' Request body: ' + request.body);
                                        request.end();
                                    }
                                });
                            });
                        })
                        .setTimeout(0)
                        .on('error', (error) => {
                            console.log(timestamp() + 'e:', error);
                        });
                    request.end();
                });
            })
            .setTimeout(0)
            .on('error', (error) => {
                console.log(timestamp() + 'e:', error);
            });
        requestAuth.write("username=" + TURBO_USER + "&password=" + TURBO_PWD)
        requestAuth.end();
    });
}




function randomBetween(min, max) {
    return Math.random() * (max - min) + min
}




// Setting the server to listen at port 3000
app.listen(3000, function (req, res) {
    console.log(timestamp() + "-----------------------------------------------------------------------------------------");
    console.log(timestamp() + "-----------------------------------------------------------------------------------------");
    console.log(timestamp() + "");
    console.log(timestamp() + " 🚀 CloudPak for Watson AIOps");
    console.log(timestamp() + "");
    console.log(timestamp() + "    🛰️ Turbonomic Gateway - Push Turbonomic Actions to CP4WAIOPS Event Manager");
    console.log(timestamp() + "");
    console.log(timestamp() + "-----------------------------------------------------------------------------------------");
    console.log(timestamp() + "-----------------------------------------------------------------------------------------");
    console.log(timestamp() + "     Provided by");
    console.log(timestamp() + "     🇨🇭 Niklaus Hirt (nikh@ch.ibm.com)");
    console.log(timestamp() + "     🇨🇬🇧 Luca Floris (luca.floris@uk.ibm.com)");
    console.log(timestamp() + "");
    console.log(timestamp() + "");
    console.log(timestamp() + "-----------------------------------------------------------------------------------------");


    if (POLLING_INTERVAL == "") {
        console.log(timestamp() + "❌ POLLING_INTERVAL not defined. Exiting....");
        exit();
    }
    if (TURBO_USER == "") {
        console.log(timestamp() + "❌ TURBO_USER not defined. Exiting....");
        exit();
    }
    if (TURBO_PWD == "") {
        console.log(timestamp() + "❌ TURBO_PWD not defined. Exiting....");
        exit();
    }
    if (TURBO_API_URL == "") {
        console.log(timestamp() + "❌ TURBO_API_URL not defined. Exiting....");
        exit();
    }
    if (TURBO_BA_NAME == "") {
        console.log(timestamp() + "❌ TURBO_BA_NAME not defined. Exiting....");
        exit();
    }
    if (NOI_WEBHOOK_URL == "") {
        console.log(timestamp() + "❌ NOI_WEBHOOK_URL not defined. Exiting....");
        exit();
    }
    if (NOI_WEBHOOK_PATH == "") {
        console.log(timestamp() + "❌ NOI_WEBHOOK_PATH not defined. Exiting....");
        exit();
    }
    /*
    if (ALERTGROUP_POSTFIX == "") {
        console.log(timestamp() + "❌ ALERTGROUP_POSTFIX not defined. Exiting....");
        exit();
    }
    */
    if (ACTION_TYPES == "") {
        console.log(timestamp() + "❌ ACTION_TYPES not defined. Exiting....");
        exit();
    }
    if (ENTITY_TYPES == "") {
        console.log(timestamp() + "❌ ENTITY_TYPES not defined. Exiting....");
        exit();
    }
    if (ACTION_STATES == "") {
        console.log(timestamp() + "❌ ACTION_STATES not defined. Exiting....");
        exit();
    } 

    console.log(timestamp() + "-----------------------------------------------------------------------------------------");
    console.log(timestamp() + " 🛠️ Parameters");
    console.log(timestamp() + "-----------------------------------------------------------------------------------------");
    console.log(timestamp() + "");
    console.log(timestamp() + "    POLLING_INTERVAL    : " + POLLING_INTERVAL + " seconds");
    console.log(timestamp() + "");
    console.log(timestamp() + "    TURBO_USER          : " + TURBO_USER);
    console.log(timestamp() + "    TURBO_PWD           : PASSWORD SET");
    console.log(timestamp() + "    TURBO_API_URL       : " + TURBO_API_URL);
    console.log(timestamp() + "    TURBO_BA_NAME       : " + TURBO_BA_NAME);
    console.log(timestamp() + "");
    console.log(timestamp() + "    NOI_SUMMARY_PREFIX  : " + NOI_SUMMARY_PREFIX);
    console.log(timestamp() + "    NOI_WEBHOOK_URL     : " + NOI_WEBHOOK_URL);
    console.log(timestamp() + "    NOI_WEBHOOK_PATH    : " + NOI_WEBHOOK_PATH);
    console.log(timestamp() + "");
   // console.log(timestamp() + "    ALERTGROUP_POSTFIX    : " + ALERTGROUP_POSTFIX);
   // console.log(timestamp() + "");
    console.log(timestamp() + "    ACTION_TYPES    : " + ACTION_TYPES);
    console.log(timestamp() + "    ACTION_STATES    : " + ACTION_STATES);
    console.log(timestamp() + "    ENTITY_TYPES    : " + ENTITY_TYPES);
    console.log(timestamp() + "");
    console.log(timestamp() + "-----------------------------------------------------------------------------------------");
    console.log(timestamp() + "");
    console.log(timestamp() + " 🌏 Server is running at port 3000");
    console.log(timestamp() + "");
    console.log(timestamp() + "-----------------------------------------------------------------------------------------");

    pushBA(TURBO_BA_NAME);
    setInterval(function () {
        pushBA(TURBO_BA_NAME);
        console.log("Starting...")
    }, POLLING_INTERVAL * 1000)
});