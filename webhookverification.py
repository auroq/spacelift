import hmac
import hashlib
import os


def lambda_handler(event, context):
    print('Lambda running')
    print('--- event ---')
    print(event)
    print('--- context ---')
    print(context)

    header_signature_256 = event['headers']['x-signature-256']
    body = event['body']
    secret = os.getenv('SPACELIFT_WEBHOOK_SECRET')
    print('--- header ---')
    print(header_signature_256)
    print('--- body ---')
    print(body)
    print('--- secret ---')
    print(secret)

    signature_bytes = bytes(secret, 'utf-8')
    digest = hmac.new(key=signature_bytes, msg=body.encode('utf-8'), digestmod=hashlib.sha256)
    calculated_signature = digest.hexdigest()

    if calculated_signature != header_signature_256:
        return {'StatusCode': 403}

    return {'StatusCode': 200}
