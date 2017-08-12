#!/bin/bash

$(aws_control/listInstances.sh | grep namenode | awk '{print $3}')
