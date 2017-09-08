export JAVA_HOME=/usr/lib/jvm/java-1.8.0

export HADOOP_HOME=/usr/local/hadoop
export HADOOP_CONF_DIR=/usr/local/hadoop/etc/hadoop
export HIVE_HOME=/usr/local/apache-hive
export KAFKA_HOME=/usr/local/kafka

#Some convenient aliases
unalias fs &> /dev/null
alias fs="hadoop fs"
unalias hls &> /dev/null
alias hls="fs -ls"

export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$HIVE_HOME/bin:$KAFKA_HOME/bin
