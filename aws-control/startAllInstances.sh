#!/bin/bash

aws ec2 start-instances --instance-ids $(aws-control/listInstances.sh | awk '{print $1}' | tr '\n' ' ')
