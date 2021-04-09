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




