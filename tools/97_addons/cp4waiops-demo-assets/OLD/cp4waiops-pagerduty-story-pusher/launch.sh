
export DEBUG_ME="False"
export TOKEN="P4ssw0rd!"

export DISCORD_WEBHOOK="https://discord.com/api/webhooks/xxxxxxx"

export MIN_RANK=3
export ACTIVE=True
export POLL_DELAY=5 


export PAGERDUTY_URL=https://events.pagerduty.com/v2/enqueue
export PAGERDUTY_TOKEN=70646bcec


#rm -f ./db/stories.db
python ./CODE/main.py 

exit 1



export TOKEN=test
DEBUG=os.environ.get('DEBUG',False)
TOKEN=os.environ.get('TOKEN',"P4ssw0rd!")

DISCORD_WEBHOOK=os.environ.get('DISCORD_WEBHOOK','not provided')
MAIL_USER=os.environ.get('MAIL_USER','not provided')
MAIL_PWD=os.environ.get('MAIL_PWD','not provided')





cd webhook
python manage.py runserver


{
  "output": "07:26:43.710101208: Notice Ingress remote file copy tool launched in container (user=<NA> user_loginuid=-1 command=curl -s -k --cert /etc/elasticsearch//secret/admin-cert --key /etc/elasticsearch//secret/admin-key -H Content-type:application/json https://localhost:9200/_template/common.settings.project.template.json --head -w %{response_code} -o /dev/null pid=565124 parent_process=es_util container_id=ed5325ed3a2f container_name=elasticsearch image=registry.redhat.io/openshift-logging/elasticsearch6-rhel8:<NA>) k8s.ns=openshift-logging k8s.pod=elasticsearch-cdm-beb95p5n-1-65f68dd74f-crkx6 container=ed5325ed3a2f",
  "priority": "Notice",
  "rule": "Launch Ingress Remote File Copy Tools in Container",
  "time": "2022-12-12T07:26:43.710101208Z",
  "output_fields": {
    "container.id": "ed5325ed3a2f",
    "container.image.repository": "registry.redhat.io/openshift-logging/elasticsearch6-rhel8",
    "container.image.tag": null,
    "container.name": "elasticsearch",
    "evt.time": 1670830003710101208,
    "k8s.ns.name": "openshift-logging",
    "k8s.pod.name": "elasticsearch-cdm-beb95p5n-1-65f68dd74f-crkx6",
    "proc.cmdline": "curl -s -k --cert /etc/elasticsearch//secret/admin-cert --key /etc/elasticsearch//secret/admin-key -H Content-type:application/json https://localhost:9200/_template/common.settings.project.template.json --head -w %{response_code} -o /dev/null",
    "proc.pid": 565124,
    "proc.pname": "es_util",
    "user.loginuid": -1,
    "user.name": "<NA>"
  },
  "source": "syscall",
  "tags": [
    "mitre_command_and_control",
    "network",
    "process"
  ]
}


exit 1




2022-05-20T12:00:21.000Z

override_with_date

{
    "id": "1a2a6787-59ad-4acd-bd0d-46c1ddfd8e00",
    "occurrenceTime": "TIMESTAMP_DATE",
    "summary": "SUMMARY_TEXT",
    "severity": SEVERITY_NUMBER,
    "type": {
        "eventType": "problem",
        "classification": "MANAGER_NAME"
    },
    "expirySeconds": EXPIRY_SECONDS,
    "links": [{
        "linkType": "webpage",
        "name": "MANAGER_NAME",
        "description": "MANAGER_NAME",
        "url": "URL_TXT"
    }],
    "sender": {
        "type": "host",
        "name": "SENDER_NAME",
        "sourceId": "SENDER_NAME"
    },
    "resource": {
        "type": "host",
        "name": "RESOURCE_NAME",
        "sourceId": "RESOURCE_NAME"
    },
    "details": {
        "operation": "push","user": "nikh@ch.ibm.com","branch": "main"
    }
}