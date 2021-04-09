# backup.sh
 
 deployment의 desired replica값을 저장하는 script입니다.
 
 서버 작업을 위해 서비스를 중단하는 경우, replica=0으로 설정하는 경우가 많습니다.
 
 이 때, 서버 작업 진행 후 다시 기존의 desired replica로 되돌리기 위한 백업 과정입니다.

``` shell
 ./backup.sh < prd or stg >
```

prd와 stg는 alias로, 각각 kubectl을 실행할 때 production, stage cluster의 kube config를 이용합니다.

실행 예시

```shell
./backup.sh prd
```

<img src="/images/cluster/script1.jpg">

prd를 argument로 넘겼으니 ./prd/deployment_desired_replicas.txt. 파일이 만들어 집니다.

<img src="/images/cluster/script2.jpg">

위와 같이 [ deployment의 NAME , DESIRED ] 형태로 저장됩니다.

이후 restore.sh에서 이 파일을 읽어 kubectl scale deployment $(NAME) --replicas=$(DESIRED) 형태로 복원을 진행합니다.


