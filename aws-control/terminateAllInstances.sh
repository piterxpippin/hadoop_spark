#!/bin/bash

aws ec2 terminate-instances --instance-ids $(aws-control/listInstances.sh | awk '{print $1}' | tr '\n' ' ')
