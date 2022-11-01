
# Create Tool Pod

```bash
oc apply -n default -f ./tools/10_turbonomic/create-actionscript-pod.yaml
```


Put public key in `actionscript-pod` Deployment under Environment `SSH_KEY`




# Configure Turbonomic

Add Target `Orchestrator/ActionScript`

Configure with:


Name or Address
actionscript-pod-service.default

Script Path
/root/actionmanifest.yaml

Port 
22

User ID
root

Private Token
<Your private key>

Public Host Key
<Your public key>




Questions:
Topology not showing
Execute Plan Steps
Action Script not showing



