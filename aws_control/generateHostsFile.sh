#!/bin/bash

aws ec2 describe-instances | python3 -c '
import sys,json
for value in json.load(sys.stdin)["Reservations"][0]["Instances"]:
    print(value.get("PrivateIpAddress"), value["Tags"][0]["Value"], sep=" ", end="\n")
'
