echo "   __________  __ ___       _____    ________            "
echo "  / ____/ __ \/ // / |     / /   |  /  _/ __ \____  _____"
echo " / /   / /_/ / // /| | /| / / /| |  / // / / / __ \/ ___/"
echo "/ /___/ ____/__  __/ |/ |/ / ___ |_/ // /_/ / /_/ (__  ) "
echo "\____/_/      /_/  |__/|__/_/  |_/___/\____/ .___/____/  "
echo "                                          /_/            "
echo ""
echo ""
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo ""
echo " 🚀  CP4WAIOPS  Create and run Training Definitions"
echo ""
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo ""
echo ""

# https://ai-platform-api-cp4waiops.itzroks-270003bu3k-qd899z-6ccd7f378ae819553d37d5f2ee142bd6-0000.eu-de.containers.appdomain.cloud/graphql
#   mutation toggleAlgorithmEnablement {
#     toggleAlgorithmEnablement(algorithmName: Moving_Average_Log_Anomaly_Detection) {
#       message
#       status
#     }
#   }




echo "  ***************************************************************************************************************************************************"
echo "   🛠️   Get Namespace"
export WAIOPS_NAMESPACE=$(oc get po -A|grep aiops-orchestrator-controller |awk '{print$1}')
oc project $WAIOPS_NAMESPACE >/tmp/templog.txt 2>&1
echo "       Namespace: $WAIOPS_NAMESPACE"
echo ""

echo "  ***************************************************************************************************************************************************"
echo "   🛠️   Get Route"
oc create route passthrough ai-platform-api -n $WAIOPS_NAMESPACE  --service=aimanager-aio-ai-platform-api-server --port=4000 --insecure-policy=Redirect --wildcard-policy=None
export ROUTE=$(oc get route -n $WAIOPS_NAMESPACE ai-platform-api  -o jsonpath={.spec.host})
echo "       Route: $ROUTE"
echo ""


# TURN OFF ANALYSIS RSA
export result=$(curl "https://$ROUTE/graphql" -k -s -H 'Accept-Encoding: gzip, deflate, br' -H 'Content-Type: application/json' -H 'Accept: application/json' -H 'Connection: keep-alive' -H 'DNT: 1' -H 'Origin: https://ai-platform-api-cp4waiops.itzroks-270003bu3k-qd899z-6ccd7f378ae819553d37d5f2ee142bd6-0000.eu-de.containers.appdomain.cloud' --data-binary '{"query":"  mutation toggleAlgorithmEnablement {\n    toggleAlgorithmEnablement(algorithmName: Moving_Average_Log_Anomaly_Detection) {\n      message\n      status\n    }\n  }\n"}' --compressed)

# CREATE DATASET LAD
export result=$(curl 'https://ai-platform-api-cp4waiops.itzroks-270003bu3k-pp4gqc-6ccd7f378ae819553d37d5f2ee142bd6-0000.eu-gb.containers.appdomain.cloud/graphql' -H 'Accept-Encoding: gzip, deflate, br' -H 'Content-Type: application/json' -H 'Accept: application/json' -H 'Connection: keep-alive' -H 'DNT: 1' -H 'Origin: https://ai-platform-api-cp4waiops.itzroks-270003bu3k-pp4gqc-6ccd7f378ae819553d37d5f2ee142bd6-0000.eu-gb.containers.appdomain.cloud' --data-binary '{"query":"mutation createDataSet {\n  createDataSet(\n    startTimestamp: \"2021-05-05T00:00:00.000Z\"\n    endTimestamp: \"2021-05-07T00:00:00.000Z\"\n    notes: \"Automatically created by Nicks scripts\"\n    connections:\"\"\n  ) {\n    dataSetId\n  }\n}"}' --compressed

# CFREATE ANALYSIS LAD
export result=$(curl 'https://ai-platform-api-cp4waiops.itzroks-270003bu3k-pp4gqc-6ccd7f378ae819553d37d5f2ee142bd6-0000.eu-gb.containers.appdomain.cloud/graphql' -H 'Accept-Encoding: gzip, deflate, br' -H 'Content-Type: application/json' -H 'Accept: application/json' -H 'Connection: keep-alive' -H 'DNT: 1' -H 'Origin: https://ai-platform-api-cp4waiops.itzroks-270003bu3k-pp4gqc-6ccd7f378ae819553d37d5f2ee142bd6-0000.eu-gb.containers.appdomain.cloud' --data-binary '{"query":"mutation createTrainingDefinition {\n  createTrainingDefinition(\n    definitionName: \"LogAnomalyDetection\"\n    algorithmName: Log_Anomaly_Detection\n    dataSetIds: \"G6SSnH4BWKNKgDnQH8zu\"\n    version: \"v0\"\n    description: \"Automatically created by Nicks scripts\"\n    createdBy: \"demo\"\n    promoteOption: whenTrainingComplete\n    trainingSchedule: {\n      frequency: manual\n      repeat: daily\n      timeRangeValidStart: null\n      timeRangeValidEnd: null\n      noEndDate: false\n    }\n  ) {\n    status\n    message\n  }\n}"}' --compressed)

# CFREATE ANALYSIS TG
curl 'https://ai-platform-api-cp4waiops.itzroks-270003bu3k-pp4gqc-6ccd7f378ae819553d37d5f2ee142bd6-0000.eu-gb.containers.appdomain.cloud/graphql' -H 'Accept-Encoding: gzip, deflate, br' -H 'Content-Type: application/json' -H 'Accept: application/json' -H 'Connection: keep-alive' -H 'DNT: 1' -H 'Origin: https://ai-platform-api-cp4waiops.itzroks-270003bu3k-pp4gqc-6ccd7f378ae819553d37d5f2ee142bd6-0000.eu-gb.containers.appdomain.cloud' --data-binary '{"query":"\nmutation createTrainingDefinition {\n  createTrainingDefinition(\n    definitionName: \"TemporalGrouping\"\n    algorithmName: Temporal_Grouping\n    version: \"v0\"\n    description: \"Automatically created by Nicks scripts\"\n    createdBy: \"demo\"\n    promoteOption: manual\n    trainingSchedule: {\n      frequency: scheduled\n      repeat: daily\n      timeRangeValidStart: \"2022-01-26T00:00:00.000+01:00\"\n      timeRangeValidEnd: null\n      noEndDate: true\n    }\n  ) {\n    status\n    message\n  }\n}\n"}' --compressed)

