# KubeToy
## v2.6.1

A simple Node.js application that deploys to Kubernetes, including OpenShift 4.x.  It is used to help 
explore the functionality of Kubernetes.  This toy application has a user interface 
which you can:

* write messages to the log (stdout / stderr)
* intentionally crash the application to view auto repair
* toggle a liveness probe and monitor kuberenetes behavior  
* read config maps and secrets from environment vars and files
* get a HTTP resource (i.e. from a local service)
* if connected to shared storage, read and write files
* [stress](https://linux.die.net/man/1/stress) the container with excessive cpu usage, memory allocation and/or disk I/O

KubeToy can be installed with these [kubernetes definition 
files](https://gitlab.com/ibmhccoc/kubetoy/-/tree/master/deployment).  








