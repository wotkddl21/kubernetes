#!/bin/bash
source ./env.sh
if [ "$1" == "stg" ];then
        prd=$stg_env
elif [ "$1" == "prd" ]; then
      prd=$prd_env
else
    echo "Usage : $0 prd"
    echo "Usage : $0 stg"
    exit 1
fi
ctl=""
namespace_list=("default" "kube-system")
column1=$pod_column
column=8
index=0
totalnum=0
for namespace in ${namespace_list[@]};do
        line=0
        write_x=0
        num=0
        index=0
        echo -e '\nnamespace : '$namespace'\n'
        echo -e -n "\e[33m"
        echo -n "NAME "
        echo -e -n "\e[35m"
        echo -n "STATUS "
        echo -e -n "\e[91m"
        echo -n "RESTART "
        echo -e -n "\e[36m"
        echo -n "AGE "
        echo -e -n "\e[37m"
        echo "HOSTNODE "
        for arg in `$prd get pod -o wide -n $namespace`;do
                if [ $line -lt $column1 ]; then
                        line=`expr $line + 1`
                        continue
                fi
                if [ $index == 1 ] ; then
                        echo -e -n "\e[33m"
                        echo -e -n $arg' '
                fi
                if [ $index == 3 ] ; then
                        echo -e -n "\e[35m"
                        echo -e -n $arg' '
                fi
                if [ $index == 4 ]; then
                        echo -e -n "\e[91m"
                        echo -e -n $arg' '
                fi
                if [ $index == 5 ] ; then
                        echo -e -n "\e[36m"
                        echo -e -n $arg' '
                fi
                if [ $index == 7 ] ; then
                        echo -e -n "\e[37m"
                        echo -e -n $arg' '
                fi
                if [ $index == `expr $column - 1` ] ; then
                        echo -e '\n'
                        num=`expr $num + 1`
                        totalnum=`expr $totalnum + 1`
                fi
                index=`expr $index + 1`
                index=`expr $index % $column`
        done
        echo -e -n "\e[33m"
        echo -n $num
        echo -e -n "\e[37m"
        echo -n ' pods on '
        echo -e -n "\e[36m"
        echo -n $namespace
        echo -e -n "\e[37m"
        echo -e ' space\n'
done
echo -n "total "
echo -e -n "\e[33m"
echo -n $totalnum
echo -e -n "\e[37m"
echo ' pods on cluster'