# CFREATE ANALYSIS CR
export result=$(curl 'https://ai-platform-api-cp4waiops.itzroks-270003bu3k-pp4gqc-6ccd7f378ae819553d37d5f2ee142bd6-0000.eu-gb.containers.appdomain.cloud/graphql' -H 'Accept-Encoding: gzip, deflate, br' -H 'Content-Type: application/json' -H 'Accept: application/json' -H 'Connection: keep-alive' -H 'DNT: 1' -H 'Origin: https://ai-platform-api-cp4waiops.itzroks-270003bu3k-pp4gqc-6ccd7f378ae819553d37d5f2ee142bd6-0000.eu-gb.containers.appdomain.cloud' --data-binary '{"query":"mutation createTrainingDefinition {\n  createTrainingDefinition(\n    definitionName: \"ChangeRisk\"\n    algorithmName: Change_Risk\n    version: \"v0\"\n    description: \"Automatically created by Nicks scripts\"\n    createdBy: \"demo\"\n    promoteOption: whenTrainingComplete\n    trainingSchedule: {\n      frequency: manual\n      repeat: daily\n      timeRangeValidStart: null\n      timeRangeValidEnd: null\n      noEndDate: false\n    }\n  ) {\n    status\n    message\n  }\n}\n"}' --compressed)

# CFREATE ANALYSIS SI
export result=$(curl 'https://ai-platform-api-cp4waiops.itzroks-270003bu3k-pp4gqc-6ccd7f378ae819553d37d5f2ee142bd6-0000.eu-gb.containers.appdomain.cloud/graphql' -H 'Accept-Encoding: gzip, deflate, br' -H 'Content-Type: application/json' -H 'Accept: application/json' -H 'Connection: keep-alive' -H 'DNT: 1' -H 'Origin: https://ai-platform-api-cp4waiops.itzroks-270003bu3k-pp4gqc-6ccd7f378ae819553d37d5f2ee142bd6-0000.eu-gb.containers.appdomain.cloud' --data-binary '{"query":"\nmutation createTrainingDefinition {\n  createTrainingDefinition(\n    definitionName: \"SimilarIncidents\"\n    algorithmName: Similar_Incidents\n    version: \"v0\"\n    description: \"Automatically created by Nicks scripts\"\n    createdBy: \"demo\"\n    promoteOption: whenTrainingComplete\n    trainingSchedule: {\n      frequency: manual\n      repeat: daily\n      timeRangeValidStart: null\n      timeRangeValidEnd: null\n      noEndDate: false\n    }\n  ) {\n    status\n    message\n  }\n}"}' --compressed)

