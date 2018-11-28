
# Creating a Kubernetes cluster for SQL Server 2019 big data cluster

SQL Server 2019 big data cluster is deployed as docker containers on a Kubernetes cluster. These samples provide scripts that can be used to provision a Kubernetes clusters using different environments.

## Create a Kubernetes cluster using Kubeadm on Ubuntu 16.04 LTS or 18.04 LTS 

Use the scripts in the **kubeadm** folder to deploy Kubernetes over multiple Linux machines (physical or virtualized) using `kubeadm` utility. 

## Deploy a SQL Server big data cluster on Azure Kubernetes Service (AKS) 

Using the sample Python script in **aks** folder, you will deploy a Kubernetes cluster in Azure using AKS and a SQL Server big data cluster using on top of it. 
