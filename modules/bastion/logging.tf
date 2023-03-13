# Create a log group for ssh accesss
resource "aws_cloudwatch_log_group" "ssh-access-log-group" {
  name              = "/aws/events/ssh-access"
  retention_in_days = 60
  kms_key_id        = aws_kms_key.ssmkey.arn
}

# Create a cloudtrail and event rule to monitor bastion access over ssh
resource "aws_cloudtrail" "ssh-access" {
  # checkov:skip=CKV_AWS_252: SNS not currently needed
  # checkov:skip=CKV2_AWS_10: Cloudwatch logs already being used with cloudtrail
  name                       = "ssh-access"
  s3_bucket_name             = aws_s3_bucket.access_log_bucket.id
  kms_key_id                 = aws_kms_key.ssmkey.arn
  is_multi_region_trail      = true
  enable_log_file_validation = true
  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }
  depends_on = [
    aws_s3_bucket_policy.cloudwatch-s3-policy,
    aws_kms_key.ssmkey,
    aws_cloudwatch_log_group.ssh-access-log-group
  ]
}

resource "aws_cloudwatch_event_rule" "ssh-access" {
  name        = "ssh-access"
  description = "filters ssm access logs and sends usable data to a cloudwatch log group"

  event_pattern = <<EOF
{
  "source": ["aws.ssm"],
  "detail-type": ["AWS API Call via CloudTrail"],
  "detail": {
    "eventSource": ["ssm.amazonaws.com"],
    "eventName": ["IAMUser","StartSession"]
  }
}
EOF
}

resource "aws_cloudwatch_event_target" "ssm-target" {
  rule      = aws_cloudwatch_event_rule.ssh-access.name
  target_id = "ssh-access-target"
  arn       = aws_cloudwatch_log_group.ssh-access-log-group.arn
}

# Create a cloudwatch agent configuration file and log group
resource "aws_ssm_parameter" "cloudwatch_configuration_file" {
  name      = "AmazonCloudWatch-linux-${var.name}"
  type      = "SecureString"
  overwrite = true
  value = jsonencode({
    "agent" : {
      "metrics_collection_interval" : 60,
      "run_as_user" : "root"
    },
    "logs" : {
      "logs_collected" : {
        "files" : {
          "collect_list" : [
            {
              "file_path" : "/root/.bash_history",
              "log_group_name" : "ec2-cloudwatch-logging-${var.name}",
              "log_stream_name" : "root-user-commands",
              "retention_in_days" : 60
            },
            {
              "file_path" : "/home/ec2-user/.bash_history",
              "log_group_name" : "ec2-cloudwatch-logging-${var.name}",
              "log_stream_name" : "ec2-user-commands",
              "retention_in_days" : 60
            },

            {
              "file_path" : "/var/log/secure",
              "log_group_name" : "ec2-cloudwatch-logging-${var.name}",
              "log_stream_name" : "logins",
              "retention_in_days" : 60
            },
            {
              "file_path" : "/home/ssm-user/.bash_history",
              "log_group_name" : "ec2-cloudwatch-logging-${var.name}",
              "log_stream_name" : "ssm-user-commands",
              "retention_in_days" : 60
            },
          ]
        }
      }
    },
    "metrics" : {
      "aggregation_dimensions" : [
        [
          "InstanceId"
        ]
      ],

      "metrics_collected" : {
        "collectd" : {
          "metrics_aggregation_interval" : 60
        },
        "cpu" : {
          "measurement" : [
            "cpu_usage_idle",
            "cpu_usage_iowait",
            "cpu_usage_user",
            "cpu_usage_system"
          ],
          "metrics_collection_interval" : 60,
          "resources" : [
            "*"
          ],
          "totalcpu" : false
        },
        "disk" : {
          "measurement" : [
            "used_percent",
            "inodes_free"
          ],
          "metrics_collection_interval" : 60,
          "resources" : [
            "*"
          ]
        },
        "diskio" : {
          "measurement" : [
            "io_time"
          ],
          "metrics_collection_interval" : 60,
          "resources" : [
            "*"
          ]
        },
        "mem" : {
          "measurement" : [
            "mem_used_percent"
          ],
          "metrics_collection_interval" : 60
        },
        "statsd" : {
          "metrics_aggregation_interval" : 60,
          "metrics_collection_interval" : 10,
          "service_address" : ":8125"
        },
        "swap" : {
          "measurement" : [
            "swap_used_percent"
          ],
          "metrics_collection_interval" : 60
        }
      }
    }
  })
}

resource "aws_cloudwatch_log_group" "ec2_cloudwatch_logs" {
  name              = "ec2-cloudwatch-logging-${var.name}"
  retention_in_days = 60
  kms_key_id        = aws_kms_key.ssmkey.arn
}

# Create cloudwatch log group for ssm
resource "aws_cloudwatch_log_group" "session_manager_log_group" {
  name_prefix       = "${var.cloudwatch_log_group_name}-"
  retention_in_days = var.cloudwatch_logs_retention
  kms_key_id        = aws_kms_key.ssmkey.arn

  tags = var.tags
}
