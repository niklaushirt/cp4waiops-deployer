
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# Init Code
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"


# ES LOGS DUMP 
cat ./tools/02_training/helpers/dump_es/DUMP/logs/1000-1000-20211213-logtrain.json|jq '._source.instance_id' | sort | uniq -c

for actFile in $(ls -1 . | grep "json");
do
    echo $actFile
    cat $actFile|jq '._source.instance_id' | sort | uniq -c
done


mkdir CLEAN
for actFile in $(ls -1 . | grep "json");
do
    echo $actFile
    cat $actFile| grep -v "mysql"| grep -v "load"| grep -v "mongodb"| grep -v "rabbitmq"| grep -v "redis" > ./CLEAN/$actFile
    cat ./CLEAN/$actFile|jq '._source.instance_id' | sort | uniq -c
done





mkdir CLEAN
for actFile in $(ls -1 . | grep "json");
do
    echo $actFile
    cat $actFile| grep -v "mysql"| grep -v "load"| grep -v "mongodb"| grep -v "rabbitmq"| grep -v "redis"| grep -v "dispatch"| grep -v "payment" > ./CLEAN/$actFile
    cat ./CLEAN/$actFile|jq '._source.instance_id' | sort | uniq -c
done








export JSON_NAME=1000-1000-20211214-logtrain.json
cat ./tools/02_training/helpers/dump_es/DUMP/logs/$JSON_NAME| grep -v "mysql"| grep -v "load"| grep -v "mongodb"| grep -v "rabbitmq"| grep -v "redis"| grep -v "shipping"| grep -v "user"| grep -v "cart"| grep -v "dispatch"| grep -v "payment" > ./tools/02_training/TRAINING_FILES/ELASTIC/robot-shop/logs/temp/$JSON_NAME
cat ./tools/02_training/TRAINING_FILES/ELASTIC/robot-shop/logs/temp/$JSON_NAME|jq '._source.instance_id' | sort | uniq -c




export JSON_NAME=1000-1000-20211214-logtrain.json
cat ./$JSON_NAME| grep -v "mysql"| grep -v "load"| grep -v "mongodb"| grep -v "rabbitmq"| grep -v "redis"| grep -v "shipping"| grep -v "user"| grep -v "cart"| grep -v "dispatch"| grep -v "payment" > ./$JSON_NAME-new
cat ./$JSON_NAME-new|jq '._source.instance_id' | sort | uniq -c




        # fix sed issue on mac
        OS=$(uname -s | tr '[:upper:]' '[:lower:]')
        SED="sed"
        if [ "${OS}" == "darwin" ]; then
            SED="gsed"
            if [ ! -x "$(command -v ${SED})"  ]; then
            __output "This script requires $SED, but it was not found.  Perform \"brew install gnu-sed\" and try again."
            exit
            fi
        fi

cat ./tools/8_training/DUMP_SNOW/snowchangerequest.json > /tmp/snowchangerequest1.json


cat /tmp/snowchangerequest1.json | ${SED} -e 's/,"raw_data":{.*}}}/}}/' > /tmp/snowchangerequest2.json

cat /tmp/snowchangerequest2.json | ${SED} -e 's/Unsuccessful/unsuccessful/' > /tmp/snowchangerequest3.json
cat /tmp/snowchangerequest3.json | ${SED} -e 's/Successful/successful/' > /tmp/snowchangerequest4.json

cat /tmp/snowchangerequest3.json  > ./tools/8_training/INDEXES_SNOW/snowchangerequest.json

#./tools/8_training/INDEXES_SNOW/snowchangerequest.json

mkdir CLEAN
for actFile in $(ls -1 . | grep "json");
do
    echo $actFile
    cat $actFile| grep -v "mysql"| grep -v "load"| grep -v "mongodb"| grep -v "rabbitmq"| grep -v "redis"| grep -v "dispatch"| grep -v "payment" > ./CLEAN/$actFile
    cat ./CLEAN/$actFile|jq '._source.instance_id' | sort | uniq -c
done


mkdir CLEAN
for actFile in $(ls -1 . | grep "json");
do
    echo $actFile
    cat $actFile| grep -v "mysql"| grep -v "load"| grep -v "mongodb"| grep -v "rabbitmq"| grep -v "redis"| grep -v "shipping"| grep -v "user"| grep -v "cart"| grep -v "dispatch"| grep -v "payment" > ./CLEAN/$actFile
    cat ./CLEAN/$actFile|jq '._source.instance_id' | sort | uniq -c
done

