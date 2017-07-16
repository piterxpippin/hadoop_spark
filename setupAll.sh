#!/bin/bash

./configureMasterNode.sh ../First_Key_Pair.pem 52.43.162.116 hadoop_namenode
./configureSlaveNode.sh ../First_Key_Pair.pem 34.211.6.20    hadoop_datanode_1
./configureSlaveNode.sh ../First_Key_Pair.pem 34.211.102.147 hadoop_datanode_2
./configureSlaveNode.sh ../First_Key_Pair.pem 35.162.174.117 hadoop_datanode_3
./configureSlaveNode.sh ../First_Key_Pair.pem 52.26.45.218   hadoop_datanode_4
