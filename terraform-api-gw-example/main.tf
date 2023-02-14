# states what cloud provider we want to use.
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  # backend "s3" {
  #   bucket = "tc-terraform-state-locking"
  #   key = "tc/s4/terraform.tfstate"
  #   region = "us-east-1"
  #   dynamodb_table = "terraform-state-locking"
  #   encrypt = true
  # }
}

# setting additional configs
provider "aws" {
  region = "us-east-1"
}


# this will zip the file my lambdas are in.
provider "archive" {}
data "archive_file" "zip" {
  type = "zip"
  source_file = "welcome.py"
  output_path = "welcome.zip"
}


# create iam role for lambda
resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_hello_lambda"
  # this is a trust policy. It dictates that the role being created is of aws lambda
  # and to assume that role.
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
}
  EOF
}

# create iam policy for lambda. iam policy dictates the actions that the lambda is allowed to do.
resource "aws_iam_policy" "iam_policy_for_lambda" {
  
  name        = "aws_iam_policy_for_terraform_aws_lambda_role"
  path        = "/"
  description = "AWS IAM Policy for managing aws lambda role"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "iam:PassRole"
        ],
        "Resource": "arn:aws:logs:*:*:*",
        "Effect": "Allow"
      }
    ]
}
  EOF
}


# attach iam policy to iam role
resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.iam_policy_for_lambda.arn 
}

# permission for api gateway to invoke welcome lambda
resource "aws_lambda_permission" "welcome-lambda-perm" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.welcome-lambda.function_name}"
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_rest_api.tc-api-gateway.execution_arn}/*/*"
}


# lambda function
resource "aws_lambda_function" "welcome-lambda" {
  function_name    = "welcome"
  filename         = data.archive_file.zip.output_path
  source_code_hash = data.archive_file.zip.output_base64sha256
  role             = aws_iam_role.iam_for_lambda.arn 
  handler          = "welcome.welcome_handler"
  runtime          =  "python3.9"
  depends_on       = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]
}




# permission for api gateway to invoke name lambda
resource "aws_lambda_permission" "name-lambda-perm" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.name_lambda.function_name}"
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_rest_api.tc-api-gateway.execution_arn}/*/*"
}



# lambda function
resource "aws_lambda_function" "name_lambda" {
  function_name    = "name"
  filename         = data.archive_file.zip.output_path
  source_code_hash = data.archive_file.zip.output_base64sha256
  role             = aws_iam_role.iam_for_lambda.arn 
  handler          = "welcome.name_handler"
  runtime          =  "python3.9"
  depends_on       = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]
}