# RUN ANALYSIS LAD
export result=$(curl 'https://ai-platform-api-cp4waiops.itzroks-270003bu3k-pp4gqc-6ccd7f378ae819553d37d5f2ee142bd6-0000.eu-gb.containers.appdomain.cloud/graphql' -H 'Accept-Encoding: gzip, deflate, br' -H 'Content-Type: application/json' -H 'Accept: application/json' -H 'Connection: keep-alive' -H 'DNT: 1' -H 'Origin: https://ai-platform-api-cp4waiops.itzroks-270003bu3k-pp4gqc-6ccd7f378ae819553d37d5f2ee142bd6-0000.eu-gb.containers.appdomain.cloud' --data-binary '{"query":"mutation startTrainingRun {\n  startTrainingRun(definitionName: \"LogAnomalyDetection\") {\n    message\n    status\n  }\n}\n\n"}' --compressed)

# RUN ANALYSIS TG
export result=$(curl 'https://ai-platform-api-cp4waiops.itzroks-270003bu3k-pp4gqc-6ccd7f378ae819553d37d5f2ee142bd6-0000.eu-gb.containers.appdomain.cloud/graphql' -H 'Accept-Encoding: gzip, deflate, br' -H 'Content-Type: application/json' -H 'Accept: application/json' -H 'Connection: keep-alive' -H 'DNT: 1' -H 'Origin: https://ai-platform-api-cp4waiops.itzroks-270003bu3k-pp4gqc-6ccd7f378ae819553d37d5f2ee142bd6-0000.eu-gb.containers.appdomain.cloud' --data-binary '{"query":"mutation startTrainingRun {\n  startTrainingRun(definitionName: \"TemporalGrouping\") {\n    message\n    status\n  }\n}\n\n"}' --compressed)

# RUN ANALYSIS CR
export result=$(curl 'https://ai-platform-api-cp4waiops.itzroks-270003bu3k-pp4gqc-6ccd7f378ae819553d37d5f2ee142bd6-0000.eu-gb.containers.appdomain.cloud/graphql' -H 'Accept-Encoding: gzip, deflate, br' -H 'Content-Type: application/json' -H 'Accept: application/json' -H 'Connection: keep-alive' -H 'DNT: 1' -H 'Origin: https://ai-platform-api-cp4waiops.itzroks-270003bu3k-pp4gqc-6ccd7f378ae819553d37d5f2ee142bd6-0000.eu-gb.containers.appdomain.cloud' --data-binary '{"query":"mutation startTrainingRun {\n  startTrainingRun(definitionName: \"ChangeRisk\") {\n    message\n    status\n  }\n}\n\n"}' --compressed)

# RUN ANALYSIS SI
export result=$(curl 'https://ai-platform-api-cp4waiops.itzroks-270003bu3k-pp4gqc-6ccd7f378ae819553d37d5f2ee142bd6-0000.eu-gb.containers.appdomain.cloud/graphql' -H 'Accept-Encoding: gzip, deflate, br' -H 'Content-Type: application/json' -H 'Accept: application/json' -H 'Connection: keep-alive' -H 'DNT: 1' -H 'Origin: https://ai-platform-api-cp4waiops.itzroks-270003bu3k-pp4gqc-6ccd7f378ae819553d37d5f2ee142bd6-0000.eu-gb.containers.appdomain.cloud' --data-binary '{"query":"mutation startTrainingRun {\n  startTrainingRun(definitionName: \"SimilarIncidents\") {\n    message\n    status\n  }\n}\n\n"}' --compressed)





echo "  ***************************************************************************************************************************************************"
echo "   📥  New RSA Status"
echo "  ***************************************************************************************************************************************************"
echo ""
echo $result| jq -r ".data.toggleAlgorithmEnablement.message"



echo "--------------------------------------------------------------------------------------------------------------------------------"
echo "--------------------------------------------------------------------------------------------------------------------------------"
echo " ✅ DONE... "
echo "--------------------------------------------------------------------------------------------------------------------------------"
echo "--------------------------------------------------------------------------------------------------------------------------------"



exit 1



curl "https://$ROUTE/graphql" -k -H 'Accept-Encoding: gzip, deflate, br' -H 'Content-Type: application/json' -H 'Accept: application/json'  --compressed -d @./tools/02_training/training-definitions/run-analysis-TG.graphql



curl 'https://ai-platform-api-cp4waiops.itzroks-270003bu3k-pp4gqc-6ccd7f378ae819553d37d5f2ee142bd6-0000.eu-gb.containers.appdomain.cloud/graphql' -H 'Accept-Encoding: gzip, deflate, br' -H 'Content-Type: application/json' -H 'Accept: application/json' -H 'Connection: keep-alive' -H 'DNT: 1' -H 'Origin: https://ai-platform-api-cp4waiops.itzroks-270003bu3k-pp4gqc-6ccd7f378ae819553d37d5f2ee142bd6-0000.eu-gb.containers.appdomain.cloud' --data-binary '{"query":"\nmutation startTrainingRun {\n  startTrainingRun(definitionName: \"TemporalGrouping\") {\n    message\n    status\n  }\n}"}' --compressed
