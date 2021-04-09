#!/bin/bash
if [ "$#" -lt 1 ] ; then
    echo " Usage : $0 prd"
    echo " Usage : $0 stg"
    exit 1
fi
if [ "$1" == "prd" ]; then
  kubectl="kubectl --kubeconfig=/home/tacoadmin/taco/contexts/prd_admin.conf"
elif [ "$1" == "stg" ]; then
  kubectl="kubectl --kubeconfig=/home/tacoadmin/taco/contexts/stg_admin.conf"
fi
mkdir -p ./hpa
mkdir -p ./hpa/$1
$kubectl  get hpa | awk '/[0-9]/{print $2}' > ./hpa/$1/now_hpa.txt
$kubectl  get deployment | awk '/[0-9]/{print $1}' > ./hpa/$1/now_deployment.txt
python ./hpa/hpa.py $1
