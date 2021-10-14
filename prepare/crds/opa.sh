#!/usr/bin/env bash

kubectl apply -f ./prepare/crds/constraint-templates.yaml

count=0
echo "Constraint Template CRDs: Creating..."
# Wait up to (approximately) three minutes for CRD registration
while [ $count -le 180 ]
do
    kubectl get requiredlabels 2> /dev/null
    requiredlabels=$?
    kubectl get deploymentselector 2> /dev/null
    deploymentselector=$?
    kubectl get resourcelimit 2> /dev/null
    resourcelimit=$?
    kubectl get disallowedtags 2> /dev/null
    disallowedtags=$?
    # Exit code 0 means there were no resources found (desired behavior)
    # Before CRD registration, the exit code for the get commands is 1
    if [ $requiredlabels -ne 0 ] || [ $deploymentselector -ne 0 ] ||  [ $resourcelimit -ne 0 ] || [ $disallowedtags -ne 0 ]
    then
        echo "Constraint Template CRDs: Still creating..."
        sleep 5
        count=$(( count+5 ))
    else
        echo "Constraint Template CRDs: Creation complete"
        exit 0
    fi
done
echo "Constraint Template CRDs: Failed"
# On failure, display stderr
set -x
kubectl get requiredlabels
kubectl get deploymentselector
kubectl get resourcelimit
kubectl get disallowedtags
exit 3