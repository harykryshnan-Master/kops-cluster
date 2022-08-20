# Author - Navindu Jayatilake


module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = var.vpc_cidr_block

  # For high resiliency & fault-tolerancy, Multi-AZ VPC solution is used
  azs             = var.availability_zones
  private_subnets = var.subnet_cidr_blocks["private_subnets"]
  public_subnets  = var.subnet_cidr_blocks["public_subnets"]
  enable_nat_gateway = var.enable_nat_gateway
  
  # VPC Flow Logs (Cloudwatch log group and IAM role will be created)
  enable_flow_log                      = var.enable_vpc_flow_logs
  create_flow_log_cloudwatch_log_group = var.create_vpc_cw_log_group
  create_flow_log_cloudwatch_iam_role  = var.create_flow_log_cw_log_iam_role
  flow_log_max_aggregation_interval    = var.flow_log_max_aggregation_interval

  # Tagging for the VPC and support resources
  tags = var.tags
  vpc_tags = "${merge(var.tags, tomap({"Name" = "vpc-${var.application_name}-${var.environment}"}))}"
  private_subnet_tags = "${merge(var.tags, tomap({"Name" = "private-subnet-${var.application_name}-${var.environment}"}))}"
  public_subnet_tags = "${merge(var.tags, tomap({"Name" = "public-subnet-${var.application_name}-${var.environment}"}))}"
  nat_gateway_tags = "${merge(var.tags, tomap({"Name" = "nat-gateway-${var.application_name}-${var.environment}"}))}"
 
}

# -------------------------------------------------------
# QUESTION 02
# -------------------------------------------------------
# I have used kOps (Kubernetes Operations) to deploy the Kubernetes Cluster on the created AWS VPC
# Prior deploying I have created an S3 bucket(bayes-esports-assignment-kops-bucket)in us-east-1 to manage the kOps state file
# Here I have used Terraform "local-exec" provisioner type to invoke a local executable after a resource is created
# Passed all the aurguments necessary for the private network topolgy cluster creation
# for Assignment purpose I have used a single-master approach; But when creating for production setup it is recommended to go with multi-master setup.
# That way, if a master node is terminated the ASG will launch a new master instance with the master's volume. Because of the dedicated EBS volumes, each master is bound to a fixed Availability Zone (AZ). If the AZ becomes unavailable, the master instance in that AZ will also become unavailable.
# To connect to Kube cluster and manipluate with it, I have used a bastion server and deployed an nginx 

# Null resource to provision kOps Kubernetes cluster
resource "null_resource" "kops_cluster_provisioner" {

    provisioner "local-exec" {
        
        interpreter=["/bin/bash", "-c"]
        command =  <<EOT
                      ${path.module}/create_kops_cluster.sh 3 us-east-1a us-east-1b us-east-1c ${var.application_name}.k8s.local ${module.vpc.vpc_id} ${element(module.vpc.private_subnets, 0)} ${element(module.vpc.private_subnets, 1)} ${element(module.vpc.private_subnets, 2)} ${element(module.vpc.public_subnets, 0)} ${element(module.vpc.public_subnets, 1)} ${element(module.vpc.public_subnets, 2)}
                    EOT
    }
    depends_on = [module.vpc]
}
