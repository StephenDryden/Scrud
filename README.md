# Scrud

Scrud is a bare bones simple serverless app built using dynamodb, lambda and api gateway, deployed via Terraform.

This was heavily based off the serverless AWS tutorial found [here](https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-dynamo-db.html).

Simply export your AWS credentails for a user that has access to dynamodb, lambda, cloudwatch and api gateway and then run your normal terraform commands. Do not under any circumstance commit your AWS credentials.

```
export AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
export AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
export AWS_DEFAULT_REGION=us-west-2
terraform plan
```
