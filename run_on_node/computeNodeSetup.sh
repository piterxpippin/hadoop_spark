#!/bin/bash

if [ $EUID -ne 0 ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

if [ -z "$1" ]; then
    echo 'You must provide a hostname!'
    exit 1
fi

REPO_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
hostname=$1

. $REPO_DIR/externalFunctions.sh $hostname

installNecessaryPackages
setHostname
addExternalHostnames
createHadoopGroupAndHduser
disableIPv6
configureSshToNotAskTooManyQuestions
generateSshKeysForSlaveHduser
modifyBashrcForHduser
extractHadoopToNode
fixProblemWithMissingJavaHomeVariable
copyHadoopConfigurationXmls
setOwnershipToHduserHadoop

echo "Compute node setup completed."
