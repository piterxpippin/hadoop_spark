#!/bin/bash

aws ec2 stop-instances --instance-ids $(aws_control/listInstances.sh | awk '{print $1}' | tr '\n' ' ')
