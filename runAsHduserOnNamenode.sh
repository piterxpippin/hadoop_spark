#!/bin/bash

if [ -z "$1" ]; then
    echo "You must provide .pem key for logging into machines!"
    exit 1
fi
if [ -z "$2" ]; then
    echo "You must provide a command!"
    exit 1
fi
keyPath=$1
command=$2

namenodeAddress=$(aws-control/listInstances.sh | grep namenode | awk '{print $3}')
ssh -o StrictHostKeyChecking=no -i $keyPath ec2-user@$namenodeAddress "sudo -S -u hduser -i /bin/bash -l -c \"eval '$command'\""
