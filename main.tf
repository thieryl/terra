# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
}

# Create a VPC to launch our instances into
#resource "aws_vpc" "default" {
#  cidr_block = "10.0.0.0/16"
#
#}
# Create an internet gateway to give our subnet access to the outside world
#resource "aws_internet_gateway" "default" {
#  vpc_id = "${aws_vpc.default.id}"
#}

# Grant the VPC internet access on its main route table
#resource "aws_route" "internet_access" {
#  route_table_id         = "${aws_vpc.default.main_route_table_id}"
#  destination_cidr_block = "0.0.0.0/0"
#  gateway_id             = "${aws_internet_gateway.default.id}"
#}
#
## Create a subnet to launch our instances into
#resource "aws_subnet" "default" {
#  vpc_id                  = "${aws_vpc.default.id}"
#  cidr_block              = "10.0.1.0/24"
#  map_public_ip_on_launch = true
#}

# A security group for the ELB so it is accessible via the web
resource "aws_security_group" "elb" {
  name        = "terraform_example_elb"
  description = "Used in the terraform"

  #vpc_id      = "${aws_vpc.default.id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "web-elb" {
  name               = "terraform-example-elb"
  availability_zones = ["${split(",",var.availability_zones)}"]

  #subnets         = ["${aws_subnet.default.id}"]
  #security_groups = ["${aws_security_group.elb.id}"]
  #instances       = ["${aws_instance.web.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }
}

resource "aws_launch_configuration" "web-lc" {
  name          = "terraform-example-launch-config"
  image_id      = "${lookup(var.aws_amis, var.aws_region)}"
  instance_type = "${var.instance_type}"

  #Security Groups
  security_groups = ["${aws_security_group.elb.id}"]
  user_data       = "${file("user_data.sh")}"
  key_name        = "${var.key_name}"
}

resource "aws_autoscaling_group" "web-asg" {
  availability_zones   = ["${split(",",var.availability_zones)}"]
  name                 = "terraform-asg-example"
  max_size             = "${var.asg_max}"
  min_size             = "${var.asg_min}"
  desired_capacity     = "${var.desired_capacity}"
  force_delete         = true
  launch_configuration = "${aws_launch_configuration.web-lc.name}"
  load_balancers       = ["${aws_elb.web-elb.name}"]

  #vpc_zone_identifier = ["${split(",",var.availability_zones)}"]
  tags {
    key                 = "Name"
    value               = "web-asg"
    propagate_at_launch = true
  }
}

resource "aws_key_pair" "auth" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

#resource "aws_instance" "web" {
#  # The connection block tells our provisioner how to
#  # communicate with the resource (instance)
#  connection {
#    # The default username for our AMI
#    user = "ec2-user"
#
#    # The connection will use the local SSH agent for authentication.
#  }
#
#  instance_type = "t2.micro"
#
#  tags {
#    Name = "tlo-web"
#  }
#
#  # Lookup the correct AMI based on the region
#  # we specified
#  ami = "${lookup(var.aws_amis, var.aws_region)}"
#
#  # The name of our SSH keypair we created above.
#  key_name = "${aws_key_pair.auth.id}"
#
#  # Our Security group to allow HTTP and SSH access
#  vpc_security_group_ids = ["${aws_security_group.default.id}"]
#
#  # We're going to launch into the same subnet as our ELB. In a production
#  # environment it's more common to have a separate private subnet for
#  # backend instances.
#  subnet_id = "${aws_subnet.default.id}"
#
#  # We run a remote provisioner on the instance after creating it.
#  # In this case, we just install nginx and start it. By default,
#  # this should be on port 80
#
#  provisioner "remote-exec" {
#    inline = [
#      "sudo yum update -qy",
#      "sudo yum install nginx -y",
#      "sudo service nginx start",
#    ]
#  }
#}
#

