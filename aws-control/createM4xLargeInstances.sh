#!/bin/bash

instanceTagNameList="namenode datanode1 datanode2 datanode3 datanode4"

for desiredNameTag in $instanceTagNameList; do
    aws ec2 run-instances \
        --image-id ami-9fa343e7 \
        --instance-type m4.xlarge \
        --key-name First_Key_Pair \
        --security-groups launch-wizard-1 \
        --placement 'AvailabilityZone=us-west-2c' \
        --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value='$desiredNameTag'}]' \
        --count 1
done
