#!/bin/bash
StartTime=$(date +%s)
source ./env.sh
if [ "$#" -lt 1 ] ; then
    echo " Usage : $0 prd"
    echo " Usage : $0 stg"
    exit 1
fi
if [ "$1" == "prd" ]; then
  get_command="$prd_env get --all-namespaces -o wide "
  describe_command="$prd_env describe --all-namespaces "
  kubectl="$prd_env"
elif [ "$1" == "stg" ]; then
  get_command="$stg_env get --all-namespaces -o wide "
  describe_command="$stg_env describe --all-namespaces "
  kubectl="$stg_env"
fi
list1=`cat ./resource_list/resource1.list`
list2=`cat ./resource_list/resource2.list`
list3=`cat ./resource_list/resource3.list`
list4=`cat ./resource_list/resource4.list`
time=`date +%Y-%m-%d`
name=""
namespace=""
i=0
mkdir -p ./$1/backup_$time
mkdir -p ./$1/backup_latest
rm -rf ./$1/backup_latest/*
rm -r ./$1/backup_$time/*
mkdir -p ./$1/backup_$time/get
mkdir -p ./$1/backup_$time/describe
mkdir -p ./$1/backup_latest/get
mkdir -p ./$1/backup_latest/describe
mkdir -p ./$1/backup_$time/describe/resource_name_list
mkdir -p ./$1/backup_latest/describe/resource_name_list
y=`tput lines`
for resource in $list1; do
# backup day by day
  $get_command  $resource > ./$1/backup_$time/get/$resource
  cat ./$1/backup_$time/get/$resource | awk '/[0-9]/{print $1 } ' >> ./$1/backup_$time/describe/resource_name_list/$resource
# update the latest
  cat ./$1/backup_$time/get/$resource > ./$1/backup_latest/get/$resource
  cat ./$1/backup_latest/get/$resource | awk '/[0-9]/{print $1 } ' >> ./$1/backup_latest/describe/resource_name_list/$resource
  echo -e "$get_command $resource\033[0K"
  mkdir -p ./$1/backup_$time/describe/txt/$resource
  mkdir -p ./$1/backup_$time/get/txt/$resource
  mkdir -p ./$1/backup_latest/describe/txt/$resource
  mkdir -p ./$1/backup_latest/get/txt/$resource
  names=`cat ./$1/backup_$time/describe/resource_name_list/$resource `
  for name in $names; do
       $describe_command $resource $name > ./$1/backup_$time/describe/txt/$resource/$name
       cat ./$1/backup_$time/describe/txt/$resource/$name > ./$1/backup_latest/describe/txt/$resource/$name
        com="$describe_command $resource $name"
        echo -e -n "$com\033[0K\r"
       $kubectl get $resource $name -o yaml > ./$1/backup_$time/get/txt/$resource/$name
       cat ./$1/backup_$time/get/txt/$resource/$name > ./$1/backup_latest/get/txt/$resource/$name
  done
done
for resource in $list2; do
# update day by day
  $get_command  $resource > ./$1/backup_$time/get/$resource
  cat ./$1/backup_$time/get/$resource | awk '/[0-9]/{printf $2} /[0-9]/{printf "\t"} /[0-9]/{printf $1} /[0-9]/{printf "\n"} ' >> ./$1/backup_$time/describe/resource_name_list/$resource
# update the latest
  cat ./$1/backup_$time/get/$resource > ./$1/backup_latest/get/$resource
  cat ./$1/backup_latest/get/$resource | awk '/[0-9]/{printf $2} /[0-9]/{printf "\t"} /[0-9]/{printf $1} /[0-9]/{printf "\n"} ' >> ./$1/backup_latest/describe/resource_name_list/$resource
  names_namespace=`cat ./$1/backup_$time/describe/resource_name_list/$resource`
  echo -e "$get_command $resource\033[0K"
  mkdir -p ./$1/backup_$time/describe/txt/$resource
  mkdir -p ./$1/backup_$time/describe/txt/$resource/default
  mkdir -p ./$1/backup_$time/describe/txt/$resource/kube-system
  mkdir -p ./$1/backup_$time/describe/txt/$resource/kube-public
  mkdir -p ./$1/backup_$time/get/txt/$resource
  mkdir -p ./$1/backup_$time/get/txt/$resource/default
  mkdir -p ./$1/backup_$time/get/txt/$resource/kube-system
  mkdir -p ./$1/backup_$time/get/txt/$resource/kube-public
  mkdir -p ./$1/backup_latest/describe/txt/$resource
  mkdir -p ./$1/backup_latest/describe/txt/$resource/default
  mkdir -p ./$1/backup_latest/describe/txt/$resource/kube-system
  mkdir -p ./$1/backup_latest/describe/txt/$resource/kube-public
  mkdir -p ./$1/backup_latest/get/txt/$resource
  mkdir -p ./$1/backup_latest/get/txt/$resource/default
  mkdir -p ./$1/backup_latest/get/txt/$resource/kube-system
  mkdir -p ./$1/backup_latest/get/txt/$resource/kube-public
  for word in $names_namespace; do
       if [ "$i" == "0" ]; then
          name=$word
          i=`expr $i + 1`
          continue
       fi
       if [ "$i" == "1" ]; then
          namespace=$word
          $kubectl describe $resource $name -n $namespace > ./$1/backup_$time/describe/txt/$resource/$namespace/$name
          cat ./$1/backup_$time/describe/txt/$resource/$namespace/$name > ./$1/backup_latest/describe/txt/$resource/$namespace/$name
          echo -e -n "$kubectl describe $resource $name -n $namespace\033[0K\r"
          $kubectl get $resource $name -o yaml -n $namespace > ./$1/backup_$time/get/txt/$resource/$namespace/$name
          cat ./$1/backup_$time/get/txt/$resource/$namespace/$name > ./$1/backup_latest/get/txt/$resource/$namespace/$name

          i=0
       fi
  done
done
for resource in $list3; do
  $get_command  $resource > ./$1/backup_$time/get/$resource
  cat ./$1/backup_$time/get/$resource | awk '/[0-9]/{printf $2} /[0-9]/{printf "\t"}  /[0-9]/{printf $1 } /[0-9]/{printf "\n"} ' >> ./$1/backup_$time/describe/resource_name_list/$resource

  cat ./$1/backup_$time/get/$resource > ./$1/backup_latest/get/$resource
  cat ./$1/backup_latest/get/$resource | awk '/[0-9]/{printf $2} /[0-9]/{printf "\t"}  /[0-9]/{printf $1 } /[0-9]/{printf "\n"} ' >> ./$1/backup_latest/describe/resource_name_list/$resource
  names_namespace=`cat ./$1/backup_$time/describe/resource_name_list/$resource`
  echo -e "$get_command $resource\033[0K"
  mkdir -p ./$1/backup_$time/describe/txt/$resource
  mkdir -p ./$1/backup_$time/describe/txt/$resource/default
  mkdir -p ./$1/backup_$time/describe/txt/$resource/kube-system
  mkdir -p ./$1/backup_$time/describe/txt/$resource/kube-public
  mkdir -p ./$1/backup_latest/describe/txt/$resource
  mkdir -p ./$1/backup_latest/describe/txt/$resource/default
  mkdir -p ./$1/backup_latest/describe/txt/$resource/kube-system
  mkdir -p ./$1/backup_latest/describe/txt/$resource/kube-public
  for word in $names_namespace; do
       if [ "$i" == "0" ]; then
          name=$word
          i=`expr $i + 1`
          continue
       fi
       if [ "$i" == "1" ]; then
          namespace=$word
          $kubectl describe $resource $name -n $namespace > ./$1/backup_$time/describe/txt/$resource/$namespace/$name
          cat ./$1/backup_$time/describe/txt/$resource/$namespace/$name > ./$1/backup_latest/describe/txt/$resource/$namespace/$name
          echo -e -n "$kubectl describe $resource $name -n $namespace\033[0K\r"
          i=0
       fi
  done
done
for resource in $list4; do
  $get_command  $resource > ./$1/backup_$time/get/$resource
  cat ./$1/backup_$time/get/$resource> ./$1/backup_latest/get/$resource
  echo -e "$get_command $resource \033[0K"
done
EndTime=$(date +%s)
echo "It takes $(($EndTime - $StartTime)) seconds to complete this task."