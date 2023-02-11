# this file stores all the delcaration of the variables that the "hello" module is 
# going to set values for in api-gw.tf


variable "apigateway" {}

variable resource {}

variable httpmethod {
    default = "GET"
}

variable "authorization" {
  default = "NONE"
}

variable "lambda_function" {}