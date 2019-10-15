resource "aws_instance" "eks-api-proxy" {
  associate_public_ip_address = false
  
  private_ip    = "${var.eks-api-proxy["ipv4"]}"
  ami           = "${var.eks-api-proxy["ami"]}"
  instance_type = "${var.eks-api-proxy["instance-type"]}"
  subnet_id     = "${element(var.private-fixed-subnet-ids, var.eks-api-proxy["az"])}"
  key_name      = "${var.eks-api-proxy["ec2-key-name"]}"

  vpc_security_group_ids = ["${aws_security_group.eks-cluster-api-proxy.id}"]

  user_data = "${data.template_file.eks-api-proxy.rendered}"

  root_block_device {
    volume_type = "gp2"
    volume_size = "8"
    
    delete_on_termination = true
  }

  tags {
    Name        = "${var.environment}-eks-api-proxy"
    Environment = "${var.environment}"
  }

  count = "${signum(var.eks-api-proxy["enabled"])}"
}

data "template_file" "eks-api-proxy" {

  template = "${file("./content/eks-api-proxy.cloudinit.yml")}"
  
  vars = {
    ApiEndpoint  = "${aws_eks_cluster.cluster.endpoint}"
    LaunchScript = "${base64encode(file("./content/eks-api-proxy-launch"))}"
  }
}