/usr/local/kafka/bin/kafka-topics.sh --zookeeper {{ zookeeper_hosts }}/kafka \
--topic customer_orders --delete
