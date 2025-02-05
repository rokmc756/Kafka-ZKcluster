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
ANSIBLE_TARGET_PASS="changeme"  # It should be changed with password of sudo user in managed nodes that kafka would be installed.
~~ snip
```

#### 3) Configure hostname / ip addresses / username into inventory file to run ansible playbook
```
$ vi ansible-hosts-rk9
[all:vars]
ssh_key_filename="id_rsa"
remote_machine_username="jomoon"
remote_machine_password="changeme"


[monitor]
rk9-node01 ansible_ssh_host=192.168.2.191


[standby]
rk9-node02 ansible_ssh_host=192.168.2.192


# These are your kafka cluster nodes
[kafka_brokers]
rk9-node03 kafka_broker_id=1 ansible_ssh_host=192.168.2.193
rk9-node04 kafka_broker_id=2 ansible_ssh_host=192.168.2.194
rk9-node05 kafka_broker_id=3 ansible_ssh_host=192.168.2.195


# These are your zookeeper cluster nodes
[zk_servers]
rk9-node03 zk_id=1 ansible_ssh_host=192.168.2.193
rk9-node04 zk_id=2 ansible_ssh_host=192.168.2.194
rk9-node05 zk_id=3 ansible_ssh_host=192.168.2.195
```

#### 4) Initialization Linux Host to install packages required and generate/exchange ssh keys between all hosts.
```
$ vi roles/hosts/vars/main.yml
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

$ make hosts r=init
$ make hosts r=uninit
```

#### 5) Configure variables for kafka version and location which will be installed as well as other parameters
```
$ vi group_vars/all.yml
~~ snip
_kafka:
  user: kafka
  group: kafka
  major_version: 3
  minor_version: 6
  patch_version: 2
  scala:
    major_version: 2
    minor_version: 12
  base_path: /usr/local
  download: false
  download_url: http://apache.rediris.es/kafka
  download_path: /tmp
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
    ipaddr0: "192.168.0.19"
    ipaddr1: "192.168.1.19"
    ipaddr2: "192.168.2.19"
  vms:
    rk9: [ "rk9-freeipa", "rk9-node01", "rk9-node02", "rk9-node03", "rk9-node04", "rk9-node05" ]
    ubt24: [ "rk9-freeipa", "ubt24-node01", "ubt24-node02", "ubt24-node03", "ubt24-node04", "ubt24-node05" ]
  debug_opt: ""  # --debug
~~ snip
```

#### 6) Configure variables for zookeeper version and location which will be installed as well as other parameters
```
$ vi group_vars/all.yml
~~ snip
_zookeeper:
  user: zookeeper
  group: zookeeper
  major_version: 3
  minor_version: 9
  patch_version: 3
  base_path: /usr/local
  download: false
  download_url: http://apache.rediris.es/zookeeper
  download_path: /tmp
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
    ipaddr0: "192.168.0.19"
    ipaddr1: "192.168.1.19"
    ipaddr2: "192.168.2.19"
~~ snip
```

#### 7) Configure variables for java version and location
```
$ vi group_vars/all.yml
~~ snip
_jdk:
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
_kafka_ui:
  base_path: "/root"
  api_version: "0.7.2"
  jmx_port: 9997
  port: 8080
  oracle_java: false
  download: false
  download_url: "https://github.com/provectus/kafka-ui/releases/download"
  download_path: "/root"
~~ snip
```


#### 9) Configure Makefile to Install and Configure Zookeeper/Kafka/Kafka UI Conveniently by Make Command
```
$ vi Makefile
~~ snip
download:
        @ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -u ${USERNAME} download-kafka.yml --tags="download"


