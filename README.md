# Installing K8S 1.17 on CentOS 7
---------------------------------

Master:
=======
1-
```
sudo yum update -y
```

2-
```
sudo setenforce 0
```

3-
```
sudo sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
```

4-
```
# sudo yum remove cloud-init -y #optional if it is cloud image
sudo yum install epel-release -y
sudo yum install net-tools tcpdump vim wget tcpdump -y
```

5-
```
sudo tee -a /etc/yum.repos.d/kubernetes.repo << EOM
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOM
```

6-
```
sudo yum update -y
```

7-
```
sudo yum install -y docker
```

8-
```
sudo systemctl enable docker && sudo systemctl start docker
```

9-
```
sudo yum install -y kubelet-1.17.8-0.x86_64 kubeadm-1.17.8-0.x86_64 kubectl-1.17.8-0.x86_64
```

10-
```
sudo systemctl enable kubelet && sudo systemctl start kubelet
```

11-
OPTIONAL: To use custom certificate. add the CA or intermidery CA to the master node at /etc/kubernetes/pki. to create CA and Intermediate CA on linux machine check the steps here: [Certificate Geneartion](<https://github.com/mohanadelamin/k8s-installation-notes/blob/master/certificate_generation.md>)
```
sudo mkdir /etc/kubernetes/pki
cp ca.crt ca.key /etc/kubernetes/pki
```

12-
```
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address 10.193.86.8 --ignore-preflight-errors=all --apiserver-cert-extra-sans k8s-master.emea-ce.local,10.193.86.8
```

13-
```
sudo cp /etc/kubernetes/admin.conf $HOME/
sudo chown $(id -u):$(id -g) $HOME/admin.conf
export KUBECONFIG=$HOME/admin.conf
```

14-
```
curl -sSL "https://github.com/coreos/flannel/blob/master/Documentation/kube-flannel.yml?raw=true" | kubectl --namespace=kube-system create -f -
```

15-
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml
```

#####

Worker:
=======
1-
```
sudo yum update -y
```

2-
```
sudo setenforce 0
```

3-
```
sudo sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
```

4-
```
# sudo yum remove cloud-init -y #optional if it is cloud image
sudo yum install epel-release -y
sudo yum install net-tools tcpdump vim wget tcpdump -y
```

5-
```
sudo tee -a /etc/yum.repos.d/kubernetes.repo << EOM
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOM
```

6-
```
sudo yum update -y
```

7-
```
sudo yum install -y docker
```

8-
```
sudo systemctl enable docker && sudo systemctl start docker
```

9-
```
sudo yum install -y kubelet-1.17.8-0.x86_64 kubeadm-1.17.8-0.x86_64 kubectl-1.17.8-0.x86_64
```

10-
```
sudo systemctl enable kubelet && sudo systemctl start kubelet
```

11-
```
kubeadm join 10.193.86.8:6443 --token 9s1kqp.y9ckjzee671vzyod \
    --discovery-token-ca-cert-hash sha256:ab8d8d8f18d19658f3d1f8ec063f17a687a765bea93638308aa78aaa0ec3957b
```
