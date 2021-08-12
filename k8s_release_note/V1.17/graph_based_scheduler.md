# Poseidon-Firmament Scheduler

## Introduction

데이터 센터 단위 혹은 Warehouse단위의 컴퓨팅 환경에서 클러스터를 스케줄 하기 위해 Mesos, Google Borg, Kubernetes가 등장했다.

Cluster scheduler는 resource들을 계산해서 workload를 분배한다.

## Poseidon-Firmament Scheduler - How It Works

Poseidon-Firmament scheduler(이하 PF)는 kubernetes의 기본 scheduler 옆에서 network graph기반의 스케줄링을 통해 kubernetes의 scheduling능력을 극대화할 수 있다.

Network graph를 통해 최적화를 하기 때문에 스케줄링 오버헤드를 줄인다.

## 주요 특징

성능 테스트 결과 PF는 클러스터의 노드의 수가 많아질 수록, kubernetes default scheduler보다 탁월한 성능을 보여줬다.

노드 2700개로 구성된 클러스터에서 실험하니, default scheduler보다 7배 높은 성능을 기록했다.

다양한 rule constraint를 지원한다.


## Poseidon Mediation Layer

kube default scheduler가 POD를 스케줄링한 뒤 배포하기 직전에 다른 scheduler에게 조언을 구할 수 있다.

Poseidon은, default scheduler에게 해당 pod에 최적화된 node를 알려주고, default scheduler는 이를 따르게 된다.

## Use Case

deployment, job과 같은 다양한 scheduling을 진행할 수 있지만 특히 Big data/AI job과 같이 많은 task로 이루어진 job들에 있어서는 엄청난 이점을 가져다 준다.

