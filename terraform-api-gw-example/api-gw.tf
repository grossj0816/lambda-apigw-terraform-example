resource "aws_api_gateway_rest_api" "tc-api-gateway" {
  name = "Terraform Courses API"
  description = "AWS Rest API Example with Terraform"
  endpoint_configuration {
    types = [ "REGIONAL" ]
  }
}

# ENDPOINT PATH: /terraform-course
resource "aws_api_gateway_resource" "terraform-course" {
  rest_api_id = aws_api_gateway_rest_api.tc-api-gateway.id
  parent_id   = aws_api_gateway_rest_api.tc-api-gateway.root_resource_id
  path_part   = "terraform-course"   
}

# ENDPOINT PATH: /terraform-course/hello
resource "aws_api_gateway_resource" "hello" {
  rest_api_id = aws_api_gateway_rest_api.tc-api-gateway.id
  parent_id   = aws_api_gateway_resource.terraform-course.id
  path_part   = "hello"   
}

# module bundles up resources for setting up 
module "hello" {
  source            = "./gw-basic-method-w-lambda"
  apigateway        = aws_api_gateway_rest_api.tc-api-gateway
  resource          = aws_api_gateway_resource.hello
  lambda_function   = aws_lambda_function.welcome-lambda
  authorization     = "NONE"
  httpmethod        =  "GET"
}

resource "aws_api_gateway_deployment" "hello-deployment" {
  rest_api_id = aws_api_gateway_rest_api.tc-api-gateway.id
  # when deploying the apis in the gateway 
  depends_on = [module.hello.integration]
  lifecycle {
    # if changes are made in the deployment create new resources before deleting
    # existing resources
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "r" {
  stage_name = "r"
  rest_api_id = aws_api_gateway_rest_api.tc-api-gateway.id
  deployment_id = aws_api_gateway_deployment.hello-deployment.id
  depends_on = [aws_api_gateway_rest_api.tc-api-gateway]
}