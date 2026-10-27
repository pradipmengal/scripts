# SNS Topic for ASG events
resource "aws_sns_topic" "asg_events" {
  name = "nat-asg-events"
}

# SNS Topic policy
resource "aws_sns_topic_policy" "asg_events_policy" {
  arn = aws_sns_topic.asg_events.arn
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "autoscaling.amazonaws.com" },
      Action    = "SNS:Publish",
      Resource  = aws_sns_topic.asg_events.arn
    }]
  })
}

# Lifecycle hooks (launch + terminate)
resource "aws_autoscaling_lifecycle_hook" "on_launch" {
  for_each                = data.terraform_remote_state.nat.outputs.nat_asg_names
  name                    = "attach-eni-${each.key}"
  autoscaling_group_name  = each.value
  lifecycle_transition    = "autoscaling:EC2_INSTANCE_LAUNCHING"
  default_result          = "CONTINUE"
  heartbeat_timeout       = 300
  notification_target_arn = aws_sns_topic.asg_events.arn
  role_arn                = aws_iam_role.asg_lifecycle_role.arn
}

resource "aws_autoscaling_lifecycle_hook" "on_terminate" {
  for_each                = data.terraform_remote_state.nat.outputs.nat_asg_names
  name                    = "detach-eni-${each.key}"
  autoscaling_group_name  = each.value
  lifecycle_transition    = "autoscaling:EC2_INSTANCE_TERMINATING"
  default_result          = "CONTINUE"
  heartbeat_timeout       = 300
  notification_target_arn = aws_sns_topic.asg_events.arn
  role_arn                = aws_iam_role.asg_lifecycle_role.arn
}

# Lambda role + policy
resource "aws_iam_role" "lambda_role" {
  name = "nat-eni-reattach-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "lambda.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "lambda_inline" {
  name = "nat-eni-reattach-inline"
  role = aws_iam_role.lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:AttachNetworkInterface",
          "ec2:DetachNetworkInterface",
          "ec2:Describe*",
          "ec2:ModifyInstanceAttribute"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

# Package Lambda code
data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "lambda.zip"

  source {
    filename = "index.py"
    content  = <<EOT
import boto3, json

ec2 = boto3.client("ec2")

def find_eni_for_az(az):
    nis = ec2.describe_network_interfaces(Filters=[{"Name":"tag:Name","Values":[f"nat-eni-{az}"]}])["NetworkInterfaces"]
    return nis[0] if nis else None

def handler(event, context):
    print("event:", json.dumps(event))
    for rec in event.get("Records", []):
        msg = json.loads(rec.get("Sns", {}).get("Message", "{}")) if "Sns" in rec else json.loads(rec.get("body", "{}"))
        detail = msg.get("detail", {}) if "detail" in msg else msg
        asg = detail.get("AutoScalingGroupName") or msg.get("AutoScalingGroupName")
        lifecycle = detail.get("LifecycleTransition") or msg.get("LifecycleTransition")
        instance_id = detail.get("EC2InstanceId") or msg.get("EC2InstanceId")
        if not instance_id:
            continue
        inst = ec2.describe_instances(InstanceIds=[instance_id])["Reservations"][0]["Instances"][0]
        az = inst["Placement"]["AvailabilityZone"]
        eni = find_eni_for_az(az)
        if not eni:
            print("No ENI found for", az)
            continue
        eni_id = eni["NetworkInterfaceId"]
        try:
            ec2.modify_instance_attribute(InstanceId=instance_id, SourceDestCheck={"Value": False})
        except Exception as e:
            print("modify_instance_attribute err", e)
        if "LAUNCHING" in lifecycle:
            attach = eni.get("Attachment")
            if attach:
                try:
                    ec2.detach_network_interface(AttachmentId=attach["AttachmentId"], Force=True)
                except Exception as e:
                    print("detach err", e)
            try:
                ec2.attach_network_interface(NetworkInterfaceId=eni_id, InstanceId=instance_id, DeviceIndex=1)
                print("attached", eni_id, "to", instance_id)
            except Exception as e:
                print("attach err", e)
        elif "TERMINATING" in lifecycle:
            for iface in inst.get("NetworkInterfaces", []):
                if iface["NetworkInterfaceId"] == eni_id and "Attachment" in iface:
                    try:
                        ec2.detach_network_interface(AttachmentId=iface["Attachment"]["AttachmentId"], Force=True)
                    except Exception as e:
                        print("detach-on-term err", e)
    return {"ok": True}
EOT

  }
}

# Lambda function
resource "aws_lambda_function" "nat_eni_reattach" {
  function_name = "nat-eni-reattach"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "python3.11"
  filename      = data.archive_file.lambda_zip.output_path
  timeout       = var.lambda_timeout
}

# Lambda permissions & subscription
resource "aws_lambda_permission" "sns_invoke" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.nat_eni_reattach.arn
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.asg_events.arn
}

resource "aws_sns_topic_subscription" "lambda_sub" {
  topic_arn = aws_sns_topic.asg_events.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.nat_eni_reattach.arn
}

# IAM role for ASG lifecycle hooks
resource "aws_iam_role" "asg_lifecycle_role" {
  name = "asg-lifecycle-hook-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "autoscaling.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

# Role policy for ASG lifecycle
resource "aws_iam_role_policy" "asg_lifecycle_policy" {
  name = "asg-lifecycle-sns-policy"
  role = aws_iam_role.asg_lifecycle_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = ["sns:Publish"],
      Resource = aws_sns_topic.asg_events.arn
    }]
  })
}

