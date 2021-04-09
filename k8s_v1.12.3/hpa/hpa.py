import sys
if __name__== '__main__':
  if len(sys.argv)!=2:
    print("Usage : "+sys.argv[0]+" prd or stg")
    sys.exit()
  try:
    f = open("./hpa/"+sys.argv[-1]+"/now_hpa.txt",'r')
  except:
    print("Please cd ../ && ./hpa.sh prd or stg")
    sys.exit()
  hpas=[]
  while True:
    hpa = f.readline().strip()
    if not hpa: break
    hpas.append(hpa.split('/')[-1])
  f.close()
  f = open('./hpa/'+sys.argv[-1]+'/now_deployment.txt','r')
  deployments = []
  while True:
    deployment = f.readline().strip()
    if not deployment: break
    deployments.append(deployment)
  print("the list of deployments that the hpa has referred to but not exist now.")
  num=0
  for hpa in hpas:
    if hpa not in deployments:
      print(hpa)
      num+=1
  print("total num : " + str(num))
