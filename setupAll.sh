#!/bin/bash

if [ -z "$1" ]; then
    echo "You must provide .pem key for logging into machines!"
    exit 1
fi
keyPath=$1

. aws_control/startAllInstances.sh
while [ $(aws ec2 describe-instance-status | grep "running" | wc -l) == "0" ]; do
    echo "Waiting 5 seconds for all instances' \"running\" state..."
    sleep 5
done

aws_control/generateHostsFile.sh > run_on_node/hosts
git add run_on_node/hosts
git commit -m "Updating hosts file"
git push

OLD_IFS=$IFS
IFS=$'\n'
for instance in $(aws_control/listInstances.sh | while read -r a; do echo $a; done); do
    IFS=$OLD_IFS
    instanceName=$(echo $instance | awk '{print $2}')
    instancePublicIp=$(echo $instance | awk '{print $3}')
    
    if [ "$instanceName" == "namenode" ]; then
        ./configureMasterNode.sh $keyPath $instancePublicIp $instanceName
    else
        ./configureSlaveNode.sh $keyPath $instancePublicIp $instanceName
    fi
done
