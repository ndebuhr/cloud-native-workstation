#!/usr/bin/env bash

script_dir=$( echo $BASH_SOURCE | egrep -o '^.*\/' )
kubectl apply -f $script_dir/../../keycloak-operator/deploy/crds/

count=0
echo "Keycloak Operator CRDs: Creating..."
# Wait up to (approximately) three minutes for CRD registration
while [ $count -le 180 ]
do
    kubectl get keycloakbackup 2> /dev/null
    keycloakbackup=$?
    kubectl get keycloakclient 2> /dev/null
    keycloakclient=$?
    kubectl get keycloakrealm 2> /dev/null
    keycloakrealm=$?
    kubectl get keycloak 2> /dev/null
    keycloak=$?
    kubectl get keycloakuser 2> /dev/null
    keycloakuser=$?
    # Exit code 0 means there were no resources found (desired behavior)
    # Before CRD registration, the exit code for the get commands is 1
    if [ $keycloakbackup -ne 0 ] || [ $keycloakclient -ne 0 ] ||  [ $keycloakrealm -ne 0 ] || [ $keycloak -ne 0 ] || [ $keycloakuser -ne 0 ]
    then
        echo "Keycloak Operator CRDs: Still creating..."
        sleep 5
        count=$(( count+5 ))
    else
        echo "Keycloak Operator CRDs: Creation complete"
        exit 0
    fi
done
echo "Keycloak Operator CRDs: Failed"
# On failure, display stderr
set -x
kubectl get keycloakbackup
kubectl get keycloakclient
kubectl get keycloakrealm
kubectl get keycloak
kubectl get keycloakuser
exit 3