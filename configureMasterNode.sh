#!/bin/bash

keyPair=$1
nodeAddress=$2
nodeHostname=$3

ssh -o StrictHostKeyChecking=no -i $keyPair ec2-user@$nodeAddress 'sudo yum -y install git'
ssh -o StrictHostKeyChecking=no -i $keyPair ec2-user@$nodeAddress 'if [ -d "$HOME/hadoop_spark" ]; then cd ~/hadoop_spark; git pull -r; else git clone https://github.com/piterxpippin/hadoop_spark.git; fi'
ssh -o StrictHostKeyChecking=no -i $keyPair ec2-user@$nodeAddress 'cd ~/hadoop_spark/run_on_node; sudo ./managementSetup.sh '$nodeHostname
ssh -o StrictHostKeyChecking=no -i $keyPair ec2-user@$nodeAddress 'sudo reboot'
