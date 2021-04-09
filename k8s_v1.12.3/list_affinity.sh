#!/bin/bash
source ./env.sh
if [ "$#" -lt 1 ] ; then
    echo " Usage : $0 prd"
    echo " Usage : $0 stg"
    exit 1
fi
if [ "$1" == "prd" ]; then
  kubectl="$prd_env"
elif [ "$1" == "stg" ]; then
  kubectl="$stg_env"
fi
 $kubectl get pod --all-namespaces -o=custom-columns=NAME:.metadata.name,AFFINITY:.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[*].values[*],OPERATOR:.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[*].operator,NODESELECTOR:.spec.nodeSelector
