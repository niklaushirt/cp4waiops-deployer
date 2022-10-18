---------------------------------------------------------------
# 19 Detailed CP4WAIOPS Installation
---------------------------------------------------------------



## 19.1 Manually install AI Manager (Optional)

Only do this if you don't want to use 🐥 Easy Install



### 19..1.1 Adapt configuration

Adapt the `00_config_cp4waiops.yaml` file with the desired parameters:


#### 19.1.1.1 Automatic Login

The Playbook provides the means to automatically login to the cluster by filling out the following section of the config file:

```bash
# *************************************************************************************
# -------------------------------------------------------------------------------------
# OCP LOGIN PARAMETERS
# -------------------------------------------------------------------------------------
# *************************************************************************************
OCP_LOGIN: true
OCP_URL: https://c100-e.eu-gb.containers.cloud.ibm.com:31513
OCP_TOKEN: sha256~T6-cxxxxxxxxxxxx-dtuj3ELQfpioUhHms

#Version of your OCP Cluster (override by setting manually - 4.6, 4.7,...)
OCP_MAJOR_VERSION: automatic
```

<div style="page-break-after: always;"></div>

#### 19.1.1.2 Adapt AI Manager Config

```bash
# *************************************************************************************
# -------------------------------------------------------------------------------------
# CP4WAIOPS AI Manager INSTALL PARAMETERS
# -------------------------------------------------------------------------------------
# *************************************************************************************

# CP4WAIOPS Namespace for installation
WAIOPS_NAMESPACE: cp4waiops

# CP4WAIOPS Size of the install (small: PoC/Demo, tall: Production)
WAIOPS_SIZE: small # Leave at small unless you know what you're doing
# Version of the catalog subscription
SUBSCRIPTION_CHANNEL: CP4WAIOPS vx.y

# *************************************************************************************
# -------------------------------------------------------------------------------------
# CP4WAIOPS Storage Class Override
# -------------------------------------------------------------------------------------
# *************************************************************************************

# Override the Storage Class auto detection (ibmc-file-gold-gid, rook-cephfs, nfs-client, ...)
STORAGECLASS_FILE_OVERRIDE: not_configured
STORAGECLASS_BLOCK_OVERRIDE: not_configured

```


> There is no need to manually define the Storage Class anymore.
> The Playbook sets the storage class to `ibmc-file-gold-gid` for ROKS and `rook-cephfs` for Fyre.
> Otherwise it uses the default Storage Class.

> It is possible to override the Storage Class detection and force a custom Storage Class by setting `STORAGECLASS_XXX_OVERRIDE` in the config file.


<div style="page-break-after: always;"></div>



#### 19.1.1.3 Adapt Event Manager Config


```bash
# *************************************************************************************
# -------------------------------------------------------------------------------------
# CP4WAIOPS Event Manager INSTALL PARAMETERS
# -------------------------------------------------------------------------------------
# *************************************************************************************

# CP4WAIOPS Namespace for installation
EVTMGR_NAMESPACE: cp4waiops-evtmgr

```
<div style="page-break-after: always;"></div>

#### 19.1.1.4 Adapt Demo Components

```bash
# *************************************************************************************
# -------------------------------------------------------------------------------------
# DEMO INSTALL PARAMETERS
# -------------------------------------------------------------------------------------
# *************************************************************************************



# Print all credentials at the end of the installation
PRINT_LOGINS: true


```

<div style="page-break-after: always;"></div>

#### 19.1.1.4 Adapt Optional Components

```bash
# ******************************************************************************
# ------------------------------------------------------------------------------
# MODULE INSTALL PARAMETERS
# ------------------------------------------------------------------------------
# ******************************************************************************
# Install Rook-Ceph (Should Rook-Ceph be installed (automatic: install when on IBM Fyre) (enable, automatic, disable))
ROOK_CEPH_INSTALL_MODE: automatic


# LDAP Domain
LDAP_DOMAIN: ibm.com
# LDAP Base
LDAP_BASE: dc=ibm,dc=com
# LDAP Admin Password
LDAP_ADMIN_PASSWORD: P4ssw0rd!

# Turbonomic Storage Class (ibmc-block-gold, rook-cephfs, nfs-client, ...)
STORAGE_CLASS_TURBO: ibmc-block-gold

# Humio Storage Class (ibmc-block-gold, rook-cephfs, nfs-client, ...)
STORAGE_CLASS_HUMIO: ibmc-block-gold


```

<div style="page-break-after: always;"></div>

### 19.1.2 Get the installation token

You can get the installation (pull) token from [https://myibm.ibm.com/products-services/containerlibrary](https://myibm.ibm.com/products-services/containerlibrary).

This allows the CP4WAIOPS images to be pulled from the IBM Container Registry.

This token is being referred to as <PULL_SECRET_TOKEN> below and should look something like this (this is NOT a valid token):

```yaml
eyJhbGciOiJIUzI1NiJ9.eyJpc3adsgJJQk0gTWFya2V0cGxhY2UiLCJpYXQiOjE1Nzg0NzQzMjgsImp0aSI6IjRjYTM3gsdgdMzExNjQxZDdiMDJhMjRmMGMxMWgdsmZhIn0.Z-rqfSLJA-R-ow__tI3RmLx4mssdggdabvdcgdgYEkbYY  
```

<div style="page-break-after: always;"></div>

### 19.1.3 🚀 Start installation

Just run:

```bash
ansible-playbook ./ansible/01_aimanager-base-install.yaml -e CP_ENTITLEMENT_KEY=<REGISTRY_TOKEN> 


Example:
ansible-playbook ./ansible/01_aimanager-base-install.yaml -e CP_ENTITLEMENT_KEY=eyJhbGciOiJIUzI1NiJ9.eyJpc3adsgJJQk0gTWFya2V0cGxhY2UiLCJpYXQiOjE1Nzg0NzQzMjgsImp0aSI6IjRjYTM3gsdgdMzExNjQxZDdiMDJhMjRmMGMxMWgdsmZhIn0.Z-rqfSLJA-R-ow__tI3RmLx4mssdggdabvdcgdgYEkbYY
```

This will install:

- IBM Operator
- AI Manager
- OpenLDAP & Register with AI Manager
- AWX (Open Source Ansible Tower) with preloaded Playbooks
- RobotShop Demo App
- Demo Service Account 
- External Routes (Flink, Topology, ...)
- Disables ASM Service match rule 
- Creates valid certificate for Ingress (Slack) 


<div style="page-break-after: always;"></div>

