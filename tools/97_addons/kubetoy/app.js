const instana = require('@instana/collector');
// init tracing
// MUST be done before loading anything else!
instana({
    tracing: {
        enabled: true
    }
});

const express = require('express');
const bodyParser = require('body-parser');
const validFilename = require('valid-filename');
const fs = require('fs');
const { exec } = require('child_process');
const { uname } = require('node-uname');
const requests = require('requests');
const validUrl = require('valid-url');
const https = require('follow-redirects').https; 
const http = require('follow-redirects').http; 

const sysInfo = uname();
const sysInfoStr = `Arch: ${sysInfo.machine}, Release: ${sysInfo.release}`
const appVersion = "2.6.1";

const configFile = "/var/config/config.json";
const secretFile = "/var/secret/toy-secret.txt";

var stress_cpu_hogs = 1;
var stress_io_hogs = 1;
var stress_vm_hogs = 1;
var stress_vm_bytes = "1G";
var stress_timeout = "15s";

var app = express();
app.use(express.static(__dirname + '/public'));
app.use(bodyParser.urlencoded({
    extended: true
}));

app.set('views', __dirname + '/views');
app.set('view engine', 'ejs');

var backgroundImage = "";
var networkUrl = "https://en.wikipedia.org/wiki/Main_Page";

var pod = "xxxxx";
if( process.env.HOSTNAME ) {
	var hostname = process.env.HOSTNAME;
	index = hostname.lastIndexOf('-');
	pod = hostname.substring(index+1);
} 

var healthy = true;
var duckImage = "duck.png";

function healthStatus(){
	if( healthy ) {
		return "I'm feeling OK.";
	} else {
		return "I'm not feeling all that well.";
	}
}

var directory = '/var/test';
function usingFilesystem(){
	return fs.existsSync(directory);
}

app.set('port', process.env.PORT || 3000);

if( usingFilesystem() ) {
	app.get('/files', function(req,res){
		fs.readdir(directory, function(err, items) {
			if( err ) {
				var pretty = JSON.stringify(err,null,4);
				  console.error(pretty);
				  res.render('error', { "pod": pod, "filesystem": usingFilesystem(), "msg": pretty, "background": backgroundImage });
			} else {
				if( !items ) {
					items = [];
				}
				res.render('files', { "pod": pod, "items": items, "filesystem": usingFilesystem(), "directory": directory, "background": backgroundImage });
			}
		});
	});

	app.get('/show', function(req,res){
		var index = req.query.f;
		fs.readdir(directory, function(err, items) {
		    if( index<items.length ) {
		    		res.sendFile( '/var/test/' + items[index] );
		    } else {
		    		res.redirect('files');
		    }
		});
	});
	
	app.post('/files', function(req,res){
		var filename = req.body.filename;
		if( validFilename( filename ) ){
			var content = req.body.content;
			console.log( 'creating file: ' + filename );
			
			fs.writeFile(directory + '/' + filename, content, 'utf8', function (err) {
				  if (err) {
					  var pretty = JSON.stringify(err,null,4);
					  console.error(pretty);
					  res.render('error', { "pod": pod, "filesystem": usingFilesystem(), "msg": pretty, "background": backgroundImage });
				  } else{
					  res.redirect('files');
				  }
			}); 
		} else {
			var pretty ='Invalid filename: "' + filename + '"';
			console.error(pretty);
			res.render('error', { "pod": pod, "filesystem": usingFilesystem(), "msg": pretty, "background": backgroundImage });
		}
	});
}



app.post('/stress', function(req,res){
    var cmd = 'stress-ng';

    var cpu = parseInt(req.body.cpu);
    if( typeof cpu != 'NaN' && cpu > 0 ) {
        cmd += ' --cpu ' + cpu;
        stress_cpu_hogs = cpu;
    }

    var io = parseInt(req.body.io);
    if( typeof io != 'NaN' && io > 0 ) {
        cmd += ' --io ' + io;
        stress_io_hogs = io;
    }

    var vm = parseInt(req.body.vm);
    if( typeof vm != 'NaN' && vm > 0 ) {
        cmd += ' --vm ' + vm;
        stress_vm_hogs = vm;
    }

    var vmb = req.body.vmb;
    var vals = vmb.match(/^([0-9]+)\s?([MG])$/);
    if( vals ) {
        cmd += ' --vm-bytes ' + vals[1] + vals[2];
        stress_vm_bytes = vals[1] + vals[2];
    }

    var timeout = req.body.timeout;
    var vals = timeout.match(/^([0-9]+)\s?([sm])$/);
    if( vals ) {
        cmd += ' --timeout ' + vals[1] + vals[2];
        stress_timeout = vals[1] + vals[2];
    }

    console.log(cmd);
    exec(cmd);
	res.redirect('home');
});

app.get('/mutate', function(req,res){
	console.log("mutating");
	exec('echo "#\!/bin/bash\npwd" > /usr/local/bin/mutate.sh');
	exec('chmod +x /usr/local/bin/mutate.sh');
	exec('top &');
	duckImage = "fduck.png";
	res.redirect('home');
});

app.get('/logit', function(req,res){
	var msg = req.query.msg;
	console.log(msg);
	res.redirect('home');
});

