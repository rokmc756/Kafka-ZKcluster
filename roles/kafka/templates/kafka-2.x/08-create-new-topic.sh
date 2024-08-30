/usr/local/kafka/bin/kafka-topics.sh --create --zookeeper  {{ hostvars[groups['kafka_brokers'][0]].ansible_hostname }}:2181/kafka --replication-factor 1 --partitions 1 --topic customer_orders
# /usr/local/kafka/bin/kafka-topics.sh --create --zookeeper {{ zookeeper_hosts }}/kafka --replication-factor 1 --partitions 1 --topic customer_orders

