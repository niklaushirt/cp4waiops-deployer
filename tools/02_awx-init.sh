#!/bin/bash
echo "*****************************************************************************************************************************"
echo " 🐥 CloudPak for Watson AIOPs - Configure AWX"
echo "*****************************************************************************************************************************"
echo "  "

export AWX_ROUTE=$(oc get route -n awx awx -o jsonpath={.spec.host})
export AWX_URL=$(echo "https://$AWX_ROUTE")
echo ""
echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   🕦  Wait for AWX being ready"
while : ; do
      READY=$(curl -s $AWX_URL|grep "Application is not available")
      if [[  $READY  =~ "Application is not available" ]]; then
            echo "        AWX not ready yet. Waiting 15 seconds"
            sleep 30
      else
            break
      fi
done
echo "       ✅  OK: AWX ready"


echo ""
echo ""
echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   🛠️   Initialisation"

export AWX_ROUTE=$(oc get route -n awx awx -o jsonpath={.spec.host})
export ADMIN_USER=admin
export ADMIN_PASSWORD=$(oc -n awx get secret awx-admin-password -o jsonpath='{.data.password}' | base64 --decode && echo)

export OCP_URL=https://c108-e.eu-gb.containers.cloud.ibm.com:30553
export OCP_TOKEN=CHANGE-ME

export AWX_REPO=$INSTALL_REPO
export RUNNER_IMAGE=niklaushirt/cp4waiops-awx:0.1.4


echo "       ✅  Done"


echo ""
echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   🔎  Parameters"
echo "        🧔 ADMIN_USER:                $ADMIN_USER"
echo "        🔐 ADMIN_PASSWORD:            $ADMIN_PASSWORD"
echo "        🌏 AWX_ROUTE:                 $AWX_ROUTE"
echo ""     
echo "        📥 SHOW_TOOLS:                $SHOW_TOOLS"
echo "        📥 SHOW_ADDONS:               $SHOW_ADDONS"
echo "        📥 SHOW_CONFIG:               $SHOW_CONFIG"
echo "        📥 SHOW_DEBUG:                $SHOW_DEBUG"
echo ""
echo ""
echo ""

echo "        🔐 CP_ENTITLEMENT_KEY:     $CP_ENTITLEMENT_KEY"


echo ""
echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   🚀  Create AWX Execution Environment"
export result=$(curl -X "POST" -s "https://$AWX_ROUTE/api/v2/execution_environments/" -u "$ADMIN_USER:$ADMIN_PASSWORD" --insecure \
-H 'content-type: application/json' \
-d $'{
    "name": "CP4WAIOPS Execution Environment",
    "description": "CP4WAIOPS Execution Environment",
    "organization": null,
    "image": "'$RUNNER_IMAGE'",
    "credential": null,
    "pull": "missing"
}')

if [[ $result =~ " already exists" ]];
then
    export EXENV_ID=$(curl -X "GET" -s "https://$AWX_ROUTE/api/v2/execution_environments/" -u "$ADMIN_USER:$ADMIN_PASSWORD" --insecure|jq -c '.results[]| select( .name == "CP4WAIOPS Execution Environment")|.id')
    echo "        Already exists with ID:$EXENV_ID"
else
    echo "        Execution Environment created: "$(echo $result|jq ".created")
    export EXENV_ID=$(echo $result|jq ".id")
fi 


echo ""
echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   🚀  Create AWX Project"
export result=$(curl -X "POST" -s "https://$AWX_ROUTE/api/v2/projects/" -u "$ADMIN_USER:$ADMIN_PASSWORD" --insecure \
-H 'content-type: application/json' \
-d $'{
    "name": "CP4WAIOPS ANSIBLE INSTALLER",
    "description": "CP4WAIOPS ANSIBLE INSTALLER",
    "local_path": "",
    "scm_type": "git",
    "scm_url": "'$AWX_REPO'",
    "scm_branch": "",
    "scm_refspec": "",
    "scm_clean": false,
    "scm_track_submodules": false,
    "scm_delete_on_update": false,
    "credential": null,
    "timeout": 0,
    "organization": 1,
    "scm_update_on_launch": false,
    "scm_update_cache_timeout": 0,
    "allow_override": false,
    "default_environment": null
}')

