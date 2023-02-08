---------------------------------------------------------------
# 18 Detailed Prerequisites
---------------------------------------------------------------


## 18.1 OpenShift requirements

I installed the demo in a ROKS environment.

You'll need:

- ROKS 4.8 (4.7 should work also)
- 5x worker nodes Flavor `b3c.16x64` (so 16 CPU / 64 GB)

You might get away with less if you don't install some components (ELK, Turbonomic,...)



## 18.2 Tooling

You need the following tools installed in order to follow through this guide:

- ansible
- oc (4.7 or greater)
- jq
- kubectl (Not needed anymore - replaced by `oc`)
- kafkacat (only for training and debugging)
- elasticdump (only for training and debugging)
- IBM cloudctl (only for LDAP)

<div style="page-break-after: always;"></div>

### 18.2.1 On Mac - Automated (preferred)

Use Option 🐥`71` in Easy Install to install the `Prerequisites for Mac`

#### 18.2.1.1 On Mac - Manual

Only do this if you don't want to use 🐥 Easy Install

Or install them manually:


```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install ansible
ansible-galaxy collection install community.kubernetes:1.2.1
ansible-galaxy collection install kubernetes.core:2.2.3
ansible-galaxy collection install cloud.common
pip install openshift pyyaml kubernetes 
brew install kafkacat
brew install node
brew install wget
npm install elasticdump -g
brew install jq

curl -L https://github.com/IBM/cloud-pak-cli/releases/latest/download/cloudctl-darwin-amd64.tar.gz -o cloudctl-darwin-amd64.tar.gz
tar xfvz cloudctl-darwin-amd64.tar.gz
sudo mv cloudctl-darwin-amd64 /usr/local/bin/cloudctl
rm cloudctl-darwin-amd64.tar.gz

```


Get oc and kubectl (optional) from [here](https://github.com/openshift/okd/releases/)

or use :

```bash
wget https://github.com/openshift/okd/releases/download/4.7.0-0.okd-2021-07-03-190901/openshift-client-mac-4.7.0-0.okd-2021-07-03-190901.tar.gz -O oc.tar.gz
tar xfzv oc.tar.gz
sudo mv oc /usr/local/bin
sudo mv kubectl /usr/local/bin.  (this is optional)
rm oc.tar.gz
rm README.md
```



I highly recomment installing the `k9s` tool :

```bash
wget https://github.com/derailed/k9s/releases/download/v0.24.15/k9s_Darwin_x86_64.tar.gz
tar xfzv k9s_Darwin_x86_64.tar.gz
sudo mv k9s /usr/local/bin
rm LICENSE
rm README.md
```


<div style="page-break-after: always;"></div>

### 18.2.2 On Ubuntu Linux - Automated (preferred) 

Use Option 🐥`72` in Easy Install to install the `Prerequisites for Ubuntu`


#### 18.2.2.1 On Ubuntu Linux - Manual

Only do this if you don't want to use 🐥 Easy Install

Or install them manually:


`sed` comes preinstalled

```bash
sudo apt-get install -y ansible
ansible-galaxy collection install community.kubernetes:1.2.1
ansible-galaxy collection install kubernetes.core:2.2.3
pip install openshift pyyaml kubernetes 
sudo apt-get install -y kafkacat
sudo apt-get install -y npm
sudo apt-get install -y jq
sudo npm install elasticdump -g

curl -L https://github.com/IBM/cloud-pak-cli/releases/latest/download/cloudctl-linux-amd64.tar.gz -o cloudctl-linux-amd64.tar.gz
tar xfvz cloudctl-linux-amd64.tar.gz
sudo mv cloudctl-linux-amd64 /usr/local/bin/cloudctl
rm cloudctl-linux-amd64.tar.gz

```

Get oc and oc from [here](https://github.com/openshift/okd/releases/)

or use :

```bash
wget https://github.com/openshift/okd/releases/download/4.7.0-0.okd-2021-07-03-190901/openshift-client-linux-4.7.0-0.okd-2021-07-03-190901.tar.gz -O oc.tar.gz
tar xfzv oc.tar.gz
sudo mv oc /usr/local/bin
sudo mv kubectl /usr/local/bin
rm oc.tar.gz
rm README.md
```

I highly recomment installing the `k9s` tool :

```bash
wget https://github.com/derailed/k9s/releases/download/v0.24.15/k9s_Linux_x86_64.tar.gz
tar xfzv k9s_Linux_x86_64.tar.gz
sudo mv k9s /usr/local/bin
rm LICENSE
rm README.md
```

<div style="page-break-after: always;"></div>

## 18.3 Get the scripts and code from GitHub


### 18.3.1 Clone the GitHub Repository (preferred)

And obviosuly you'll need to download this repository to use the scripts.


```
git clone https://<YOUR GIT TOKEN>@github.ibm.com/NIKH/aiops-install-ansible.git 
```

You can create your GIT token [here](https://github.ibm.com/settings/tokens).

#### 18.3.1.1 Refresh the code from GitHub

Make sure you have the latest version:

```
git checkout origin/master -f | git checkout master -f | git pull origin master
```

Or create an alias for reuse:

```
alias gitrefresh='git checkout origin/master -f | git checkout master -f | git pull origin master'
```

### 18.3.2 Download the GitHub Repository in a ZIP (not preferred)

Simply click on the green `CODE` button and select `Download Zip` to download the scripts and code.

❗ If there are updates you have to re-download the ZIP.


<div style="page-break-after: always;"></div>



