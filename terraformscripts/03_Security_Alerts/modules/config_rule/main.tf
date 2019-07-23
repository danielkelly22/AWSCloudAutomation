###################################################################################################################
# Filename   : main.tf
# Summary    : Config module used by Onica to create an AWS Foundation
# Author     : Sami Meekhaeal Davis (Onica)
# Notes      : Used to create basic config rules to monitor the accounts
###################################################################################################################

terraform {
    required_version = ">= 0.10.3" # introduction of Local Values configuration language feature
}




###################################################################################################################
# Config Rules
###################################################################################################################
resource "aws_config_config_rule" "EC2_INSTANCE_MANAGED_BY_SSM" {
    name =  "${format("%s-%s", upper(var.prefix_name), "EC2_INSTANCE_MANAGED_BY_SSM")}"

    source {
        owner             = "AWS"
        source_identifier = "EC2_INSTANCE_MANAGED_BY_SSM"
    }

    depends_on = ["aws_config_configuration_recorder.config_recorder"]
}
resource "aws_config_config_rule" "EC2_VOLUME_INUSE_CHECK" {
    name =  "${format("%s-%s", upper(var.prefix_name), "EC2_VOLUME_INUSE_CHECK")}"

    source {
        owner             = "AWS"
        source_identifier = "EC2_VOLUME_INUSE_CHECK"
    }

    depends_on = ["aws_config_configuration_recorder.config_recorder"]
}

resource "aws_config_config_rule" "CLOUD_TRAIL_ENABLED" {
    name =  "${format("%s-%s", upper(var.prefix_name), "CLOUD_TRAIL_ENABLED")}"

    source {
        owner             = "AWS"
        source_identifier = "CLOUD_TRAIL_ENABLED"
    }

    depends_on = ["aws_config_configuration_recorder.config_recorder"]
}

resource "aws_config_config_rule" "REQUIRED_TAGS" {
    name =  "${format("%s-%s", upper(var.prefix_name), "REQUIRED_TAGS")}"

    source {
        owner             = "AWS"
        source_identifier = "REQUIRED_TAGS"
    }
  input_parameters = "{\"tag1Key\": \"Name\",\"tag2Key\": \"ApplicationOwner\",\"tag3Key\": \"Environment\",\"tag4Key\": \"AssetRole\",\"tag5Key\": \"CostCenter\"}"

    depends_on = ["aws_config_configuration_recorder.config_recorder"]
}

resource "aws_config_config_rule" "VPC_FLOW_LOGS_ENABLED" {
    name =  "${format("%s-%s", upper(var.prefix_name), "VPC_FLOW_LOGS_ENABLED")}"

    source {
        owner             = "AWS"
        source_identifier = "VPC_FLOW_LOGS_ENABLED"
    }

    depends_on = ["aws_config_configuration_recorder.config_recorder"]
}

resource "aws_config_config_rule" "ROOT_ACCOUNT_MFA_ENABLED" {
    name =  "${format("%s-%s", upper(var.prefix_name), "ROOT_ACCOUNT_MFA_ENABLED")}"

    source {
        owner             = "AWS"
        source_identifier = "ROOT_ACCOUNT_MFA_ENABLED"
    }

    depends_on = ["aws_config_configuration_recorder.config_recorder"]
}

resource "aws_config_config_rule" "S3_BUCKET_PUBLIC_READ_PROHIBITED" {
    name =  "${format("%s-%s", upper(var.prefix_name), "S3_BUCKET_PUBLIC_READ_PROHIBITED")}"

    source {
        owner             = "AWS"
        source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
    }

    depends_on = ["aws_config_configuration_recorder.config_recorder"]
}

resource "aws_config_config_rule" "S3_BUCKET_PUBLIC_WRITE_PROHIBITED" {
    name =  "${format("%s-%s", upper(var.prefix_name), "S3_BUCKET_PUBLIC_WRITE_PROHIBITED")}"

    source {
        owner             = "AWS"
        source_identifier = "S3_BUCKET_PUBLIC_WRITE_PROHIBITED"
    }

    depends_on = ["aws_config_configuration_recorder.config_recorder"]
}