if [[ $result =~ " already exists" ]];
then
    export PROJECT_ID=$(curl -X "GET" -s "https://$AWX_ROUTE/api/v2/projects/" -u "$ADMIN_USER:$ADMIN_PASSWORD" --insecure|jq -c '.results[]| select( .name == "CP4WAIOPS ANSIBLE INSTALLER")|.id')
    echo "        Already exists with ID:$PROJECT_ID"
else
    echo "        Project created: "$(echo $result|jq ".created")
    export PROJECT_ID=$(echo $result|jq ".id")
fi



echo ""
echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   🚀  Create AWX Inventory"
export result=$(curl -X "POST" -s "https://$AWX_ROUTE/api/v2/inventories/" -u "$ADMIN_USER:$ADMIN_PASSWORD" --insecure \
-H 'content-type: application/json' \
-d $'{
    "name": "CP4WAIOPS Install",
    "description": "CP4WAIOPS Install",
    "organization": 1,
    "project": '$PROJECT_ID',
    "kind": "",
    "host_filter": null,
    "variables": "---\nOCP_LOGIN: false\nOCP_URL: '$OCP_URL'\nOCP_TOKEN: '$OCP_TOKEN'\n#CP_ENTITLEMENT_KEY: '$CP_ENTITLEMENT_KEY'"
}
')

if [[ $result =~ " already exists" ]];
then
    export INVENTORY_ID=$(curl -X "GET" -s "https://$AWX_ROUTE/api/v2/inventories/" -u "$ADMIN_USER:$ADMIN_PASSWORD" --insecure|jq -c '.results[]| select( .name == "CP4WAIOPS Install")|.id')
    echo "        Already exists with ID:$INVENTORY_ID"
else
    echo "        Inventory created: "$(echo $result|tr -d '\n'|jq ".created")
    export INVENTORY_ID=$(echo $result|tr -d '\n'|jq ".id")
    echo ""
    echo "   ------------------------------------------------------------------------------------------------------------------------------"
    echo "   🕦  Waiting 15s"
    sleep 15
fi


echo ""
echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   ✅  RPOJECT Parameters"
echo "        🧔 EXECUTION_ENV:             $EXENV_ID"
echo "        🔐 INVENTORY_ID:              $INVENTORY_ID"
echo "        🌏 PROJECT_ID:                $PROJECT_ID"
echo ""






echo ""
echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   🚀  Create Job: Install CP4WAIOPS AI Manager And Demo Content - 3.3.2"
export result=$(curl -X "POST" -s "https://$AWX_ROUTE/api/v2/job_templates/" -u "$ADMIN_USER:$ADMIN_PASSWORD" --insecure \
-H 'content-type: application/json' \
-d $'{
    "name": "01_Install CP4WAIOPS AI Manager And Demo Content - 3.3.2",
    "description": "Install CP4WAIOPS AI Manager And Demo Content - 3.3.2",
    "job_type": "run",
    "inventory": '$INVENTORY_ID',
    "project": '$PROJECT_ID',
    "playbook": "ansible/00_cp4waiops-install.yaml",
    "scm_branch": "",
    "execution_environment": '$EXENV_ID',
    "ask_variables_on_launch": true,
    "extra_vars": "---\nconfig_file_path: \"./configs/cp4waiops-roks-aimanager-all-33.yaml\"\nCP_ENTITLEMENT_KEY: '$CP_ENTITLEMENT_KEY'"
}
')
if [[ $result =~ " already exists" ]];
then
    echo "        Already exists."
else
    echo "        Job created: "$(echo $result|jq ".created")
fi 


