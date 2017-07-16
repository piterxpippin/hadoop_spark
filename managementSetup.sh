#!/bin/bash

if [ $EUID -ne 0 ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

. ./externalFunctions.sh

installNecessaryPackages
addHostnamesAndRemoveMalfunctioningLocalhost
createHadoopGroupAndAddHduser
disableIPv6
configureSshToNotAskTooManyQuestions
generateSshKeysForHduser
modifyBashrcForHduser
extractHadoopToNode
extractSparkToNode
fixProblemWithMissingJavaHomeVariable
copyHadoopConfigurationXmls
addHadoopSlavesListFile
setOwnershipToHduserHadoop

echo "Management node setup completed."