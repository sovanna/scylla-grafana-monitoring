#!/usr/bin/env bash

. versions.sh
VERSIONS=$DEFAULT_VERSION
GRAFANA_PORT=3000
DB_ADDRESS="127.0.0.1:9090"

usage="$(basename "$0") [-h] [-v comma separated versions ] [-g grafana port ] [-p ip:port address of prometheus ] [-a admin password] -- loads the prometheus datasource and the Scylla dashboards into an existing grafana installation"

while getopts ':hg:p:v:a:' option; do
  case "$option" in
    h) echo "$usage"
       exit
       ;;
    v) VERSIONS=$OPTARG
       ;;
    g) GRAFANA_PORT=$OPTARG
       ;;
    p) DB_ADDRESS=$OPTARG
       ;;
    a) GRAFANA_ADMIN_PASSWORD=$OPTARG
       ;;
  esac
done

curl -XPOST -i http://admin:$GRAFANA_ADMIN_PASSWORD@localhost:$GRAFANA_PORT/api/datasources \
     --data-binary '{"name":"prometheus", "type":"prometheus", "url":"'"http://$DB_ADDRESS"'", "access":"proxy", "basicAuth":false}' \
     -H "Content-Type: application/json"
IFS=',' ;for v in $VERSIONS; do
	curl -XPOST -i http://admin:$GRAFANA_ADMIN_PASSWORD@localhost:$GRAFANA_PORT/api/dashboards/db --data-binary @./grafana/scylla-dash.$v.json -H "Content-Type: application/json"
	curl -XPOST -i http://admin:$GRAFANA_ADMIN_PASSWORD@localhost:$GRAFANA_PORT/api/dashboards/db --data-binary @./grafana/scylla-dash-per-server.$v.json -H "Content-Type: application/json"
	curl -XPOST -i http://admin:$GRAFANA_ADMIN_PASSWORD@localhost:$GRAFANA_PORT/api/dashboards/db --data-binary @./grafana/scylla-dash-io-per-server.$v.json -H "Content-Type: application/json"
done

