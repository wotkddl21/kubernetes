echo -e -n "\e[93m"
echo "apt-get update"
apt-get update

echo "swapoff -a"
swapoff -a

echo "apt-get install vim curl net-tools git conntrack  -y"
apt-get install vim curl net-tools -y

echo "apt-get install apt-transport-https ca-certificates"
apt-get install apt-transport-https ca-certificates

echo "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

echo "add repository"
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $( lsb_release -cs ) stable" 

apt-get update
echo "install docker"
apt-get install docker-ce docker-ce-cli containerd.io -y

cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

echo "change cgroup driver from cgroupfs to systemd"
mkdir -p /etc/systemd/system/docker.service.d
sed -i '12s/^/#/' /etc/fstab
echo "reload docker"
systemctl daemon-reload
systemctl restart docker

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | \
sudo tee /etc/apt/sources.list.d/kubernetes.list
apt-get update -q
echo -e -n "\e[0m"

