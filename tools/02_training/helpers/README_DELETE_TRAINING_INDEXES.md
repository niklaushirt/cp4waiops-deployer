# Delete Trained Log Model


## List Indices

In a separate Terminal run

```bash
while true; do oc port-forward statefulset/$(oc get statefulset | grep iaf-system-elasticsearch-es-aiops | awk '{print $1}') 9200; done
```



```bash
oc project aiops

export ES_USERNAME=$(oc get secret $(oc get secrets | grep ibm-elasticsearch-secret | awk '!/-min/' | awk '{print $1;}') -o jsonpath="{.data.username}"| base64 --decode)
export ES_PASSWORD=$(oc get secret $(oc get secrets | grep ibm-elasticsearch-secret | awk '!/-min/' | awk '{print $1;}') -o jsonpath="{.data.password}"| base64 --decode)
echo $ES_USERNAME
echo $ES_PASSWORD

curl -s -k -u $ES_USERNAME:$ES_PASSWORD -XGET https://localhost:9200/_cat/indices

oc exec -it $(oc get po |grep model-train-console|awk '{print$1}') bash
```
oc get po |grep aimanager-aio-controller



## Delete Logtrain Indexes


```bash
# Get the indexes for Logtrain

indexes=$(curl -u $ES_USERNAME:$ES_PASSWORD -XGET https://localhost:9200/_cat/indices  --insecure | grep logtrain | awk '{print $3;}')
echo $indexes
```


```bash
# Then delete the indexes

for item in $indexes
do
        echo "curl -u $ES_USERNAME:$ES_PASSWORD --insecure  -XDELETE https://localhost:9200/$item"
        curl -u $ES_USERNAME:$ES_PASSWORD --insecure  -XDELETE https://$ES_ENDPOINT/$item
done
```








