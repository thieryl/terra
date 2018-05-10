output "security_group" {
  value = "${aws_security_group.elb.id}"
}

output "launch_configuration" {
  value = "${aws_launch_configuration.web-lc.id}"
}

output "asg_name" {
  value = "${aws_autoscaling_group.web-asg.id}"
}

output "elb_name" {
  value = "${aws_elb.web-elb.dns_name}"
}

variable "asg_min" {
  description = "Min numbers of servers in ASG"
  default     = "1"
}

variable "asg_max" {
  description = "Max numbers of servers in ASG"
  default     = "2"
}

variable "asg_desired" {
  description = "Desired numbers of servers in ASG"
  default     = "1"
}

variable "availability_zones" {
  default     = "us-east-1b,us-east-1c,us-east-1d,us-east-1e"
  description = "List of availability zones, use AWS CLI to find your "
}
