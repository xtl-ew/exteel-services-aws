# Provider vars
variable "access_key"                { default = "" }
variable "secret_key"                { default = "" }
variable "region"                    { default = "eu-west-1" }
variable "account_alias"             { default = "" }

variable "lambda_cost_report_amount_limit"      { default = "1" }
variable "lambda_cost_report_slack_webhook_url" { default = "" }

# EC2 vars
variable "ec2_key_pair_name"         { default = "adminkey" }
variable "ec2_key_pair_pub"          { default = "" }

# VPC vars
variable "vpc_cidr"                  { default = "10.10.0.0/16" }
variable "admin_ips"                 { default = [] }

# OCI load
variable "payload_image"             { default = "docker.io/axedsteel/serveremu-alpha:25122023" }
variable "db_image"                  { default = "docker.io/coleifer/sqlite-web:latest" }
