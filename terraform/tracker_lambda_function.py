import json
import boto3
import os
from botocore.exceptions import ClientError

dynamodb = boto3.resource('dynamodb')

def lambda_handler(event, context):
    try:
        # Get table name from the environment variable
        table_name = os.environ['TABLE_NAME']

        # Create dynamodb table
        table = dynamodb.Table(table_name)
        
        # Get SES Event data
        sns_message = json.loads(event['Records'][0]['Sns']['Message'])
        ses_notification_type = sns_message.get('eventType', None)
        
        # Write only Delivery Event types
        if ses_notification_type == 'Delivery':
            # Primary_key name: messageId
            message_id = sns_message['mail']['messageId']
            
            # Get all mail metadata
            mail_metadata = sns_message['mail']
            mail_metadata['messageId'] = message_id  # adding messageId 

            # Save the metadatas to DynamoDB
            response = table.put_item(Item=mail_metadata)
            print("Metadatas of email saved successfully to DynamoDB", json.dumps(mail_metadata))
        
        return {
            'statusCode': 200,
            'body': json.dumps('Success')
        }

    # KeyError: If any necessary key is missing, return like below
    except KeyError as e:
        print("Event data is missing or incorrect: ", str(e))
        return {
            'statusCode': 500,
            'body': json.dumps('Internal Server Error')
        }
    
    # ClientError: If we have any boto3 errors like connection to dynamodb, return like below
    except ClientError as e:
        print("Mail metadata could not be saved:", e)
        return {
            'statusCode': 500,
            'body': json.dumps('Internal Server Error')
        }