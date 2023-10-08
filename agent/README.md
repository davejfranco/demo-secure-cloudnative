# Security Agent

The is a security agent that can be deployed as a container in a ECS task definition or deploy in a new AMI to be user in a ECS capacity provider.

## Pre-requisites
- Docker installed


## Steps
1. Clone this repository
2. Go to the agent folder
3. Run the following command to build the image:
```
docker build -t security-agent .
```
