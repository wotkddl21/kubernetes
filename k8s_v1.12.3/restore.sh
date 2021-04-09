#!/bin/bash
source ./env.sh
list=`cat ./$1/deployment_desired_replicas.txt`
if [ "$1" == "prd" ]; then
  com=$prd_env
elif [ "$1" == "stg" ]; then
  com=$stg_env
fi
i=0
temp=""
temp2=""
for var in $list; do
        if [ "$i" == "0" ]; then
                temp=$var
                i=`expr $i + 1`
                continue
        fi
        if [ "$i" == "1" ]; then
                temp2=$var
                $com scale deployment $temp --replicas=$temp2
                echo -n "scale  "
                echo -n -e "\e[34m"
                echo -n $temp
                echo -n -e "\e[0m"
                echo -n "  replicas  "
                echo -n -e "\e[36m"
                echo -n -e $temp2
                echo -e "\e[0m"
                i=0
  fi
done