###################################################################################################################
# Config Recorder
###################################################################################################################
resource "aws_config_configuration_recorder" "config_recorder" {
    name     = "${var.prefix_name}-config-recorder"
    role_arn = "${aws_iam_role.role.arn}"

    recording_group {
        all_supported = true
        include_global_resource_types = true
    }
}

resource "aws_config_configuration_recorder_status" "config_recorder_status" {
    name       = "${aws_config_configuration_recorder.config_recorder.name}"
    is_enabled = true
    depends_on = ["aws_config_delivery_channel.config_delivery_channel"]
}

resource "random_string" "random_string" {
    length = 16
    special = false
    upper = false
}

resource "aws_s3_bucket" "config_bucket" {
    bucket = "awsconfig-bucket-${random_string.random_string.result}"

    tags = "${merge(map("Name", format("%s-%s", "awsconfig-bucket", random_string.random_string.result)),var.tags)}"

    policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [{
        "Sid": "AWSConfigBucketPermissionsCheck",
        "Effect": "Allow",
        "Principal": {
            "Service": [
                "config.amazonaws.com"
            ]
        },
        "Action": "s3:GetBucketAcl",
        "Resource": "arn:aws:s3:::awsconfig-bucket-${random_string.random_string.result}"
    },
    {
        "Sid": " AWSConfigBucketDelivery",
        "Effect": "Allow",
        "Principal": {
            "Service": [
                "config.amazonaws.com"    
            ]
        },
        "Action": "s3:PutObject",
        "Resource": "arn:aws:s3:::awsconfig-bucket-${random_string.random_string.result}/*",
        "Condition": { 
            "StringEquals": { 
            "s3:x-amz-acl": "bucket-owner-full-control" 
            }
        }
    }]
} 
POLICY

}

resource "aws_config_delivery_channel" "config_delivery_channel" {
    name           = "config_delivery_channel"
    s3_bucket_name = "${aws_s3_bucket.config_bucket.bucket}"
}

resource "aws_iam_role" "role" {
    name = "${var.prefix_name}-awsconfig-role"

    assume_role_policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "config.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
POLICY
}

resource "aws_iam_role_policy" "policy" {
    name = "${var.prefix_name}-awsconfig-policy"
    role = "${aws_iam_role.role.id}"

    policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "config:Put*",
            "Effect": "Allow",
            "Resource": "*"

        },
         {
            "Action": "config:BatchGetResourceConfig",
            "Effect": "Allow",
            "Resource": "*"

        },
        {
            "Effect": "Allow",
            "Action": ["s3:PutObject"],
            "Resource": ["arn:aws:s3:::${aws_s3_bucket.config_bucket.bucket}/*"]
        },
        {
            "Effect": "Allow",
            "Action": ["s3:GetBucketAcl"],
            "Resource": "arn:aws:s3:::${aws_s3_bucket.config_bucket.bucket}"
        }
    ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "read_only" {
    role       = "${aws_iam_role.role.name}"
    policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

###################################################################################################################
# Email Notification
###################################################################################################################
resource "aws_cloudwatch_event_rule" "console" {
    name        = "aws_config_compliance_rule"
    description = "Alert on out of AWS Config compliance alerts"

    event_pattern = <<PATTERN
{
    "source": [
        "aws.config"
    ],
    "detail-type": [
        "Config Rules Compliance Change"
    ]
}
PATTERN
}

resource "aws_cloudwatch_event_target" "cloudwatch_event_target" {
    rule      = "${aws_cloudwatch_event_rule.console.name}"
    target_id = "SendToSNS"
    arn       = "${aws_sns_topic.aws_config_alerts.arn}"
}

resource "aws_sns_topic" "aws_config_alerts" {
    name = "aws_config_alerts"
}

resource "aws_sns_topic_policy" "sns_topic_policy" {
    arn    = "${aws_sns_topic.aws_config_alerts.arn}"
    policy = "${data.aws_iam_policy_document.sns_topic_policy_doc.json}"
}

data "aws_iam_policy_document" "sns_topic_policy_doc" {
    statement {
        effect  = "Allow"
        actions = ["SNS:Publish"]

        principals {
            type        = "Service"
            identifiers = ["events.amazonaws.com"]
        }

        resources = ["${aws_sns_topic.aws_config_alerts.arn}"]
    }
    }