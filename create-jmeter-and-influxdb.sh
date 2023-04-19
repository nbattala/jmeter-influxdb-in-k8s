#!/usr/bin/env bash

namespace="$1"
if [ -z "$namespace" ]
then
  echo "Enter the name of an existing or a new namespace to be used to create jmeter and influxdb"
  read namespace
fi

kubectl create namespace $namespace --dry-run=client -o yaml | kubectl apply -f -

echo "Creating Jmeter Deployment and Configmap"
kubectl -n $namespace apply -f jmeter_cm.yaml

kubectl -n $namespace apply -f jmeter_deploy.yaml

echo "Creating Influxdb and the service"
helm repo add influxdata https://helm.influxdata.com/
helm upgrade -n $namespace --install influxdb-rel \
  -f influxdb-helm-values.yaml \
  influxdata/influxdb

#create a influxdb database
echo "creating jmeter database in influxdb-rel-0"
kubectl -n $namespace exec -it influxdb-rel-0 -- influx -execute 'CREATE DATABASE jmeter'
