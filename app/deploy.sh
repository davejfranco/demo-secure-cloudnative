#!/bin/bash

TASK_DEFINITION=$1
CLUSTER_NAME=$2
SERVICE_NAME=$3

TASK_DEFINITION=$(aws ecs describe-task-definition --task-definition "$TASK_FAMILY" --region "$AWS_DEFAULT_REGION")

NEW_TASK_DEFINITION=$(echo $TASK_DEFINITION | jq --arg IMAGE "$FULL_IMAGE" '.taskDefinition | .containerDefinitions[0].image = $IMAGE | del(.taskDefinitionArn) | del(.revision) | del(.status) | del(.requiresAttributes) | del(.compatibilities) |  del(.registeredAt)  | del(.registeredBy)')

NEW_TASK_INFO=$(aws ecs register-task-definition --region "$AWS_DEFAULT_REGION" --cli-input-json "$NEW_TASK_DEFINITION")

NEW_REVISION=$(echo $NEW_TASK_INFO | jq '.taskDefinition.revision')

aws ecs update-service --cluster ${ECS_CLUSTER} --service ${SERVICE_NAME} --task-definition ${TASK_FAMILY}:${NEW_REVISION}