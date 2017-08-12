#!/bin/bash

./aws_control/listInstances.sh

./configureMasterNode.sh ../First_Key_Pair.pem 52.43.162.116 namenode
./configureSlaveNode.sh ../First_Key_Pair.pem 34.211.6.20    datanode1
./configureSlaveNode.sh ../First_Key_Pair.pem 34.211.102.147 datanode2
./configureSlaveNode.sh ../First_Key_Pair.pem 35.162.174.117 datanode3
./configureSlaveNode.sh ../First_Key_Pair.pem 52.26.45.218   datanode4
