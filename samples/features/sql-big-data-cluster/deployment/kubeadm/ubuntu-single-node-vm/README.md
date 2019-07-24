
# Deploy a SQL Server big data cluster on single node Kubernetes cluster (kubeadm)

Using this sample bash script, you will deploy a single node Kubernetes cluster using  kubeadm and a SQL Server big data cluster on top of it. The script must be run from the VM you are planning to use for your kubeadm deployment.

## Pre-requisites

1. A vanilla Ubuntu 16.04 or 18.04 VM. All dependencies will be setup by the script. Using Azure Linux VMs is not yet supported.
1. VM should have at least 8CPUs, 64GB RAM and 100GB disk space.After installing the images you will be left with 50GB for data/logs across all components.

## Instructions

1. Download the script on the VM you are planning to use for the deployment

```

curl --output kickstarter-azdata.sh  http://rima-5.guest.corp.microsoft.com/kickstarter-azdata.sh
```

1. Make the script executable

```

chmod +x kickstarter-azdata.sh
```

1. Run the script (make sure you are running with sudo)

```

sudo ./kickstarter-azdata.sh
```

1. Refresh alias setup for azdata

```

source ~/.bashrc
```

When prompted, provide your input for the password that will be used for all external endpoints: controller, SQL Server master and gateway. The password should be sufficiently complex based on existing rules for SQL Server password. The controller username is defaulted to *admin*.
