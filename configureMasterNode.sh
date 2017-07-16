#!/bin/bash

keyPair=$1
nodeAddress=$2
nodeHostname=$3

ssh -i $keyPair ec2-user@$nodeAddress "sudo hostnamectl set-hostname $nodeHostname"
ssh -i $keyPair ec2-user@$nodeAddress 'sudo yum -y install git'
ssh -i $keyPair ec2-user@$nodeAddress 'git clone https://github.com/piterxpippin/hadoop_spark.git'
ssh -i $keyPair ec2-user@$nodeAddress 'sudo ~/hadoop_spark/managementSetup.sh'
