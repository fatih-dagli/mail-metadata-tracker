# DynamoDb related variables
dynamodb_table_name = "mail-tracker-dynamodb-table"

# SNS Topic related variables
sns_topic_name = "mail-tracker-sns-topic"

# S3 Bucket related variables
csv_report_s3_bucket_name = "csv-report-s3-bucket"

# IAM User related variables
ses_iam_user_name = "mail-tracker-iam-ses-user"

# IAM Role related variables
mail_tracker_lambda_iam_role_name = "mail-tracker-lambda-role"
csv_report_lambda_iam_role_name   = "csv-report-lambda-role"

# IAM Policy related variables
csv_report_s3_iam_policy_name            = "csv-report-lambda-s3-policy"
cloudwatch_iam_policy_name               = "cloudwatch-policy"
mail_tracker_dynamodb_iam_policy_name    = "mail-tracker-lambda-dynamodb-policy"
csv_report_dynamodb_iam_read_policy_name = "csv-report-lambda-dynamodb-policy"

# Lambda Function related variables
mail_tracker_lambda_function_name      = "mail-tracker-lambda-function"
csv_report_lambda_function_name        = "csv-report-lambda-function"
mail_tracker_lambda_function_file_path = "C:\\Users\\<username>\\Desktop\\mail_tracker_lambda_function.zip"
csv_report_lambda_function_file_path   = "C:\\Users\\<username>\\Desktop\\csv_report_lambda_function.zip"

# AWS SES realated variables
ses_configuration_set_name      = "mail-tracker-configuration-set"
ses_event_destination_name      = "mail-tracker-event-destination"
ses_email_identity              = "<email_address>"
ses_access_iam_user_policy_name = "mail-tracker-ses-iam-user-policy"
