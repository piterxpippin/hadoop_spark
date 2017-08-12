#!/bin/bash

aws ec2 describe-instances | python3 -c '
import sys,json
for value in json.load(sys.stdin)["Reservations"][1]["Instances"]:
    print(value["InstanceId"], value["Tags"][0]["Value"], value.get("PublicIpAddress"), sep="\t", end="\n")
'
