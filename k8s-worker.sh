#!/bin/bash
echo "Updating system ....."
sudo yum update -y 

echo "Disabling SELINUX ....."
sudo setenforce 0 
sudo sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux 

echo "Removing cloud-init ....."
sudo yum remove cloud-init -y 

echo "Installing Epel release repo ....."
sudo yum install epel-release -y 

echo "Installing networking tools ....."
sudo yum install net-tools tcpdump vim wget tcpdump -y 

echo "Updating K8s repo ....."
sudo tee -a /etc/yum.repos.d/kubernetes.repo << EOM
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOM

echo "Updating system ....."
sudo yum update -y 

echo "Installing Docker ....."
sudo yum install -y 

echo "Starting and enabling Docker ......"
sudo systemctl enable docker && sudo systemctl start docker 

echo "Installing kubernetes 1.17 ....."
sudo yum install -y kubelet-1.17.8-0.x86_64 kubeadm-1.17.8-0.x86_64 kubectl-1.17.8-0.x86_64 

echo "Starting and enabling kubelet ....."
sudo systemctl enable kubelet && sudo systemctl start kubelet 

echo "Joining the kubernetes cluster ....."
echo "Run the kubeadm join command from the k8s-master.sh script results"
