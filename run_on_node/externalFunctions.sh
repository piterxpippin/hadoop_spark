#!/bin/bash

REPO_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
hostname=$1

function runAs() {
    local username="$1"
    local command="$2"
    sudo -S -u $username -i /bin/bash -l -c "eval '$command'"
}


function installNecessaryPackages() {
    local necessaryPackages="expect java java-devel wget"
    yum -y install $necessaryPackages
}

function setHostname() {
    cp /etc/hosts /etc/hosts.backup
    # localhost set in the file breaks connectivity (it is now removed completely)
    # sed -i "s/127.0.0.1/# 127.0.0.1/" /etc/hosts
    echo $hostname > /etc/hostname
    hostnamectl set-hostname --static $hostname
    echo 'preserve_hostname: true' >> /etc/cloud/cloud.cfg
}

function addExternalHostnames() {
    cat $REPO_DIR/hosts > /etc/hosts
}

function createHadoopGroupAndHduser() {
    useradd hduser
    echo hduser:hduser | chpasswd
    groupadd hadoop
    usermod -g hadoop hduser
    usermod -a -G ec2-user hduser
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
    runAs hduser 'mkdir $HOME/.ssh'
    runAs hduser 'chmod 700 $HOME/.ssh'
    
    runAs hduser 'touch $HOME/.ssh/config'
    runAs hduser 'chmod 600 $HOME/.ssh/config'
    runAs hduser 'echo "Host namenode"                 > $HOME/.ssh/config'
    runAs hduser 'echo "    StrictHostKeyChecking no" >> $HOME/.ssh/config'
    runAs hduser 'echo "Host datanode?"               >> $HOME/.ssh/config'
    runAs hduser 'echo "    StrictHostKeyChecking no" >> $HOME/.ssh/config'
    runAs hduser 'echo "Host 0.0.0.0"                 >> $HOME/.ssh/config'
    runAs hduser 'echo "    StrictHostKeyChecking no" >> $HOME/.ssh/config'
}

function generateSshKeysForMasterHduser() {
    #runAs hduser 'if [ ! -e $HOME/.ssh/id_rsa ]; then ssh-keygen -t rsa -P "" -f $HOME/.ssh/id_rsa; cat $HOME/.ssh/id_rsa.pub >> $HOME/.ssh/authorized_keys; fi'
    cp -R $REPO_DIR/ssh/ /tmp/
    
    runAs hduser 'cp /tmp/ssh/id_rsa $HOME/.ssh/id_rsa'
    runAs hduser 'chmod 600 $HOME/.ssh/id_rsa'
    
    runAs hduser 'cp /tmp/ssh/id_rsa.pub $HOME/.ssh/id_rsa.pub'
    runAs hduser 'chmod 644 $HOME/.ssh/id_rsa.pub'
    
    runAs hduser 'cp /tmp/ssh/authorized_keys $HOME/.ssh/authorized_keys'
    runAs hduser 'chmod 644 $HOME/.ssh/authorized_keys'
    
    rm -rf /tmp/ssh
}

function generateSshKeysForSlaveHduser() {
    #runAs hduser 'if [ ! -e $HOME/.ssh/id_rsa ]; then ssh-keygen -t rsa -P "" -f $HOME/.ssh/id_rsa; cat $HOME/.ssh/id_rsa.pub >> $HOME/.ssh/authorized_keys; fi'
    #runAs hduser 'cp $REPO_DIR/ssh/id_rsa $HOME/.ssh/id_rsa'
    #runAs hduser 'cp $REPO_DIR/ssh/id_rsa.pub $HOME/.ssh/id_rsa.pub'
    cp -R $REPO_DIR/ssh/ /tmp/
    runAs hduser 'if [ ! -e $HOME/.ssh/id_rsa ]; then ssh-keygen -t rsa -P "" -f $HOME/.ssh/id_rsa; fi'
    runAs hduser 'chmod 600 $HOME/.ssh/id_rsa'
    runAs hduser 'chmod 644 $HOME/.ssh/id_rsa.pub'
    
    runAs hduser 'cp /tmp/ssh/authorized_keys $HOME/.ssh/authorized_keys'
    runAs hduser 'cat $HOME/.ssh/id_rsa.pub >> $HOME/.ssh/authorized_keys'
    runAs hduser 'chmod 644 $HOME/.ssh/authorized_keys'
    
    rm -rf /tmp/ssh
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
    chmod 777 /tmp/addToBashrc.sh
    runAs hduser 'cat /tmp/addToBashrc.sh >> ~/.bashrc'
    rm /tmp/addToBashrc.sh
}

function fixProblemWithMissingJavaHomeVariable() {
    echo 'export JAVA_HOME=/usr/lib/jvm/java-1.8.0' >> /etc/profile
    sed -i 's|export JAVA_HOME=${JAVA_HOME}|export JAVA_HOME=/usr/lib/jvm/java-1.8.0|g' /usr/local/hadoop/etc/hadoop/hadoop-env.sh
}

function copyHadoopConfigurationXmls() {
    cp $REPO_DIR/hadoop_common_configuration/* /usr/local/hadoop/etc/hadoop
}

function addHadoopMastersAndSlavesList() {
    cp $REPO_DIR/hadoop_master_configuration/masters /usr/local/hadoop/etc/hadoop/masters
    cp $REPO_DIR/hadoop_master_configuration/slaves /usr/local/hadoop/etc/hadoop/slaves
}

function setOwnershipToHduserHadoop() {
    chown -R hduser:hadoop /usr/local/hadoop
}

function setupHdfsBeforeFirstRun() {
    runAs hduser 'hdfs namenode -format'
}

function downloadAndInstallKafka() {
    if [ ! -e /tmp/kafka_2.11-0.11.0.0.tgz ]; then
        wget http://ftp.ps.pl/pub/apache/kafka/0.11.0.0/kafka_2.11-0.11.0.0.tgz -O /tmp/kafka_2.11-0.11.0.0.tgz
    fi
    tar xf /tmp/kafka_2.11-0.11.0.0.tgz -C /usr/local
    mv /usr/local/kafka_2.11-0.11.0.0 /usr/local/kafka
    chown -R hduser:hadoop /usr/local/kafka
}

function downloadAndInstallHive() {
    if [ ! -e /tmp/apache-hive-2.3.0-bin.tar.gz ]; then
        wget http://ftp.ps.pl/pub/apache/hive/hive-2.3.0/apache-hive-2.3.0-bin.tar.gz -O /tmp/apache-hive-2.3.0-bin.tar.gz
    fi
    tar xf /tmp/apache-hive-2.3.0-bin.tar.gz -C /usr/local
    mv /usr/local/apache-hive-2.3.0-bin /usr/local/apache-hive
    chown -R hduser:hadoop /usr/local/apache-hive
}
