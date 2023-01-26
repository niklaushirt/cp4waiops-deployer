

# *************************************************************************************************************************************************
# --------------------------------------------------------------------------------------------------------------------------------------
# Create Gateway
# --------------------------------------------------------------------------------------------------------------------------------------
# *************************************************************************************************************************************************
    

echo "🚀 AWX - Get AWX URL"
export AWX_ROUTE=$(oc get route -n awx awx -o jsonpath={.spec.host})
export AWX_URL=$(echo "https://$AWX_ROUTE")
echo $AWX_URL
echo ""


echo "🚀 AWX - Get AWX Password"
export AWX_PWD=$(oc -n awx get secret awx-admin-password -o jsonpath='{.data.password}' | base64 --decode && echo)
echo $AWX_PWD
echo ""



# echo "🚀 AWX - Create AWX Execution Environment"
#     export RUNNER_IMAGE=niklaushirt/cp4waiops-awx:0.1.4
#     export result=$(curl -X "POST" -s "$AWX_URL/api/v2/execution_environments/" -u "admin:$AWX_PWD" --insecure \
#     -H 'content-type: application/json' \
#     -d $'{
#       "name": "CP4WAIOPS Execution Environment",
#       "description": "CP4WAIOPS Execution Environment",
#       "organization": null,
#       "image": "'$RUNNER_IMAGE'",
#       "credential": null,
#       "pull": "missing"
#     }')

#     if [[ $result =~ " already exists" ]];
#     then
#         export EXENV_ID=$(curl -X "GET" -s "$AWX_URL/api/v2/execution_environments/" -u "admin:$AWX_PWD" --insecure|jq -c '.results[]| select( .name == "CP4WAIOPS Execution Environment")|.id')
#     else
#         export EXENV_ID=$(echo $result|jq ".id")
#         sleep 60
#     fi 
#     echo "$EXENV_ID"





echo "🚀 AWX - Create AWX Project"
export AWX_REPO=https://github.com/niklaushirt/ansible-demo
export result=$(curl -X "POST" -s "$AWX_URL/api/v2/projects/" -u "admin:$AWX_PWD" --insecure \
-H 'content-type: application/json' \
-d $'{
    "name": "EDA Demo",
    "description": "EDA Demo",
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
    export PROJECT_ID=$(curl -X "GET" -s "$AWX_URL/api/v2/projects/" -u "admin:$AWX_PWD" --insecure|jq -c '.results[]| select( .name == "EDA Demo")|.id')
else
    export PROJECT_ID=$(echo $result|jq ".id")
fi
#sleep 60
echo "Project ID: $PROJECT_ID"
echo ""






# echo "🚀 AWX - Hack sync AWX Project"
#     export AWX_REPO=https://github.com/niklaushirt/ansible-demo
#     export result=$(curl -X "GET" -s "$AWX_URL/api/v2/projects/{{ AWX_PROJECT_ID }}/update" -u "admin:$AWX_PWD" --insecure \
#     -H 'content-type: application/json')

#     if [[ $result =~ " already exists" ]];
#     then
#         export PROJECT_ID=$(curl -X "GET" -s "$AWX_URL/api/v2/projects/" -u "admin:$AWX_PWD" --insecure|jq -c '.results[]| select( .name == "CP4WAIOPS Runbooks")|.id')
#     else
#         export PROJECT_ID=$(echo $result|jq ".id")
#     fi
#     #sleep 60
#     echo "$PROJECT_ID"




echo "🚀 AWX - Create AWX Inventory"
    export result=$(curl -X "POST" -s "$AWX_URL/api/v2/inventories/" -u "admin:$AWX_PWD" --insecure \
-H 'content-type: application/json' \
-d $'{
    "name": "EDA Demo",
    "description": "EDA Demo",
    "organization": 1,
    "project": '$PROJECT_ID',
    "kind": "",
    "host_filter": null,
    "variables": ""
}')

if [[ $result =~ " already exists" ]];
then
    export INVENTORY_ID=$(curl -X "GET" -s "$AWX_URL/api/v2/inventories/" -u "admin:$AWX_PWD" --insecure|jq -c '.results[]| select( .name == "CP4WAIOPS Runbooks")|.id')
else
    export INVENTORY_ID=$(echo $result|tr -d '\n'|jq ".id")
    sleep 15
fi
echo "$INVENTORY_ID"
echo "Inventory ID: $INVENTORY_ID"
echo ""


echo "🚀 AWX - Create AWX Template CatchAll"
    export result=$(curl -X "POST" -s "$AWX_URL/api/v2/job_templates/" -u "admin:$AWX_PWD" --insecure \
    -H 'content-type: application/json' \
    -d $'{
      "name": "CatchAll",
      "description": "CatchAll",
      "job_type": "run",
      "inventory": '$INVENTORY_ID',
      "project": '$PROJECT_ID',
      "playbook": "eda-demo/demo-playbook.yaml",
      "scm_branch": "",
      "extra_vars": "",
      "ask_variables_on_launch": true,
      "extra_vars": "PROVIDE: my_k8s_apiurl and my_k8s_apikey",
      "execution_environment": 1
    }')

    echo $result




echo "🚀 AWX - Create AWX Template ReconfigureGeneric"
    export result=$(curl -X "POST" -s "$AWX_URL/api/v2/job_templates/" -u "admin:$AWX_PWD" --insecure \
    -H 'content-type: application/json' \
    -d $'{
      "name": "ReconfigureGeneric",
      "description": "ReconfigureGeneric",
      "job_type": "run",
      "inventory": '$INVENTORY_ID',
      "project": '$PROJECT_ID',
      "playbook": "eda-demo/demo-playbook.yaml",
      "scm_branch": "",
      "extra_vars": "",
      "ask_variables_on_launch": true,
      "extra_vars": "PROVIDE: my_k8s_apiurl and my_k8s_apikey",
      "execution_environment": 1
    }')

    echo $result




echo "🚀 AWX - Create AWX Template ResizeGeneric"
    export result=$(curl -X "POST" -s "$AWX_URL/api/v2/job_templates/" -u "admin:$AWX_PWD" --insecure \
    -H 'content-type: application/json' \
    -d $'{
      "name": "ResizeGeneric",
      "description": "ResizeGeneric",
      "job_type": "run",
      "inventory": '$INVENTORY_ID',
      "project": '$PROJECT_ID',
      "playbook": "eda-demo/demo-playbook.yaml",
      "scm_branch": "",
      "extra_vars": "",
      "ask_variables_on_launch": true,
      "extra_vars": "PROVIDE: my_k8s_apiurl and my_k8s_apikey",
      "execution_environment": 1
    }')

    echo $result




echo "🚀 AWX - Create AWX Template ResizeCatalogue"
    export result=$(curl -X "POST" -s "$AWX_URL/api/v2/job_templates/" -u "admin:$AWX_PWD" --insecure \
    -H 'content-type: application/json' \
    -d $'{
      "name": "ResizeCatalogue",
      "description": "ResizeCatalogue",
      "job_type": "run",
      "inventory": '$INVENTORY_ID',
      "project": '$PROJECT_ID',
      "playbook": "eda-demo/demo-playbook.yaml",
      "scm_branch": "",
      "extra_vars": "",
      "ask_variables_on_launch": true,
      "extra_vars": "PROVIDE: my_k8s_apiurl and my_k8s_apikey",
      "execution_environment": 1
    }')

    echo $result


