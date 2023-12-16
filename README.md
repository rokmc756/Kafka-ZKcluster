## What is Kafka-ZKCluster?
Kafka-ZKCluster is ansible playbook to deploy Apache Kafka that is a distributed event streaming platform using publish-subscribe topics and Zookeeper that keeps track of status of the Kafka cluster nodes and it also keeps track of Kafka topics, partitions etc.
Zookeeper it self is allowing multiple clients to perform simultaneous reads and writes and acts as a shared configuration service within the system.

## Kafka-ZKCluster Architecutre
![alt text](https://raw.githubusercontent.com/rokmc756/kafka-zkcluster/main/roles/kafka/images/kafka-zkcluster-architecture2.webp)

## Where is Kafka-ZKCluster from how is it changed?
Kafka-ZKCluster has been developing based on https://github.com/sleighzy/ansible-kafka. Sleighzy! Thanks for sharing it.
Since it provide Oracle JDK install I've changed it to OpenJDK in grobal variables in a group_vars directory.
Additionally systemd configuration files for zookeeper and kafka has been changed as well.

## Supported Kafka and Zookeeper version
* Kafka
* Zookeeper

## Supported Platform and OS
* Virtual Machines
* Cloud Infrastructure
* Baremetal
* RHEL / CentOS and Rocky 6.x/7.x/8.x/9.x

## Prerequisite
MacOS or Fedora/CentOS/RHEL installed with ansible as ansible host.
At least three supported OS should be prepared with yum repository configured

## Prepare ansible host to run gpfarmer
* MacOS
```
$ xcode-select --install
$ brew install ansible
$ brew install https://raw.githubusercontent.com/kadwanev/bigboybrew/master/Library/Formula/sshpass.rb
```

* Fedora/CentOS/RHEL
```
$ sudo yum install ansible
$ sudo yum install sshpass
```

## Prepareing OS
Configure Yum / Local & EPEL Repostiory

## How to install and confgiure Kafaka-ZKCluster
#### 1) Clone playbook from github and move installation directory
```
$ git clone https://github.com/rokmc756/kafka-zkcluster
$ cd kafka-zkcluster
```

#### 2) Configure user password of sudo user for Kafka's VMs
```
$ vi Makefile
~~ snip
ANSIBLE_HOST_PASS="changeme"  # It should be changed with password of user in ansible host that gpfarmer would be run.
ANSIBLE_TARGET_PASS="changeme"  # It should be changed with password of sudo user in managed nodes that gpdb would be installed.
~~ snip
```

#### 3) Configure hostname / ip addresses / username into inventory file to run ansible playbook
```
$ vi ansible-hosts
[all:vars]
ssh_key_filename="id_rsa"
remote_machine_username="jomoon"
remote_machine_password="changeme"

# These are your kafka cluster nodes
[monitor]
co7-master kafka_broker_id=4 ansible_ssh_host=192.168.0.61

# These are your kafka cluster nodes
[brokers]
co7-node01 kafka_broker_id=1 ansible_ssh_host=192.168.0.63
co7-node02 kafka_broker_id=2 ansible_ssh_host=192.168.0.64
co7-node03 kafka_broker_id=3 ansible_ssh_host=192.168.0.65

# These are your zookeeper cluster nodes
[zookeepers]
co7-node01 zk_id=1 ansible_ssh_host=192.168.0.63
co7-node02 zk_id=2 ansible_ssh_host=192.168.0.64
co7-node03 zk_id=3 ansible_ssh_host=192.168.0.65
```

#### 4) Configure variables for kafka version and location which will be installed as well as other parameters
```
$ vi roles/kafka/vars/main.yml
package_download_path : "/tmp"
kafka:
  version: 3.5.1
  scala_version: 2.13
  installation_path: /usr/local
  download_mirror: http://apache.rediris.es/kafka
  download_kafka: false
  configuration:
    port: 9092
    data_dir: /usr/local/kafka/data
    log_dirs: /usr/local/kafka/logs
    log_path: /usr/local/kafka/log
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
  #  log_dirs: /tmp/lib/kafka/kafka-logs
  #  data_dir: /var/lib/kafka
  #  log_dirs: /usr/local/kafka/logs
  #  log_path: /var/log/kafka
zookeeper:
  version: 3.8.1
  installation_path: /usr/local
  download_mirror: http://apache.rediris.es/zookeeper
  download_zookeeper: false
  configuration:
    port: 2181
    log_path: /var/log/zookeeper
    data_dir: /var/lib/zookeeper
    tick_time: 2000
    init_limit: 5
    sync_limit: 2
  use_internal_zookeeper: false
```

#### 5) Configure variables for zookeeper version and location which will be installed as well as other parameters
```
$ vi roles/zookeeper/vars/main.yml
package_download_path : "/tmp"
zookeeper:
  version: 3.9.1
  installation_path: /usr/local
  download_mirror: http://apache.rediris.es/zookeeper
  download_zookeeper: false
  configuration:
    port: 2181
    log_path: /usr/local/apache-zookeeper/log
    data_dir: /usr/local/apache-zookeeper/data
    tick_time: 2000
    init_limit: 5
    sync_limit: 2
  use_internal_zookeeper: false
#  log_path: /var/log/zookeeper
#  data_dir: /var/lib/zookeeper
```

#### 6) Configure variables for java version and location
```
$ vi roles/java/vars/main.yml
---
jvm_home: "/usr/lib/jvm"
install_oracle_java: false
oracle_java_version: "13.0.2"
```

#### 7) Configure variables for Kafka UI version and other parameters
```
$ vi roles/kafka-ui/vars/main.yml
kafka_ui_api_version: "0.7.1"
jmx_port: 9997
kafka_ui_port: 8080
install_oracle_java: true
```

## How to Deploy Kafaka-ZKCluster
#### Configure ansible playbook to deploy Kafka-ZKCluster and UI
```
$ vi install-kafka.yml
---
- hosts: brokers
  remote_user: root
  become: true
  roles:
    - java
    - firewall
    - zookeeper
    - kafka

- hosts: monitor
  remote_user: root
  become: true
  roles:
    - firewall
    - java
    - kafka-ui

$ make install
```

## How to Destroy Kafaka-ZKCluster
#### Configure ansible playbook to destroy Kafka-ZKCluster and Kafka UI
```
$ vi uninstall-kafka.yml
---
- hosts: monitor
  remote_user: root
  become: true
  roles:
    - kafka-ui
    - firewall
    - java

- hosts: brokers
  remote_user: root
  become: true
  roles:
    - java
    - firewall
    - zookeeper
    - kafka

$ make uninstall
```

## Planning
- Adding playbook to install and confgiure kafka / zookeeper monitor
- Configuring Auth for Kafka UI ( Check if configuration SSL is possible? )
- Configuring Scheme Segistry and Ssql DB for Kafka UI
- Testing Confluent Platform recent version 7.3
