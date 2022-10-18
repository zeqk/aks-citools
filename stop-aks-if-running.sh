#!/bin/bash

RESOURCE_GROUP="$1"
CLUSTER="$2"
if [[ -z "$CLUSTER" || -z "$RESOURCE_GROUP" ]]; then
	echo "stop-aks-if-running.sh <resource_group> <cluster>"
	exit 1
fi

POWERSTATE=$(az aks show \
	--resource-group "$RESOURCE_GROUP" \
	--name "$CLUSTER" \
	--query "powerState.code" -o tsv)

if [[ "$POWERSTATE" -eq "Running" ]]; then
	az aks stop \
		--resource-group "$RESOURCE_GROUP" \
		--name "$CLUSTER" \
		--no-wait
fi