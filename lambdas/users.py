import os
import json
import sys
import boto3
from boto3.dynamodb.conditions import Key

# fetch all users
def users_getter_handler(event, context):

    # set the resource that we are connecting to from our lambda
    dynamodb = boto3.resource('dynamodb')

    # setting the dynamodb table that we are trying to use
    table = dynamodb.Table('users')
    
    # set the response of the scan (fetch all) on the users table
    response = table.scan()

    # set response in item variable
    items = response['Items']


    #transform the response into json return it    
    return{
        "statusCode": 200,
        'body': json.dumps(items, indent=3)
    }



# fetch individual user
def user_getter_handler(event, context):

    # set the resource that we are connecting to from our lambda
    dynamodb = boto3.resource('dynamodb')

    # setting the dynamodb table that we are trying to use
    table = dynamodb.Table('users')

    #pulling in the path parameter that we set in the endpoint url
    userId = event.get('pathParameters', {}).get('userId', 'n/a')
    print("USER ID", userId)
    
    #set response to be the response retured from get_item()
    response = table.query(
        KeyConditionExpression=Key('userObjIndex').eq(userId)
    )

    # set response in item variable
    item = response['Items']


    return{
        "statusCode": 200,
        'body': json.dumps(item, indent=3)    
    }


# create new user record
def create_user_handler(event, context):

    userObj = json.loads(event.get('body'))

    # set the resource that we are connecting to from our lambda
    dynamodb = boto3.resource('dynamodb')

    # setting the dynamodb table that we are trying to use
    table = dynamodb.Table('users')



    table.put_item(
        Item={
            "userObjIndex" : userObj['userObjIndex'],
            'firstName' : userObj['firstName'],
            'lastName' : userObj['lastName'],
            'userName' : userObj['lastName'],
        }
    )


    return{
        "statusCode": 200,
        'body': "NEW USER RECORD HAS BEEN CREATED!"
    }


# update individual user record
def update_user_handler(event, context):

    userObj = json.loads(event.get('body'))

    # set the resource that we are connecting to from our lambda
    dynamodb = boto3.resource('dynamodb')

    # setting the dynamodb table that we are trying to use
    table = dynamodb.Table('users')

    response = table.update_item(
        Key={
            "userObjIndex" : userObj['userObjIndex']
        },
        UpdateExpression='SET firstName = :fname, lastName = :lname, userName = :uname',
        ExpressionAttributeValues={
            ':fname': userObj['firstName'],
            ':lname': userObj['lastName'],
            ':uname': userObj['userName']
        }
    )

    return{
        "statusCode": 200,
        'body': 'EXISTING USER RECORD HAS BEEN UPDATED!'
    }



# delete individual user record
def delete_user_handler(event, context):

    # set the resource that we are connecting to from our lambda
    dynamodb = boto3.resource('dynamodb')

    # setting the dynamodb table that we are trying to use
    table = dynamodb.Table('users')

    #pulling in the path parameter that we set in the endpoint url
    userId = event.get('pathParameters', {}).get('userId', 'n/a')




    #set response to be the response retured from get_item()
    response = table.delete_item(
        Key={
            "userObjIndex" : userId
        }
    )


    return{
        "statusCode": 200,
        'body': 'EXISTING USER RECORD HAS BEEN DELETED!'
    }