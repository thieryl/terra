variable "public_key_path" {
  description = <<DESCRIPTION
Path to the SSH public key to be used for authentication.
Ensure this keypair is added to your local SSH agent so provisioners can
connect.

Example: ~/.ssh/terraform.pub
DESCRIPTION

  default = "~/.ssh/terraform.pub"
}

variable "key_name" {
  description = "Desired name of AWS key pair"
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "eu-west-1"
}

# Ubuntu Precise 12.04 LTS (x64)
variable "aws_amis" {
  default = {
    eu-west-1 = "ami-9cbe9be5"
    eu-west-2 = "ami-c12dcda6"
  }
}

variable "instance_type" {
  default     = "t2.micro"
  description = "AWS instance type"
}

variable "availability_zones" {
  default     = "eu-west-1a,eu-west-1b,eu-west-1c"
  description = "List of availability zones, use AWS CLI to find your "
}

variable "asg_min" {
  description = "Min numbers of servers in ASG"
  default     = "1"
}

variable "asg_max" {
  description = "Max numbers of servers in ASG"
  default     = "2"
}

variable "desired_capacity" {
  description = "Desired numbers of servers in ASG"
  default     = "1"
}
