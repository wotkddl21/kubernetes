import os
import subprocess
import sys
from difflib import context_diff
if len(sys.argv) <2:
  print("Usage : python "+sys.argv[0]+" prd or stg ")
  sys.exit()
def print_result(num,com):
  if num==0:
    print("\tNothing special in "+com)
  elif num==1:
    print("\tThere is \033[33m"+str(num)+"\033[0m thing to check in \033[94m"+com+"\033[0m")
  else:
    print("\tThere are \033[33m"+str(num)+"\033[0m things to check in \033[94m"+com+"\033[0m")

first_list = [['componentstatuses',1,'Healthy']
                ,['nodes',1,'Ready']
                ,['pv',4,'Bound']
                ,['events',2,'Normal']
                ,['pvc',2,'Bound']
                ]
cluster=""
num=0
if sys.argv[-1]=='stg':
  cluster='stg'
elif sys.argv[-1]=='prd':
  cluster='prd'
else:
  print("Usage : "+sys.argv[0]+" prd or stg ")
  sys.exit()
for command in first_list:
  subprocess.call(['/bin/bash','get_now.sh',command[0],cluster])  # > ./cluster/current_resource/now_"command[0]".txt
  filename = "./"+cluster+"/current_resource/now_"+command[0]+".txt"
  print(command[0])
  f = open(filename,'r')
  lines=[]
  while True:
    line = f.readline()
    if not line: break
    lines.append(line)
  i=0
  if len(lines)==1:
    continue  # no resource found
  for line in lines:
    if i==0:
       i+=1; continue
    t = line.split()
    if t[command[1]]!=command[2]:
        num+=1
        for i in range(0,len(t)):
            if i == command[1]:
                print("\033[33m\t"+t[i]),
                continue
            print("\033[0m"+t[i]),
        print("")
  f.close()
  print_result(num,command[0])
  num=0
second_list = [ ['clusterrolebindings',0],
                ['clusterroles',0],
                ['namespaces',0],
                ['priorityclasses',0],
                ['controllerrevisions',1],
                ['endpoints',1],
                ['horizontalpodautoscalers',1],
                ['ingresses',1],
                ['rolebindings',1],
                ['roles',1],
                ['secrets',1],
                ['services',1],
                ['serviceaccounts',1],
                ['configmaps',1]
        ]
for command in second_list:
  subprocess.call(['/bin/bash','get_now.sh',command[0],cluster])  #
  filename = "./"+cluster+"/current_resource/now_"+command[0] + ".txt"
  print(command[0])
  f = open(filename,'r')
  flag = True
  lines=[]
  while True:
    line = f.readline()
    if not line: break
    temp = line.split()
    lines.append(temp[command[1]])
  f.close()
  i=0
  filename = "./"+cluster+"/backup_latest/get/"+command[0]
  f = open(filename,'r')
  before = []
  while True:
    line = f.readline()
    if not line: break
    temp = line.split()
    before.append(temp[command[1]])
  for b in before:
    if i==0:
      i+=1; continue
    if b not in lines:
      if command[1]==0:
        print("\033[33m\t"+b+"\033[0m is not found now.")
      else:
        print("\033[33m\t"+b+"\033[0m is not found now in \033[36m"+temp[0]+"\033[0m namespace.")
      num+=1
  print_result(num,command[0])
  num=0
third_list= [   ['daemonsets',[(2,3),(2,4),(2,6)]],
                ['deployments',[(2,3),(2,4)]],
                ['replicasets',[(2,3),(2,4)]],
                ['statefulsets',[(2,3)]]
]
# check current state
for command in third_list:
  subprocess.call(['/bin/bash','get_now.sh',command[0],cluster])  # ./current_resource/now_"command[0].txt
  filename = "./"+cluster+"/current_resource/now_"+command[0] + ".txt"
  print(command[0])
  f = open(filename,'r')
  flag = True
  lines=[]
  current=[]
  while True:
    line = f.readline()
    if not line: break
    lines.append(line)
    current.append(line.split()[1])  # current = [  NAME  ]
  f.close()
  i=0
  for b in lines:
    if i==0:
      i=1;continue
    for com in command[1]:
      x,y = com
      t = b.split()
      if t[x]!=t[y]:
         flag = False
         print("\033[33m"+t[1]+"\033[0m is unhealthy in \033[36m"+t[0]+"\033[0m namespace.")
         print("\033[91m"+b+"\033[0m")
         break
  filename = "./"+cluster+"/backup_latest/get/"+command[0]
  f = open(filename,'r')
  before = [];i=0
  while True:
    line = f.readline()
    if not line: break
    temp = line.split()
    before.append(temp[1])
  for b in before:
    if i==0:
      i+=1; continue
    if b not in current:
      print("\033[33m\t"+b+"\033[0m is not found now in \033[36m"+temp[0]+"\033[0m namespace.")
      num+=1
  print_result(num,command[0])
  num=0



