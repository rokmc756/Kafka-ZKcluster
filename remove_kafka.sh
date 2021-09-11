#!/bin/bash

for i in `echo "192.168.0.171 192.168.0.172 192.168.0.173"`
do
    echo $i
    ssh root@$i "systemctl stop kafka zookeeper"
    rm -rf /usr/local/kafka*
    rm -rf /usr/local/apache-zookeeper*
    ps -ef | grep java | grep kafka
    ps -ef | grep java | grep zookeeper
    rm -rf /var/log/zookeeper
    rm -rf /var/lib/zookeeper
    rm -rf /var/lib/kafka
    rm -rf /var/log/kafka
    rm -rf /tmp/lib/kafka/kafka-logs
done
