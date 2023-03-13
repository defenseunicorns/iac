locals {
  role_name                 = "${var.name}-role"
  add_custom_policy_to_role = var.policy_content != null && var.policy_content != ""

  bucket_prefix = var.name

  # ssh access
  keys_update_frequency      = "*/5 * * * *"
  enable_hourly_cron_updates = true

  security_group_configs = [{
    name        = "${var.name}-sg"
    description = "SG for ${var.name}"
    vpc_id      = var.vpc_id
    ingress_rules = [{
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.allowed_public_ips # admin IPs or private IP (internal) of Software Defined Perimter
      description = "SSH access"
      },
    ]
    egress_rules = [{
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound traffic"
    }]
  }]
}
