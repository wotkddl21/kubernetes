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
mkdir -p ./$1
$kubectl get deployment  -o=custom-columns=NAME:.metadata.name,DESIRED:.spec.replicas | awk '/[0-9]/{printf $1} /[0-9]/{printf "\t"} /[0-9]/{printf $2} /[0-9]/{printf "\n"}' > ./$1/deployment_desired_replicas.txt

