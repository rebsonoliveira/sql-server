
# Deploy a SQL Server big data cluster on single node Kubernetes cluster (kubeadm)

Using this sample bash script, you will deploy a single node Kubernetes cluster using  kubeadm and a SQL Server big data cluster on top of it. The script must be run from the VM you are planning to use for your kubeadm deployment.

## Pre-requisites

1. A vanilla Ubuntu 16.04 or 18.04 VM. All dependencies will be setup by the script. Using Azure Linux VMs is not yet supported.
1. VM should have at least 8 CPUs, 64GB RAM and 100GB disk space. After installing the images you will be left with 50GB for data/logs across all components.

## Instructions

1. Download the script on the VM you are planning to use for the deployment

```

curl --output setup-bdc.sh https://raw.githubusercontent.com/microsoft/sql-server-samples/master/samples/features/sql-big-data-cluster/deployment/kubeadm/ubuntu-single-node-vm/setup-bdc.sh
```

2. Make the script executable

```

chmod +x setup-bdc.sh
```

3. Run the script (make sure you are running with sudo)

```

sudo ./setup-bdc.sh
```

4. Refresh alias setup for azdata

```

source ~/.bashrc
```

When prompted, provide your input for the password that will be used for all external endpoints: controller, SQL Server master and gateway. The password should be sufficiently complex based on existing rules for SQL Server password. The controller username is defaulted to *admin*.
