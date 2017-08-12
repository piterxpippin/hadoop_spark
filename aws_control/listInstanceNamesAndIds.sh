#!/bin/bash

aws ec2 describe-instances | python3 -c '
import sys,json
for value in json.load(sys.stdin)["Reservations"][0]["Instances"]:
    print(value["Tags"][0]["Value"], value["InstanceId"], value.get("PublicIpAddress"), sep="\t", end="\n")
'
