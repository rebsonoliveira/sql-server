

# Create a Kubernetes cluster using Kubeadm on Ubuntu 16.04 LTS or 18.04 LTS 

In this example, we will deploy Kubernetes over multiple Linux machines (physical or virtualized) using kubeadm utility. These instructions have been tested primarily with Ubuntu 16.04 LTS version. If you are using Ubuntu 18.04 LTS then install of docker.io may fail with message below depending on your configuration.

    Package docker.io is not available, but is referred to by another package.
    This may mean that the package is missing, has been obsoleted, or
    is only available from another source
    
    E: Package 'docker.io' has no installation candidate
    
To install docker, you can follow the steps below:

    #!/usr/bin/env bash
    
    sudo apt update
    
    sudo apt --yes install \
        software-properties-common \
        apt-transport-https \
        ca-certificates \
        curl
    
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    
    sudo add-apt-repository \
        "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    
    sudo apt update
    
    sudo apt --yes install docker-ce
    
    sudo usermod --append --groups docker $USER


## Pre-requisites

1. Multiple Linux machines or virtual machines. Recommended configuration is 8 CPUs, 32 GB memory each and at least 100 GB storage for each machine. Minimum number of machines required is three machines
1. Designate one machine as the Kubernetes master
1. Rest of the machines will be used as the Kubernetes agents

### Useful resources

[Deploy SQL Server 2019 big data cluster on Kubernetes](https://docs.microsoft.com/en-us/sql/big-data-cluster/deployment-guidance?view=sqlallproducts-allversions)

[Creating a cluster using kubeadm](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/)

[Troubleshooting kubeadm](https://kubernetes.io/docs/setup/independent/troubleshooting-kubeadm/)

### Instructions

1. Execute [ubuntu/ubuntu-setup-k8s-prereqs.sh](ubuntu/ubuntu-setup-k8s-prereqs.sh/) script on each machine
1. Execute [ubuntu/ubuntu-setup-k8s-master.sh](ubuntu/ubuntu-setup-k8s-master.sh/) script on the machine designated as Kubernetes master
1. After successful initialization of the Kubernetes master, follow the kubeadm join commands output by the script on each agent machine
1. Now, you can deploy SQL Server 2019 big data cluster using instructions [here](https://docs.microsoft.com/en-us/sql/big-data-cluster/deployment-guidance?view=sqlallproducts-allversions)
