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
