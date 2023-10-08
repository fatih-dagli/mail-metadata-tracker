# Define aws provider
provider "aws" {
  region = "us-east-1"
}

#Store terraform state in the S3 bucket
terraform {
  backend "s3" {
    bucket     = "tracker-terraform-state-bucket"
    key        = "terraform.tfstate"
    region     = "us-east-1"
    encrypt    = true
    kms_key_id = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" # Server-side encryption with AWS Key Management Service keys (SSE-KMS)
  }
}

#Create DynamoDb Table
resource "aws_dynamodb_table" "mail_tracker_table" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST" # Pay_per_request or provisioned capacity
  hash_key     = "messageId"
  attribute {
    name = "messageId"
    type = "S" # String type
  }
}

#Create SNS Topic
resource "aws_sns_topic" "mail_tracker_sns_topic" {
  name = var.sns_topic_name
}

# Create S3 Bucket for CSV Report
resource "aws_s3_bucket" "csv-report-s3-bucket" {
  bucket = var.csv_report_s3_bucket_name
  # to destroy s3 bucket and s3 bucket contents while destroying
  force_destroy = true
}

# Create IAM Role for Mail Tracker Lambda
resource "aws_iam_role" "mail_tracker_lambda_role" {
  name = var.mail_tracker_lambda_iam_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Create IAM Role for CSV Report Lambda
resource "aws_iam_role" "csv_report_lambda_role" {
  name = var.csv_report_lambda_iam_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Create IAM policy to access Cloudwatch from the Lambda
resource "aws_iam_policy" "cloudwatch_iam_policy" {
  name = var.cloudwatch_iam_policy_name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

# Attach the cloudwatch_iam_policy to the Mail Tracker Lambda Role
resource "aws_iam_role_policy_attachment" "mail_tracker_lambda_policy_attachment" {
  policy_arn = aws_iam_policy.cloudwatch_iam_policy.arn
  role       = aws_iam_role.mail_tracker_lambda_role.name
}

# Create IAM policy to write to DynamoDb from the Lambda for Mail Tracker
resource "aws_iam_policy" "mail_tracker_dynamodb_iam_policy" {
  name        = var.mail_tracker_dynamodb_iam_policy_name
  description = "Policy for writing to DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:BatchWriteItem"
        ],
        Effect   = "Allow",
        Resource = aws_dynamodb_table.mail_tracker_table.arn
      }
    ]
  })
}

# Attach the mail_tracker_dynamodb_iam_policy to the Lambda Role for Mail Tracker
resource "aws_iam_role_policy_attachment" "mail_tracker_dynamodb_lambda_policy_attachment" {
  policy_arn = aws_iam_policy.mail_tracker_dynamodb_iam_policy.arn
  role       = aws_iam_role.mail_tracker_lambda_role.name
}

# Create IAM policy to read data in DynamoDb from the Lambda for CSV Report
resource "aws_iam_policy" "csv_report_dynamodb_iam_read_policy" {
  name = var.csv_report_dynamodb_iam_read_policy_name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "dynamodb:GetItem",
          "dynamodb:Scan",
          "dynamodb:Query"
        ],
        Effect   = "Allow",
        Resource = aws_dynamodb_table.mail_tracker_table.arn
      }
    ]
  })
}

# Attach the cloudwatch_iam_policy to the CSV Report Lambda Role
resource "aws_iam_role_policy_attachment" "csv_report_cloudwatch_lambda_policy_attachment" {
  policy_arn = aws_iam_policy.cloudwatch_iam_policy.arn
  role       = aws_iam_role.csv_report_lambda_role.name
}

# Attach the dynamodb policy to the CSV Report Lambda Role
resource "aws_iam_role_policy_attachment" "csv_report_dynamodb_read_policy_attachment" {
  policy_arn = aws_iam_policy.csv_report_dynamodb_iam_read_policy.arn
  role       = aws_iam_role.csv_report_lambda_role.name
}

