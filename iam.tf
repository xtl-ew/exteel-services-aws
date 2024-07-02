resource "aws_key_pair" "admin" {
  key_name   = var.ec2_key_pair_name
  public_key = var.ec2_key_pair_pub
}

data "aws_iam_policy_document" "assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "host-policy-doc" {
  statement {
    actions = [
      "ec2:DetachVolume",
      "ec2:AttachVolume",
      "ec2:DescribeVolumeStatus",
      "ec2:DescribeVolumes",
      "ec2:DescribeVolumeAttribute"
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_role" "host" {
  name               = "host"
  assume_role_policy = data.aws_iam_policy_document.assume-role-policy.json
}
resource "aws_iam_role_policy_attachment" "host-ssm" {
  role       = aws_iam_role.host.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
resource "aws_iam_instance_profile" "host-profile" {
  name  = "host-profile"
  role = aws_iam_role.host.name
}
resource "aws_iam_role_policy" "host-policy" {
  name   = "host-policy"
  role   = aws_iam_role.host.id
  policy = data.aws_iam_policy_document.host-policy-doc.json
}

# Management host policy and role
data "aws_iam_policy_document" "mgmt-policy-doc" {
  statement {
    actions = [
      "ec2:Describe*",
      "elasticloadbalancing:Describe*",
      "cloudwatch:ListMetrics",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:Describe*",
      "autoscaling:Describe*",
      "route53:*",
      "route53domains:*",
      "cloudfront:ListDistributions",
      "elasticbeanstalk:DescribeEnvironments",
      "elasticfilesystem:DescribeMountTargets",
      "elasticfilesystem:DescribeFileSystems",
      "s3:*",
      "sns:ListTopics",
      "sns:ListSubscriptionsByTopic",
    ]

    resources = [
      "*",
    ]
  }
}
resource "aws_iam_role" "mgmt" {
  name               = "mgmt"
  assume_role_policy = data.aws_iam_policy_document.assume-role-policy.json
}
resource "aws_iam_instance_profile" "mgmt-profile" {
  name  = "mgmt-profile"
  role = aws_iam_role.mgmt.name
}
resource "aws_iam_role_policy" "mgmt-policy" {
  name   = "mgmt-policy"
  role   = aws_iam_role.mgmt.id
  policy = data.aws_iam_policy_document.mgmt-policy-doc.json
}
