export username=$(oc get secret $(oc get secrets | grep elastic-secret | awk '!/-min/' | awk '{print $1;}') -o jsonpath="{.data.username}"| base64 --decode)
export password=$(oc get secret $(oc get secrets | grep elastic-secret | awk '!/-min/' | awk '{print $1;}') -o jsonpath="{.data.password}"| base64 --decode)


for index in $(curl -k -u $username:$password -XGET https://localhost:9200/_cat/indices | grep -E "1000-1000-518" | awk '{print $3;}'); do
    curl -k -u $username:$password -XDELETE "https://localhost:9200/$index"
done
