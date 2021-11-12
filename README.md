# What is Kafka-ZKCluster?
Kafka-ZKCluster is ansible playbook to deploy Apache Kafka that is a distributed event streaming platform using publish-subscribe topics.

# Kafka-ZKCluster Architecutre
![alt text](https://github.com/rokmc756/kafka-zkcluster/blob/main/roles/kafka/files/kafka-diagram.jpeg)


# Where is Kafka-ZKCluster from how is it changed?
Kafka-ZKCluster has been developing based on gpdb-ansible project - https://github.com/andreasscherbaum/gpdb-ansible. Andreas! Thanks for sharing it.
Since it only provide install GPDB on a single host GPFarmer support multiple hosts and many extensions to deploy them and support two
binary type, rpm and bin..

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


$ vi role/gpdb/var/main.yml
~~~
---
google_cloud: false

# number of Greenplum Database segments
gpdb_number_segments: 2               # Change how many instances want to run
gpdb_mirror_enable: true              # Enable if mirror instances is run or not
gpdb_spread_mirrors: "-S"             # Enable if spread mirror is used or not

# if you change the version, Ansible will attempt a database upgrade
# greenplum-db-4.3.9.0-build-1-RHEL5-x86_64.zip
gpdb_major_version: 5
gpdb_minor_version: 21.0
gpdb_build_version:
gpdb_rhel_name: 'rhel7'
gpdb_binary_type: 'zip'

smdw_hostname: "smdw6"
seg_serialized_install: False
gpdb_initdb_single: False
gpdb_initdb_with_standby: True
gpdb_network_range: "192.168.0.0"
gpdb_admin_password: "changeme"
~~~

$ vi role/gpcc/var/main.yml
~~~
---
# greenplum-cc-web-6.0.0-beta.5-rhel7_x86_64.zip
# greenplum-cc-web-4.7.0-LINUX-x86_64.zip
gpcc_major_version: 4
gpcc_minor_version: 7.0
gpcc_build_version:
gpcc_rhel_name: LINUX-
# gpcc_rhel_name: rhel7_
gpdb_initdb_only_single: false
gpdb_initdb_with_standby: true
gpcc_network_range: "192.168.0.0/24"
gpcc_subnet_range: 24
gpcc_password: "changeme"
~~~

$ vi role/gptext/var/main.yml
~~~
---
gptext_major_version: 3
gptext_minor_version: 3.0
gptext_patch_version:
gptext_build_version:
gptext_gpdb_version:
gptext_java_version: 1.8.0
gptext_rhel_name: rhel6
gptext_database_name: testdb
gptext_all_hosts: "mdw6 smdw6 sdw6-1 sdw6-2 sdw6-3"   # The number of all nodes should be 3, 5 or 7
~~~

$ vi role/madlib/var/main.yml
~~~
---
madlib_major_version: 1
madlib_minor_version: 15
madlib_patch_version: 1
madlib_gpdb_version: gp5
madlib_rhel_version: rhel7
madlib_database_name: testdb
madlib_mdw_hostname: mdw6
# madlib-1.15.1-gp5-rhel6-x86_64.tar.gz
# madlib-1.15.1-gp4.3orca-rhel5-x86_64.tar.gz
~~~

$ vi role/postgis/var/mail.yml
~~~
---
postgis_prefix_major_version:
postgis_major_version: 2
postgis_minor_version: 1
postgis_patch_version: .5+pivotal.2
postgis_gpdb_version: gp5
postgis_rhel_version: rhel7
postgis_database_name: testdb
# postgis-2.1.5+pivotal.2-gp5-rhel7-x86_64.gppkgg
# postgis-ossv2.0.3_pv2.0.2_gpdb4.3orca-rhel5-x86_64.gppkg
~~~

$ vi install-host.yml
~~~
---
- hosts: all
  become: yes
  roles:
    - gpdb
    - gptext

- hosts: mdw6
  become: yes
  roles:
    - gpcc
    - madlib
    - postgis
~~~

$ make init

$ make install


# Planning
Adding playbook to remove GPDB and other extensions

Adding playbook to update GPDB and other extensions

Converting Makefile.init from original project.

Documenting how to make OS template for GPDB and GPFarmer.


