#!/bin/bash

REPO_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function runAs() {
    local username="$1"
    local command="$2"
    sudo -S -u $username -i /bin/bash -l -c "eval '$command'"
}


function installNecessaryPackages() {
    local necessaryPackages="expect java java-devel wget"
    yum -y install $necessaryPackages
}

function addHostnamesAndRemoveMalfunctioningLocalhost() {
    cat $REPO_DIR/hosts_conf >> /etc/hosts
    
    # Remove the first line - it contains localhost address with hostname, that broke connectivity between namenode and datanode
    #mv /etc/hosts /etc/hosts.bkp
    #tail -n +2 /etc/hosts > /etc/hosts
}

function createHadoopGroupAndHduser() {
    useradd hduser
    echo hduser:hduser | chpasswd
    groupadd hadoop
    usermod -a -G hadoop hduser
}

function disableIPv6() {
    grep -q "net.ipv6.conf.all.disable_ipv6=1" "/etc/sysctl.conf"
    if [ ! "$?" ]; then
        sudo echo "net.ipv6.conf.all.disable_ipv6=1"     >> /etc/sysctl.conf
    fi
    
    grep -q "net.ipv6.conf.default.disable_ipv6=1" "/etc/sysctl.conf"
    if [ ! "$?" ]; then
        echo "net.ipv6.conf.default.disable_ipv6=1"     >> /etc/sysctl.conf
    fi
    
    grep -q "net.ipv6.conf.lo.disable_ipv6=1" "/etc/sysctl.conf"
    if [ ! "$?" ]; then
        echo "net.ipv6.conf.lo.disable_ipv6=1"     >> /etc/sysctl.conf
    fi
    
    sysctl -p
}

function configureSshToNotAskTooManyQuestions() {
    runAs hduser 'echo "Host *"                 > $HOME/.ssh/config'
    runAs hduser 'echo "    StrictHostKeyChecking no"     >> $HOME/.ssh/config'
    runAs hduser 'echo "    UserKnownHostsFile=/dev/null" >> $HOME/.ssh/config'
}

function generateSshKeysForHduser() {
    runAs hduser 'if [ ! -e $HOME/.ssh/id_rsa ]; then ssh-keygen -t rsa -P "" -f $HOME/.ssh/id_rsa; cat $HOME/.ssh/id_rsa.pub >> $HOME/.ssh/authorized_keys; fi'
}

function extractHadoopToNode() {
    if [ ! -e /tmp/hadoop-2.7.3.tar.gz ]; then
        wget http://www-eu.apache.org/dist/hadoop/common/hadoop-2.7.3/hadoop-2.7.3.tar.gz -O /tmp/hadoop-2.7.3.tar.gz
    fi
    tar xf /tmp/hadoop-2.7.3.tar.gz -C /usr/local
    mv /usr/local/hadoop-2.7.3 /usr/local/hadoop
}

function modifyBashrcForHduser() {
    cp $REPO_DIR/addToBashrc.sh /tmp/addToBashrc.sh
    chmod 777 $REPO_DIR/addToBashrc.sh
    runAs hduser 'cat /tmp/addToBashrc.sh >> ~/.bashrc'
    rm /tmp/addToBashrc.sh
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
