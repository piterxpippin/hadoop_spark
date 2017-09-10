#!/bin/bash

aws ec2 describe-instances --filters 'Name=instance-state-name,Values=pending,running,shutting-down,stopping,stopped' --query 'Reservations[*].Instances[*].[PrivateIpAddress,Tags[*].Value]' | python3 -c '
import sys,json
for jsonArray in json.load(sys.stdin):
    for value in jsonArray:
        print(value[0], value[1][0], sep=" ", end="\n")
'
