
# Create EC2 Instance Profile
resource "aws_iam_instance_profile" "bastion_ssm_profile" {
  name = "${var.name}-ssm-profile"
  role = aws_iam_role.bastion_ssm_role.name
}

# Create EC2 Instance Role
resource "aws_iam_role" "bastion_ssm_role" {
  name                 = local.role_name
  permissions_boundary = var.permissions_boundary

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

# Attach AmazonSSMManagedInstanceCore policy to role
data "aws_iam_policy" "AmazonSSMManagedInstanceCore" {
  arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


resource "aws_iam_role_policy_attachment" "bastion-ssm-amazon-policy-attach" {
  role       = aws_iam_role.bastion_ssm_role.name
  policy_arn = data.aws_iam_policy.AmazonSSMManagedInstanceCore.arn
}

# Create S3/CloudWatch Logs access document, policy and attach to role
data "aws_iam_policy_document" "ssm_s3_cwl_access" {
  # checkov:skip=CKV_AWS_111: ADD REASON
  # A custom policy for S3 bucket access
  # https://docs.aws.amazon.com/en_us/systems-manager/latest/userguide/setup-instance-profile.html#instance-profile-custom-s3-policy
  statement {
    sid = "S3BucketAccessForSessionManager"

    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectVersionAcl",
    ]

    resources = [
      aws_s3_bucket.session_logs_bucket.arn,
      "${aws_s3_bucket.session_logs_bucket.arn}/*",
    ]
  }

  statement {
    sid = "S3EncryptionForSessionManager"

    actions = [
      "s3:GetEncryptionConfiguration",
    ]

    resources = [
      aws_s3_bucket.session_logs_bucket.arn
    ]
  }

  # A custom policy for CloudWatch Logs access
  # https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/permissions-reference-cwl.html
  statement {
    sid = "CloudWatchLogsAccessForSessionManager"

    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = ["*"]
  }

  statement {
    sid = "KMSEncryptionForSessionManager"

    actions = [
      "kms:DescribeKey",
      "kms:GenerateDataKey",
      "kms:Decrypt",
      "kms:Encrypt",
    ]

    resources = [aws_kms_key.ssmkey.arn]
  }
}

resource "aws_iam_policy" "ssm_s3_cwl_access" {
  name   = "${var.name}-ssm_s3_cwl_access-${var.aws_region}"
  path   = "/"
  policy = data.aws_iam_policy_document.ssm_s3_cwl_access.json
}

resource "aws_iam_role_policy_attachment" "bastion-ssm-s3-cwl-policy-attach" {
  role       = aws_iam_role.bastion_ssm_role.name
  policy_arn = aws_iam_policy.ssm_s3_cwl_access.arn
}

# Create ssm_ec2_access document, policy and attachment
data "aws_iam_policy_document" "ssm_ec2_access" {
  statement {
    sid = "KMSEncryptionForSessionManager"
    actions = [
      "kms:DescribeKey",
      "kms:GenerateDataKey",
      "kms:Decrypt",
      "kms:Encrypt",
    ]
    resources = [aws_kms_key.ssmkey.arn]
  }
  statement {
    actions = ["ssm:StartSession"]
    resources = [
      "arn:${data.aws_partition.current.partition}:ec2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:instance/${aws_instance.application.id}",
      "arn:${data.aws_partition.current.partition}:ssm:*:*:document/AWS-StartSSHSession"
    ]
  }
}
# Create a custom policy for the bastion and attachment
resource "aws_iam_policy" "ssm_ec2_access" {
  name   = "ssm-${var.name}-${var.aws_region}"
  path   = "/"
  policy = data.aws_iam_policy_document.ssm_ec2_access.json
}

resource "aws_iam_role_policy_attachment" "bastion-ssm-ec2-access-policy-attach" {
  role       = aws_iam_role.bastion_ssm_role.name
  policy_arn = aws_iam_policy.ssm_ec2_access.arn
}

# Create custom policy and attachment
resource "aws_iam_policy" "custom" {
  count       = local.add_custom_policy_to_role ? 1 : 0
  name        = "${local.role_name}-policy"
  path        = "/"
  description = "Custom policy for EC2 instance"

  policy = var.policy_content
}

resource "aws_iam_role_policy_attachment" "custom" {
  count      = local.add_custom_policy_to_role ? 1 : 0
  role       = aws_iam_role.bastion_ssm_role.name
  policy_arn = aws_iam_policy.custom[0].arn
}

# Additional policy attachments if needed

resource "aws_iam_role_policy_attachment" "managed" {
  count      = length(var.policy_arns)
  role       = aws_iam_role.bastion_ssm_role.name
  policy_arn = var.policy_arns[count.index]
}

# S3 readonly policy and attachment
resource "aws_iam_role_policy_attachment" "s3_companion_cube" {
  role       = aws_iam_role.bastion_ssm_role.name
  policy_arn = aws_iam_policy.s3_readonly_policy.arn
}

resource "aws_iam_policy" "s3_readonly_policy" {
  name   = "${local.bucket_prefix}-s3-readonly"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetObject"
            ],
            "Resource": [
              "${aws_s3_bucket.session_logs_bucket.arn}/*",
              "${aws_s3_bucket.session_logs_bucket.arn}"
            ]
        }
    ]
}
EOF
}

