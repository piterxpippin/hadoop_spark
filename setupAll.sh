#!/bin/bash

for instance in $(./aws_control/listInstances.sh); do
    instanceName=$(echo $instance | awk '{print $2}')
    instancePublicIp=$(echo $instance | awk '{print $3}')
    
    if [ $instanceName == "namenode" ]; then
        ./configureMasterNode.sh ../First_Key_Pair.pem $instancePublicIp $instanceName
    else
        ./configureSlaveNode.sh ../First_Key_Pair.pem $instancePublicIp $instanceName
    fi
done
