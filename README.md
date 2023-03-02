# lambda-apigw-terraform-example
The baseline of this project was to use write terraform code to provision infrastructure in AWS. My goal was to write terraform code to provision a new API Gateway, a few lambda functions doing individual CRUD operations & a backend DynamoDB NoSQL table that the lambda functions are doing those CRUD Operations on.  This project took alot of time to understand how to spin up these different services, but took alot of time as well to understand how to connect these three services so they can work with each other. 

<h3>Infrastructure Provisioned through Terraform:</h3>

<ul>
  <li>API Gateway</li>
  <li>Lambda Functions (Python)</li>
  <li>DynamoDB table for CRUD Operations on user table</li>
</ul>

<hr/>

<h4>Online Sources that helped me in the development of this project: </h4>

<ul>
  <li><a href="https://boto3.amazonaws.com/v1/documentation/api/latest/guide/dynamodb.html">Boto3 Docs</a></li>
  <li><a href="https://aws-lambda-for-python-developers.readthedocs.io/en/latest/02_event_and_context/#event">AWS Lambda for Python Developers</a></li>
</ul>
