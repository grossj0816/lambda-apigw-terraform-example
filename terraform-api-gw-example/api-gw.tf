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




# ENDPOINT PATH: /terraform-course/users
resource "aws_api_gateway_resource" "users" {
  rest_api_id  = aws_api_gateway_rest_api.tc-api-gateway.id
  parent_id    = aws_api_gateway_resource.terraform-course.id
  path_part    = "users"
}

# module bundles up resources for setting up users endpoint
module "fetch_all_users" {
  source            = "./gw-basic-method-w-lambda/"
  apigateway        = aws_api_gateway_rest_api.tc-api-gateway
  resource          = aws_api_gateway_resource.users
  lambda_function   = aws_lambda_function.fetchAllUsers_lambda
  authorization     = "NONE"
  httpmethod        =  "GET"
}



# ENDPOINT PATH: /terraform-course/users/{user}
resource "aws_api_gateway_resource" "indiv-user" {
  rest_api_id  = aws_api_gateway_rest_api.tc-api-gateway.id
  parent_id    = aws_api_gateway_resource.users.id
  path_part    = "{userId}"
}


module "fetch_user" {
  source            = "./gw-basic-method-w-lambda/"
  apigateway        = aws_api_gateway_rest_api.tc-api-gateway
  resource          = aws_api_gateway_resource.indiv-user
  lambda_function   = aws_lambda_function.fetchUser_lambda
  authorization     = "NONE"
  httpmethod        =  "GET"
}


module "delete_user" {
  source            = "./gw-basic-method-w-lambda/"
  apigateway        = aws_api_gateway_rest_api.tc-api-gateway
  resource          = aws_api_gateway_resource.indiv-user
  lambda_function   = aws_lambda_function.deleteUser_lambda
  # authorization     = "NONE"
  httpmethod        =  "DELETE"
}




# ENDPOINT PATH: /terraform-course/users/addNewUser
resource "aws_api_gateway_resource" "new-user" {
  rest_api_id  = aws_api_gateway_rest_api.tc-api-gateway.id
  parent_id    = aws_api_gateway_resource.users.id
  path_part    = "newUser"
}


module "new_user" {
  source            = "./gw-basic-method-w-lambda/"
  apigateway        = aws_api_gateway_rest_api.tc-api-gateway
  resource          = aws_api_gateway_resource.new-user
  lambda_function   = aws_lambda_function.createUser_lambda
  authorization     = "NONE"
  httpmethod        =  "POST"
}


# ENDPOINT PATH: /terraform-course/users/update
resource "aws_api_gateway_resource" "update-user" {
  rest_api_id  = aws_api_gateway_rest_api.tc-api-gateway.id
  parent_id    = aws_api_gateway_resource.users.id
  path_part    = "updateUser"
}

module "update_user" {
  source            = "./gw-basic-method-w-lambda/"
  apigateway        = aws_api_gateway_rest_api.tc-api-gateway
  resource          = aws_api_gateway_resource.update-user
  lambda_function   = aws_lambda_function.updateUser_lambda
  authorization     = "NONE"
  httpmethod        =  "PUT"
}


resource "aws_api_gateway_deployment" "hello-deployment" {
  rest_api_id = aws_api_gateway_rest_api.tc-api-gateway.id
  # when deploying the apis in the gateway 
  depends_on = [module.fetch_all_users.integration, 
                module.fetch_user.integration, 
                module.new_user.integration,
                module.update_user.integration,
                module.delete_user.integration]
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