#!/bin/bash

if [ $EUID -ne 0 ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

. ./externalFunctions.sh

installNecessaryPackages
addHostnamesAndRemoveMalfunctioningLocalhost
createHadoopGroupAndHduser
disableIPv6
configureSshToNotAskTooManyQuestions
generateSshKeysForMasterHduser
modifyBashrcForHduser
extractHadoopToNode
fixProblemWithMissingJavaHomeVariable
copyHadoopConfigurationXmls
addHadoopSlavesListFile
setOwnershipToHduserHadoop

echo "Management node setup completed."
