import os
import boto3
import csv
import json
from datetime import datetime, timedelta

# Get table_name and s3_bucket values from environment variables
table_name = os.environ['TABLE_NAME']
s3_bucket = os.environ['S3_BUCKET_NAME']

# Get date, hours and minutes and generate the report name
current_datetime = datetime.now().strftime('%Y-%m-%d_%H-%M')  # Ex: 2023-10-12_14-30
s3_key = f'email_reports/email_report_{current_datetime}.csv'  # S3 Path

dynamodb = boto3.resource('dynamodb')
s3_client = boto3.client('s3')
table = dynamodb.Table(table_name)

def lambda_handler(event, context):
    # Calculate the last week
    end_date = datetime.now()
    start_date = end_date - timedelta(days=7)

    # Get last week's metadatas from DynamoDB
    response = table.scan(
        FilterExpression='#timestamp between :start_date and :end_date',
        ExpressionAttributeNames={'#timestamp': 'timestamp'},
        ExpressionAttributeValues={':start_date': start_date.isoformat(), ':end_date': end_date.isoformat()}
    )

    # Generate the CSV file
    csv_data = response['Items']
    csv_filename = '/tmp/email_report.csv'  # Temporary area of Lambda
    with open(csv_filename, 'w', newline='') as csvfile:
        fieldnames = csv_data[0].keys() if csv_data else []
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        for item in csv_data:
            writer.writerow(item)

    # Upload the CSV file to s3 bucket
    s3_client.upload_file(csv_filename, s3_bucket, s3_key)

    # Return success if upload is finished without problem
    return {
        'statusCode': 200,
        'body': json.dumps('Success')
    }
