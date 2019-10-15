resource "aws_launch_configuration" "eks-nodes-blue" {
  name_prefix          = "${var.environment}-eks-nodes-blue"
  image_id             = "${var.eks-nodes-blue["ami"]}"
  instance_type        = "${var.eks-nodes-blue["instance-type"]}"
  iam_instance_profile = "${aws_iam_instance_profile.eks-nodes.id}"
  key_name             = "${var.eks-nodes-blue["ec2-key-name"]}"
  security_groups      = [ 
    "${aws_security_group.eks-cluster-node-base.id}",
    "${aws_security_group.eks-cluster-node-standard.id}",
  ]

  associate_public_ip_address = false

  user_data = "${data.template_file.eks-nodes-blue-userdata.rendered}"

  enable_monitoring = true

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "${var.eks-nodes-blue["disk-size-gb"]}"
    delete_on_termination = true
  }

  placement_tenancy = "default"

  lifecycle {
    create_before_destroy = true
  }
}

data "template_file" "eks-nodes-blue-userdata" {

  template = "${file("./content/eks-nodes-blue.cloudinit.yml")}"
  
  vars = {
    LaunchScript    = "${base64encode(file("./content/eks-nodes-blue-launch"))}"
    ClusterName     = "${aws_eks_cluster.cluster.name}"
    ClusterAPI      = "${aws_eks_cluster.cluster.endpoint}"
    ClusterCABase64 = "${aws_eks_cluster.cluster.certificate_authority.0.data}"

    node-exporter-release-s3-uri            = "s3://${var.software-bucket}/${var.eks-nodes-blue["node-exporter-binary-key"]}"
    node-exporter-installation-files-s3-uri = "s3://${aws_s3_bucket.system-configuration.id}/node-exporter"

    update-auto-reboot-installation-files-s3-uri = "s3://${aws_s3_bucket.system-configuration.id}/update-auto-reboot"
  }
}