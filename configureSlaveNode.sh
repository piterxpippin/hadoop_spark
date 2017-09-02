#!/bin/bash

keyPair=$1
nodeAddress=$2
nodeHostname=$3

function runCommand() {
    ssh -o StrictHostKeyChecking=no -i $keyPair ec2-user@$nodeAddress $1
}

runCommand 'sudo yum -y install git'
runCommand 'if [ -d "$HOME/hadoop_spark" ]; then cd ~/hadoop_spark; git pull -r; else git clone https://github.com/piterxpippin/hadoop_spark.git; fi'
runCommand 'cd ~/hadoop_spark/run_on_node; sudo ./computeNodeSetup.sh '$nodeHostname
runCommand 'sudo reboot'
