// ---------------------------------------------------------------------------------------------------------------------------------------------------"
// ---------------------------------------------------------------------------------------------------------------------------------------------------"
// ---------------------------------------------------------------------------------------------------------------------------------------------------"
// Installing Script for all CP4WAIOPS V3.1.1components
//
// V3.1.1
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
const app = express();


const RT_MIN_1=process.env.RESPTIME_MIN_1
const RT_MIN_2=process.env.RESPTIME_MIN_2
const RT_AVG_1=process.env.RESPTIME_AVG_1
const RT_AVG_2=process.env.RESPTIME_AVG_2
const RT_MAX_1=process.env.RESPTIME_MAX_1
const RT_MAX_2=process.env.RESPTIME_MAX_2

const TR_MIN_1=process.env.TRANSACTION_MIN_1
const TR_MIN_2=process.env.TRANSACTION_MIN_2
const TR_AVG_1=process.env.TRANSACTION_AVG_1
const TR_AVG_2=process.env.TRANSACTION_AVG_2
const TR_MAX_1=process.env.TRANSACTION_MAX_1
const TR_MAX_2=process.env.TRANSACTION_MAX_2

function timestamp(){
    function pad(n) {return n<10 ? "0"+n : n}
    d=new Date()
    dash="-"
    colon=":"
    return d.getFullYear()+dash+
    pad(d.getMonth()+1)+dash+
    pad(d.getDate())+" "+
    pad(d.getHours())+colon+
    pad(d.getMinutes())+colon+
    pad(d.getSeconds())+ "  " + colon + "  "
  }

  
// Defining get request at '/' route
app.get('/', function (req, res) {
    console.log(timestamp() + " 🚀 Request received on endpoint /");

    res.write('<H1>TURBONOMIC DIF ENDPOINT</H1>')
    res.write('')
    res.write('<H3>Available Endpoints:<BR></H3>')
    res.write('&nbsp;&nbsp;&nbsp;- /businessApplication/name/uid<BR>')
    res.write('&nbsp;&nbsp;&nbsp;- /businessTransaction/name/uid<BR>')
    res.write('&nbsp;&nbsp;&nbsp;- /service/name/uid<BR>')
    res.write('&nbsp;&nbsp;&nbsp;- /databaseServer/name/uid<BR>')
    res.write('&nbsp;&nbsp;&nbsp;- /application/name/uid<BR>')

    res.send()
});



app.get('/helloworld', function (req, res) {
    const secondsSinceEpoch = Math.round(Date.now() / 1000)

    const rtMin=randomBetween(RT_MIN_1,RT_MIN_2)
    const rtAverage=randomBetween(RT_AVG_1,RT_AVG_2)
    const rtMax=randomBetween(RT_MAX_1,RT_MAX_2)

    const trMin=randomBetween(TR_MIN_1,TR_MIN_2)
    const trAverage=randomBetween(TR_AVG_1,TR_AVG_2)
    const trMax=randomBetween(TR_MAX_1,TR_MAX_2)



    console.log(timestamp() + " 🚀 Request received on endpoint /helloworld");
    console.log("");


    res.json({
      "version": "v1",
      "updateTime": secondsSinceEpoch,
        "scope": "",
        "source": "",
        "topology": [{
            "uniqueId": "Hello_World_BusinessApp",
            "type": "businessApplication",
            "name": "Hello World",
            "metrics": {
                "responseTime": [{
                    "average": rtAverage,
                    "max": rtMax,
                    "min": rtMin,
                    "unit": "ms"
                }],
                "transaction": [{
                    "average": trAverage,
                    "max": trMax,
                    "min": trMin,
                    "unit": "tps"
                }]
            }
        }]
    });
});



app.get('/:type', function (req, res) {

    console.log(timestamp() + " ❌ Incomplete request received on endpoint /type");

    res.write('<H1>TURBONOMIC DIF ENDPOINT</H1><BR>')
    res.write('Please use /type/name/uid<BR>')
    res.write('Valid types are businessApplication, businessTransaction, service, databaseServer, application')
    
    res.send()
});


app.get('/:type/:name/', function (req, res) {

    console.log(timestamp() + " ❌ Incomplete request received on endpoint /type/name");


    res.write('<H1>TURBONOMIC DIF ENDPOINT</H1><BR>')
    res.write('Please use /type/name/uid<BR>')
    res.write('Valid types are businessApplication, businessTransaction, service, databaseServer, application')
    res.send()
});




app.get('/:type/:name/:uid', function (req, res) {
    const secondsSinceEpoch = Math.round(Date.now() / 1000)

    const type=req.params.type
    const uid=req.params.uid
    const name=req.params.name

    const rtMin=randomBetween(50,200)
    const rtAverage=randomBetween(200,500)
    const rtMax=randomBetween(500,2000)

    const trMin=randomBetween(50,100)
    const trAverage=randomBetween(100,200)
    const trMax=randomBetween(200,300)



    console.log(timestamp() + " 🚀 Request received on endpoint /" + type);
    console.log(timestamp() + "    name : " + name);
    console.log(timestamp() + "    uid  : " + uid);
    console.log(timestamp() + "");


    res.json({
      "version": "v1",
      "updateTime": secondsSinceEpoch,
        "scope": "",
        "source": "",
        "topology": [{
            "uniqueId": uid,
            "type": type,
            "name": name,
            "metrics": {
                "responseTime": [{
                    "average": rtAverage,
                    "max": rtMax,
                    "min": rtMin,
                    "unit": "ms"
                }],
                "transaction": [{
                    "average": trAverage,
                    "max": trMax,
                    "min": trMin,
                    "unit": "tps"
                }]
            }
        }]
    });
});





function randomBetween(min, max) {  
    return Math.random() * (max - min) + min
  }




// Setting the server to listen at port 3000
app.listen(3000, function (req, res) {
    console.log(timestamp() + "-----------------------------------------------------------------------------------------");
    console.log(timestamp() + "-----------------------------------------------------------------------------------------");
    console.log(timestamp() + "");
    console.log(timestamp() + " 🚀 CloudPack for Watson AIOps");
    console.log(timestamp() + "");
    console.log(timestamp() + "    📥 Turbonomic Dif Server");
    console.log(timestamp() + "");
    console.log(timestamp() + "-----------------------------------------------------------------------------------------");
    console.log(timestamp() + "-----------------------------------------------------------------------------------------");
    console.log(timestamp() + "Provided by Niklaus Hirt (nikh@ch.ibm.com)");
    console.log(timestamp() + "");
    console.log(timestamp() + "");
    console.log(timestamp() + "-----------------------------------------------------------------------------------------");
    console.log(timestamp() + "");
    console.log(timestamp() + "");
    console.log(timestamp() + "-----------------------------------------------------------------------------------------");
    console.log(timestamp() + "");
    console.log(timestamp() + "");
    console.log(timestamp() + "");
    console.log(timestamp() + "Server is running at port 3000");
    console.log(timestamp() + "");
    console.log(timestamp() + "-----------------------------------------------------------------------------------------");

});


