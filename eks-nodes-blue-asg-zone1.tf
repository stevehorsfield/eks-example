resource "aws_autoscaling_group" "eks-nodes-blue-zone1" {
  name = "${var.environment}-eks-nodes-blue-zone1"

  min_size = "${var.eks-nodes-blue["min-size"]}"
  max_size = "${var.eks-nodes-blue["max-size"]}"
  
  health_check_grace_period = 300
  health_check_type         = "EC2" # ELB checks require all load balancer checks to pass which is too aggressive
  default_cooldown          = 180

  force_delete = false

  launch_configuration = "${aws_launch_configuration.eks-nodes-blue.name}"

  vpc_zone_identifier = ["${element(var.eks-private-subnet-ids,1)}"]

  suspended_processes = [ ]

  wait_for_capacity_timeout = 0 # Don't make Terraform wait for healthy instances
  wait_for_elb_capacity     = 0

  target_group_arns = [
    "${aws_lb_target_group.internal-ingress-dynamic.arn}",
  ]

  tag {
    key                  = "Name"
    value                = "${var.environment}-eks-nodes-blue-zone1"
    propagate_at_launch  = true
  }

  tag {
    key                  = "Environment"
    value                = "${var.environment}"
    propagate_at_launch  = true
  }

  tag {
    key                  = "AutoScalingGroupName"
    value                = "${var.environment}-eks-nodes-blue-zone1"
    propagate_at_launch  = true
  }

  tag {
    key                  = "kubernetes.io/cluster/${aws_eks_cluster.cluster.name}"
    value                = "owned"
    propagate_at_launch  = true
  }
}