제가 담당하는 cluster를 관리하기 위한 script와 python 파일들을 올려놓을 공간입니다.

각 code에 대한 간단한 설명입니다.

|실행파일|참조 파일|비고|
|:-----|:-----|:-----|
|get_now.sh	|없음|현재 k8s resource 저장|
|get_pod_list_within_specific_time.py	|get_now.sh,<prd or stg>/current_resource/now_pod.txt|현재 POD의 정보와 backup_latest/에 저장된 정보 비교|
|resource.sh|env.sh, resource_list/resource*.list|All k8s resource backup |
|check_total_resource.py|env.sh, get_now.sh,<prd or stg>/current_resource/now_*.txt,<prd or stg>/backup_latest/get/*|POD를 제외한 모든 resource의 현재정보와 backup_latest에 저장된 정보 비교|
|backup.sh|env.sh|	인증서 교체 작업 준비|
|restore.sh|env.sh,<prd or stg>/deployment_desired_replicas.txt|인증서 교체 작업 준비|
|hpa.sh	|./hpa/hpa.sh <prd or stg>|	참조 deployment가 없는 hpa 목록조회|
|hpa/hpa.py|	hpa/<prd or stg>/now_<deployment or hpa>.txt|참조 deployment가 없는 hpa 목록조회|	|list_affinity.sh|env.sh|Deployment의 affinity 조회|
|pod.sh|env.sh|현재 실행중인 POD조회|


|환경 변수 파일|
|:-----|
|env.sh|
|resource_list/resource1.list|
|resource_list/resource2.list|
|resource_list/resource3.list|
|resource_list/resource4.list|


## ※ 참고 사항 : shell script의 경우, argument를 $로 표시

ex) ./test.sh hello world  --> 이 경우, $0 : test.sh, $1 : hello , $2 : world

### 1. get_now.sh

|참조 파일| 없음|
|:----|:----|
|실행 방법|``` ./get_now.sh {resource} {prd or stg}  ```|
|실행 과정|$1를 $2 클러스터에서 kubectl get을 통해 얻어낸 뒤, $2/current_resource/noe_$1.txt로 저장|
|실행 예시| ``` ./get_now.sh pod prd ``` <br><img src="/images/cluster/script5.jpg">|
|output | $2/current_resource/now_$1.txt|

### 2. get_pod_list_within_specific_time.py

|참조 파일| get_now.sh, <prd or stg>/current_resource/now_pod.txt |
|:----|:----|
|실행 방법|``` python get_pod_list_within_specific_time.py < prd or stg > < time >   ```|
|실행 과정| ※ 장애 발생 후 (장애 해결 이후) pod 상태 비교를 위한 파일 <br> get_now.sh 를 호출해서 $1/current_resource/now_*.txt를 생성 <br> $1 클러스터에서 $2 (min) 이전에 실행되었거나 not RUNNING POD출력 |
|실행 예시| ``` python get_pod_list_within_specific_time.py prd 10  ```<br> <img src="/images/cluster/script6.jpg">|
|output | stdout <br> POD의 age가 $2(min)보다 작은 경우, 노란색 줄로 표시<br>
POD의 status가 not Running 인 경우 붉은 줄로 표시  |

### 3. resource.sh

|참조 파일| env.sh, resource_list/resource*.list |
|:----|:----|
|실행 방법|``` ./resource.sh <prd or stg>  ```|
|실행 과정| resource_list/resource*.list에 저장된 kubernetes resource를 kubectl get, describe 로부터 값을 받아오고 이를 $1/backup_$time , $1/backup_latest 에 저장 <br>p.s. $time : 현재 날짜 (ex 2021-04-06) |
|실행 예시| ``` ./resource.sh prd  ```<br> <img src="/images/cluster/script7.jpg"><br> <img src="/images/cluster/script8.jpg">|
|output | $1/backup_latest/* , $1/backup_$time/* |

### 4. check_total_resource.py

|참조 파일|env.sh, get_now.sh, <br><prd or stg>/current_resource/now_*.txt, <prd or stg>/backup_latest/get/* |
|:----|:----|
|실행 방법|``` python check_total_resource.py <prd or stg> ```|
|실행 과정|※ 장애 발생 및 작업 전후 Kubernetes resource 상태 비교를 위한 코드<br>get_now.sh 를 호출해서 $1/current_resource/now_*.txt를 생성<br>resource.sh를 통해 저장해 놓은 $1/backup_latest/get/*의 값과 비교<br>( now_*.txt의 목록은 resource/resource*.list 에서 확인 가능 )|
|실행 예시| ``` python check_total_resource.py prd ```<br> <img src="/images/cluster/script18.jpg"><br> <img src="/images/cluster/script19.jpg"><br> <img src="/images/cluster/script20.jpg">|
|output |stdout으로 출력<br>not 'Healthy' componenestatuses, <br>not 'Ready' nodes,<br>not 'Bound' pv,<br>not 'Normal' events,<br>not 'Bound' pvc,<br>[ clusterrolebindings, clusterroles, namespaces, <br>priorityclasses, controllerrevisions, endpoints, <br> horizontalpodautoscalers, ingresses, rolebindings, <br>roles, secrets, serviceaccounts, configmaps] - > ./$1/backup_latest/get/*에 저장된 값중 지금 존재하지 않는 resource를 출력<br>DESIRED!= CURRENT or DESRIED!= READY or DESIRED!= AVAILABLE인 daemonsets,<br>DESIRED != CURRENT or DESIRED != AVAILABLE 인 deployments,<br>DESIRED != CURRENT or DESIRED != READY 인 replicasets,<br>DESIRED != CURRENT 인 statefulsets |

### 5. backup.sh

|참조 파일| |
|:----|:----|
|실행 방법|```   ```|
|실행 과정| |
|실행 예시| ```  ```<br> <img src="/images/cluster/script5.jpg">|
|output | |

### 6. restore.sh

|참조 파일| |
|:----|:----|
|실행 방법|```   ```|
|실행 과정| |
|실행 예시| ```  ```<br> <img src="/images/cluster/script5.jpg">|
|output | |

### 7. hpa.sh

|참조 파일| |
|:----|:----|
|실행 방법|```   ```|
|실행 과정| |
|실행 예시| ```  ```<br> <img src="/images/cluster/script5.jpg">|
|output | |

### 8. hpa/hpa.py

|참조 파일| |
|:----|:----|
|실행 방법|```   ```|
|실행 과정| |
|실행 예시| ```  ```<br> <img src="/images/cluster/script5.jpg">|
|output | |

### 9. list_affinity.sh

|참조 파일| |
|:----|:----|
|실행 방법|```   ```|
|실행 과정| |
|실행 예시| ```  ```<br> <img src="/images/cluster/script5.jpg">|
|output | |

### 10. pod.sh

|참조 파일| |
|:----|:----|
|실행 방법|```   ```|
|실행 과정| |
|실행 예시| ```  ```<br> <img src="/images/cluster/script5.jpg">|
|output | |