echo ""
echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   🚀  Create Job: Install CP4WAIOPS AI Manager Only - 3.3.2"
export result=$(curl -X "POST" -s "https://$AWX_ROUTE/api/v2/job_templates/" -u "$ADMIN_USER:$ADMIN_PASSWORD" --insecure \
-H 'content-type: application/json' \
-d $'{
    "name": "02_Install CP4WAIOPS AI Manager Only - 3.3.2",
    "description": "Install CP4WAIOPS AI Manager Only - 3.3.2",
    "job_type": "run",
    "inventory": '$INVENTORY_ID',
    "project": '$PROJECT_ID',
    "playbook": "ansible/00_cp4waiops-install.yaml",
    "scm_branch": "",
    "extra_vars": "",
    "execution_environment": '$EXENV_ID',
    "ask_variables_on_launch": true,
    "extra_vars": "---\nconfig_file_path: \"./configs/cp4waiops-roks-aimanager-33.yaml\"\nCP_ENTITLEMENT_KEY: '$CP_ENTITLEMENT_KEY'"
}
')
if [[ $result =~ " already exists" ]];
then
    echo "        Already exists."
else
    echo "        Job created: "$(echo $result|jq ".created")
fi 




echo ""
echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   🚀  Create Job: Install CP4WAIOPS AI Manager Demo Content - 3.3.2"
export result=$(curl -X "POST" -s "https://$AWX_ROUTE/api/v2/job_templates/" -u "$ADMIN_USER:$ADMIN_PASSWORD" --insecure \
-H 'content-type: application/json' \
-d $'{
    "name": "03_Install CP4WAIOPS AI Manager Demo Content - 3.3.2",
    "description": "Install CP4WAIOPS AI Manager Demo Content - 3.3.2",
    "job_type": "run",
    "inventory": '$INVENTORY_ID',
    "project": '$PROJECT_ID',
    "playbook": "ansible/00_cp4waiops-install.yaml",
    "scm_branch": "",
    "extra_vars": "",
    "execution_environment": '$EXENV_ID',
    "ask_variables_on_launch": true,
    "extra_vars": "---\nconfig_file_path: \"./configs/cp4waiops-roks-aimanager-demo-content-33.yaml\"\nCP_ENTITLEMENT_KEY: '$CP_ENTITLEMENT_KEY'"
}
')
if [[ $result =~ " already exists" ]];
then
    echo "        Already exists."
else
    echo "        Job created: "$(echo $result|jq ".created")
fi 



echo ""
echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   🚀  Create Job: Install CP4WAIOPS Event Manager - 3.3.2"
export result=$(curl -X "POST" -s "https://$AWX_ROUTE/api/v2/job_templates/" -u "$ADMIN_USER:$ADMIN_PASSWORD" --insecure \
-H 'content-type: application/json' \
-d $'{
    "name": "04_Install CP4WAIOPS Event Manager - 3.3.2",
    "description": "02_Install CP4WAIOPS Event Manager - 3.3.2",
    "job_type": "run",
    "inventory": '$INVENTORY_ID',
    "project": '$PROJECT_ID',
    "playbook": "ansible/00_cp4waiops-install.yaml",
    "scm_branch": "",
    "extra_vars": "",
    "execution_environment": '$EXENV_ID',
    "ask_variables_on_launch": true,
    "extra_vars": "---\nconfig_file_path: \"./configs/cp4waiops-roks-eventmanager-33.yaml\"\nCP_ENTITLEMENT_KEY: '$CP_ENTITLEMENT_KEY'"
}
')
if [[ $result =~ " already exists" ]];
then
    echo "        Already exists."
else
    echo "        Job created: "$(echo $result|jq ".created")
fi 



echo ""
echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   🚀  Create Job: Install CP4WAIOPS Infrastructure Management - 3.3.2"
export result=$(curl -X "POST" -s "https://$AWX_ROUTE/api/v2/job_templates/" -u "$ADMIN_USER:$ADMIN_PASSWORD" --insecure \
-H 'content-type: application/json' \
-d $'{
    "name": "05_Install CP4WAIOPS Infrastructure Management - 3.3.2",
    "description": "03_Install CP4WAIOPS Infrastructure Management - 3.3.2",
    "job_type": "run",
    "inventory": '$INVENTORY_ID',
    "project": '$PROJECT_ID',
    "playbook": "ansible/00_cp4waiops-install.yaml",
    "scm_branch": "",
    "extra_vars": "",
    "execution_environment": '$EXENV_ID',
    "ask_variables_on_launch": true,
    "extra_vars": "---\nconfig_file_path: \"./configs/cp4waiops-roks-inframgt-33.yaml\"\nCP_ENTITLEMENT_KEY: '$CP_ENTITLEMENT_KEY'"
}
')

