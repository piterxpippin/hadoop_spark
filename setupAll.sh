#!/bin/bash

if [ -z "$1" ]; then
    echo "You must provide .pem key for logging into machines!"
    exit 1
fi
keyPair=$1

. aws-control/createM4LargeInstances.sh
while [ $(aws ec2 describe-instance-status | grep "running" | wc -l) != "5" ]; do
    echo "Waiting 5 seconds for all instances' \"running\" state..."
    sleep 5
done

if [ "$(aws-control/generateHostsFile.sh)" != "$(cat run_on_node/hosts)" ]; then
    aws-control/generateHostsFile.sh > run_on_node/hosts
    git add run_on_node/hosts
    git commit -m "Updating hosts file"
    git push
fi

OLD_IFS=$IFS
IFS=$'\n'
namenodeInstancePublicIp=""
for instance in $(aws-control/listInstances.sh); do
    IFS=$OLD_IFS
    instanceName=$(echo $instance | awk '{print $2}')
    instancePublicIp=$(echo $instance | awk '{print $3}')

    if [ "$instanceName" != "namenode" ]; then
        ./configureSlaveNode.sh $keyPair $instancePublicIp $instanceName &
    else
        namenodeInstancePublicIp=$instancePublicIp
    fi
done

./configureMasterNode.sh $keyPair $namenodeInstancePublicIp namenode
