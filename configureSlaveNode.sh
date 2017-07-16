#!/bin/bash

keyPair=$1
nodeAddress=$2

ssh -i $keyPair ec2-user@$nodeAddress 'sudo yum -y install git'
ssh -i $keyPair ec2-user@$nodeAddress 'git clone https://github.com/piterxpippin/hadoop_spark.git'
ssh -i $keyPair ec2-user@$nodeAddress 'cd ~/hadoop_spark/; sudo ./computeNodeSetup.sh'
