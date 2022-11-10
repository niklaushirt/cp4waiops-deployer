# ----------------------------------------------------------------------------------------------------------------------------------------------------------
## Data Check
# ----------------------------------------------------------------------------------------------------------------------------------------------------------



## Check Number of log lines per container

```bash
cat ./tools/5_training/2_logs/trainingdata/raw/log-bookinfo.json|jq '.["kubernetes.container_name"]' | sort | uniq -c
```

## Delete entries for certain entities in the json

```bash
grep -v 'kubernetes.container_name":"<my-container-name-to-delete>' ./tools/5_training/2_logs/trainingdata/raw/log-bookinfo.json > final.json
```

# Export Training Data (Humio Filter)

```bash
"kubernetes.namespace_name" = robot-shop
| "kubernetes.container_name" = /web|ratings|catalogue/
| @rawstring = /ratings/ | @rawstring = /error/
```


# Check indices

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

```
