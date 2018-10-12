# Creating a Kubernetes cluster for SQL Server 2019 big data cluster
SQL Server 2019 big data cluster is deployed as docker containers on a Kubernetes cluster. These samples provide scripts that can be used to provision a Kubernetes cluster using different methods.


## Create a Kubernetes cluster using Kubeadm
In this example, we will deploy Kubernetes over multiple Linux machines (physical or virtualized) using kubeadm utility. These instructions have been tested primarily with Ubuntu 16.04 LTS version. If you are using Ubuntu 18.04 LTS then some of the steps may need to be changed depending on your configuration.

### Pre-requisites
1. Multiple Linux machines or virtual machines. Recommended configuration is 8 CPUs, 32 GB memory each for each machine. Minimum number of machines required is three machines
1. Designate one machine as the Kubernetes master
1. Rest of the machine will be used as the Kubernetes agents

#### Useful resources
[Deploy SQL Server 2019 big data cluster on Kubernetes](https://docs.microsoft.com/en-us/sql/big-data-cluster/deployment-guidance?view=sqlallproducts-allversions)
[Creating a cluster using kubeadm](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/)
[Troubleshooting kubeadm](https://kubernetes.io/docs/setup/independent/troubleshooting-kubeadm/)

#### Instructions
1. Execute [kubeadm/setup-k8s-prereqs.sh](kubeadm/setup-k8s-prereqs.sh/) script on each machine
1. Execute [kubeadm/setup-k8s-master.sh](kubeadm/setup-k8s-master.sh/) script on the machine designated as Kubernetes master
1. After successful initialization of the Kubernetes master, follow the kubeadm join commands output by the script on each agent machine
1. Now, you can deploy SQL Server 2019 big data cluster using instructions [here](https://docs.microsoft.com/en-us/sql/big-data-cluster/deployment-guidance?view=sqlallproducts-allversions)
