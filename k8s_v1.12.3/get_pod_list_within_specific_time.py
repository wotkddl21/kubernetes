import subprocess
import sys
if len(sys.argv)<2:
  print("Usage : "+sys.argv[0]+"time(min) "+" stg or prd")
  sys.exit()
subprocess.call(['/bin/bash','get_now.sh','pod',sys.argv[1]])
def get_time(time):
  s=0
  temp=0
  for t in time:
    if t!='s' and t!='m' and t!='h' and t!='d':
      temp*=10; temp+=int(t)
    elif t=='d':
      s += temp*24*60*60
      temp=0
    elif t=='h':
      s += temp*60*60
      temp=0
    elif t=='m':
      s += temp*60
      temp=0
    elif t=='s':
      s+= temp
  return s
if __name__== '__main__':
  f = open('./'+sys.argv[1]+'/current_resource/now_pod.txt','r')
  boundary=10
  if len(sys.argv)==3:
    boundary=int(eval(sys.argv[-1]))
  lines= []
  new_list = []
  not_running_list=[]
  while True:
    line = f.readline()
    if not line: break
    lines.append(line)
  i=0
  for line in lines:
    print("\033[0m"),
    t = line.split()
    if i==0:
      print("\033[0k\r"+line),
      i+=1
      continue
    T=get_time(t[5])
    i+=1
    if t[3] != 'Running' and t[3] !='STATUS' and t[3] !='ContainerCreating':
      print("\033[7m\033[91m"),
      not_running_list.append(line)
    elif T < boundary*60:
      print("\033[7m\033[33m"),
      new_list.append(line)
    print("\033[0k\r"+line+"\033[0m"),
  f.close()
  f = open('./'+sys.argv[1]+'/pod_need_to_check/new_list.txt','w')
  for candi in new_list:
    f.write(candi)
  f.close()
  f = open('./'+sys.argv[1]+'/pod_need_to_check/not_running_list.txt','w')
  for candi in not_running_list:
    f.write(candi)
  f.close()
  print("\033[33m \033[0k\r"+str(len(new_list))+"\033[0m number of pods started within "+str(boundary/60/24)+" days "+str(boundary/60%24)+" hours " +str(boundary%60)+" minutes.")
  print("\t Check the file \" ./"+sys.argv[1]+"/pod_need_to_check/new_list.txt \" ")
  print("\033[91m\033[0k\r"+str(len(not_running_list))+"\033[0m number of pods are in weird status")
  print("\t Check the file \" ./"+sys.argv[1]+"/pod_need_to_check/not_running_list \"")