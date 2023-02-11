def welcome_handler(event, context):
    return {
        "statusCode": 200,
        'body': 'Hello Juwan'
    }


def name_handler(event, context):

    if event['pathParameters'] is None:
      return{
        "statusCode": 200,
        'body': 'YOU DID NOT ENTER A NAME!!'
      }

    message = 'Hello {}!'.format(event['pathParameters']['name'])
    return{
        "statusCode": 200,
        'body': message
    }