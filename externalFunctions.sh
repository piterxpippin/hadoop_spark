#!/bin/bash

REPO_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function runAs() {
    local username="$1"
    local command="$2"
    sudo -S -u $username -i /bin/bash -l -c "eval '$command'"
}


function installNecessaryPackages() {
    local necessaryPackages="expect java java-devel wget"
    sudo yum -y install $necessaryPackages
}

function addHostnamesAndRemoveMalfunctioningLocalhost() {
    cat $REPO_DIR/hosts_conf >> /etc/hosts
    
    # Remove the first line - it contains localhost address with hostname, that broke connectivity between namenode and datanode
    #mv /etc/hosts /etc/hosts.bkp
    #tail -n +2 /etc/hosts > /etc/hosts
}

function createHadoopGroupAndAddHduser() {
    sudo groupadd hadoop
    sudo usermod -a -G hadoop hduser
}

function disableIPv6() {
    echo "net.ipv6.conf.all.disable_ipv6=1"     >> /etc/sysctl.conf
    echo "net.ipv6.conf.default.disable_ipv6=1" >> /etc/sysctl.conf
    echo "net.ipv6.conf.lo.disable_ipv6=1"      >> /etc/sysctl.conf
    sudo sysctl -p
}

function configureSshToNotAskTooManyQuestions() {
    runAs hduser 'echo "Host *"                 >> $HOME/.ssh/config'
    runAs hduser 'echo "    StrictHostKeyChecking no"     >> $HOME/.ssh/config'
    runAs hduser 'echo "    UserKnownHostsFile=/dev/null" >> $HOME/.ssh/config'
}

function generateSshKeysForHduser() {
    runAs hduser 'ssh-keygen -t rsa -P "" -f $HOME/.ssh/id_rsa'
    runAs hduser 'cat $HOME/.ssh/id_rsa.pub >> $HOME/.ssh/authorized_keys'
}

function extractHadoopToNode() {
    mkdir $REPO_DIR/downloads
    if [ ! -e "/tmp/hadoop-2.7.3.tar.gz" ]; then
        wget http://www-eu.apache.org/dist/hadoop/common/hadoop-2.7.3/hadoop-2.7.3.tar.gz /tmp/hadoop-2.7.3.tar.gz
    fi
    tar xf $REPO_DIR/packages/hadoop-2.7.3.tar.gz -C /usr/local
    mv /usr/local/hadoop-2.7.3 /usr/local/hadoop
}

function modifyBashrcForHduser() {
    runAs hduser 'cat '$REPO_DIR'/addToBashrc.sh >> ~/.bashrc'
}

function fixProblemWithMissingJavaHomeVariable() {
    echo 'export JAVA_HOME=/usr/lib/jvm/java-1.8.0' >> /etc/profile
    sed -i 's|export JAVA_HOME=${JAVA_HOME}|export JAVA_HOME=/usr/lib/jvm/java-1.8.0|g' /usr/local/hadoop/etc/hadoop/hadoop-env.sh
}

function copyHadoopConfigurationXmls() {
    cp -R $REPO_DIR/hadoop_configuration /usr/local/hadoop/etc/hadoop
}

function addHadoopSlavesListFile() {
    cp $REPO_DIR/available_hosts /usr/local/hadoop/etc/hadoop/slaves
}

function setOwnershipToHduserHadoop() {
    chown -R hduser:hadoop /usr/local/hadoop
}
