variable "dynamodb_table_name" {
  type        = string
  description = "DynamoDb Table name"
}

variable "sns_topic_name" {
  type        = string
  description = "Mail Tracker SNS Topic name"
}

variable "mail_tracker_lambda_iam_role_name" {
  type        = string
  description = "Mail Tracker Lambda IAM Role name"
}

variable "csv_report_lambda_iam_role_name" {
  type        = string
  description = "CSV Report Lambda IAM Role name"
}

variable "cloudwatch_iam_policy_name" {
  type        = string
  description = "Cloudwatch IAM Policy name"
}

variable "mail_tracker_dynamodb_iam_policy_name" {
  type        = string
  description = "Mail Tracker Dynamodb IAM Policy name"
}

variable "csv_report_dynamodb_iam_read_policy_name" {
  type        = string
  description = "CSV Report Dynamodb IAM Policy name"
}

variable "csv_report_s3_iam_policy_name" {
  type        = string
  description = "CSV Report S3 IAM Policy name"
}

variable "mail_tracker_lambda_function_name" {
  type        = string
  description = "Mail Tracker Lambda Function name"
}

variable "csv_report_lambda_function_name" {
  type        = string
  description = "CSV Report Lambda Function name"
}

variable "mail_tracker_lambda_function_file_path" {
  type        = string
  description = "Mail Tracker Lambda Function file path"
}

variable "csv_report_lambda_function_file_path" {
  type        = string
  description = "CSV Report Lambda Function file path"
}

variable "csv_report_s3_bucket_name" {
  type        = string
  description = "CSV Report S3 Bucket name"
}

variable "ses_configuration_set_name" {
  type        = string
  description = "SES Configuration set name"
}

variable "ses_event_destination_name" {
  type        = string
  description = "SES Event Destination name"
}

variable "ses_email_identity" {
  type        = string
  description = "SES Email Identity"
}

variable "ses_iam_user_name" {
  type        = string
  description = "SES IAM User Name"
}

variable "ses_access_iam_user_policy_name" {
  type        = string
  description = "SES IAM User Policy Name"
}
