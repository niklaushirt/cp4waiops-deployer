export TOKEN=test

export ITERATE_ELEMENT="events"
export WEBHOOK_DEBUG="false"

export EVENT_TEMPLATE='{"id": "1a2a6787-59ad-4acd-bd0d-46c1ddfd8e00","occurrenceTime": "@@TIMESTAMP_DATE","summary": "@@SUMMARY_TEXT","severity": @@SEVERITY_NUMBER,"type": {"eventType": "problem","classification": "@@MANAGER_NAME"},"expirySeconds": @@EXPIRY_SECONDS,"links": [{"linkType": "webpage","name": "@@MANAGER_NAME","description": "@@MANAGER_NAME","url": "@@URL_TXT"}],"sender": {"type": "host","name": "@@SENDER_NAME","sourceId": "@@SENDER_NAME"},"resource": {"type": "host","name": "@@RESOURCE_NAME","sourceId": "@@RESOURCE_NAME"},"details": {@@DETAILS_JSON}}'
export EVENT_MAPPING='kubernetes.container_name,RESOURCE_NAME;
	    kubernetes.namespace_name,SENDER_NAME;
	    @rawstring,SUMMARY_TEXT;
	    override_with_date,TIMESTAMP_DATE;
	    URL,URL_TXT;
	    Severity,SEVERITY_NUMBER;
	    Expiry,EXPIRY_SECONDS;
	    details,DETAILS_JSON;
	    Manager,MANAGER_NAME'





cd webhook
python manage.py runserver

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