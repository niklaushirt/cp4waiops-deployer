cat << EOF | oc apply -f -
apiVersion: v1                     
kind: Namespace
metadata:
  name: cp4waiops-installation
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: cp4waiops-installer-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: default
    namespace: cp4waiops-installation
---
apiVersion: batch/v1
kind: Job
metadata:
  name: waiops-easy-install-aimanager-practicum
  namespace: cp4waiops-installation
spec:
  serviceAccountname: cp4waiops-installer-admin
  template:
    spec:
      containers:
        - name: install
          image: quay.io/niklaushirt/cp4waiops-tools:2.0
          imagePullPolicy: IfNotPresent
          resources:
            requests:
              memory: "64Mi"
              cpu: "150m"
            limits:
              memory: "1256Mi"
              cpu: "1200m"
          command:
            - /bin/sh
            - -c
            - |
              #!/bin/bash
              #set -x

              echo "*****************************************************************************************************************************"
              echo " ✅ STARTING: INSTALL CP4WAIOps with Demo Content"
              echo "*****************************************************************************************************************************"
              echo ""
              echo ""
              echo "------------------------------------------------------------------------------------------------------------------------------"
              echo " 📥 Clone Repo https://github.com/niklaushirt/cp4waiops-deployer.git"
              git clone https://github.com/niklaushirt/cp4waiops-deployer.git -b cp4waiops_stable

              
              cd cp4waiops-deployer
              echo ""
              echo ""

              echo "------------------------------------------------------------------------------------------------------------------------------"
              echo " 🚀 Prepare Ansible"
              ansible-galaxy collection install community.kubernetes:1.2.1
              ansible-galaxy collection install kubernetes.core:2.2.3
              ansible-galaxy collection install cloud.common
              pip install openshift pyyaml kubernetes 
              echo ""
              echo ""

              echo "------------------------------------------------------------------------------------------------------------------------------"
              echo " 🚀 Starting Installation"
              ansible-playbook ./ansible/00_cp4waiops-install.yaml -e "config_file_path=./configs/cp4waiops-practicum.yaml"
              echo ""
              echo ""
              echo "*****************************************************************************************************************************"
              echo " ✅ DONE"
              echo "*****************************************************************************************************************************"

              while true
              do
                sleep 1000
              done

      restartPolicy: Never
  backoffLimit: 4
EOF