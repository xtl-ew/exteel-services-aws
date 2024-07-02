resource "aws_iam_role_policy" "lambda_cost_report_policy" {
  name   = "lambda_cost_report_policy"
  role   = aws_iam_role.lambda_cost_report_role.id
  
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:*:*:*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ce:GetCostAndUsage"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role" "lambda_cost_report_role" {
  name               = "lambda_cost_report_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "archive_file" "lambda_cost_report_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_cost_report"
  output_path = "${path.module}/lambda_cost_report.zip"
}

resource "aws_lambda_function" "lambda_cost_report" {
  filename         = data.archive_file.lambda_cost_report_zip.output_path
  source_code_hash = data.archive_file.lambda_cost_report_zip.output_base64sha256
  
  function_name    = "slack_cost_report"
  role             = aws_iam_role.lambda_cost_report_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.7"
  
  timeout          = 60
  
  environment {
    variables = {
      alias        = var.account_alias
      amount_limit = var.lambda_cost_report_amount_limit
      days         = "1"
      hook         = var.lambda_cost_report_slack_webhook_url
    }
  }
}

resource "aws_cloudwatch_event_rule" "trigger_lambda_cost_report_daily" {
  name                = "trigger_lambda_cost_report_daily"
  description         = "trigger_lambda_cost_report_daily"
  schedule_expression = "cron(0 1 ? * * *)"
}

resource "aws_cloudwatch_event_target" "trigger_lambda_cost_report_daily" {
  rule = aws_cloudwatch_event_rule.trigger_lambda_cost_report_daily.name
  arn  = aws_lambda_function.lambda_cost_report.arn
}

resource "aws_lambda_permission" "trigger_lambda_cost_report_daily_weird_permission" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_cost_report.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.trigger_lambda_cost_report_daily.arn
}