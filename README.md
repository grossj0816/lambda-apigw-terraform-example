# lambda-apigw-terraform-example
The baseline of this project was to use develop terraform code to provision infrastructure in AWS.  The goal was to write terraform code to provision a new API Gateway that when gets invoked via endpoint, it calls a lambda function also provisioned to return "Hello Juwan!".

<h3>Infrastructure Provisioned through Terraform:</h3>

<ul>
  <li>API Gateway</li>
  <li>API Endpoint Resource</li>
  <li>Lambda Function (Python)</li>
</ul>

<hr/>

<h3>What I am going to do next: </h3>
<br />
<ul>
  <li>Create a resource for building an EC2 instance <b>(DONE)</b></li>
  <li>Set up that instance to run a MySQL Server <b>(DONE)</b></li>
  <li>Create secrets for db access<b>(DONE)</b></li>
</ul>