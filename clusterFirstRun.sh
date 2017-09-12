#!/bin/bash

if [ -z "$1" ]; then
    echo "You must provide .pem key for logging into machines!"
    exit 1
fi
keyPath=$1

namenodeAddress=$(aws-control/listInstances.sh | grep namenode | awk '{print $3}')
ssh -o StrictHostKeyChecking=no -i $keyPath ec2-user@$namenodeAddress 'sudo -S -u hduser -i /bin/bash -l -c "start-dfs.sh; start-yarn.sh"'
sleep 20

ssh -o StrictHostKeyChecking=no -i $keyPath ec2-user@$namenodeAddress 'sudo -S -u hduser -i /bin/bash -l -c "hdfs dfs -mkdir -p /tmp"'
ssh -o StrictHostKeyChecking=no -i $keyPath ec2-user@$namenodeAddress 'sudo -S -u hduser -i /bin/bash -l -c "hdfs dfs -mkdir -p /user/hive/warehouse"'
ssh -o StrictHostKeyChecking=no -i $keyPath ec2-user@$namenodeAddress 'sudo -S -u hduser -i /bin/bash -l -c "hdfs dfs -chmod g+w /tmp"'
ssh -o StrictHostKeyChecking=no -i $keyPath ec2-user@$namenodeAddress 'sudo -S -u hduser -i /bin/bash -l -c "hdfs dfs -chmod g+w /user/hive/warehouse"'

ssh -o StrictHostKeyChecking=no -i $keyPath ec2-user@$namenodeAddress 'sudo -S -u hduser -i /bin/bash -l -c "schematool -dbType derby -initSchema"'
#ssh -o StrictHostKeyChecking=no -i $keyPath ec2-user@$namenodeAddress 'screen -S hiveServerRun -d -m sudo -S -u hduser -i /bin/bash -l -c "hiveserver2"'
sleep 10

ssh -o StrictHostKeyChecking=no -i $keyPath ec2-user@$namenodeAddress 'sudo -S -u hduser -i /bin/bash -l -c "zookeeper-server-start.sh -daemon /usr/local/kafka/config/zookeeper.properties"'
sleep 10
ssh -o StrictHostKeyChecking=no -i $keyPath ec2-user@$namenodeAddress 'sudo -S -u hduser -i /bin/bash -l -c "kafka-server-start.sh -daemon /usr/local/kafka/config/server.properties"'
sleep 10
ssh -o StrictHostKeyChecking=no -i $keyPath ec2-user@$namenodeAddress 'sudo -S -u hduser -i /bin/bash -l -c "kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic testTopic"'
