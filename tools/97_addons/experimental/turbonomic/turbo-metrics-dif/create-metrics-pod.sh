# https://github.com/turbonomic/data-ingestion-framework


oc apply -n default -f ./tools/10_turbonomic/data-ingestion/create-data-ingestion.yaml


echo "Now you can configure Turbonomic"

echo "Get the UID from Vendor ID in the Turbonomic UI"

echo "http://turbo-dif-service.default:3000/helloworld"
echo "http://turbo-dif-service.default:3000/businessApplication/RobotShop/285171179567776"
echo "http://turbo-dif-service.default:3000/service/Service-robot-shop%2Fcatalogue/b2d6fd52-c895-469e-bb98-2a791faefce7"