# Create IAM policy to write data to S3 from the Lambda for CSV Report
resource "aws_iam_policy" "csv_report_lambda_s3_policy" {
  name = var.csv_report_s3_iam_policy_name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["s3:PutObject", "s3:PutObjectAcl"],
        Resource = "arn:aws:s3:::${var.csv_report_s3_bucket_name}/*"
      }
    ]
  })
}

#  Attach the s3 policy to the Lambda Role for CSV Report
resource "aws_iam_role_policy_attachment" "csv_report_lambda_s3_policy_attachment" {
  policy_arn = aws_iam_policy.csv_report_lambda_s3_policy.arn
  role       = aws_iam_role.csv_report_lambda_role.name
}

# Create Lambda Function for mail tracker
resource "aws_lambda_function" "mail_tracker_lambda_function" {
  function_name = var.mail_tracker_lambda_function_name
  filename      = var.mail_tracker_lambda_function_file_path
  role          = aws_iam_role.mail_tracker_lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.mail_tracker_table.name
    }
  }
}

# Create Lambda Function for CSV report
resource "aws_lambda_function" "csv_report_lambda_function" {
  function_name = var.csv_report_lambda_function_name
  filename      = var.csv_report_lambda_function_file_path
  role          = aws_iam_role.csv_report_lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"

  environment {
    variables = {
      TABLE_NAME     = aws_dynamodb_table.mail_tracker_table.name
      S3_BUCKET_NAME = "${var.csv_report_s3_bucket_name}"
    }
  }
}

# Create Cloudwatch Event Rule for CSV report schedule
resource "aws_cloudwatch_event_rule" "weekly_schedule" {
  name                = "WeeklyScheduleRule"
  description         = "Weekly schedule rule for triggering Lambda function"
  schedule_expression = "cron(0 7 ? * MON *)" # EVERY MONDAY 7 AM UTC
}

# Add Lambda target to Cloudwatch event rule for CSV report schedule
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.weekly_schedule.name
  target_id = "WeeklyLambdaTarget"
  arn       = aws_lambda_function.csv_report_lambda_function.arn
}

# Add SNS trigger to Mail Tracker Lambda
resource "aws_lambda_permission" "sns_trigger" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.mail_tracker_lambda_function.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.mail_tracker_sns_topic.arn
}

# Add SNS subscription using lambda arn for Mail tracker
resource "aws_sns_topic_subscription" "lambda_subscription" {
  topic_arn = aws_sns_topic.mail_tracker_sns_topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.mail_tracker_lambda_function.arn
}

# Create configuration set in AWS SES
resource "aws_ses_configuration_set" "mail_configuration_set" {
  name = var.ses_configuration_set_name
}

# Create Event Destination and assign to configuration set in AWS SES 
resource "aws_ses_event_destination" "mail_event_destination" {
  configuration_set_name = aws_ses_configuration_set.mail_configuration_set.name
  name                   = var.ses_event_destination_name
  enabled                = true
  matching_types         = ["delivery", "send"]
  sns_destination {
    topic_arn = aws_sns_topic.mail_tracker_sns_topic.arn
  }
}

# Create Email Identity for AWS SES
resource "aws_sesv2_email_identity" "verified_email" {
  email_identity         = var.ses_email_identity
  configuration_set_name = aws_ses_configuration_set.mail_configuration_set.name
}

# Create AWS IAM User
resource "aws_iam_user" "ses_smtp_user" {
  name = var.ses_iam_user_name
}

# Create IAM user policy
resource "aws_iam_user_policy" "ses_smtp_user_policy" {
  name = var.ses_access_iam_user_policy_name
  user = aws_iam_user.ses_smtp_user.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "ses:SendRawEmail",
        Resource = "*"
      }
    ]
  })
}

# Create IAM user Access / Secret Key
resource "aws_iam_access_key" "aws_iam_access_secret_key" {
  user = aws_iam_user.ses_smtp_user.name
}
