#!/bin/bash

if [ ! -z "$1" ]; then
    instanceName=$1
    instanceId=$(aws ec2 describe-instances --filters "Name=tag-value,Values=$instanceName" | grep -Po '"InstanceId": "(\K[^",]+)')
    aws ec2 stop-instances --instance-ids $instanceId
else
    echo "Name an instance to stop"
fi
