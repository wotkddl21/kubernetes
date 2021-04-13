# Kubeadm

kubeadm은 kubernetes 공식 설치 도구입니다.

이번에는  kubeadm과 keepalived, haproxy를 통해 multi-master kubernetes cluster를 구축해보겠습니다.

master node : 3대, worker node 1대로 구성할 예정입니다.

|NODE 이름|Role|ip|
|:---|:---|:---|
|master1|master|~~|
|master2|master|~~|
|master3|master|~~|
|worker1|worker1|~~|
|worker2|worker2|~~|

master node들은 아래와 같은 구조로 구축할 예정입니다.

<img src="images/multimaster/1.jpg>">

비어있는 ip인 130.1.3.200를 vip로 사용할 것 입니다.

우선 필요한 리소스들을 설치하겠습니다.

``` shell
chmod +x ./install.sh
./install.sh
```
<img src="/images/multimaster/2.jpg>">

master 3대 중 1대는 NMASTER, 나머지 2대는 BACKUP으로 설정합니다.

``` shell
cat <<EOF > /etc/keepalived/keepalived.conf
global_defs {
	router_id LVS_DEVEL
}
vrrp_instance VI_1 {
	state NMASTER
	interface enp0s3
	virtual_router_id 51
	priority 101
	authentication {
		auth_type PASS
		auth_pass 12345
	}
	virtual_ipaddress {
		130.1.3.200
	}
}
EOF

```
--> master

``` shell
cat <<EOF > /etc/keepalived/keepalived.conf
global_defs {
	router_id LVS_DEVEL
}
vrrp_instance VI_1 {
	state BACKUP
	interface enp0s3
	virtual_router_id 51
	priority 101
	authentication {
		auth_type PASS
		auth_pass 12345
	}
	virtual_ipaddress {
		130.1.3.200
	}
}
EOF

```