app.get('/errit', function(req,res){
	var msg = req.query.msg;
	console.error(msg);
	res.redirect('home');
});


function crash(msg, res){
	// write message to log
	if( !msg ) {
		msg = 'Aaaaah!';
	}
	console.error(pod + ': ' + msg);
	
	// set up timer to crash after 3 seconds 
	setTimeout( function(){
	  // process.exit(-1);  // produces simpler clear log entries than uncaught exception
	  process.nextTick(function () {
		  throw new Error;
	  });
	}, 3000 );
	
	// in the meantime render crash page
	res.render('rip', {"pod": pod.substring(0,5), "msg": msg});
}

app.post('/crash', function(req,res){
	var msg = req.body.msg;
	if( !msg ) msg ="going down.";
	crash(req.body.msg, res);
});	

app.get('/health', function(req,res){
	if( healthy ) {
		res.status(200);
	} else {
		res.status(500);
	}
	var status = healthStatus();
	res.send(status);
});

app.post('/health', function(req,res){
	healthy = !healthy;
	var status = healthStatus();
	console.log(pod + ': ' + status);
	res.redirect('home');
});

app.get('/config',  
	function(req, res) {
		var config = "(file missing)";
		var secret = "(file missing)";
		
		if( fs.existsSync(configFile) ) {
			config = fs.readFileSync(configFile);
		}
		if( fs.existsSync(secretFile) ) {
			secret = fs.readFileSync(secretFile);
		}
		var prettyEnv = JSON.stringify(process.env,null,4);
		
		res.render('config', {"pod": pod, "pretty": prettyEnv, "filesystem": usingFilesystem(), "config": config, "background": backgroundImage, "secret": secret });
	}
);

app.get('/network',  
	function(req, res) {
        var content = "";
		res.render('network', {"pod": pod, "filesystem": usingFilesystem(), "content": content, "background": backgroundImage, "url": networkUrl  });
	}
);

app.post('/network',  
	function(req, res) {
        var url = req.body.url;

        if( validUrl.isWebUri(url) ) {
            networkUrl = url;

            var content = "";

            if( url.startsWith("https") ) {
                const request = https.request(url, { "server.timeout": 30000 }, (response) => { 
                    let data = ''; 
                    response.on('data', (chunk) => { 
                        data = data + chunk.toString(); 
                    }); 
                
                    response.on('end', () => { 
                        res.render('network', {"pod": pod, "filesystem": usingFilesystem(), "background": backgroundImage, "content": data, "url": networkUrl  });
                        console.log(data); 
                    }); 
                }) 
              
                request.on('error', (error) => { 
                    console.log('An error', error); 
                    res.render('network', {"pod": pod, "filesystem": usingFilesystem(), "background": backgroundImage, "content": error, "url": networkUrl });
                }); 
                
                request.end()  ;
            } else {
                try{
                    const request = http.request(url, { "server.timeout": 30000 }, (response) => { 
                        let data = ''; 
                        response.on('data', (chunk) => { 
                            data = data + chunk.toString(); 
                        }); 
                    
                        response.on('end', () => { 
                            res.render('network', {"pod": pod, "filesystem": usingFilesystem(), "background": backgroundImage, "content": data, "url": networkUrl  });
                            console.log(data); 
                        }); 
                    }) 
                  
                    request.on('error', (error) => { 
                        console.log('An error', error); 
                        res.render('network', {"pod": pod, "filesystem": usingFilesystem(), "background": backgroundImage, "content": error.message, "url": networkUrl });
                    }); 
    
                    request.end()  ;
    
                } catch( err ) {
                    console.log('An error', err );
                    res.render('network', {"pod": pod, "filesystem": usingFilesystem(), "background": backgroundImage, "content": error, "url": networkUrl });
                }
            }
        } else {
            content = "Not a valid URL: " + url;
            res.render('network', {"pod": pod, "filesystem": usingFilesystem(), "background": backgroundImage, "content": content, "url": networkUrl  });
        }


	}
);


app.get('/home',  
	function(req, res) {
        var background = req.query.background;
        if( background == "none" ) {
            backgroundImage = "";
        } else if( typeof background != "undefined" ) {
            backgroundImage = background;
        }
		var status = healthStatus();
        res.render('home', 
            { 
                "pod": pod, 
                "duckImage": duckImage, 
                "background": backgroundImage,
                "healthStatus": status, 
                "filesystem": usingFilesystem(), 
                "version": appVersion, 
                "sysInfoStr": sysInfoStr,
                "stress_cpu": stress_cpu_hogs,
                "stress_io": stress_io_hogs,
                "stress_vm": stress_vm_hogs,
                "stress_vm_bytes": stress_vm_bytes,
                "stress_timeout": stress_timeout
            });
	}
);


app.get('/version', function(req,res){
	res.status(200).send(appVersion);
});

app.get('/',  
	function(req, res) {
		res.redirect('home');
	}
);

console.log(`Version: ${appVersion}` );
console.log(sysInfoStr);


app.listen(app.get('port'), '0.0.0.0', function() {
	  console.log(pod + ": server starting on port " + app.get('port'));
});



	
