#!/bin/bash

keyPair=$1
nodeAddress=$2
nodeHostname=$3

function runCommand() {
    ssh -o StrictHostKeyChecking=no -i $keyPair ec2-user@$nodeAddress $1
}

runCommand 'sudo yum -y install git wget screen'
runCommand 'chmod -R 750 $HOME'
runCommand 'if [ -d "$HOME/hadoop_spark" ]; then cd ~/hadoop_spark; git pull -r; else git clone https://github.com/piterxpippin/hadoop_spark.git; fi'
runCommand 'mkdir database'
runCommand 'cd database; for file in $(curl http://ftp.sunet.se/mirror/archive/ftp.sunet.se/pub/tv+movies/imdb/ | grep --color=never -Po "\>(\K[a-z\.-]+\.gz)"); do wget http://ftp.sunet.se/mirror/archive/ftp.sunet.se/pub/tv+movies/imdb/$file & done; wait'
runCommand 'cd database; for file in $(ls); do gunzip $file & done; wait'
runCommand 'chmod -R 777 database'
runCommand 'cd ~/hadoop_spark/run_on_node; sudo ./managementSetup.sh '$nodeHostname
runCommand 'sudo reboot'
sleep 30
runCommand 'cd ~/hadoop_spark/run_on_node; ./postManagementSetup.sh'
runCommand 'cd ~/hadoop_spark/run_on_node; sudo ./kafkaHiveSetup.sh'
