---------------------------------------------------------------
# 19 INSTANA
---------------------------------------------------------------

## 19.1 Prerequisites

### 19.1.1 Get VM

This guide is for an Installation on Ubuntu 20.04.

Get a 32 vCPU | 64 GB VM (on IBM Cloud for example)

SSH into your VM

```bash
ssh ubuntu@159.122.143.xxx
```


### 19.1.2 Install Docker

```bash
sudo apt-get update
sudo apt-get -y install \
ca-certificates \
curl \
gnupg \
lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get -y install docker-ce docker-ce-cli containerd.io


sudo groupadd docker
sudo usermod -aG docker $USER

```
❗Logout and login again

## 19.2 Installing INSTANA

### 19.2.1 Preparing for installation

#### 19.2.1.1 Install the instana command line tool

1. Run commands as root

	```bash
	sudo su -
	```

1. Install the command line tool

	```bash
	echo "deb [arch=amd64] https://self-hosted.instana.io/apt generic main" > /etc/apt/sources.list.d/instana-product.list
	wget -qO - "https://self-hosted.instana.io/signing_key.gpg" | apt-key add -
	apt-get update
	apt-get install instana-console
	```

#### 19.2.1.2 Prepare the data directories

```bash
mkdir -p /mnt/data
mkdir -p /mnt/traces
mkdir -p /mnt/metrics
mkdir -p /var/log/instana
```

## 19.3 Install INSTANA instance

1. Start the docker containers

	```bash
	instana init
	```
	
	1. Select `single`
	1. Tenant name: `demo` (or whatever you like)
	1. Unit name: `demo` (or whatever you like)
	1. Agent key: Leave blank (hit enter)
	1. Download key: Enter your download key, obtained from IBM/Instana
	1. Sales key: Enter your sales key, obtained from IBM/Instana
	1. FQDN: enter the IP of your cluster (159.122.143.xxx)
	1. For the data directories: just hit enter
	1. Signed certificate file: Leave blank (hit enter)
	1. Private key file: Leave blank (hit enter)

	Wait for the installation to finish.


1. Get Admin login

	```bash
	instana configure admin
	
	  > Configure admin user ✓
	  > https://159.122.143.xxx
	  > E-Mail: admin@instana.local
	  > Password: hX85k7bTtu
	```

1. Import License

	```bash
	instana license download -k pgAxxxxxHoQ
	instana license import
	instana license verify
	```

1. Exit root 

	```bash
	exit
	```




