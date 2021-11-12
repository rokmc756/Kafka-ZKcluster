# What is Kafka-ZKCluster?
Kafka-ZKCluster is ansible playbook to deploy Apache Kafka that is a distributed event streaming platform using publish-subscribe topics and Zookeeper that keeps track of status of the Kafka cluster nodes and it also keeps track of Kafka topics, partitions etc.
Zookeeper it self is allowing multiple clients to perform simultaneous reads and writes and acts as a shared configuration service within the system.

# Kafka-ZKCluster Architecutre
![alt text](https://github.com/rokmc756/kafka-zkcluster/blob/main/roles/kafka/files/kafka-diagram.jpeg)


# Where is Kafka-ZKCluster from how is it changed?
Kafka-ZKCluster has been developing based on https://github.com/sleighzy/ansible-kafka. Sleighzy! Thanks for sharing it.
Since it provide Oracle JDK install I've changed it to OpenJDK in grobal variables in a group_vars directory.
Additionally systemd configuration files for zookeeper and kafka has been changed as well.

# Supported Kafka and Zookeeper version
Kafka
Zookeeper

# Supported Platform and OS
Virtual Machines
Cloud Infrastructure
Baremetal
RHEL / CentOS and Rocky 5/6/7


# Prerequisite
MacOS or Fedora/CentOS/RHEL installed with ansible as ansible host.
At least three supported OS should be prepared with yum repository configured

# Prepare ansible host to run gpfarmer
* MacOS
~~~
$ xcode-select --install
$ brew install ansible
$ brew install https://raw.githubusercontent.com/kadwanev/bigboybrew/master/Library/Formula/sshpass.rb
~~~

* Fedora/CentOS/RHEL
~~~
$ sudo yum install ansible
$ sudo yum install sshpass
~~~

## Prepareing OS
Configure Yum / Local & EPEL Repostiory

# Download / configure / run gpfarmer
$ git clone https://github.com/rokmc756/kafka-zkcluster

$ cd kafka-zkcluster

$ vi Makefile
~~~
ANSIBLE_HOST_PASS="changeme"  # It should be changed with password of user in ansible host that gpfarmer would be run.
ANSIBLE_TARGET_PASS="changeme"  # # It should be changed with password of sudo user in managed nodes that gpdb would be installed.
~~~

$ vi ansible-hosts
~~~
[all:vars]
ssh_key_filename="id_rsa"
remote_machine_username="jomoon"
remote_machine_password="changeme"

# These are your kafka cluster nodes
[kafka_servers]
sdw6-01 kafka_broker_id=1 ansible_ssh_host=192.168.0.61
sdw6-02 kafka_broker_id=2 ansible_ssh_host=192.168.0.62
sdw6-03 kafka_broker_id=3 ansible_ssh_host=192.168.0.63

# These are your zookeeper cluster nodes
[zk_servers]
sdw6-01 zk_id=1 ansible_ssh_host=192.168.0.61
sdw6-02 zk_id=2 ansible_ssh_host=192.168.0.62
sdw6-03 zk_id=3 ansible_ssh_host=192.168.0.63


$ vi group_vars/kafka_servers
~~~
package_download_path : "/tmp"
kafka:
  version: 2.8.1
  scala_version: 2.13
  installation_path: /usr/local
  download_mirror: http://apache.rediris.es/kafka
  configuration:
    port: 9092
    data_dir: /var/lib/kafka
    log_dirs: /tmp/lib/kafka/kafka-logs
    log_path: /var/log/kafka
    network_threads: 3
    disk_threads: 8
    num_partitions: 3
    so_snd_buff_bytes: 102400
    so_rcv_buff_bytes: 102400
    so_request_max_bytes: 104857600
    data_dir_recovery_threads: 1
    log_retention_hours: 24
    log_retention_bytes: 1073741824
    log_segment_bytes: 1073741824
    log_retention_check_interval: 300000
    log_cleaner_enable: false
    zk_connection_timeout: 60000
zookeeper:
  version: 3.7.0
  installation_path: /usr/local
  download_mirror: http://apache.rediris.es/zookeeper
  configuration:
    port: 2181
    log_path: /var/log/zookeeper
    data_dir: /var/lib/zookeeper
    tick_time: 2000
    init_limit: 5
    sync_limit: 2
  use_internal_zookeeper: 1
java:
  version: 8u101
  installation_path: /usr/java/jdk1.8.0_101
  build: b13
  platform: x86_64
  priority: 100
  download_mirror: http://download.oracle.com/otn-pub/java/jdk
  download_cookies: "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie"
~~~

$ vi setup-kafka.yml
~~~
- hosts: kafka_servers
  become: true
  roles:
    - firewall
    - java
    - kafka
~~~

$ make install


# Planning
Adding playbook to install and confgiure kafka / zookeeper monitor
