#!/bin/bash

HOSTS="rk8-master rk8-slave rk8-node01 rk8-node02 rk8-node03"
# HOSTS="rk9-master rk9-slave rk9-node01 rk9-node02 rk9-node03"
for i in `echo "$HOSTS"`
do
    ssh root@$i "systemctl stop kafaka"
    ssh root@$i "systemctl stop zookeeper"
    ssh root@$i "killall java"
done

for i in `echo "$HOSTS"`
do
    ssh root@$i "rm -rf /usr/local/kafka* /usr/local/apache-zookeeper* /var/log/zookeeper /var/lib/zookeeper /var/lib/kafka /tmp/lib/kafka/kafka-logs"
    ssh root@$i "sync; echo 3 > /proc/sys/vm/drop_caches"
done
