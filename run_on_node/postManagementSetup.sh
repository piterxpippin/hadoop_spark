#!/bin/bash

REPO_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. $REPO_DIR/externalFunctions.sh namenode

runAs hduser 'start-dfs.sh'
runAs hduser 'hdfs dfs -mkdir -p /user/hduser/input'
runAs hduser 'hdfs dfs -put /home/ec2-user/database/* /user/hduser/input/'
runAs hduser 'stop-dfs.sh'