if [[ $result =~ " already exists" ]];
then
    echo "        Already exists."
else
    echo "        Job created: "$(echo $result|jq ".created")
fi 




echo ""
echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   🚀  Create Job: Install CP4WAIOPS AI Manager And Demo Content - 3.4 FVT"
export result=$(curl -X "POST" -s "https://$AWX_ROUTE/api/v2/job_templates/" -u "$ADMIN_USER:$ADMIN_PASSWORD" --insecure \
-H 'content-type: application/json' \
-d $'{
    "name": "01_Install CP4WAIOPS AI Manager And Demo Content - 3.4 FVT",
    "description": "Install CP4WAIOPS AI Manager And Demo Content - 3.4 FVT",
    "job_type": "run",
    "inventory": '$INVENTORY_ID',
    "project": '$PROJECT_ID',
    "playbook": "ansible/00_cp4waiops-install.yaml",
    "scm_branch": "",
    "execution_environment": '$EXENV_ID',
    "ask_variables_on_launch": true,
    "extra_vars": "---\nconfig_file_path: \"./configs/cp4waiops-roks-aimanager-all-34.yaml\"\nCP_ENTITLEMENT_KEY: '$CP_ENTITLEMENT_KEY'"
}
')
if [[ $result =~ " already exists" ]];
then
    echo "        Already exists."
else
    echo "        Job created: "$(echo $result|jq ".created")
fi 


echo ""
echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   🚀  Create Job: Install CP4WAIOPS AI Manager Only - 3.4 FVT"
export result=$(curl -X "POST" -s "https://$AWX_ROUTE/api/v2/job_templates/" -u "$ADMIN_USER:$ADMIN_PASSWORD" --insecure \
-H 'content-type: application/json' \
-d $'{
    "name": "02_Install CP4WAIOPS AI Manager Only - 3.4 FVT",
    "description": "Install CP4WAIOPS AI Manager Only - 3.4 FVT",
    "job_type": "run",
    "inventory": '$INVENTORY_ID',
    "project": '$PROJECT_ID',
    "playbook": "ansible/00_cp4waiops-install.yaml",
    "scm_branch": "",
    "extra_vars": "",
    "execution_environment": '$EXENV_ID',
    "ask_variables_on_launch": true,
    "extra_vars": "---\nconfig_file_path: \"./configs/cp4waiops-roks-aimanager-34.yaml\"\nCP_ENTITLEMENT_KEY: '$CP_ENTITLEMENT_KEY'"
}
')
if [[ $result =~ " already exists" ]];
then
    echo "        Already exists."
else
    echo "        Job created: "$(echo $result|jq ".created")
fi 




echo ""
echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   🚀  Create Job: Install CP4WAIOPS AI Manager Demo Content - 3.4 FVT"
export result=$(curl -X "POST" -s "https://$AWX_ROUTE/api/v2/job_templates/" -u "$ADMIN_USER:$ADMIN_PASSWORD" --insecure \
-H 'content-type: application/json' \
-d $'{
    "name": "03_Install CP4WAIOPS AI Manager Demo Content - 3.4 FVT",
    "description": "Install CP4WAIOPS AI Manager Demo Content - 3.4 FVT",
    "job_type": "run",
    "inventory": '$INVENTORY_ID',
    "project": '$PROJECT_ID',
    "playbook": "ansible/00_cp4waiops-install.yaml",
    "scm_branch": "",
    "extra_vars": "",
    "execution_environment": '$EXENV_ID',
    "ask_variables_on_launch": true,
    "extra_vars": "---\nconfig_file_path: \"./configs/cp4waiops-roks-aimanager-demo-content-34.yaml\"\nCP_ENTITLEMENT_KEY: '$CP_ENTITLEMENT_KEY'"
}
')
if [[ $result =~ " already exists" ]];
then
    echo "        Already exists."
