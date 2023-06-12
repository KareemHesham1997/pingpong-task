# pingpong-task

1- Terraform infrastructure as a code to build the infrastructure, Terraform code includes:

(VPC - 2 public subnets - 2 private subnets - EKS cluster with workernode and roles - internet gateway - nat gateway - route tables - Bastion Host).

2- Ansible:

Used Ansible playbook, roles & tasks to install Docker daemon in the workernode

Note: to be able to use ansible with a private workernode you have to touch a config file in this path ~/.ssh/config the config file is as follow:

Host bastion
    hostname "public ip of the bastion"
    user ubuntu
    port 22
    identityfile /path/to/the/key
    
3- AWS EKS:

Used to deploy App

4- Docker:

Used to build dockerfiles for jenkins and the app

5- Jenkins:

Used to make the CI CD part and make a complete pipeline
