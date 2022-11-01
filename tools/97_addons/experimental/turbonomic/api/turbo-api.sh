

Auth
curl -k -s -c $(pwd)/auth-cookie -H 'Accept: application/json' "https://api-turbonomic.cp4waiops-953327-a376efc1170b9b8ace6422196c51e491-0000.eu-de.containers.appdomain.cloud/api/v3/login?hateoas=true" -d 'username=apiuser&password=P4ssw0rd'

Get all business apps
curl -s -b $(pwd)/auth-cookie -XGET 'https://api-turbonomic.cp4waiops-953327-a376efc1170b9b8ace6422196c51e491-0000.eu-de.containers.appdomain.cloud/vmturbo/rest/search?types=BusinessApplication&limit=500&cursor=0' | jq > business-apps.json
Get Actions for app
curl -s -b $(pwd)/auth-cookie -XGET  'https://api-turbonomic.cp4waiops-953327-a376efc1170b9b8ace6422196c51e491-0000.eu-de.containers.appdomain.cloud/vmturbo/rest/entities/74060840891130/actions?limit=500&cursor=0' | jq > robot-shop-ba-actions.json














rm /tmp/cookies
curl -k -s -c /tmp/cookies "https://api-turbonomic.cp4waiops-953327-a376efc1170b9b8ace6422196c51e491-0000.eu-de.containers.appdomain.cloud/api/v3/login?hateoas=true" -H 'Accept: application/json' -H 'Cookie: bb50a134b3c2bfc9dc343c4ecc5294de=8a979513b3bc47eb132d374fa434e878' -d 'username=administrator&password=<MY PASSWORD>'
cat /tmp/cookies


curl "https://api-turbonomic.cp4waiops-953327-a376efc1170b9b8ace6422196c51e491-0000.eu-de.containers.appdomain.cloud/api/v3/actions" \
     -H 'Accept: application/json' \
     -H 'Content-Type: application/x-www-form-urlencoded; charset=utf-8' \
     -b '/tmp/cookies'




curl -XPOST "https://api-turbonomic.cp4waiops-953327-a376efc1170b9b8ace6422196c51e491-0000.eu-de.containers.appdomain.cloud/api/v3/actions" \
     -H 'Accept: application/json' \
     -H 'Content-Type: application/json' \
     -b '/tmp/cookies' \
     -d $'{
            "scopes": [
                "Market"
            ],
            "actionInput": {
                "groupBy": [
                "actionModes"
                ],
                "actionStateList": [
                "PENDING_ACCEPT"
                ],
                "environmentType": "CLOUD"
            },
            "relatedType": "CONTAINER_POD "
            }'




curl -XPOST "https://api-turbonomic.cp4waiops-953327-a376efc1170b9b8ace6422196c51e491-0000.eu-de.containers.appdomain.cloud/api/v3/actions" \
     -H 'Accept: application/json' \
     -H 'Content-Type: application/json' \
     -b '/tmp/cookies' \
     -d $'{
            "scopes": [
                "Market"
            ],
            "actionInput": {
                "groupBy": [
                    "actionModes"
                ],
                "actionStateList": [
                    "PENDING_ACCEPT"
                ]
            },
            "relatedType": "VirtualMachine"
            }'




curl -XPOST "https://api-turbonomic.cp4waiops-953327-a376efc1170b9b8ace6422196c51e491-0000.eu-de.containers.appdomain.cloud/api/v3/actions" \
     -H 'Accept: application/json' \
     -H 'Content-Type: application/json' \
     -b '/tmp/cookies' \
     -d $'{
            "actionInput": {
                "groupBy": [
                    "actionModes"
                ],
                "actionStateList": [
                    "PENDING_ACCEPT"
                ]
            },
            "relatedType": "VirtualMachine"
            }'












curl -s -k -c ./cookies -H 'accept: application/json' 'https://api-turbonomic.cp4waiops-953327-a376efc1170b9b8ace6422196c51e491-0000.eu-de.containers.appdomain.cloud/api/v3/login?hateoas=true' -d 'username=administrator&password=<MY PASSWORD>'

curl -s -k "https://api-turbonomic.cp4waiops-953327-a376efc1170b9b8ace6422196c51e491-0000.eu-de.containers.appdomain.cloud/api/v3/login?hateoas=true" -H 'Accept: application/json' -H 'Content-Type: text/plain; charset=utf-8' -H 'Cookie: bb50a134b3c2bfc9dc343c4ecc5294de=8a979513b3bc47eb132d374fa434e878' -d "username=administrator]password=<MY PASSWORD>"

https://api-turbonomic.cp4waiops-953327-a376efc1170b9b8ace6422196c51e491-0000.eu-de.containers.appdomain.cloud/swagger/external/index.html


curl -k -s "https://api-turbonomic.cp4waiops-953327-a376efc1170b9b8ace6422196c51e491-0000.eu-de.containers.appdomain.cloud/api/v3/login?hateoas=true" -H 'Accept: application/json' -H 'Cookie: bb50a134b3c2bfc9dc343c4ecc5294de=8a979513b3bc47eb132d374fa434e878' -d 'username=administrator&password=<MY PASSWORD>'




curl "https://api-turbonomic.cp4waiops-953327-a376efc1170b9b8ace6422196c51e491-0000.eu-de.containers.appdomain.cloud/api/v3/login?hateoas=true" \
     -H 'Accept: application/json' \
     -H 'Content-Type: application/x-www-form-urlencoded; charset=utf-8' \
     -H 'Cookie: bb50a134b3c2bfc9dc343c4ecc5294de=8a979513b3bc47eb132d374fa434e878' \
     --data-urlencode "username=demo" \
     --data-urlencode "password=aaa111"


curl "https://api-turbonomic.cp4waiops-953327-a376efc1170b9b8ace6422196c51e491-0000.eu-de.containers.appdomain.cloud/api/v3/actions" \
     -H 'Accept: application/json' \
     -H 'Content-Type: application/x-www-form-urlencoded; charset=utf-8' \
     -H 'Cookie: bb50a134b3c2bfc9dc343c4ecc5294de=8a979513b3bc47eb132d374fa434e878' \
     --data-urlencode "username=demo" \
     --data-urlencode "password=aaa111"




