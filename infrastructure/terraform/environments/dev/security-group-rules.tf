// Temporary public access
resource "aws_security_group_rule" "node_ingress_lb" {
  security_group_id = module.foundation.node_security_group_id
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow inbound traffic from load balancers"
}

resource "aws_security_group_rule" "node_ingress_from_cluster" {
  security_group_id        = module.foundation.node_security_group_id
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  source_security_group_id = module.foundation.cluster_security_group_id
  description              = "Allow worker nodes to receive communication from the cluster control plane"
}
