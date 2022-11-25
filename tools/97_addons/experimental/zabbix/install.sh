https://www.zabbix.com/documentation/5.0/en/manual

oc apply -f ./tools/97_addons/experimental/zabbix/zabbix_base.yaml
oc apply -f ./tools/97_addons/experimental/zabbix/zabbix_install.yaml


oc delete -f ./tools/97_addons/experimental/zabbix/zabbix_base.yaml
oc delete -f ./tools/97_addons/experimental/zabbix/zabbix_install.yaml



