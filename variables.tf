variable "environment" {
  description = "The environment name, used in tags and names"
  type        = "string"
  default     = "myenv"
}

variable "region" {
  description = "AWS region"
  type        = "string"
  default     = "us-east-1"
}

variable "access-key" {
  description = "AWS access key"
  type        = "string"
}

variable "secret-key" {
  description = "AWS secret key"
  type        = "string"
}

variable "vpc-id" {
  description = "Target VPC"
  type        = "string"
}

# Used separate subnets for fixed IP addressing alleviates some of the risk
# of addressing conflicts when addresses are taken by other systems such as
# RDS or EKS
variable "private-fixed-subnet-ids" {
  description = "List of VPC Subnet IDs for IP addressing that is statically assigned"
  type        = "list"
}

variable "alb-private-subnet-ids" {
  description = "List of private subnet IDs for ALB endpoints"
  type        = "list"
}

variable "eks-private-subnet-ids" {
  description = "List of VPC Subnet IDs for EKS worker nodes and control plane access"
  type        = "list"
}

variable "dns-cidrs" {
  description = "CIDR blocks for DNS access"
  type        = "list"
  default     = ["169.254.169.253/32"]
}

variable "ntp-cidrs" {
  description = "CIDR blocks for NTP access"
  type        = "list"
  default     = ["169.254.169.123/32"]
}

variable "ssh-source-cidrs" {
  type    = "list"
  default = [ "10.1.0.0/16" ]
}

variable "software-bucket" {
  description = "Name of S3 bucket containing deployable software releases"
  type        = "string"
  default     = "my-software-bucket"
}

variable "eks-bootstrap" {
  description = "Properties needed to control progressive creation of EKS cluster"
  type        = "map"
  default     = {
    creator-role-exists = 1
  }
}

variable "eks-api-proxy" {
  type        = "map"
  default     = {
    ami           = "ami-0c6b1d09930fac512"
    instance-type = "t3.micro"
    ec2-key-name  = "my-ec2-ssh-key"
    ipv4          = "10.1.2.3"
    az            = 0
    enabled       = 1
  }
}

variable "eks-api-proxy-access-source-cidrs" {
  type    = "list"
  default = [ "10.1.0.0/16" ]
}

variable "eks-nodes-blue" {
  type        = "map"
  description = "configuration of blue EKS nodes"

  default = {
    min-size = 0
    max-size = 10

    ami           = "ami-08c4955bcc43b124e"
    instance-type = "r5.xlarge"
    ec2-key-name  = "my-ec2-ssh-key"
    disk-size-gb  = "100"

    node-exporter-binary-key = "node-exporter/node_exporter-0.18.1.linux-amd64.tar.gz"
  }
}

variable "dynamic-ingress" {
  description = ""
  type        = "map"

  default = {
    host-name-match          = "*.my-company.com"
    port                     = "32700"
  }
}

variable "internal-alb-cidr-blocks" {
  description = "CIDR blocks allowed access to internal ALB listener"
  type        = "list"
}

variable "dns-private-forward-zone-id" {
  description = "Route53 zone ID for registering names"
  type        = "string"
}

variable "dns-private-forward-zone-name" {
  description = "Route53 zone name for registering names"
  type        = "string"
}