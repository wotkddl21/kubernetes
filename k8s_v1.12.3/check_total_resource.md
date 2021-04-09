# check_total_resource.py

resource.sh 를 통해 backup_latest에 저장된 값과 현재 cluster를 통해 얻어낸 값의 차이를 보여주는 코드입니다.

서버작업을 진행하기 전, ./resource.sh를 통해 현재 클러스터의 상태를 snapshot형태로 저장합니다.

서버작업 이후 이 코드를 실행시켜 snapshot에 저장된 클러스터 상태와 현재를 비교합니다.

POD의 경우, 이름의 hash값이 달라지기 때문에 이 코드에서는 고려하지 않고 pod.sh에서 다뤘습니다.

deployment, replicaset, daemonset 같은 경우 desired값과 runnung 혹은 available값이 다른지 확인하는 과정을 거쳤습니다.

<img src="/images/cluster/script18.jpg">

<img src="/images/cluster/script19.jpg">

<img src="/images/cluster/script20.jpg">

