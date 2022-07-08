variable "application_name" {
  type = string
  description = "Name of the application"
}
variable "vpc_name" {
  type = string
  description = "Name of the VPC"
}

variable "vpc_cidr_block" {
  type = string
  description = "CIDR block of the VPC"
}

variable "availability_zones" {
  type = list
  description = "Availability zones that the subnets should be distributed across"
}

variable "subnet_cidr_blocks" {
  type = map
  description = "CIDR block for subnets"
}

variable "tags" {
  type = map
  description = "Mandatory tags of the VPC"
}

variable "enable_nat_gateway" {
  type = bool
  description = "Enable NAT Gateway (True/False)"
}

variable "enable_vpn_gateway" {
  type = bool
  description = "Enable VPN Gateway (True/False)"
}

variable "enable_vpc_flow_logs" {
  type = bool
  description = "Enable VPC flow logs (True/False)"
}

variable "create_vpc_cw_log_group" {
  type = bool
  description = "Create CloudWatch log group for VPC flow log (True/False)"
}

variable "create_flow_log_cw_log_iam_role" {
  type = bool
  description = "Create IAM Role for CloudWatch log group of flow logs (True/False)"
}

variable "flow_log_max_aggregation_interval" {
  type = number
  description = "Max aggregation interval of VPC flow log"
}

variable "environment" {
  type = string
  description = "Environment of the application"
}