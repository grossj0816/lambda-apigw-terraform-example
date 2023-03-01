# lambda-apigw-terraform-example
The baseline of this project was to use develop terraform code to provision infrastructure in AWS.  The goal was to write terraform code to provision a new API Gateway that when gets invoked via endpoint, it calls a lambda function also provisioned to return "Hello Juwan!".

<h3>Infrastructure Provisioned through Terraform:</h3>

<ul>
  <li>API Gateway</li>
  <li>Lambda Functions (Python)</li>
  <li>DynamoDB table for CRUD Operations on user table</li>
</ul>
