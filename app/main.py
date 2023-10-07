import json
import boto3
import pymysql
import botocore
from fastapi import FastAPI

SECRET_ID='n261'
VERSION=0.1
REGION='us-east-1'

app = FastAPI()

# Connect to AWS Secret Manager
client = boto3.client('secretsmanager', region_name=REGION)
#session = boto3.Session(region_name=REGION)
#client = session.client('secretsmanager')

# Retrieve database credentials from Secret Manager
try:
  response = client.get_secret_value(SecretId=SECRET_ID)
except botocore.exceptions.ClientError as error:
    raise error

# Connect to RDS instance
db_credentials = json.loads(response['SecretString'])
connection = pymysql.connect(
    host=db_credentials['DB_HOSTNAME'],
    user=db_credentials['DB_USERNAME'],
    password=db_credentials['DB_PASSWORD'],
    port=3306
)

# Check if connection was successful
if connection.open:
    print("Connection to MySQL instance successful")
    conn = "ok"
    connection.close()
else:
    print("Connection to MySQL instance failed")
    conn = "not ok"

# Define dummy endpoint
@app.get("/")
async def hello():
  return {"message": "Hello World"}

@app.get("/version")
async def version():
  return {"version": str(VERSION)}

@app.get("/db")
async def version():
  return {"connection": conn}
