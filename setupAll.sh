#!/bin/bash

. aws_control/startAllInstances.sh
while [ $(aws ec2 describe-instance-status | grep "running" | wc -l) == "0" ]; do
    echo "Waiting 5 seconds for all instances' \"running\" state..."
    sleep 5
done

for instance in $(./aws_control/listInstances.sh); do
    instanceName=$(echo $instance | awk '{print $2}')
    instancePublicIp=$(echo $instance | awk '{print $3}')
    
    if [ "$instanceName" == "namenode" ]; then
        ./configureMasterNode.sh ../First_Key_Pair.pem $instancePublicIp $instanceName
    else
        ./configureSlaveNode.sh ../First_Key_Pair.pem $instancePublicIp $instanceName
    fi
done
