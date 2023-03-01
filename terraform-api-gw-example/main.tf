# states what cloud provider we want to use.
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket = "tc-terraform-state-storage-s3"
    key = "api-terraform-courses"
    region = "us-east-1"
    dynamodb_table = "terraform-state-locking"
    encrypt = true
  }
}

# setting additional configs
provider "aws" {
  region = "us-east-1"
}



# this will zip my lambda functions and set the function handlers we want to run
provider "archive" {}

data "archive_file" "users-zip" {
  type = "zip"
  source_dir = "../lambdas"
  output_path = "../lambda-zips/users.zip"
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
          "logs:PutLogEvents"
        ],
        "Resource": "arn:aws:logs:*:*:*",
        "Effect": "Allow"
      },
      {
        "Action": [
          "dynamodb:BatchGetItem",
          "dynamodb:GetItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:BatchWriteItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem"
        ],
        "Resource": "arn:aws:dynamodb:us-east-1:294652976462:table/users",
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




# permission for api gateway to invoke lambda
resource "aws_lambda_permission" "fetchAllUsers-lambda-perm" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.fetchAllUsers_lambda.function_name}"
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_rest_api.tc-api-gateway.execution_arn}/*/*"
}



# lambda function
resource "aws_lambda_function" "fetchAllUsers_lambda" {
  function_name    = "fetchAllUsers"
  filename         = data.archive_file.users-zip.output_path
  source_code_hash = data.archive_file.users-zip.output_base64sha256
  role             = aws_iam_role.iam_for_lambda.arn 
  handler          = "users.users_getter_handler"
  runtime          =  "python3.9"
  depends_on       = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]

}


# permission for api gateway to invoke lambda
resource "aws_lambda_permission" "fetchUser-lambda-perm" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.fetchUser_lambda.function_name}"
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_rest_api.tc-api-gateway.execution_arn}/*/*"
}


# lambda function
resource "aws_lambda_function" "fetchUser_lambda" {
  function_name    = "fetchUser"
  filename         = data.archive_file.users-zip.output_path
  source_code_hash = data.archive_file.users-zip.output_base64sha256
  role             = aws_iam_role.iam_for_lambda.arn 
  handler          = "users.user_getter_handler"
  runtime          =  "python3.9"
  depends_on       = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]

}



# permission for api gateway to invoke lambda
resource "aws_lambda_permission" "createUser-lambda-perm" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.createUser_lambda.function_name}"
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_rest_api.tc-api-gateway.execution_arn}/*/*"
}


# lambda function
resource "aws_lambda_function" "createUser_lambda" {
  function_name    = "createUser"
  filename         = data.archive_file.users-zip.output_path
  source_code_hash = data.archive_file.users-zip.output_base64sha256
  role             = aws_iam_role.iam_for_lambda.arn 
  handler          = "users.create_user_handler"
  runtime          =  "python3.9"
  depends_on       = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]

}


# permission for api gateway to invoke lambda
resource "aws_lambda_permission" "updateUser-lambda-perm" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.updateUser_lambda.function_name}"
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_rest_api.tc-api-gateway.execution_arn}/*/*"
}


# lambda function
resource "aws_lambda_function" "updateUser_lambda" {
  function_name    = "updateUser"
  filename         = data.archive_file.users-zip.output_path
  source_code_hash = data.archive_file.users-zip.output_base64sha256
  role             = aws_iam_role.iam_for_lambda.arn 
  handler          = "users.update_user_handler"
  runtime          =  "python3.9"
  depends_on       = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]

}



# permission for api gateway to invoke lambda
resource "aws_lambda_permission" "deleteUser-lambda-perm" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.deleteUser_lambda.function_name}"
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_rest_api.tc-api-gateway.execution_arn}/*/*"
}


# lambda function
resource "aws_lambda_function" "deleteUser_lambda" {
  function_name    = "deleteUser"
  filename         = data.archive_file.users-zip.output_path
  source_code_hash = data.archive_file.users-zip.output_base64sha256
  role             = aws_iam_role.iam_for_lambda.arn 
  handler          = "users.delete_user_handler"
  runtime          =  "python3.9"
  depends_on       = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]

}