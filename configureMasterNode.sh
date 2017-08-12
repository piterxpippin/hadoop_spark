#!/bin/bash

keyPair=$1
nodeAddress=$2
nodeHostname=$3

ssh -o StrictHostKeyChecking=no -i $keyPair ec2-user@$nodeAddress 'sudo yum -y install git'
ssh -o StrictHostKeyChecking=no -i $keyPair ec2-user@$nodeAddress 'git clone https://github.com/piterxpippin/hadoop_spark.git'
ssh -o StrictHostKeyChecking=no -i $keyPair ec2-user@$nodeAddress 'sudo ~/hadoop_spark/managementSetup.sh' $nodeHostname
