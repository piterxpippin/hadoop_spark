#!/bin/bash

REPO_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. $REPO_DIR/externalFunctions.sh namenode

downloadAndInstallKafka
downloadAndInstallHive
