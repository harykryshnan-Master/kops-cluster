#!/bin/bash


# subnets refers to private subnets
# utility-subnets refers to public subnets
# Note: here we have used existing VPC and Subnets to deploy our cluster. Hence, we should use utility-subnets, topology and networking options

# Export the kOps state
export KOPS_STATE_STORE=s3://kops-cluster-25


# Cluster creation
kops create cluster $5 \
       --state "s3://kops-s3-bucket-for-state" \
       --zones=$2,$3,$4  \
       --master-count=1 \
       --master-size=t2.medium \
       --master-zones=$2 \
       --node-count=3 \
       --node-size=t2.micro \
       --subnets=$7,$8,$9 \
       --utility-subnets="${10}","${11}","${12}" \
       --topology=private \
       --networking=calico \
       --yes

