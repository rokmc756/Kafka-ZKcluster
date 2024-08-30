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
* Kafka UI

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
$ git clone https://github.com/rokmc756/Kafka-ZKcluster
$ cd Kafka-ZKcluster
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

[monitor]
rk8-node01 ansible_ssh_host=192.168.0.71

# These are your kafka cluster nodes
[kafka_brokers]
rk9-node03 kafka_broker_id=1 ansible_ssh_host=192.168.0.73
rk9-node04 kafka_broker_id=2 ansible_ssh_host=192.168.0.74
rk9-node05 kafka_broker_id=3 ansible_ssh_host=192.168.0.75

# These are your zookeeper cluster nodes
[zk_servers]
rk9-node03 zk_id=1 ansible_ssh_host=192.168.0.73
rk9-node04 zk_id=2 ansible_ssh_host=192.168.0.74
rk9-node05 zk_id=3 ansible_ssh_host=192.168.0.75
```

#### 4) Initialization Linux Host to install packages required and generate/exchange ssh keys between all hosts.
```
$ vi roles/init-hosts/vars/main.yml
ansible_ssh_pass: "changeme"
ansible_become_pass: "changeme"

sudo_user: "kafka"
sudo_group: "kafka"
local_sudo_user: "jomoon"
wheel_group: "wheel"            # RHEL / CentOS / Rocky / SUSE / OpenSUSE
# wheel_group: "sudo"           # Debian / Ubuntu
root_user_pass: "changeme"
sudo_user_pass: "changeme"
sudo_user_home_dir: "/home/{{ sudo_user }}"
domain_name: "jtest.pivotal.io"

make init
```

#### 5) Configure variables for kafka version and location which will be installed as well as other parameters
```
$ vi group_vars/all.yml
~~ snip
kafka:
  major_version: 3
  minor_version: 6
  patch_version: 2
  scala:
    major_version: 2
    minor_version: 12
  base_path: /usr/local
  download_url: http://apache.rediris.es/kafka
  download_path: /tmp
  download: false
  config:
    port: 9092
    log_dirs: /usr/local/kafka/logs
    log_path: /usr/local/kafka/log
    data_dir: /usr/local/kafka/data
    topic_dirs:
      - "data1"
      - "data2"
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
  net:
    type: "virtual"                # Or Physical
    gateway: "192.168.0.1"
    ipaddr0: "192.168.0.7"
    ipaddr1: "192.168.1.7"
    ipaddr2: "192.168.2.7"
~~ snip
```

#### 6) Configure variables for zookeeper version and location which will be installed as well as other parameters
```
$ vi group_vars/all.yml
~~ snip
zookeeper:
  major_version: 3
  minor_version: 9
  patch_version: 2
  base_path: /usr/local
  download_url: http://apache.rediris.es/zookeeper
  download_path: /tmp
  download: false
  config:
    port: 2181
    log_path: /usr/local/apache-zookeeper/log
    data_dir: /usr/local/apache-zookeeper/data
    tick_time: 2000
    init_limit: 5
    sync_limit: 2
  use_internal_zookeeper: false
  # log_path: /var/log/zookeeper
  # data_dir: /var/lib/zookeeper
  net:
    type: "virtual"                # Or Physical
    gateway: "192.168.0.1"
    ipaddr0: "192.168.0.7"
    ipaddr1: "192.168.1.7"
    ipaddr2: "192.168.2.7"
~~ snip
```

#### 7) Configure variables for java version and location
```
$ vi group_vars/all.yml
~~ snip
jdk:
  oss:
    install: true
    jvm_home: "/usr/lib/jvm"
    major_version: 1
    minor_version: 8
    patch_version: 0
  oracle:
    install: false
    jvm_home: "/usr/lib/jvm"
    major_version: 13
    minor_version: 0
    patch_version: 2
~~ snip
```

#### 8) Configure variables for Kafka UI version and other parameters
```
$ vi group_vars/all.yml
~~ snip
kafka_ui:
  api_version: "0.7.2"
  jmx_port: 9997
  port: 8080
  oracle_java: false
~~ snip
```

## How to Deploy Kafaka-ZKCluster
#### Configure ansible playbook to deploy Kafka-ZKCluster and UI
```
$ vi install-kafka.yml
- hosts: all
  become: true
  roles:
    - firewall
    - java

- hosts: kafka_brokers
  become: true
  roles:
    - zookeeper
    - kafka

- hosts: monitor
  become: true
  roles:
    - kafka-ui

$ make install
```

## How to Destroy Kafaka-ZKCluster
#### Configure ansible playbook to destroy Kafka-ZKCluster and Kafka UI
```
$ vi uninstall-kafka.yml
---
- hosts: kafka_brokers
  become: true
  roles:
    - kafka
    - zookeeper

- hosts: monitor
  become: true
  roles:
    - kafka-ui

- hosts: all
  become: true
  roles:
    - java
    - firewall

$ make uninstall

$ make uninit
```

## Planning
- Adding playbook to install and confgiure kafka / zookeeper monitor
- Configuring Auth for Kafka UI ( Check if configuration SSL is possible? )
- Configuring Scheme Segistry and Ssql DB for Kafka UI
- Testing Confluent Platform Recent Version 7.3
