import hashlib
import hmac
import json
import os

import boto3


dynamodb_table_name = os.getenv('DYNAMODB_TABLE_NAME')
spacelift_webhook_secret = os.getenv('SPACELIFT_WEBHOOK_SECRET')


def lambda_handler(event, context):
    print('Lambda running')
    try:
        header_signature_256, webhook_body = parse_request(event)
    except KeyError:
        err = 'Missing body or x-signature-256 header'
        print(err)
        return response(400, err)

    if not verify_signature(header_signature_256, webhook_body):
        err = 'calculated signature did not match header'
        print(err)
        return response(403, err)

    write_to_dynamodb(webhook_body)

    return response(200)


def parse_request(event):
    print('Parsing request')
    header_prefix = 'sha256='
    header_signature_256 = event['headers']['x-signature-256']
    if header_signature_256.startswith(header_prefix):
        header_signature_256 = header_signature_256[len(header_prefix):]

    webhook_body = event['body'].encode('utf-8')
    return header_signature_256, webhook_body


def verify_signature(header_signature_256, webhook_body):
    print('Verifying signature')
    signature_bytes = bytes(spacelift_webhook_secret, 'utf-8')
    digest = hmac.new(key=signature_bytes, msg=webhook_body, digestmod=hashlib.sha256)
    return digest.hexdigest() == header_signature_256


def write_to_dynamodb(webhook_body):
    print('Writing webhook body to DynamoDB')
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(dynamodb_table_name)
    item = json.loads(webhook_body)
    item['runId'] = item['run']['id']  # Append run.id to the root of the object so that it can be used as the hash key
    table.put_item(Item=item)
    print('Webhook body successfully written to DynamoDB!')


def response(code, msg=None):
    response_obj = {'statusCode': code}
    if msg:
        response_obj['body'] = json.dumps({'msg': msg})
    return response_obj
