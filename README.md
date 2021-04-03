# Spacelift Webhook

This terraform module is an all-in-one solution for setting up [Spacelift webhooks][spacelift-webhooks] on a given stack, receiving them, and persisting the data.

The architecture consists of a webhook integration created in Spacelift which calls [AWS API Gateway][aws-api-gateway].
The API Gateway is a proxy to [AWS Lambda][aws-lambda] without any authorizor.
Lambda handles validation by parsing the `x-signature-256` header from the request and comparing against it against the body of the request. See [Spacelift documentation][spacelift-validation] for more information.
If validation is successful, the lambda persists the event to a [DynamoDB][aws-dynamodb] table.

This module also handles creation of the necessary AWS roles and policies as well as the webhook secret used for validating requests between Spacelift and AWS.

See the [examples directory][examples] for usage examples of this module.
You can also find each each variable for the module documented in the [variables.tf][variables] file.


[examples]: ./examples
[variables]: ./variables.tf

[aws-lambda]: https://aws.amazon.com/lambda/
[aws-dynamodb]: https://aws.amazon.com/dynamodb/
[aws-api-gateway]: https://aws.amazon.com/api-gateway/

[spacelift]: https://spacelift.io
[spacelift-webhooks]: https://docs.spacelift.io/integrations/webhooks
[spacelift-validation]: https://docs.spacelift.io/integrations/webhooks#validating-payload