else
    echo "        Job created: "$(echo $result|jq ".created")
fi 



echo ""
echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   🚀  Create Job: Install CP4WAIOPS Event Manager - 3.4 FVT"
export result=$(curl -X "POST" -s "https://$AWX_ROUTE/api/v2/job_templates/" -u "$ADMIN_USER:$ADMIN_PASSWORD" --insecure \
-H 'content-type: application/json' \
-d $'{
    "name": "04_Install CP4WAIOPS Event Manager - 3.4 FVT",
    "description": "02_Install CP4WAIOPS Event Manager - 3.4 FVT",
    "job_type": "run",
    "inventory": '$INVENTORY_ID',
    "project": '$PROJECT_ID',
    "playbook": "ansible/00_cp4waiops-install.yaml",
    "scm_branch": "",
    "extra_vars": "",
    "execution_environment": '$EXENV_ID',
    "ask_variables_on_launch": true,
    "extra_vars": "---\nconfig_file_path: \"./configs/cp4waiops-roks-eventmanager-34.yaml\"\nCP_ENTITLEMENT_KEY: '$CP_ENTITLEMENT_KEY'"
}
')
if [[ $result =~ " already exists" ]];
then
    echo "        Already exists."
else
    echo "        Job created: "$(echo $result|jq ".created")
fi 



echo ""
echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   🚀  Create Job: Install CP4WAIOPS Infrastructure Management - 3.4 FVT"
export result=$(curl -X "POST" -s "https://$AWX_ROUTE/api/v2/job_templates/" -u "$ADMIN_USER:$ADMIN_PASSWORD" --insecure \
-H 'content-type: application/json' \
-d $'{
    "name": "05_Install CP4WAIOPS Infrastructure Management - 3.4 FVT",
    "description": "03_Install CP4WAIOPS Infrastructure Management - 3.4 FVT",
    "job_type": "run",
    "inventory": '$INVENTORY_ID',
    "project": '$PROJECT_ID',
    "playbook": "ansible/00_cp4waiops-install.yaml",
    "scm_branch": "",
    "extra_vars": "",
    "execution_environment": '$EXENV_ID',
    "ask_variables_on_launch": true,
    "extra_vars": "---\nconfig_file_path: \"./configs/cp4waiops-roks-inframgt-34.yaml\"\nCP_ENTITLEMENT_KEY: '$CP_ENTITLEMENT_KEY'"
}
')

if [[ $result =~ " already exists" ]];
then
    echo "        Already exists."
else
    echo "        Job created: "$(echo $result|jq ".created")
fi 



echo ""
echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   🚀  Create Job: Get CP4WAIOPS Logins"
export result=$(curl -X "POST" -s "https://$AWX_ROUTE/api/v2/job_templates/" -u "$ADMIN_USER:$ADMIN_PASSWORD" --insecure \
-H 'content-type: application/json' \
-d $'{
    "name": "10_Get CP4WAIOPS Logins",
    "description": "10_Get CP4WAIOPS Logins",
    "job_type": "run",
    "inventory": '$INVENTORY_ID',
    "project": '$PROJECT_ID',
    "playbook": "ansible/90_get-all-logins.yaml",
    "scm_branch": "",
    "extra_vars": "",
    "execution_environment": '$EXENV_ID'
}
')

if [[ $result =~ " already exists" ]];
then
    echo "        Already exists."
else
    echo "        Job created: "$(echo $result|jq ".created")
fi 



