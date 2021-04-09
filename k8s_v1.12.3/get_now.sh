#!/bin/bash
#prd_env="kubectl --kubeconfig=/home/~~~"
#stg_env="kubectl --kubeconfig=/home/~~~"
if [ "$#" -lt 1 ] ; then
    echo " Usage : $0 resource prd "
    echo " Usage : $0 resource stg "
    exit 1
fi
if [ "$2" == "prd" ]; then
  kubectl="$prd_env"
elif [ "$2" == "stg" ]; then
  kubectl="$stg_env"
fi
mkdir -p ./$2/current_resource
$kubectl get $1 -o wide --all-namespaces > ./$2/current_resource/now_$1.txt