# For All Roles
%:
        @ln -sf ansible-hosts-rk9 ansible-hosts;
        @cat Makefile.tmp  | sed -e 's/temp/${*}/g' > Makefile.${*}

        @if [ "${*}" = "java" ] || [ "${*}" = "firewall" || [ "${*}" = "hosts" ] ; then\
                cat setup-temp.yml.tmp | sed -e 's/    - temp/    - ${*}/g' > setup-${*}.yml;\
        elif [ "${*}" = "zookeeper" ]; then\
                cat setup-kafka-temp.yml.tmp | sed -e 's/    - temp/    - ${*}/g' > setup-${*}.yml;\
        elif [ "${*}" = "kafka" ]; then\
                cat setup-kafka-temp.yml.tmp | sed -e 's/    - temp/    - ${*}/g' > setup-${*}.yml;\
        elif [ "${*}" = "kafka-ui" ]; then\
                cat setup-kafka-ui-temp.yml.tmp | sed -e 's/    - temp/    - ${*}/g' > setup-${*}.yml;\
        else\
                echo "No actions to temp";\
                exit;\
        fi

        @make -f Makefile.${*} r=${r} s=${s} c=${c} USERNAME=${USERNAME}
        @rm -f setup-${*}.yml Makefile.${*}
~~ snip
```


#### 10) Download All Software Binary and Save it to the role/XXXX/files Directory
```
$ make download
```

## How to Deploy Kafaka-ZKCluster
```
$ make firewall   s=enable
$ make java       s=setup
$ make zookeeper  s=install
$ make kafka      s=install
$ make kafka-ui   s=install
```

## How to Destroy Kafaka-ZKCluster
```
$ make kafka-ui   s=uninstall
$ make kafka      s=uninstall
$ make zookeeper  s=uninstall
$ make java       s=remove
$ make firewall   s=disable
```

## Reference
- https://github.com/sleighzy/ansible-kafka
- https://github.com/aleonsan/ansible-kafka


## Kafka Command Examples
- Check the List of Kafka Broker when using Independent Zookeeper. In case of using Dependent Zookeeper inside of Kafe zookeeper-shell.sh could be used instead of zkCli.sh.
~~~
$ zkCli.sh -server localhost:2181 ls /kafka/brokers/ids
~~ snip
WatchedEvent state:SyncConnected type:None path:null zxid: -1
[1, 2, 3]
~~ snip
~~~

- Check the Status of Kafka Broker when using Independent Zookeeper
~~~
$ zkCli.sh -server localhost:2181 get /kafka/brokers/ids/1
~~ snip
{"listener_security_protocol_map":{"PLAINTEXT":"PLAINTEXT"},"endpoints":["PLAINTEXT://rk9-node03.jtest.pivotal.io:9092"],"jmx_port":9997,"features":{},"host":"rk9-node03.jtest.pivotal.io","timestamp":"1725032975661","port":9092,"version":5}
~~ snip
~~~

- Show Topic List
~~~
$ kafka-topics.sh --bootstrap-server localhost:9092 --list
~~~

- Create Topic
~~~
$ kafka-topics.sh --create --bootstrap-server localhost:9092 --replication-factor 1 --partitions 1 --topic test
Created topic test.

$ kafka-topics.sh --create --bootstrap-server localhost:9092 --replication-factor 1 --partitions 1 --topic numtest
Created topic numtest.

$ kafka-topics.sh --create --bootstrap-server localhost:9092 --replication-factor 1 --partitions 1 --topic mytopic
Created topic numtest.
~~~

- Increase the Number of Partitons for Topic
~~~
$ kafka-topics.sh --alter --partitions 7 --topic test --bootstrap-server localhost:9092
~~~

- Describe the Topic
~~~
$ kafka-topics.sh --describe --bootstrap-server localhost:9092
Topic: test     TopicId: fMHGvWG-QhquwzgvOGIYow PartitionCount: 1       ReplicationFactor: 1    Configs: segment.bytes=1073741824
        Topic: test     Partition: 0    Leader: 1       Replicas: 1     Isr: 1
Topic: numtest  TopicId: yi5_3jhSRk2Qb1ar2rFUNQ PartitionCount: 1       ReplicationFactor: 1    Configs: segment.bytes=1073741824
        Topic: numtest  Partition: 0    Leader: 3       Replicas: 3     Isr: 3
~~~

- Delete Topic
~~~
# kafka-topics.sh --bootstrap-server localhost:9092 --delete --topic mytopic
~~~

- Check Leader Follower for Topic
~~~
# kafka-topics.sh --bootstrap-server localhost:9092 --topic mytopic --describe
Topic: mytopic  TopicId: PRpjpc_NS2u57WtUa955fQ PartitionCount: 1       ReplicationFactor: 1    Configs: segment.bytes=1073741824
        Topic: mytopic  Partition: 0    Leader: 3       Replicas: 3     Isr: 3
~~~

- Check the Offset of Topic and Partition
~~~
$ kafka-get-offsets.sh --bootstrap-server localhost:9092 --topic test.topic

# In case of --partitions or --topic-partitions partition could be specified
$ kafka-get-offsets.sh --bootstrap-server localhost:9092 --topic test.topic --partitions 0,1

# In case of using option --topic-partitions, 0-8, -5 (0~5), 6- (6~) is possible to represent for range
$ kafka-get-offsets.sh --bootstrap-server localhost:9092 --topic-partitions test.topic:0,test.topic2:1-3,test.topic3:5-,test.topic4:-8
~~~

- Trace Realtime Consuming Messages
~~~
# This option, --from-beginning should be consider since it read all messages saved.
$ kafka-console-consumer.sh --bootstrap-server localhost:9092 --from-beginning --topic numtest

# For Specific Partiton Messages Consuming
$ kafka/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --from-beginning --partition 1 --topic numtest
~~~


- Check Consumer Groups
~~~
# kafka-consumer-groups.sh  --bootstrap-server localhost:9092 --list
console-consumer-53426

# kafka-consumer-groups.sh  --bootstrap-server localhost:9092 --group console-consumer-53426 --describe
Consumer group 'console-consumer-53426' has no active members.
~~~

- Check Kafka Logs
~~~
# Check Server Log
$ less <Kafka Home Dir/logs/server.log

# Check Connect Log
$ less <Kafka Home Dir>/logs/connect.log
~~~


## Planning
- [X] Adding Playbook to Install and Confgiure Kafka / Zookeeper Monitor
- [] Configuring Auth for Kafka UI and Check if Configuring SSL is Possible
- [] Configuring Scheme Segistry and Ssql DB for Kafka UI

