#!/bin/bash

keyPair=$1
nodeAddress=$2
nodeHostname=$3

ssh -o StrictHostKeyChecking=no -i $keyPair ec2-user@$nodeAddress 'sudo yum -y install git wget'
ssh -o StrictHostKeyChecking=no -i $keyPair ec2-user@$nodeAddress 'chmod -R 740 $HOME'
ssh -o StrictHostKeyChecking=no -i $keyPair ec2-user@$nodeAddress 'if [ -d "$HOME/hadoop_spark" ]; then cd ~/hadoop_spark; git pull -r; else git clone https://github.com/piterxpippin/hadoop_spark.git; fi'
ssh -o StrictHostKeyChecking=no -i $keyPair ec2-user@$nodeAddress 'mkdir database'
ssh -o StrictHostKeyChecking=no -i $keyPair ec2-user@$nodeAddress 'cd database; for file in $(curl http://ftp.sunet.se/mirror/archive/ftp.sunet.se/pub/tv+movies/imdb/ | grep --color=never -Po "\>(\K[a-z\.-]+\.gz)"); do wget http://ftp.sunet.se/mirror/archive/ftp.sunet.se/pub/tv+movies/imdb/$file & done; wait'
ssh -o StrictHostKeyChecking=no -i $keyPair ec2-user@$nodeAddress 'cd database; for file in $(ls); do gunzip $file & done; wait'
ssh -o StrictHostKeyChecking=no -i $keyPair ec2-user@$nodeAddress 'chmod -R 777 database'
ssh -o StrictHostKeyChecking=no -i $keyPair ec2-user@$nodeAddress 'cd ~/hadoop_spark/run_on_node; sudo ./managementSetup.sh '$nodeHostname
ssh -o StrictHostKeyChecking=no -i $keyPair ec2-user@$nodeAddress 'sudo reboot'