echo ""
echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   🚀  Create Job: Install Turbonomic"
export result=$(curl -X "POST" -s "https://$AWX_ROUTE/api/v2/job_templates/" -u "$ADMIN_USER:$ADMIN_PASSWORD" --insecure \
-H 'content-type: application/json' \
-d $'{
    "name": "10_Install Turbonomic",
    "description": "Install Turbonomic",
    "job_type": "run",
    "inventory": '$INVENTORY_ID',
    "project": '$PROJECT_ID',
    "playbook": "ansible/00_cp4waiops-install.yaml",
    "scm_branch": "",
    "extra_vars": "---\nconfig_file_path: \"./configs/cp4waiops-roks-turbonomic.yaml\"\nCP_ENTITLEMENT_KEY: '$CP_ENTITLEMENT_KEY'",
    "execution_environment": '$EXENV_ID'
}
')

if [[ $result =~ " already exists" ]];
then
    echo "        Already exists."
else
    echo "        Job created: "$(echo $result|jq ".created")
fi 



echo ""
echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   🚀  Create Job: Install ELK"
export result=$(curl -X "POST" -s "https://$AWX_ROUTE/api/v2/job_templates/" -u "$ADMIN_USER:$ADMIN_PASSWORD" --insecure \
-H 'content-type: application/json' \
-d $'{
    "name": "11_Install ELK",
    "description": "Install ELK",
    "job_type": "run",
    "inventory": '$INVENTORY_ID',
    "project": '$PROJECT_ID',
    "playbook": "ansible/00_cp4waiops-install.yaml",
    "scm_branch": "",
    "extra_vars": "---\nconfig_file_path: \"./configs/cp4waiops-roks-elk.yaml\"\nCP_ENTITLEMENT_KEY: '$CP_ENTITLEMENT_KEY'",
    "execution_environment": '$EXENV_ID'
}
')

if [[ $result =~ " already exists" ]];
then
    echo "        Already exists."
else
    echo "        Job created: "$(echo $result|jq ".created")
fi 



echo "    "
echo "    "
echo "    "
echo "    "
echo " -----------------------------------------------------------------------------------------------------------------------------------------------"
echo " -----------------------------------------------------------------------------------------------------------------------------------------------"
echo " 🔎 AWX Installed Content"
echo " -----------------------------------------------------------------------------------------------------------------------------------------------"
echo " -----------------------------------------------------------------------------------------------------------------------------------------------"
echo "    "
echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
echo "    📥 AWX Projects"
curl -X "GET" -s "https://$AWX_ROUTE/api/v2/projects/" -u "$ADMIN_USER:$ADMIN_PASSWORD" --insecure|jq ".results[].name"| sed 's/^/         /'
echo "    "
echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
echo "    📥 AWX Inventories"
curl -X "GET" -s "https://$AWX_ROUTE/api/v2/inventories/" -u "$ADMIN_USER:$ADMIN_PASSWORD" --insecure|jq ".results[].name"| sed 's/^/         /'
echo "    "
echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
echo "    📥 AWX Execution Environments"
curl -X "GET" -s "https://$AWX_ROUTE/api/v2/execution_environments/" -u "$ADMIN_USER:$ADMIN_PASSWORD" --insecure|jq ".results[].name"| sed 's/^/         /'
echo "    "
echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
echo "    📥 AWX Job Templates"
curl -X "GET" -s "https://$AWX_ROUTE/api/v2/job_templates/" -u "$ADMIN_USER:$ADMIN_PASSWORD" --insecure|jq ".results[].name"| sed 's/^/         /'
echo "    "
echo "    "
echo "    "


echo " -----------------------------------------------------------------------------------------------------------------------------------------------"
echo " -----------------------------------------------------------------------------------------------------------------------------------------------"
echo " 🚀 AWX Access"
echo " -----------------------------------------------------------------------------------------------------------------------------------------------"
echo " -----------------------------------------------------------------------------------------------------------------------------------------------"
echo "    "
echo "     📥 AWX :"
echo ""
echo "         🌏 URL:      https://$AWX_ROUTE"
echo "         🧑 User:     admin"
echo "         🔐 Password: $(oc -n awx get secret awx-admin-password -o jsonpath='{.data.password}' | base64 --decode && echo)"
echo "    "
echo "    "


echo "*****************************************************************************************************************************"
echo " ✅ DONE"
echo "*****************************************************************************************************************************"

while true
do
    sleep 60000                           
done

