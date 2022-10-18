# Get the Integration URL for Private Cloud (Fyre, TEE, ...) - CP4WAIOPS Tunnel


As the Slack integration requires a two-way communication and for Slack to communicate with the WAIOps server, you need to configure a tunnel, a feature that is included in CP4WAIOPS.  

> ❗To use this feature, make sure the Secure Tunnel is enabled in the installtion definition.
> 
> 
```yaml
apiVersion: orchestrator.aiops.ibm.com/v1alpha1
kind: Installation
metadata:
  name: {{ WAIOPS_NAME }}
  namespace: {{ WAIOPS_NAMESPACE }}
spec:
  imagePullSecret: ibm-entitlement-key
  license:
    accept: true
  pakModules:
    - enabled: true
      name: aiManager
    - enabled: true
      name: aiopsFoundation
    - enabled: true
      name: applicationManager
    - enabled: true    <-- Make sure this is set to true ⚠️
      name: connection
```

> The automated install does this by default.


1. Open your AIManager Web UI

1. In the `AI Manager` "Hamburger" Menu select `Administration`/`Tunnel`

   ![secure_gw_search](images/tunnel1.png)

1. Click `Create Connection`

1. Click on the `Shortcut` Option

	![secure_gw_search](images/tunnel2.png)

1. Enter any name that helps you identify the tunnel

	![secure_gw_search](images/tunnel3.png)

1. Enter the connection information for the Bastion/Tunnel Cluster:

	- Enter the login command you can find at the very end of the `LOGIN_TEC.txt` file
	- Enter a unique Namespace name to install tunnel (try to postfix it with your name)
	- Enter your registry password/pull-token from [https://myibm.ibm.com/products-services/containerlibrary](https://myibm.ibm.com/products-services/containerlibrary). This allows the CP4WAIOPS tunnel images to be pulled from the IBM Container Registry. 

	![secure_gw_search](images/tunnel4.png)

1. Click `Finish`

1. CP4WAIOPS will install the tunnel. This will take some time (up to 5 minutes)

	![secure_gw_search](images/tunnel5.png)

1. Copy the first URL and jot it down

	![secure_gw_search](images/tunnel6.png)


This means that you're good to go.

This is the URL you will be using for step 6.














