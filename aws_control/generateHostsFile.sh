#!/bin/bash

aws ec2 describe-instances --query 'Reservations[*].Instances[*].[PrivateIpAddress,Tags[*].Value]' | python3 -c '
import sys,json
for jsonArray in json.load(sys.stdin):
    for value in jsonArray:
        print(value[0], value[1][0], sep=" ", end="\n")
'