# S3 logging policy and attachment
resource "aws_iam_role_policy_attachment" "s3_logging_cube" {
  role       = aws_iam_role.bastion_ssm_role.name
  policy_arn = aws_iam_policy.s3_logging_policy.arn
}

resource "aws_iam_policy" "s3_logging_policy" {
  name   = "${local.bucket_prefix}-s3-logging"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
              "s3:ListBucket",
              "s3:GetObject",
              "s3:PutObject"
            ],
            "Resource": [
              "${aws_s3_bucket.access_log_bucket.arn}/*",
              "${aws_s3_bucket.access_log_bucket.arn}"
            ]
        }
    ]
}
EOF
}

# Terraform policy and attachment
resource "aws_iam_role_policy_attachment" "terraform" {
  role       = aws_iam_role.bastion_ssm_role.name
  policy_arn = aws_iam_policy.terraform_policy.arn
}

resource "aws_iam_policy" "terraform_policy" {
  # checkov:skip=CKV_AWS_286: TODO: Tighten this policy up. It currently allows actions that can be used for privilege escalation without constraint. Ref: https://docs.bridgecrew.io/docs/ensure-iam-policies-does-not-allow-privilege-escalation
  # checkov:skip=CKV_AWS_110: TODO: Fix CKV_AWS_286. It is identical to this policy.
  # checkov:skip=CKV_AWS_287: TODO: Tighten this policy up. It currently allows actions that can be used for credentials exposure without constraint. Ref: https://docs.bridgecrew.io/docs/ensure-iam-policies-do-not-allow-credentials-exposure
  # checkov:skip=CKV_AWS_107: TODO: Fix CKV_AWS_287. It is identical to this policy.
  # checkov:skip=CKV_AWS_288: TODO: Tighten this policy up. It currently allows actions that can be used to exfiltrate secrets or other data without constraint. https://docs.bridgecrew.io/docs/ensure-iam-policies-do-not-allow-data-exfiltration
  # checkov:skip=CKV_AWS_108: TODO: Fix CKV_AWS_288. It is identical to this policy.
  # checkov:skip=CKV_AWS_289: TODO: Tighten this policy up. It currently allows actions that can be used for permissions management and/or resource exposure without constraint. Ref: https://docs.bridgecrew.io/docs/ensure-iam-policies-do-not-allow-permissions-management-resource-exposure-without-constraint
  # checkov:skip=CKV_AWS_109: TODO: Fix CKV_AWS_289. It is identical to this policy.
  # checkov:skip=CKV_AWS_290: TODO: Tighten this policy up. It currently allows actions that can be used to for resource exposure without constraint. Ref: https://docs.bridgecrew.io/docs/ensure-iam-policies-do-not-allow-write-access-without-constraint
  # checkov:skip=CKV_AWS_111: TODO: Fix CKV_AWS_290. It is identical to this policy.

  name   = "${local.bucket_prefix}-terraform-policy"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "autoscaling:*",
                "aws-marketplace-management:*",
                "aws-marketplace:*",
                "cloudformation:*",
                "cloudtrail:*",
                "cloudwatch:*",
                "events:*",
                "logs:*",
                "dynamodb:*",
                "glacier:*",
                "dms:*",
                "iam:GetPolicyVersion",
                "iam:GetRole",
                "iam:ListInstance*",
                "iam:CreateInstanceProfile",
                "iam:UploadServerCertificate",
                "iam:UpdateServerCertificate",
                "iam:GetServerCertificate",
                "iam:DeleteServerCertificate",
                "iam:DetachRolePolicy",
                "iam:DeleteRolePolicy",
                "iam:PutRolePermissionsBoundary",
                "iam:PutRolePolicy",
                "iam:CreatePolicy",
                "iam:CreatePolicyVersion",
                "iam:AttachRolePolicy",
                "iam:*InstanceProfile",
                "iam:Generate*",
                "iam:Get*",
                "iam:List*",
                "iam:Sim*",
                "iam:Tag*",
                "iam:Untag*",
                "iam:*ServiceLinkedRole",
                "ec2:*",
                "elasticbeanstalk:*",
                "elasticache:*",
                "elasticloadbalancing:*",
                "elasticmapreduce:*",
                "events:*",
                "glacier:*",
                "kinesis:*",
                "kms:*",
                "lambda:*",
                "logs:*",
                "ram:*",
                "rds:*",
                "redshift:*",
                "s3:*",
                "sns:*",
                "sqs:*",
                "swf:*",
                "tag:*",
                "workspaces:*",
                "ecs:*",
                "ecr:*",
                "inspector:Create*",
                "inspector:Delete*",
                "inspector:DescribeCrossAccountAccessRole",
                "inspector:DescribeAssessmentRuns",
                "inspector:DescribeAssessmentTargets",
                "inspector:DescribeAssessmentTemplates",
                "inspector:DescribeFindings",
                "inspector:DescribeResourceGroups",
                "inspector:DescribeRulesPackages",
                "inspector:List*",
                "inspector:PreviewAgents",
                "inspector:RemoveAttributesFromFindings",
                "inspector:SetTagsForResource",
                "inspector:StartAssessmentRun",
                "inspector:StopAssessmentRun",
                "inspector:SubscribeToEvent",
                "inspector:UnsubscribeFromEvent",
                "inspector:UpdateAssessmentTarget"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "iam:PassRole"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Effect": "Allow",
            "Action": [
                "eks:DescribeCluster"
            ],
            "Resource": "*"
        },
        {
            "Action": [
                "iam:DeletePolicy",
                "iam:DeletePolicyVersion"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "iam:DeleteRole"
            ],
            "Resource": [
                "arn:${data.aws_partition.current.partition}:iam::*:role/*-rke2-*",
                "arn:${data.aws_partition.current.partition}:iam::*:role/*"
            ],
            "Effect": "Allow"
        },
        {
            "Action": [
                "iam:CreateRole"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "ssm:*"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "sts:AssumeRole"
            ],
            "Resource": [
                "arn:${data.aws_partition.current.partition}:iam::*:role/s3-dataRefresh"
            ],
            "Effect": "Allow"
        },
        {
            "Action": [
                "aws-portal:*Billing",
                "s3:PutBucketPublicAccessBlock",
                "s3:PutAccountPublicAccessBlock"
            ],
            "Resource": "*",
            "Effect": "Deny"
        }
    ]
}
EOF
}
# Create custom policy for KMS
data "aws_iam_policy_document" "kms_access" {
  # checkov:skip=CKV_AWS_111: todo reduce perms on key
  # checkov:skip=CKV_AWS_109: todo be more specific with resources
  statement {
    sid = "KMS Key Default"
    principals {
      type = "AWS"
      identifiers = [
        "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }

    actions = [
      "kms:*",
    ]

    resources = ["*"]
  }
  statement {
    sid = "CloudWatchLogsEncryption"
    principals {
      type        = "Service"
      identifiers = ["logs.${var.aws_region}.amazonaws.com"]
    }
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*",
    ]

    resources = ["*"]
  }
  statement {
    sid = "Cloudtrail KMS permissions"
    principals {
      type = "Service"
      identifiers = [
        "cloudtrail.amazonaws.com"
      ]
    }
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*",
    ]
    resources = ["*"]
  }

}
